import 'enums.dart';

/// Model representing progress within a specific question category
class CategoryProgress {
  final QuestionCategory category;
  final int questionsAnswered;
  final int correctAnswers;
  final Set<Checkpoint> completedCheckpoints;
  final Checkpoint? lastCompletedCheckpoint;
  final DateTime lastPlayedAt;
  final int totalScore;
  final List<String> usedQuestionIds;

  const CategoryProgress({
    required this.category,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.completedCheckpoints = const {},
    this.lastCompletedCheckpoint,
    required this.lastPlayedAt,
    this.totalScore = 0,
    this.usedQuestionIds = const [],
  });

  /// Creates a new CategoryProgress with default values
  factory CategoryProgress.initial(QuestionCategory category) {
    return CategoryProgress(category: category, lastPlayedAt: DateTime.now());
  }

  /// Creates a copy with updated values
  CategoryProgress copyWith({
    QuestionCategory? category,
    int? questionsAnswered,
    int? correctAnswers,
    Set<Checkpoint>? completedCheckpoints,
    Checkpoint? lastCompletedCheckpoint,
    DateTime? lastPlayedAt,
    int? totalScore,
    List<String>? usedQuestionIds,
  }) {
    return CategoryProgress(
      category: category ?? this.category,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      completedCheckpoints: completedCheckpoints ?? this.completedCheckpoints,
      lastCompletedCheckpoint:
          lastCompletedCheckpoint ?? this.lastCompletedCheckpoint,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      totalScore: totalScore ?? this.totalScore,
      usedQuestionIds: usedQuestionIds ?? this.usedQuestionIds,
    );
  }

  /// Calculates accuracy percentage
  double get accuracy {
    if (questionsAnswered == 0) return 0.0;
    return (correctAnswers / questionsAnswered).clamp(0.0, 1.0);
  }

  /// Gets the next checkpoint to reach
  Checkpoint? get nextCheckpoint {
    for (final checkpoint in Checkpoint.values) {
      if (!completedCheckpoints.contains(checkpoint)) {
        return checkpoint;
      }
    }
    return null; // All checkpoints completed
  }

  /// Gets questions remaining to next checkpoint
  int get questionsToNextCheckpoint {
    final next = nextCheckpoint;
    if (next == null) return 0;
    return (next.questionsRequired - questionsAnswered).clamp(
      0,
      next.questionsRequired,
    );
  }

  /// Gets progress percentage to next checkpoint (0.0 to 1.0)
  double get progressToNextCheckpoint {
    final next = nextCheckpoint;
    if (next == null) return 1.0;

    final previousCheckpointQuestions =
        lastCompletedCheckpoint?.questionsRequired ?? 0;
    final questionsInCurrentSegment =
        questionsAnswered - previousCheckpointQuestions;
    final questionsNeededForSegment =
        next.questionsRequired - previousCheckpointQuestions;

    if (questionsNeededForSegment <= 0) return 1.0;
    return (questionsInCurrentSegment / questionsNeededForSegment).clamp(
      0.0,
      1.0,
    );
  }

  /// Checks if the category is completed (all checkpoints reached)
  bool get isCompleted =>
      completedCheckpoints.length == Checkpoint.values.length;

  /// Gets the current segment display text
  String get currentSegmentDisplay {
    final next = nextCheckpoint;
    if (next == null) {
      return 'Category Completed!';
    }

    final previousQuestions = lastCompletedCheckpoint?.questionsRequired ?? 0;
    final questionsInSegment = questionsAnswered - previousQuestions;
    final questionsNeeded = next.questionsRequired - previousQuestions;

    return '$questionsInSegment/$questionsNeeded questions to ${next.displayName}';
  }

  /// Converts to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'questionsAnswered': questionsAnswered,
      'correctAnswers': correctAnswers,
      'completedCheckpoints': completedCheckpoints.map((c) => c.name).toList(),
      'lastCompletedCheckpoint': lastCompletedCheckpoint?.name,
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
      'totalScore': totalScore,
      'usedQuestionIds': usedQuestionIds,
    };
  }

  /// Creates from JSON for persistence
  factory CategoryProgress.fromJson(Map<String, dynamic> json) {
    return CategoryProgress(
      category: QuestionCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => QuestionCategory.dogBreeds,
      ),
      questionsAnswered: json['questionsAnswered'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      completedCheckpoints:
          (json['completedCheckpoints'] as List?)
              ?.map(
                (name) => Checkpoint.values.firstWhere(
                  (c) => c.name == name,
                  orElse: () => Checkpoint.chihuahua,
                ),
              )
              .toSet() ??
          {},
      lastCompletedCheckpoint: json['lastCompletedCheckpoint'] != null
          ? Checkpoint.values.firstWhere(
              (c) => c.name == json['lastCompletedCheckpoint'],
              orElse: () => Checkpoint.chihuahua,
            )
          : null,
      lastPlayedAt:
          DateTime.tryParse(json['lastPlayedAt'] as String? ?? '') ??
          DateTime.now(),
      totalScore: json['totalScore'] as int? ?? 0,
      usedQuestionIds: List<String>.from(
        json['usedQuestionIds'] as List? ?? [],
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryProgress &&
        other.category == category &&
        other.questionsAnswered == questionsAnswered &&
        other.correctAnswers == correctAnswers;
  }

  @override
  int get hashCode {
    return Object.hash(category, questionsAnswered, correctAnswers);
  }

  @override
  String toString() {
    return 'CategoryProgress('
        'category: $category, '
        'questions: $questionsAnswered, '
        'correct: $correctAnswers, '
        'accuracy: ${(accuracy * 100).toStringAsFixed(1)}%'
        ')';
  }
}
