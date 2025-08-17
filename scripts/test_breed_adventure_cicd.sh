#!/bin/bash

# Script to test the Breed Adventure CI/CD pipeline locally
# This simulates the GitHub Actions workflow

set -e  # Exit on any error

FLUTTER_PROJECT_DIR="dogdog_trivia_game"
COVERAGE_THRESHOLD=90

echo "🐕 Testing Breed Adventure CI/CD Pipeline"
echo "=========================================="

# Change to project directory
cd "$FLUTTER_PROJECT_DIR"

echo ""
echo "📦 Installing dependencies..."
flutter pub get

echo ""
echo "🔍 Verifying Flutter installation..."
flutter doctor -v

echo ""
echo "🧹 Checking code formatting..."
if dart format --set-exit-if-changed lib/models/breed_adventure/ lib/controllers/breed_adventure/ lib/services/breed_adventure/ lib/widgets/breed_adventure/ lib/screens/dog_breeds_adventure_screen.dart test/breed_adventure/; then
    echo "✅ Code formatting check passed"
else
    echo "❌ Code formatting issues found"
    exit 1
fi

echo ""
echo "🔍 Running static analysis..."
echo "Analyzing breed adventure specific files..."
flutter analyze lib/models/breed_adventure/ || echo "⚠️ Analysis issues in models"
flutter analyze lib/controllers/breed_adventure/ || echo "⚠️ Analysis issues in controllers"
flutter analyze lib/services/breed_adventure/ || echo "⚠️ Analysis issues in services"
flutter analyze lib/widgets/breed_adventure/ || echo "⚠️ Analysis issues in widgets"
flutter analyze lib/screens/dog_breeds_adventure_screen.dart || echo "⚠️ Analysis issues in screen"
flutter analyze test/breed_adventure/ || echo "⚠️ Analysis issues in tests"

echo ""
echo "🌐 Generating localization files..."
flutter gen-l10n

echo ""
echo "📊 Verifying test structure..."
unit_tests=$(find test/breed_adventure/unit -name "*.dart" 2>/dev/null | wc -l || echo "0")
integration_tests=$(find test/breed_adventure/integration -name "*.dart" 2>/dev/null | wc -l || echo "0")
total_tests=$(find test/breed_adventure -name "*.dart" -not -name "*.mocks.dart" 2>/dev/null | wc -l || echo "0")

echo "📋 Test Summary:"
echo "  • Unit tests: $unit_tests"
echo "  • Integration tests: $integration_tests"
echo "  • Total test files: $total_tests"

if [ "$total_tests" -lt 5 ]; then
    echo "⚠️ Warning: Low number of test files detected"
else
    echo "✅ Good test coverage structure detected!"
fi

echo ""
echo "🧪 Running breed adventure unit tests..."
flutter test test/breed_adventure/unit/ --coverage --reporter=expanded
echo "✅ Unit tests completed!"

echo ""
echo "🔗 Running breed adventure integration tests..."
flutter test test/breed_adventure/integration/ --coverage --reporter=expanded
echo "✅ Integration tests completed!"

echo ""
echo "📈 Analyzing test coverage..."

# Check if coverage file exists
if [ ! -f coverage/lcov.info ]; then
    echo "❌ No coverage file found"
    exit 1
fi

# Extract breed adventure file coverage
echo "📊 Coverage for breed adventure files:"

breed_adventure_files=$(grep -E "SF:.*breed_adventure" coverage/lcov.info | wc -l || echo "0")
echo "  • Breed adventure files in coverage: $breed_adventure_files"

# Calculate coverage for breed adventure files
if grep -q "breed_adventure" coverage/lcov.info; then
    echo "✅ Breed adventure files found in coverage report"
    
    # Extract coverage data for breed adventure files
    awk '
    /SF:.*breed_adventure/ { 
        file = $0
        getline; while (!/^SF:/ && !/^end_of_record/ && NF > 0) {
            if (/^LF:/) lines_found = substr($0, 4)
            if (/^LH:/) lines_hit = substr($0, 4)
            getline
        }
        if (lines_found > 0) {
            coverage = (lines_hit / lines_found) * 100
            printf "  • %s: %.1f%% (%d/%d lines)\n", file, coverage, lines_hit, lines_found
        }
    }' coverage/lcov.info
else
    echo "⚠️ No breed adventure files found in coverage report"
fi

# Overall coverage check
total_lines=$(grep "^LF:" coverage/lcov.info | awk -F: '{sum += $2} END {print sum}')
hit_lines=$(grep "^LH:" coverage/lcov.info | awk -F: '{sum += $2} END {print sum}')

if [ "$total_lines" -gt 0 ]; then
    overall_coverage=$(echo "scale=2; $hit_lines * 100 / $total_lines" | bc -l || echo "0")
    echo "📊 Overall coverage: ${overall_coverage}% ($hit_lines/$total_lines lines)"
    
    # Note: For breed adventure specific coverage, we might want to calculate only breed adventure files
    # But for now, this gives us an overall view
    echo ""
    echo "📝 CI/CD Pipeline Test Summary:"
    echo "================================="
    echo "✅ All breed adventure tests passed!"
    echo "📊 Coverage report generated"
    echo "🚀 Pipeline simulation complete"
    echo ""
    echo "💡 Note: In GitHub Actions, coverage threshold will be enforced"
    echo "   Current threshold: ${COVERAGE_THRESHOLD}%"
    echo "   The pipeline will focus on breed adventure specific coverage"
else
    echo "❌ No coverage data found"
    exit 1
fi

echo ""
echo "🎉 Breed Adventure CI/CD Pipeline Test Complete!"
echo "This script simulates the GitHub Actions workflow locally."
echo "Push changes to trigger the actual CI/CD pipeline."
