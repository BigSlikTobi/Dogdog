# Implementation Plan

-
  1. [ ] Create core treasure map system foundation
  - Create PathType enum with display names and descriptions for all 5 themed
    paths
  - Create Checkpoint enum with question requirements, display names, and image
    paths
  - Create TreasureMapController class to manage path progression and checkpoint
    tracking
  - Write unit tests for path selection and checkpoint progression logic
  - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2_

-
  2. [ ] Implement checkpoint-based power-up distribution system
- [ ] 2.1 Create CheckpointRewards system with balanced power-up distribution
  - Implement CheckpointRewards class with getRewardsForCheckpoint method
  - Define base power-up rewards for each checkpoint (Chihuahua through Deutsche
    Dogge)
  - Implement bonus power-up logic for high accuracy (80%+) performance
  - Ensure all 5 power-up types (fiftyFifty, hint, extraTime, skip,
    secondChance) are properly distributed
  - Write unit tests for power-up distribution algorithms
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

- [ ] 2.2 Fix power-up availability and usage logic
  - Update PowerUpController to properly handle all 5 power-up types
  - Fix power-up awarding logic in GameController to use checkpoint-based
    distribution
  - Ensure skip and secondChance power-ups are properly available and functional
  - Write integration tests for power-up usage across all types
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

-
  3. [ ] Fix lives display system to show accurate heart count
  - Create LivesController class to manage lives state independently
  - Update lives display widget to show exactly 3 hearts (not 4) based on actual
    lives count
  - Implement proper heart icon generation based on current lives vs max lives
  - Fix game over logic to use actual lives count rather than display
    assumptions
  - Update secondChance power-up to properly restore lives and update display
  - Write unit tests for lives display synchronization
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

-
  4. [ ] Implement persistent timer system with warnings
- [ ] 4.1 Create PersistentTimerController for improved timer management
  - Implement PersistentTimerController class with start, pause, resume, and
    addTime methods
  - Add timer warning system at 30% remaining time with visual and audio
    feedback
  - Implement proper timer state preservation during pause/resume cycles
  - Add smooth time addition animation for extraTime power-up usage
  - Write unit tests for timer persistence and warning triggers
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [ ] 4.2 Integrate enhanced timer with game flow
  - Update GameController to use PersistentTimerController instead of basic
    Timer
  - Implement proper timer reset and restart for each new question
  - Add timer expiration handling with immediate incorrect answer processing
  - Ensure timer state is properly maintained during screen transitions
  - Write integration tests for timer behavior during game state changes
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

-
  5. [ ] Create question pool management with no-repeat logic
  - Implement QuestionPoolManager class to handle question selection and
    exclusion
  - Create question filtering system based on PathType and difficulty
    progression
  - Implement question ID tracking to prevent repeats within the same path
  - Add question shuffling logic that maintains variety while avoiding
    duplicates
  - Create question pool reset logic for checkpoint fallback scenarios
  - Write unit tests for question exclusion and shuffling algorithms
  - _Requirements: 8.3, 8.4, 9.1, 9.2, 9.3, 9.4_

-
  6. [ ] Implement checkpoint fallback system
- [ ] 6.1 Create checkpoint fallback logic
  - Implement CheckpointFallbackHandler class to manage game over scenarios
  - Create logic to reset player to last completed checkpoint with restored
    lives
  - Implement checkpoint progress preservation including earned power-ups
  - Add question pool reset and reshuffling for checkpoint restart
  - Create user-friendly messaging system for checkpoint fallback explanations
  - Write unit tests for checkpoint fallback scenarios
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_

- [ ] 6.2 Integrate fallback system with game controller
  - Update GameController to handle checkpoint-based game over logic
  - Implement restartFromCheckpoint method with proper state restoration
  - Add checkpoint progress tracking and persistence across game sessions
  - Ensure power-up inventory is maintained during checkpoint fallback
  - Write integration tests for complete fallback and restart scenarios
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_

-
  7. [ ] Create path selection and treasure map UI
- [ ] 7.1 Build path selection screen
  - Create PathSelectionScreen widget with 5 themed path options
  - Implement path cards showing display names, descriptions, and preview
    information
  - Add path unlocking logic and visual indicators for locked/unlocked paths
  - Create smooth navigation to treasure map screen upon path selection
  - Write widget tests for path selection interactions
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_

- [ ] 7.2 Build treasure map visualization screen
  - Create TreasureMapScreen widget with visual progress representation
  - Implement TreasureMapPainter for custom treasure map drawing
  - Create CheckpointMarker widgets for each dog breed checkpoint
  - Add progress indicators showing current position and questions to next
    checkpoint
  - Implement checkpoint completion animations and visual celebrations
  - Write widget tests for treasure map interactions and visual states
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

-
  8. [ ] Update game screen with enhanced mechanics
- [ ] 8.1 Update game screen UI for treasure map integration
  - Modify GameScreen to show current path and checkpoint progress
  - Update lives display to show accurate heart count (3 hearts maximum)
  - Enhance power-up bar to properly display all 5 power-up types with
    availability
  - Add checkpoint progress indicator showing questions remaining to next
    milestone
  - Update timer display with warning states and enhanced visual feedback
  - Write widget tests for updated game screen components
  - _Requirements: 2.3, 2.4, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

- [ ] 8.2 Implement enhanced feedback and engagement systems
  - Add streak multiplier animations and visual celebrations for correct answers
  - Implement milestone progress animations when approaching checkpoints
  - Create satisfying power-up usage feedback with before/after state
    transitions
  - Add combo multiplier displays and bonus point animations
  - Implement personal best celebrations and achievement notifications
  - Write integration tests for feedback system responsiveness
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_

-
  9. [ ] Create checkpoint celebration and transition screens
  - Create CheckpointCelebrationScreen widget for milestone achievements
  - Implement checkpoint achievement animations using corresponding dog breed
    images
  - Add power-up reward display showing newly earned power-ups with counts
  - Create accuracy and performance summary display for completed checkpoint
  - Implement smooth transitions from celebration back to treasure map or next
    questions
  - Write widget tests for checkpoint celebration interactions
  - _Requirements: 2.5, 2.6, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

-
  10. [ ] Implement data persistence and state management
- [ ] 10.1 Create path progress persistence system
  - Implement PathProgress model for storing path completion data
  - Create GameSession model for current session state management
  - Add local storage for checkpoint progress, answered question IDs, and
    power-up inventory
  - Implement progress loading and saving across app sessions
  - Create migration logic for existing save data to new checkpoint system
  - Write unit tests for data persistence and loading logic
  - _Requirements: 9.4, 9.5, 9.6_

- [ ] 10.2 Update game controller for enhanced state management
  - Refactor GameController to integrate TreasureMapController and
    CheckpointSystem
  - Implement proper state synchronization between all controller components
  - Add error handling for state inconsistencies and recovery mechanisms
  - Create comprehensive game statistics tracking for path progression
  - Ensure all game mechanics maintain consistent state across interactions
  - Write integration tests for complete state management scenarios
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_

-
  11. [ ] Comprehensive testing and integration
  - Write integration tests for complete path progression from start to Deutsche
    Dogge
  - Test checkpoint fallback scenarios with various failure points
  - Verify power-up distribution and availability across all checkpoints
  - Test question pool management with no-repeat logic across multiple
    playthroughs
  - Validate timer persistence and warning systems under various game conditions
  - Create performance tests for treasure map rendering and checkpoint
    animations
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

-
  12. [ ] Polish and user experience enhancements
  - Add sound effects for checkpoint achievements and power-up usage
  - Implement haptic feedback for milestone achievements on mobile devices
  - Create tutorial system explaining the new treasure map progression
  - Add accessibility features for treasure map navigation and checkpoint
    identification
  - Implement smooth animations and transitions throughout the new system
  - Conduct user testing with target age group to validate engagement
    improvements
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_
