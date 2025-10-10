# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/evaluations', type: :request do
  path '/api/v1/evaluate' do
    post('Trigger evaluation process') do
      tags 'Evaluation Management'
      description 'Start AI-powered evaluation of uploaded documents'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :evaluation_request, in: :body, schema: {
        type: :object,
        properties: {
          job_title: { type: :string, example: 'Senior Software Engineer' },
          cv_document_id: { type: :integer, example: 3 },
          project_document_id: { type: :integer, example: 4 }
        },
        required: ['job_title', 'cv_document_id']
      }

      response(202, 'evaluation queued') do
        schema type: :object,
               properties: {
                 assessment_id: { type: :string, format: :uuid, example: 'eca471ee-1841-4f1c-9aae-81645f1a8bc9' },
                 evaluation_status: { type: :string, enum: ['queued'], example: 'queued' }
               },
               required: ['assessment_id', 'evaluation_status']

        examples 'application/json' => {
          assessment_id: 'eca471ee-1841-4f1c-9aae-81645f1a8bc9',
          evaluation_status: 'queued'
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('assessment_id')
          expect(data).to have_key('evaluation_status')
          expect(data['evaluation_status']).to eq('queued')
        end
      end

      response(400, 'bad request') do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          error: 'Invalid document ID',
          message: 'CV document not found',
          details: { cv_document_id: 999 }
        }

        run_test!
      end

      response(422, 'unprocessable entity') do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          error: 'Missing required parameters',
          message: 'Job title and CV document ID are required',
          details: { missing_fields: ['job_title', 'cv_document_id'] }
        }

        run_test!
      end
    end
  end

  path '/api/v1/result/{id}' do
    parameter name: 'id', in: :path, type: :string, format: :uuid, description: 'Assessment ID'

    get('Retrieve evaluation results') do
      tags 'Evaluation Management'
      description 'Get the results of a completed evaluation'
      produces 'application/json'

      response(200, 'evaluation completed') do
        schema '$ref' => '#/components/schemas/EvaluationJob'

        examples 'application/json' => {
          assessment_id: 'eca471ee-1841-4f1c-9aae-81645f1a8bc9',
          evaluation_status: 'completed',
          resume_compatibility_score: 0.85,
          resume_analysis_feedback: 'Strong candidate with solid technical foundation. Demonstrates excellent problem-solving skills and code quality. Recommended for next interview round with focus on AI/ML knowledge assessment.',
          portfolio_quality_score: 4,
          portfolio_analysis_feedback: 'Excellent project structure and implementation. Shows deep understanding of software engineering principles and best practices. Clean code architecture with proper testing coverage.',
          comprehensive_assessment_summary: 'Highly qualified candidate with strong technical skills and practical experience. Project demonstrates advanced knowledge and professional development practices. Strongly recommend proceeding to technical interview stage.',
          created_at: '2024-01-15T10:30:45.123Z',
          updated_at: '2024-01-15T10:35:12.456Z'
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('assessment_id')
          expect(data).to have_key('evaluation_status')
          expect(data['evaluation_status']).to eq('completed')
        end
      end

      response(202, 'evaluation in progress') do
        schema type: :object,
               properties: {
                 assessment_id: { type: :string, format: :uuid },
                 evaluation_status: { type: :string, enum: ['queued', 'processing'] },
                 estimated_completion: { type: :string, example: '2-3 minutes' }
               }

        examples 'application/json' => {
          assessment_id: 'eca471ee-1841-4f1c-9aae-81645f1a8bc9',
          evaluation_status: 'processing',
          estimated_completion: '2-3 minutes'
        }

        run_test!
      end

      response(404, 'not found') do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          error: 'Evaluation not found',
          message: 'No evaluation found with the provided assessment ID',
          details: { assessment_id: 'invalid-uuid' }
        }

        run_test!
      end

      response(500, 'evaluation failed') do
        schema type: :object,
               properties: {
                 assessment_id: { type: :string, format: :uuid },
                 evaluation_status: { type: :string, enum: ['failed'] },
                 error: { type: :string },
                 retry_available: { type: :boolean }
               }

        examples 'application/json' => {
          assessment_id: 'eca471ee-1841-4f1c-9aae-81645f1a8bc9',
          evaluation_status: 'failed',
          error: 'LLM service temporarily unavailable',
          retry_available: true
        }

        run_test!
      end
    end
  end
end