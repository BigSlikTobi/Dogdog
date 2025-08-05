# DogDog Trivia Game - Technical Stack

## Framework & Language
- **Flutter**: Cross-platform mobile framework (3.8.0+)
- **Dart**: Programming language (SDK included with Flutter)
- **Target Platforms**: iOS, Android, Web, macOS, Linux, Windows

## Core Dependencies
- **provider**: ^6.1.2 - State management solution (Provider pattern)
- **shared_preferences**: ^2.2.2 - Local data persistence
- **audioplayers**: ^6.0.0 - Audio playback for sound effects
- **cupertino_icons**: ^1.0.8 - iOS-style icons

## Development Dependencies
- **flutter_test**: Built-in testing framework
- **flutter_lints**: ^5.0.0 - Code quality and style enforcement

## Architecture Patterns
- **Provider Pattern**: State management across the application
- **Repository Pattern**: Data access and persistence layer
- **Observer Pattern**: Reactive UI updates
- **Strategy Pattern**: Adaptive difficulty algorithms
- **Factory Pattern**: Question and achievement creation
- **MVC Pattern**: Clean separation of concerns

## Common Commands

### Development
```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d android
flutter run -d ios

# Run with hot reload (debug mode)
flutter run --debug

# Run in release mode for performance testing
flutter run --release
```

### Testing
```bash
# Run all tests (300+ test cases)
flutter test

# Run tests with coverage report
flutter test --coverage

# Run specific test categories
flutter test test/controllers/
flutter test test/integration/
flutter test test/services/

# Run specific test file
flutter test test/controllers/game_controller_test.dart
```

### Building
```bash
# Build for Android
flutter build apk --release
flutter build appbundle --release  # For Play Store

# Build for iOS
flutter build ios --release
flutter build ipa --release  # For App Store

# Build for Web
flutter build web --release

# Build for Desktop
flutter build macos --release
flutter build windows --release
flutter build linux --release
```

### Code Quality
```bash
# Analyze code quality
flutter analyze

# Format code
flutter format .

# Check for outdated dependencies
flutter pub outdated
```

## Asset Management
- **Audio Assets**: `assets/audio/` - MP3 files for sound effects
- **Data Assets**: `assets/data/questions.json` - Question database
- **Platform Icons**: Platform-specific app icons in respective folders

## Performance Targets
- **Animation Performance**: 60 FPS with smooth transitions
- **App Startup**: Under 2 seconds on target devices
- **Screen Transitions**: Under 300ms for smooth navigation
- **Memory Usage**: Optimized with proper resource cleanup
- **Test Coverage**: 95%+ across all components

## Error Handling
- **Global Error Handling**: Comprehensive error catching and recovery
- **Platform-Specific**: Special handling for iOS memory protection and Android lifecycle
- **Retry Mechanisms**: Exponential backoff for transient failures
- **Graceful Degradation**: Fallback content when assets fail to load