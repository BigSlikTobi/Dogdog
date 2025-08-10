import 'difficulty_phase.dart';
import 'enums.dart';

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
      powerUps: {
        PowerUpType.hint: 2,
        PowerUpType.extraTime: 2,
        PowerUpType.skip: 1,
        PowerUpType.secondChance: 1,
      },
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

  @override
  String toString() {
    return 'BreedAdventureGameState(score: $score, correctAnswers: $correctAnswers, '
        'totalQuestions: $totalQuestions, currentPhase: $currentPhase, '
        'isGameActive: $isGameActive, consecutiveCorrect: $consecutiveCorrect)';
  }
}
