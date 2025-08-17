import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/breed_adventure/breed_adventure_services.dart';
import '../../services/image_cache_service.dart';
import '../../services/audio_service.dart';
import '../../services/progress_service.dart';
import '../../services/error_service.dart';
import 'breed_adventure_power_up_controller.dart';
import '../../services/game_persistence_service.dart';

/// Controller for managing the Dog Breeds Adventure game state and logic
class BreedAdventureController extends ChangeNotifier {
  // Services
  final BreedService _breedService;
  final BreedAdventureTimer _timer;
  final ImageCacheService _imageCacheService;
  final OptimizedImageCacheService _optimizedImageCache;
  final BreedAdventureMemoryManager _memoryManager;
  final BreedAdventurePerformanceMonitor _performanceMonitor;
  final FrameRateOptimizer _frameRateOptimizer;
  final BreedAdventurePowerUpController _powerUpController;
  final AudioService _audioService;
  final ProgressService _progressService;
  final ErrorService _errorService;
  final GamePersistenceService _persistenceService;

  // Game state
  BreedAdventureGameState _gameState = BreedAdventureGameState.initial();
  BreedChallenge? _currentChallenge;
  StreamSubscription<int>? _timerSubscription;
  bool _isInitialized = false;
  AnswerFeedback _feedbackState = AnswerFeedback.none;
  int? _feedbackIndex;
  int _highScore = 0;

  // Error handling state
  int _consecutiveFailures = 0;
  bool _isInRecoveryMode = false;
  AppError? _lastError;
  final List<String> _failedImageUrls = [];

  // Configuration
  static const int baseScore = 100;
  static const int timeBonus = 10; // Points per second remaining
  static const int streakBonus = 50; // Bonus for consecutive correct answers
  static const int powerUpRewardThreshold =
      5; // Correct answers needed for power-up reward
  static const int maxLives = 3; // Maximum lives in the game
  static const int maxConsecutiveFailures =
      3; // Max failures before recovery mode
  static const int maxFailedUrls = 10; // Max failed URLs to track

  BreedAdventureController({
    BreedService? breedService,
    BreedAdventureTimer? timer,
    ImageCacheService? imageCacheService,
    BreedAdventurePowerUpController? powerUpController,
    AudioService? audioService,
    ProgressService? progressService,
    ErrorService? errorService,
    GamePersistenceService? persistenceService,
  }) : _breedService = breedService ?? BreedService.instance,
       _timer = timer ?? BreedAdventureTimer.instance,
       _imageCacheService = imageCacheService ?? ImageCacheService.instance,
       _optimizedImageCache = OptimizedImageCacheService.instance,
       _memoryManager = BreedAdventureMemoryManager.instance,
       _performanceMonitor = BreedAdventurePerformanceMonitor.instance,
       _frameRateOptimizer = FrameRateOptimizer.instance,
       _powerUpController =
           powerUpController ?? BreedAdventurePowerUpController(),
       _audioService = audioService ?? AudioService(),
       _progressService = progressService ?? ProgressService(),
       _errorService = errorService ?? ErrorService(),
       _persistenceService = persistenceService ?? GamePersistenceService();

  /// Current game state
  BreedAdventureGameState get gameState => _gameState;

  /// Current challenge being displayed
  BreedChallenge? get currentChallenge => _currentChallenge;

  /// The feedback state for the current answer.
  AnswerFeedback get feedbackState => _feedbackState;

  /// The index of the image that was selected.
  int? get feedbackIndex => _feedbackIndex;

  /// Current score
  int get currentScore => _gameState.score;

  /// High score
  int get highScore => _highScore;

  /// Current correct answers count
  int get correctAnswers => _gameState.correctAnswers;

  /// Current difficulty phase
  DifficultyPhase get currentPhase => _gameState.currentPhase;

  /// Remaining time from game state
  int get timeRemaining => _gameState.timeRemaining;

  /// Check if timer is running
  bool get isTimerRunning => _timer.isRunning;

  /// Power-up inventory
  Map<PowerUpType, int> get powerUpInventory => _powerUpController.powerUps;

  /// Check if game is active
  bool get isGameActive => _gameState.isGameActive;

  /// Check if game is initialized
  bool get isInitialized => _isInitialized;

  /// Get current lives remaining
  int get livesRemaining => maxLives - _getIncorrectAnswers();

  /// Get accuracy percentage
  double get accuracy => _gameState.accuracy;

  /// Get game duration in seconds
  int get gameDurationSeconds => _gameState.gameDurationSeconds;

  /// Error handling getters for testing and UI
  bool get hasError => _lastError != null;
  AppError? get currentError => _lastError;
  bool get isInRecoveryMode => _isInRecoveryMode;
  int get consecutiveFailures => _consecutiveFailures;
  bool get hasImageErrors => _failedImageUrls.isNotEmpty;

  /// Performance monitoring getters
  bool get isPerformingWell => _performanceMonitor.isPerformingWell;
  double get currentFPS => _performanceMonitor.getPerformanceStats().currentFPS;
  double get averageFPS => _performanceMonitor.getPerformanceStats().averageFPS;
  bool get shouldOptimizeMemory => _memoryManager.shouldOptimizeMemory;
  int get currentMemoryUsageMB =>
      _memoryManager.getMemoryStats().currentUsageMB;

  /// Get comprehensive performance statistics
  dynamic get performanceStats => _performanceMonitor.getPerformanceStats();
  dynamic get memoryStats => _memoryManager.getMemoryStats();
  dynamic get imageCacheStats => _optimizedImageCache.getPerformanceStats();
  int get failedImageCount => _failedImageUrls.length;

  /// Clear all error state
  void clearErrors() {
    _resetErrorState();
    notifyListeners();
  }

  /// Initialize the controller and all services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Reset error state
      _resetErrorState();

      // Initialize services with retry mechanism
      await _initializeServicesWithRetry();

      // Initialize power-ups for breed adventure
      _powerUpController.initializeForBreedAdventure();

      // Initialize app services for integration
      await _initializeAppServices();

      // Load high score
      _highScore = await _persistenceService.getBreedAdventureHighScore();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      await _handleInitializationError(e);
      throw Exception('Failed to initialize BreedAdventureController: $e');
    }
  }

  /// Start a new game
  Future<void> startGame() async {
    if (!_isInitialized) {
      throw StateError('Controller not initialized. Call initialize() first.');
    }

    // Reset game state
    _gameState = BreedAdventureGameState.initial().copyWith(
      isGameActive: true,
      gameStartTime: DateTime.now(),
      powerUps: Map.from(_powerUpController.powerUps),
    );

    // Set up timer subscription
    _timerSubscription?.cancel();
    _timerSubscription = _timer.timerStream.listen(_onTimerUpdate);

    // Generate first challenge
    await _generateNextChallenge();

    // Start background preloading for better performance
    _preloadInitialGameImages();

    notifyListeners();
  }

  /// Select an image (0 or 1) as the answer
  Future<void> selectImage(int imageIndex) async {
    if (!_isGameActive || _currentChallenge == null) return;

    // Stop the timer
    _timer.stop();

    final isCorrect = _currentChallenge!.isCorrectSelection(imageIndex);
    final timeRemaining = _timer.remainingSeconds;

    // Set feedback state and notify listeners to show it immediately
    _feedbackState = isCorrect
        ? AnswerFeedback.correct
        : AnswerFeedback.incorrect;
    _feedbackIndex = imageIndex;
    notifyListeners();

    if (isCorrect) {
      await _handleCorrectAnswer(timeRemaining);
    } else {
      await _handleIncorrectAnswer();
    }

    // Different delays for correct vs incorrect answers
    // Correct answers: shorter delay for faster gameplay
    // Incorrect answers: longer delay to process feedback
    final feedbackDelay = isCorrect
        ? const Duration(
            milliseconds: 300,
          ) // Fast progression for correct answers
        : const Duration(milliseconds: 300); // More time to see what went wrong

    await Future.delayed(feedbackDelay);

    // Proceed to the next challenge or end the game
    final incorrectAnswers = _getIncorrectAnswers();
    if (incorrectAnswers < maxLives) {
      await _generateNextChallenge();
    } else {
      await _endGame();
    }
  }

  /// Use a power-up
  Future<bool> usePowerUp(PowerUpType powerUpType) async {
    if (!_isGameActive || !_powerUpController.canUsePowerUp(powerUpType)) {
      return false;
    }

    bool success = false;

    switch (powerUpType) {
      case PowerUpType.extraTime:
        success = await _useExtraTimePowerUp();
        break;
      case PowerUpType.skip:
        success = await _useSkipPowerUp();
        break;
      case PowerUpType.fiftyFifty:
      case PowerUpType.hint:
      case PowerUpType.secondChance:
        // These power-ups are not supported in breed adventure mode
        success = false;
        break;
    }

    if (success) {
      // Power-up consumption is handled by the individual apply methods
      _updatePowerUpsInGameState();
      // Play power-up feedback sound
      await _playPowerUpFeedback(powerUpType);
      notifyListeners();
    }

    return success;
  }

  /// Pause the game (pauses timer)
  void pauseGame() {
    if (_isGameActive) {
      _timer.pause();
      notifyListeners();
    }
  }

  /// Resume the game (resumes timer)
  void resumeGame() {
    if (_isGameActive) {
      _timer.resume();
      notifyListeners();
    }
  }

  /// End the current game
  Future<void> endGame() async {
    await _endGame();
    notifyListeners();
  }

  /// Reset the controller to initial state
  void reset() {
    _timer.stop();
    _timerSubscription?.cancel();
    _timerSubscription = null;
    _currentChallenge = null;
    _gameState = BreedAdventureGameState.initial();
    _powerUpController.resetForNewGame();
    notifyListeners();
  }

  /// Handle correct answer
  Future<void> _handleCorrectAnswer(int timeRemaining) async {
    final phaseMultiplier = _gameState.currentPhase.scoreMultiplier;
    final timeBonusPoints = timeRemaining * timeBonus;
    final streakBonusPoints = _gameState.consecutiveCorrect >= 2
        ? streakBonus
        : 0;
    final totalPoints =
        (baseScore * phaseMultiplier) + timeBonusPoints + streakBonusPoints;

    _gameState = _gameState.copyWith(
      score: _gameState.score + totalPoints,
      correctAnswers: _gameState.correctAnswers + 1,
      totalQuestions: _gameState.totalQuestions + 1,
      consecutiveCorrect: _gameState.consecutiveCorrect + 1,
      usedBreeds: Set.from(_gameState.usedBreeds)
        ..add(_currentChallenge!.correctBreedName),
    );

    // Track correct answer for power-up rewards
    _powerUpController.trackCorrectAnswer();

    // Integrate with existing app systems
    await _playCorrectAnswerFeedback();
    await _recordCorrectAnswerProgress(totalPoints);

    // Check for phase progression
    await _checkPhaseProgression();
  }

  /// Handle incorrect answer
  Future<void> _handleIncorrectAnswer() async {
    _gameState = _gameState.copyWith(
      totalQuestions: _gameState.totalQuestions + 1,
      consecutiveCorrect: 0,
      usedBreeds: Set.from(_gameState.usedBreeds)
        ..add(_currentChallenge!.correctBreedName),
    );

    // Integrate with existing app systems
    await _playIncorrectAnswerFeedback();
    await _recordIncorrectAnswerProgress();
  }

  /// Generate the next challenge
  Future<void> _generateNextChallenge() async {
    // Reset feedback state for the new round
    _feedbackState = AnswerFeedback.none;
    _feedbackIndex = null;

    try {
      // Check if we need to progress to next phase
      if (!_breedService.hasAvailableBreeds(
        _gameState.currentPhase,
        _gameState.usedBreeds,
      )) {
        final nextPhase = _gameState.currentPhase.nextPhase;
        if (nextPhase != null) {
          _gameState = _gameState.copyWith(
            currentPhase: nextPhase,
            usedBreeds: <String>{}, // Reset used breeds for new phase
          );
        } else {
          // No more phases, end game
          await _endGame();
          return;
        }
      }

      // Generate new challenge
      _currentChallenge = await _breedService.generateChallenge(
        _gameState.currentPhase,
        _gameState.usedBreeds,
      );

      // Preload images
      await _preloadChallengeImages();

      // Start timer
      _timer.start();

      // Notify listeners of the new challenge and timer state
      notifyListeners();
    } catch (e) {
      debugPrint('Error generating challenge: $e');
      await _endGame();
    }
  }

  /// Preload images for the current challenge with performance optimization
  Future<void> _preloadChallengeImages() async {
    if (_currentChallenge == null) return;

    try {
      // Track image loading performance
      final stopwatch = Stopwatch()..start();

      _performanceMonitor.trackImageLoadStart(
        _currentChallenge!.correctImageUrl,
      );
      _performanceMonitor.trackImageLoadStart(
        _currentChallenge!.incorrectImageUrl,
      );

      // Use optimized image cache for immediate loading of current challenge images
      await _optimizedImageCache.preloadCriticalImages([
        _currentChallenge!.correctImageUrl,
        _currentChallenge!.incorrectImageUrl,
      ]);

      // Preload additional images from current phase in background for better performance
      _preloadBackgroundImages();

      stopwatch.stop();

      // Track completion times
      _performanceMonitor.trackImageLoadEnd(
        _currentChallenge!.correctImageUrl,
        stopwatch.elapsed,
      );
      _performanceMonitor.trackImageLoadEnd(
        _currentChallenge!.incorrectImageUrl,
        stopwatch.elapsed,
      );

      debugPrint('Images preloaded in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      debugPrint('Error preloading images: $e');
      // Continue anyway - images will load on demand
    }
  }

  /// Preload background images from current phase to improve future performance
  void _preloadBackgroundImages() {
    // Don't block the UI - run this in background
    Future.microtask(() async {
      try {
        final availableBreeds = _breedService.getAvailableBreeds(
          _gameState.currentPhase,
          _gameState.usedBreeds,
        );

        // Get image URLs from next few potential breeds (up to 10)
        final imageUrlsToPreload = availableBreeds
            .take(10)
            .map((breed) => breed.imageUrl)
            .where((url) => url.isNotEmpty)
            .toList();

        if (imageUrlsToPreload.isNotEmpty) {
          // Use the delayed preloading for background images
          await _optimizedImageCache.preloadNextImages(imageUrlsToPreload);
          debugPrint(
            'Background preloaded ${imageUrlsToPreload.length} images',
          );
        }
      } catch (e) {
        debugPrint('Error preloading background images: $e');
      }
    });
  }

  /// Preload initial game images when starting the game
  void _preloadInitialGameImages() {
    // Don't block the UI - run this in background
    Future.microtask(() async {
      try {
        // Get a sample of breeds from current phase for preloading
        final availableBreeds = _breedService.getAvailableBreeds(
          _gameState.currentPhase,
          <String>{}, // Empty set to get all available breeds
        );

        // Preload images from first 15 breeds to have them ready
        final initialImageUrls = availableBreeds
            .take(15)
            .map((breed) => breed.imageUrl)
            .where((url) => url.isNotEmpty)
            .toList();

        if (initialImageUrls.isNotEmpty) {
          // Use delayed preloading so it doesn't interfere with current challenge
          await _optimizedImageCache.preloadNextImages(initialImageUrls);
          debugPrint(
            'Initial game preloaded ${initialImageUrls.length} images',
          );
        }
      } catch (e) {
        debugPrint('Error preloading initial game images: $e');
      }
    });
  }

  /// Check if phase progression is needed
  Future<void> _checkPhaseProgression() async {
    if (!_breedService.hasAvailableBreeds(
      _gameState.currentPhase,
      _gameState.usedBreeds,
    )) {
      final nextPhase = _gameState.currentPhase.nextPhase;
      if (nextPhase != null) {
        _gameState = _gameState.copyWith(
          currentPhase: nextPhase,
          usedBreeds: <String>{}, // Reset used breeds for new phase
        );
      }
    }
  }

  /// Get power-up celebration message
  String getPowerUpCelebrationMessage(PowerUpType powerUpType) {
    return _powerUpController.getPowerUpCelebrationMessage(powerUpType);
  }

  /// Get power-up description
  String getPowerUpDescription(PowerUpType powerUpType) {
    return _powerUpController.getPowerUpDescription(powerUpType);
  }

  /// Check if close to earning a power-up reward
  bool get isCloseToReward => _powerUpController.isCloseToReward();

  /// Check if a power-up can be used
  bool canUsePowerUp(PowerUpType powerUpType) {
    return _isGameActive && _powerUpController.canUsePowerUp(powerUpType);
  }

  /// Use extra time power-up
  Future<bool> _useExtraTimePowerUp() async {
    if (_timer.isActive) {
      final extraSeconds = _powerUpController.applyBreedExtraTime();
      if (extraSeconds > 0) {
        _timer.addTime(extraSeconds);
        return true;
      }
    }
    return false;
  }

  /// Use skip power-up
  Future<bool> _useSkipPowerUp() async {
    if (_currentChallenge != null && _powerUpController.applyBreedSkip()) {
      // Mark breed as used without penalty
      _gameState = _gameState.copyWith(
        totalQuestions: _gameState.totalQuestions + 1,
        usedBreeds: Set.from(_gameState.usedBreeds)
          ..add(_currentChallenge!.correctBreedName),
      );

      // Generate next challenge
      await Future.delayed(const Duration(milliseconds: 500));
      await _generateNextChallenge();
      return true;
    }
    return false;
  }

  /// Get number of incorrect answers
  int _getIncorrectAnswers() {
    return _gameState.totalQuestions - _gameState.correctAnswers;
  }

  /// End the game
  Future<void> _endGame() async {
    _timer.stop();
    _timerSubscription?.cancel();
    _timerSubscription = null;

    if (_gameState.score > _highScore) {
      _highScore = _gameState.score;
      await _persistenceService.saveBreedAdventureHighScore(_highScore);
    }

    _gameState = _gameState.copyWith(isGameActive: false);
    notifyListeners();
  }

  /// Handle timer updates
  void _onTimerUpdate(int remainingSeconds) {
    _gameState = _gameState.copyWith(timeRemaining: remainingSeconds);
    notifyListeners();
  }

  /// Handle timer expiration
  Future<void> handleTimeExpired() async {
    if (!_isGameActive || _currentChallenge == null) return;

    // Treat as incorrect answer
    await _handleIncorrectAnswer();

    // No second chance - just continue normal flow
    final incorrectAnswers = _getIncorrectAnswers();
    if (incorrectAnswers < maxLives) {
      // Use same delay as incorrect answers for consistency
      await Future.delayed(const Duration(milliseconds: 600));
      await _generateNextChallenge();
    } else {
      await _endGame();
    }

    notifyListeners();
  }

  /// Update power-ups in game state
  void _updatePowerUpsInGameState() {
    _gameState = _gameState.copyWith(
      powerUps: Map.from(_powerUpController.powerUps),
    );
  }

  /// Check if game is active
  bool get _isGameActive => _gameState.isGameActive;

  /// Get game statistics
  GameStatistics getGameStatistics() {
    return GameStatistics.fromBreedAdventure(
      _gameState,
      _highScore,
      livesRemaining,
      _getTotalPowerUpsUsed(),
    );
  }

  /// Get total power-ups used
  int _getTotalPowerUpsUsed() {
    final initialPowerUps = {
      PowerUpType.hint: 2,
      PowerUpType.extraTime: 2,
      PowerUpType.skip: 1,
      PowerUpType.secondChance: 1,
    };

    int totalUsed = 0;
    for (final entry in initialPowerUps.entries) {
      final currentCount = _powerUpController.getPowerUpCount(entry.key);
      totalUsed += (entry.value - currentCount).clamp(0, entry.value);
    }

    return totalUsed;
  }

  /// Integrate with AudioService for correct answer feedback
  Future<void> _playCorrectAnswerFeedback() async {
    try {
      // Play appropriate sound based on streak
      if (_gameState.consecutiveCorrect >= 3) {
        await _audioService.playStreakBonusSound();
      } else {
        await _audioService.playCorrectAnswerSound();
      }
    } catch (e) {
      // Silently handle audio errors to prevent game disruption
      debugPrint('Audio error: $e');
    }
  }

  /// Integrate with AudioService for incorrect answer feedback
  Future<void> _playIncorrectAnswerFeedback() async {
    try {
      await _audioService.playIncorrectAnswerSound();
    } catch (e) {
      // Silently handle audio errors to prevent game disruption
      debugPrint('Audio error: $e');
    }
  }

  /// Integrate with AudioService for power-up usage
  Future<void> _playPowerUpFeedback(PowerUpType powerUpType) async {
    try {
      await _audioService.playPowerUpSpecificSound(powerUpType);
    } catch (e) {
      // Silently handle audio errors to prevent game disruption
      debugPrint('Audio error: $e');
    }
  }

  /// Integrate with ProgressService for correct answers
  Future<void> _recordCorrectAnswerProgress(int pointsEarned) async {
    try {
      await _progressService.recordCorrectAnswer(
        pointsEarned: pointsEarned,
        currentStreak: _gameState.consecutiveCorrect,
      );
    } catch (e) {
      // Silently handle progress errors to prevent game disruption
      debugPrint('Progress tracking error: $e');
    }
  }

  /// Integrate with ProgressService for incorrect answers
  Future<void> _recordIncorrectAnswerProgress() async {
    try {
      await _progressService.recordIncorrectAnswer();
    } catch (e) {
      // Silently handle progress errors to prevent game disruption
      debugPrint('Progress tracking error: $e');
    }
  }

  /// Record game completion with ProgressService
  Future<void> recordGameCompletion() async {
    try {
      await _progressService.recordGameCompletion(
        finalScore: _gameState.score,
        levelReached: _gameState.currentPhase.scoreMultiplier,
      );
    } catch (e) {
      // Silently handle progress errors to prevent game disruption
      debugPrint('Progress tracking error: $e');
    }
  }

  /// Initialize services for app integration
  Future<void> _initializeAppServices() async {
    try {
      // Audio and Progress services are already initialized as singletons
      // Just verify they're ready
      if (!_audioService.isMuted) {
        // Audio service is already initialized
      }
      // ProgressService is already initialized
    } catch (e) {
      debugPrint('App services initialization error: $e');
    }
  }

  // MARK: - Error Handling and Recovery Methods

  /// Reset error state
  void _resetErrorState() {
    _consecutiveFailures = 0;
    _isInRecoveryMode = false;
    _lastError = null;
    _failedImageUrls.clear();
  }

  /// Initialize services with retry mechanism
  Future<void> _initializeServicesWithRetry() async {
    // Simple retry without GenericRetry - will implement basic retry logic
    await _retryOperation(() async {
      await _breedService.initialize();
    }, 'BreedService initialization');

    await _retryOperation(() async {
      await _imageCacheService.initialize();
    }, 'ImageCacheService initialization');

    // Initialize performance optimization services
    await _retryOperation(() async {
      await _optimizedImageCache.initialize();
    }, 'OptimizedImageCacheService initialization');

    await _retryOperation(() async {
      await _memoryManager.initialize();
    }, 'BreedAdventureMemoryManager initialization');

    await _retryOperation(() async {
      await _performanceMonitor.initialize();
    }, 'BreedAdventurePerformanceMonitor initialization');

    // Initialize frame rate optimizer
    _frameRateOptimizer.initialize();
  }

  /// Simple retry mechanism for service initialization
  Future<void> _retryOperation(
    Future<void> Function() operation,
    String context,
  ) async {
    const maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        await operation();
        return; // Success
      } catch (e) {
        attempts++;
        await _errorService.recordError(
          ErrorType.gameLogic,
          '$context failed (attempt $attempts): $e',
          severity: attempts == maxAttempts
              ? ErrorSeverity.high
              : ErrorSeverity.medium,
          originalError: e,
        );

        if (attempts >= maxAttempts) {
          rethrow; // Final attempt failed
        }

        // Wait before retry
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      }
    }
  }

  /// Handle initialization errors with recovery strategies
  Future<void> _handleInitializationError(Object error) async {
    await _errorService.recordError(
      ErrorType.gameLogic,
      'BreedAdventureController initialization failed: $error',
      severity: ErrorSeverity.critical,
      originalError: error,
    );

    // Attempt to activate recovery mode
    _isInRecoveryMode = true;
    _lastError = AppError(
      type: ErrorType.gameLogic,
      message: 'Failed to initialize breed adventure: ${error.toString()}',
      severity: ErrorSeverity.critical,
      originalError: error,
    );
  }

  /// Handle image loading failures with fallback strategies
  Future<void> handleImageLoadError(String imageUrl, Object error) async {
    _failedImageUrls.add(imageUrl);

    // Limit the list size
    if (_failedImageUrls.length > maxFailedUrls) {
      _failedImageUrls.removeAt(0);
    }

    await _errorService.recordError(
      ErrorType.network,
      'Image load failed for $imageUrl: $error',
      severity: ErrorSeverity.medium,
      originalError: error,
    );

    _consecutiveFailures++;
    _lastError = AppError(
      type: ErrorType.network,
      severity: ErrorSeverity.medium,
      message: 'Image load failed for $imageUrl: $error',
    );

    if (_consecutiveFailures >= maxConsecutiveFailures) {
      await _activateRecoveryMode();
    }

    notifyListeners();
  }

  /// Handle network connectivity issues
  Future<void> handleNetworkError(Object error) async {
    await _errorService.handleNetworkError(error);

    // Update local error tracking
    _consecutiveFailures++;
    _lastError = AppError(
      type: ErrorType.network,
      severity: ErrorSeverity.medium,
      message: 'Exception: $error',
    );

    // Clear image cache to force retry
    _imageCacheService.clearCache();

    // Activate recovery mode for graceful degradation
    await _activateRecoveryMode();

    notifyListeners();
  }

  /// Handle invalid breed data with fallback
  Future<BreedChallenge?> handleBreedDataError(
    DifficultyPhase phase,
    Object error,
  ) async {
    await _errorService.recordError(
      ErrorType.gameLogic,
      'Breed data error for phase $phase: $error',
      severity: ErrorSeverity.high,
      originalError: error,
    );

    // Update local error tracking
    _consecutiveFailures++;
    _lastError = AppError(
      type: ErrorType.gameLogic,
      severity: ErrorSeverity.high,
      message: 'Breed data error for phase $phase: $error',
    );

    // Try to recover with fallback breed pool
    try {
      return await _generateFallbackChallenge(phase);
    } catch (fallbackError) {
      await _errorService.recordError(
        ErrorType.gameLogic,
        'Fallback challenge generation failed: $fallbackError',
        severity: ErrorSeverity.critical,
        originalError: fallbackError,
      );
      return null;
    } finally {
      notifyListeners();
    }
  }

  /// Activate recovery mode with graceful degradation
  Future<void> _activateRecoveryMode() async {
    if (_isInRecoveryMode) return;

    _isInRecoveryMode = true;

    await _errorService.recordError(
      ErrorType.gameLogic,
      'Activated recovery mode due to consecutive failures',
      severity: ErrorSeverity.high,
    );

    // Reset failed image URLs to allow retry
    _imageCacheService.resetFailedUrls();

    // Don't reset consecutive failures here - they should only be reset on successful recovery

    notifyListeners();
  }

  /// Generate fallback challenge for error recovery
  Future<BreedChallenge?> _generateFallbackChallenge(
    DifficultyPhase phase,
  ) async {
    // Try to get any available breeds for the phase using existing method
    try {
      final fallbackBreeds = _breedService.getBreedsByDifficultyPhase(phase);

      if (fallbackBreeds.isEmpty) {
        // Use hardcoded fallback breeds if all else fails
        return _createHardcodedFallbackChallenge();
      }

      // Generate challenge with available breeds using correct parameter order
      final usedBreeds = _gameState.usedBreeds.toSet();
      return await _breedService.generateChallenge(phase, usedBreeds);
    } catch (e) {
      // Final fallback - return hardcoded challenge
      return _createHardcodedFallbackChallenge();
    }
  }

  /// Create hardcoded fallback challenge as last resort
  BreedChallenge? _createHardcodedFallbackChallenge() {
    // Return a basic challenge with local asset images
    const fallbackBreeds = ['German Shepherd', 'Golden Retriever'];

    if (fallbackBreeds.length >= 2) {
      return BreedChallenge(
        correctBreedName: fallbackBreeds[0],
        correctImageUrl:
            'assets/images/schaeferhund.png', // Local asset fallback
        incorrectImageUrl: 'assets/images/cocker.png', // Local asset fallback
        correctImageIndex: 0, // Always put correct on left for simplicity
        phase: DifficultyPhase.beginner,
      );
    }

    return null;
  }

  /// Recovery strategies for different error types
  Future<void> recoverFromError(ErrorType errorType) async {
    switch (errorType) {
      case ErrorType.network:
        await _recoverFromNetworkError();
        break;
      case ErrorType.gameLogic:
        await _recoverFromGameLogicError();
        break;
      case ErrorType.storage:
        await _recoverFromStorageError();
        break;
      case ErrorType.audio:
        await _recoverFromAudioError();
        break;
      case ErrorType.ui:
        // UI errors are handled by error boundaries
        break;
      case ErrorType.unknown:
        await _recoverFromUnknownError();
        break;
    }

    // Clear error state after successful recovery
    clearErrors();
  }

  /// Recover from network-related errors
  Future<void> _recoverFromNetworkError() async {
    // Clear caches and retry
    _imageCacheService.clearCache();
    _imageCacheService.resetFailedUrls();

    // Reset network-related error state
    _consecutiveFailures = 0;
    _isInRecoveryMode = false;

    // Note: Cannot reload challenge images without BuildContext
    // Images will be loaded on demand when next challenge is generated

    notifyListeners();
  }

  /// Recover from game logic errors
  Future<void> _recoverFromGameLogicError() async {
    // Reset to a known good state
    if (_gameState.isGameActive) {
      // Try to continue with current state
      _isInRecoveryMode = false;
    } else {
      // Reset to initial state
      _gameState = BreedAdventureGameState.initial();
    }

    notifyListeners();
  }

  /// Recover from storage errors
  Future<void> _recoverFromStorageError() async {
    // Continue without storing progress
    _isInRecoveryMode = false;
    notifyListeners();
  }

  /// Recover from audio errors
  Future<void> _recoverFromAudioError() async {
    // Continue with silent mode
    _isInRecoveryMode = false;
    notifyListeners();
  }

  /// Recover from unknown errors
  Future<void> _recoverFromUnknownError() async {
    // General recovery - reset error state
    _resetErrorState();
    notifyListeners();
  }

  /// Validate game state integrity
  bool validateGameState() {
    try {
      // Check critical game state fields
      if (_gameState.score < 0) return false;
      if (_gameState.correctAnswers < 0) return false;
      if (_gameState.totalQuestions < 0) return false;
      if (_gameState.correctAnswers > _gameState.totalQuestions) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get current error state for UI display
  Map<String, dynamic> getErrorState() {
    return {
      'isInRecoveryMode': _isInRecoveryMode,
      'consecutiveFailures': _consecutiveFailures,
      'lastError': _lastError?.toString(),
      'failedImageCount': _failedImageUrls.length,
    };
  }

  /// User-friendly retry mechanism
  Future<bool> retryLastOperation() async {
    if (_lastError == null) return true;

    try {
      switch (_lastError!.type) {
        case ErrorType.network:
          await _recoverFromNetworkError();
          break;
        case ErrorType.gameLogic:
          await _recoverFromGameLogicError();
          break;
        default:
          _resetErrorState();
      }

      // Clear errors on successful retry
      clearErrors();
      return true;
    } catch (e) {
      await _errorService.recordError(
        ErrorType.unknown,
        'Retry operation failed: $e',
        severity: ErrorSeverity.medium,
        originalError: e,
      );
      return false;
    }
  }

  /// Cleanup memory resources and cached data with advanced optimization
  Future<void> cleanupMemory() async {
    try {
      debugPrint('Starting advanced memory cleanup...');

      // Use memory manager for intelligent cleanup
      await _memoryManager.cleanupMemory();

      // Optimize game state through memory manager
      _gameState = _memoryManager.optimizeGameState(_gameState);

      // Clear image cache statistics and perform memory cleanup
      _imageCacheService.clearStatistics();

      // Clear failed image URLs if accumulating
      if (_failedImageUrls.length > 10) {
        _failedImageUrls.clear();
      }

      // Reset power-up controller to free memory
      _powerUpController.resetForNewGame();

      // Get memory statistics for monitoring
      final memoryStats = _memoryManager.getMemoryStats();
      final performanceStats = _performanceMonitor.getPerformanceStats();

      debugPrint('Memory cleanup completed: $memoryStats');
      debugPrint('Performance after cleanup: $performanceStats');
    } catch (e) {
      debugPrint('Memory cleanup error: $e');
    }
  }

  @override
  void dispose() {
    _timer.stop();
    _timerSubscription?.cancel();

    // Dispose performance optimization services
    _memoryManager.dispose();
    _performanceMonitor.dispose();
    _frameRateOptimizer.dispose();
    _optimizedImageCache.dispose();

    super.dispose();
  }
}
