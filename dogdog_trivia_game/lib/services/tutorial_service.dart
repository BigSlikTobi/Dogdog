import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enums.dart';
import 'error_service.dart';

/// Service for managing tutorial system and onboarding
class TutorialService {
  static final TutorialService _instance = TutorialService._internal();
  factory TutorialService() => _instance;
  TutorialService._internal();

  static const String _treasureMapTutorialKey = 'treasure_map_tutorial_shown';
  static const String _checkpointTutorialKey = 'checkpoint_tutorial_shown';
  static const String _powerUpTutorialKey = 'power_up_tutorial_shown';
  static const String _pathSelectionTutorialKey =
      'path_selection_tutorial_shown';

  bool _isInitialized = false;
  bool _treasureMapTutorialShown = false;
  bool _checkpointTutorialShown = false;
  bool _powerUpTutorialShown = false;
  bool _pathSelectionTutorialShown = false;

  /// Initialize the tutorial service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadTutorialState();
      _isInitialized = true;
    } catch (error, stackTrace) {
      ErrorService().recordError(
        ErrorType.storage,
        'Failed to initialize tutorial service: $error',
        severity: ErrorSeverity.low,
        stackTrace: stackTrace,
        originalError: error,
      );

      // Fallback: mark as initialized but reset tutorial state
      _isInitialized = true;
      await _resetAllTutorials();
    }
  }

  /// Load tutorial state from shared preferences
  Future<void> _loadTutorialState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _treasureMapTutorialShown =
          prefs.getBool(_treasureMapTutorialKey) ?? false;
      _checkpointTutorialShown = prefs.getBool(_checkpointTutorialKey) ?? false;
      _powerUpTutorialShown = prefs.getBool(_powerUpTutorialKey) ?? false;
      _pathSelectionTutorialShown =
          prefs.getBool(_pathSelectionTutorialKey) ?? false;
    } catch (e) {
      // Use default settings if loading fails
      _treasureMapTutorialShown = false;
      _checkpointTutorialShown = false;
      _powerUpTutorialShown = false;
      _pathSelectionTutorialShown = false;
    }
  }

  /// Save tutorial state to shared preferences
  Future<void> _saveTutorialState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_treasureMapTutorialKey, _treasureMapTutorialShown);
      await prefs.setBool(_checkpointTutorialKey, _checkpointTutorialShown);
      await prefs.setBool(_powerUpTutorialKey, _powerUpTutorialShown);
      await prefs.setBool(
        _pathSelectionTutorialKey,
        _pathSelectionTutorialShown,
      );
    } catch (e) {
      // Silently fail if saving fails
    }
  }

  /// Whether the treasure map tutorial has been shown
  bool get isTreasureMapTutorialShown => _treasureMapTutorialShown;

  /// Whether the checkpoint tutorial has been shown
  bool get isCheckpointTutorialShown => _checkpointTutorialShown;

  /// Whether the power-up tutorial has been shown
  bool get isPowerUpTutorialShown => _powerUpTutorialShown;

  /// Whether the path selection tutorial has been shown
  bool get isPathSelectionTutorialShown => _pathSelectionTutorialShown;

  /// Mark treasure map tutorial as shown
  Future<void> markTreasureMapTutorialShown() async {
    _treasureMapTutorialShown = true;
    await _saveTutorialState();
  }

  /// Mark checkpoint tutorial as shown
  Future<void> markCheckpointTutorialShown() async {
    _checkpointTutorialShown = true;
    await _saveTutorialState();
  }

  /// Mark power-up tutorial as shown
  Future<void> markPowerUpTutorialShown() async {
    _powerUpTutorialShown = true;
    await _saveTutorialState();
  }

  /// Mark path selection tutorial as shown
  Future<void> markPathSelectionTutorialShown() async {
    _pathSelectionTutorialShown = true;
    await _saveTutorialState();
  }

  /// Reset all tutorials (for testing or admin purposes)
  Future<void> _resetAllTutorials() async {
    _treasureMapTutorialShown = false;
    _checkpointTutorialShown = false;
    _powerUpTutorialShown = false;
    _pathSelectionTutorialShown = false;
    await _saveTutorialState();
  }

  /// Reset all tutorials public method
  Future<void> resetAllTutorials() async {
    await _resetAllTutorials();
  }

  /// Check if any tutorial should be shown for the current context
  bool shouldShowTutorialFor(TutorialType tutorialType) {
    if (!_isInitialized) return false;

    switch (tutorialType) {
      case TutorialType.treasureMap:
        return !_treasureMapTutorialShown;
      case TutorialType.checkpoint:
        return !_checkpointTutorialShown;
      case TutorialType.powerUp:
        return !_powerUpTutorialShown;
      case TutorialType.pathSelection:
        return !_pathSelectionTutorialShown;
    }
  }

  /// Mark tutorial as shown for the given type
  Future<void> markTutorialShown(TutorialType tutorialType) async {
    switch (tutorialType) {
      case TutorialType.treasureMap:
        await markTreasureMapTutorialShown();
        break;
      case TutorialType.checkpoint:
        await markCheckpointTutorialShown();
        break;
      case TutorialType.powerUp:
        await markPowerUpTutorialShown();
        break;
      case TutorialType.pathSelection:
        await markPathSelectionTutorialShown();
        break;
    }
  }

  /// Get tutorial data for the given type
  TutorialData getTutorialData(TutorialType tutorialType) {
    switch (tutorialType) {
      case TutorialType.treasureMap:
        return TutorialData(
          title: 'Welcome to Treasure Map!',
          steps: [
            TutorialStep(
              title: 'Your Adventure Begins',
              description:
                  'Navigate through checkpoints by answering questions correctly. Each path has unique dog breed challenges!',
              icon: Icons.map,
            ),
            TutorialStep(
              title: 'Checkpoint Progress',
              description:
                  'Complete sets of questions to reach each checkpoint. Your progress is saved automatically!',
              icon: Icons.flag,
            ),
            TutorialStep(
              title: 'Earn Rewards',
              description:
                  'Reach checkpoints to earn power-ups and unlock new challenges on your journey!',
              icon: Icons.star,
            ),
          ],
        );
      case TutorialType.checkpoint:
        return TutorialData(
          title: 'Checkpoint System',
          steps: [
            TutorialStep(
              title: 'Reach Milestones',
              description:
                  'Answer questions correctly to advance toward the next checkpoint!',
              icon: Icons.flag,
            ),
            TutorialStep(
              title: 'Earn Power-ups',
              description:
                  'Each checkpoint rewards you with helpful power-ups for future questions!',
              icon: Icons.bolt,
            ),
            TutorialStep(
              title: 'Track Progress',
              description:
                  'See how many questions remain until your next milestone achievement!',
              icon: Icons.trending_up,
            ),
          ],
        );
      case TutorialType.powerUp:
        return TutorialData(
          title: 'Power-up System',
          steps: [
            TutorialStep(
              title: 'Fifty-Fifty',
              description:
                  'Removes two incorrect answers, making your choice easier!',
              icon: Icons.filter_2,
            ),
            TutorialStep(
              title: 'Hint',
              description: 'Provides a helpful clue about the correct answer!',
              icon: Icons.lightbulb,
            ),
            TutorialStep(
              title: 'Extra Time',
              description:
                  'Adds precious seconds to your timer when time is running out!',
              icon: Icons.access_time,
            ),
            TutorialStep(
              title: 'Skip Question',
              description: 'Move to the next question without penalty!',
              icon: Icons.skip_next,
            ),
            TutorialStep(
              title: 'Second Chance',
              description: 'Restores a life when you make a mistake!',
              icon: Icons.favorite,
            ),
          ],
        );
      case TutorialType.pathSelection:
        return TutorialData(
          title: 'Learning Paths',
          steps: [
            TutorialStep(
              title: 'Choose Your Journey',
              description:
                  'Select from 5 different themed learning paths, each with unique challenges!',
              icon: Icons.explore,
            ),
            TutorialStep(
              title: 'Track Your Progress',
              description:
                  'Each path tracks your individual progress and achievements separately!',
              icon: Icons.track_changes,
            ),
            TutorialStep(
              title: 'Complete the Adventure',
              description:
                  'Reach the final Deutsche Dogge checkpoint to complete your chosen path!',
              icon: Icons.emoji_events,
            ),
          ],
        );
    }
  }
}

/// Types of tutorials available in the system
enum TutorialType { treasureMap, checkpoint, powerUp, pathSelection }

/// Data structure for tutorial content
class TutorialData {
  final String title;
  final List<TutorialStep> steps;

  const TutorialData({required this.title, required this.steps});
}

/// Individual step in a tutorial
class TutorialStep {
  final String title;
  final String description;
  final IconData icon;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}
