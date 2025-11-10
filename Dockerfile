# Build stage
FROM golang:1.25-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git ca-certificates tzdata

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o kraken-crypt ./cmd/main.go

# Final stage
FROM alpine:latest

# Install ca-certificates for HTTPS requests
RUN apk --no-cache add ca-certificates

# Create non-root user
RUN addgroup -g 1001 -S kraken && \
  adduser -u 1001 -S kraken -G kraken

# Set working directory
WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /app/kraken-crypt .

# Copy documentation
COPY --from=builder /app/README.md .
COPY --from=builder /app/LICENSE .

# Change ownership to non-root user
RUN chown -R kraken:kraken /app

# Switch to non-root user
USER kraken

# Expose port (if needed for HTTP services)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ./kraken-crypt --version || exit 1

# Default command
CMD ["./kraken-crypt"]
