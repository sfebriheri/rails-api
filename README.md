# Rails API with CI/CD Testing

A RESTful API built with Ruby on Rails, featuring comprehensive API testing and automated CI/CD pipeline with GitHub Actions.

## Features

- **RESTful API** - Articles API with full CRUD operations
- **Comprehensive Testing** - RSpec test suite with request specs, model specs, and factories
- **CI/CD Pipeline** - Automated testing and linting with GitHub Actions
- **Code Quality** - RuboCop linting, Brakeman security scanning, and Bundler Audit
- **Test Coverage** - SimpleCov integration with coverage reporting
- **API Documentation** - Well-structured API endpoints

## Ruby Version

- Ruby 3.2.2
- Rails 7.1.3+

## System Dependencies

- PostgreSQL 15+
- Bundler 2.6+

## Setup Instructions

1. **Install dependencies**
   ```bash
   bundle install
   ```

2. **Database setup**
   ```bash
   rails db:create
   rails db:migrate
   ```

3. **Run the test suite**
   ```bash
   bundle exec rspec
   ```

4. **Start the server**
   ```bash
   rails server
   ```

## API Endpoints

### Articles API (v1)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/articles` | Get all articles |
| GET | `/api/v1/articles/:id` | Get a specific article |
| POST | `/api/v1/articles` | Create a new article |
| PUT/PATCH | `/api/v1/articles/:id` | Update an article |
| DELETE | `/api/v1/articles/:id` | Delete an article |

### Example Request

```bash
# Create an article
curl -X POST http://localhost:3000/api/v1/articles \
  -H "Content-Type: application/json" \
  -d '{
    "article": {
      "title": "My First Article",
      "body": "This is the article content.",
      "published": true
    }
  }'

# Get all articles
curl http://localhost:3000/api/v1/articles

# Get a specific article
curl http://localhost:3000/api/v1/articles/1

# Update an article
curl -X PUT http://localhost:3000/api/v1/articles/1 \
  -H "Content-Type: application/json" \
  -d '{
    "article": {
      "title": "Updated Title"
    }
  }'

# Delete an article
curl -X DELETE http://localhost:3000/api/v1/articles/1
```

## Testing

The project uses RSpec for testing with the following tools:

- **RSpec Rails** - Main testing framework
- **FactoryBot** - Test data factories
- **Faker** - Realistic fake data generation
- **Shoulda Matchers** - One-liner testing matchers
- **SimpleCov** - Code coverage analysis

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/requests/api/v1/articles_spec.rb

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

## CI/CD Pipeline

The project uses GitHub Actions for continuous integration and deployment:

### Workflows

1. **Test Job**
   - Sets up Ruby and PostgreSQL
   - Installs dependencies
   - Prepares test database
   - Runs RSpec test suite
   - Generates test coverage reports
   - Uploads test results and coverage artifacts

2. **Lint Job**
   - Runs RuboCop for code style
   - Runs Brakeman for security scanning
   - Runs Bundler Audit for dependency vulnerabilities

### Triggering CI/CD

The pipeline runs automatically on:
- Push to `main` branch
- Pull requests to `main` branch

## Code Quality Tools

### RuboCop
```bash
bundle exec rubocop
```

### Brakeman (Security Scanner)
```bash
bundle exec brakeman
```

### Bundler Audit (Dependency Security)
```bash
bundle exec bundler-audit check --update
```

## Development

### Adding New API Endpoints

1. Generate model and migration
2. Create controller in `app/controllers/api/v1/`
3. Add routes in `config/routes.rb`
4. Create factory in `spec/factories/`
5. Write request specs in `spec/requests/api/v1/`

### Before Committing

```bash
# Run tests
bundle exec rspec

# Run linters
bundle exec rubocop
bundle exec brakeman
```

## Deployment

The application is containerized and ready for deployment. See `Dockerfile` for container configuration.

## Health Check

The API includes a health check endpoint:
```bash
curl http://localhost:3000/up
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

All pull requests must pass CI/CD checks before merging.

## License

This project is available as open source.
