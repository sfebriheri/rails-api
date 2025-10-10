# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/job_descriptions', type: :request do
  path '/api/v1/job_descriptions' do
    get('List job descriptions') do
      tags 'Reference Documents'
      description 'Retrieve all available job descriptions for evaluation reference'
      produces 'application/json'

      response(200, 'successful') do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/JobDescription' }

        examples 'application/json' => [
          {
            id: 1,
            title: 'Senior Software Engineer',
            description: 'We are looking for an experienced software engineer to join our team...',
            requirements: ['5+ years experience', 'Ruby on Rails', 'PostgreSQL', 'API development'],
            created_at: '2024-01-15T10:00:00.000Z',
            updated_at: '2024-01-15T10:00:00.000Z'
          },
          {
            id: 2,
            title: 'Full Stack Developer',
            description: 'Join our dynamic team as a full stack developer...',
            requirements: ['3+ years experience', 'React', 'Node.js', 'MongoDB'],
            created_at: '2024-01-15T11:00:00.000Z',
            updated_at: '2024-01-15T11:00:00.000Z'
          }
        ]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
        end
      end
    end

    post('Create job description') do
      tags 'Reference Documents'
      description 'Create a new job description for evaluation reference'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :job_description, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: 'Senior Software Engineer' },
          description: { type: :string, example: 'We are looking for an experienced software engineer...' },
          requirements: { 
            type: :array, 
            items: { type: :string },
            example: ['5+ years experience', 'Ruby on Rails', 'PostgreSQL']
          }
        },
        required: ['title', 'description']
      }

      response(201, 'created') do
        schema '$ref' => '#/components/schemas/JobDescription'

        examples 'application/json' => {
          id: 3,
          title: 'Senior Software Engineer',
          description: 'We are looking for an experienced software engineer to join our team...',
          requirements: ['5+ years experience', 'Ruby on Rails', 'PostgreSQL', 'API development'],
          created_at: '2024-01-15T12:00:00.000Z',
          updated_at: '2024-01-15T12:00:00.000Z'
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('id')
          expect(data).to have_key('title')
          expect(data).to have_key('description')
        end
      end

      response(422, 'unprocessable entity') do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          error: 'Validation failed',
          message: 'Title and description are required',
          details: { missing_fields: ['title', 'description'] }
        }

        run_test!
      end
    end
  end

  path '/api/v1/job_descriptions/{id}' do
    parameter name: 'id', in: :path, type: :integer, description: 'Job description ID'

    get('Show job description') do
      tags 'Reference Documents'
      description 'Retrieve a specific job description by ID'
      produces 'application/json'

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/JobDescription'

        examples 'application/json' => {
          id: 1,
          title: 'Senior Software Engineer',
          description: 'We are looking for an experienced software engineer to join our team...',
          requirements: ['5+ years experience', 'Ruby on Rails', 'PostgreSQL', 'API development'],
          created_at: '2024-01-15T10:00:00.000Z',
          updated_at: '2024-01-15T10:00:00.000Z'
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('id')
          expect(data).to have_key('title')
        end
      end

      response(404, 'not found') do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          error: 'Job description not found',
          message: 'No job description found with ID 999',
          details: { id: 999 }
        }

        run_test!
      end
    end

    delete('Delete job description') do
      tags 'Reference Documents'
      description 'Delete a job description by ID'
      produces 'application/json'

      response(204, 'no content') do
        run_test!
      end

      response(404, 'not found') do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          error: 'Job description not found',
          message: 'No job description found with ID 999',
          details: { id: 999 }
        }

        run_test!
      end
    end
  end
end