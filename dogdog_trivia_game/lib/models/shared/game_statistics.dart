import '../breed_adventure/breed_adventure_game_state.dart';

/// Shared model for game statistics across all game modes
class GameStatistics {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final double accuracy;
  final int gameDuration;
  final int powerUpsUsed;
  final int livesRemaining;
  final int highScore;
  final bool isNewHighScore;
  final Map<String, dynamic> additionalStats;

  const GameStatistics({
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.accuracy,
    required this.gameDuration,
    required this.powerUpsUsed,
    required this.livesRemaining,
    required this.highScore,
    required this.isNewHighScore,
    this.additionalStats = const {},
  });

  /// Factory constructor for breed adventure game statistics
  factory GameStatistics.fromBreedAdventure(
    BreedAdventureGameState state,
    int highScore,
    int livesRemaining,
    int powerUpsUsed,
  ) {
    return GameStatistics(
      score: state.score,
      correctAnswers: state.correctAnswers,
      totalQuestions: state.totalQuestions,
      accuracy: state.accuracy,
      gameDuration: state.gameDurationSeconds,
      powerUpsUsed: powerUpsUsed,
      livesRemaining: livesRemaining,
      highScore: highScore,
      isNewHighScore: state.score == highScore && state.score > 0,
      additionalStats: {
        'currentPhase': state.currentPhase.name,
        'consecutiveCorrect': state.consecutiveCorrect,
        'usedBreedsCount': state.usedBreeds.length,
        'gameMode': 'breed_adventure',
      },
    );
  }

  /// Factory constructor for regular trivia game statistics
  factory GameStatistics.fromRegularTrivia({
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    required int gameDuration,
    required int powerUpsUsed,
    required int livesRemaining,
    required int highScore,
    Map<String, dynamic> additionalStats = const {},
  }) {
    final accuracy = totalQuestions > 0
        ? (correctAnswers / totalQuestions) * 100
        : 0.0;

    return GameStatistics(
      score: score,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      accuracy: accuracy,
      gameDuration: gameDuration,
      powerUpsUsed: powerUpsUsed,
      livesRemaining: livesRemaining,
      highScore: highScore,
      isNewHighScore: score == highScore && score > 0,
      additionalStats: {'gameMode': 'regular_trivia', ...additionalStats},
    );
  }

  /// Get formatted accuracy string
  String get formattedAccuracy => '${accuracy.toStringAsFixed(0)}%';

  /// Get formatted game duration
  String get formattedDuration {
    final minutes = gameDuration ~/ 60;
    final seconds = gameDuration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if this is a perfect game (100% accuracy)
  bool get isPerfectGame => accuracy >= 100.0 && totalQuestions > 0;

  /// Get the game mode from additional stats
  String get gameMode => additionalStats['gameMode'] as String? ?? 'unknown';

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'accuracy': accuracy,
      'gameDuration': gameDuration,
      'powerUpsUsed': powerUpsUsed,
      'livesRemaining': livesRemaining,
      'highScore': highScore,
      'isNewHighScore': isNewHighScore,
      'additionalStats': additionalStats,
    };
  }

  /// Create from JSON
  factory GameStatistics.fromJson(Map<String, dynamic> json) {
    return GameStatistics(
      score: json['score'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      gameDuration: json['gameDuration'] as int? ?? 0,
      powerUpsUsed: json['powerUpsUsed'] as int? ?? 0,
      livesRemaining: json['livesRemaining'] as int? ?? 0,
      highScore: json['highScore'] as int? ?? 0,
      isNewHighScore: json['isNewHighScore'] as bool? ?? false,
      additionalStats: json['additionalStats'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameStatistics &&
        other.score == score &&
        other.correctAnswers == correctAnswers &&
        other.totalQuestions == totalQuestions &&
        other.accuracy == accuracy &&
        other.gameDuration == gameDuration &&
        other.powerUpsUsed == powerUpsUsed &&
        other.livesRemaining == livesRemaining &&
        other.highScore == highScore &&
        other.isNewHighScore == isNewHighScore;
  }

  @override
  int get hashCode => Object.hash(
    score,
    correctAnswers,
    totalQuestions,
    accuracy,
    gameDuration,
    powerUpsUsed,
    livesRemaining,
    highScore,
    isNewHighScore,
  );

  @override
  String toString() {
    return 'GameStatistics(score: $score, correctAnswers: $correctAnswers, '
        'totalQuestions: $totalQuestions, accuracy: $formattedAccuracy, '
        'gameMode: $gameMode)';
  }
}
