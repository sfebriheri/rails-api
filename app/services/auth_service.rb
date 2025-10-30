# AuthService - Handles JWT token generation and validation
class AuthService
  ALGORITHM = 'HS256'
  TOKEN_EXPIRY = 24.hours.freeze

  class InvalidTokenError < StandardError; end
  class ExpiredTokenError < StandardError; end

  def self.generate_token(user_id, email, roles: ['user'])
    payload = {
      user_id: user_id,
      email: email,
      roles: roles,
      iat: Time.current.to_i,
      exp: (Time.current + TOKEN_EXPIRY).to_i
    }

    JWT.encode(payload, secret_key, ALGORITHM)
  end

  def self.decode_token(token)
    raise InvalidTokenError, 'Token is required' if token.blank?

    begin
      decoded = JWT.decode(token, secret_key, true, algorithm: ALGORITHM)
      decoded.first.symbolize_keys
    rescue JWT::DecodeError => e
      raise InvalidTokenError, "Invalid token: #{e.message}"
    rescue JWT::ExpiredSignature
      raise ExpiredTokenError, 'Token has expired'
    end
  end

  def self.verify_token(token)
    decode_token(token)
    true
  rescue InvalidTokenError, ExpiredTokenError
    false
  end

  def self.extract_user_id(token)
    payload = decode_token(token)
    payload[:user_id]
  end

  def self.extract_user_email(token)
    payload = decode_token(token)
    payload[:email]
  end

  def self.has_role?(token, required_role)
    payload = decode_token(token)
    payload[:roles].include?(required_role) || payload[:roles].include?('admin')
  rescue InvalidTokenError, ExpiredTokenError
    false
  end

  private

  def self.secret_key
    @secret_key ||= begin
      key = Rails.application.secrets.secret_key_base
      raise "SECRET_KEY_BASE environment variable is not set" if key.blank?
      key
    end
  end
end
