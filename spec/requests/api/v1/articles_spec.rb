# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/articles', type: :request do
  path '/api/v1/articles' do
    get('List articles') do
      tags 'Content Management'
      description 'Retrieve all available articles and resources'
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, description: 'Page number for pagination', required: false
      parameter name: :per_page, in: :query, type: :integer, description: 'Number of items per page', required: false
      parameter name: :category, in: :query, type: :string, description: 'Filter by category', required: false

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 articles: {
                   type: :array,
                   items: { '$ref' => '#/components/schemas/Article' }
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
          articles: [
            {
              id: 1,
              title: 'Best Practices for Technical Interviews',
              content: 'This article covers the essential best practices...',
              category: 'interview-tips',
              author: 'HR Team',
              published_at: '2024-01-15T10:00:00.000Z',
              created_at: '2024-01-15T09:00:00.000Z',
              updated_at: '2024-01-15T09:30:00.000Z'
            },
            {
              id: 2,
              title: 'How to Evaluate Software Engineering Skills',
              content: 'A comprehensive guide to evaluating technical skills...',
              category: 'evaluation-guide',
              author: 'Tech Team',
              published_at: '2024-01-14T15:00:00.000Z',
              created_at: '2024-01-14T14:00:00.000Z',
              updated_at: '2024-01-14T14:30:00.000Z'
            }
          ],
          pagination: {
            current_page: 1,
            total_pages: 5,
            total_count: 47,
            per_page: 10
          }
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('articles')
          expect(data['articles']).to be_an(Array)
        end
      end
    end

    post('Create article') do
      tags 'Content Management'
      description 'Create a new article or resource'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :article, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: 'Best Practices for Technical Interviews' },
          content: { type: :string, example: 'This article covers the essential best practices...' },
          category: { type: :string, example: 'interview-tips' },
          author: { type: :string, example: 'HR Team' },
          published_at: { type: :string, format: :datetime, example: '2024-01-15T10:00:00.000Z' }
        },
        required: ['title', 'content', 'category']
      }

      response(201, 'created') do
        schema '$ref' => '#/components/schemas/Article'

        examples 'application/json' => {
          id: 3,
          title: 'Best Practices for Technical Interviews',
          content: 'This article covers the essential best practices...',
          category: 'interview-tips',
          author: 'HR Team',
          published_at: '2024-01-15T10:00:00.000Z',
          created_at: '2024-01-15T09:45:00.000Z',
          updated_at: '2024-01-15T09:45:00.000Z'
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('id')
          expect(data).to have_key('title')
          expect(data).to have_key('content')
        end
      end

      response(422, 'unprocessable entity') do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          error: 'Validation failed',
          message: 'Title, content, and category are required',
          details: { missing_fields: ['title', 'content', 'category'] }
        }

        run_test!
      end
    end
  end

  path '/api/v1/articles/{id}' do
    parameter name: 'id', in: :path, type: :integer, description: 'Article ID'

    get('Show article') do
      tags 'Content Management'
      description 'Retrieve a specific article by ID'
      produces 'application/json'

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Article'

        examples 'application/json' => {
          id: 1,
          title: 'Best Practices for Technical Interviews',
          content: 'This article covers the essential best practices for conducting effective technical interviews. It includes guidelines for question preparation, candidate evaluation criteria, and post-interview assessment procedures.',
          category: 'interview-tips',
          author: 'HR Team',
          published_at: '2024-01-15T10:00:00.000Z',
          created_at: '2024-01-15T09:00:00.000Z',
          updated_at: '2024-01-15T09:30:00.000Z'
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
          error: 'Article not found',
          message: 'No article found with ID 999',
          details: { id: 999 }
        }

        run_test!
      end
    end

    put('Update article') do
      tags 'Content Management'
      description 'Update an existing article'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :article, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          content: { type: :string },
          category: { type: :string },
          author: { type: :string },
          published_at: { type: :string, format: :datetime }
        }
      }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Article'

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('id')
          expect(data).to have_key('updated_at')
        end
      end

      response(404, 'not found') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response(422, 'unprocessable entity') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    delete('Delete article') do
      tags 'Content Management'
      description 'Delete an article by ID'
      produces 'application/json'

      response(204, 'no content') do
        run_test!
      end

      response(404, 'not found') do
        schema '$ref' => '#/components/schemas/Error'
        
        examples 'application/json' => {
          error: 'Article not found',
          message: 'No article found with ID 999',
          details: { id: 999 }
        }

        run_test!
      end
    end
  end
end
