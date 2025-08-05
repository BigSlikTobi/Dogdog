import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_progress.dart';
import '../models/achievement.dart';
import '../models/enums.dart';
import '../utils/retry_mechanism.dart';
import 'error_service.dart';

/// Service for managing player progress, achievements, and local data persistence
class ProgressService extends ChangeNotifier {
  static const String _progressKey = 'player_progress';
  static const String _firstLaunchKey = 'first_launch';
  static const String _dataVersionKey = 'data_version';
  static const String _lastSaveKey = 'last_save_timestamp';
  static const String _backupKey = 'progress_backup';

  // Current data version for migration purposes
  static const int _currentDataVersion = 1;

  // Auto-save interval in seconds
  static const int _autoSaveInterval = 30;

  PlayerProgress _currentProgress = PlayerProgress.initial();
  SharedPreferences? _prefs;
  bool _hasUnsavedChanges = false;
  DateTime? _lastSaveTime;
  Stream<void>? _autoSaveStream;
  StreamSubscription<void>? _autoSaveSubscription;

  /// Gets the current player progress
  PlayerProgress get currentProgress => _currentProgress;

  /// Initializes the service and loads saved progress
  Future<void> initialize() async {
    try {
      final result = await StorageRetry.execute<void>(() async {
        _prefs = await SharedPreferences.getInstance();
        await _performDataMigration();
        await _loadProgress();
      });

      if (result.success) {
        _startAutoSaveTimer();
      } else {
        // Fallback initialization with default progress
        _currentProgress = PlayerProgress.initial();
        ErrorService().handleStorageError(
          result.error ?? Exception('Failed to initialize progress service'),
        );
      }
    } catch (error, stackTrace) {
      ErrorService().recordError(
        ErrorType.storage,
        'Critical failure in ProgressService initialization',
        severity: ErrorSeverity.high,
        stackTrace: stackTrace,
        originalError: error,
      );

      // Use default progress as fallback
      _currentProgress = PlayerProgress.initial();
    }
  }

  /// Performs data migration if needed
  Future<void> _performDataMigration() async {
    try {
      final currentVersion = _prefs?.getInt(_dataVersionKey) ?? 0;

      if (currentVersion < _currentDataVersion) {
        await _migrateData(currentVersion, _currentDataVersion);
        await _prefs?.setInt(_dataVersionKey, _currentDataVersion);
      }
    } catch (e) {
      debugPrint('Error during data migration: $e');
      // If migration fails, we'll start fresh
      await _clearAllData();
    }
  }

  /// Migrates data from old version to new version
  Future<void> _migrateData(int fromVersion, int toVersion) async {
    debugPrint('Migrating data from version $fromVersion to $toVersion');

    // Create backup before migration
    await _createBackup();

    // Perform version-specific migrations
    for (int version = fromVersion; version < toVersion; version++) {
      switch (version) {
        case 0:
          await _migrateFromV0ToV1();
          break;
        // Add more migration cases as needed
      }
    }
  }

  /// Migrates from version 0 to version 1
  Future<void> _migrateFromV0ToV1() async {
    // Example migration: Add new fields or restructure data
    final oldProgressJson = _prefs?.getString(_progressKey);
    if (oldProgressJson != null) {
      try {
        // Parse old format and convert to new format
        final oldProgress = PlayerProgress.fromJsonString(oldProgressJson);
        // In this case, no changes needed as we're starting with v1
        await _prefs?.setString(_progressKey, oldProgress.toJsonString());
      } catch (e) {
        debugPrint('Error migrating from v0 to v1: $e');
        // If migration fails, start fresh
        await _prefs?.remove(_progressKey);
      }
    }
  }

  /// Starts the auto-save timer
  void _startAutoSaveTimer() {
    // Skip auto-save timer in test environment
    if (const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false)) {
      return;
    }

    // Auto-save every 30 seconds if there are unsaved changes
    _autoSaveStream = Stream.periodic(
      const Duration(seconds: _autoSaveInterval),
    );
    _autoSaveSubscription = _autoSaveStream!.listen((_) {
      if (_hasUnsavedChanges) {
        _saveProgressWithBackup();
      }
    });
  }

  /// Loads player progress from local storage
  Future<void> _loadProgress() async {
    try {
      final progressJson = _prefs?.getString(_progressKey);
      if (progressJson != null) {
        _currentProgress = PlayerProgress.fromJsonString(progressJson);
      } else {
        // First time user - create initial progress
        _currentProgress = PlayerProgress.initial();
        await _saveProgress();
      }
    } catch (e) {
      // If loading fails, start with initial progress
      _currentProgress = PlayerProgress.initial();
      await _saveProgress();
    }
  }

  /// Saves current progress to local storage
  Future<void> _saveProgress() async {
    try {
      final progressJson = _currentProgress.toJsonString();
      await _prefs?.setString(_progressKey, progressJson);
      await _prefs?.setString(_lastSaveKey, DateTime.now().toIso8601String());
      _lastSaveTime = DateTime.now();
      _hasUnsavedChanges = false;
    } catch (e) {
      debugPrint('Error saving progress: $e');
      // Try to recover from backup if save fails
      await _recoverFromBackup();
    }
  }

  /// Saves progress with automatic backup creation
  Future<void> _saveProgressWithBackup() async {
    try {
      // Create backup before saving
      await _createBackup();
      await _saveProgress();
    } catch (e) {
      debugPrint('Error saving progress with backup: $e');
    }
  }

  /// Creates a backup of current progress
  Future<void> _createBackup() async {
    try {
      final currentProgressJson = _prefs?.getString(_progressKey);
      if (currentProgressJson != null) {
        await _prefs?.setString(_backupKey, currentProgressJson);
        debugPrint('Backup created successfully');
      }
    } catch (e) {
      debugPrint('Error creating backup: $e');
    }
  }

  /// Recovers progress from backup
  Future<void> _recoverFromBackup() async {
    try {
      final backupJson = _prefs?.getString(_backupKey);
      if (backupJson != null) {
        _currentProgress = PlayerProgress.fromJsonString(backupJson);
        debugPrint('Progress recovered from backup');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error recovering from backup: $e');
      // If backup recovery fails, start with initial progress
      _currentProgress = PlayerProgress.initial();
      notifyListeners();
    }
  }

  /// Clears all stored data
  Future<void> _clearAllData() async {
    try {
      await _prefs?.remove(_progressKey);
      await _prefs?.remove(_backupKey);
      await _prefs?.remove(_lastSaveKey);
      await _prefs?.remove(_dataVersionKey);
      debugPrint('All data cleared');
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }

  /// Updates progress after a correct answer
  Future<List<Achievement>> recordCorrectAnswer({
    required int pointsEarned,
    required int currentStreak,
  }) async {
    final newCorrectAnswers = _currentProgress.totalCorrectAnswers + 1;
    final newQuestionsAnswered = _currentProgress.totalQuestionsAnswered + 1;
    final newScore = _currentProgress.totalScore + pointsEarned;
    final newLongestStreak = currentStreak > _currentProgress.longestStreak
        ? currentStreak
        : _currentProgress.longestStreak;

    // Check for newly unlocked achievements
    final newlyUnlocked = await _checkForNewAchievements(newCorrectAnswers);

    // Update current rank based on correct answers
    final newRank = _calculateRankFromCorrectAnswers(newCorrectAnswers);

    // Update achievements list with newly unlocked ones
    final updatedAchievements = _currentProgress.achievements.map((
      achievement,
    ) {
      if (newlyUnlocked.any((unlocked) => unlocked.id == achievement.id)) {
        return achievement.unlock();
      }
      return achievement;
    }).toList();

    _currentProgress = _currentProgress.copyWith(
      totalCorrectAnswers: newCorrectAnswers,
      totalQuestionsAnswered: newQuestionsAnswered,
      totalScore: newScore,
      currentRank: newRank,
      achievements: updatedAchievements,
      lastPlayDate: DateTime.now(),
      longestStreak: newLongestStreak,
    );

    _hasUnsavedChanges = true;
    await _saveProgress();
    notifyListeners();
    return newlyUnlocked;
  }

  /// Updates progress after an incorrect answer
  Future<void> recordIncorrectAnswer() async {
    final newQuestionsAnswered = _currentProgress.totalQuestionsAnswered + 1;

    _currentProgress = _currentProgress.copyWith(
      totalQuestionsAnswered: newQuestionsAnswered,
      lastPlayDate: DateTime.now(),
    );

    _hasUnsavedChanges = true;
    await _saveProgress();
    notifyListeners();
  }

  /// Records the completion of a game
  Future<void> recordGameCompletion({
    required int finalScore,
    required int levelReached,
  }) async {
    final newGamesPlayed = _currentProgress.totalGamesPlayed + 1;
    final newHighestLevel = levelReached > _currentProgress.highestLevel
        ? levelReached
        : _currentProgress.highestLevel;

    _currentProgress = _currentProgress.copyWith(
      totalGamesPlayed: newGamesPlayed,
      highestLevel: newHighestLevel,
      lastPlayDate: DateTime.now(),
    );

    _hasUnsavedChanges = true;
    await _saveProgress();
    notifyListeners();
  }

  /// Updates daily challenge streak
  Future<void> recordDailyChallengeCompletion() async {
    final now = DateTime.now();
    final lastChallenge = _currentProgress.lastDailyChallengeDate;

    int newStreak = _currentProgress.dailyChallengeStreak;

    if (lastChallenge == null) {
      // First daily challenge
      newStreak = 1;
    } else {
      // Calculate days difference using date only (ignore time)
      final lastDate = DateTime(
        lastChallenge.year,
        lastChallenge.month,
        lastChallenge.day,
      );
      final currentDate = DateTime(now.year, now.month, now.day);
      final daysDifference = currentDate.difference(lastDate).inDays;

      if (daysDifference == 1) {
        // Consecutive day
        newStreak += 1;
      } else if (daysDifference > 1) {
        // Streak broken, start over
        newStreak = 1;
      }
      // If same day (daysDifference == 0), don't change streak
    }

    _currentProgress = _currentProgress.copyWith(
      dailyChallengeStreak: newStreak,
      lastDailyChallengeDate: now,
      lastPlayDate: now,
    );

    _hasUnsavedChanges = true;
    await _saveProgress();
    notifyListeners();
  }

  /// Unlocks specific content (like breed cards, themes, etc.)
  Future<void> unlockContent(String contentId) async {
    final updatedContent = Map<String, bool>.from(
      _currentProgress.unlockedContent,
    );
    updatedContent[contentId] = true;

    _currentProgress = _currentProgress.copyWith(
      unlockedContent: updatedContent,
    );

    _hasUnsavedChanges = true;
    await _saveProgress();
    notifyListeners();
  }

  /// Checks if specific content is unlocked
  bool isContentUnlocked(String contentId) {
    return _currentProgress.unlockedContent[contentId] ?? false;
  }

  /// Gets all unlocked achievements
  List<Achievement> getUnlockedAchievements() {
    return _currentProgress.unlockedAchievements;
  }

  /// Gets all locked achievements
  List<Achievement> getLockedAchievements() {
    return _currentProgress.lockedAchievements;
  }

  /// Gets progress towards next rank (0.0 to 1.0)
  double getProgressToNextRank() {
    return _currentProgress.progressToNextRank;
  }

  /// Gets the next rank to achieve
  Rank? getNextRank() {
    return _currentProgress.nextRank;
  }

  /// Checks for newly unlocked achievements based on correct answers
  Future<List<Achievement>> _checkForNewAchievements(int correctAnswers) async {
    final newlyUnlocked = <Achievement>[];

    for (final achievement in _currentProgress.achievements) {
      if (achievement.shouldUnlock(correctAnswers)) {
        newlyUnlocked.add(achievement);
      }
    }

    return newlyUnlocked;
  }

  /// Calculates the current rank based on correct answers
  Rank _calculateRankFromCorrectAnswers(int correctAnswers) {
    for (int i = Rank.values.length - 1; i >= 0; i--) {
      final rank = Rank.values[i];
      if (correctAnswers >= rank.requiredCorrectAnswers) {
        return rank;
      }
    }
    return Rank.chihuahua;
  }

  /// Resets all progress (for testing or user request)
  Future<void> resetProgress() async {
    _currentProgress = PlayerProgress.initial();
    _hasUnsavedChanges = true;
    await _saveProgress();
    notifyListeners();
  }

  /// Exports progress as JSON string (for backup/sharing)
  String exportProgress() {
    return _currentProgress.toJsonString();
  }

  /// Imports progress from JSON string (for restore)
  Future<bool> importProgress(String jsonString) async {
    try {
      final importedProgress = PlayerProgress.fromJsonString(jsonString);
      _currentProgress = importedProgress;
      _hasUnsavedChanges = true;
      await _saveProgress();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error importing progress: $e');
      return false;
    }
  }

  /// Gets player statistics summary
  Map<String, dynamic> getStatistics() {
    return {
      'totalCorrectAnswers': _currentProgress.totalCorrectAnswers,
      'totalQuestionsAnswered': _currentProgress.totalQuestionsAnswered,
      'totalGamesPlayed': _currentProgress.totalGamesPlayed,
      'totalScore': _currentProgress.totalScore,
      'accuracy': _currentProgress.accuracy,
      'averageScore': _currentProgress.averageScore,
      'currentRank': _currentProgress.currentRank,
      'highestLevel': _currentProgress.highestLevel,
      'longestStreak': _currentProgress.longestStreak,
      'dailyChallengeStreak': _currentProgress.dailyChallengeStreak,
      'unlockedAchievements': _currentProgress.unlockedAchievements.length,
      'totalAchievements': _currentProgress.achievements.length,
    };
  }

  /// Checks if this is the first time the app is launched
  Future<bool> isFirstLaunch() async {
    final isFirst = _prefs?.getBool(_firstLaunchKey) ?? true;
    if (isFirst) {
      await _prefs?.setBool(_firstLaunchKey, false);
    }
    return isFirst;
  }

  /// Gets the current player progress (async version for consistency)
  Future<PlayerProgress> getPlayerProgress() async {
    return _currentProgress;
  }

  /// Forces an immediate save of current progress
  Future<void> forceSave() async {
    await _saveProgressWithBackup();
  }

  /// Gets the last save timestamp
  DateTime? getLastSaveTime() {
    return _lastSaveTime;
  }

  /// Checks if there are unsaved changes
  bool hasUnsavedChanges() {
    return _hasUnsavedChanges;
  }

  /// Gets data integrity status
  Future<Map<String, dynamic>> getDataIntegrityStatus() async {
    try {
      final hasMainData = _prefs?.getString(_progressKey) != null;
      final hasBackup = _prefs?.getString(_backupKey) != null;
      final lastSaveString = _prefs?.getString(_lastSaveKey);
      final dataVersion = _prefs?.getInt(_dataVersionKey) ?? 0;

      DateTime? lastSave;
      if (lastSaveString != null) {
        try {
          lastSave = DateTime.parse(lastSaveString);
        } catch (e) {
          debugPrint('Error parsing last save time: $e');
        }
      }

      return {
        'hasMainData': hasMainData,
        'hasBackup': hasBackup,
        'lastSaveTime': lastSave?.toIso8601String(),
        'dataVersion': dataVersion,
        'currentVersion': _currentDataVersion,
        'hasUnsavedChanges': _hasUnsavedChanges,
        'isHealthy': hasMainData && dataVersion == _currentDataVersion,
      };
    } catch (e) {
      debugPrint('Error getting data integrity status: $e');
      return {
        'hasMainData': false,
        'hasBackup': false,
        'lastSaveTime': null,
        'dataVersion': 0,
        'currentVersion': _currentDataVersion,
        'hasUnsavedChanges': _hasUnsavedChanges,
        'isHealthy': false,
        'error': e.toString(),
      };
    }
  }

  /// Validates the current progress data
  bool validateProgressData() {
    try {
      // Basic validation checks
      if (_currentProgress.totalCorrectAnswers < 0 ||
          _currentProgress.totalQuestionsAnswered < 0 ||
          _currentProgress.totalGamesPlayed < 0 ||
          _currentProgress.totalScore < 0) {
        return false;
      }

      // Logical validation
      if (_currentProgress.totalCorrectAnswers >
          _currentProgress.totalQuestionsAnswered) {
        return false;
      }

      // Achievement validation
      for (final achievement in _currentProgress.achievements) {
        if (achievement.isUnlocked &&
            _currentProgress.totalCorrectAnswers <
                achievement.requiredCorrectAnswers) {
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error validating progress data: $e');
      return false;
    }
  }

  /// Repairs corrupted data if possible
  Future<bool> repairData() async {
    try {
      if (!validateProgressData()) {
        // Try to recover from backup first
        await _recoverFromBackup();

        if (!validateProgressData()) {
          // If backup is also corrupted, reset to initial state
          debugPrint('Data corruption detected, resetting to initial state');
          _currentProgress = PlayerProgress.initial();
          _hasUnsavedChanges = true;
          await _saveProgress();
          notifyListeners();
        }

        return true;
      }
      return true;
    } catch (e) {
      debugPrint('Error repairing data: $e');
      return false;
    }
  }

  /// Disposes of the service and saves any pending changes
  @override
  void dispose() {
    // Cancel the auto-save subscription
    _autoSaveSubscription?.cancel();
    _autoSaveSubscription = null;
    _autoSaveStream = null;

    if (_hasUnsavedChanges) {
      // Force save before disposing (fire and forget)
      _saveProgress();
    }
    super.dispose();
  }
}
