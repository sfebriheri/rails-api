# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/case_studies', type: :request do
  path '/api/v1/case_studies' do
    get('List case studies') do
      tags 'Reference Documents'
      description 'Retrieve all available case studies for evaluation reference'
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, description: 'Page number for pagination', required: false
      parameter name: :per_page, in: :query, type: :integer, description: 'Number of items per page', required: false
      parameter name: :difficulty, in: :query, type: :string, description: 'Filter by difficulty level', required: false

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 case_studies: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       title: { type: :string },
                       description: { type: :string },
                       difficulty: { type: :string, enum: ['beginner', 'intermediate', 'advanced'] },
                       requirements: { type: :array, items: { type: :string } },
                       evaluation_criteria: { type: :array, items: { type: :string } },
                       created_at: { type: :string, format: :datetime },
                       updated_at: { type: :string, format: :datetime }
                     }
                   }
                 },
                 pagination: {
                   type: :object,
                   properties: {
                     current_page: { type: :integer },
                     total_pages: { type: :integer },
                     total_count: { type: :integer },
                     per_page: { type: :integer }
                   }
                 }
               }

        examples 'application/json' => {
          case_studies: [
            {
              id: 1,
              title: 'E-commerce API Development',
              description: 'Build a RESTful API for an e-commerce platform with user authentication, product management, and order processing.',
              difficulty: 'intermediate',
              requirements: ['Ruby on Rails', 'PostgreSQL', 'JWT Authentication', 'API Documentation'],
              evaluation_criteria: ['Code Quality', 'API Design', 'Database Schema', 'Testing Coverage', 'Documentation'],
              created_at: '2024-01-15T10:00:00.000Z',
              updated_at: '2024-01-15T10:00:00.000Z'
            },
            {
              id: 2,
              title: 'Real-time Chat Application',
              description: 'Develop a real-time chat application with WebSocket support, user presence, and message history.',
              difficulty: 'advanced',
              requirements: ['WebSockets', 'Redis', 'Background Jobs', 'Real-time Features'],
              evaluation_criteria: ['Real-time Implementation', 'Scalability', 'Performance', 'User Experience'],
              created_at: '2024-01-14T15:00:00.000Z',
              updated_at: '2024-01-14T15:00:00.000Z'
            }
          ],
          pagination: {
            current_page: 1,
            total_pages: 3,
            total_count: 25,
            per_page: 10
          }
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('case_studies')
          expect(data['case_studies']).to be_an(Array)
        end
      end
    end

    post('Create case study') do
      tags 'Reference Documents'
      description 'Create a new case study for evaluation reference'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :case_study, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: 'E-commerce API Development' },
          description: { type: :string, example: 'Build a RESTful API for an e-commerce platform...' },
          difficulty: { type: :string, enum: ['beginner', 'intermediate', 'advanced'], example: 'intermediate' },
          requirements: { 
            type: :array, 
            items: { type: :string },
            example: ['Ruby on Rails', 'PostgreSQL', 'JWT Authentication']
          },
          evaluation_criteria: { 
            type: :array, 
            items: { type: :string },
            example: ['Code Quality', 'API Design', 'Database Schema']
          }
        },
        required: ['title', 'description', 'difficulty']
      }

      response(201, 'created') do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 description: { type: :string },
                 difficulty: { type: :string },
                 requirements: { type: :array, items: { type: :string } },
                 evaluation_criteria: { type: :array, items: { type: :string } },
                 created_at: { type: :string, format: :datetime },
                 updated_at: { type: :string, format: :datetime }
               }

        examples 'application/json' => {
          id: 3,
          title: 'E-commerce API Development',
          description: 'Build a RESTful API for an e-commerce platform with user authentication, product management, and order processing.',
          difficulty: 'intermediate',
          requirements: ['Ruby on Rails', 'PostgreSQL', 'JWT Authentication', 'API Documentation'],
          evaluation_criteria: ['Code Quality', 'API Design', 'Database Schema', 'Testing Coverage', 'Documentation'],
          created_at: '2024-01-15T12:00:00.000Z',
          updated_at: '2024-01-15T12:00:00.000Z'
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('id')
          expect(data).to have_key('title')
          expect(data).to have_key('difficulty')
        end
      end

      response(422, 'unprocessable entity') do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          error: 'Validation failed',
          message: 'Title, description, and difficulty are required',
          details: { missing_fields: ['title', 'description', 'difficulty'] }
        }

        run_test!
      end
    end
  end

  path '/api/v1/case_studies/{id}' do
    parameter name: 'id', in: :path, type: :integer, description: 'Case study ID'

    get('Show case study') do
      tags 'Reference Documents'
      description 'Retrieve a specific case study by ID'
      produces 'application/json'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 description: { type: :string },
                 difficulty: { type: :string },
                 requirements: { type: :array, items: { type: :string } },
                 evaluation_criteria: { type: :array, items: { type: :string } },
                 detailed_instructions: { type: :string },
                 sample_data: { type: :object },
                 created_at: { type: :string, format: :datetime },
                 updated_at: { type: :string, format: :datetime }
               }

        examples 'application/json' => {
          id: 1,
          title: 'E-commerce API Development',
          description: 'Build a RESTful API for an e-commerce platform with user authentication, product management, and order processing.',
          difficulty: 'intermediate',
          requirements: ['Ruby on Rails', 'PostgreSQL', 'JWT Authentication', 'API Documentation'],
          evaluation_criteria: ['Code Quality', 'API Design', 'Database Schema', 'Testing Coverage', 'Documentation'],
          detailed_instructions: 'Create a comprehensive e-commerce API that includes user registration and authentication, product catalog management, shopping cart functionality, and order processing. The API should follow RESTful principles and include proper error handling, validation, and documentation.',
          sample_data: {
            users: [{ name: 'John Doe', email: 'john@example.com' }],
            products: [{ name: 'Laptop', price: 999.99, category: 'Electronics' }]
          },
          created_at: '2024-01-15T10:00:00.000Z',
          updated_at: '2024-01-15T10:00:00.000Z'
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('id')
          expect(data).to have_key('title')
          expect(data).to have_key('detailed_instructions')
        end
      end

      response(404, 'not found') do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          error: 'Case study not found',
          message: 'No case study found with ID 999',
          details: { id: 999 }
        }

        run_test!
      end
    end

    delete('Delete case study') do
      tags 'Reference Documents'
      description 'Delete a case study by ID'
      produces 'application/json'

      response(204, 'no content') do
        run_test!
      end

      response(404, 'not found') do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          error: 'Case study not found',
          message: 'No case study found with ID 999',
          details: { id: 999 }
        }

        run_test!
      end
    end
  end
end