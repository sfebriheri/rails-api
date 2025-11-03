module Api
  module V1
    class UsersController < ApplicationController
      # Disable CSRF protection for API endpoints
      protect_from_forgery with: :null_session

      # Skip authentication for register and login
      skip_before_action :verify_authenticity_token, only: [:register, :login]

      # POST /api/v1/register
      def register
        email = params[:email]
        password = params[:password]
        role = params[:role] || 'user'

        # Validation
        if email.blank?
          return render json: { error: 'Email is required' }, status: :bad_request
        end

        if password.blank?
          return render json: { error: 'Password is required' }, status: :bad_request
        end

        if password.length < 8
          return render json: { error: 'Password must be at least 8 characters long' }, status: :bad_request
        end

        # Check if user already exists
        if User.exists?(email: email.downcase)
          return render json: { error: 'Email already registered' }, status: :conflict
        end

        begin
          # Create user
          user = User.new(
            email: email,
            password: password,
            role: role,
            active: true
          )

          if user.save
            # Generate JWT token
            token = AuthService.generate_token(user.id, user.email, roles: [user.role])

            render json: {
              message: 'User registered successfully',
              user: {
                id: user.id,
                email: user.email,
                role: user.role,
                created_at: user.created_at
              },
              token: token
            }, status: :created
          else
            render json: {
              error: 'Registration failed',
              details: user.errors.full_messages
            }, status: :unprocessable_entity
          end
        rescue => e
          Rails.logger.error "Registration error: #{e.class} - #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: { error: 'Registration failed', details: e.message }, status: :internal_server_error
        end
      end

      # POST /api/v1/login
      def login
        email = params[:email]
        password = params[:password]

        if email.blank? || password.blank?
          return render json: { error: 'Email and password are required' }, status: :bad_request
        end

        # Authenticate user
        user = User.authenticate(email, password)

        if user
          # Check if user is active
          unless user.active
            return render json: { error: 'Account is deactivated' }, status: :forbidden
          end

          # Generate JWT token
          token = AuthService.generate_token(user.id, user.email, roles: [user.role])

          render json: {
            message: 'Login successful',
            user: {
              id: user.id,
              email: user.email,
              role: user.role
            },
            token: token
          }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end
    end
  end
end
