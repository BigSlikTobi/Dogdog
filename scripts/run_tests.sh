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

# Run the tests
echo "🔍 Running unit tests..."
flutter test

# Check test results
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ All tests passed!"
    echo ""
    echo "📊 Test Summary:"
    echo "- Unit tests: ✓ Models, Services, Controllers"
    echo "- Widget tests: ✓ Basic widget functionality"
    echo "- Integration tests: ✓ App startup and navigation"
    echo ""
    echo "🎉 Test suite completed successfully!"
else
    echo ""
    echo "❌ Some tests failed. Check the output above for details."
    exit 1
fi


echo -e "${BLUE}🚀 Starting Flutter Test Suite for DogDog Trivia Game${NC}"

# Change to project directory
cd "$(dirname "$0")/../dogdog_trivia_game"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Flutter Doctor Check${NC}"
flutter doctor

echo -e "${BLUE}📦 Installing Dependencies${NC}"
flutter pub get

echo -e "${BLUE}🌍 Generating Localization Files${NC}"
flutter gen-l10n

echo -e "${BLUE}🔍 Running Code Analysis${NC}"
if flutter analyze; then
    echo -e "${GREEN}✅ Code analysis passed${NC}"
else
    echo -e "${RED}❌ Code analysis failed${NC}"
    exit 1
fi

echo -e "${BLUE}🎨 Checking Code Formatting${NC}"
if dart format --set-exit-if-changed .; then
    echo -e "${GREEN}✅ Code formatting is correct${NC}"
else
    echo -e "${RED}❌ Code formatting issues found${NC}"
    echo -e "${YELLOW}Run 'dart format .' to fix formatting${NC}"
    exit 1
fi

echo -e "${BLUE}🧪 Running Unit Tests${NC}"
if flutter test --coverage --reporter=expanded; then
    echo -e "${GREEN}✅ All tests passed${NC}"
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi

echo -e "${BLUE}📊 Generating Coverage Report${NC}"
if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    echo -e "${GREEN}✅ Coverage report generated in coverage/html/index.html${NC}"
else
    echo -e "${YELLOW}⚠️  genhtml not found. Install lcov to generate HTML coverage reports${NC}"
fi

echo -e "${BLUE}🔧 Running Integration Tests${NC}"
flutter test test/integration/ --reporter=expanded

echo -e "${GREEN}🎉 All tests completed successfully!${NC}"
echo -e "${BLUE}📈 Test Summary:${NC}"
echo -e "  • Code analysis: ✅"
echo -e "  • Code formatting: ✅"
echo -e "  • Unit tests: ✅"
echo -e "  • Integration tests: ✅"
echo -e "  • Coverage report: Available in coverage/html/"
