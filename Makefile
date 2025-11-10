# Makefile for kraken-crypt
# Provides convenient commands for local development

.PHONY: help install test test-race test-coverage benchmark lint format security build clean ci pre-commit install-hooks

# Default target
help: ## Show this help message
	@echo "kraken-crypt Development Commands"
	@echo "================================="
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Installation
install: ## Install dependencies and tools
	@echo "Installing Go dependencies..."
	go mod download
	go mod verify
	@echo "Installing development tools..."
	@if ! command -v golangci-lint &> /dev/null; then \
		echo "Installing golangci-lint..."; \
		curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $$(go env GOPATH)/bin v1.55.2; \
	fi
	@if ! command -v gosec &> /dev/null; then \
		echo "Installing gosec..."; \
		go install github.com/securecodewarrior/gosec/v2/cmd/gosec@latest || echo "gosec installation failed, continuing without it"; \
	fi
	@if ! command -v staticcheck &> /dev/null; then \
		echo "Installing staticcheck..."; \
		go install honnef.co/go/tools/cmd/staticcheck@latest; \
	fi
	@if ! command -v pre-commit &> /dev/null; then \
		echo "Installing pre-commit..."; \
		pip install pre-commit; \
	fi

# Testing
test: ## Run tests
	@echo "Running tests..."
	go test -v ./pkg/kraken-crypt/...

test-race: ## Run tests with race detection
	@echo "Running tests with race detection..."
	go test -v -race ./pkg/kraken-crypt/...

test-coverage: ## Run tests with coverage
	@echo "Running tests with coverage..."
	go test -v -race -coverprofile=coverage.out ./pkg/kraken-crypt/...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

benchmark: ## Run benchmarks
	@echo "Running benchmarks..."
	go test -bench=. -benchmem ./pkg/kraken-crypt/... > benchmark_results.txt 2>&1
	@echo "Benchmark results saved to: benchmark_results.txt"

# Code quality
lint: ## Run linters
	@echo "Running golangci-lint..."
	golangci-lint run --timeout=5m
	@echo "Running staticcheck..."
	staticcheck ./pkg/kraken-crypt/...
	@echo "Running go vet..."
	go vet ./pkg/kraken-crypt/...

format: ## Format code
	@echo "Formatting code..."
	gofmt -s -w ./pkg/kraken-crypt/...
	goimports -w ./pkg/kraken-crypt/...
	@echo "Code formatted"

security: ## Run security checks
	@echo "Running gosec security scanner..."
	gosec -fmt sarif -out gosec.sarif ./pkg/kraken-crypt/...
	@echo "Security scan completed: gosec.sarif"

# Build
build: ## Build the project
	@echo "Building project..."
	go build ./pkg/kraken-crypt/...
	@echo "Build completed"

# Documentation
docs: ## Generate documentation
	@echo "Generating API documentation..."
	mkdir -p docs
	go doc -all ./pkg/kraken-crypt/... > docs/api.md
	@echo "API documentation generated: docs/api.md"

# Pre-commit hooks
install-hooks: ## Install pre-commit hooks
	@echo "Installing pre-commit hooks..."
	pre-commit install
	@echo "Pre-commit hooks installed"

pre-commit: ## Run pre-commit hooks on all files
	@echo "Running pre-commit hooks..."
	pre-commit run --all-files

# CI/CD
ci: ## Run full CI/CD pipeline locally
	@echo "Running local CI/CD pipeline..."
	./scripts/local-ci.sh

# Cleanup
clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	rm -f coverage.out coverage.html benchmark_results.txt gosec.sarif
	@echo "Cleanup completed"

# Development workflow
dev-setup: install install-hooks ## Complete development setup
	@echo "Development setup completed!"
	@echo "You can now run: make test, make lint, make ci"

# Quick checks
quick-check: format lint test ## Quick development check (format, lint, test)
	@echo "Quick check completed"

# Full pipeline
full-check: format lint test-race test-coverage security benchmark ## Full quality check
	@echo "Full quality check completed"
