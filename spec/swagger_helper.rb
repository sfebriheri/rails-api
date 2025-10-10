# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'AI-Powered Job Application Screening Service API',
        version: 'v1',
        description: 'API for intelligent resume and portfolio assessment platform',
        contact: {
          name: 'API Support',
          email: 'support@example.com'
        },
        license: {
          name: 'MIT',
          url: 'https://opensource.org/licenses/MIT'
        }
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        },
        {
          url: 'https://api.example.com',
          description: 'Production server'
        }
      ],
      components: {
        schemas: {
          Document: {
            type: 'object',
            properties: {
              id: { type: 'integer', example: 1 },
              filename: { type: 'string', example: 'resume.pdf' },
              file_size: { type: 'integer', example: 245760 },
              content_type: { type: 'string', example: 'application/pdf' },
              processed: { type: 'boolean', example: false },
              job_title: { type: 'string', example: 'Senior Software Engineer' },
              created_at: { type: 'string', format: 'date-time' },
              updated_at: { type: 'string', format: 'date-time' }
            },
            required: ['id', 'filename', 'file_size', 'content_type', 'processed']
          },
          EvaluationJob: {
            type: 'object',
            properties: {
              assessment_id: { type: 'string', format: 'uuid', example: 'eca471ee-1841-4f1c-9aae-81645f1a8bc9' },
              evaluation_status: { 
                type: 'string', 
                enum: ['queued', 'processing', 'completed', 'failed'],
                example: 'completed'
              },
              resume_compatibility_score: { type: 'number', format: 'float', minimum: 0.0, maximum: 1.0, example: 0.85 },
              resume_analysis_feedback: { type: 'string', example: 'Strong technical background with relevant experience...' },
              portfolio_quality_score: { type: 'integer', minimum: 1, maximum: 5, example: 4 },
              portfolio_analysis_feedback: { type: 'string', example: 'Well-structured project demonstrating good practices...' },
              comprehensive_assessment_summary: { type: 'string', example: 'Highly qualified candidate recommended for interview...' },
              created_at: { type: 'string', format: 'date-time' },
              updated_at: { type: 'string', format: 'date-time' }
            },
            required: ['assessment_id', 'evaluation_status']
          },
          JobDescription: {
            type: 'object',
            properties: {
              id: { type: 'integer', example: 1 },
              title: { type: 'string', example: 'Senior Software Engineer' },
              description: { type: 'string', example: 'We are looking for an experienced software engineer...' },
              requirements: { type: 'array', items: { type: 'string' }, example: ['5+ years experience', 'Ruby on Rails', 'PostgreSQL'] },
              created_at: { type: 'string', format: 'date-time' },
              updated_at: { type: 'string', format: 'date-time' }
            },
            required: ['id', 'title', 'description']
          },
          Article: {
            type: 'object',
            properties: {
              id: { type: 'integer', example: 1 },
              title: { type: 'string', example: 'Getting Started with AI' },
              content: { type: 'string', example: 'This article covers the basics of AI...' },
              author: { type: 'string', example: 'John Doe' },
              published: { type: 'boolean', example: true },
              created_at: { type: 'string', format: 'date-time' },
              updated_at: { type: 'string', format: 'date-time' }
            },
            required: ['id', 'title', 'content']
          },
          Error: {
            type: 'object',
            properties: {
              error: { type: 'string', example: 'Invalid request parameters' },
              message: { type: 'string', example: 'The uploaded file must be a PDF' },
              details: { type: 'object', example: { field: 'cv', issue: 'invalid_format' } }
            },
            required: ['error']
          }
        },
        securitySchemes: {
          Bearer: {
            type: 'http',
            scheme: 'bearer',
            bearerFormat: 'JWT'
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end