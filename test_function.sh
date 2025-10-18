#!/bin/bash

# Script to test the Lambda function running locally

LAMBDA_URL="http://localhost:9000/2015-03-31/functions/function/invocations"

echo "🧪 Testing Lambda function..."

# Test 1: Using the test_event.json file
echo "Test 1: Using test_event.json"
curl -XPOST "$LAMBDA_URL" \
  -H "Content-Type: application/json" \
  -d @test_event.json \
  | jq '.' 2>/dev/null || cat

echo -e "\n" 

# Test 2: Simple test with inline JSON
echo "Test 2: Simple test with inline JSON"
curl -XPOST "$LAMBDA_URL" \
  -H "Content-Type: application/json" \
  -d '{"name": "Test User", "message": "Hello from test script!"}' \
  | jq '.' 2>/dev/null || cat

echo -e "\n"

# Test 3: Test without name parameter
echo "Test 3: Test without name parameter"
curl -XPOST "$LAMBDA_URL" \
  -H "Content-Type: application/json" \
  -d '{"type": "anonymous_test"}' \
  | jq '.' 2>/dev/null || cat

echo -e "\n✅ Testing complete!"
