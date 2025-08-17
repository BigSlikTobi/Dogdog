import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../../models/breed_adventure/breed_adventure_game_state.dart';
import '../../models/breed_adventure/difficulty_phase.dart';
import '../../models/enums.dart';
import '../../services/game_persistence_service.dart';
import '../../services/error_service.dart';

/// Manages reliable state preservation and recovery for breed adventure
class BreedAdventureStateManager with WidgetsBindingObserver {
  static final BreedAdventureStateManager _instance =
      BreedAdventureStateManager._internal();
  static BreedAdventureStateManager get instance => _instance;

  BreedAdventureStateManager._internal();

  final GamePersistenceService _persistence = GamePersistenceService();
  final ErrorService _errorService = ErrorService();

  bool _isInitialized = false;
  bool _isGameActive = false;
  bool _isBackgrounded = false;
  BreedAdventureGameState? _lastValidState;
  Timer? _stateValidationTimer;
  Timer? _autoSaveTimer;

  // State validation settings
  static const Duration _validationInterval = Duration(seconds: 30);
  static const Duration _autoSaveInterval = Duration(seconds: 10);
  static const int _maxStateHistorySize = 10;

  final List<BreedAdventureGameState> _stateHistory = [];

  /// Initialize the state manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _persistence.initialize();

    // Only add observer if widgets binding is available (not in tests)
    try {
      WidgetsBinding.instance.addObserver(this);
    } catch (e) {
      // Widgets binding not available (probably in test environment)
      // Continue without lifecycle observation
    }

    _startPeriodicValidation();
    _startAutoSave();

    _isInitialized = true;
  }

  /// Dispose resources
  void dispose() {
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (e) {
      // Widgets binding not available (probably in test environment)
      // Continue without removing observer
    }

    _stateValidationTimer?.cancel();
    _autoSaveTimer?.cancel();
    _stateHistory.clear();
    _lastValidState = null;
    _isGameActive = false;
    _isInitialized = false;
  }

  /// Handle app lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _handleAppBackgrounded();
        break;
      case AppLifecycleState.resumed:
        _handleAppForegrounded();
        break;
      case AppLifecycleState.inactive:
        // App temporarily losing focus (e.g., incoming call)
        if (_isGameActive) {
          _saveCurrentStateImmediate();
        }
        break;
      case AppLifecycleState.hidden:
        // App is hidden but still running
        _handleAppBackgrounded();
        break;
    }
  }

  /// Save current game state for preservation
  Future<void> saveGameState(BreedAdventureGameState state) async {
    if (!_isInitialized) return;

    try {
      // Validate state before saving
      if (!state.isValid()) {
        await _errorService.recordError(
          ErrorType.gameLogic,
          'Attempted to save invalid game state: ${state.toString()}',
          severity: ErrorSeverity.medium,
        );
        return;
      }

      // Add to state history
      _addToStateHistory(state);
      _lastValidState = state;

      // Save to persistence
      await _persistence.saveBreedAdventureState(state);

      // Also save power-ups separately for redundancy
      await _persistence.saveBreedAdventurePowerUps(state.powerUps);
    } catch (e) {
      await _errorService.recordError(
        ErrorType.gameLogic,
        'Failed to save breed adventure state: $e',
        severity: ErrorSeverity.high,
        originalError: e,
      );
    }
  }

  /// Load saved game state with validation and recovery
  Future<BreedAdventureGameState?> loadGameState() async {
    if (!_isInitialized) return null;

    try {
      final state = await _persistence.loadBreedAdventureState();

      if (state == null) return null;

      // Additional validation
      if (!_validateStateIntegrity(state)) {
        await _errorService.recordError(
          ErrorType.gameLogic,
          'Loaded state failed integrity check, attempting recovery',
          severity: ErrorSeverity.medium,
        );

        // Try to recover with backup power-ups
        return await _attemptStateRecovery(state);
      }

      _lastValidState = state;
      return state;
    } catch (e) {
      await _errorService.recordError(
        ErrorType.gameLogic,
        'Failed to load breed adventure state: $e',
        severity: ErrorSeverity.high,
        originalError: e,
      );
      return null;
    }
  }

  /// Clear saved state (for new game)
  Future<void> clearSavedState() async {
    if (!_isInitialized) return;

    try {
      await _persistence.clearBreedAdventureState();
      _lastValidState = null;
      _stateHistory.clear();
      _isGameActive = false;
    } catch (e) {
      await _errorService.recordError(
        ErrorType.gameLogic,
        'Failed to clear breed adventure state: $e',
        severity: ErrorSeverity.medium,
        originalError: e,
      );
    }
  }

  /// Mark game as active/inactive
  void setGameActive(bool active) {
    _isGameActive = active;

    if (!active) {
      // Game ended, save final state immediately
      _saveCurrentStateImmediate();
    }
  }

  /// Validate current state integrity
  bool validateCurrentState(BreedAdventureGameState state) {
    return _validateStateIntegrity(state);
  }

  /// Get recovery state if current state is corrupted
  BreedAdventureGameState? getRecoveryState() {
    // Return the most recent valid state from history
    for (int i = _stateHistory.length - 1; i >= 0; i--) {
      final state = _stateHistory[i];
      if (_validateStateIntegrity(state)) {
        return state;
      }
    }
    return null;
  }

  /// Update statistics after game completion
  Future<void> updateGameStatistics({
    required BreedAdventureGameState finalState,
    required int gameDuration,
    required int powerUpsUsed,
  }) async {
    if (!_isInitialized) return;

    try {
      await _persistence.updateBreedAdventureStatistics(
        finalState: finalState,
        gameDuration: gameDuration,
        powerUpsUsed: powerUpsUsed,
      );
    } catch (e) {
      await _errorService.recordError(
        ErrorType.gameLogic,
        'Failed to update breed adventure statistics: $e',
        severity: ErrorSeverity.medium,
        originalError: e,
      );
    }
  }

  /// Handle app going to background
  void _handleAppBackgrounded() {
    _isBackgrounded = true;

    if (_isGameActive && _lastValidState != null) {
      // Save state immediately when backgrounding
      _saveCurrentStateImmediate();

      // Also send haptic feedback to indicate pause
      HapticFeedback.lightImpact();
    }
  }

  /// Handle app returning from background
  void _handleAppForegrounded() {
    final wasBackgrounded = _isBackgrounded;
    _isBackgrounded = false;

    if (wasBackgrounded && _isGameActive) {
      // App was backgrounded during active game
      // The game controller should handle pausing/resuming
      // This just ensures state integrity
      _validateCurrentStateAfterBackground();
    }
  }

  /// Save current state immediately (for critical moments)
  void _saveCurrentStateImmediate() {
    if (_lastValidState != null) {
      // Use a separate isolate or compute to avoid blocking
      saveGameState(_lastValidState!);
    }
  }

  /// Validate state integrity after backgrounding
  void _validateCurrentStateAfterBackground() {
    if (_lastValidState != null && !_validateStateIntegrity(_lastValidState!)) {
      _errorService.recordError(
        ErrorType.gameLogic,
        'State corruption detected after app background/foreground cycle',
        severity: ErrorSeverity.high,
      );
    }
  }

  /// Start periodic state validation
  void _startPeriodicValidation() {
    _stateValidationTimer = Timer.periodic(_validationInterval, (timer) {
      if (_isGameActive && _lastValidState != null) {
        if (!_validateStateIntegrity(_lastValidState!)) {
          _errorService.recordError(
            ErrorType.gameLogic,
            'Periodic validation found corrupted state',
            severity: ErrorSeverity.high,
          );
        }
      }
    });
  }

  /// Start auto-save timer
  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(_autoSaveInterval, (timer) {
      if (_isGameActive && _lastValidState != null) {
        saveGameState(_lastValidState!);
      }
    });
  }

  /// Validate state integrity
  bool _validateStateIntegrity(BreedAdventureGameState state) {
    // Use the built-in validation
    if (!state.isValid()) return false;

    // Additional business logic validation

    // Check if phase progression makes sense
    final totalQuestions = state.totalQuestions;
    if (totalQuestions > 0) {
      // Beginner phase should have some questions before intermediate
      if (state.currentPhase == DifficultyPhase.intermediate &&
          totalQuestions < 5) {
        return false;
      }
      // Expert phase should have many questions
      if (state.currentPhase == DifficultyPhase.expert && totalQuestions < 15) {
        return false;
      }
    }

    // Check if power-up counts are reasonable
    final totalPowerUps = state.totalPowerUps;
    if (totalPowerUps > 20) {
      // Suspiciously high power-up count
      return false;
    }

    // Check if used breeds count makes sense for the phase
    if (state.usedBreeds.length > 100) {
      // Too many breeds used
      return false;
    }

    // Check if game duration makes sense (if active)
    if (state.isGameActive && state.gameStartTime != null) {
      final duration = DateTime.now().difference(state.gameStartTime!);
      if (duration.inHours > 2) {
        // Game has been active for more than 2 hours, suspicious
        return false;
      }
    }

    return true;
  }

  /// Attempt to recover corrupted state
  Future<BreedAdventureGameState?> _attemptStateRecovery(
    BreedAdventureGameState corruptedState,
  ) async {
    try {
      // Try to load backup power-ups
      final backupPowerUps = await _persistence.loadBreedAdventurePowerUps();

      if (backupPowerUps != null) {
        // Create a corrected state with backup power-ups
        final recoveredState = corruptedState.copyWith(
          powerUps: backupPowerUps,
        );

        if (_validateStateIntegrity(recoveredState)) {
          await _errorService.recordError(
            ErrorType.gameLogic,
            'Successfully recovered state using backup power-ups',
            severity: ErrorSeverity.low,
          );
          return recoveredState;
        }
      }

      // Try to get a valid state from history
      final historyState = getRecoveryState();
      if (historyState != null) {
        await _errorService.recordError(
          ErrorType.gameLogic,
          'Recovered state from history',
          severity: ErrorSeverity.medium,
        );
        return historyState;
      }

      // Last resort: create a safe state based on corrupted state
      final safeState = BreedAdventureGameState(
        score: corruptedState.score.clamp(0, 10000),
        correctAnswers: corruptedState.correctAnswers.clamp(
          0,
          corruptedState.totalQuestions,
        ),
        totalQuestions: corruptedState.totalQuestions.clamp(0, 200),
        currentPhase: corruptedState.currentPhase,
        usedBreeds: corruptedState.usedBreeds.length > 100
            ? corruptedState.usedBreeds.take(50).toSet()
            : corruptedState.usedBreeds,
        powerUps: {
          PowerUpType.extraTime: 2,
          PowerUpType.skip: 1,
        }, // Reset to default
        isGameActive: false, // Deactivate to be safe
        gameStartTime: corruptedState.gameStartTime,
        consecutiveCorrect: corruptedState.consecutiveCorrect.clamp(0, 20),
        timeRemaining: corruptedState.timeRemaining.clamp(0, 30),
        currentHint: corruptedState.currentHint,
      );

      if (_validateStateIntegrity(safeState)) {
        await _errorService.recordError(
          ErrorType.gameLogic,
          'Created safe recovery state',
          severity: ErrorSeverity.medium,
        );
        return safeState;
      }
    } catch (e) {
      await _errorService.recordError(
        ErrorType.gameLogic,
        'State recovery failed: $e',
        severity: ErrorSeverity.high,
        originalError: e,
      );
    }

    return null;
  }

  /// Add state to history with size management
  void _addToStateHistory(BreedAdventureGameState state) {
    _stateHistory.add(state);

    // Keep only recent states
    if (_stateHistory.length > _maxStateHistorySize) {
      _stateHistory.removeAt(0);
    }
  }
}
