import 'enums.dart';

/// Model for storing path completion progress and statistics
class PathProgress {
  /// The path this progress belongs to
  final PathType pathType;

  /// Current checkpoint reached (last completed checkpoint)
  final Checkpoint currentCheckpoint;

  /// List of answered question IDs to prevent repeats
  final List<String> answeredQuestionIds;

  /// Power-ups earned and available for this path
  final Map<PowerUpType, int> powerUpInventory;

  /// Questions answered correctly in current session
  final int correctAnswers;

  /// Total questions attempted in current session
  final int totalQuestions;

  /// Best accuracy achieved on this path
  final double bestAccuracy;

  /// Total time spent on this path (in seconds)
  final int totalTimeSpent;

  /// Number of times checkpoint fallback was used
  final int fallbackCount;

  /// Timestamp of last play session
  final DateTime lastPlayed;

  /// Whether this path has been completed (reached Deutsche Dogge)
  final bool isCompleted;

  const PathProgress({
    required this.pathType,
    this.currentCheckpoint = Checkpoint.chihuahua,
    this.answeredQuestionIds = const [],
    this.powerUpInventory = const {},
    this.correctAnswers = 0,
    this.totalQuestions = 0,
    this.bestAccuracy = 0.0,
    this.totalTimeSpent = 0,
    this.fallbackCount = 0,
    required this.lastPlayed,
    this.isCompleted = false,
  });

  /// Creates a PathProgress from JSON-like Map
  factory PathProgress.fromMap(Map<String, dynamic> map) {
    // Parse power-up inventory
    final powerUpMap = <PowerUpType, int>{};
    final powerUpData = map['powerUpInventory'] as Map<String, dynamic>? ?? {};
    for (final entry in powerUpData.entries) {
      // Only add valid power-up types
      for (final powerUpType in PowerUpType.values) {
        if (powerUpType.toString() == entry.key) {
          powerUpMap[powerUpType] = entry.value as int;
          break;
        }
      }
    }

    return PathProgress(
      pathType: PathType.values.firstWhere(
        (p) => p.toString() == map['pathType'],
        orElse: () => PathType.dogBreeds,
      ),
      currentCheckpoint: Checkpoint.values.firstWhere(
        (c) => c.toString() == map['currentCheckpoint'],
        orElse: () => Checkpoint.chihuahua,
      ),
      answeredQuestionIds: List<String>.from(map['answeredQuestionIds'] ?? []),
      powerUpInventory: powerUpMap,
      correctAnswers: map['correctAnswers'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      bestAccuracy: (map['bestAccuracy'] ?? 0.0).toDouble(),
      totalTimeSpent: map['totalTimeSpent'] ?? 0,
      fallbackCount: map['fallbackCount'] ?? 0,
      lastPlayed: DateTime.fromMillisecondsSinceEpoch(
        map['lastPlayed'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  /// Converts PathProgress to Map for storage
  Map<String, dynamic> toMap() {
    // Convert power-up inventory to storable format
    final powerUpData = <String, dynamic>{};
    for (final entry in powerUpInventory.entries) {
      powerUpData[entry.key.toString()] = entry.value;
    }

    return {
      'pathType': pathType.toString(),
      'currentCheckpoint': currentCheckpoint.toString(),
      'answeredQuestionIds': answeredQuestionIds,
      'powerUpInventory': powerUpData,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'bestAccuracy': bestAccuracy,
      'totalTimeSpent': totalTimeSpent,
      'fallbackCount': fallbackCount,
      'lastPlayed': lastPlayed.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
    };
  }

  /// Creates a copy with updated values
  PathProgress copyWith({
    PathType? pathType,
    Checkpoint? currentCheckpoint,
    List<String>? answeredQuestionIds,
    Map<PowerUpType, int>? powerUpInventory,
    int? correctAnswers,
    int? totalQuestions,
    double? bestAccuracy,
    int? totalTimeSpent,
    int? fallbackCount,
    DateTime? lastPlayed,
    bool? isCompleted,
  }) {
    return PathProgress(
      pathType: pathType ?? this.pathType,
      currentCheckpoint: currentCheckpoint ?? this.currentCheckpoint,
      answeredQuestionIds: answeredQuestionIds ?? this.answeredQuestionIds,
      powerUpInventory: powerUpInventory ?? this.powerUpInventory,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      bestAccuracy: bestAccuracy ?? this.bestAccuracy,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      fallbackCount: fallbackCount ?? this.fallbackCount,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Calculates current accuracy percentage
  double get currentAccuracy {
    if (totalQuestions == 0) return 0.0;
    return (correctAnswers / totalQuestions) * 100;
  }

  /// Gets the next checkpoint to reach
  Checkpoint get nextCheckpoint {
    final checkpoints = Checkpoint.values;
    final currentIndex = checkpoints.indexOf(currentCheckpoint);

    if (currentIndex >= checkpoints.length - 1) {
      return currentCheckpoint; // Already at final checkpoint
    }

    return checkpoints[currentIndex + 1];
  }

  /// Checks if a question has been answered
  bool hasAnsweredQuestion(String questionId) {
    return answeredQuestionIds.contains(questionId);
  }

  /// Adds a question to the answered list
  PathProgress addAnsweredQuestion(String questionId) {
    if (hasAnsweredQuestion(questionId)) return this;

    final updatedIds = List<String>.from(answeredQuestionIds)..add(questionId);
    return copyWith(answeredQuestionIds: updatedIds);
  }

  /// Adds power-ups to inventory
  PathProgress addPowerUps(Map<PowerUpType, int> newPowerUps) {
    final updatedInventory = Map<PowerUpType, int>.from(powerUpInventory);

    for (final entry in newPowerUps.entries) {
      updatedInventory[entry.key] =
          (updatedInventory[entry.key] ?? 0) + entry.value;
    }

    return copyWith(powerUpInventory: updatedInventory);
  }

  /// Uses a power-up (decrements count)
  PathProgress usePowerUp(PowerUpType powerUpType) {
    final currentCount = powerUpInventory[powerUpType] ?? 0;
    if (currentCount <= 0) return this;

    final updatedInventory = Map<PowerUpType, int>.from(powerUpInventory);
    updatedInventory[powerUpType] = currentCount - 1;

    return copyWith(powerUpInventory: updatedInventory);
  }

  /// Advances to next checkpoint
  PathProgress advanceCheckpoint() {
    final nextCp = nextCheckpoint;
    final isNowCompleted = nextCp == Checkpoint.deutscheDogge;

    return copyWith(
      currentCheckpoint: nextCp,
      isCompleted: isNowCompleted,
      lastPlayed: DateTime.now(),
    );
  }

  /// Updates session statistics
  PathProgress updateSessionStats({
    required int correctAnswers,
    required int totalQuestions,
    required int timeSpent,
  }) {
    final newTotalQuestions = this.totalQuestions + totalQuestions;
    final newCorrectAnswers = this.correctAnswers + correctAnswers;
    final newAccuracy = newTotalQuestions > 0
        ? (newCorrectAnswers / newTotalQuestions) * 100
        : 0.0;

    return copyWith(
      correctAnswers: newCorrectAnswers,
      totalQuestions: newTotalQuestions,
      bestAccuracy: newAccuracy > bestAccuracy ? newAccuracy : bestAccuracy,
      totalTimeSpent: totalTimeSpent + timeSpent,
      lastPlayed: DateTime.now(),
    );
  }

  /// Resets progress to last checkpoint (for fallback)
  PathProgress resetToCheckpoint() {
    return copyWith(
      fallbackCount: fallbackCount + 1,
      lastPlayed: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'PathProgress(path: $pathType, checkpoint: $currentCheckpoint, '
        'accuracy: ${currentAccuracy.toStringAsFixed(1)}%, '
        'completed: $isCompleted)';
  }
}
