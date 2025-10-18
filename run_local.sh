#!/bin/bash

# Script to build and run the containerized Lambda function locally

set -e

echo "🐳 Building Docker image for Lambda function..."
docker build -t test-lambda .

echo "✅ Docker image built successfully!"

echo "🚀 Starting Lambda container..."
echo "The container will be available at http://localhost:9000"
echo "Press Ctrl+C to stop the container"

# Run the container with port mapping
docker run --rm -p 9000:8080 test-lambda:latest
