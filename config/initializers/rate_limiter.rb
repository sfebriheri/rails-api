# Rate Limiting Configuration using Rack::Attack
# Skip initialization during database tasks to avoid circular dependencies
if !ENV['SKIP_RATE_LIMITER'] && ![
  'db:create', 'db:drop', 'db:migrate', 'db:rollback', 'db:seed', 'db:reset', 'db:prepare'
].any? { |task| ARGV.include?(task) }

  begin
    require 'rack/attack'

    # Configure Redis cache store for rate limiting
    redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/1')
    begin
      Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
        url: redis_url,
        expires_in: 1.hour
      )
    rescue => e
      Rails.logger.warn "Failed to configure Redis for rate limiting: #{e.message}"
    end
  rescue LoadError
    Rails.logger.warn "Rack::Attack gem not available. Rate limiting disabled."
    # Gracefully handle missing gem
    module Rack
      class Attack
        def self.throttle(*args); end
        def self.error_handler; end
      end
    end
  rescue => e
    Rails.logger.error "Failed to initialize Rack::Attack: #{e.message}"
  end

  # General API rate limit: 100 requests per hour per IP
  Rack::Attack.throttle('api/ip', limit: 100, period: 1.hour) do |req|
    req.ip if req.path.start_with?('/api')
  end

  # File upload rate limit: 10 uploads per hour per authenticated user
  Rack::Attack.throttle('upload/user', limit: 10, period: 1.hour) do |req|
    # Extract user ID from JWT token if available
    if req.path.include?('upload') && req.post?
      auth_header = req.headers['Authorization']
      if auth_header&.start_with?('Bearer ')
        token = auth_header.split(' ').last
        begin
          decoded = JWT.decode(token, Rails.application.secrets.secret_key_base, true, algorithm: 'HS256')
          decoded.first['user_id']
        rescue
          nil
        end
      end
    end
  end

  # Evaluation creation rate limit: 20 evaluations per hour per user
  Rack::Attack.throttle('evaluate/user', limit: 20, period: 1.hour) do |req|
    if req.path.include?('evaluate') && req.post?
      auth_header = req.headers['Authorization']
      if auth_header&.start_with?('Bearer ')
        token = auth_header.split(' ').last
        begin
          decoded = JWT.decode(token, Rails.application.secrets.secret_key_base, true, algorithm: 'HS256')
          decoded.first['user_id']
        rescue
          nil
        end
      end
    end
  end

  # Protect from brute forcing job IDs: 30 requests per minute per IP
  Rack::Attack.throttle('result/ip', limit: 30, period: 1.minute) do |req|
    req.ip if req.path.include?('result') && req.get?
  end

  # Custom responses for rate limited requests
  Rack::Attack.throttled_responder = lambda do |req|
    [429, { 'Content-Type' => 'application/json' },
     [JSON.generate({ error: 'Too many requests. Please try again later.' })]]
  end

  # Log rate limit hits
  ActiveSupport::Notifications.subscribe('throttle.rack_attack') do |name, start, finish, request_id, payload|
    Rails.logger.warn "Rate limit exceeded: #{payload[:request].ip} - #{payload[:request].path}"
  end
else
  Rails.logger.info "Rate limiting skipped for database tasks" if ENV['SKIP_RATE_LIMITER']
end
