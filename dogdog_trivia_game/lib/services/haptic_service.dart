import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enums.dart';
import 'error_service.dart';

/// Service for managing haptic feedback throughout the game
class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _isEnabled = true;
  bool _isInitialized = false;

  /// Initialize the haptic service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadSettings();
      _isInitialized = true;
    } catch (error, stackTrace) {
      ErrorService().recordError(
        ErrorType.ui,
        'Failed to initialize haptic service: $error',
        severity: ErrorSeverity.low,
        stackTrace: stackTrace,
        originalError: error,
      );

      // Fallback: disable haptics if initialization fails
      _isEnabled = false;
      _isInitialized = true;
    }
  }

  /// Load haptic settings from shared preferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool('haptic_enabled') ?? true;
    } catch (e) {
      // Use default settings if loading fails
      _isEnabled = true;
    }
  }

  /// Save haptic settings to shared preferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('haptic_enabled', _isEnabled);
    } catch (e) {
      // Silently fail if saving fails
    }
  }

  /// Whether haptic feedback is currently enabled
  bool get isEnabled => _isEnabled;

  /// Toggles the haptic feedback state
  Future<void> toggleHaptics() async {
    _isEnabled = !_isEnabled;
    await _saveSettings();
  }

  /// Sets the haptic feedback state
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    await _saveSettings();
  }

  /// Provides light haptic feedback for button presses
  Future<void> lightFeedback() async {
    if (!_isEnabled || !_isInitialized) return;

    try {
      await HapticFeedback.lightImpact();
    } catch (error) {
      ErrorService().recordError(
        ErrorType.ui,
        'Failed to provide light haptic feedback: $error',
        severity: ErrorSeverity.low,
        originalError: error,
      );
    }
  }

  /// Provides medium haptic feedback for correct answers
  Future<void> mediumFeedback() async {
    if (!_isEnabled || !_isInitialized) return;

    try {
      await HapticFeedback.mediumImpact();
    } catch (error) {
      ErrorService().recordError(
        ErrorType.ui,
        'Failed to provide medium haptic feedback: $error',
        severity: ErrorSeverity.low,
        originalError: error,
      );
    }
  }

  /// Provides heavy haptic feedback for major achievements
  Future<void> heavyFeedback() async {
    if (!_isEnabled || !_isInitialized) return;

    try {
      await HapticFeedback.heavyImpact();
    } catch (error) {
      ErrorService().recordError(
        ErrorType.ui,
        'Failed to provide heavy haptic feedback: $error',
        severity: ErrorSeverity.low,
        originalError: error,
      );
    }
  }

  /// Provides selection haptic feedback for navigation
  Future<void> selectionFeedback() async {
    if (!_isEnabled || !_isInitialized) return;

    try {
      await HapticFeedback.selectionClick();
    } catch (error) {
      ErrorService().recordError(
        ErrorType.ui,
        'Failed to provide selection haptic feedback: $error',
        severity: ErrorSeverity.low,
        originalError: error,
      );
    }
  }

  /// Provides power-up specific haptic feedback
  Future<void> powerUpFeedback(PowerUpType powerUpType) async {
    switch (powerUpType) {
      case PowerUpType.extraTime:
        await mediumFeedback(); // Moderate impact for time extension
        break;
      case PowerUpType.fiftyFifty:
      case PowerUpType.hint:
        await lightFeedback(); // Light feedback for assistance
        break;
      case PowerUpType.skip:
        await selectionFeedback(); // Quick selection for skip
        break;
      case PowerUpType.secondChance:
        await heavyFeedback(); // Strong feedback for life restoration
        break;
    }
  }

  /// Provides checkpoint completion haptic feedback
  Future<void> checkpointCompleteFeedback() async {
    if (!_isEnabled || !_isInitialized) return;

    // Double heavy impact for major milestone
    await heavyFeedback();
    await Future.delayed(const Duration(milliseconds: 100));
    await heavyFeedback();
  }

  /// Provides path completion haptic feedback
  Future<void> pathCompleteFeedback() async {
    if (!_isEnabled || !_isInitialized) return;

    // Triple heavy impact for ultimate achievement
    await heavyFeedback();
    await Future.delayed(const Duration(milliseconds: 80));
    await heavyFeedback();
    await Future.delayed(const Duration(milliseconds: 80));
    await heavyFeedback();
  }

  /// Provides streak bonus haptic feedback
  Future<void> streakBonusFeedback() async {
    await mediumFeedback();
  }

  /// Provides milestone achievement haptic feedback
  Future<void> milestoneFeedback() async {
    await heavyFeedback();
  }

  /// Provides incorrect answer haptic feedback
  Future<void> incorrectAnswerFeedback() async {
    if (!_isEnabled || !_isInitialized) return;

    // Short vibration pattern for negative feedback
    try {
      await HapticFeedback.vibrate();
    } catch (error) {
      ErrorService().recordError(
        ErrorType.ui,
        'Failed to provide incorrect answer haptic feedback: $error',
        severity: ErrorSeverity.low,
        originalError: error,
      );
    }
  }
}
