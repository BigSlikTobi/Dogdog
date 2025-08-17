# Shared Screens

This directory contains screen components that are reusable across different game modes and features in the DogDog Trivia Game.

## Purpose

Shared screens help maintain consistency across the app and reduce code duplication by providing common screen layouts and functionality that can be used in multiple game contexts.

## Available Screens

### Game Completion Screens

- **`GameCompletionScreen`** - A reusable game completion screen for all game modes
  - Animated score display with counting effect
  - Game statistics presentation with customizable metrics
  - Achievement notifications with celebration animations
  - Configurable navigation actions (primary and secondary buttons)
  - Consistent visual design following the app's design system
  - Support for custom statistics widgets
  - Accessibility features built-in

## Usage

Import the barrel file to access all shared screens:

```dart
import '../screens/shared/shared_screens.dart';
```

Or import individual screens:

```dart
import '../screens/shared/game_completion_screen.dart';
```

## Examples

### Regular Trivia Game Completion
```dart
GameCompletionScreen.trivia(
  statistics: gameStatistics,
  onPlayAgain: () => _startNewGame(),
  onReturnHome: () => _navigateHome(),
  newlyUnlockedAchievements: achievements,
)
```

### Breed Adventure Game Completion
```dart
GameCompletionScreen.breedAdventure(
  statistics: adventureStatistics,
  onPlayAgain: () => _startNewAdventure(),
  onReturnHome: () => _navigateToMap(),
  customStatistics: [
    _buildPhaseProgressWidget(),
    _buildBreedMasteryWidget(),
  ],
)
```

### Checkpoint Celebration
```dart
GameCompletionScreen.checkpoint(
  statistics: checkpointStats,
  onContinue: () => _continueGame(),
  onReturnHome: () => _pauseGame(),
  newlyUnlockedAchievements: milestoneAchievements,
)
```

## Configuration

### GameCompletionAction
Configure action buttons with:
```dart
GameCompletionAction(
  label: 'Play Again',
  onPressed: () => _handlePlayAgain(),
  icon: Icons.refresh, // Optional
)
```

### Custom Statistics
Add game-specific statistics widgets:
```dart
customStatistics: [
  _buildTimeStatistic(),
  _buildAccuracyBreakdown(),
  _buildDifficultyProgression(),
]
```

## Design System Integration

The shared game completion screen follows the established design system:
- Uses `ModernColors` for consistent color schemes
- Applies `ModernTypography` for text hierarchy
- Follows `ModernSpacing` guidelines for layout
- Implements `ModernShadows` for depth and elevation
- Integrates with existing animation patterns

## Animation Features

- **Fade-in Animation**: Smooth entrance with opacity transition
- **Scale Animation**: Elastic scaling for main content elements
- **Score Counting**: Animated number counting for score display
- **Achievement Celebration**: Special animations for unlocked achievements
- **Staggered Timing**: Coordinated animation sequence for optimal UX

## Accessibility

The shared screens include comprehensive accessibility features:
- Semantic labels for all interactive elements
- Screen reader compatibility
- High contrast mode support
- Keyboard navigation support
- Audio feedback integration

## Customization Options

- **Background Color**: Customize screen background
- **Title and Subtitle**: Configure header text
- **Statistics Display**: Show/hide default statistics
- **Custom Content**: Add game-specific widgets
- **Button Configuration**: Customize action buttons
- **Achievement Display**: Control achievement notifications

## Integration with Game Statistics

The screen works with the shared `GameStatistics` model:
```dart
class GameStatistics {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final double accuracy;
  final bool isNewHighScore;
  // ... additional fields
}
```

## Testing

Shared screens should have comprehensive tests covering:
- Screen rendering and layout
- Animation behavior and timing
- User interaction handling
- Statistics display accuracy
- Achievement notification flow
- Accessibility features
- Navigation actions

## Extension Points

The shared screens are designed to be extensible:
- Factory constructors for common game modes
- Configurable action buttons and callbacks
- Custom statistics widget support
- Flexible achievement display
- Theme and styling customization