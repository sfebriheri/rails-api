module Api
  class BaseController < ApplicationController
    # Disable CSRF protection for API endpoints
    protect_from_forgery with: :null_session
  end
end