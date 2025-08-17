#!/bin/bash

# iPhone Profile Mode Caching Test Script
# Run this script to build and test the image caching improvements

set -e  # Exit on any error

echo "🐕 DogDog - iPhone Profile Mode Caching Test"
echo "=============================================="

# Check if we're in the correct directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Please run this script from the dogdog_trivia_game directory"
    exit 1
fi

echo "✅ Found pubspec.yaml - we're in the right directory"

# Clean build
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run tests to ensure everything is working
echo "🧪 Running tests..."
flutter test --reporter=compact

# Analyze code
echo "🔍 Analyzing code..."
flutter analyze --no-fatal-infos

# Build for profile mode (optimized for testing on iPhone)
echo "🏗️ Building for profile mode..."
flutter build ios --profile --no-codesign

echo ""
echo "✅ Build completed successfully!"
echo ""
echo "📱 To test on iPhone:"
echo "1. Open ios/Runner.xcworkspace in Xcode"
echo "2. Select your iPhone device"
echo "3. Run the app in profile mode"
echo "4. Test the breed adventure mode - especially Labrador Retriever"
echo ""
echo "🔍 Watch for these log messages:"
echo "  - 'Image cache configured for iPhone: 200 items, 100MB'"
echo "  - 'Preloaded X/Y critical images'"
echo "  - 'Successfully preloaded network image for [breed name]'"
echo ""
echo "🌐 Test scenarios:"
echo "  ✓ Normal network - should load from Supabase"
echo "  ✓ Airplane mode - should fallback to local assets"
echo "  ✓ Poor network - should mix network and fallbacks"
echo ""
echo "🎯 Expected behavior:"
echo "  - Images load even without network"
echo "  - No 'Bild konnte nicht geladen' errors"
echo "  - Smooth performance in profile mode"
