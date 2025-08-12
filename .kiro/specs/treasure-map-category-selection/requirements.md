# Requirements Document

## Introduction

This specification enhances the DogDog trivia game's treasure map system to support the new localized question format with category-based selection. The system will transition from using the old questions.json format to the new questions_fixed.json format, which includes three categories (Dog Training, Dog Breeds, Dog Behavior), four difficulty levels (easy, easy+, medium, hard), and full localization support (German, English, Spanish). Players will be able to select their preferred category in the treasure map screen and experience questions with progressive difficulty while maintaining the existing treasure map progression mechanics.

## Requirements

### Requirement 1

**User Story:** As a player, I want to select from three specific dog-related categories in the treasure map screen, so that I can focus on the topics that interest me most.

#### Acceptance Criteria

1. WHEN accessing the treasure map screen THEN the system SHALL display three category options: "Dog Training", "Dog Breeds", and "Dog Behavior"
2. WHEN selecting a category THEN the system SHALL load questions exclusively from that category using the questions_fixed.json format
3. WHEN displaying category options THEN the system SHALL show localized category names based on the current app language setting
4. WHEN a category is selected THEN the system SHALL update the treasure map header to show the selected category name
5. WHEN switching between categories THEN the system SHALL reset the current progress and start fresh with the new category
6. WHEN no category is selected initially THEN the system SHALL default to "Dog Breeds" category

### Requirement 2

**User Story:** As a player, I want questions to follow a progressive difficulty sequence (easy → easy+ → medium → hard), so that the challenge increases naturally as I advance through the treasure map.

#### Acceptance Criteria

1. WHEN starting a treasure map journey THEN the system SHALL begin with "easy" difficulty questions
2. WHEN progressing through questions THEN the system SHALL transition from "easy" to "easy+" after the first checkpoint
3. WHEN reaching the middle checkpoints THEN the system SHALL present "medium" difficulty questions
4. WHEN approaching the final checkpoints THEN the system SHALL present "hard" difficulty questions
5. WHEN questions are randomized THEN the system SHALL maintain the difficulty progression while shuffling question order within each difficulty level
6. WHEN difficulty transitions occur THEN the system SHALL ensure smooth progression without sudden difficulty spikes

### Requirement 3

**User Story:** As a player, I want to experience questions in my preferred language (German, English, or Spanish), so that I can fully understand and enjoy the content.

#### Acceptance Criteria

1. WHEN loading questions THEN the system SHALL use the current app locale to determine question language
2. WHEN displaying questions THEN the system SHALL show text, answers, hints, and fun facts in the selected language
3. WHEN the app language changes THEN the system SHALL reload questions in the new language without losing progress
4. WHEN a language is not available for a question THEN the system SHALL fallback to German as the default language
5. WHEN displaying category names THEN the system SHALL use localized strings from the app's localization system
6. WHEN showing UI elements THEN the system SHALL ensure all text elements respect the current language setting

### Requirement 4

**User Story:** As a player, I want the question service to seamlessly transition from the old format to the new format, so that the game continues to work without interruption.

#### Acceptance Criteria

1. WHEN the question service initializes THEN the system SHALL load questions from questions_fixed.json instead of questions.json
2. WHEN parsing the new question format THEN the system SHALL correctly extract category, difficulty, localized text, and metadata
3. WHEN filtering questions by category THEN the system SHALL return only questions matching the selected category
4. WHEN filtering questions by difficulty THEN the system SHALL support the new difficulty levels (easy, easy+, medium, hard)
5. WHEN the new format is unavailable THEN the system SHALL fallback to the old format with appropriate error handling
6. WHEN question data is processed THEN the system SHALL maintain compatibility with existing game mechanics

### Requirement 5

**User Story:** As a player, I want the treasure map progression to work seamlessly with the new question categories, so that I can complete treasure map journeys in any category.

#### Acceptance Criteria

1. WHEN progressing through a category-specific treasure map THEN the system SHALL track progress independently for each category
2. WHEN reaching checkpoints THEN the system SHALL award power-ups and rewards as defined in the existing treasure map system
3. WHEN completing a treasure map in one category THEN the system SHALL allow starting a new journey in a different category
4. WHEN switching categories mid-journey THEN the system SHALL save current progress and allow resuming later
5. WHEN displaying progress THEN the system SHALL show category-specific completion status and achievements
6. WHEN the treasure map is completed THEN the system SHALL celebrate the achievement with category-specific messaging

### Requirement 6

**User Story:** As a player, I want the question randomization to work properly with the new format, so that I get varied and engaging questions throughout my journey.

#### Acceptance Criteria

1. WHEN questions are selected THEN the system SHALL randomize questions within each difficulty level for the selected category
2. WHEN progressing through difficulties THEN the system SHALL ensure no question is repeated within the same treasure map journey
3. WHEN starting a new journey in the same category THEN the system SHALL provide a fresh set of randomized questions
4. WHEN insufficient questions exist for a difficulty/category combination THEN the system SHALL handle gracefully with appropriate fallbacks
5. WHEN questions are exhausted THEN the system SHALL either recycle questions or provide appropriate completion messaging
6. WHEN randomization occurs THEN the system SHALL maintain the progressive difficulty structure

### Requirement 7

**User Story:** As a player, I want the treasure map UI to clearly indicate my selected category and progress, so that I always know which topic I'm exploring.

#### Acceptance Criteria

1. WHEN viewing the treasure map THEN the system SHALL display the selected category name prominently in the header
2. WHEN showing progress indicators THEN the system SHALL include category-specific visual elements or colors
3. WHEN displaying the action button THEN the system SHALL show category-appropriate text (e.g., "Start Dog Training Adventure")
4. WHEN navigating to the game screen THEN the system SHALL pass the selected category information to maintain context
5. WHEN returning to the treasure map THEN the system SHALL remember the last selected category
6. WHEN category selection changes THEN the system SHALL update all relevant UI elements to reflect the new selection

### Requirement 8

**User Story:** As a player, I want the system to handle errors gracefully when loading the new question format, so that the game remains playable even if there are data issues.

#### Acceptance Criteria

1. WHEN the questions_fixed.json file is missing THEN the system SHALL fallback to the old questions.json format
2. WHEN question data is corrupted THEN the system SHALL display appropriate error messages and provide recovery options
3. WHEN a specific category has no questions THEN the system SHALL disable that category option and show a message
4. WHEN localization data is missing THEN the system SHALL fallback to available languages with user notification
5. WHEN network or storage errors occur THEN the system SHALL provide retry mechanisms and offline fallbacks
6. WHEN critical errors prevent gameplay THEN the system SHALL guide users to alternative game modes or recovery actions