module Api
  class BaseController < ApplicationController
    # Disable CSRF protection for API endpoints
    protect_from_forgery with: :null_session

    before_action :authenticate_request!
    before_action :set_current_user

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
    rescue_from ActionController::ParameterMissing, with: :render_bad_request
    rescue_from AuthService::InvalidTokenError, with: :render_unauthorized
    rescue_from AuthService::ExpiredTokenError, with: :render_token_expired

    attr_accessor :current_user

    private

    # Authenticate JWT token from Authorization header
    def authenticate_request!
      token = extract_token_from_header

      if token.blank?
        return render_error('Missing authorization token', status: :unauthorized)
      end

      begin
        @current_user_data = AuthService.decode_token(token)
      rescue AuthService::InvalidTokenError
        return render_error('Invalid token', status: :unauthorized)
      rescue AuthService::ExpiredTokenError
        return render_error('Token has expired', status: :unauthorized)
      end
    end

    # Set current user object (can be extended to fetch from database)
    def set_current_user
      return unless @current_user_data

      @current_user = User.find_by(id: @current_user_data[:user_id])

      unless @current_user
        return render_error('User not found', status: :unauthorized)
      end
    end

    # Extract JWT token from Authorization header
    def extract_token_from_header
      auth_header = request.headers['Authorization']
      return nil if auth_header.blank?

      # Expected format: "Bearer <token>"
      match = auth_header.match(/^Bearer\s+(.+)$/)
      match ? match[1] : nil
    end

    # Check if user has required role
    def authorize_role!(required_role)
      roles = @current_user_data[:roles] || []

      unless roles.include?(required_role) || roles.include?('admin')
        render_forbidden
      end
    end

    # Check if user owns a document or resource
    def authorize_ownership!(resource)
      unless resource.user_id == @current_user&.id
        render_forbidden
      end
    end

    def render_success(data = {}, status: :ok)
      render json: data, status: status
    end

    def render_error(message, status: :unprocessable_entity, details: nil)
      error_response = { error: message }
      error_response[:details] = details if details
      render json: error_response, status: status
    end

    def render_not_found(exception = nil)
      message = exception&.message || 'Resource not found'
      render_error(message, status: :not_found)
    end

    def render_unprocessable_entity(exception)
      render_error('Validation failed', details: exception.record.errors.full_messages)
    end

    def render_bad_request(exception)
      render_error(exception.message, status: :bad_request)
    end

    def render_unauthorized
      render_error('Unauthorized', status: :unauthorized)
    end

    def render_token_expired
      render_error('Token has expired', status: :unauthorized)
    end

    def render_forbidden
      render_error('Forbidden - insufficient permissions', status: :forbidden)
    end
  end
end
