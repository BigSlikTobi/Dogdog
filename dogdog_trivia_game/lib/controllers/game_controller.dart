import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/question.dart';
import '../models/enums.dart';
import '../services/question_service.dart';
import '../services/progress_service.dart';
import '../services/error_service.dart';
import '../utils/retry_mechanism.dart';
import 'power_up_controller.dart';

/// Controller class that manages the game state and logic using Provider pattern
class GameController extends ChangeNotifier {
  final QuestionService _questionService;
  final PowerUpController _powerUpController;
  final ProgressService? _progressService;
  GameState _gameState = GameState.initial();
  Timer? _timer;
  int _recentMistakes = 0;

  GameController({
    QuestionService? questionService,
    PowerUpController? powerUpController,
    ProgressService? progressService,
  }) : _questionService = questionService ?? QuestionService(),
       _powerUpController = powerUpController ?? PowerUpController(),
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

  /// Time remaining for current question (if timed)
  int get timeRemaining => _gameState.timeRemaining;

  /// Whether timer is active for current level
  bool get isTimerActive => _gameState.isTimerActive;

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

  /// Whether incorrect feedback animation should be triggered
  bool get shouldTriggerIncorrectAnimation =>
      _gameState.lastAnswerWasCorrect == false && _gameState.isShowingFeedback;

  /// Power-up controller for managing power-ups
  PowerUpController get powerUpController => _powerUpController;

  /// Current power-up inventory
  Map<PowerUpType, int> get powerUps => _powerUpController.powerUps;

  /// Initializes a new game with the specified level
  ///
  /// [level] - Starting level (1-5)
  /// [questionsPerRound] - Number of questions to load for this round
  Future<void> initializeGame({
    int level = 1,
    int questionsPerRound = 10,
  }) async {
    try {
      final result = await GameLogicRetry.execute<void>(() async {
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
      });

      if (!result.success) {
        ErrorService().handleGameLogicError(
          result.error ?? Exception('Game initialization failed'),
        );

        // Create minimal fallback game state
        _gameState = GameState.initial();
        _gameState = _gameState.copyWith(
          level: level,
          isGameActive: false,
          lives: 0, // This will make isGameOver return true
        );
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

    final nextIndex = _gameState.currentQuestionIndex + 1;

    if (nextIndex >= _gameState.questions.length) {
      // Award power-ups for completing this set of questions
      _awardLevelCompletionPowerUps();

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

  /// Starts the countdown timer for the current question
  void _startTimer() {
    _stopTimer(); // Ensure no existing timer

    if (_gameState.timeRemaining <= 0) {
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newTimeRemaining = _gameState.timeRemaining - 1;

      if (newTimeRemaining <= 0) {
        _stopTimer();
        _onTimerExpired();
      } else {
        _gameState = _gameState.copyWith(timeRemaining: newTimeRemaining);
        notifyListeners();
      }
    });
  }

  /// Stops the current timer
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Pauses the game (stops timer, sets game inactive)
  void pauseGame() {
    if (_gameState.isGameActive) {
      _stopTimer();
      _gameState = _gameState.copyWith(isGameActive: false);
      notifyListeners();
    }
  }

  /// Resumes the game (restarts timer if needed, sets game active)
  void resumeGame() {
    if (!_gameState.isGameActive && !_gameState.isGameOver) {
      _gameState = _gameState.copyWith(isGameActive: true);

      if (_gameState.isTimerActive && _gameState.timeRemaining > 0) {
        _startTimer();
      }

      notifyListeners();
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
      notifyListeners();
    }

    return hint;
  }

  /// Uses the extra time power-up
  /// Returns true if successfully applied
  bool useExtraTime() {
    if (!_gameState.isGameActive ||
        _gameState.isGameOver ||
        !_gameState.isTimerActive) {
      return false;
    }

    final extraSeconds = _powerUpController.applyExtraTime();
    if (extraSeconds > 0) {
      _powerUpController.usePowerUp(PowerUpType.extraTime);

      // Add extra time to current timer
      final newTimeRemaining = _gameState.timeRemaining + extraSeconds;
      _gameState = _gameState.copyWith(timeRemaining: newTimeRemaining);

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

  /// Awards power-ups for completing a level
  void _awardLevelCompletionPowerUps() {
    // Award power-ups based on level and performance
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

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
