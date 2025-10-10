# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/documents', type: :request do
  path '/api/v1/upload' do
    post('Upload documents for evaluation') do
      tags 'Document Upload'
      description 'Upload CV and project report documents for AI-powered evaluation'
      consumes 'multipart/form-data'
      produces 'application/json'

      parameter name: :cv, in: :formData, type: :file, required: true, description: 'CV/Resume PDF file'
      parameter name: :project_report, in: :formData, type: :file, required: false, description: 'Project report PDF file'
      parameter name: :job_title, in: :formData, type: :string, required: true, description: 'Target job title for evaluation'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 cv: { '$ref' => '#/components/schemas/Document' },
                 project_report: { '$ref' => '#/components/schemas/Document' }
               },
               required: ['cv']

        examples 'application/json' => {
          cv: {
            id: 3,
            filename: 'sample_cv.pdf',
            file_size: 245760,
            content_type: 'application/pdf',
            processed: false,
            job_title: 'Senior Software Engineer',
            created_at: '2024-01-15T10:30:45.123Z',
            updated_at: '2024-01-15T10:30:45.123Z'
          },
          project_report: {
            id: 4,
            filename: 'sample_project_report.pdf',
            file_size: 512000,
            content_type: 'application/pdf',
            processed: false,
            job_title: 'Senior Software Engineer',
            created_at: '2024-01-15T10:30:45.456Z',
            updated_at: '2024-01-15T10:30:45.456Z'
          }
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('cv')
          expect(data['cv']).to have_key('id')
          expect(data['cv']).to have_key('filename')
        end
      end

      response(400, 'bad request') do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          error: 'Invalid file format',
          message: 'Only PDF files are supported',
          details: { field: 'cv', issue: 'invalid_format' }
        }

        run_test!
      end

      response(422, 'unprocessable entity') do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          error: 'Missing required parameters',
          message: 'CV file and job title are required',
          details: { missing_fields: ['cv', 'job_title'] }
        }

        run_test!
      end

      response(413, 'payload too large') do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          error: 'File too large',
          message: 'File size must be less than 10MB',
          details: { max_size: '10MB', received_size: '15MB' }
        }

        run_test!
      end
    end
  end
end