import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/audio_service.dart';

/// Enhanced timer controller with persistent state, warnings, and improved management
class PersistentTimerController extends ChangeNotifier {
  Timer? _timer;
  int _timeRemaining = 0;
  int _totalTime = 0;
  bool _isActive = false;
  bool _isPaused = false;
  bool _hasTriggeredWarning = false;
  VoidCallback? _onTimeExpired;
  VoidCallback? _onWarning;

  int get timeRemaining => _timeRemaining;
  int get totalTime => _totalTime;
  bool get isActive => _isActive;
  bool get isPaused => _isPaused;
  double get progress => _totalTime > 0 ? _timeRemaining / _totalTime : 0.0;
  bool get isWarningTriggered => _hasTriggeredWarning;
  bool get isInCriticalTime => progress <= 0.3 && _timeRemaining > 0;

  /// Starts a new timer with the specified duration
  void startTimer({
    required int seconds,
    required VoidCallback onTimeExpired,
    VoidCallback? onWarning,
  }) {
    _stopTimer();
    _timeRemaining = seconds;
    _totalTime = seconds;
    _isActive = true;
    _isPaused = false;
    _hasTriggeredWarning = false;
    _onTimeExpired = onTimeExpired;
    _onWarning = onWarning;

    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    notifyListeners();
  }

  /// Pauses the timer without stopping it
  void pauseTimer() {
    if (_isActive && !_isPaused) {
      _timer?.cancel();
      _isPaused = true;
      notifyListeners();
    }
  }

  /// Resumes a paused timer
  void resumeTimer() {
    if (_isActive && _isPaused && _timeRemaining > 0) {
      _isPaused = false;
      _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
      notifyListeners();
    }
  }

  /// Adds time to the current timer (for extraTime power-up)
  void addTime(int seconds) {
    if (_isActive && seconds > 0) {
      _timeRemaining += seconds;
      notifyListeners();
    }
  }

  /// Stops the timer completely
  void stopTimer() {
    _stopTimer();
  }

  /// Resets the timer to a new duration without starting it
  void resetTimer(int seconds) {
    _stopTimer();
    _timeRemaining = seconds;
    _totalTime = seconds;
    _hasTriggeredWarning = false;
    notifyListeners();
  }

  /// Internal timer tick handler
  void _onTick(Timer timer) {
    if (_timeRemaining > 0) {
      _timeRemaining--;
      notifyListeners();

      // Trigger warning at 30% remaining time, but only once
      if (!_hasTriggeredWarning &&
          _timeRemaining <= (_totalTime * 0.3).round() &&
          _timeRemaining > 0) {
        _hasTriggeredWarning = true;
        _triggerWarning();
      }
    } else {
      _stopTimer();
      _onTimeExpired?.call();
    }
  }

  /// Triggers the warning notification
  void _triggerWarning() {
    // Trigger visual and audio warning
    AudioService().playTimerWarningSound();
    _onWarning?.call();
  }

  /// Internal method to stop the timer
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isActive = false;
    _isPaused = false;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
