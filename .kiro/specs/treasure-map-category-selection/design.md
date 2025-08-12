# Design Document

## Overview

This design document outlines the implementation of category-based question selection for the DogDog trivia game's treasure map system. The solution transitions from the current questions.json format to the new questions_fixed.json format, introducing three selectable categories (Dog Training, Dog Breeds, Dog Behavior) with progressive difficulty levels (easy, easy+, medium, hard) and full localization support. The design maintains compatibility with existing treasure map mechanics while enhancing the user experience with category-specific content and improved question management.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Treasure Map Screen                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Dog Training   │  │   Dog Breeds    │  │  Dog Behavior   │ │
│  │    Category     │  │    Category     │  │    Category     │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                Enhanced Question Service                        │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │              New Question Format Parser                     │ │
│  │  • Category-based filtering                                │ │
│  │  • Progressive difficulty mapping                          │ │
│  │  • Localization support                                    │ │
│  └─────────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │              Question Pool Manager                          │ │
│  │  • Category-specific pools                                 │ │
│  │  • Difficulty progression logic                            │ │
│  │  • Randomization within constraints                        │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│              Enhanced Treasure Map Controller                  │
│  • Category selection state management                         │
│  • Category-specific progress tracking                         │
│  • Integration with existing checkpoint system                 │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Selects Category → TreasureMapController.setCategory() → 
QuestionService.loadCategoryQuestions() → 
Progressive Difficulty Selection → 
Localized Question Delivery → 
Game Screen with Category Context
```

## Components and Interfaces

### 1. Enhanced Question Model

```dart
class LocalizedQuestion {
  final String id;
  final String category;
  final String difficulty; // 'easy', 'easy+', 'medium', 'hard'
  final Map<String, String> text; // Localized question text
  final Map<String, List<String>> answers; // Localized answer options
  final int correctAnswerIndex;
  final Map<String, String> hint; // Localized hints
  final Map<String, String> funFact; // Localized fun facts
  final String ageRange;
  final List<String> tags;
}
```

### 2. Category Enum Extension

```dart
enum QuestionCategory {
  dogTraining('Dog Training'),
  dogBreeds('Dog Breeds'),
  dogBehavior('Dog Behavior');

  const QuestionCategory(this.displayName);
  final String displayName;

  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case QuestionCategory.dogTraining:
        return l10n.category_dogTraining;
      case QuestionCategory.dogBreeds:
        return l10n.category_dogBreeds;
      case QuestionCategory.dogBehavior:
        return l10n.category_dogBehavior;
    }
  }
}
```

### 3. Enhanced Question Service Interface

```dart
abstract class IQuestionService {
  Future<void> initialize();
  
  List<LocalizedQuestion> getQuestionsByCategory({
    required QuestionCategory category,
    required String locale,
    required int count,
    required List<String> difficultyProgression,
    Set<String>? excludeIds,
  });
  
  List<String> getDifficultyProgression(int questionCount);
  
  bool hasQuestionsForCategory(QuestionCategory category);
  
  int getQuestionCountForCategory(QuestionCategory category);
}
```

### 4. Enhanced Treasure Map Controller

```dart
class TreasureMapController extends ChangeNotifier {
  QuestionCategory _selectedCategory = QuestionCategory.dogBreeds;
  Map<QuestionCategory, int> _categoryProgress = {};
  Map<QuestionCategory, Set<Checkpoint>> _categoryCheckpoints = {};
  
  QuestionCategory get selectedCategory => _selectedCategory;
  
  void selectCategory(QuestionCategory category) {
    _selectedCategory = category;
    _loadCategoryProgress();
    notifyListeners();
  }
  
  int getCategoryProgress(QuestionCategory category) {
    return _categoryProgress[category] ?? 0;
  }
  
  Set<Checkpoint> getCategoryCheckpoints(QuestionCategory category) {
    return _categoryCheckpoints[category] ?? {};
  }
  
  void _loadCategoryProgress() {
    // Load saved progress for selected category
  }
}
```

## Data Models

### Question Data Structure (questions_fixed.json)

```json
{
  "questions": [
    {
      "id": "DT_easy_001",
      "category": "Dog Training",
      "difficulty": "easy",
      "text": {
        "de": "German question text",
        "en": "English question text",
        "es": "Spanish question text"
      },
      "answers": {
        "de": ["German answer 1", "German answer 2", "German answer 3", "German answer 4"],
        "en": ["English answer 1", "English answer 2", "English answer 3", "English answer 4"],
        "es": ["Spanish answer 1", "Spanish answer 2", "Spanish answer 3", "Spanish answer 4"]
      },
      "correctAnswerIndex": 2,
      "hint": {
        "de": "German hint",
        "en": "English hint", 
        "es": "Spanish hint"
      },
      "funFact": {
        "de": "German fun fact",
        "en": "English fun fact",
        "es": "Spanish fun fact"
      },
      "ageRange": "8-12",
      "tags": ["training", "basic-commands"]
    }
  ]
}
```

### Difficulty Progression Mapping

```dart
class DifficultyProgression {
  static List<String> getProgressionForQuestionCount(int count) {
    if (count <= 15) {
      return ['easy', 'easy', 'easy+', 'easy+', 'medium'];
    } else if (count <= 30) {
      return ['easy', 'easy', 'easy+', 'easy+', 'medium', 'medium', 'hard'];
    } else {
      return ['easy', 'easy+', 'medium', 'medium', 'hard', 'hard'];
    }
  }
}
```

## Error Handling

### Fallback Strategy

1. **Primary**: Load questions_fixed.json with full localization
2. **Secondary**: Load questions_fixed.json with English fallback
3. **Tertiary**: Load old questions.json format
4. **Final**: Use hardcoded sample questions

### Error Recovery Mechanisms

```dart
class QuestionLoadingStrategy {
  static Future<List<LocalizedQuestion>> loadWithFallback({
    required String primaryPath,
    required String fallbackPath,
    required QuestionCategory category,
    required String locale,
  }) async {
    try {
      return await _loadFromPath(primaryPath, category, locale);
    } catch (primaryError) {
      try {
        return await _loadFromPath(fallbackPath, category, 'en');
      } catch (fallbackError) {
        return _getHardcodedQuestions(category);
      }
    }
  }
}
```

## Testing Strategy

### Unit Tests

1. **Question Service Tests**
   - Category filtering accuracy
   - Difficulty progression logic
   - Localization fallback behavior
   - Question randomization within constraints

2. **Treasure Map Controller Tests**
   - Category selection state management
   - Progress tracking per category
   - Integration with checkpoint system

3. **Question Model Tests**
   - Localized content extraction
   - Data validation and parsing
   - Error handling for missing translations

### Integration Tests

1. **End-to-End Category Selection**
   - User selects category → Questions load → Game starts
   - Category switching preserves progress
   - Localization changes update content

2. **Treasure Map Progression**
   - Questions follow difficulty progression
   - Checkpoints award appropriate rewards
   - Progress saves and restores correctly

### Performance Tests

1. **Question Loading Performance**
   - Large question file parsing time
   - Memory usage with multiple categories
   - Localization switching performance

2. **UI Responsiveness**
   - Category selection response time
   - Smooth transitions between categories
   - Progress indicator updates

## Implementation Phases

### Phase 1: Core Infrastructure
- Implement LocalizedQuestion model
- Create enhanced QuestionService with new format support
- Add category filtering and difficulty progression logic

### Phase 2: Treasure Map Integration
- Extend TreasureMapController with category support
- Update treasure map UI with category selection
- Implement category-specific progress tracking

### Phase 3: Localization and Polish
- Add full localization support for all languages
- Implement fallback mechanisms
- Add error handling and recovery

### Phase 4: Testing and Optimization
- Comprehensive testing suite
- Performance optimization
- User experience refinements

## Security Considerations

- **Data Validation**: Validate all question data before use
- **Locale Sanitization**: Ensure locale strings are safe
- **Error Information**: Avoid exposing sensitive error details to users
- **Resource Management**: Prevent memory leaks with large question datasets

## Performance Considerations

- **Lazy Loading**: Load questions on-demand per category
- **Caching**: Cache parsed questions to avoid repeated parsing
- **Memory Management**: Dispose unused question pools
- **Localization Efficiency**: Cache localized strings to avoid repeated lookups

## Accessibility

- **Screen Reader Support**: Ensure category names are properly announced
- **High Contrast**: Category selection buttons support high contrast mode
- **Font Scaling**: All text respects system font size settings
- **Navigation**: Keyboard and assistive technology navigation support