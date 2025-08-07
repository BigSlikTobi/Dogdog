# Requirements Document

## Introduction

This specification transforms the DogDog trivia game from a simple difficulty-based quiz into an engaging treasure map adventure with themed learning paths. The new system replaces the current easy/medium/hard/expert selection with topic-based paths (Dog Breeds, Dog Training, Health & Care, Dog Behavior, Dog History) where players progress through checkpoints representing dog breed achievements (Chihuahua → Cocker Spaniel → German Shepherd → Great Dane) every 10 questions. This addresses current issues with power-up availability, lives display accuracy, timer persistence, and overall engagement while creating a more compelling progression system.

## Requirements

### Requirement 1

**User Story:** As a player, I want to choose from different themed learning paths at the start, so that I can focus on the dog topics that interest me most.

#### Acceptance Criteria

1. WHEN starting a new game THEN the system SHALL present 5 themed path options: "Dog Breeds", "Dog Training", "Health & Care", "Dog Behavior", and "Dog History"
2. WHEN selecting a path THEN the system SHALL display a treasure map showing the progression route with 5 checkpoints
3. WHEN viewing the treasure map THEN the system SHALL show dog breed checkpoints: Chihuahua (10 questions), Cocker Spaniel (20 questions), German Shepherd (30 questions), Great Dane (40 questions), and Deutsche Dogge (50 questions)
4. WHEN a path is selected THEN the system SHALL load questions specific to that topic with progressive difficulty
5. WHEN displaying path selection THEN the system SHALL show preview information about each topic's content
6. WHEN a path is completed THEN the system SHALL unlock the next available path for continued play

### Requirement 2

**User Story:** As a player, I want to see my progress visually represented on a treasure map with clear checkpoints, so that I feel motivated to reach the next milestone.

#### Acceptance Criteria

1. WHEN viewing the treasure map THEN the system SHALL display a path with 5 checkpoints marked by dog breed images
2. WHEN progressing through questions THEN the system SHALL show a progress indicator moving along the map path
3. WHEN reaching a checkpoint THEN the system SHALL highlight the achieved dog breed with celebration animation
4. WHEN between checkpoints THEN the system SHALL show current position with "X/10 questions to next checkpoint"
5. WHEN completing a checkpoint THEN the system SHALL unlock the next section of the map with visual rewards
6. WHEN viewing completed checkpoints THEN the system SHALL display them with full color and achievement badges

### Requirement 3

**User Story:** As a player, I want the timer to be more persistent and engaging, so that time pressure adds meaningful challenge to the game.

#### Acceptance Criteria

1. WHEN the timer is active THEN the system SHALL maintain consistent countdown without interruptions
2. WHEN switching between questions THEN the system SHALL properly reset and restart the timer for each new question
3. WHEN the timer reaches critical levels (30% remaining) THEN the system SHALL provide visual and audio warnings
4. WHEN time runs out THEN the system SHALL immediately process it as an incorrect answer with appropriate feedback
5. WHEN using extraTime power-up THEN the system SHALL smoothly add time with visual feedback
6. WHEN pausing/resuming the game THEN the system SHALL properly handle timer state preservation

### Requirement 4

**User Story:** As a player, I want more engaging game mechanics that keep me motivated to continue playing, so that the game feels rewarding and addictive.

#### Acceptance Criteria

1. WHEN achieving answer streaks THEN the system SHALL provide escalating rewards and visual celebrations
2. WHEN completing question sets THEN the system SHALL show progress milestones with meaningful rewards
3. WHEN using power-ups THEN the system SHALL provide satisfying visual and audio feedback
4. WHEN making correct answers THEN the system SHALL display combo multipliers and bonus point animations
5. WHEN reaching new personal bests THEN the system SHALL celebrate achievements with special animations
6. WHEN the game session continues THEN the system SHALL introduce progressive challenges and variety

### Requirement 5

**User Story:** As a player, I want all 5 power-ups (50/50, hint, extra time, skip, second chance) to be equally available and properly distributed at checkpoints, so that I have access to the full range of strategic options throughout my treasure map journey.

#### Acceptance Criteria

1. WHEN reaching Chihuahua checkpoint (10 questions) THEN the system SHALL award 2 fiftyFifty, 2 hint, and 1 extraTime power-ups
2. WHEN reaching Cocker Spaniel checkpoint (20 questions) THEN the system SHALL award 2 fiftyFifty, 2 hint, 2 extraTime, and 1 skip power-up
3. WHEN reaching German Shepherd checkpoint (30 questions) THEN the system SHALL award 2 fiftyFifty, 2 hint, 2 extraTime, 2 skip, and 1 secondChance power-up
4. WHEN reaching Great Dane checkpoint (40 questions) THEN the system SHALL award 3 of each power-up type with bonus distribution for high performance
5. WHEN reaching Deutsche Dogge checkpoint (50 questions) THEN the system SHALL award 4 of each power-up type as the ultimate treasure reward
6. WHEN achieving 80%+ accuracy at any checkpoint THEN the system SHALL provide bonus power-ups including guaranteed skip and secondChance

### Requirement 6

**User Story:** As a player, I want enhanced feedback systems that make my actions feel impactful, so that every interaction feels responsive and rewarding.

#### Acceptance Criteria

1. WHEN answering correctly THEN the system SHALL display immediate positive feedback with score animations
2. WHEN using power-ups THEN the system SHALL show clear before/after states with smooth transitions
3. WHEN losing lives THEN the system SHALL provide appropriate feedback without being overly punishing
4. WHEN achieving milestones THEN the system SHALL celebrate with appropriate animations and sound effects
5. WHEN the game state changes THEN the system SHALL ensure all UI elements update smoothly and consistently
6. WHEN player performance varies THEN the system SHALL adapt feedback intensity to maintain engagement

### Requirement 7

**User Story:** As a player, I want the lives display to accurately reflect the actual number of lives I have, so that I can properly track my remaining chances without confusion.

#### Acceptance Criteria

1. WHEN starting any treasure map path THEN the system SHALL display exactly 3 hearts representing 3 lives
2. WHEN a life is lost THEN the system SHALL update the display to show the correct number of remaining hearts
3. WHEN using secondChance power-up THEN the system SHALL update the hearts display to reflect the restored life
4. WHEN the lives display renders THEN the system SHALL never show more hearts than the actual lives available
5. WHEN checking game over conditions THEN the system SHALL use the actual lives count, not a fixed display count
6. WHEN the game state changes THEN the system SHALL ensure the lives display stays synchronized with the actual lives value

### Requirement 8

**User Story:** As a player, I want to restart from my last checkpoint when I run out of lives, so that I don't lose all my progress but still face meaningful consequences for failure.

#### Acceptance Criteria

1. WHEN running out of lives THEN the system SHALL reset the player to their last completed checkpoint
2. WHEN restarting from a checkpoint THEN the system SHALL restore 3 lives and maintain all earned power-ups from that checkpoint
3. WHEN restarting from a checkpoint THEN the system SHALL shuffle the question pool to provide fresh questions
4. WHEN restarting from a checkpoint THEN the system SHALL ensure no previously answered questions are repeated
5. WHEN falling back to a checkpoint THEN the system SHALL display a clear message explaining the restart and progress preservation
6. WHEN no checkpoints have been reached THEN the system SHALL restart from the beginning of the selected path

### Requirement 9

**User Story:** As a player, I want the game to maintain consistent state and mechanics across all interactions, so that the experience feels polished and reliable.

#### Acceptance Criteria

1. WHEN any game mechanic is triggered THEN the system SHALL maintain consistent state across all components
2. WHEN power-ups are used THEN the system SHALL properly update inventory counts and availability
3. WHEN game events occur THEN the system SHALL ensure proper synchronization between controller and UI states
4. WHEN transitioning between game phases THEN the system SHALL preserve all relevant game state information
5. WHEN error conditions arise THEN the system SHALL handle them gracefully without breaking game mechanics
6. WHEN the game is paused/resumed THEN the system SHALL maintain perfect state consistency