# GitHub Actions Workflow Test

This file is created to trigger the GitHub Actions workflow and verify it runs correctly.

## Expected Workflow Jobs

1. **Test Job**
   - ✅ Checkout code
   - ✅ Setup Ruby 3.2.2
   - ✅ Install dependencies
   - ✅ Setup PostgreSQL
   - ✅ Prepare database
   - ✅ Run RSpec tests
   - ✅ Upload test results
   - ✅ Upload coverage reports

2. **Lint Job**
   - ✅ Checkout code
   - ✅ Setup Ruby 3.2.2
   - ✅ Run RuboCop
   - ✅ Run Brakeman security scan
   - ✅ Run Bundler Audit

## How to Verify Workflow

1. Go to: https://github.com/sfebriheri/rails-api/actions
2. Look for the latest workflow run triggered by this commit
3. Check that both "test" and "lint" jobs complete successfully
4. Download artifacts (test-results and coverage) if needed

## Timestamp
Created: 2025-10-06 to test GitHub Actions CI/CD pipeline
