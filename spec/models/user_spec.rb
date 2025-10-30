require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }

    it 'validates email format' do
      user = build(:user, email: 'invalid-email')
      expect(user).not_to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:documents).dependent(:destroy) }
    it { is_expected.to have_many(:evaluation_jobs).dependent(:destroy) }
    it { is_expected.to have_many(:audit_logs).dependent(:nullify) }
  end

  describe '#authenticate' do
    let(:user) { create(:user, password: 'password123') }

    it 'returns user when credentials are valid' do
      authenticated_user = User.authenticate(user.email, 'password123')
      expect(authenticated_user).to eq(user)
    end

    it 'returns nil when password is invalid' do
      authenticated_user = User.authenticate(user.email, 'wrong_password')
      expect(authenticated_user).to be_nil
    end

    it 'returns nil when user not found' do
      authenticated_user = User.authenticate('nonexistent@example.com', 'password123')
      expect(authenticated_user).to be_nil
    end
  end

  describe '#valid_password?' do
    let(:user) { create(:user, password: 'password123') }

    it 'returns true for correct password' do
      expect(user.valid_password?('password123')).to be true
    end

    it 'returns false for incorrect password' do
      expect(user.valid_password?('wrong_password')).to be false
    end
  end
end
