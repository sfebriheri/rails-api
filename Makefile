## Make-based workflow for Rails API

# Configurable variables
RUBY_VERSION ?= $(shell cat .ruby-version 2>/dev/null || echo 3.2.2)
PORT ?= 3000
SPEC ?=

# Detect rbenv and prefer its shims if available
RBENV := $(shell command -v rbenv 2>/dev/null)
ifeq ($(RBENV),)
  RBENV_EXEC :=
else
  RBENV_EXEC := $(RBENV) exec
endif

BUNDLE := bundle

.PHONY: help setup install server swagger rspec db-setup db-migrate db-reset clean rebuild all

help:
	@echo "Available targets:"
	@echo "  setup      - Ensure Ruby $(RUBY_VERSION) via rbenv (if installed)"
	@echo "  install    - Install gems to vendor/bundle"
	@echo "  server     - Start Rails server on port $(PORT)"
	@echo "  swagger    - Regenerate Swagger docs via rswag"
	@echo "  rspec      - Run test suite (override SPEC=...)"
	@echo "  db-setup   - Initialize database (create, load schema, seed)"
	@echo "  db-migrate - Run database migrations"
	@echo "  db-reset   - Drop, create, and migrate database"
	@echo "  clean      - Clean bundler artifacts"
	@echo "  rebuild    - Clean, reinstall, and reset database"
	@echo "  all        - Install deps and setup database"

setup:
ifeq ($(RBENV),)
	@echo "rbenv not found; ensure Ruby $(RUBY_VERSION) is active."
else
	$(RBENV) install -s $(RUBY_VERSION)
	$(RBENV) local $(RUBY_VERSION)
endif

install:
	$(RBENV_EXEC) $(BUNDLE) install --path vendor/bundle

server:
	$(RBENV_EXEC) $(BUNDLE) exec rails server -p $(PORT)

swagger:
	$(RBENV_EXEC) $(BUNDLE) exec rake rswag:specs:swaggerize

rspec:
	$(RBENV_EXEC) $(BUNDLE) exec rspec $(SPEC)

db-setup:
	$(RBENV_EXEC) $(BUNDLE) exec rails db:setup

db-migrate:
	$(RBENV_EXEC) $(BUNDLE) exec rails db:migrate

db-reset:
	$(RBENV_EXEC) $(BUNDLE) exec rails db:reset

clean:
	$(RBENV_EXEC) $(BUNDLE) clean --force

rebuild: clean install db-reset

all: install db-setup