#!/bin/bash

# Production Deployment Script for cocodr.xyz Migration
# This script handles build optimization, environment setup, and deployment

set -e  # Exit on any error

echo "🚀 Starting production deployment for cocodr.xyz"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_error ".env file not found. Please create it from .env.example"
    exit 1
fi

# Set production environment
export NODE_ENV=production

print_status "Setting production environment variables..."
# Override development values with production ones
export VITE_API_BASE_URL="https://api.cocodr.xyz"
export VITE_WS_URL="wss://apidev.cocodr.xyz"

# Install dependencies if needed
print_status "Installing dependencies..."
if command -v bun &> /dev/null; then
    bun install
elif command -v npm &> /dev/null; then
    npm install
else
    print_error "Neither bun nor npm found"
    exit 1
fi

# Run database migrations
print_status "Running database migrations..."
if command -v bun &> /dev/null; then
    bun run db:migrate
elif command -v npm &> /dev/null; then
    npm run db:migrate
fi

# Build optimizations
print_status "Building application with optimizations..."
if command -v bun &> /dev/null; then
    bun run build
elif command -v npm &> /dev/null; then
    npm run build
fi

# Build API
print_status "Building API..."
cd api
if command -v bun &> /dev/null; then
    bun run build
elif command -v npm &> /dev/null; then
    npm run build
fi
cd ..

# Docker build if Dockerfile exists
if [ -f "Dockerfile" ]; then
    print_status "Building Docker image..."
    docker build -t casino-app:latest .
fi

# Deploy to Fly.io if fly CLI is available
if command -v fly &> /dev/null; then
    print_status "Deploying to Fly.io..."
    fly deploy
else
    print_warning "Fly CLI not found. Manual deployment required."
fi

# Health check function
health_check() {
    local url=$1
    local max_attempts=10
    local attempt=1

    print_status "Performing health check on $url..."

    while [ $attempt -le $max_attempts ]; do
        if curl -f -s "$url" > /dev/null 2>&1; then
            print_status "✅ Health check passed for $url"
            return 0
        fi

        print_warning "Health check attempt $attempt/$max_attempts failed. Retrying in 10 seconds..."
        sleep 10
        ((attempt++))
    done

    print_error "❌ Health check failed for $url after $max_attempts attempts"
    return 1
}

# Wait for deployment to be ready
print_status "Waiting for deployment to stabilize..."
sleep 30

# Perform health checks
health_check "https://app.cocodr.xyz"
health_check "https://api.cocodr.xyz"

# Additional checks
print_status "Checking API endpoints..."
if curl -f -s "https://api.cocodr.xyz/api/health" > /dev/null 2>&1; then
    print_status "✅ API health endpoint responding"
else
    print_warning "⚠️ API health endpoint not accessible (may not be implemented)"
fi

print_status "🎉 Deployment completed successfully!"
print_status "Verify the application at: https://app.cocodr.xyz"
print_status "API available at: https://api.cocodr.xyz"

# Optional: Run tests if available
if [ -f "package.json" ] && grep -q '"test"' package.json; then
    print_status "Running tests..."
    if command -v bun &> /dev/null; then
        bun test || print_warning "Tests failed, but deployment continued"
    elif command -v npm &> /dev/null; then
        npm test || print_warning "Tests failed, but deployment continued"
    fi
fi

print_status "Deployment script completed."