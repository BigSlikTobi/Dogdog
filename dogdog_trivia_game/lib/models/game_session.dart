import 'enums.dart';

/// Model for managing current game session state
class GameSession {
  /// Current active path being played
  final PathType? currentPath;

  /// Current lives remaining
  final int livesRemaining;

  /// Current question being answered
  final String? currentQuestionId;

  /// Questions answered in this session
  final List<String> sessionQuestionIds;

  /// Power-ups used in this session
  final Map<PowerUpType, int> powerUpsUsed;

  /// Session start time
  final DateTime sessionStart;

  /// Current streak of correct answers
  final int currentStreak;

  /// Best streak achieved in this session
  final int bestStreak;

  /// Whether the session is currently paused
  final bool isPaused;

  /// Time spent in current session (in seconds)
  final int sessionTimeSpent;

  const GameSession({
    this.currentPath,
    this.livesRemaining = 3,
    this.currentQuestionId,
    this.sessionQuestionIds = const [],
    this.powerUpsUsed = const {},
    required this.sessionStart,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.isPaused = false,
    this.sessionTimeSpent = 0,
  });

  /// Creates a GameSession from Map for storage
  factory GameSession.fromMap(Map<String, dynamic> map) {
    // Parse power-ups used
    final powerUpsMap = <PowerUpType, int>{};
    final powerUpData = map['powerUpsUsed'] as Map<String, dynamic>? ?? {};
    for (final entry in powerUpData.entries) {
      final powerUpType = PowerUpType.values.firstWhere(
        (p) => p.toString() == entry.key,
        orElse: () => PowerUpType.fiftyFifty,
      );
      powerUpsMap[powerUpType] = entry.value as int;
    }

    return GameSession(
      currentPath: map['currentPath'] != null
          ? PathType.values.firstWhere(
              (p) => p.toString() == map['currentPath'],
              orElse: () => PathType.dogBreeds,
            )
          : null,
      livesRemaining: map['livesRemaining'] ?? 3,
      currentQuestionId: map['currentQuestionId'],
      sessionQuestionIds: List<String>.from(map['sessionQuestionIds'] ?? []),
      powerUpsUsed: powerUpsMap,
      sessionStart: DateTime.fromMillisecondsSinceEpoch(
        map['sessionStart'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      currentStreak: map['currentStreak'] ?? 0,
      bestStreak: map['bestStreak'] ?? 0,
      isPaused: map['isPaused'] ?? false,
      sessionTimeSpent: map['sessionTimeSpent'] ?? 0,
    );
  }

  /// Converts GameSession to Map for storage
  Map<String, dynamic> toMap() {
    // Convert power-ups used to storable format
    final powerUpData = <String, dynamic>{};
    for (final entry in powerUpsUsed.entries) {
      powerUpData[entry.key.toString()] = entry.value;
    }

    return {
      'currentPath': currentPath?.toString(),
      'livesRemaining': livesRemaining,
      'currentQuestionId': currentQuestionId,
      'sessionQuestionIds': sessionQuestionIds,
      'powerUpsUsed': powerUpData,
      'sessionStart': sessionStart.millisecondsSinceEpoch,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'isPaused': isPaused,
      'sessionTimeSpent': sessionTimeSpent,
    };
  }

  /// Creates a copy with updated values
  GameSession copyWith({
    PathType? currentPath,
    int? livesRemaining,
    String? currentQuestionId,
    List<String>? sessionQuestionIds,
    Map<PowerUpType, int>? powerUpsUsed,
    DateTime? sessionStart,
    int? currentStreak,
    int? bestStreak,
    bool? isPaused,
    int? sessionTimeSpent,
  }) {
    return GameSession(
      currentPath: currentPath ?? this.currentPath,
      livesRemaining: livesRemaining ?? this.livesRemaining,
      currentQuestionId: currentQuestionId ?? this.currentQuestionId,
      sessionQuestionIds: sessionQuestionIds ?? this.sessionQuestionIds,
      powerUpsUsed: powerUpsUsed ?? this.powerUpsUsed,
      sessionStart: sessionStart ?? this.sessionStart,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      isPaused: isPaused ?? this.isPaused,
      sessionTimeSpent: sessionTimeSpent ?? this.sessionTimeSpent,
    );
  }

  /// Starts a new session for a path
  GameSession startNewSession(PathType pathType) {
    return GameSession(
      currentPath: pathType,
      livesRemaining: 3,
      sessionStart: DateTime.now(),
      sessionQuestionIds: const [],
      powerUpsUsed: const {},
      currentStreak: 0,
      bestStreak: 0,
      isPaused: false,
      sessionTimeSpent: 0,
    );
  }

  /// Adds a question to the session
  GameSession addSessionQuestion(String questionId) {
    final updatedQuestions = List<String>.from(sessionQuestionIds)
      ..add(questionId);

    return copyWith(
      currentQuestionId: questionId,
      sessionQuestionIds: updatedQuestions,
    );
  }

  /// Updates streak counters
  GameSession updateStreak(bool isCorrect) {
    if (isCorrect) {
      final newStreak = currentStreak + 1;
      return copyWith(
        currentStreak: newStreak,
        bestStreak: newStreak > bestStreak ? newStreak : bestStreak,
      );
    } else {
      return copyWith(currentStreak: 0);
    }
  }

  /// Uses a power-up in the session
  GameSession usePowerUp(PowerUpType powerUpType) {
    final updatedPowerUps = Map<PowerUpType, int>.from(powerUpsUsed);
    updatedPowerUps[powerUpType] = (updatedPowerUps[powerUpType] ?? 0) + 1;

    return copyWith(powerUpsUsed: updatedPowerUps);
  }

  /// Reduces lives
  GameSession loseLife() {
    return copyWith(livesRemaining: (livesRemaining - 1).clamp(0, 3));
  }

  /// Restores a life (for second chance power-up)
  GameSession gainLife() {
    return copyWith(livesRemaining: (livesRemaining + 1).clamp(0, 3));
  }

  /// Pauses/unpauses the session
  GameSession setPaused(bool paused) {
    return copyWith(isPaused: paused);
  }

  /// Updates session time
  GameSession updateSessionTime(int additionalSeconds) {
    return copyWith(sessionTimeSpent: sessionTimeSpent + additionalSeconds);
  }

  /// Checks if the session is game over
  bool get isGameOver => livesRemaining <= 0;

  /// Gets session statistics
  Map<String, dynamic> get sessionStats => {
    'questionsAnswered': sessionQuestionIds.length,
    'currentStreak': currentStreak,
    'bestStreak': bestStreak,
    'powerUpsUsed': powerUpsUsed.values.fold(0, (a, b) => a + b),
    'timeSpent': sessionTimeSpent,
    'livesRemaining': livesRemaining,
  };

  @override
  String toString() {
    return 'GameSession(path: $currentPath, lives: $livesRemaining, '
        'streak: $currentStreak, questions: ${sessionQuestionIds.length})';
  }
}
