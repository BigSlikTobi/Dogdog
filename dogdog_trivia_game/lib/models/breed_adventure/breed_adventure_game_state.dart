import 'difficulty_phase.dart';
import '../enums.dart';

/// Model representing the current state of a Dog Breeds Adventure game session
class BreedAdventureGameState {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final DifficultyPhase currentPhase;
  final Set<String> usedBreeds;
  final Map<PowerUpType, int> powerUps;
  final bool isGameActive;
  final DateTime? gameStartTime;
  final int consecutiveCorrect;
  final int timeRemaining;
  final String? currentHint;

  const BreedAdventureGameState({
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.currentPhase,
    required this.usedBreeds,
    required this.powerUps,
    required this.isGameActive,
    this.gameStartTime,
    this.consecutiveCorrect = 0,
    this.timeRemaining = 10,
    this.currentHint,
  });

  /// Creates an initial game state for starting a new game
  factory BreedAdventureGameState.initial() {
    return BreedAdventureGameState(
      score: 0,
      correctAnswers: 0,
      totalQuestions: 0,
      currentPhase: DifficultyPhase.beginner,
      usedBreeds: <String>{},
      powerUps: {PowerUpType.extraTime: 2, PowerUpType.skip: 1},
      isGameActive: false,
      gameStartTime: null,
      consecutiveCorrect: 0,
      timeRemaining: 10,
      currentHint: null,
    );
  }

  /// Creates a copy of this state with updated values
  BreedAdventureGameState copyWith({
    int? score,
    int? correctAnswers,
    int? totalQuestions,
    DifficultyPhase? currentPhase,
    Set<String>? usedBreeds,
    Map<PowerUpType, int>? powerUps,
    bool? isGameActive,
    DateTime? gameStartTime,
    int? consecutiveCorrect,
    int? timeRemaining,
    String? currentHint,
  }) {
    return BreedAdventureGameState(
      score: score ?? this.score,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      currentPhase: currentPhase ?? this.currentPhase,
      usedBreeds: usedBreeds ?? Set<String>.from(this.usedBreeds),
      powerUps: powerUps ?? Map<PowerUpType, int>.from(this.powerUps),
      isGameActive: isGameActive ?? this.isGameActive,
      gameStartTime: gameStartTime ?? this.gameStartTime,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      currentHint: currentHint ?? this.currentHint,
    );
  }

  /// Returns the accuracy percentage (0-100)
  double get accuracy {
    if (totalQuestions == 0) return 0.0;
    return (correctAnswers / totalQuestions) * 100;
  }

  /// Returns the current game duration in seconds
  int get gameDurationSeconds {
    if (gameStartTime == null) return 0;
    return DateTime.now().difference(gameStartTime!).inSeconds;
  }

  /// Returns true if the player should receive a power-up reward
  bool get shouldReceivePowerUpReward {
    return consecutiveCorrect > 0 && consecutiveCorrect % 5 == 0;
  }

  /// Returns the total number of power-ups available
  int get totalPowerUps {
    return powerUps.values.fold(0, (sum, count) => sum + count);
  }

  /// Returns true if the specified power-up is available
  bool hasPowerUp(PowerUpType powerUpType) {
    return (powerUps[powerUpType] ?? 0) > 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BreedAdventureGameState &&
        other.score == score &&
        other.correctAnswers == correctAnswers &&
        other.totalQuestions == totalQuestions &&
        other.currentPhase == currentPhase &&
        other.usedBreeds.length == usedBreeds.length &&
        other.usedBreeds.containsAll(usedBreeds) &&
        other.powerUps.length == powerUps.length &&
        other.isGameActive == isGameActive &&
        other.gameStartTime == gameStartTime &&
        other.consecutiveCorrect == consecutiveCorrect &&
        other.timeRemaining == timeRemaining;
  }

  @override
  int get hashCode => Object.hash(
    score,
    correctAnswers,
    totalQuestions,
    currentPhase,
    usedBreeds.length,
    powerUps.length,
    isGameActive,
    gameStartTime,
    consecutiveCorrect,
    timeRemaining,
  );

  /// Converts this state to a JSON map for persistence
  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'currentPhase': currentPhase.index,
      'usedBreeds': usedBreeds.toList(),
      'powerUps': powerUps.map(
        (key, value) => MapEntry(key.index.toString(), value),
      ),
      'isGameActive': isGameActive,
      'gameStartTime': gameStartTime?.millisecondsSinceEpoch,
      'consecutiveCorrect': consecutiveCorrect,
      'timeRemaining': timeRemaining,
      'currentHint': currentHint,
    };
  }

  /// Creates a game state from a JSON map
  factory BreedAdventureGameState.fromJson(Map<String, dynamic> json) {
    return BreedAdventureGameState(
      score: json['score'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      currentPhase: DifficultyPhase.values[json['currentPhase'] ?? 0],
      usedBreeds: Set<String>.from(json['usedBreeds'] ?? []),
      powerUps: _deserializePowerUps(json['powerUps']),
      isGameActive: json['isGameActive'] ?? false,
      gameStartTime: json['gameStartTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['gameStartTime'])
          : null,
      consecutiveCorrect: json['consecutiveCorrect'] ?? 0,
      timeRemaining: json['timeRemaining'] ?? 10,
      currentHint: json['currentHint'],
    );
  }

  /// Helper method to safely deserialize power-ups map
  static Map<PowerUpType, int> _deserializePowerUps(dynamic powerUpsJson) {
    if (powerUpsJson == null) {
      return {PowerUpType.extraTime: 2, PowerUpType.skip: 1}; // Default
    }

    final Map<PowerUpType, int> result = {};

    if (powerUpsJson is Map) {
      powerUpsJson.forEach((key, value) {
        try {
          final powerUpIndex = int.parse(key.toString());
          if (powerUpIndex >= 0 && powerUpIndex < PowerUpType.values.length) {
            result[PowerUpType.values[powerUpIndex]] = value as int? ?? 0;
          }
        } catch (e) {
          // Skip invalid entries
        }
      });
    }

    return result;
  }

  /// Validates the integrity of this game state
  bool isValid() {
    // Check for negative values
    if (score < 0 || correctAnswers < 0 || totalQuestions < 0) return false;

    // Check logical consistency
    if (correctAnswers > totalQuestions) return false;

    // Check consecutive correct makes sense
    if (consecutiveCorrect < 0) return false;

    // Check time remaining is reasonable
    if (timeRemaining < 0) return false;

    // Check power-ups are valid
    for (final count in powerUps.values) {
      if (count < 0) return false;
    }

    return true;
  }

  /// Creates a safe copy with validation
  BreedAdventureGameState copyWithValidation({
    int? score,
    int? correctAnswers,
    int? totalQuestions,
    DifficultyPhase? currentPhase,
    Set<String>? usedBreeds,
    Map<PowerUpType, int>? powerUps,
    bool? isGameActive,
    DateTime? gameStartTime,
    int? consecutiveCorrect,
    int? timeRemaining,
    String? currentHint,
  }) {
    final newState = copyWith(
      score: score,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      currentPhase: currentPhase,
      usedBreeds: usedBreeds,
      powerUps: powerUps,
      isGameActive: isGameActive,
      gameStartTime: gameStartTime,
      consecutiveCorrect: consecutiveCorrect,
      timeRemaining: timeRemaining,
      currentHint: currentHint,
    );

    if (!newState.isValid()) {
      throw StateError('Invalid game state created: $newState');
    }

    return newState;
  }

  @override
  String toString() {
    return 'BreedAdventureGameState(score: $score, correctAnswers: $correctAnswers, '
        'totalQuestions: $totalQuestions, currentPhase: $currentPhase, '
        'isGameActive: $isGameActive, consecutiveCorrect: $consecutiveCorrect)';
  }
}
