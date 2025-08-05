# DogDog Trivia Game - Project Structure

## Root Directory Structure
```
dogdog_trivia_game/
├── lib/                      # Main source code
├── test/                     # Test files (300+ tests)
├── assets/                   # Game assets (audio, data)
├── android/                  # Android platform files
├── ios/                      # iOS platform files
├── web/                      # Web platform files
├── macos/                    # macOS platform files
├── linux/                   # Linux platform files
├── windows/                  # Windows platform files
├── pubspec.yaml             # Dependencies and configuration
└── README.md                # Project documentation
```

## Source Code Organization (`lib/`)
```
lib/
├── main.dart                 # App entry point with global error handling
├── controllers/              # Game state management (Provider pattern)
│   ├── game_controller.dart  # Main game logic and state
│   └── power_up_controller.dart # Power-up inventory and effects
├── models/                   # Data models and business entities
│   ├── achievement.dart      # Achievement and rank system
│   ├── enums.dart           # Game enums (Difficulty, PowerUpType, etc.)
│   ├── game_state.dart      # Current game session state
│   ├── models.dart          # Barrel export file
│   ├── player_progress.dart # Long-term player statistics
│   └── question.dart        # Question data structure
├── screens/                  # UI screens and navigation
│   ├── achievements_screen.dart # Progress and ranks display
│   ├── difficulty_selection_screen.dart # Category selection
│   ├── error_recovery_screen.dart # Error handling UI
│   ├── game_over_screen.dart # End game summary
│   ├── game_screen.dart     # Main quiz interface
│   ├── home_screen.dart     # Welcome screen with animations
│   └── result_screen.dart   # Answer feedback and fun facts
├── services/                 # Business logic services
│   ├── audio_service.dart   # Sound effects and feedback
│   ├── error_service.dart   # Error tracking and recovery
│   ├── progress_service.dart # Player data persistence
│   └── question_service.dart # Question management and adaptive difficulty
├── utils/                    # Utility functions and helpers
│   ├── accessibility.dart   # Screen reader and accessibility support
│   ├── animations.dart      # Custom animations and transitions
│   ├── responsive.dart      # Responsive design utilities
│   └── retry_mechanism.dart # Error recovery mechanisms
└── widgets/                  # Reusable UI components
    ├── animated_button.dart  # Interactive button components
    ├── audio_settings.dart  # Audio control widgets
    ├── error_boundary.dart  # Error handling widgets
    └── loading_animation.dart # Loading state indicators
```

## Test Structure (`test/`)
```
test/
├── controllers/              # Controller logic tests
├── integration/              # End-to-end workflow tests
├── models/                   # Data model validation tests
├── screens/                  # UI component and screen tests
├── services/                 # Business logic service tests
├── utils/                    # Utility function tests
├── widgets/                  # Reusable component tests
└── widget_test.dart         # Main widget test entry point
```

## Assets Structure (`assets/`)
```
assets/
├── audio/                    # Sound effects (MP3 format)
│   ├── achievement_unlock.mp3
│   ├── happy_bark.mp3
│   ├── playful_bark.mp3
│   ├── power_up.mp3
│   └── sad_whimper.mp3
└── data/
    └── questions.json        # Question database with German content
```

## Architecture Layers

### Presentation Layer (`screens/`, `widgets/`)
- UI screens and reusable components
- Handles user interactions and navigation
- Consumes state from controllers via Provider

### Controller Layer (`controllers/`)
- State management using Provider pattern
- Game logic and business rules
- Coordinates between services and UI

### Service Layer (`services/`)
- Business logic implementation
- Data persistence and retrieval
- External integrations (audio, error tracking)

### Model Layer (`models/`)
- Data structures and entities
- Enums and constants
- Serialization/deserialization logic

### Utility Layer (`utils/`)
- Helper functions and utilities
- Cross-cutting concerns (accessibility, animations)
- Reusable algorithms and mechanisms

## Naming Conventions

### Files and Directories
- Use `snake_case` for file and directory names
- Suffix with type: `_controller.dart`, `_service.dart`, `_screen.dart`
- Use descriptive names that indicate purpose

### Classes and Functions
- Use `PascalCase` for class names
- Use `camelCase` for function and variable names
- Use descriptive names that indicate functionality

### Constants and Enums
- Use `PascalCase` for enum names
- Use `camelCase` for enum values
- Use `SCREAMING_SNAKE_CASE` for compile-time constants

## Import Organization
1. Dart core libraries
2. Flutter framework imports
3. Third-party package imports
4. Local project imports (relative paths)
5. Barrel exports from `models/models.dart`

## Code Organization Principles
- **Single Responsibility**: Each class has one clear purpose
- **Dependency Injection**: Services injected via constructors
- **Separation of Concerns**: Clear boundaries between layers
- **Testability**: All components designed for easy testing
- **Modularity**: Reusable components and services