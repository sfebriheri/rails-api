require 'rails_helper'

RSpec.describe AuthService, type: :service do
  describe '.generate_token' do
    it 'generates a valid JWT token' do
      token = AuthService.generate_token(1, 'user@example.com', roles: ['user'])
      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3) # JWT has 3 parts
    end

    it 'includes user data in token' do
      token = AuthService.generate_token(123, 'test@example.com', roles: ['user'])
      payload = AuthService.decode_token(token)
      expect(payload[:user_id]).to eq(123)
      expect(payload[:email]).to eq('test@example.com')
    end

    it 'sets token expiry' do
      token = AuthService.generate_token(1, 'user@example.com')
      payload = AuthService.decode_token(token)
      expect(payload[:exp]).to be > Time.current.to_i
    end
  end

  describe '.decode_token' do
    let(:token) { AuthService.generate_token(1, 'user@example.com', roles: ['user']) }

    it 'decodes valid token' do
      payload = AuthService.decode_token(token)
      expect(payload).to be_a(Hash)
      expect(payload[:user_id]).to eq(1)
    end

    it 'raises error for invalid token' do
      expect {
        AuthService.decode_token('invalid.token.here')
      }.to raise_error(AuthService::InvalidTokenError)
    end

    it 'raises error for blank token' do
      expect {
        AuthService.decode_token('')
      }.to raise_error(AuthService::InvalidTokenError)
    end
  end

  describe '.verify_token' do
    let(:token) { AuthService.generate_token(1, 'user@example.com') }

    it 'returns true for valid token' do
      expect(AuthService.verify_token(token)).to be true
    end

    it 'returns false for invalid token' do
      expect(AuthService.verify_token('invalid-token')).to be false
    end
  end

  describe '.extract_user_id' do
    let(:token) { AuthService.generate_token(123, 'user@example.com') }

    it 'extracts user_id from token' do
      user_id = AuthService.extract_user_id(token)
      expect(user_id).to eq(123)
    end
  end

  describe '.has_role?' do
    it 'returns true for user with required role' do
      token = AuthService.generate_token(1, 'user@example.com', roles: ['user'])
      expect(AuthService.has_role?(token, 'user')).to be true
    end

    it 'returns true for admin with any role' do
      token = AuthService.generate_token(1, 'admin@example.com', roles: ['admin'])
      expect(AuthService.has_role?(token, 'user')).to be true
    end

    it 'returns false for user without required role' do
      token = AuthService.generate_token(1, 'user@example.com', roles: ['user'])
      expect(AuthService.has_role?(token, 'admin')).to be false
    end
  end
end
