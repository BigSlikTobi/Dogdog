#!/bin/bash

# Simple Test Runner Script for Dogdog Trivia Game
# This script runs the simplified test suite

echo "🐕 Running Dogdog Trivia Game Test Suite..."
echo "================================================"

cd "$(dirname "$0")/../dogdog_trivia_game"

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found. Make sure you're in the right directory."
    exit 1
fi

# Get dependencies
echo "🔄 Getting dependencies..."
flutter pub get

# Run the tests
echo "🔍 Running unit tests..."
if flutter test --coverage --reporter=expanded; then
  echo "✅ Unit tests passed!"
else
  echo "❌ Some tests failed. Check the output above for details."
  exit 1
fi
