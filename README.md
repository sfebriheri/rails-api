# AI-Powered Job Application Screening Service

A Ruby on Rails backend service that automates the initial screening of job applications using AI-driven evaluation pipelines, RAG (Retrieval-Augmented Generation), and LLM chaining.

## 🚀 Features

- **AI-Driven Evaluation Pipeline** - Multi-stage LLM evaluation with CV and project assessment
- **Document Processing** - PDF upload with text extraction and vector embedding generation
- **RAG Implementation** - Vector database integration for context retrieval
- **Asynchronous Processing** - Background job processing with Sidekiq
- **Error Handling & Resilience** - Retry logic, rate limiting, and failure recovery
- **RESTful API** - Clean API endpoints for document upload, evaluation, and results
- **Comprehensive Testing** - RSpec test suite with request specs, model specs, and factories
- **CI/CD Pipeline** - Automated testing and linting with GitHub Actions
- **Code Quality** - RuboCop linting, Brakeman security scanning, and Bundler Audit

## 📋 Requirements

- **Ruby**: 3.2.2
- **Rails**: 7.1.5+
- **PostgreSQL**: 15+
- **Redis**: For Sidekiq background jobs
- **Bundler**: 2.6+

## 🛠️ Setup Instructions

### Option 1: Local Development Setup

#### Step 1: Install Ruby 3.2.2 with rbenv

```bash
# Install Ruby 3.2.2
rbenv install 3.2.2

# Set it as the local version for this project
cd /path/to/rails-api
rbenv local 3.2.2

# Verify the Ruby version
ruby -v
# Should output: ruby 3.2.2p53
```

#### Step 2: Install Dependencies

```bash
# Install the correct bundler version
gem install bundler -v 2.6.2

# Install project dependencies
bundle install
```

#### Step 3: Database Setup

```bash
# Create and migrate database
rails db:create
rails db:migrate

# Optional: Seed with sample data
rails db:seed
```

#### Step 4: Start Services

```bash
# Start Redis (required for Sidekiq)
redis-server

# Start Sidekiq (in a separate terminal)
bundle exec sidekiq

# Start the Rails server
rails server
```

### Option 2: Docker Setup

If you prefer not to install Ruby locally:

```bash
# Build the Docker image
docker build -t rails-api .

# Run the application
docker-compose up
```

## 🔧 Development Tools

### Security and Code Quality Checks

```bash
# Update vulnerability database and check for issues
bundle exec bundler-audit check --update

# Run security scanner
bundle exec brakeman -q -w2

# Run code style linter
bundle exec rubocop

# Run all tests
bundle exec rspec
```

### Quick Commands Reference

```bash
# After installing Ruby 3.2.2
rbenv local 3.2.2
gem install bundler -v 2.6.2
bundle install

# Database operations
rails db:create db:migrate

# Start all services
redis-server                    # Terminal 1
bundle exec sidekiq            # Terminal 2
rails server                   # Terminal 3

# Run quality checks
bundle exec bundler-audit check --update
bundle exec brakeman -q -w2
bundle exec rubocop
bundle exec rspec
```

## 📡 API Endpoints

### Job Screening Service

#### Document Upload
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/upload` | Upload CV and project report PDFs |

#### Evaluation Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/evaluate` | Start AI evaluation of uploaded documents |
| GET | `/api/v1/result/:job_id` | Get evaluation results and status |

#### Reference Document Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/POST/DELETE | `/api/v1/job_descriptions` | Manage job description documents |
| GET/POST/DELETE | `/api/v1/case_studies` | Manage case study documents |
| GET/POST/DELETE | `/api/v1/scoring_rubrics` | Manage scoring rubric documents |

### Example API Usage

```bash
# Upload documents
curl -X POST http://localhost:3000/api/v1/upload \
  -F "cv=@candidate_cv.pdf" \
  -F "project_report=@project_report.pdf"

# Start evaluation
curl -X POST http://localhost:3000/api/v1/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "job_title": "Senior Backend Engineer",
    "cv_document_id": 1,
    "project_document_id": 2
  }'

# Check evaluation results
curl http://localhost:3000/api/v1/result/550e8400-e29b-41d4-a716-446655440000
```

## 🧪 Testing

The project uses RSpec for comprehensive testing:

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/requests/api/v1/evaluations_spec.rb

# Run with coverage report
COVERAGE=true bundle exec rspec
```

### Test Structure

```
spec/
├── factories/          # FactoryBot factories
├── models/            # Model specs
├── requests/          # API request specs
│   └── api/v1/       # Versioned API specs
└── support/          # Test helpers and configuration
```

## 🔄 CI/CD Pipeline

The project uses GitHub Actions for continuous integration:

### Automated Workflows

1. **Test Job**
   - Sets up Ruby 3.2.2 and PostgreSQL
   - Installs dependencies
   - Runs RSpec test suite
   - Generates coverage reports

2. **Lint Job**
   - Runs RuboCop for code style
   - Runs Brakeman for security scanning
   - Runs Bundler Audit for dependency vulnerabilities

### Triggering CI/CD

The pipeline runs automatically on:
- Push to `main` branch
- Pull requests to `main` branch

## 🔍 Troubleshooting

### Ruby Version Issues

```bash
# If Ruby version is still wrong after rbenv install
exec $SHELL
rbenv rehash
which ruby
ruby -v
```

### Dependency Issues

```bash
# If gems are missing or conflicting
bundle clean --force
bundle install
```

### Background Jobs Not Processing

```bash
# Ensure Redis is running
redis-cli ping
# Should return: PONG

# Restart Sidekiq
bundle exec sidekiq
```

### Database Issues

```bash
# Reset database if needed
rails db:drop db:create db:migrate
```

## 🚀 Deployment

The application is containerized and ready for deployment:

- **Docker**: See `Dockerfile` for container configuration
- **Health Check**: Available at `/up` endpoint
- **Environment Variables**: Configure via `.env` file (see `.env.example`)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Run tests and linters before committing
4. Commit your changes (`git commit -m 'Add some amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

### Before Committing

```bash
# Ensure all checks pass
bundle exec rspec
bundle exec rubocop
bundle exec brakeman
bundle exec bundler-audit check --update
```

## 📄 License

This project is available as open source.

---

## 📚 Additional Resources

- **API Documentation**: Check the `API_TEST_SETUP.md` for detailed testing examples
- **GitHub Actions**: View automated workflows in `.github/workflows/`
- **Code Quality**: Configuration files include `.rubocop.yml`, `.rspec`
- **Legacy API**: The project also includes a legacy articles API for reference