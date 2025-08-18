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

/// Manages the state and logic for the Dog Breeds Adventure game.
///
/// This controller is the central hub for the breed adventure feature. It is responsible for:
/// - Managing the game's state, including the score, lives, and current challenge.
/// - Handling user interactions, such as selecting an image or using a power-up.
/// - Coordinating with the various services to fetch data, manage timers, cache images, etc.
/// - Notifying the UI of state changes so that it can rebuild.
/// - Handling errors and recovering from them gracefully.
/// - Managing the game's lifecycle, from initialization to completion.
class BreedAdventureController extends ChangeNotifier {
  // Services
  /// Service for managing breed data and generating challenges.
  final BreedService _breedService;

  /// Timer for the 10-second challenge countdown.
  final BreedAdventureTimer _timer;

  /// Service for caching images.
  final ImageCacheService _imageCacheService;

  /// Advanced service for optimized image caching.
  final OptimizedImageCacheService _optimizedImageCache;

  /// Service for managing memory usage.
  final BreedAdventureMemoryManager _memoryManager;

  /// Service for monitoring game performance.
  final BreedAdventurePerformanceMonitor _performanceMonitor;

  /// Service for optimizing the frame rate.
  final FrameRateOptimizer _frameRateOptimizer;

  /// Controller for managing power-ups.
  final BreedAdventurePowerUpController _powerUpController;

  /// Service for playing audio feedback.
  final AudioService _audioService;

  /// Service for tracking player progress.
  final ProgressService _progressService;

  /// Service for recording and handling errors.
  final ErrorService _errorService;

  /// Service for persisting game data.
  final GamePersistenceService _persistenceService;

  /// Manager for saving and restoring the game state.
  final BreedAdventureStateManager _stateManager;

  // --- Game State ---
  /// The current state of the game.
  BreedAdventureGameState _gameState = BreedAdventureGameState.initial();

  /// The current challenge being displayed to the user.
  BreedChallenge? _currentChallenge;

  /// Subscription to the timer stream.
  StreamSubscription<int>? _timerSubscription;

  /// Whether the controller has been initialized.
  bool _isInitialized = false;

  /// The feedback state for the current answer (e.g., correct, incorrect).
  AnswerFeedback _feedbackState = AnswerFeedback.none;

  /// The index of the image that was selected by the user.
  int? _feedbackIndex;

  /// The player's high score for the breed adventure game.
  int _highScore = 0;

  // --- Error Handling State ---
  /// The number of consecutive failures (e.g., image load errors).
  int _consecutiveFailures = 0;

  /// Whether the game is currently in recovery mode.
  bool _isInRecoveryMode = false;

  /// The last error that occurred.
  AppError? _lastError;

  /// A list of URLs for images that have failed to load.
  final List<String> _failedImageUrls = [];

  // --- Configuration ---
  /// The base score for a correct answer.
  static const int baseScore = 100;

  /// The number of points awarded for each second remaining on the timer.
  static const int timeBonus = 10;

  /// The bonus points awarded for a streak of correct answers.
  static const int streakBonus = 50;

  /// The number of correct answers required to earn a power-up.
  static const int powerUpRewardThreshold = 5;

  /// The maximum number of lives a player has.
  static const int maxLives = 3;

  /// The maximum number of consecutive failures before entering recovery mode.
  static const int maxConsecutiveFailures = 3;

  /// The maximum number of failed image URLs to keep track of.
  static const int maxFailedUrls = 10;

  /// Creates a new instance of the [BreedAdventureController].
  ///
  /// The services can be injected for testing purposes. If they are not provided,
  /// the default singleton instances will be used.
  BreedAdventureController({
    BreedService? breedService,
    BreedAdventureTimer? timer,
    ImageCacheService? imageCacheService,
    BreedAdventurePowerUpController? powerUpController,
    AudioService? audioService,
    ProgressService? progressService,
    ErrorService? errorService,
    GamePersistenceService? persistenceService,
    BreedAdventureStateManager? stateManager,
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
       _persistenceService = persistenceService ?? GamePersistenceService(),
       _stateManager = stateManager ?? BreedAdventureStateManager.instance;

  /// The current state of the game.
  BreedAdventureGameState get gameState => _gameState;

  /// The current challenge being displayed to the user.
  BreedChallenge? get currentChallenge => _currentChallenge;

  /// The feedback state for the current answer (e.g., correct, incorrect).
  AnswerFeedback get feedbackState => _feedbackState;

  /// The index of the image that was selected by the user.
  int? get feedbackIndex => _feedbackIndex;

  /// The current score.
  int get currentScore => _gameState.score;

  /// The player's high score.
  int get highScore => _highScore;

  /// The number of correct answers so far.
  int get correctAnswers => _gameState.correctAnswers;

  /// The current difficulty phase of the game.
  DifficultyPhase get currentPhase => _gameState.currentPhase;

  /// The remaining time on the timer for the current challenge.
  int get timeRemaining => _gameState.timeRemaining;

  /// Whether the timer is currently running.
  bool get isTimerRunning => _timer.isRunning;

  /// The player's current inventory of power-ups.
  Map<PowerUpType, int> get powerUpInventory => _powerUpController.powerUps;

  /// Whether the game is currently active.
  bool get isGameActive => _gameState.isGameActive;

  /// Whether the controller has been initialized.
  bool get isInitialized => _isInitialized;

  /// The number of lives the player has remaining.
  int get livesRemaining => maxLives - _getIncorrectAnswers();

  /// The player's accuracy as a percentage.
  double get accuracy => _gameState.accuracy;

  /// The duration of the current game in seconds.
  int get gameDurationSeconds => _gameState.gameDurationSeconds;

  /// Whether there is currently an error.
  bool get hasError => _lastError != null;

  /// The last error that occurred.
  AppError? get currentError => _lastError;

  /// Whether the game is in recovery mode.
  bool get isInRecoveryMode => _isInRecoveryMode;

  /// The number of consecutive failures.
  int get consecutiveFailures => _consecutiveFailures;

  /// Whether there have been any image loading errors.
  bool get hasImageErrors => _failedImageUrls.isNotEmpty;

  /// Whether the game is performing well.
  bool get isPerformingWell => _performanceMonitor.isPerformingWell;

  /// The current frames per second (FPS).
  double get currentFPS => _performanceMonitor.getPerformanceStats().currentFPS;

  /// The average frames per second (FPS).
  double get averageFPS => _performanceMonitor.getPerformanceStats().averageFPS;

  /// Whether the memory should be optimized.
  bool get shouldOptimizeMemory => _memoryManager.shouldOptimizeMemory;

  /// The current memory usage in megabytes.
  int get currentMemoryUsageMB =>
      _memoryManager.getMemoryStats().currentUsageMB;

  /// Comprehensive performance statistics.
  dynamic get performanceStats => _performanceMonitor.getPerformanceStats();

  /// Memory usage statistics.
  dynamic get memoryStats => _memoryManager.getMemoryStats();

  /// Image cache performance statistics.
  dynamic get imageCacheStats => _optimizedImageCache.getPerformanceStats();

  /// The number of images that have failed to load.
  int get failedImageCount => _failedImageUrls.length;

  /// Clears all error state.
  void clearErrors() {
    _resetErrorState();
    notifyListeners();
  }

  /// Initializes the controller and all its services.
  ///
  /// This method should be called before starting a new game.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Reset any previous error state.
      _resetErrorState();

      // Initialize all services with a retry mechanism.
      await _initializeServicesWithRetry();

      // Initialize the state manager for reliable state preservation.
      await _stateManager.initialize();

      // Initialize the power-ups for the breed adventure game.
      _powerUpController.initializeForBreedAdventure();

      // Initialize app services for integration (e.g., audio, progress).
      await _initializeAppServices();

      // Load the high score from persistence.
      _highScore = await _persistenceService.getBreedAdventureHighScore();

      // Try to restore a previous game state if one is available.
      await _tryRestorePreviousState();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      await _handleInitializationError(e);
      throw Exception('Failed to initialize BreedAdventureController: $e');
    }
  }

  /// Starts a new game.
  ///
  /// This method resets the game state and generates the first challenge.
  Future<void> startGame() async {
    if (!_isInitialized) {
      throw StateError('Controller not initialized. Call initialize() first.');
    }

    // Clear any previously saved state since we're starting a new game.
    await _stateManager.clearSavedState();

    // Reset the game state to its initial values.
    _gameState = BreedAdventureGameState.initial().copyWith(
      isGameActive: true,
      gameStartTime: DateTime.now(),
      powerUps: Map.from(_powerUpController.powerUps),
    );

    // Mark the game as active in the state manager.
    _stateManager.setGameActive(true);

    // Save the initial state.
    await _stateManager.saveGameState(_gameState);

    // Set up the timer subscription to listen for timer updates.
    _timerSubscription?.cancel();
    _timerSubscription = _timer.timerStream.listen(_onTimerUpdate);

    // Generate the first challenge.
    await _generateNextChallenge();

    // Start preloading images in the background for better performance.
    _preloadInitialGameImages();

    notifyListeners();
  }

  /// Handles the user's selection of an image.
  ///
  /// [imageIndex] is the index of the image that was selected (0 or 1).
  Future<void> selectImage(int imageIndex) async {
    if (!_isGameActive || _currentChallenge == null) return;

    // Stop the timer as soon as the user makes a selection.
    _timer.stop();

    final isCorrect = _currentChallenge!.isCorrectSelection(imageIndex);
    final timeRemaining = _timer.remainingSeconds;

    // Set the feedback state to show immediate feedback to the user.
    _feedbackState = isCorrect
        ? AnswerFeedback.correct
        : AnswerFeedback.incorrect;
    _feedbackIndex = imageIndex;
    notifyListeners();

    // Handle the correct or incorrect answer.
    if (isCorrect) {
      await _handleCorrectAnswer(timeRemaining);
    } else {
      await _handleIncorrectAnswer();
    }

    // Add a short delay to allow the user to see the feedback.
    final feedbackDelay = isCorrect
        ? const Duration(
            milliseconds: 300,
          ) // Fast progression for correct answers.
        : const Duration(
            milliseconds: 300,
          ); // More time to see what went wrong.

    await Future.delayed(feedbackDelay);

    // Proceed to the next challenge or end the game if the player is out of lives.
    final incorrectAnswers = _getIncorrectAnswers();
    if (incorrectAnswers < maxLives) {
      await _generateNextChallenge();
    } else {
      await _endGame();
    }
  }

  /// Uses a power-up.
  ///
  /// Returns `true` if the power-up was used successfully, `false` otherwise.
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
        // These power-ups are not supported in the breed adventure mode.
        success = false;
        break;
    }

    if (success) {
      // The power-up consumption is handled by the individual `apply` methods.
      _updatePowerUpsInGameState();
      // Play a sound to give feedback to the user.
      await _playPowerUpFeedback(powerUpType);
      notifyListeners();
    }

    return success;
  }

  /// Pauses the game by pausing the timer.
  void pauseGame() {
    if (_isGameActive) {
      _timer.pause();

      // Save the current state when the game is paused.
      _stateManager.saveGameState(_gameState);

      notifyListeners();
    }
  }

  /// Resumes the game by resuming the timer.
  void resumeGame() {
    if (_isGameActive) {
      _timer.resume();
      notifyListeners();
    }
  }

  /// Ends the current game.
  Future<void> endGame() async {
    await _endGame();
    notifyListeners();
  }

  /// Resets the controller to its initial state.
  void reset() {
    _timer.stop();
    _timerSubscription?.cancel();
    _timerSubscription = null;
    _currentChallenge = null;
    _gameState = BreedAdventureGameState.initial();
    _powerUpController.resetForNewGame();
    notifyListeners();
  }

  /// Handles a correct answer.
  ///
  /// This method calculates the score, updates the game state, and checks for phase progression.
  Future<void> _handleCorrectAnswer(int timeRemaining) async {
    // Calculate the score for the correct answer.
    final phaseMultiplier = _gameState.currentPhase.scoreMultiplier;
    final timeBonusPoints = timeRemaining * timeBonus;
    final streakBonusPoints = _gameState.consecutiveCorrect >= 2
        ? streakBonus
        : 0;
    final totalPoints =
        (baseScore * phaseMultiplier) + timeBonusPoints + streakBonusPoints;

    final newState = _gameState.copyWith(
      score: _gameState.score + totalPoints,
      correctAnswers: _gameState.correctAnswers + 1,
      totalQuestions: _gameState.totalQuestions + 1,
      consecutiveCorrect: _gameState.consecutiveCorrect + 1,
      usedBreeds: Set.from(_gameState.usedBreeds)
        ..add(_currentChallenge!.correctBreedName),
    );

    // Update the game state with persistence and validation.
    await _updateGameStateWithPersistence(newState);

    // Track the correct answer for power-up rewards.
    _powerUpController.trackCorrectAnswer();

    // Integrate with other app systems (audio, progress tracking).
    await _playCorrectAnswerFeedback();
    await _recordCorrectAnswerProgress(totalPoints);

    // Check if the player has completed the current phase.
    await _checkPhaseProgression();
  }

  /// Handles an incorrect answer.
  ///
  /// This method updates the game state and records the incorrect answer.
  Future<void> _handleIncorrectAnswer() async {
    // Update the game state for an incorrect answer.
    final newState = _gameState.copyWith(
      totalQuestions: _gameState.totalQuestions + 1,
      consecutiveCorrect: 0,
      usedBreeds: Set.from(_gameState.usedBreeds)
        ..add(_currentChallenge!.correctBreedName),
    );

    // Update the game state with persistence and validation.
    await _updateGameStateWithPersistence(newState);

    // Integrate with other app systems (audio, progress tracking).
    await _playIncorrectAnswerFeedback();
    await _recordIncorrectAnswerProgress();
  }

  /// Generates the next challenge.
  ///
  /// This method checks for phase progression, generates a new challenge using the `BreedService`,
  /// preloads the images for the challenge, and starts the timer.
  Future<void> _generateNextChallenge() async {
    // Reset the feedback state for the new round.
    _feedbackState = AnswerFeedback.none;
    _feedbackIndex = null;

    try {
      // Check if we need to progress to the next phase.
      if (!_breedService.hasAvailableBreeds(
        _gameState.currentPhase,
        _gameState.usedBreeds,
      )) {
        final nextPhase = _gameState.currentPhase.nextPhase;
        if (nextPhase != null) {
          // Progress to the next phase.
          _gameState = _gameState.copyWith(
            currentPhase: nextPhase,
            usedBreeds: <String>{}, // Reset the used breeds for the new phase.
          );
        } else {
          // No more phases, so end the game.
          await _endGame();
          return;
        }
      }

      // Generate a new challenge.
      _currentChallenge = await _breedService.generateChallenge(
        _gameState.currentPhase,
        _gameState.usedBreeds,
      );

      // Preload the images for the challenge to ensure a smooth user experience.
      await _preloadChallengeImages();

      // Start the timer for the new challenge.
      _timer.start();

      // Notify the UI of the new challenge and timer state.
      notifyListeners();
    } catch (e) {
      debugPrint('Error generating challenge: $e');
      await _endGame();
    }
  }

  /// Preloads the images for the current challenge with performance optimization.
  Future<void> _preloadChallengeImages() async {
    if (_currentChallenge == null) return;

    try {
      // Track the image loading performance.
      final stopwatch = Stopwatch()..start();

      _performanceMonitor.trackImageLoadStart(
        _currentChallenge!.correctImageUrl,
      );
      _performanceMonitor.trackImageLoadStart(
        _currentChallenge!.incorrectImageUrl,
      );

      // Use the optimized image cache for immediate loading of the current challenge's images.
      await _optimizedImageCache.preloadCriticalImages([
        _currentChallenge!.correctImageUrl,
        _currentChallenge!.incorrectImageUrl,
      ]);

      // Preload additional images from the current phase in the background for better performance.
      _preloadBackgroundImages();

      stopwatch.stop();

      // Track the completion times.
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
      // Continue anyway - the images will load on demand.
    }
  }

  /// Preloads background images from the current phase to improve future performance.
  void _preloadBackgroundImages() {
    // Don't block the UI - run this in the background.
    Future.microtask(() async {
      try {
        final availableBreeds = _breedService.getAvailableBreeds(
          _gameState.currentPhase,
          _gameState.usedBreeds,
        );

        // Get the image URLs from the next few potential breeds (up to 10).
        final imageUrlsToPreload = availableBreeds
            .take(10)
            .map((breed) => breed.imageUrl)
            .where((url) => url.isNotEmpty)
            .toList();

        if (imageUrlsToPreload.isNotEmpty) {
          // Use delayed preloading for the background images.
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

  /// Preloads initial game images when starting the game.
  void _preloadInitialGameImages() {
    // Don't block the UI - run this in the background.
    Future.microtask(() async {
      try {
        // Get a sample of breeds from the current phase for preloading.
        final availableBreeds = _breedService.getAvailableBreeds(
          _gameState.currentPhase,
          <String>{}, // Empty set to get all available breeds.
        );

        // Preload images from the first 15 breeds to have them ready.
        final initialImageUrls = availableBreeds
            .take(15)
            .map((breed) => breed.imageUrl)
            .where((url) => url.isNotEmpty)
            .toList();

        if (initialImageUrls.isNotEmpty) {
          // Use delayed preloading so it doesn't interfere with the current challenge.
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

  /// Checks if phase progression is needed.
  Future<void> _checkPhaseProgression() async {
    if (!_breedService.hasAvailableBreeds(
      _gameState.currentPhase,
      _gameState.usedBreeds,
    )) {
      final nextPhase = _gameState.currentPhase.nextPhase;
      if (nextPhase != null) {
        final newState = _gameState.copyWith(
          currentPhase: nextPhase,
          usedBreeds: <String>{}, // Reset used breeds for the new phase.
        );

        // Update the state with persistence and validation.
        await _updateGameStateWithPersistence(newState);
      }
    }
  }

  /// Gets the celebration message for a power-up.
  String getPowerUpCelebrationMessage(PowerUpType powerUpType) {
    return _powerUpController.getPowerUpCelebrationMessage(powerUpType);
  }

  /// Gets the description for a power-up.
  String getPowerUpDescription(PowerUpType powerUpType) {
    return _powerUpController.getPowerUpDescription(powerUpType);
  }

  /// Whether the player is close to earning a power-up reward.
  bool get isCloseToReward => _powerUpController.isCloseToReward();

  /// Whether a power-up can be used.
  bool canUsePowerUp(PowerUpType powerUpType) {
    return _isGameActive && _powerUpController.canUsePowerUp(powerUpType);
  }

  /// Uses the "Extra Time" power-up.
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

  /// Uses the "Skip" power-up.
  Future<bool> _useSkipPowerUp() async {
    if (_currentChallenge != null && _powerUpController.applyBreedSkip()) {
      // Mark the breed as used without penalty.
      final newState = _gameState.copyWith(
        totalQuestions: _gameState.totalQuestions + 1,
        usedBreeds: Set.from(_gameState.usedBreeds)
          ..add(_currentChallenge!.correctBreedName),
      );

      // Update the state with persistence and validation.
      await _updateGameStateWithPersistence(newState);

      // Generate the next challenge.
      await Future.delayed(const Duration(milliseconds: 500));
      await _generateNextChallenge();
      return true;
    }
    return false;
  }

  /// Gets the number of incorrect answers.
  int _getIncorrectAnswers() {
    return _gameState.totalQuestions - _gameState.correctAnswers;
  }

  /// Ends the game.
  Future<void> _endGame() async {
    _timer.stop();
    _timerSubscription?.cancel();
    _timerSubscription = null;

    // Calculate the game duration.
    final gameDuration = _gameState.gameStartTime != null
        ? DateTime.now().difference(_gameState.gameStartTime!).inSeconds
        : 0;

    // Calculate the number of power-ups used during the game.
    final initialPowerUps = {PowerUpType.extraTime: 2, PowerUpType.skip: 1};
    final currentPowerUps = _powerUpController.powerUps;
    final powerUpsUsed = initialPowerUps.entries
        .map(
          (entry) =>
              (initialPowerUps[entry.key] ?? 0) -
              (currentPowerUps[entry.key] ?? 0),
        )
        .fold(0, (sum, used) => sum + used);

    // Update the high score if the current score is higher.
    if (_gameState.score > _highScore) {
      _highScore = _gameState.score;
      await _persistenceService.saveBreedAdventureHighScore(_highScore);
    }

    // Mark the game as inactive.
    final finalState = _gameState.copyWith(isGameActive: false);
    _gameState = finalState;

    // Mark the game as inactive in the state manager and update the statistics.
    _stateManager.setGameActive(false);
    await _stateManager.updateGameStatistics(
      finalState: finalState,
      gameDuration: gameDuration,
      powerUpsUsed: powerUpsUsed,
    );

    // Clear the saved state since the game is complete.
    await _stateManager.clearSavedState();

    notifyListeners();
  }

  /// Handles timer updates from the `BreedAdventureTimer`.
  void _onTimerUpdate(int remainingSeconds) {
    _gameState = _gameState.copyWith(timeRemaining: remainingSeconds);
    notifyListeners();
  }

  /// Handles timer expiration.
  Future<void> handleTimeExpired() async {
    if (!_isGameActive || _currentChallenge == null) return;

    // Treat timer expiration as an incorrect answer.
    await _handleIncorrectAnswer();

    // No second chance - just continue the normal flow.
    final incorrectAnswers = _getIncorrectAnswers();
    if (incorrectAnswers < maxLives) {
      // Use the same delay as for incorrect answers for consistency.
      await Future.delayed(const Duration(milliseconds: 600));
      await _generateNextChallenge();
    } else {
      await _endGame();
    }

    notifyListeners();
  }

  /// Updates the power-ups in the game state.
  void _updatePowerUpsInGameState() {
    final newState = _gameState.copyWith(
      powerUps: Map.from(_powerUpController.powerUps),
    );

    // Use an async update for persistence.
    _updateGameStateWithPersistence(newState);
  }

  /// Whether the game is currently active.
  bool get _isGameActive => _gameState.isGameActive;

  /// Gets the game statistics.
  GameStatistics getGameStatistics() {
    return GameStatistics.fromBreedAdventure(
      _gameState,
      _highScore,
      livesRemaining,
      _getTotalPowerUpsUsed(),
    );
  }

  /// Gets the total number of power-ups used.
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

  /// Integrates with the [AudioService] to play feedback for a correct answer.
  Future<void> _playCorrectAnswerFeedback() async {
    try {
      // Play a special sound for a streak of correct answers.
      if (_gameState.consecutiveCorrect >= 3) {
        await _audioService.playStreakBonusSound();
      } else {
        await _audioService.playCorrectAnswerSound();
      }
    } catch (e) {
      // Silently handle audio errors to prevent disrupting the game.
      debugPrint('Audio error: $e');
    }
  }

  /// Integrates with the [AudioService] to play feedback for an incorrect answer.
  Future<void> _playIncorrectAnswerFeedback() async {
    try {
      await _audioService.playIncorrectAnswerSound();
    } catch (e) {
      // Silently handle audio errors to prevent disrupting the game.
      debugPrint('Audio error: $e');
    }
  }

  /// Integrates with the [AudioService] to play feedback for using a power-up.
  Future<void> _playPowerUpFeedback(PowerUpType powerUpType) async {
    try {
      await _audioService.playPowerUpSpecificSound(powerUpType);
    } catch (e) {
      // Silently handle audio errors to prevent disrupting the game.
      debugPrint('Audio error: $e');
    }
  }

  /// Integrates with the [ProgressService] to record a correct answer.
  Future<void> _recordCorrectAnswerProgress(int pointsEarned) async {
    try {
      await _progressService.recordCorrectAnswer(
        pointsEarned: pointsEarned,
        currentStreak: _gameState.consecutiveCorrect,
      );
    } catch (e) {
      // Silently handle progress errors to prevent disrupting the game.
      debugPrint('Progress tracking error: $e');
    }
  }

  /// Integrates with the [ProgressService] to record an incorrect answer.
  Future<void> _recordIncorrectAnswerProgress() async {
    try {
      await _progressService.recordIncorrectAnswer();
    } catch (e) {
      // Silently handle progress errors to prevent disrupting the game.
      debugPrint('Progress tracking error: $e');
    }
  }

  /// Records the completion of a game with the [ProgressService].
  Future<void> recordGameCompletion() async {
    try {
      await _progressService.recordGameCompletion(
        finalScore: _gameState.score,
        levelReached: _gameState.currentPhase.scoreMultiplier,
      );
    } catch (e) {
      // Silently handle progress errors to prevent disrupting the game.
      debugPrint('Progress tracking error: $e');
    }
  }

  /// Initializes the services for app integration.
  Future<void> _initializeAppServices() async {
    try {
      // Audio and Progress services are already initialized as singletons.
      // Just verify they're ready.
      if (!_audioService.isMuted) {
        // Audio service is already initialized.
      }
      // ProgressService is already initialized.
    } catch (e) {
      debugPrint('App services initialization error: $e');
    }
  }

  // MARK: - Error Handling and Recovery Methods

  /// Resets the error state.
  void _resetErrorState() {
    _consecutiveFailures = 0;
    _isInRecoveryMode = false;
    _lastError = null;
    _failedImageUrls.clear();
  }

  /// Initializes the services with a retry mechanism.
  Future<void> _initializeServicesWithRetry() async {
    // Simple retry without GenericRetry - will implement basic retry logic.
    await _retryOperation(() async {
      await _breedService.initialize();
    }, 'BreedService initialization');

    await _retryOperation(() async {
      await _imageCacheService.initialize();
    }, 'ImageCacheService initialization');

    // Initialize performance optimization services.
    await _retryOperation(() async {
      await _optimizedImageCache.initialize();
    }, 'OptimizedImageCacheService initialization');

    await _retryOperation(() async {
      await _memoryManager.initialize();
    }, 'BreedAdventureMemoryManager initialization');

    await _retryOperation(() async {
      await _performanceMonitor.initialize();
    }, 'BreedAdventurePerformanceMonitor initialization');

    // Initialize the frame rate optimizer.
    _frameRateOptimizer.initialize();
  }

  /// A simple retry mechanism for service initialization.
  Future<void> _retryOperation(
    Future<void> Function() operation,
    String context,
  ) async {
    const maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        await operation();
        return; // Success.
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
          rethrow; // Final attempt failed.
        }

        // Wait before retrying.
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      }
    }
  }

  /// Handles initialization errors with recovery strategies.
  Future<void> _handleInitializationError(Object error) async {
    await _errorService.recordError(
      ErrorType.gameLogic,
      'BreedAdventureController initialization failed: $error',
      severity: ErrorSeverity.critical,
      originalError: error,
    );

    // Attempt to activate recovery mode.
    _isInRecoveryMode = true;
    _lastError = AppError(
      type: ErrorType.gameLogic,
      message: 'Failed to initialize breed adventure: ${error.toString()}',
      severity: ErrorSeverity.critical,
      originalError: error,
    );
  }

  /// Handles image loading failures with fallback strategies.
  Future<void> handleImageLoadError(String imageUrl, Object error) async {
    _failedImageUrls.add(imageUrl);

    // Limit the size of the list.
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

  /// Handles network connectivity issues.
  Future<void> handleNetworkError(Object error) async {
    await _errorService.handleNetworkError(error);

    // Update the local error tracking.
    _consecutiveFailures++;
    _lastError = AppError(
      type: ErrorType.network,
      severity: ErrorSeverity.medium,
      message: 'Exception: $error',
    );

    // Clear the image cache to force a retry.
    _imageCacheService.clearCache();

    // Activate recovery mode for graceful degradation.
    await _activateRecoveryMode();

    notifyListeners();
  }

  /// Handles invalid breed data with a fallback.
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

    // Update the local error tracking.
    _consecutiveFailures++;
    _lastError = AppError(
      type: ErrorType.gameLogic,
      severity: ErrorSeverity.high,
      message: 'Breed data error for phase $phase: $error',
    );

    // Try to recover with a fallback breed pool.
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

  /// Activates recovery mode with graceful degradation.
  Future<void> _activateRecoveryMode() async {
    if (_isInRecoveryMode) return;

    _isInRecoveryMode = true;

    await _errorService.recordError(
      ErrorType.gameLogic,
      'Activated recovery mode due to consecutive failures',
      severity: ErrorSeverity.high,
    );

    // Reset the failed image URLs to allow a retry.
    _imageCacheService.resetFailedUrls();

    // Don't reset consecutive failures here - they should only be reset on successful recovery.

    notifyListeners();
  }

  /// Generates a fallback challenge for error recovery.
  Future<BreedChallenge?> _generateFallbackChallenge(
    DifficultyPhase phase,
  ) async {
    // Try to get any available breeds for the phase using the existing method.
    try {
      final fallbackBreeds = _breedService.getBreedsByDifficultyPhase(phase);

      if (fallbackBreeds.isEmpty) {
        // Use hardcoded fallback breeds if all else fails.
        return _createHardcodedFallbackChallenge();
      }

      // Generate a challenge with the available breeds using the correct parameter order.
      final usedBreeds = _gameState.usedBreeds.toSet();
      return await _breedService.generateChallenge(phase, usedBreeds);
    } catch (e) {
      // Final fallback - return a hardcoded challenge.
      return _createHardcodedFallbackChallenge();
    }
  }

  /// Creates a hardcoded fallback challenge as a last resort.
  BreedChallenge? _createHardcodedFallbackChallenge() {
    // Return a basic challenge with local asset images.
    const fallbackBreeds = ['German Shepherd', 'Golden Retriever'];

    if (fallbackBreeds.length >= 2) {
      return BreedChallenge(
        correctBreedName: fallbackBreeds[0],
        correctImageUrl:
            'assets/images/schaeferhund.png', // Local asset fallback.
        incorrectImageUrl: 'assets/images/cocker.png', // Local asset fallback.
        correctImageIndex:
            0, // Always put the correct image on the left for simplicity.
        phase: DifficultyPhase.beginner,
      );
    }

    return null;
  }

  /// Provides recovery strategies for different error types.
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
        // UI errors are handled by error boundaries.
        break;
      case ErrorType.unknown:
        await _recoverFromUnknownError();
        break;
    }

    // Clear the error state after a successful recovery.
    clearErrors();
  }

  /// Recovers from network-related errors.
  Future<void> _recoverFromNetworkError() async {
    // Clear the caches and retry.
    _imageCacheService.clearCache();
    _imageCacheService.resetFailedUrls();

    // Reset the network-related error state.
    _consecutiveFailures = 0;
    _isInRecoveryMode = false;

    // Note: Cannot reload challenge images without a BuildContext.
    // Images will be loaded on demand when the next challenge is generated.

    notifyListeners();
  }

  /// Recovers from game logic errors.
  Future<void> _recoverFromGameLogicError() async {
    // Reset to a known good state.
    if (_gameState.isGameActive) {
      // Try to continue with the current state.
      _isInRecoveryMode = false;
    } else {
      // Reset to the initial state.
      _gameState = BreedAdventureGameState.initial();
    }

    notifyListeners();
  }

  /// Recovers from storage errors.
  Future<void> _recoverFromStorageError() async {
    // Continue without storing progress.
    _isInRecoveryMode = false;
    notifyListeners();
  }

  /// Recovers from audio errors.
  Future<void> _recoverFromAudioError() async {
    // Continue with silent mode.
    _isInRecoveryMode = false;
    notifyListeners();
  }

  /// Recovers from unknown errors.
  Future<void> _recoverFromUnknownError() async {
    // General recovery - reset the error state.
    _resetErrorState();
    notifyListeners();
  }

  /// Validates the integrity of the game state.
  bool validateGameState() {
    try {
      // Check critical game state fields.
      if (_gameState.score < 0) return false;
      if (_gameState.correctAnswers < 0) return false;
      if (_gameState.totalQuestions < 0) return false;
      if (_gameState.correctAnswers > _gameState.totalQuestions) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets the current error state for UI display.
  Map<String, dynamic> getErrorState() {
    return {
      'isInRecoveryMode': _isInRecoveryMode,
      'consecutiveFailures': _consecutiveFailures,
      'lastError': _lastError?.toString(),
      'failedImageCount': _failedImageUrls.length,
    };
  }

  /// A user-friendly retry mechanism.
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

      // Clear errors on a successful retry.
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

  /// Cleans up memory resources and cached data with advanced optimization.
  Future<void> cleanupMemory() async {
    try {
      debugPrint('Starting advanced memory cleanup...');

      // Use the memory manager for intelligent cleanup.
      await _memoryManager.cleanupMemory();

      // Optimize the game state through the memory manager.
      _gameState = _memoryManager.optimizeGameState(_gameState);

      // Clear the image cache statistics and perform memory cleanup.
      _imageCacheService.clearStatistics();

      // Clear the failed image URLs if they are accumulating.
      if (_failedImageUrls.length > 10) {
        _failedImageUrls.clear();
      }

      // Reset the power-up controller to free up memory.
      _powerUpController.resetForNewGame();

      // Get memory statistics for monitoring.
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

    // Mark the game as inactive and save the final state.
    _stateManager.setGameActive(false);

    // Dispose of the performance optimization services.
    _memoryManager.dispose();
    _performanceMonitor.dispose();
    _frameRateOptimizer.dispose();
    _optimizedImageCache.dispose();

    // Dispose of the state manager.
    _stateManager.dispose();

    super.dispose();
  }

  /// Tries to restore a previous game state if one is available.
  Future<void> _tryRestorePreviousState() async {
    try {
      final savedState = await _stateManager.loadGameState();

      if (savedState != null && savedState.isGameActive) {
        // Validate the saved state.
        if (_stateManager.validateCurrentState(savedState)) {
          // Restore the state.
          _gameState = savedState;

          // Restore the power-ups in the controller.
          _powerUpController.setPowerUps(savedState.powerUps);

          debugPrint(
            'Restored previous game state: score=${savedState.score}, phase=${savedState.currentPhase}',
          );
        } else {
          // The state is corrupted, so try to recover.
          await _attemptStateRecovery();
        }
      }
    } catch (e) {
      await _errorService.recordError(
        ErrorType.gameLogic,
        'Failed to restore previous state: $e',
        severity: ErrorSeverity.medium,
        originalError: e,
      );
    }
  }

  /// Attempts to recover from a corrupted state.
  Future<void> _attemptStateRecovery() async {
    try {
      final recoveryState = _stateManager.getRecoveryState();

      if (recoveryState != null) {
        _gameState = recoveryState.copyWith(
          isGameActive: false,
        ); // Deactivate to be safe.
        _powerUpController.setPowerUps(recoveryState.powerUps);

        await _errorService.recordError(
          ErrorType.gameLogic,
          'Successfully recovered from corrupted state using backup',
          severity: ErrorSeverity.low,
        );

        debugPrint('Recovered game state from backup');
      } else {
        // Complete reset to a safe state.
        _gameState = BreedAdventureGameState.initial();
        _powerUpController.resetForNewGame();

        await _errorService.recordError(
          ErrorType.gameLogic,
          'Reset to initial state due to unrecoverable corruption',
          severity: ErrorSeverity.medium,
        );

        debugPrint('Reset to initial state due to corruption');
      }
    } catch (e) {
      await _errorService.recordError(
        ErrorType.gameLogic,
        'State recovery failed completely: $e',
        severity: ErrorSeverity.high,
        originalError: e,
      );
    }
  }

  /// Updates the game state with automatic persistence and validation.
  Future<void> _updateGameStateWithPersistence(
    BreedAdventureGameState newState,
  ) async {
    try {
      // Validate the new state before applying it.
      if (!_stateManager.validateCurrentState(newState)) {
        await _errorService.recordError(
          ErrorType.gameLogic,
          'Attempted to update to invalid game state, using recovery',
          severity: ErrorSeverity.medium,
        );

        await _attemptStateRecovery();
        return;
      }

      // Apply the new state.
      _gameState = newState;

      // Save to the state manager for persistence.
      await _stateManager.saveGameState(_gameState);

      // Optimize memory if needed.
      _gameState = _memoryManager.optimizeGameState(_gameState);
    } catch (e) {
      await _errorService.recordError(
        ErrorType.gameLogic,
        'Failed to update game state with persistence: $e',
        severity: ErrorSeverity.high,
        originalError: e,
      );

      // Try recovery as a fallback.
      await _attemptStateRecovery();
    }
  }
}
