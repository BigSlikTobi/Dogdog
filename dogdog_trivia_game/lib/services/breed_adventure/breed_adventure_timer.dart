import 'dart:async';
import 'package:flutter/foundation.dart';

/// Timer service for managing the 10-second countdown in Dog Breeds Adventure
class BreedAdventureTimer {
  static BreedAdventureTimer? _instance;
  static BreedAdventureTimer get instance =>
      _instance ??= BreedAdventureTimer._();

  BreedAdventureTimer._();

  /// Factory constructor for testing purposes
  @visibleForTesting
  factory BreedAdventureTimer.forTesting() => BreedAdventureTimer._();

  Timer? _timer;
  StreamController<int>? _timerController;
  int _remainingSeconds = 0;
  bool _isActive = false;
  bool _isPaused = false;

  // Configuration constants
  static const int defaultDuration = 10; // 10 seconds per question
  static const int extraTimeBonus = 5; // Extra time power-up adds 5 seconds
  static const int minTimeRemaining = 0; // Minimum time (when timer expires)
  static const int maxTimeAllowed = 30; // Maximum time allowed (with power-ups)

  /// Get the current remaining seconds
  int get remainingSeconds => _remainingSeconds;

  /// Check if the timer is currently active (running or paused)
  bool get isActive => _isActive;

  /// Check if the timer is currently paused
  bool get isPaused => _isPaused;

  /// Check if the timer is currently running (active and not paused and not expired)
  bool get isRunning => _isActive && !_isPaused && !hasExpired;

  /// Check if the timer has expired (reached zero)
  bool get hasExpired => _remainingSeconds <= 0 && _isActive;

  /// Get the timer stream for real-time UI updates
  Stream<int> get timerStream {
    _timerController ??= StreamController<int>.broadcast();
    return _timerController!.stream;
  }

  /// Start the timer with the specified duration (default 10 seconds)
  void start({int duration = defaultDuration}) {
    if (duration < 0) {
      throw ArgumentError('Timer duration cannot be negative: $duration');
    }

    if (duration > maxTimeAllowed) {
      throw ArgumentError(
        'Timer duration exceeds maximum allowed: $duration > $maxTimeAllowed',
      );
    }

    // Stop any existing timer
    stop();

    _remainingSeconds = duration;
    _isActive = true;
    _isPaused = false;

    // Initialize stream controller if needed
    _timerController ??= StreamController<int>.broadcast();

    // Emit initial value
    _timerController!.add(_remainingSeconds);

    // Start the countdown
    _startCountdown();
  }

  /// Add extra time to the current timer (for Extra Time power-up)
  void addTime(int seconds) {
    if (!_isActive) {
      throw StateError('Cannot add time to inactive timer');
    }

    if (seconds < 0) {
      throw ArgumentError('Cannot add negative time: $seconds');
    }

    final newTime = _remainingSeconds + seconds;
    if (newTime > maxTimeAllowed) {
      _remainingSeconds = maxTimeAllowed;
    } else {
      _remainingSeconds = newTime;
    }

    // Emit updated value
    _timerController?.add(_remainingSeconds);
  }

  /// Pause the timer (for power-up usage)
  void pause() {
    if (!_isActive || _isPaused) return;

    _isPaused = true;
    _timer?.cancel();
    _timer = null;
  }

  /// Resume the timer after being paused
  void resume() {
    if (!_isActive || !_isPaused) return;

    _isPaused = false;
    _startCountdown();
  }

  /// Stop the timer completely
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isActive = false;
    _isPaused = false;
  }

  /// Reset the timer to initial state without starting
  void reset({int duration = defaultDuration}) {
    if (duration < 0) {
      throw ArgumentError('Timer duration cannot be negative: $duration');
    }

    if (duration > maxTimeAllowed) {
      throw ArgumentError(
        'Timer duration exceeds maximum allowed: $duration > $maxTimeAllowed',
      );
    }

    stop();
    _remainingSeconds = duration;

    // Emit reset value if stream is active
    _timerController?.add(_remainingSeconds);
  }

  /// Get the elapsed time since timer started
  int getElapsedTime({int originalDuration = defaultDuration}) {
    if (!_isActive) return 0;
    return originalDuration - _remainingSeconds;
  }

  /// Get the progress percentage (0.0 to 1.0)
  double getProgress({int originalDuration = defaultDuration}) {
    if (originalDuration <= 0) return 1.0;
    if (!_isActive) return 0.0;

    final elapsed = getElapsedTime(originalDuration: originalDuration);
    return (elapsed / originalDuration).clamp(0.0, 1.0);
  }

  /// Check if timer is in critical state (less than 3 seconds remaining)
  bool get isCritical =>
      _isActive && _remainingSeconds <= 3 && _remainingSeconds > 0;

  /// Check if timer is in warning state (less than 5 seconds remaining)
  bool get isWarning =>
      _isActive && _remainingSeconds <= 5 && _remainingSeconds > 3;

  /// Get timer state for UI display
  TimerState get state {
    if (!_isActive) return TimerState.inactive;
    if (_isPaused) return TimerState.paused;
    if (hasExpired) return TimerState.expired;
    if (isCritical) return TimerState.critical;
    if (isWarning) return TimerState.warning;
    return TimerState.normal;
  }

  /// Dispose of resources and clean up
  void dispose() {
    stop();
    _timerController?.close();
    _timerController = null;
  }

  /// Start the internal countdown mechanism
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) {
        timer.cancel();
        return;
      }

      _remainingSeconds--;

      // Emit updated value
      _timerController?.add(_remainingSeconds);

      // Check if timer has expired
      if (_remainingSeconds <= 0) {
        _remainingSeconds = 0;
        timer.cancel();
        _timer = null;

        // Timer remains active but stopped to indicate expiration
        // The game controller should handle the expiration
      }
    });
  }

  /// Reset the singleton instance (mainly for testing)
  @visibleForTesting
  void resetInstance() {
    dispose();
    _instance = null;
  }
}

/// Enum representing different timer states
enum TimerState {
  inactive, // Timer is not running
  normal, // Timer is running normally (>5 seconds)
  warning, // Timer is in warning state (3-5 seconds)
  critical, // Timer is in critical state (1-3 seconds)
  expired, // Timer has reached zero
  paused, // Timer is paused
}

/// Extension to provide display properties for timer states
extension TimerStateExtension on TimerState {
  /// Get the display color for the timer state
  String get colorName {
    switch (this) {
      case TimerState.inactive:
        return 'grey';
      case TimerState.normal:
        return 'green';
      case TimerState.warning:
        return 'orange';
      case TimerState.critical:
        return 'red';
      case TimerState.expired:
        return 'darkRed';
      case TimerState.paused:
        return 'blue';
    }
  }

  /// Get the display name for the timer state
  String get displayName {
    switch (this) {
      case TimerState.inactive:
        return 'Inactive';
      case TimerState.normal:
        return 'Normal';
      case TimerState.warning:
        return 'Warning';
      case TimerState.critical:
        return 'Critical';
      case TimerState.expired:
        return 'Expired';
      case TimerState.paused:
        return 'Paused';
    }
  }

  /// Check if the timer state indicates urgency
  bool get isUrgent =>
      this == TimerState.critical || this == TimerState.expired;

  /// Check if the timer state is active (running or paused)
  bool get isActive => this != TimerState.inactive;
}
