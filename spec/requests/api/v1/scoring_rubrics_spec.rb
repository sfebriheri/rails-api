# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/scoring_rubrics', type: :request do
  path '/api/v1/scoring_rubrics' do
    get('List scoring rubrics') do
      tags 'Reference Documents'
      description 'Retrieve all available scoring rubrics for evaluation reference'
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, description: 'Page number for pagination', required: false
      parameter name: :per_page, in: :query, type: :integer, description: 'Number of items per page', required: false
      parameter name: :category, in: :query, type: :string, description: 'Filter by category', required: false

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 scoring_rubrics: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string },
                       description: { type: :string },
                       category: { type: :string },
                       criteria: {
                         type: :array,
                         items: {
                           type: :object,
                           properties: {
                             name: { type: :string },
                             weight: { type: :number },
                             levels: {
                               type: :array,
                               items: {
                                 type: :object,
                                 properties: {
                                   score: { type: :integer },
                                   description: { type: :string }
                                 }
                               }
                             }
                           }
                         }
                       },
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
          scoring_rubrics: [
            {
              id: 1,
              name: 'Software Engineering Assessment',
              description: 'Comprehensive rubric for evaluating software engineering skills and project quality',
              category: 'technical-assessment',
              criteria: [
                {
                  name: 'Code Quality',
                  weight: 0.3,
                  levels: [
                    { score: 1, description: 'Poor code structure, no documentation' },
                    { score: 2, description: 'Basic code structure, minimal documentation' },
                    { score: 3, description: 'Good code structure, adequate documentation' },
                    { score: 4, description: 'Excellent code structure, comprehensive documentation' }
                  ]
                },
                {
                  name: 'Problem Solving',
                  weight: 0.25,
                  levels: [
                    { score: 1, description: 'Limited problem-solving approach' },
                    { score: 2, description: 'Basic problem-solving skills' },
                    { score: 3, description: 'Strong problem-solving abilities' },
                    { score: 4, description: 'Exceptional problem-solving and innovation' }
                  ]
                }
              ],
              created_at: '2024-01-15T10:00:00.000Z',
              updated_at: '2024-01-15T10:00:00.000Z'
            }
          ],
          pagination: {
            current_page: 1,
            total_pages: 2,
            total_count: 15,
            per_page: 10
          }
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('scoring_rubrics')
          expect(data['scoring_rubrics']).to be_an(Array)
        end
      end
    end

    post('Create scoring rubric') do
      tags 'Reference Documents'
      description 'Create a new scoring rubric for evaluation reference'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :scoring_rubric, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'Software Engineering Assessment' },
          description: { type: :string, example: 'Comprehensive rubric for evaluating software engineering skills...' },
          category: { type: :string, example: 'technical-assessment' },
          criteria: {
            type: :array,
            items: {
              type: :object,
              properties: {
                name: { type: :string },
                weight: { type: :number },
                levels: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      score: { type: :integer },
                      description: { type: :string }
                    }
                  }
                }
              }
            }
          }
        },
        required: ['name', 'description', 'category', 'criteria']
      }

      response(201, 'created') do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 description: { type: :string },
                 category: { type: :string },
                 criteria: { type: :array },
                 created_at: { type: :string, format: :datetime },
                 updated_at: { type: :string, format: :datetime }
               }

        examples 'application/json' => {
          id: 2,
          name: 'Software Engineering Assessment',
          description: 'Comprehensive rubric for evaluating software engineering skills and project quality',
          category: 'technical-assessment',
          criteria: [
            {
              name: 'Code Quality',
              weight: 0.3,
              levels: [
                { score: 1, description: 'Poor code structure, no documentation' },
                { score: 4, description: 'Excellent code structure, comprehensive documentation' }
              ]
            }
          ],
          created_at: '2024-01-15T12:00:00.000Z',
          updated_at: '2024-01-15T12:00:00.000Z'
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('id')
          expect(data).to have_key('name')
          expect(data).to have_key('criteria')
        end
      end

      response(422, 'unprocessable entity') do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          error: 'Validation failed',
          message: 'Name, description, category, and criteria are required',
          details: { missing_fields: ['name', 'description', 'category', 'criteria'] }
        }

        run_test!
      end
    end
  end

  path '/api/v1/scoring_rubrics/{id}' do
    parameter name: 'id', in: :path, type: :integer, description: 'Scoring rubric ID'

    get('Show scoring rubric') do
      tags 'Reference Documents'
      description 'Retrieve a specific scoring rubric by ID'
      produces 'application/json'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 description: { type: :string },
                 category: { type: :string },
                 criteria: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       name: { type: :string },
                       weight: { type: :number },
                       description: { type: :string },
                       levels: {
                         type: :array,
                         items: {
                           type: :object,
                           properties: {
                             score: { type: :integer },
                             description: { type: :string },
                             examples: { type: :array, items: { type: :string } }
                           }
                         }
                       }
                     }
                   }
                 },
                 usage_guidelines: { type: :string },
                 created_at: { type: :string, format: :datetime },
                 updated_at: { type: :string, format: :datetime }
               }

        examples 'application/json' => {
          id: 1,
          name: 'Software Engineering Assessment',
          description: 'Comprehensive rubric for evaluating software engineering skills and project quality',
          category: 'technical-assessment',
          criteria: [
            {
              name: 'Code Quality',
              weight: 0.3,
              description: 'Evaluate the overall quality, structure, and maintainability of the code',
              levels: [
                {
                  score: 1,
                  description: 'Poor code structure, no documentation, inconsistent style',
                  examples: ['No comments', 'Inconsistent naming', 'Poor organization']
                },
                {
                  score: 4,
                  description: 'Excellent code structure, comprehensive documentation, consistent style',
                  examples: ['Clear comments', 'Consistent naming', 'Well-organized modules']
                }
              ]
            }
          ],
          usage_guidelines: 'Use this rubric to evaluate technical projects and coding assignments. Each criterion should be scored independently, and the final score is calculated using the weighted average.',
          created_at: '2024-01-15T10:00:00.000Z',
          updated_at: '2024-01-15T10:00:00.000Z'
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('id')
          expect(data).to have_key('criteria')
          expect(data).to have_key('usage_guidelines')
        end
      end

      response(404, 'not found') do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          error: 'Scoring rubric not found',
          message: 'No scoring rubric found with ID 999',
          details: { id: 999 }
        }

        run_test!
      end
    end

    delete('Delete scoring rubric') do
      tags 'Reference Documents'
      description 'Delete a scoring rubric by ID'
      produces 'application/json'

      response(204, 'no content') do
        run_test!
      end

      response(404, 'not found') do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          error: 'Scoring rubric not found',
          message: 'No scoring rubric found with ID 999',
          details: { id: 999 }
        }

        run_test!
      end
    end
  end
end