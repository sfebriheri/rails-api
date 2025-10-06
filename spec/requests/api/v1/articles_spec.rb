require 'rails_helper'

RSpec.describe 'Api::V1::Articles', type: :request do
  # Initialize test data
  let!(:articles) { create_list(:article, 10) }
  let(:article_id) { articles.first.id }

  # Test suite for GET /api/v1/articles
  describe 'GET /api/v1/articles' do
    before { get '/api/v1/articles' }

    it 'returns articles' do
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /api/v1/articles/:id
  describe 'GET /api/v1/articles/:id' do
    context 'when the record exists' do
      before { get "/api/v1/articles/#{article_id}" }

      it 'returns the article' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(article_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:article_id) { 100 }
      before { get "/api/v1/articles/#{article_id}" }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(json['error']).to match(/Article not found/)
      end
    end
  end

  # Test suite for POST /api/v1/articles
  describe 'POST /api/v1/articles' do
    context 'when the request is valid' do
      let(:valid_attributes) do
        {
          article: {
            title: 'Learn Rails',
            body: 'This is a comprehensive guide to Rails.',
            published: true
          }
        }
      end

      before { post '/api/v1/articles', params: valid_attributes }

      it 'creates an article' do
        expect(json['title']).to eq('Learn Rails')
        expect(json['body']).to eq('This is a comprehensive guide to Rails.')
        expect(json['published']).to eq(true)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      let(:invalid_attributes) do
        { article: { title: '', body: '' } }
      end

      before { post '/api/v1/articles', params: invalid_attributes }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(json['errors']).to include("Title can't be blank")
        expect(json['errors']).to include("Body can't be blank")
      end
    end
  end

  # Test suite for PUT /api/v1/articles/:id
  describe 'PUT /api/v1/articles/:id' do
    context 'when the record exists' do
      let(:valid_attributes) do
        { article: { title: 'Updated Title' } }
      end

      before { put "/api/v1/articles/#{article_id}", params: valid_attributes }

      it 'updates the record' do
        expect(json['title']).to eq('Updated Title')
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request is invalid' do
      let(:invalid_attributes) do
        { article: { title: '' } }
      end

      before { put "/api/v1/articles/#{article_id}", params: invalid_attributes }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(json['errors']).to include("Title can't be blank")
      end
    end
  end

  # Test suite for DELETE /api/v1/articles/:id
  describe 'DELETE /api/v1/articles/:id' do
    before { delete "/api/v1/articles/#{article_id}" }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end

    it 'deletes the article' do
      expect(Article.exists?(article_id)).to be_falsey
    end
  end
end
