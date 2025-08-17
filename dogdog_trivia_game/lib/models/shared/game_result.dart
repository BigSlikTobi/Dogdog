import 'game_statistics.dart';
import '../achievement.dart';
import '../enums.dart';

/// Shared model for game completion results across all game modes
class GameSession {
  final GameStatistics statistics;
  final GameMode gameMode;
  final DateTime completedAt;
  final List<Achievement> achievementsUnlocked;
  final Map<String, dynamic> modeSpecificData;

  const GameSession({
    required this.statistics,
    required this.gameMode,
    required this.completedAt,
    this.achievementsUnlocked = const [],
    this.modeSpecificData = const {},
  });

  /// Factory constructor for breed adventure results
  factory GameSession.fromBreedAdventure({
    required GameStatistics statistics,
    required DateTime completedAt,
    List<Achievement> achievementsUnlocked = const [],
    String? currentPhase,
    int? usedBreedsCount,
    int? consecutiveCorrect,
  }) {
    return GameSession(
      statistics: statistics,
      gameMode: GameMode.breedAdventure,
      completedAt: completedAt,
      achievementsUnlocked: achievementsUnlocked,
      modeSpecificData: {
        'currentPhase': currentPhase,
        'usedBreedsCount': usedBreedsCount,
        'consecutiveCorrect': consecutiveCorrect,
      },
    );
  }

  /// Factory constructor for regular trivia results
  factory GameSession.fromRegularTrivia({
    required GameStatistics statistics,
    required DateTime completedAt,
    List<Achievement> achievementsUnlocked = const [],
    String? category,
    String? difficulty,
  }) {
    return GameSession(
      statistics: statistics,
      gameMode: GameMode.classicTrivia,
      completedAt: completedAt,
      achievementsUnlocked: achievementsUnlocked,
      modeSpecificData: {'category': category, 'difficulty': difficulty},
    );
  }

  /// Check if this is a high score result
  bool get isHighScore => statistics.isNewHighScore;

  /// Check if this is a perfect game result
  bool get isPerfectGame => statistics.isPerfectGame;

  /// Get celebration messages based on performance
  List<String> get celebrationMessages {
    final messages = <String>[];

    if (isHighScore) {
      messages.add('New High Score!');
    }

    if (isPerfectGame) {
      messages.add('Perfect Game!');
    }

    if (statistics.accuracy >= 90) {
      messages.add('Excellent Performance!');
    } else if (statistics.accuracy >= 75) {
      messages.add('Great Job!');
    } else if (statistics.accuracy >= 50) {
      messages.add('Good Effort!');
    }

    if (achievementsUnlocked.isNotEmpty) {
      messages.add(
        '${achievementsUnlocked.length} Achievement${achievementsUnlocked.length > 1 ? 's' : ''} Unlocked!',
      );
    }

    return messages.isEmpty ? ['Game Complete!'] : messages;
  }

  /// Get the primary celebration message
  String get primaryCelebrationMessage {
    final messages = celebrationMessages;
    return messages.isNotEmpty ? messages.first : 'Game Complete!';
  }

  /// Get mode-specific display data
  Map<String, String> get displayData {
    switch (gameMode) {
      case GameMode.breedAdventure:
        return {
          'Phase': modeSpecificData['currentPhase']?.toString() ?? 'Unknown',
          'Breeds Seen': modeSpecificData['usedBreedsCount']?.toString() ?? '0',
          'Best Streak':
              modeSpecificData['consecutiveCorrect']?.toString() ?? '0',
        };
      case GameMode.classicTrivia:
        return {
          'Category': modeSpecificData['category']?.toString() ?? 'Mixed',
          'Difficulty': modeSpecificData['difficulty']?.toString() ?? 'Normal',
        };
      case GameMode.treasureMap:
        return {
          'Map': modeSpecificData['mapName']?.toString() ?? 'Unknown',
          'Treasures': modeSpecificData['treasuresFound']?.toString() ?? '0',
        };
    }
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'statistics': statistics.toJson(),
      'gameMode': gameMode.name,
      'completedAt': completedAt.toIso8601String(),
      'achievementsUnlocked': achievementsUnlocked
          .map((a) => a.toJson())
          .toList(),
      'modeSpecificData': modeSpecificData,
    };
  }

  /// Create from JSON
  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      statistics: GameStatistics.fromJson(
        json['statistics'] as Map<String, dynamic>,
      ),
      gameMode: GameMode.values.firstWhere(
        (mode) => mode.name == json['gameMode'],
        orElse: () => GameMode.classicTrivia,
      ),
      completedAt: DateTime.parse(json['completedAt'] as String),
      achievementsUnlocked:
          (json['achievementsUnlocked'] as List<dynamic>?)
              ?.map((a) => Achievement.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      modeSpecificData: json['modeSpecificData'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameSession &&
        other.statistics == statistics &&
        other.gameMode == gameMode &&
        other.completedAt == completedAt &&
        other.achievementsUnlocked.length == achievementsUnlocked.length &&
        other.modeSpecificData.length == modeSpecificData.length;
  }

  @override
  int get hashCode => Object.hash(
    statistics,
    gameMode,
    completedAt,
    achievementsUnlocked.length,
    modeSpecificData.length,
  );

  @override
  String toString() {
    return 'GameSession(gameMode: $gameMode, score: ${statistics.score}, '
        'accuracy: ${statistics.formattedAccuracy}, completedAt: $completedAt)';
  }
}
