import 'package:flutter/material.dart';
import '../models/enums.dart';

/// Controller for managing enhanced feedback and engagement animations in the game
///
/// This controller handles:
/// - Score multiplier animations and celebrations
/// - Streak milestone animations
/// - Checkpoint approach feedback
/// - Power-up usage animations
/// - Personal best notifications
class FeedbackController extends ChangeNotifier {
  /// Current animation states
  bool _isScoreAnimating = false;
  bool _isStreakCelebrating = false;
  bool _isMilestoneAnimating = false;
  bool _isPowerUpAnimating = false;
  bool _isPersonalBestShowing = false;

  /// Animation trigger flags
  bool _shouldShowStreakCelebration = false;
  bool _shouldShowMilestoneProgress = false;
  bool _shouldShowPersonalBest = false;
  bool _shouldShowPowerUpFeedback = false;

  /// Current streak and multiplier values for animations
  int _currentStreak = 0;
  int _currentMultiplier = 1;
  int _scoreGained = 0;

  /// Milestone progress animation values
  double _milestoneProgress = 0.0;
  int _questionsToMilestone = 0;
  final int _nextMilestone = 1000;

  /// Power-up animation state
  PowerUpType? _activePowerUpType;
  int _powerUpBefore = 0;
  int _powerUpAfter = 0;

  /// Personal best information
  int _personalBest = 0;
  int _newBestScore = 0;
  int _previousBestScore = 0;
  bool _isNewPersonalBest = false;

  // Getters
  bool get isScoreAnimating => _isScoreAnimating;
  bool get isStreakCelebrating => _isStreakCelebrating;
  bool get isMilestoneAnimating => _isMilestoneAnimating;
  bool get isPowerUpAnimating => _isPowerUpAnimating;
  bool get isPersonalBestShowing => _isPersonalBestShowing;

  bool get shouldShowStreakCelebration => _shouldShowStreakCelebration;
  bool get shouldShowMilestoneProgress => _shouldShowMilestoneProgress;
  bool get shouldShowPersonalBest => _shouldShowPersonalBest;
  bool get showStreakCelebration => _shouldShowStreakCelebration;
  bool get showMilestoneProgress => _shouldShowMilestoneProgress;
  bool get showPersonalBest => _shouldShowPersonalBest;
  bool get showPowerUpFeedback => _shouldShowPowerUpFeedback;

  int get currentStreak => _currentStreak;
  int get currentMultiplier => _currentMultiplier;
  int get nextMilestone => _nextMilestone;
  double get milestoneProgress => _milestoneProgress;
  PowerUpType? get powerUpType => _activePowerUpType;
  int get powerUpBefore => _powerUpBefore;
  int get powerUpAfter => _powerUpAfter;
  int get newBestScore => _newBestScore;
  int get previousBestScore => _previousBestScore;
  int get scoreGained => _scoreGained;
  int get questionsToMilestone => _questionsToMilestone;
  int get personalBest => _personalBest;
  bool get isNewPersonalBest => _isNewPersonalBest;

  /// Triggers score gain animation with multiplier celebration
  void triggerScoreAnimation(int scoreGained, int newMultiplier, int streak) {
    _scoreGained = scoreGained;
    _currentMultiplier = newMultiplier;
    _currentStreak = streak;
    _isScoreAnimating = true;

    // Check for streak milestones (every 3 correct answers)
    if (streak > 0 && streak % 3 == 0 && streak != _previousStreakMilestone) {
      _shouldShowStreakCelebration = true;
      _previousStreakMilestone = streak;
    }

    notifyListeners();
  }

  int _previousStreakMilestone = 0;

  /// Triggers milestone progress animation when approaching checkpoint
  void triggerMilestoneProgress(double progress, int questionsRemaining) {
    _milestoneProgress = progress;
    _questionsToMilestone = questionsRemaining;
    _shouldShowMilestoneProgress = true;
    _isMilestoneAnimating = true;
    notifyListeners();
  }

  /// Triggers power-up usage animation
  void triggerPowerUpAnimation(
    PowerUpType powerUpType, {
    int? beforeValue,
    int? afterValue,
  }) {
    _activePowerUpType = powerUpType;
    _powerUpBefore = beforeValue ?? 0;
    _powerUpAfter = afterValue ?? 0;
    _shouldShowPowerUpFeedback = true;
    _isPowerUpAnimating = true;
    notifyListeners();
  }

  /// Triggers personal best celebration
  void triggerPersonalBest(int newScore, int previousBest) {
    if (newScore > previousBest) {
      _newBestScore = newScore;
      _previousBestScore = previousBest;
      _personalBest = newScore;
      _isNewPersonalBest = true;
      _shouldShowPersonalBest = true;
      _isPersonalBestShowing = true;
      notifyListeners();
    }
  }

  /// Completes score animation
  void completeScoreAnimation() {
    _isScoreAnimating = false;
    notifyListeners();
  }

  /// Completes streak celebration
  void completeStreakCelebration() {
    _isStreakCelebrating = false;
    _shouldShowStreakCelebration = false;
    notifyListeners();
  }

  /// Completes milestone animation
  void completeMilestoneAnimation() {
    _isMilestoneAnimating = false;
    _shouldShowMilestoneProgress = false;
    notifyListeners();
  }

  /// Completes power-up animation
  void completePowerUpAnimation() {
    _isPowerUpAnimating = false;
    _activePowerUpType = null;
    notifyListeners();
  }

  /// Completes personal best celebration
  void completePersonalBest() {
    _isPersonalBestShowing = false;
    _shouldShowPersonalBest = false;
    _isNewPersonalBest = false;
    notifyListeners();
  }

  /// Resets all animation states
  void resetAnimations() {
    _isScoreAnimating = false;
    _isStreakCelebrating = false;
    _isMilestoneAnimating = false;
    _isPowerUpAnimating = false;
    _isPersonalBestShowing = false;

    _shouldShowStreakCelebration = false;
    _shouldShowMilestoneProgress = false;
    _shouldShowPersonalBest = false;

    _activePowerUpType = null;
    notifyListeners();
  }

  /// Updates score tracking for animation calculations
  void updateScore(int newScore) {}

  /// Hide streak celebration
  void hideStreakCelebration() {
    _shouldShowStreakCelebration = false;
    _isStreakCelebrating = false;
    notifyListeners();
  }

  /// Hide milestone progress
  void hideMilestoneProgress() {
    _shouldShowMilestoneProgress = false;
    _isMilestoneAnimating = false;
    notifyListeners();
  }

  /// Hide power-up feedback
  void hidePowerUpFeedback() {
    _shouldShowPowerUpFeedback = false;
    _isPowerUpAnimating = false;
    _activePowerUpType = null;
    notifyListeners();
  }

  /// Hide personal best
  void hidePersonalBest() {
    _shouldShowPersonalBest = false;
    _isPersonalBestShowing = false;
    _isNewPersonalBest = false;
    notifyListeners();
  }
}
