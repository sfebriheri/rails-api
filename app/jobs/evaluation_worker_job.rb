class EvaluationWorkerJob < ApplicationJob
  queue_as :evaluation

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(evaluation_job_id)
    evaluation_job = EvaluationJob.find(evaluation_job_id)

    Rails.logger.info "Starting evaluation for job #{evaluation_job.job_id}"

    evaluation_job.start_processing!

    # Step 1: CV Evaluation
    cv_results = evaluate_cv(evaluation_job)

    # Step 2: Project Report Evaluation
    project_results = evaluate_project_report(evaluation_job)

    # Step 3: Final Analysis
    overall_summary = generate_overall_summary(evaluation_job, cv_results, project_results)

    # Combine results
    final_results = {
      cv_match_rate: cv_results[:match_rate],
      cv_feedback: cv_results[:feedback],
      project_score: project_results[:score],
      project_feedback: project_results[:feedback],
      overall_summary: overall_summary
    }

    evaluation_job.complete!(final_results)

    Rails.logger.info "Evaluation completed for job #{evaluation_job.job_id}"

  rescue => e
    Rails.logger.error "Evaluation failed for job #{evaluation_job_id}: #{e.message}"
    evaluation_job&.fail!(e.message)
    raise
  end

  private

  def evaluate_cv(evaluation_job)
    cv_document = evaluation_job.cv_document
    job_title = evaluation_job.job_title

    # Check if text was extracted
    if cv_document.extracted_text.blank?
      raise "CV document text extraction failed or returned empty content"
    end

    # Retrieve relevant context from job descriptions and CV scoring rubrics
    context = retrieve_context(['job_description', 'scoring_rubric'],
                              "CV evaluation for #{job_title}")

    # Prepare prompt for CV evaluation
    prompt = build_cv_evaluation_prompt(cv_document.extracted_text, job_title, context)

    # Call LLM
    response = call_llm(prompt, temperature: 0.3)

    # Parse response
    parse_cv_response(response)
  end

  def evaluate_project_report(evaluation_job)
    project_document = evaluation_job.project_document
    job_title = evaluation_job.job_title

    # Check if text was extracted
    if project_document.extracted_text.blank?
      raise "Project document text extraction failed or returned empty content"
    end

    # Retrieve relevant context from case studies and project scoring rubrics
    context = retrieve_context(['case_study', 'scoring_rubric'],
                              "Project evaluation for #{job_title}")

    # Prepare prompt for project evaluation
    prompt = build_project_evaluation_prompt(project_document.extracted_text, job_title, context)

    # Call LLM
    response = call_llm(prompt, temperature: 0.3)

    # Parse response
    parse_project_response(response)
  end

  def generate_overall_summary(evaluation_job, cv_results, project_results)
    job_title = evaluation_job.job_title

    prompt = build_summary_prompt(job_title, cv_results, project_results)

    response = call_llm(prompt, temperature: 0.4)

    response.strip
  end

  def retrieve_context(document_types, query)
    # Generate query embedding
    query_embedding = generate_embedding(query)

    # Search for similar content
    similar_embeddings = VectorEmbedding.search_similar(
      query_embedding,
      limit: 10,
      document_types: document_types
    )

    # Extract relevant text chunks
    if similar_embeddings.blank?
      "No relevant context found for #{document_types.join(', ')}"
    else
      similar_embeddings.map { |item| item[:embedding].content_chunk }.join("\n\n")
    end
  end

  def build_cv_evaluation_prompt(cv_text, job_title, context)
    <<~PROMPT
      You are an expert HR professional evaluating a candidate's CV for the position of #{job_title}.

      CONTEXT (Job Requirements and Scoring Criteria):
      #{context}

      CANDIDATE CV:
      #{cv_text}

      Please evaluate this CV and provide:
      1. A match rate between 0.0 and 1.0 (where 1.0 is perfect match)
      2. Detailed feedback explaining strengths and areas for improvement

      Focus on:
      - Technical skills alignment
      - Experience level and relevance
      - Achievements and impact
      - Cultural fit indicators

      Respond in JSON format:
      {
        "match_rate": 0.XX,
        "feedback": "Detailed feedback here..."
      }
    PROMPT
  end

  def build_project_evaluation_prompt(project_text, job_title, context)
    <<~PROMPT
      You are an expert technical evaluator assessing a candidate's project report for the position of #{job_title}.

      CONTEXT (Case Study Requirements and Scoring Criteria):
      #{context}

      PROJECT REPORT:
      #{project_text}

      Please evaluate this project report and provide:
      1. A score between 1.0 and 5.0 (where 5.0 is excellent)
      2. Detailed feedback on the implementation

      Focus on:
      - Correctness and requirement fulfillment
      - Code quality and architecture
      - Error handling and resilience
      - Documentation quality
      - Creativity and bonus features

      Respond in JSON format:
      {
        "score": X.X,
        "feedback": "Detailed feedback here..."
      }
    PROMPT
  end

  def build_summary_prompt(job_title, cv_results, project_results)
    <<~PROMPT
      You are an expert hiring manager providing a final assessment for a #{job_title} candidate.

      CV EVALUATION:
      - Match Rate: #{cv_results[:match_rate]}
      - Feedback: #{cv_results[:feedback]}

      PROJECT EVALUATION:
      - Score: #{project_results[:score]}/5.0
      - Feedback: #{project_results[:feedback]}

      Provide a concise 3-5 sentence overall summary that includes:
      - Key strengths of the candidate
      - Main areas for improvement or concerns
      - Hiring recommendation

      Be specific and actionable in your assessment.
    PROMPT
  end

  def call_llm(prompt, temperature: 0.3)
    llm_service = LlmService.new

    begin
      Timeout.timeout(ENV.fetch('EVALUATION_TIMEOUT', 300).to_i) do
        llm_service.chat_completion(prompt, temperature: temperature, max_tokens: 2000)
      end
    rescue Timeout::Error
      Rails.logger.error "LLM request timeout for evaluation"
      raise "LLM evaluation request exceeded timeout limit"
    rescue LlmService::LlmError => e
      Rails.logger.error "LLM service error: #{e.message}"
      raise "LLM evaluation failed: #{e.message}"
    end
  end

  def parse_cv_response(response)
    begin
      parsed = JSON.parse(response)
      {
        match_rate: parsed['match_rate'].to_f,
        feedback: parsed['feedback']
      }
    rescue JSON::ParserError
      # Fallback if JSON parsing fails
      {
        match_rate: 0.5,
        feedback: response
      }
    end
  end

  def parse_project_response(response)
    begin
      parsed = JSON.parse(response)
      {
        score: parsed['score'].to_f,
        feedback: parsed['feedback']
      }
    rescue JSON::ParserError
      # Fallback if JSON parsing fails
      {
        score: 3.0,
        feedback: response
      }
    end
  end

  def generate_embedding(text)
    llm_service = LlmService.new

    begin
      llm_service.generate_embedding(text)
    rescue LlmService::LlmError => e
      Rails.logger.error "Embedding generation failed: #{e.message}"
      raise "Failed to generate embedding: #{e.message}"
    end
  end
end
