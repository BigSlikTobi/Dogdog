# Shared Widgets

This directory contains UI widgets that are reusable across different game modes and features in the DogDog Trivia Game.

## Purpose

Shared widgets help maintain consistency across the app and reduce code duplication by providing common UI components that can be used in multiple contexts.

## Available Widgets

### Animation Widgets

- **`SuccessAnimationWidget`** - Displays success animations by alternating between success images
  - Supports multiple animation variants (quick, celebration, achievement, etc.)
  - Configurable timing, scaling, and dismissal behavior
  - Accessibility support with semantic labels
  - Used for celebrating correct answers, level completions, and achievements

- **`LoadingAnimation`** - Custom loading animation widget with dog-themed elements
  - Multiple loading animation types (circular, shimmer, dots, wave)
  - Configurable size, color, and message
  - Smooth animations with proper disposal

- **`StreakCelebrationWidget`** - Displays streak celebration animations with multiplier feedback
  - Shows streak count and score multiplier
  - Animated scaling and pulsing effects
  - Configurable duration and completion callbacks

## Usage

Import the barrel file to access all shared widgets:

```dart
import '../widgets/shared/shared_widgets.dart';
```

Or import individual widgets:

```dart
import '../widgets/shared/success_animation_widget.dart';
import '../widgets/shared/loading_animation.dart';
import '../widgets/shared/streak_celebration_widget.dart';
```

## Examples

### Success Animation
```dart
SuccessAnimationWidget.correctAnswer(
  width: 200,
  height: 200,
  onAnimationComplete: () => print('Animation complete!'),
  semanticLabel: 'Correct answer celebration',
)
```

### Loading Animation
```dart
LoadingAnimation(
  size: 60.0,
  color: ModernColors.primary,
  message: 'Loading breed images...',
)
```

### Streak Celebration
```dart
StreakCelebrationWidget(
  streakCount: 5,
  multiplier: 2,
  onAnimationComplete: () => _handleStreakComplete(),
)
```

## Design System Integration

All shared widgets follow the established design system:
- Use `ModernColors` for consistent color schemes
- Apply `ModernTypography` for text styling
- Follow `ModernSpacing` guidelines for layout
- Implement `ModernShadows` for depth and elevation

## Accessibility

Shared widgets include accessibility features:
- Semantic labels for screen readers
- High contrast mode support
- Keyboard navigation compatibility
- Audio cues where appropriate

## Testing

Each shared widget should have comprehensive tests covering:
- Widget rendering and layout
- Animation behavior and timing
- User interaction handling
- Accessibility features
- Error states and edge cases

## Extension Points

Shared widgets are designed to be extensible:
- Factory constructors for common variants
- Extension methods for specialized use cases
- Configurable parameters for customization
- Plugin patterns for additional functionality