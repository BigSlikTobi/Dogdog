import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enums.dart';
import '../models/path_progress.dart';
import '../models/game_session.dart';

/// Service for persisting game progress and session data
class GamePersistenceService {
  static const String _pathProgressPrefix = 'path_progress_';
  static const String _currentSessionKey = 'current_session';
  static const String _globalStatsKey = 'global_stats';
  static const String _settingsKey = 'game_settings';
  static const String _breedAdventureHighScoreKey =
      'breed_adventure_high_score';

  SharedPreferences? _prefs;

  /// Initialize the persistence service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Saves path progress for a specific path
  Future<void> savePathProgress(PathProgress progress) async {
    await _ensureInitialized();
    final key = _pathProgressPrefix + progress.pathType.toString();
    final json = jsonEncode(progress.toMap());
    await _prefs!.setString(key, json);
  }

  /// Loads path progress for a specific path
  Future<PathProgress?> loadPathProgress(PathType pathType) async {
    await _ensureInitialized();
    final key = _pathProgressPrefix + pathType.toString();
    final json = _prefs!.getString(key);

    if (json == null) return null;

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return PathProgress.fromMap(map);
    } catch (e) {
      // If data is corrupted, return null and let the app create new progress
      return null;
    }
  }

  /// Loads progress for all paths
  Future<Map<PathType, PathProgress>> loadAllPathProgress() async {
    await _ensureInitialized();
    final progressMap = <PathType, PathProgress>{};

    for (final pathType in PathType.values) {
      final progress = await loadPathProgress(pathType);
      if (progress != null) {
        progressMap[pathType] = progress;
      }
    }

    return progressMap;
  }

  /// Creates default progress for a path if none exists
  PathProgress createDefaultProgress(PathType pathType) {
    return PathProgress(pathType: pathType, lastPlayed: DateTime.now());
  }

  /// Gets or creates path progress
  Future<PathProgress> getOrCreatePathProgress(PathType pathType) async {
    final existing = await loadPathProgress(pathType);
    if (existing != null) return existing;

    final defaultProgress = createDefaultProgress(pathType);
    await savePathProgress(defaultProgress);
    return defaultProgress;
  }

  /// Saves current game session
  Future<void> saveGameSession(GameSession session) async {
    await _ensureInitialized();
    final json = jsonEncode(session.toMap());
    await _prefs!.setString(_currentSessionKey, json);
  }

  /// Loads current game session
  Future<GameSession?> loadGameSession() async {
    await _ensureInitialized();
    final json = _prefs!.getString(_currentSessionKey);

    if (json == null) return null;

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return GameSession.fromMap(map);
    } catch (e) {
      // If data is corrupted, return null
      return null;
    }
  }

  /// Clears current game session
  Future<void> clearGameSession() async {
    await _ensureInitialized();
    await _prefs!.remove(_currentSessionKey);
  }

  /// Saves the high score for the breed adventure game
  Future<void> saveBreedAdventureHighScore(int score) async {
    await _ensureInitialized();
    await _prefs!.setInt(_breedAdventureHighScoreKey, score);
  }

  /// Loads the high score for the breed adventure game
  Future<int> getBreedAdventureHighScore() async {
    await _ensureInitialized();
    return _prefs!.getInt(_breedAdventureHighScoreKey) ?? 0;
  }

  /// Saves global game statistics
  Future<void> saveGlobalStats(Map<String, dynamic> stats) async {
    await _ensureInitialized();
    final json = jsonEncode(stats);
    await _prefs!.setString(_globalStatsKey, json);
  }

  /// Loads global game statistics
  Future<Map<String, dynamic>> loadGlobalStats() async {
    await _ensureInitialized();
    final json = _prefs!.getString(_globalStatsKey);

    if (json == null) return _createDefaultGlobalStats();

    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      return _createDefaultGlobalStats();
    }
  }

  /// Creates default global statistics
  Map<String, dynamic> _createDefaultGlobalStats() {
    return {
      'totalQuestionsAnswered': 0,
      'totalCorrectAnswers': 0,
      'totalTimeSpent': 0,
      'totalGameSessions': 0,
      'pathsCompleted': 0,
      'bestOverallAccuracy': 0.0,
      'longestStreak': 0,
      'favoritePathType': PathType.dogTrivia.toString(),
      'lastPlayDate': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Updates global statistics with session data
  Future<void> updateGlobalStats({
    required int questionsAnswered,
    required int correctAnswers,
    required int timeSpent,
    required int bestStreak,
    required PathType pathPlayed,
    bool? pathCompleted,
  }) async {
    final stats = await loadGlobalStats();

    stats['totalQuestionsAnswered'] =
        (stats['totalQuestionsAnswered'] ?? 0) + questionsAnswered;
    stats['totalCorrectAnswers'] =
        (stats['totalCorrectAnswers'] ?? 0) + correctAnswers;
    stats['totalTimeSpent'] = (stats['totalTimeSpent'] ?? 0) + timeSpent;
    stats['totalGameSessions'] = (stats['totalGameSessions'] ?? 0) + 1;

    if (pathCompleted == true) {
      stats['pathsCompleted'] = (stats['pathsCompleted'] ?? 0) + 1;
    }

    // Update best accuracy
    final totalQuestions = stats['totalQuestionsAnswered'];
    final totalCorrect = stats['totalCorrectAnswers'];
    if (totalQuestions > 0) {
      final currentAccuracy = (totalCorrect / totalQuestions) * 100;
      stats['bestOverallAccuracy'] = currentAccuracy;
    }

    // Update longest streak
    final currentLongest = stats['longestStreak'] ?? 0;
    if (bestStreak > currentLongest) {
      stats['longestStreak'] = bestStreak;
    }

    // Update favorite path (most played)
    final pathKey = 'pathPlayCount_${pathPlayed.toString()}';
    stats[pathKey] = (stats[pathKey] ?? 0) + 1;

    // Determine favorite path
    PathType? favoritePath;
    int maxPlayCount = 0;
    for (final pathType in PathType.values) {
      final playCount = stats['pathPlayCount_${pathType.toString()}'] ?? 0;
      if (playCount > maxPlayCount) {
        maxPlayCount = playCount;
        favoritePath = pathType;
      }
    }
    if (favoritePath != null) {
      stats['favoritePathType'] = favoritePath.toString();
    }

    stats['lastPlayDate'] = DateTime.now().millisecondsSinceEpoch;

    await saveGlobalStats(stats);
  }

  /// Saves game settings
  Future<void> saveGameSettings(Map<String, dynamic> settings) async {
    await _ensureInitialized();
    final json = jsonEncode(settings);
    await _prefs!.setString(_settingsKey, json);
  }

  /// Loads game settings
  Future<Map<String, dynamic>> loadGameSettings() async {
    await _ensureInitialized();
    final json = _prefs!.getString(_settingsKey);

    if (json == null) return _createDefaultSettings();

    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      return _createDefaultSettings();
    }
  }

  /// Creates default game settings
  Map<String, dynamic> _createDefaultSettings() {
    return {
      'soundEnabled': true,
      'musicEnabled': true,
      'hapticFeedbackEnabled': true,
      'animationsEnabled': true,
      'difficulty': Difficulty.medium.toString(),
      'language': 'de',
      'tutorialCompleted': false,
    };
  }

  /// Migrates old save data to new checkpoint system
  Future<void> migrateOldSaveData() async {
    await _ensureInitialized();

    // Check if migration has already been done
    final migrationKey = 'checkpoint_migration_v1';
    if (_prefs!.getBool(migrationKey) == true) {
      return; // Already migrated
    }

    // Look for old progress data and convert it
    // This is a placeholder for actual migration logic
    // In a real scenario, you'd read old format data and convert it

    // Mark migration as complete
    await _prefs!.setBool(migrationKey, true);
  }

  /// Clears all saved data (for testing or reset)
  Future<void> clearAllData() async {
    await _ensureInitialized();
    await _prefs!.clear();
  }

  /// Gets storage size information
  Future<Map<String, int>> getStorageInfo() async {
    await _ensureInitialized();
    final keys = _prefs!.getKeys();

    int pathProgressCount = 0;
    int totalSize = 0;

    for (final key in keys) {
      if (key.startsWith(_pathProgressPrefix)) {
        pathProgressCount++;
      }

      final value = _prefs!.get(key);
      if (value is String) {
        totalSize += value.length;
      }
    }

    return {
      'pathProgressCount': pathProgressCount,
      'totalKeys': keys.length,
      'estimatedSizeBytes': totalSize,
    };
  }

  /// Ensures the service is initialized
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }
}
