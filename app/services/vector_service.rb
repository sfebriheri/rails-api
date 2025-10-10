class VectorService
  def initialize
    @llm_service = LlmService.new
  end

  def store_document_embeddings(document)
    return unless document.processed? && document.extracted_text.present?

    # Split text into chunks
    chunks = split_text_into_chunks(document.extracted_text)
    
    chunks.each_with_index do |chunk, index|
      # Generate embedding
      embedding = @llm_service.generate_embedding(chunk)
      
      # Store in database
      VectorEmbedding.create!(
        document: document,
        content_chunk: chunk,
        embedding_vector: embedding,
        chunk_index: index,
        metadata: {
          chunk_size: chunk.length,
          document_type: document.document_type,
          created_at: Time.current.iso8601
        }
      )
    end

    Rails.logger.info "Stored #{chunks.size} embeddings for document #{document.id}"
  end

  def search_similar_content(query, document_types: nil, limit: 5)
    # Generate query embedding
    query_embedding = @llm_service.generate_embedding(query)
    
    # Search for similar embeddings
    similar_results = VectorEmbedding.search_similar(
      query_embedding,
      limit: limit,
      document_types: document_types
    )
    
    # Format results
    similar_results.map do |result|
      {
        content: result[:embedding].content_chunk,
        similarity: result[:similarity],
        document_type: result[:embedding].document.document_type,
        document_id: result[:embedding].document.id,
        metadata: result[:embedding].metadata
      }
    end
  end

  def retrieve_context_for_evaluation(evaluation_type, job_title, limit: 10)
    case evaluation_type
    when 'cv'
      document_types = ['job_description', 'scoring_rubric']
      query = "CV evaluation criteria for #{job_title} position technical skills experience requirements"
    when 'project'
      document_types = ['case_study', 'scoring_rubric']
      query = "Project evaluation criteria code quality implementation requirements for #{job_title}"
    else
      raise ArgumentError, "Invalid evaluation type: #{evaluation_type}"
    end

    results = search_similar_content(query, document_types: document_types, limit: limit)
    
    # Combine content chunks
    context_text = results.map { |r| r[:content] }.join("\n\n---\n\n")
    
    {
      context: context_text,
      sources: results.map { |r| 
        {
          document_type: r[:document_type],
          document_id: r[:document_id],
          similarity: r[:similarity]
        }
      }
    }
  end

  private

  def split_text_into_chunks(text, chunk_size: 1000, overlap: 200)
    chunks = []
    start = 0
    
    while start < text.length
      end_pos = [start + chunk_size, text.length].min
      
      # Try to break at sentence boundary
      if end_pos < text.length
        last_period = text.rindex('.', end_pos)
        last_newline = text.rindex("\n", end_pos)
        break_point = [last_period, last_newline].compact.max
        
        end_pos = break_point + 1 if break_point && break_point > start + chunk_size / 2
      end
      
      chunk = text[start...end_pos].strip
      chunks << chunk if chunk.length > 50 # Skip very short chunks
      
      start = end_pos - overlap
      break if start >= text.length
    end
    
    chunks
  end
end