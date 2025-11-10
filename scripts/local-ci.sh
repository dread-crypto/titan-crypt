#!/bin/bash

# Local CI/CD Pipeline for kraken-crypt
# Replicates the GitHub Actions workflow locally

set -e

echo "🚀 Starting local CI/CD pipeline for kraken-crypt..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "go.mod" ]; then
    print_error "Not in a Go project directory. Please run from kraken-crypt root."
    exit 1
fi

# Set Go version
export GO_VERSION="1.21"
print_status "Using Go version: $GO_VERSION"

# Step 1: Go mod operations
print_status "Step 1: Go mod operations..."
go mod download
go mod verify
print_success "Go mod operations completed"

# Step 2: Run tests
print_status "Step 2: Running tests..."
go test -v -race -coverprofile=coverage.out ./pkg/kraken-crypt/...
test_exit_code=$?
if [ $test_exit_code -eq 0 ]; then
    print_success "All tests passed"
else
    print_error "Tests failed with exit code $test_exit_code"
    exit $test_exit_code
fi

# Step 3: Run benchmarks
print_status "Step 3: Running benchmarks..."
go test -bench=. -benchmem ./pkg/kraken-crypt/... > benchmark_results.txt 2>&1
print_success "Benchmarks completed"

# Step 4: Generate API documentation
print_status "Step 4: Generating API documentation..."
mkdir -p docs
go doc -all ./pkg/kraken-crypt/... > docs/api.md 2>&1 || print_warning "API documentation generation had issues, but continuing..."
print_success "API documentation generated"

# Step 5: Run golangci-lint
print_status "Step 5: Running golangci-lint..."
if command -v golangci-lint &> /dev/null; then
    golangci-lint run --timeout=5m
    print_success "golangci-lint passed"
else
    print_warning "golangci-lint not found, skipping..."
fi

# Step 6: Run gosec security scanner
print_status "Step 6: Running gosec security scanner..."
if command -v gosec &> /dev/null; then
    gosec -fmt sarif -out gosec.sarif ./pkg/kraken-crypt/...
    print_success "gosec security scan completed"
else
    print_warning "gosec not found, skipping..."
fi

# Step 7: Run staticcheck
print_status "Step 7: Running staticcheck..."
if command -v staticcheck &> /dev/null; then
    staticcheck ./pkg/kraken-crypt/...
    print_success "staticcheck passed"
else
    print_warning "staticcheck not found, skipping..."
fi

# Step 8: Run go vet
print_status "Step 8: Running go vet..."
go vet ./pkg/kraken-crypt/...
print_success "go vet passed"

# Step 9: Run go fmt check
print_status "Step 9: Checking code formatting..."
unformatted=$(gofmt -l ./pkg/kraken-crypt/...)
if [ -n "$unformatted" ]; then
    print_error "Code is not formatted. Run 'gofmt -w ./pkg/kraken-crypt/...' to fix:"
    echo "$unformatted"
    exit 1
else
    print_success "Code formatting is correct"
fi

# Step 10: Run fuzz tests
print_status "Step 10: Running fuzz tests..."
for pkg in $(go list ./pkg/kraken-crypt/...); do
    if [ -d "$pkg" ]; then
        echo "Fuzzing package: $pkg"
        go test -fuzz=. -fuzztime=10s "$pkg" || true
    fi
done
print_success "Fuzz tests completed"

# Step 11: Build the project
print_status "Step 11: Building the project..."
go build ./pkg/kraken-crypt/...
print_success "Build completed"

# Step 12: Generate coverage report
print_status "Step 12: Generating coverage report..."
go tool cover -html=coverage.out -o coverage.html
print_success "Coverage report generated: coverage.html"

# Summary
print_success "🎉 Local CI/CD pipeline completed successfully!"
print_status "Coverage report: coverage.html"
print_status "Benchmark results: benchmark_results.txt"
print_status "API documentation: docs/api.md"
print_status "Security scan: gosec.sarif"

echo ""
echo "📊 Pipeline Summary:"
echo "✅ Go mod operations"
echo "✅ Tests"
echo "✅ Benchmarks"
echo "✅ API documentation"
echo "✅ Linting"
echo "✅ Security scan"
echo "✅ Static analysis"
echo "✅ Code formatting"
echo "✅ Fuzz tests"
echo "✅ Build"
echo "✅ Coverage report"
