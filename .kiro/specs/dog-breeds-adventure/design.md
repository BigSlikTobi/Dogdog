# Design Document

## Overview

Dog Breeds Adventure is a picture-based identification game that integrates seamlessly with the existing DogDog trivia app. Players are presented with a dog breed name and must select the correct image from two options within a 10-second time limit. The game features progressive difficulty scaling through distinct phases, localized breed names, power-up mechanics, and efficient image caching for optimal performance.

## Architecture

### High-Level Architecture

The Dog Breeds Adventure game follows the existing DogDog app architecture patterns:

- **Presentation Layer**: Flutter screens and widgets using the existing design system
- **Controller Layer**: Provider-based state management for game logic
- **Service Layer**: Business logic services for breed management, image caching, and localization
- **Model Layer**: Data structures for breeds, game state, and progress tracking
- **Integration Layer**: Seamless integration with existing app services and navigation

### Component Integration

The game integrates with existing DogDog components:
- Uses existing `AudioService` for sound effects
- Leverages existing `ProgressService` for player statistics
- Utilizes existing localization system (`AppLocalizations`)
- Follows existing design system (`ModernColors`, `ModernTypography`, etc.)
- Integrates with existing power-up system from `PowerUpController`

## Components and Interfaces

### 1. Dog Breeds Adventure Screen (`DogBreedsAdventureScreen`)

**Purpose**: Main game screen that orchestrates the breed identification gameplay

**Key Features**:
- Displays breed name at the top
- Shows two images side by side
- 10-second countdown timer
- Power-up buttons
- Score and progress indicators
- Smooth animations for transitions

**Interface**:
```dart
class DogBreedsAdventureScreen extends StatefulWidget {
  const DogBreedsAdventureScreen({super.key});
}
```

### 2. Breed Adventure Controller (`BreedAdventureController`)

**Purpose**: Manages game state, difficulty progression, and breed selection logic

**Key Responsibilities**:
- Track current difficulty phase (1-2, 3-4, 5)
- Manage breed pool for current phase
- Handle correct/incorrect answers
- Track score and statistics
- Manage power-up inventory and effects
- Control game flow and transitions

**Interface**:
```dart
class BreedAdventureController extends ChangeNotifier {
  // Game state
  BreedAdventureGameState get gameState;
  int get currentScore;
  int get correctAnswers;
  DifficultyPhase get currentPhase;
  
  // Current question
  BreedChallenge? get currentChallenge;
  int get timeRemaining;
  
  // Power-ups
  Map<PowerUpType, int> get powerUpInventory;
  
  // Methods
  Future<void> startGame();
  Future<void> selectImage(int imageIndex);
  Future<void> usePowerUp(PowerUpType powerUpType);
  void nextChallenge();
  void endGame();
}
```

### 3. Breed Service (`BreedService`)

**Purpose**: Manages breed data loading, filtering, and localization

**Key Responsibilities**:
- Load breeds from `breeds.json`
- Filter breeds by difficulty phase
- Provide localized breed names
- Generate breed challenges with correct/incorrect image pairs
- Track used breeds to avoid repetition

**Interface**:
```dart
class BreedService {
  Future<void> initialize();
  List<Breed> getBreedsByDifficultyPhase(DifficultyPhase phase);
  String getLocalizedBreedName(String breedName, Locale locale);
  Future<BreedChallenge> generateChallenge(DifficultyPhase phase, Set<String> usedBreeds);
  int getTotalBreedsInPhase(DifficultyPhase phase);
}
```

### 4. Image Cache Service (`ImageCacheService`)

**Purpose**: Handles efficient image loading and caching from Firebase

**Key Responsibilities**:
- Cache images locally using Flutter's image cache
- Preload commonly used breed images
- Handle network failures gracefully
- Manage cache size and cleanup
- Provide loading states and error handling

**Interface**:
```dart
class ImageCacheService {
  Future<void> initialize();
  Future<ImageProvider> getImage(String url);
  Future<void> preloadImages(List<String> urls);
  void clearCache();
  bool isImageCached(String url);
}
```

### 5. Breed Adventure Timer (`BreedAdventureTimer`)

**Purpose**: Manages the 10-second countdown timer with power-up modifications

**Key Responsibilities**:
- 10-second countdown per question
- Handle "Extra Time" power-up (+5 seconds)
- Provide timer callbacks for UI updates
- Auto-submit when time expires

**Interface**:
```dart
class BreedAdventureTimer {
  int get remainingSeconds;
  bool get isActive;
  
  void start({int duration = 10});
  void addTime(int seconds);
  void stop();
  void reset();
  
  Stream<int> get timerStream;
}
```

## Data Models

### 1. Breed Model

```dart
class Breed {
  final String name;
  final String imageUrl;
  final int difficulty;
  
  const Breed({
    required this.name,
    required this.imageUrl,
    required this.difficulty,
  });
  
  factory Breed.fromJson(Map<String, dynamic> json);
}
```

### 2. Breed Challenge Model

```dart
class BreedChallenge {
  final String correctBreedName;
  final String correctImageUrl;
  final String incorrectImageUrl;
  final int correctImageIndex; // 0 or 1
  final DifficultyPhase phase;
  
  const BreedChallenge({
    required this.correctBreedName,
    required this.correctImageUrl,
    required this.incorrectImageUrl,
    required this.correctImageIndex,
    required this.phase,
  });
}
```

### 3. Difficulty Phase Enum

```dart
enum DifficultyPhase {
  beginner(difficulties: [1, 2], name: 'Beginner'),
  intermediate(difficulties: [3, 4], name: 'Intermediate'),
  expert(difficulties: [5], name: 'Expert');
  
  const DifficultyPhase({
    required this.difficulties,
    required this.name,
  });
  
  final List<int> difficulties;
  final String name;
}
```

### 4. Breed Adventure Game State

```dart
class BreedAdventureGameState {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final DifficultyPhase currentPhase;
  final Set<String> usedBreeds;
  final Map<PowerUpType, int> powerUps;
  final bool isGameActive;
  final DateTime? gameStartTime;
  
  const BreedAdventureGameState({
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.currentPhase,
    required this.usedBreeds,
    required this.powerUps,
    required this.isGameActive,
    this.gameStartTime,
  });
}
```

## Error Handling

### Image Loading Errors
- **Retry Mechanism**: Automatic retry up to 3 times for failed image loads
- **Fallback Strategy**: Skip to next available breed if image loading fails completely
- **Loading States**: Show loading indicators while images are being fetched
- **Network Error Handling**: Graceful degradation when network is unavailable

### Game State Errors
- **Invalid Breed Data**: Validate breed data on load and skip invalid entries
- **Empty Breed Pools**: Handle cases where no breeds are available for current phase
- **Timer Synchronization**: Ensure timer state remains consistent with game state
- **Power-up Validation**: Validate power-up usage and prevent invalid states

### Localization Errors
- **Missing Translations**: Fallback to English breed names when translations are unavailable
- **Invalid Locale**: Handle unsupported locales gracefully
- **Dynamic Loading**: Load translations on-demand to reduce app size

## Testing Strategy

### Unit Tests
- **BreedService**: Test breed filtering, localization, and challenge generation
- **ImageCacheService**: Test caching logic, error handling, and cleanup
- **BreedAdventureController**: Test game logic, scoring, and state transitions
- **BreedAdventureTimer**: Test timer functionality and power-up interactions

### Integration Tests
- **Game Flow**: Test complete game sessions from start to finish
- **Power-up Integration**: Test power-up effects on gameplay
- **Phase Transitions**: Test difficulty phase progression
- **Image Loading**: Test image loading and caching in realistic scenarios

### Widget Tests
- **DogBreedsAdventureScreen**: Test UI interactions and state updates
- **Timer Display**: Test countdown timer UI updates
- **Image Selection**: Test image tap interactions and feedback
- **Power-up Buttons**: Test power-up activation and UI states

### Performance Tests
- **Image Loading Performance**: Measure image load times and cache effectiveness
- **Memory Usage**: Monitor memory consumption during extended gameplay
- **Frame Rate**: Ensure smooth 60fps during animations and transitions
- **Battery Usage**: Optimize for minimal battery drain

## Localization Implementation

### Breed Name Localization
The game will support localized breed names through a dedicated localization service:

```dart
class BreedLocalizationService {
  static const Map<String, Map<String, String>> _breedTranslations = {
    'German Shepherd Dog': {
      'de': 'Deutscher Schäferhund',
      'es': 'Pastor Alemán',
      'en': 'German Shepherd Dog',
    },
    'Golden Retriever': {
      'de': 'Golden Retriever',
      'es': 'Golden Retriever',
      'en': 'Golden Retriever',
    },
    // ... more breed translations
  };
  
  String getLocalizedBreedName(String breedName, String languageCode) {
    return _breedTranslations[breedName]?[languageCode] ?? breedName;
  }
}
```

### UI Localization
All UI elements will use the existing `AppLocalizations` system:
- Game instructions and labels
- Power-up names and descriptions
- Score and progress indicators
- Error messages and feedback

## Performance Optimizations

### Image Caching Strategy
- **Preloading**: Preload next 5-10 breed images in background
- **LRU Cache**: Implement Least Recently Used cache eviction
- **Compression**: Use appropriate image compression for mobile devices
- **Progressive Loading**: Show low-quality placeholder while high-quality image loads

### Memory Management
- **Image Disposal**: Properly dispose of unused images to prevent memory leaks
- **Controller Cleanup**: Ensure all controllers and streams are properly disposed
- **Batch Processing**: Process breed data in batches to avoid blocking UI

### Network Optimization
- **Connection Awareness**: Adapt behavior based on network quality
- **Offline Support**: Cache essential images for offline gameplay
- **Bandwidth Management**: Prioritize critical images over background preloading

## Integration Points

### Home Screen Integration
The Dog Breeds Adventure will be accessible through a new card in the existing home screen carousel:

```dart
// Add to PathType enum in enums.dart
enum PathType {
  dogBreeds,
  dogTraining,
  healthCare,
  dogBehavior,
  dogHistory,
  breedAdventure, // New addition
}
```

### Navigation Integration
- Use existing `ModernPageRoute` for smooth transitions
- Integrate with existing navigation patterns
- Maintain app state when returning to home screen

### Progress Integration
- Save game statistics to existing `PlayerProgress` system
- Update relevant achievements and milestones
- Track long-term player performance across game modes

### Audio Integration
- Use existing `AudioService` for sound effects
- Play success/failure sounds for answers
- Integrate with existing audio settings and preferences

## Security Considerations

### Data Validation
- Validate all breed data loaded from JSON
- Sanitize user inputs and prevent injection attacks
- Validate image URLs before loading

### Privacy Protection
- No personal data collection beyond existing app patterns
- Local storage only for game progress and preferences
- Comply with existing app privacy policies

### Content Safety
- Ensure all breed images are appropriate for children
- Implement content filtering if needed
- Handle inappropriate content reports