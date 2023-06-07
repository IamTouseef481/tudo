# Build configuration
# -------------------

APP_NAME = `grep -Eo 'app: :\w*' mix.exs | cut -d ':' -f 3`
APP_VERSION = `grep -Eo 'version: "[0-9\.]*"' mix.exs | cut -d '"' -f 2`
GIT_REVISION = `git rev-parse HEAD`
DOCKER_IMAGE_TAG ?= $(APP_VERSION)
DOCKER_REGISTRY ?=
DOCKER_LOCAL_IMAGE = $(APP_NAME):$(DOCKER_IMAGE_TAG)
DOCKER_REMOTE_IMAGE = $(DOCKER_REGISTRY)/$(DOCKER_LOCAL_IMAGE)

# Linter and formatter configuration
# ----------------------------------

PRETTIER_FILES_PATTERN = '*.config.js' '{js,css,scripts}/**/*.{js,graphql,scss,css}' '../*.md' '../*/*.md'
STYLES_PATTERN = 'css'

# Introspection targets
# ---------------------

.PHONY: help
help: header targets

.PHONY: header
header:
	@echo "\033[34mEnvironment\033[0m"
	@echo "\033[34m---------------------------------------------------------------\033[0m"
	@printf "\033[33m%-23s\033[0m" "APP_NAME"
	@printf "\033[35m%s\033[0m" $(APP_NAME)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "APP_VERSION"
	@printf "\033[35m%s\033[0m" $(APP_VERSION)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "GIT_REVISION"
	@printf "\033[35m%s\033[0m" $(GIT_REVISION)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "DOCKER_IMAGE_TAG"
	@printf "\033[35m%s\033[0m" $(DOCKER_IMAGE_TAG)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "DOCKER_REGISTRY"
	@printf "\033[35m%s\033[0m" $(DOCKER_REGISTRY)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "DOCKER_LOCAL_IMAGE"
	@printf "\033[35m%s\033[0m" $(DOCKER_LOCAL_IMAGE)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "DOCKER_REMOTE_IMAGE"
	@printf "\033[35m%s\033[0m" $(DOCKER_REMOTE_IMAGE)
	@echo "\n"

.PHONY: targets
targets:
	@echo "\033[34mTargets\033[0m"
	@echo "\033[34m---------------------------------------------------------------\033[0m"
	@perl -nle'print $& if m{^[a-zA-Z_-\d]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

# Build targets
# -------------

.PHONY: prepare
prepare:
	mix deps.get

.PHONY: deps
deps:
	mix deps.get

.PHONY: build
build: ## Build the Docker image for the OTP release
	docker build \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VERSION=$(APP_VERSION) \
		--rm --tag $(DOCKER_LOCAL_IMAGE) .

.PHONY: push
push: ## Push the Docker image to the registry
	docker tag $(DOCKER_LOCAL_IMAGE) $(DOCKER_REMOTE_IMAGE)
	docker push $(DOCKER_REMOTE_IMAGE)

# Development targets
# -------------------

.PHONY: run
run: ## Run the server inside an IEx shell
	iex -S mix phx.server

.PHONY: nv-run
nv-run: ## Run the server inside an IEx shell with nv
	nv .env.dev,.env.dev.local iex -S mix phx.server

.PHONY: prerequisites
prerequisites: .tool-versions ## Get runtime dependencies like the elixir language itself
	@priv/scripts/get-prerequisites.sh

.PHONY: nv-iex
nv-iex:
	nv .env.dev,.env.dev.local iex -S mix

.PHONY: nv-deploy
nv-deploy:
	nv .env.dev,.env.dev.local mix deploy

.PHONY: setup-local
setup-local: dependencies ## Setup local environment vars, database, and dependencies
	test -f .env.dev.local || echo "SECRET_KEY_BASE=$$(mix phx.gen.secret | tail -n 1)" >> .env.dev.local
	test -f .env.dev.local || echo "SESSION_SIGNING_SALT=$$(mix phx.gen.secret | tail -n 1)" >> .env.dev.local
	test -f .env.dev.local || echo "GUARDIAN_SECRET=$$(mix phx.gen.secret | tail -n 1)" >> .env.dev.local
	touch .env.test.local
	make nv-setup

.PHONY: dependencies
dependencies: ## Install dependencies
	nv .env.dev,.env.dev.local mix deps.get

.PHONY: clean
clean: ## Clean dependencies
	mix deps.clean --all
	rm -rf _build

.PHONY: sync-translations
sync-translations: ## Synchronize translations with Accent
	npx accent sync

.PHONY: test
test: ## Run the test suite
	mix test

.PHONY: nv-test
nv-test: ## Run the test suite with nv
	nv .env.test,.env.test.local mix test

.PHONY: nv-test
nv-test-failed: ## Run the test suite with nv
	nv .env.test,.env.test.local mix test --failed

.PHONY: nv-test-file
nv-test-file: ## Run the test suite with nv and a specific test file
	nv .env.test,.env.test.local mix test $(filter-out $@,$(MAKECMDGOALS))

# .PHONY: nv-testi
# nv-testi: ## Run the test suite (including integration tests) with nv
# 	nv .env.test,.env.test.local mix test $(path)

.PHONY: nv-setup
nv-setup: ## Create tables and run migrations with nv
	echo HOME=${HOME} >> ~/.nv
	echo USER=${USER} >> ~/.nv
	echo TERM=xterm-color >> ~/.nv
	nv .env.dev,.env.dev.local mix ecto.setup

.PHONY: nv-migrate
nv-migrate: ## Just run migrations with nv
	nv .env.dev,.env.dev.local mix ecto.migrate

.PHONY: nv-seed
nv-seed:
	nv .env.dev,.env.dev.local mix run priv/repo/seeds.exs

.PHONY: nv-rollback
nv-rollback:
	nv .env.dev,.env.dev.local mix ecto.rollback

.PHONY: nv-drop
nv-drop: ## ecto.drop with nv
	nv .env.dev,.env.dev.local mix ecto.drop

.PHONY: nv-reset
nv-reset: ## ecto.reset with nv
	nv .env.dev,.env.dev.local mix ecto.reset

.PHONY: ci
ci: flint check nv-test

# Check, lint and format targets
# ------------------------------

 ## Run various checks on project files 
.PHONY: check
check: \
	check-format \
	check-unused-dependencies \
	check-dependencies-security \
	check-code-security

.PHONY: check
nv-check: \
	check-format \
	nv-check-code-coverage \
	check-unused-dependencies \
	check-dependencies-security \
	check-code-security

.PHONY: nv-check-code-coverage
nv-check-code-coverage:
	nv .env.test,.env.test.local mix coveralls.lcov

.PHONY: check-code-coverage
check-code-coverage:
	mix coveralls.lcov

.PHONY: check-dependencies-security
check-dependencies-security:
	mix deps.audit

.PHONY: check-code-security
check-code-security:
	mix sobelow --config

.PHONY: check-format
check-format:
	mix format --check-formatted

.PHONY: check-fe-format
check-fe-format:
	cd assets && npx prettier --check $(PRETTIER_FILES_PATTERN)

.PHONY: check-unused-dependencies
check-unused-dependencies:
	mix deps.unlock --check-unused

.PHONY: format
format: ## Format project files will add back for assets (cd assets && npx prettier --write $(PRETTIER_FILES_PATTERN))
	mix format

.PHONY: format-fe
format-fe:
	cd assets && npx prettier --write $(PRETTIER_FILES_PATTERN)

.PHONY: lint
lint: lint-elixir ## Lint project files TODO add back (lint-scripts lint-styles)

# Add back into compile: --warnings-as-errors credo: --strict
.PHONY: lint-elixir
lint-elixir:
	mix compile --force
	mix credo

.PHONY: lint-scripts
lint-scripts:
	cd assets && npx eslint .

.PHONY: lint-styles
lint-styles:
	cd assets && npx stylelint --syntax scss $(STYLES_PATTERN)

.PHONY: flint
flint: format lint
