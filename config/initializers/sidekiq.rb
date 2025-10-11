require 'sidekiq'

redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
  
  # Configure server-specific settings
  config.on(:startup) do
    Rails.logger.info "Sidekiq server started"
  end
  
  config.on(:shutdown) do
    Rails.logger.info "Sidekiq server shutting down"
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

# Configure job retry settings
Sidekiq.default_job_options = {
  'retry' => 3,
  'backtrace' => true
}