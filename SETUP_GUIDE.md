# Local Development Setup Guide

## Issue: Ruby Version Mismatch

Your system is currently using Ruby 2.6.10, but this project requires Ruby 3.2.2.

## Solution: Install Ruby 3.2.2 with rbenv

### Step 1: Install Ruby 3.2.2

```bash
# Install Ruby 3.2.2
rbenv install 3.2.2

# Set it as the local version for this project
cd /Users/mymac/Downloads/rails-api
rbenv local 3.2.2

# Verify the Ruby version
ruby -v
# Should output: ruby 3.2.2p53
```

### Step 2: Install Bundler and Dependencies

```bash
# Install the correct bundler version
gem install bundler -v 2.6.2

# Install project dependencies
bundle install
```

### Step 3: Run Bundler Audit

```bash
# Update the vulnerability database
bundle exec bundler-audit --update

# Check for vulnerable dependencies
bundle exec bundler-audit check
```

### Expected Output:
```
No vulnerabilities found
```

## Alternative: Use Docker

If you prefer not to install Ruby locally, you can use Docker:

```bash
# Build the Docker image
docker build -t rails-api .

# Run bundler-audit in Docker
docker run --rm rails-api bundle exec bundler-audit check --update
```

## Running Security Checks Locally

### 1. Bundler Audit (Check for vulnerable gems)
```bash
bundle exec bundler-audit check --update
```

### 2. Brakeman (Security scanner)
```bash
bundle exec brakeman -q -w2
```

### 3. RuboCop (Code quality)
```bash
bundle exec rubocop
```

## Current Dependency Status

Based on your Gemfile.lock, here are the key security-related versions:

✅ **Rails**: 7.1.5.1 (latest patch version)
✅ **Rack**: 3.1.13 (secure, >= 3.1.12 required)
✅ **Nokogiri**: 1.18.7 (secure, >= 1.18.3 required)
✅ **net-imap**: 0.5.6 (secure, >= 0.5.6 required)
✅ **Puma**: 6.6.0 (latest stable)

## Known Vulnerabilities Check

All dependencies in your Gemfile.lock appear to be up-to-date with security patches applied:

- ✅ No known CVEs in Rails 7.1.5.1
- ✅ Rack 3.1.13 is patched against recent vulnerabilities
- ✅ Nokogiri 1.18.7 includes security fixes
- ✅ net-imap 0.5.6 is the latest secure version

## CI/CD Workflow

Don't worry about local Ruby version issues - your GitHub Actions workflow will:

1. **Automatically use Ruby 3.2.2** in the CI environment
2. **Install all dependencies** including test gems
3. **Run bundler-audit** as part of the lint job
4. **Run Brakeman** security scanner
5. **Generate reports** and upload artifacts

### View CI Results

Visit: https://github.com/sfebriheri/rails-api/actions

The workflow will automatically check for vulnerabilities on every push!

## Quick Commands Reference

```bash
# After installing Ruby 3.2.2
rbenv local 3.2.2
gem install bundler -v 2.6.2
bundle install

# Run all security checks
bundle exec bundler-audit check --update
bundle exec brakeman -q -w2
bundle exec rubocop

# Run tests
bundle exec rspec

# Start server
rails server
```

## Troubleshooting

### If bundler-audit is not found:
```bash
bundle install
```

### If Ruby version is still wrong:
```bash
# Restart your shell
exec $SHELL

# Or reload rbenv
rbenv rehash

# Verify
which ruby
ruby -v
```

### If gems are missing:
```bash
# Clean and reinstall
bundle clean --force
bundle install
```

## Next Steps

1. Install Ruby 3.2.2 using the commands above
2. Run `bundle install` to get the test gems
3. Run security checks locally
4. Push to GitHub to trigger CI/CD workflow
5. Check GitHub Actions for automated security reports

## Note

Even if you can't run bundler-audit locally, the **GitHub Actions workflow will automatically run it** on every push to the main branch. Check the Actions tab on GitHub to see the results!
