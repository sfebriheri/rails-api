module Api
  class BaseController < ApplicationController
    # Disable CSRF protection for API endpoints
    protect_from_forgery with: :null_session
    
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
    rescue_from ActionController::ParameterMissing, with: :render_bad_request

    private

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
  end
end