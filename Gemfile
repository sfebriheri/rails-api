source "https://rubygems.org"

ruby "3.2.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.5", ">= 7.1.5.2"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", ">= 4.0.1"

# Background job processing
gem "sidekiq", "~> 7.0"

# HTTP client for API calls
gem "faraday", "~> 2.0"

# PDF processing
gem "pdf-reader", "~> 2.0"

# Vector database client (ChromaDB)
gem "chroma-db", "~> 0.6"

# Environment variables
gem "dotenv-rails", "~> 2.8"

# JSON Web Tokens for API authentication
gem "jwt", "~> 2.7"

# Swagger API documentation
gem "rswag-api", "~> 2.16"
gem "rswag-ui", "~> 2.16"

# Rate limiting
gem "rack-attack", "~> 6.7"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Update thor to fix CVE-2025-54314
gem "thor", ">= 1.4.0"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'bundler-audit', require: false
  gem 'brakeman', require: false
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.2'
  gem 'shoulda-matchers', '~> 6.0'
  gem 'simplecov', '~> 0.22', require: false
  gem 'rspec_junit_formatter', '~> 0.6'
  gem 'rswag-specs', '~> 2.16'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  gem "rubocop", require: false
  gem "rubocop-rails", require: false

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Security updates
  # Update to fix CVE-2025-61780, CVE-2025-61770, CVE-2025-61771, CVE-2025-61772, CVE-2025-61919
  gem 'rack', '>= 3.1.18'
  # Update to fix GHSA-353f-x4gh-cqq8, GHSA-5w6v-399v-w3cc
  gem 'nokogiri', '>= 1.18.9'
  # Update to fix CVE-2025-43857
  gem 'net-imap', '>= 0.5.7'
  # Update to fix GHSA-9j94-67jr-4cqj
  gem 'rack-session', '>= 2.1.1'

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end
