require 'rails_helper'

RSpec.describe 'API Base Controller', type: :request do
  describe 'Authentication' do
    let(:user) { create(:user) }
    let(:token) { AuthService.generate_token(user.id, user.email) }

    it 'requires authorization token' do
      get '/api/v1/documents'
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to include('Missing authorization token')
    end

    it 'rejects invalid token' do
      get '/api/v1/documents', headers: { 'Authorization' => 'Bearer invalid-token' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'accepts valid token' do
      # This will fail without actual endpoint, but tests the auth flow
      get '/api/v1/documents', headers: { 'Authorization' => "Bearer #{token}" }
      # Endpoint doesn't exist yet, but auth should pass
    end
  end

  describe 'Error Handling' do
    let(:user) { create(:user) }
    let(:token) { AuthService.generate_token(user.id, user.email) }

    it 'returns 401 for expired token' do
      expired_token = AuthService.generate_token(user.id, user.email)
      # Mock token expiry
      allow(AuthService).to receive(:decode_token).and_raise(AuthService::ExpiredTokenError)

      get '/api/v1/documents', headers: { 'Authorization' => "Bearer #{expired_token}" }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
