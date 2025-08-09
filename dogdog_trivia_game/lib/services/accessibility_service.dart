import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enums.dart';
import '../utils/path_localization.dart';
import 'error_service.dart';

/// Service for managing accessibility features throughout the game
class AccessibilityService {
  static final AccessibilityService _instance =
      AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  bool _isInitialized = false;
  bool _highContrastEnabled = false;
  bool _largeTextEnabled = false;
  bool _reducedMotionEnabled = false;
  bool _screenReaderEnabled = false;
  double _textScaleFactor = 1.0;

  /// Initialize the accessibility service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadAccessibilitySettings();
      _detectSystemAccessibilitySettings();
      _isInitialized = true;
    } catch (error, stackTrace) {
      ErrorService().recordError(
        ErrorType.ui,
        'Failed to initialize accessibility service: $error',
        severity: ErrorSeverity.low,
        stackTrace: stackTrace,
        originalError: error,
      );

      // Fallback: use default accessibility settings
      _isInitialized = true;
    }
  }

  /// Load accessibility settings from shared preferences
  Future<void> _loadAccessibilitySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _highContrastEnabled =
          prefs.getBool('accessibility_high_contrast') ?? false;
      _largeTextEnabled = prefs.getBool('accessibility_large_text') ?? false;
      _reducedMotionEnabled =
          prefs.getBool('accessibility_reduced_motion') ?? false;
      _textScaleFactor = prefs.getDouble('accessibility_text_scale') ?? 1.0;
    } catch (e) {
      // Use default settings if loading fails
      _highContrastEnabled = false;
      _largeTextEnabled = false;
      _reducedMotionEnabled = false;
      _textScaleFactor = 1.0;
    }
  }

  /// Save accessibility settings to shared preferences
  Future<void> _saveAccessibilitySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('accessibility_high_contrast', _highContrastEnabled);
      await prefs.setBool('accessibility_large_text', _largeTextEnabled);
      await prefs.setBool(
        'accessibility_reduced_motion',
        _reducedMotionEnabled,
      );
      await prefs.setDouble('accessibility_text_scale', _textScaleFactor);
    } catch (e) {
      // Silently fail if saving fails
    }
  }

  /// Detect system accessibility settings
  void _detectSystemAccessibilitySettings() {
    try {
      final data = MediaQueryData.fromView(
        WidgetsBinding.instance.platformDispatcher.views.first,
      );
      _screenReaderEnabled = data.accessibleNavigation;

      // Auto-enable large text if system text scale is high
      // Use TextScaler API to get system text scale

      // Auto-enable reduced motion if system prefers reduced motion
      if (data.disableAnimations && !_reducedMotionEnabled) {
        _reducedMotionEnabled = true;
      }
    } catch (e) {
      // Silently fail if detection fails
    }
  }

  /// Getters for accessibility settings
  bool get isHighContrastEnabled => _highContrastEnabled;
  bool get isLargeTextEnabled => _largeTextEnabled;
  bool get isReducedMotionEnabled => _reducedMotionEnabled;
  bool get isScreenReaderEnabled => _screenReaderEnabled;
  double get textScaleFactor => _textScaleFactor;

  /// Toggle high contrast mode
  Future<void> toggleHighContrast() async {
    _highContrastEnabled = !_highContrastEnabled;
    await _saveAccessibilitySettings();
  }

  /// Toggle large text mode
  Future<void> toggleLargeText() async {
    _largeTextEnabled = !_largeTextEnabled;
    _textScaleFactor = _largeTextEnabled ? 1.3 : 1.0;
    await _saveAccessibilitySettings();
  }

  /// Toggle reduced motion mode
  Future<void> toggleReducedMotion() async {
    _reducedMotionEnabled = !_reducedMotionEnabled;
    await _saveAccessibilitySettings();
  }

  /// Set custom text scale factor
  Future<void> setTextScaleFactor(double factor) async {
    _textScaleFactor = factor.clamp(0.8, 2.0);
    _largeTextEnabled = _textScaleFactor > 1.1;
    await _saveAccessibilitySettings();
  }

  /// Get accessible color scheme based on settings
  ColorScheme getAccessibleColorScheme(BuildContext context) {
    final base = Theme.of(context).colorScheme;

    if (!_highContrastEnabled) return base;

    // High contrast color modifications
    return base.copyWith(
      primary: _highContrastEnabled ? Colors.black : base.primary,
      onPrimary: _highContrastEnabled ? Colors.white : base.onPrimary,
      secondary: _highContrastEnabled ? Colors.black87 : base.secondary,
      onSecondary: _highContrastEnabled ? Colors.white : base.onSecondary,
      surface: _highContrastEnabled ? Colors.white : base.surface,
      onSurface: _highContrastEnabled ? Colors.black : base.onSurface,
    );
  }

  /// Get accessible text theme based on settings
  TextTheme getAccessibleTextTheme(BuildContext context) {
    final base = Theme.of(context).textTheme;

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: (base.displayLarge?.fontSize ?? 24) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.bold
            : base.displayLarge?.fontWeight,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: (base.displayMedium?.fontSize ?? 20) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.bold
            : base.displayMedium?.fontWeight,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: (base.bodyLarge?.fontSize ?? 16) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.w600
            : base.bodyLarge?.fontWeight,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: (base.bodyMedium?.fontSize ?? 14) * _textScaleFactor,
        fontWeight: _largeTextEnabled
            ? FontWeight.w600
            : base.bodyMedium?.fontWeight,
      ),
    );
  }

  /// Get semantic label for checkpoint
  String getCheckpointSemanticLabel(
    Checkpoint checkpoint,
    int questionsCompleted,
    int questionsRequired,
  ) {
    final progress = questionsCompleted / questionsRequired;
    final percentage = (progress * 100).round();

    String statusText;
    if (progress >= 1.0) {
      statusText = 'completed';
    } else if (progress > 0) {
      statusText = '$percentage percent complete';
    } else {
      statusText = 'not started';
    }

    return 'Checkpoint ${checkpoint.displayName}, $statusText. $questionsCompleted of $questionsRequired questions answered.';
  }

  /// Get semantic label for power-up
  String getPowerUpSemanticLabel(PowerUpType powerUpType, int count) {
    final displayName = _getPowerUpDisplayName(powerUpType);
    final description = _getPowerUpDescription(powerUpType);
    final countText = count == 1 ? '1 available' : '$count available';

    return '$displayName power-up, $countText. $description';
  }

  /// Get semantic label for path selection
  String getPathSemanticLabel(
    BuildContext context,
    PathType pathType,
    bool isUnlocked,
    double progress,
  ) {
    final statusText = isUnlocked ? 'unlocked' : 'locked';
    final progressText = progress > 0
        ? ', ${(progress * 100).round()} percent complete'
        : '';

    return '${pathType.getLocalizedName(context)} learning path, $statusText$progressText. ${pathType.getLocalizedDescription(context)}';
  }

  /// Get semantic label for timer
  String getTimerSemanticLabel(int timeRemaining, bool isWarning) {
    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;

    String timeText;
    if (minutes > 0) {
      timeText = '$minutes minutes and $seconds seconds';
    } else {
      timeText = '$seconds seconds';
    }

    final warningText = isWarning ? ' Warning: time running out.' : '';
    return 'Timer: $timeText remaining$warningText';
  }

  /// Get semantic label for lives display
  String getLivesSemanticLabel(int currentLives, int maxLives) {
    return 'Lives: $currentLives out of $maxLives remaining';
  }

  /// Get semantic label for score display
  String getScoreSemanticLabel(int score, int streak) {
    final streakText = streak > 1 ? ', streak of $streak correct answers' : '';
    return 'Score: $score points$streakText';
  }

  /// Private helper to get power-up descriptions
  String _getPowerUpDescription(PowerUpType powerUpType) {
    switch (powerUpType) {
      case PowerUpType.fiftyFifty:
        return 'Removes two incorrect answer options';
      case PowerUpType.hint:
        return 'Provides a helpful clue about the correct answer';
      case PowerUpType.extraTime:
        return 'Adds extra time to the current question timer';
      case PowerUpType.skip:
        return 'Skip the current question without losing a life';
      case PowerUpType.secondChance:
        return 'Restore one life when making a mistake';
    }
  }

  /// Private helper to get power-up display names
  String _getPowerUpDisplayName(PowerUpType powerUpType) {
    switch (powerUpType) {
      case PowerUpType.fiftyFifty:
        return 'Fifty-Fifty';
      case PowerUpType.hint:
        return 'Hint';
      case PowerUpType.extraTime:
        return 'Extra Time';
      case PowerUpType.skip:
        return 'Skip Question';
      case PowerUpType.secondChance:
        return 'Second Chance';
    }
  }

  /// Create accessible widget wrapper
  Widget createAccessibleWidget({
    required Widget child,
    required String semanticLabel,
    String? hint,
    bool isButton = false,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: isButton,
      child: isButton && onTap != null
          ? GestureDetector(onTap: onTap, child: child)
          : child,
    );
  }

  /// Get animation duration based on reduced motion setting
  Duration getAnimationDuration(Duration normalDuration) {
    if (_reducedMotionEnabled) {
      return Duration(
        milliseconds: (normalDuration.inMilliseconds * 0.3).round(),
      );
    }
    return normalDuration;
  }

  /// Check if animations should be disabled
  bool shouldDisableAnimations() {
    return _reducedMotionEnabled;
  }
}
