import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/question.dart';
import '../models/enums.dart';
import '../models/path_progress.dart';
import '../models/game_session.dart';
import '../services/question_service.dart';
import '../services/progress_service.dart';
import '../services/error_service.dart';
import '../services/checkpoint_rewards.dart';
import '../services/checkpoint_fallback_handler.dart';
import '../services/game_persistence_service.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import 'power_up_controller.dart';
import 'treasure_map_controller.dart';
import 'persistent_timer_controller.dart';

/// Controller class that manages the game state and logic using Provider pattern
class GameController extends ChangeNotifier {
  final QuestionService _questionService;
  final PowerUpController _powerUpController;
  final TreasureMapController _treasureMapController;
  final PersistentTimerController _timerController;
  final GamePersistenceService _persistenceService;
  final bool _shouldDisposeTimerController;
  final ProgressService? _progressService;

  GameState _gameState = GameState.initial();
  PathProgress? _currentPathProgress;
  GameSession? _currentSession;
  Timer? _timer; // Keep for compatibility during transition
  int _recentMistakes = 0;

  /// Callback for when a checkpoint is reached
  void Function(
    Checkpoint checkpoint,
    Map<PowerUpType, int> earnedPowerUps,
    int questionsAnswered,
    double accuracy,
    int pointsEarned,
    bool isPathCompleted,
  )?
  _onCheckpointReached;

  GameController({
    QuestionService? questionService,
    PowerUpController? powerUpController,
    TreasureMapController? treasureMapController,
    PersistentTimerController? timerController,
    GamePersistenceService? persistenceService,
    ProgressService? progressService,
  }) : _questionService = questionService ?? QuestionService(),
       _powerUpController = powerUpController ?? PowerUpController(),
       _treasureMapController =
           treasureMapController ?? TreasureMapController(),
       _timerController = timerController ?? PersistentTimerController(),
       _persistenceService = persistenceService ?? GamePersistenceService(),
       _shouldDisposeTimerController = timerController == null,
       _progressService = progressService;

  /// Current game state
  GameState get gameState => _gameState;

  /// Current question being displayed
  Question? get currentQuestion => _gameState.currentQuestion;

  /// Whether the game is currently active
  bool get isGameActive => _gameState.isGameActive;

  /// Whether the game is over (no lives remaining)
  bool get isGameOver => _gameState.isGameOver;

  /// Current score
  int get score => _gameState.score;

  /// Current lives remaining
  int get lives => _gameState.lives;

  /// Current streak count
  int get streak => _gameState.streak;

  /// Current level
  int get level => _gameState.level;

  /// Score multiplier based on current streak
  int get scoreMultiplier => _gameState.scoreMultiplier;

  /// Time remaining for current question (if timed) - now uses PersistentTimerController
  int get timeRemaining => _timerController.timeRemaining;

  /// Whether timer is active for current level
  bool get isTimerActive =>
      _gameState.isTimerActive && _timerController.isActive;

  /// Timer progress (0.0 to 1.0)
  double get timerProgress => _timerController.progress;

  /// Whether timer is in critical time (≤30% remaining)
  bool get isTimerCritical => _timerController.isInCriticalTime;

  /// Whether timer warning has been triggered
  bool get isTimerWarningTriggered => _timerController.isWarningTriggered;

  /// Whether feedback is currently being shown
  bool get isShowingFeedback => _gameState.isShowingFeedback;

  /// The selected answer index (if any)
  int? get selectedAnswerIndex => _gameState.selectedAnswerIndex;

  /// Whether the last answer was correct (if any)
  bool? get lastAnswerWasCorrect => _gameState.lastAnswerWasCorrect;

  /// List of disabled answer indices (from 50/50 power-up)
  List<int> get disabledAnswerIndices => _gameState.disabledAnswerIndices;

  /// Whether success animation should be triggered
  bool get shouldTriggerSuccessAnimation =>
      _gameState.lastAnswerWasCorrect == true && _gameState.isShowingFeedback;

  // Persistence-related getters

  /// Current path progress
  PathProgress? get currentPathProgress => _currentPathProgress;

  /// Current game session
  GameSession? get currentSession => _currentSession;

  /// Whether a session is currently active
  bool get hasActiveSession => _currentSession != null;

  /// Whether incorrect feedback animation should be triggered
  bool get shouldTriggerIncorrectAnimation =>
      _gameState.lastAnswerWasCorrect == false && _gameState.isShowingFeedback;

  /// Power-up controller for managing power-ups
  PowerUpController get powerUpController => _powerUpController;

  /// Current power-up inventory
  Map<PowerUpType, int> get powerUps => _powerUpController.powerUps;

  /// Treasure map controller for managing path progression
  TreasureMapController get treasureMapController => _treasureMapController;

  /// Current path being played
  PathType get currentPath => _treasureMapController.currentPath;

  /// Next checkpoint to reach
  Checkpoint? get nextCheckpoint => _treasureMapController.nextCheckpoint;

  /// Questions remaining to next checkpoint
  int get questionsToNextCheckpoint =>
      _treasureMapController.questionsToNextCheckpoint;

  /// Progress toward next checkpoint (0.0 to 1.0)
  double get progressToNextCheckpoint =>
      _treasureMapController.progressToNextCheckpoint;

  /// Sets the callback for when a checkpoint is reached
  void setCheckpointReachedCallback(
    void Function(
      Checkpoint checkpoint,
      Map<PowerUpType, int> earnedPowerUps,
      int questionsAnswered,
      double accuracy,
      int pointsEarned,
      bool isPathCompleted,
    )?
    callback,
  ) {
    _onCheckpointReached = callback;
  }

  /// Initializes a new path-based game with the treasure map system
  ///
  /// [path] - The themed path to play
  /// [startFromCheckpoint] - Optional checkpoint to start from (for fallback scenarios)
  Future<void> initializePathGame({
    required PathType path,
    Checkpoint? startFromCheckpoint,
  }) async {
    try {
      // Initialize the treasure map controller with the selected path
      _treasureMapController.initializePath(path);

      // If starting from a checkpoint, reset to that checkpoint
      if (startFromCheckpoint != null) {
        _treasureMapController.resetToCheckpoint(startFromCheckpoint);
      }

      // Ensure question service is initialized
      if (!_questionService.isInitialized) {
        await _questionService.initialize();
      }

      // Get questions for the path with adaptive difficulty
      final questions = _questionService.getQuestionsWithAdaptiveDifficulty(
        count: 10,
        playerLevel: 1, // Start at level 1 for path-based games
        streakCount: 0,
        recentMistakes: 0,
      );

      if (questions.isEmpty) {
        throw Exception('No questions available for path $path');
      }

      // Create initial game state for path-based game
      _gameState = GameState(
        currentQuestionIndex: 0,
        score: 0,
        lives: 3, // Always start with 3 lives in treasure map mode
        streak: 0,
        level: 1, // Path-based games start at level 1
        questions: questions,
        powerUps: {for (PowerUpType type in PowerUpType.values) type: 0},
        isGameActive: true,
        timeRemaining: 0, // No timer initially
        isTimerActive: false, // Timer will be enabled based on progress
        totalQuestionsAnswered: 0,
        correctAnswersInSession: 0,
        isShowingFeedback: false,
        selectedAnswerIndex: null,
        lastAnswerWasCorrect: null,
        disabledAnswerIndices: [],
      );

      _recentMistakes = 0;

      notifyListeners();
    } catch (error, stackTrace) {
      ErrorService().recordError(
        ErrorType.gameLogic,
        'Critical failure in path game initialization: $error',
        severity: ErrorSeverity.high,
        stackTrace: stackTrace,
        originalError: error,
      );

      // Create safe fallback state
      _gameState = GameState.initial();
      notifyListeners();
      rethrow;
    }
  }

  /// Initializes a new game with the specified level (legacy method for backward compatibility)
  ///
  /// [level] - Starting level (1-5)
  /// [questionsPerRound] - Number of questions to load for this round
  Future<void> initializeGame({
    int level = 1,
    int questionsPerRound = 10,
  }) async {
    try {
      // Ensure question service is initialized
      if (!_questionService.isInitialized) {
        await _questionService.initialize();
      }

      // Get questions with adaptive difficulty
      final questions = _questionService.getQuestionsWithAdaptiveDifficulty(
        count: questionsPerRound,
        playerLevel: level,
        streakCount: 0,
        recentMistakes: 0,
      );

      if (questions.isEmpty) {
        throw Exception('No questions available for level $level');
      }

      // Create initial game state
      _gameState = GameState(
        currentQuestionIndex: 0,
        score: 0,
        lives: level >= 5 ? 2 : 3, // Level 5+ starts with 2 lives
        streak: 0,
        level: level,
        questions: questions,
        powerUps: {for (PowerUpType type in PowerUpType.values) type: 0},
        isGameActive: true,
        timeRemaining: _getTimeLimitForLevel(level),
        isTimerActive: level > 1, // Timer starts from level 2
        totalQuestionsAnswered: 0,
        correctAnswersInSession: 0,
        isShowingFeedback: false,
        selectedAnswerIndex: null,
        lastAnswerWasCorrect: null,
        disabledAnswerIndices: [],
      );

      _recentMistakes = 0;

      // Start timer if needed
      if (_gameState.isTimerActive) {
        _startTimer();
      }

      notifyListeners();
    } catch (error, stackTrace) {
      ErrorService().recordError(
        ErrorType.gameLogic,
        'Critical failure in game initialization: $error',
        severity: ErrorSeverity.high,
        stackTrace: stackTrace,
        originalError: error,
      );

      // Create safe fallback state
      _gameState = GameState.initial();
      notifyListeners();
      rethrow;
    }
  }

  /// Initializes a new game session with path-based persistence support
  /// This is the main entry point for the treasure map system
  ///
  /// [pathType] - The selected learning path
  /// [resumeSession] - Whether to resume existing session or start fresh
  Future<void> initializeGameWithPath({
    required PathType pathType,
    bool resumeSession = true,
  }) async {
    try {
      // Initialize persistence service
      await _persistenceService.initialize();

      // Load or create path progress
      _currentPathProgress = await _persistenceService.getOrCreatePathProgress(
        pathType,
      );

      // Update treasure map controller with current path
      _treasureMapController.initializePath(pathType);

      // Handle session resumption or creation
      if (resumeSession) {
        _currentSession = await _persistenceService.loadGameSession();

        // Validate session matches current path
        if (_currentSession?.currentPath != pathType) {
          _currentSession = null; // Invalid session, start fresh
        }
      }

      // Create new session if none exists or resumption disabled
      if (_currentSession == null) {
        _currentSession = GameSession(
          sessionStart: DateTime.now(),
        ).startNewSession(pathType);
        await _persistenceService.saveGameSession(_currentSession!);
      }

      // Ensure question service is initialized
      if (!_questionService.isInitialized) {
        await _questionService.initialize();
      }

      // Get questions based on path and answered history
      final availableQuestions = await _getQuestionsForPath(
        pathType: pathType,
        excludeAnsweredIds: _currentPathProgress!.answeredQuestionIds,
      );

      if (availableQuestions.isEmpty) {
        throw Exception('No questions available for path $pathType');
      }

      // Initialize power-ups from path progress
      final powerUpsMap = Map<PowerUpType, int>.from(
        _currentPathProgress!.powerUpInventory,
      );

      // Sync power-ups with controller
      _powerUpController.setPowerUps(powerUpsMap);

      // Create initial game state
      _gameState = GameState(
        currentQuestionIndex: 0,
        score: 0,
        lives: _currentSession!.livesRemaining,
        streak: _currentSession!.currentStreak,
        level: 1, // Level is now determined by checkpoint progress
        questions: availableQuestions,
        powerUps: powerUpsMap,
        isGameActive: true,
        timeRemaining: _getTimeLimitForLevel(1),
        isTimerActive: true,
        totalQuestionsAnswered: _currentSession!.sessionQuestionIds.length,
        correctAnswersInSession: 0, // Reset for new session segment
        isShowingFeedback: false,
        selectedAnswerIndex: null,
        lastAnswerWasCorrect: null,
        disabledAnswerIndices: [],
      );

      _recentMistakes = 0;

      // Start timer
      _startTimer();

      notifyListeners();
    } catch (error, stackTrace) {
      ErrorService().recordError(
        ErrorType.gameLogic,
        'Critical failure in path-based game initialization: $error',
        severity: ErrorSeverity.high,
        stackTrace: stackTrace,
        originalError: error,
      );

      // Create safe fallback state
      _gameState = GameState.initial();
      _currentPathProgress = null;
      _currentSession = null;
      notifyListeners();
      rethrow;
    }
  }

  /// Gets questions for a specific path while excluding already answered ones
  Future<List<Question>> _getQuestionsForPath({
    required PathType pathType,
    required List<String> excludeAnsweredIds,
    int count = 10,
  }) async {
    // This is a placeholder - in a real implementation, you would filter questions
    // based on the path type and exclude answered questions
    final allQuestions = _questionService.getQuestionsWithAdaptiveDifficulty(
      count: count * 2, // Get more questions to filter from
      playerLevel: 1,
      streakCount: _gameState.streak,
      recentMistakes: _recentMistakes,
    );

    // Filter out already answered questions
    final filteredQuestions = allQuestions
        .where((q) => !excludeAnsweredIds.contains(q.id))
        .take(count)
        .toList();

    return filteredQuestions;
  }

  /// Processes a player's answer to the current question
  ///
  /// [selectedAnswerIndex] - Index of the selected answer (0-3)
  /// Returns true if the answer was correct, false otherwise
  bool processAnswer(int selectedAnswerIndex) {
    if (!_gameState.isGameActive ||
        _gameState.isGameOver ||
        _gameState.isShowingFeedback) {
      return false;
    }

    final currentQuestion = _gameState.currentQuestion;
    if (currentQuestion == null) {
      return false;
    }

    // Stop timer if active
    _stopTimer();

    final isCorrect = selectedAnswerIndex == currentQuestion.correctAnswerIndex;

    // Show immediate feedback
    _gameState = _gameState.copyWith(
      isShowingFeedback: true,
      selectedAnswerIndex: selectedAnswerIndex,
      lastAnswerWasCorrect: isCorrect,
    );

    if (isCorrect) {
      _handleCorrectAnswer(currentQuestion);
    } else {
      _handleIncorrectAnswer();
    }

    // Update total questions answered
    _gameState = _gameState.copyWith(
      totalQuestionsAnswered: _gameState.totalQuestionsAnswered + 1,
    );

    // Save progress if using path-based system
    if (_currentPathProgress != null && _currentSession != null) {
      _saveAnswerProgress(currentQuestion, isCorrect);
    }

    notifyListeners();
    return isCorrect;
  }

  /// Handles logic for correct answers
  void _handleCorrectAnswer(Question question) {
    // Calculate points based on difficulty and multiplier
    final basePoints = question.difficulty.points;
    final points = basePoints * _gameState.scoreMultiplier;

    // Update game state
    _gameState = _gameState.copyWith(
      score: _gameState.score + points,
      streak: _gameState.streak + 1,
      correctAnswersInSession: _gameState.correctAnswersInSession + 1,
    );

    // Reset recent mistakes counter on correct answer
    _recentMistakes = 0;

    // Enhanced audio and haptic feedback
    _playCorrectAnswerFeedback();

    // Update progress service with correct answer
    _progressService?.recordCorrectAnswer(
      pointsEarned: points,
      currentStreak: _gameState.streak,
    );
  }

  /// Handles logic for incorrect answers
  void _handleIncorrectAnswer() {
    // Lose a life and reset streak
    final newLives = _gameState.lives - 1;

    _gameState = _gameState.copyWith(lives: newLives, streak: 0);

    // Track recent mistakes for adaptive difficulty
    _recentMistakes++;

    // Enhanced audio and haptic feedback
    _playIncorrectAnswerFeedback();

    // Update progress service with incorrect answer
    _progressService?.recordIncorrectAnswer();

    // Check if game is over
    if (newLives <= 0) {
      _endGame();
    }
  }

  /// Clears the current feedback state
  void clearFeedback() {
    if (_gameState.isShowingFeedback) {
      _gameState = _gameState.copyWith(
        isShowingFeedback: false,
        selectedAnswerIndex: null,
        lastAnswerWasCorrect: null,
        disabledAnswerIndices: [], // Clear disabled answers for next question
      );
      notifyListeners();
    }
  }

  /// Moves to the next question in the sequence
  void nextQuestion() {
    if (!_gameState.isGameActive || _gameState.isGameOver) {
      return;
    }

    // Update treasure map progress if using path-based game
    _treasureMapController.incrementQuestionCount();

    // Check if we've reached a checkpoint
    final nextCheckpoint = _treasureMapController.nextCheckpoint;
    if (nextCheckpoint != null &&
        _treasureMapController.currentQuestionCount >=
            nextCheckpoint.questionsRequired) {
      _handleCheckpointReached(nextCheckpoint);
    }

    final nextIndex = _gameState.currentQuestionIndex + 1;

    if (nextIndex >= _gameState.questions.length) {
      // Award power-ups for completing this set of questions
      _awardLevelCompletionPowerUps();

      // Check if this is a test scenario (small number of questions)
      // In tests, we typically only provide 1-2 questions, so end the game
      if (_gameState.questions.length <= 2) {
        _endGame();
        notifyListeners();
        return;
      }

      // Load more questions to continue the game
      _loadMoreQuestionsAndContinue();
      return;
    }

    // Clear feedback state and move to next question
    _gameState = _gameState.copyWith(
      currentQuestionIndex: nextIndex,
      timeRemaining: _getTimeLimitForLevel(_gameState.level),
      isShowingFeedback: false,
      selectedAnswerIndex: null,
      lastAnswerWasCorrect: null,
      disabledAnswerIndices: [], // Clear disabled answers for next question
    );

    // Start timer for next question if needed
    if (_gameState.isTimerActive) {
      _startTimer();
    }

    notifyListeners();
  }

  /// Handles timer expiration (automatic incorrect answer)
  void _onTimerExpired() {
    if (_gameState.isGameActive && !_gameState.isGameOver) {
      // Treat timer expiration as incorrect answer
      _handleIncorrectAnswer();
      notifyListeners();
    }
  }

  /// Starts the countdown timer for the current question using PersistentTimerController
  void _startTimer() {
    final timeLimit = _getTimeLimitForLevel(_gameState.level);
    if (timeLimit <= 0) {
      return;
    }

    _timerController.startTimer(
      seconds: timeLimit,
      onTimeExpired: _onTimerExpired,
      onWarning: () {
        // Timer warning callback - can be used for UI feedback
        notifyListeners();
      },
    );
  }

  /// Stops the current timer using PersistentTimerController
  void _stopTimer() {
    _timerController.stopTimer();
    _timer?.cancel(); // Keep old timer cleanup for compatibility
    _timer = null;
  }

  /// Pauses the game (stops timer, sets game inactive)
  void pauseGame() {
    if (_gameState.isGameActive) {
      _timerController.pauseTimer();
      _gameState = _gameState.copyWith(isGameActive: false);
      notifyListeners();
    }
  }

  /// Resumes the game (restarts timer if needed, sets game active)
  void resumeGame() {
    if (!_gameState.isGameActive && !_gameState.isGameOver) {
      _gameState = _gameState.copyWith(isGameActive: true);

      if (_timerController.isActive && _timerController.timeRemaining > 0) {
        _timerController.resumeTimer();
      }

      notifyListeners();
    }
  }

  /// Saves answer progress to persistent storage
  Future<void> _saveAnswerProgress(Question question, bool isCorrect) async {
    try {
      if (_currentPathProgress == null || _currentSession == null) return;

      // Update path progress with answered question
      _currentPathProgress = _currentPathProgress!.addAnsweredQuestion(
        question.id,
      );

      // Update session with question and streak
      _currentSession = _currentSession!
          .addSessionQuestion(question.id)
          .updateStreak(isCorrect);

      // Save updated progress and session
      await _persistenceService.savePathProgress(_currentPathProgress!);
      await _persistenceService.saveGameSession(_currentSession!);

      // Check if we've reached a checkpoint
      await _checkCheckpointProgress();
    } catch (error, stackTrace) {
      ErrorService().recordError(
        ErrorType.storage,
        'Failed to save answer progress: $error',
        severity: ErrorSeverity.medium,
        stackTrace: stackTrace,
        originalError: error,
      );
      // Don't rethrow - game should continue even if save fails
    }
  }

  /// Checks if the player has reached a new checkpoint
  Future<void> _checkCheckpointProgress() async {
    if (_currentPathProgress == null) return;

    final currentCheckpoint = _currentPathProgress!.currentCheckpoint;
    final questionsAnswered =
        _currentSession!.sessionQuestionIds.length +
        _currentPathProgress!.answeredQuestionIds.length -
        _currentSession!.sessionQuestionIds.length; // Avoid double counting

    // Check if we should advance to next checkpoint
    final nextCheckpoint = _currentPathProgress!.nextCheckpoint;
    if (nextCheckpoint != currentCheckpoint &&
        questionsAnswered >= nextCheckpoint.questionsRequired) {
      // Award checkpoint rewards
      final earnedPowerUps = CheckpointRewards.getRewardsForCheckpoint(
        nextCheckpoint,
        _currentPathProgress!.currentAccuracy,
      );

      // Update path progress
      _currentPathProgress = _currentPathProgress!
          .advanceCheckpoint()
          .addPowerUps(earnedPowerUps);

      // Update treasure map controller
      _treasureMapController.completeCheckpoint(nextCheckpoint);

      // Update power-up controller
      _powerUpController.addPowerUps(earnedPowerUps);

      // Provide enhanced feedback for checkpoint completion
      await _playCheckpointCompleteFeedback();

      // Save updated progress
      await _persistenceService.savePathProgress(_currentPathProgress!);

      // Trigger checkpoint reached callback
      _onCheckpointReached?.call(
        nextCheckpoint,
        earnedPowerUps,
        questionsAnswered,
        _currentPathProgress!.currentAccuracy,
        _gameState.score,
        _currentPathProgress!.isCompleted,
      );
    }
  }

  /// Ends the current game
  void _endGame() {
    _stopTimer();
    _gameState = _gameState.copyWith(isGameActive: false);

    // Record game completion with progress service
    _progressService?.recordGameCompletion(
      finalScore: _gameState.score,
      levelReached: _gameState.level,
    );
  }

  /// Restarts the game with the same level
  Future<void> restartGame() async {
    _stopTimer();
    await initializeGame(level: _gameState.level);
  }

  /// Resets the game to initial state
  void resetGame() {
    _stopTimer();
    _gameState = GameState.initial();
    _recentMistakes = 0;

    // Clear power-up controller state
    _powerUpController.resetPowerUps();

    notifyListeners();
  }

  /// Gets the time limit for a specific level
  int _getTimeLimitForLevel(int level) {
    switch (level) {
      case 1:
        return 0; // No timer for level 1
      case 2:
        return 20;
      case 3:
        return 15;
      case 4:
        return 12;
      case 5:
      default:
        return 10;
    }
  }

  /// Loads more questions for continued play
  /// This can be used when the current question set is exhausted
  Future<void> loadMoreQuestions({int count = 10}) async {
    try {
      final newQuestions = _questionService.getQuestionsWithAdaptiveDifficulty(
        count: count,
        playerLevel: _gameState.level,
        streakCount: _gameState.streak,
        recentMistakes: _recentMistakes,
      );

      if (newQuestions.isNotEmpty) {
        final allQuestions = [..._gameState.questions, ...newQuestions];
        _gameState = _gameState.copyWith(questions: allQuestions);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading more questions: $e');
    }
  }

  /// Loads more questions and continues the game seamlessly
  /// This is called when the current question set is exhausted
  void _loadMoreQuestionsAndContinue() {
    try {
      final newQuestions = _questionService.getQuestionsWithAdaptiveDifficulty(
        count: 10,
        playerLevel: _gameState.level,
        streakCount: _gameState.streak,
        recentMistakes: _recentMistakes,
      );

      if (newQuestions.isNotEmpty) {
        // Add new questions to the existing list
        final allQuestions = [..._gameState.questions, ...newQuestions];

        // Move to the next question (which is now the first of the new questions)
        final nextIndex = _gameState.currentQuestionIndex + 1;

        _gameState = _gameState.copyWith(
          questions: allQuestions,
          currentQuestionIndex: nextIndex,
          timeRemaining: _getTimeLimitForLevel(_gameState.level),
          isShowingFeedback: false,
          selectedAnswerIndex: null,
          lastAnswerWasCorrect: null,
          disabledAnswerIndices: [], // Clear disabled answers for next question
        );

        // Start timer for next question if needed
        if (_gameState.isTimerActive) {
          _startTimer();
        }

        notifyListeners();
      } else {
        // No more questions available - end the game
        debugPrint('No more questions available, ending game');
        _endGame();
      }
    } catch (e) {
      debugPrint('Error loading more questions and continuing: $e');
      // If we can't load more questions, end the game gracefully
      _endGame();
    }
  }

  /// Uses the 50/50 power-up on the current question
  /// Returns a list of answer indices that should be disabled
  List<int> useFiftyFifty() {
    if (!_gameState.isGameActive || _gameState.isGameOver) {
      return [];
    }

    final currentQuestion = _gameState.currentQuestion;
    if (currentQuestion == null) {
      return [];
    }

    final removedIndices = _powerUpController.applyFiftyFifty(currentQuestion);
    if (removedIndices.isNotEmpty) {
      _powerUpController.usePowerUp(PowerUpType.fiftyFifty);

      // Provide power-up feedback
      _playPowerUpFeedback(PowerUpType.fiftyFifty);

      // Update game state with disabled answer indices
      _gameState = _gameState.copyWith(disabledAnswerIndices: removedIndices);

      notifyListeners();
    }

    return removedIndices;
  }

  /// Uses the hint power-up on the current question
  /// Returns the hint text or null if not available
  String? useHint() {
    if (!_gameState.isGameActive || _gameState.isGameOver) {
      return null;
    }

    final currentQuestion = _gameState.currentQuestion;
    if (currentQuestion == null) {
      return null;
    }

    final hint = _powerUpController.applyHint(currentQuestion);
    if (hint != null) {
      _powerUpController.usePowerUp(PowerUpType.hint);

      // Provide power-up feedback
      _playPowerUpFeedback(PowerUpType.hint);

      notifyListeners();
    }

    return hint;
  }

  /// Uses the extra time power-up
  /// Returns true if successfully applied
  bool useExtraTime() {
    if (!_gameState.isGameActive ||
        _gameState.isGameOver ||
        !_timerController.isActive) {
      return false;
    }

    final extraSeconds = _powerUpController.applyExtraTime();
    if (extraSeconds > 0) {
      _powerUpController.usePowerUp(PowerUpType.extraTime);

      // Provide power-up feedback
      _playPowerUpFeedback(PowerUpType.extraTime);

      // Add extra time to current timer using the persistent timer controller
      _timerController.addTime(extraSeconds);

      notifyListeners();
      return true;
    }

    return false;
  }

  /// Uses the skip power-up
  /// Returns true if successfully applied
  bool useSkip() {
    if (!_gameState.isGameActive || _gameState.isGameOver) {
      return false;
    }

    if (_powerUpController.applySkip()) {
      _powerUpController.usePowerUp(PowerUpType.skip);

      // Provide power-up feedback
      _playPowerUpFeedback(PowerUpType.skip);

      // Move to next question without penalty
      nextQuestion();
      return true;
    }

    return false;
  }

  /// Uses the second chance power-up
  /// Returns true if successfully applied
  bool useSecondChance() {
    if (!_gameState.isGameActive || _gameState.lives >= 3) {
      return false;
    }

    if (_powerUpController.applySecondChance()) {
      _powerUpController.usePowerUp(PowerUpType.secondChance);

      // Provide power-up feedback
      _playPowerUpFeedback(PowerUpType.secondChance);

      // Restore one life
      _gameState = _gameState.copyWith(lives: _gameState.lives + 1);

      notifyListeners();
      return true;
    }

    return false;
  }

  /// Adds power-ups to the inventory (typically called after level completion)
  void addPowerUps(Map<PowerUpType, int> powerUpsToAdd) {
    _powerUpController.addPowerUps(powerUpsToAdd);
    notifyListeners();
  }

  /// Adds a single power-up to the inventory
  void addPowerUp(PowerUpType type, int count) {
    _powerUpController.addPowerUp(type, count);
    notifyListeners();
  }

  /// Checks if a power-up can be used
  bool canUsePowerUp(PowerUpType type) {
    return _powerUpController.canUsePowerUp(type);
  }

  /// Gets the count of a specific power-up
  int getPowerUpCount(PowerUpType type) {
    return _powerUpController.getPowerUpCount(type);
  }

  /// Handles when a checkpoint is reached in the treasure map system
  void _handleCheckpointReached(Checkpoint checkpoint) {
    // Mark the checkpoint as completed
    _treasureMapController.completeCheckpoint(checkpoint);

    // Calculate accuracy for this checkpoint segment
    final accuracy = _gameState.totalQuestionsAnswered > 0
        ? (_gameState.correctAnswersInSession /
              _gameState.totalQuestionsAnswered)
        : 0.0;

    // Award checkpoint-based power-ups
    final checkpointRewards = CheckpointRewards.getRewardsForCheckpoint(
      checkpoint,
      accuracy,
    );

    // Award the power-ups
    addPowerUps(checkpointRewards);

    // Trigger checkpoint celebration callback if set
    _onCheckpointReached?.call(
      checkpoint,
      checkpointRewards,
      _gameState.totalQuestionsAnswered,
      accuracy,
      _gameState.score,
      _treasureMapController.isPathCompleted,
    );
  }

  /// Handles game over scenarios with checkpoint fallback using the fallback handler
  void handleGameOver() {
    try {
      final fallbackHandler = CheckpointFallbackHandler();

      final result = fallbackHandler.handleGameOver(
        gameController: this,
        treasureMapController: _treasureMapController,
        powerUpController: _powerUpController,
      );

      // Apply the fallback result to the game state
      _applyFallbackResult(result);

      // Log the fallback statistics for debugging
      final stats = fallbackHandler.getFallbackStatistics(
        result: result,
        treasureMapController: _treasureMapController,
      );
      debugPrint('Checkpoint fallback applied: $stats');
    } catch (error, stackTrace) {
      ErrorService().recordError(
        ErrorType.gameLogic,
        'Error in checkpoint fallback: $error',
        severity: ErrorSeverity.high,
        stackTrace: stackTrace,
        originalError: error,
      );

      // Fallback to normal game over if checkpoint fallback fails
      _endGame();
    }
  }

  /// Restarts the game from a specific checkpoint with proper state restoration
  ///
  /// [checkpoint] - The checkpoint to restart from
  /// [excludeQuestionIds] - Set of question IDs to exclude from the new question pool
  Future<void> restartFromCheckpoint({
    required Checkpoint checkpoint,
    Set<String>? excludeQuestionIds,
  }) async {
    try {
      final fallbackHandler = CheckpointFallbackHandler();

      // Reset treasure map to the checkpoint
      _treasureMapController.resetToCheckpoint(checkpoint);

      // Get fresh questions for the checkpoint restart
      final freshQuestions = fallbackHandler.getQuestionsForCheckpointRestart(
        pathType: _treasureMapController.currentPath,
        checkpoint: checkpoint,
        excludeQuestionIds: excludeQuestionIds ?? <String>{},
        count: 10,
      );

      if (freshQuestions.isEmpty) {
        throw Exception('No questions available for checkpoint restart');
      }

      // Restore checkpoint power-ups
      final checkpointRewards = CheckpointRewards.getRewardsForCheckpoint(
        checkpoint,
        0.8, // Assume good performance for fallback scenario
      );
      _powerUpController.addPowerUps(checkpointRewards);

      // Update game state with restored lives and fresh questions
      _gameState = _gameState.copyWith(
        lives: 3, // Always restore to 3 lives
        questions: freshQuestions,
        currentQuestionIndex: 0,
        isGameActive: true,
        isShowingFeedback: false,
        selectedAnswerIndex: null,
        lastAnswerWasCorrect: null,
        disabledAnswerIndices: [],
        streak: 0, // Reset streak on checkpoint restart
        timeRemaining: _getTimeLimitForLevel(_gameState.level),
      );

      // Start timer if needed
      if (_gameState.isTimerActive) {
        _startTimer();
      }

      notifyListeners();
    } catch (error, stackTrace) {
      ErrorService().recordError(
        ErrorType.gameLogic,
        'Error in checkpoint restart: $error',
        severity: ErrorSeverity.high,
        stackTrace: stackTrace,
        originalError: error,
      );

      // Fallback to normal game restart if checkpoint restart fails
      await restartGame();
    }
  }

  /// Legacy method for backward compatibility - now uses the enhanced checkpoint system
  void restartFromLastCheckpoint() {
    final lastCheckpoint = _treasureMapController.lastCompletedCheckpoint;
    if (lastCheckpoint != null) {
      restartFromCheckpoint(checkpoint: lastCheckpoint);
    }
  }

  /// Applies the result of a checkpoint fallback operation to the game state
  void _applyFallbackResult(CheckpointFallbackResult result) {
    switch (result.action) {
      case FallbackAction.resetToCheckpoint:
        if (result.checkpoint != null) {
          // Restart from the checkpoint with fresh questions
          restartFromCheckpoint(checkpoint: result.checkpoint!);
        }
        break;

      case FallbackAction.restartFromBeginning:
        // Restart the path from the beginning
        initializePathGame(path: _treasureMapController.currentPath);
        break;

      case FallbackAction.error:
        // Handle error case by ending the game
        _endGame();
        break;
    }

    // Restore lives as specified in the result
    _gameState = _gameState.copyWith(lives: result.restoredLives);

    notifyListeners();
  }

  /// Awards power-ups for completing a level (legacy method for backward compatibility)
  void _awardLevelCompletionPowerUps() {
    // Check if we're using the treasure map system
    if (_treasureMapController.currentPath != PathType.dogBreeds) {
      // Use checkpoint-based rewards instead of legacy system
      return;
    }

    // Legacy power-up awarding system for backward compatibility
    final powerUpsToAward = <PowerUpType, int>{};

    // Base power-ups for completing any level
    powerUpsToAward[PowerUpType.fiftyFifty] = 1;
    powerUpsToAward[PowerUpType.hint] = 1;

    // Bonus power-ups based on level difficulty
    if (_gameState.level >= 2) {
      powerUpsToAward[PowerUpType.extraTime] = 1;
    }

    if (_gameState.level >= 3) {
      powerUpsToAward[PowerUpType.skip] = 1;
    }

    if (_gameState.level >= 4) {
      powerUpsToAward[PowerUpType.secondChance] = 1;
    }

    // Bonus power-ups for good performance
    final accuracy = _gameState.totalQuestionsAnswered > 0
        ? (_gameState.correctAnswersInSession /
              _gameState.totalQuestionsAnswered)
        : 0.0;

    if (accuracy >= 0.8) {
      // 80%+ accuracy gets bonus power-ups
      powerUpsToAward[PowerUpType.fiftyFifty] =
          (powerUpsToAward[PowerUpType.fiftyFifty] ?? 0) + 1;
      powerUpsToAward[PowerUpType.hint] =
          (powerUpsToAward[PowerUpType.hint] ?? 0) + 1;
    }

    if (_gameState.lives >= 2) {
      // Completing with 2+ lives gets extra power-ups
      powerUpsToAward[PowerUpType.extraTime] =
          (powerUpsToAward[PowerUpType.extraTime] ?? 0) + 1;
    }

    // Award the power-ups
    addPowerUps(powerUpsToAward);
  }

  /// Gets game statistics for the current session
  Map<String, dynamic> getGameStatistics() {
    return {
      'score': _gameState.score,
      'level': _gameState.level,
      'lives': _gameState.lives,
      'streak': _gameState.streak,
      'totalQuestions': _gameState.totalQuestionsAnswered,
      'correctAnswers': _gameState.correctAnswersInSession,
      'accuracy': _gameState.totalQuestionsAnswered > 0
          ? (_gameState.correctAnswersInSession /
                    _gameState.totalQuestionsAnswered *
                    100)
                .round()
          : 0,
      'isGameOver': _gameState.isGameOver,
      'isGameActive': _gameState.isGameActive,
      'powerUps': _powerUpController.powerUps,
    };
  }

  /// Provides enhanced audio and haptic feedback for correct answers
  Future<void> _playCorrectAnswerFeedback() async {
    try {
      // Play appropriate sound based on streak
      if (_gameState.streak >= 5) {
        await AudioService().playStreakBonusSound();
        await HapticService().streakBonusFeedback();
      } else {
        await AudioService().playCorrectAnswerSound();
        await HapticService().mediumFeedback();
      }
    } catch (e) {
      // Silently handle audio/haptic errors to prevent game disruption
    }
  }

  /// Provides enhanced audio and haptic feedback for incorrect answers
  Future<void> _playIncorrectAnswerFeedback() async {
    try {
      await AudioService().playIncorrectAnswerSound();
      await HapticService().incorrectAnswerFeedback();
    } catch (e) {
      // Silently handle audio/haptic errors to prevent game disruption
    }
  }

  /// Provides feedback for checkpoint completion
  Future<void> _playCheckpointCompleteFeedback() async {
    try {
      await AudioService().playCheckpointCompleteSound();
      await HapticService().checkpointCompleteFeedback();
    } catch (e) {
      // Silently handle audio/haptic errors to prevent game disruption
    }
  }

  /// Provides feedback for power-up usage
  Future<void> _playPowerUpFeedback(PowerUpType powerUpType) async {
    try {
      await AudioService().playPowerUpSpecificSound(powerUpType);
      await HapticService().powerUpFeedback(powerUpType);
    } catch (e) {
      // Silently handle audio/haptic errors to prevent game disruption
    }
  }

  @override
  void dispose() {
    _stopTimer();
    if (_shouldDisposeTimerController) {
      _timerController.dispose();
    }
    super.dispose();
  }
}
