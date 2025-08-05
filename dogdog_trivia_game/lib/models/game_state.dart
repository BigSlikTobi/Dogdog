import 'dart:convert';
import 'question.dart';
import 'enums.dart';

/// Model representing the current state of the game
class GameState {
  final int currentQuestionIndex;
  final int score;
  final int lives;
  final int streak;
  final int level;
  final List<Question> questions;
  final Map<PowerUpType, int> powerUps;
  final bool isGameActive;
  final int timeRemaining;
  final bool isTimerActive;
  final int totalQuestionsAnswered;
  final int correctAnswersInSession;
  final bool isShowingFeedback;
  final int? selectedAnswerIndex;
  final bool? lastAnswerWasCorrect;
  final List<int> disabledAnswerIndices;

  const GameState({
    required this.currentQuestionIndex,
    required this.score,
    required this.lives,
    required this.streak,
    required this.level,
    required this.questions,
    required this.powerUps,
    required this.isGameActive,
    required this.timeRemaining,
    this.isTimerActive = false,
    this.totalQuestionsAnswered = 0,
    this.correctAnswersInSession = 0,
    this.isShowingFeedback = false,
    this.selectedAnswerIndex,
    this.lastAnswerWasCorrect,
    this.disabledAnswerIndices = const [],
  });

  /// Creates an initial game state
  factory GameState.initial() {
    return GameState(
      currentQuestionIndex: 0,
      score: 0,
      lives: 3,
      streak: 0,
      level: 1,
      questions: [],
      powerUps: {for (PowerUpType type in PowerUpType.values) type: 0},
      isGameActive: false,
      timeRemaining: 0,
      isTimerActive: false,
      totalQuestionsAnswered: 0,
      correctAnswersInSession: 0,
      isShowingFeedback: false,
      selectedAnswerIndex: null,
      lastAnswerWasCorrect: null,
      disabledAnswerIndices: [],
    );
  }

  /// Returns the current question if available
  Question? get currentQuestion {
    if (currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }

  /// Returns true if the game is over (no lives remaining)
  bool get isGameOver => lives <= 0;

  /// Returns true if there are more questions to answer
  bool get hasMoreQuestions => currentQuestionIndex < questions.length;

  /// Returns the score multiplier based on current streak
  int get scoreMultiplier {
    if (streak >= 5) {
      return 2;
    }
    return 1;
  }

  /// Returns the time limit for the current level
  int get timeLimitForLevel {
    switch (level) {
      case 1:
        return 0; // No timer for level 1
      case 2:
        return 20;
      case 3:
        return 15;
      case 4:
        return 12;
      case 5:
      default:
        return 10;
    }
  }

  /// Returns the starting lives for the current level
  int get startingLivesForLevel {
    if (level >= 5) {
      return 2;
    }
    return 3;
  }

  /// Creates a GameState from a JSON map
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      currentQuestionIndex: json['currentQuestionIndex'] as int,
      score: json['score'] as int,
      lives: json['lives'] as int,
      streak: json['streak'] as int,
      level: json['level'] as int,
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
      powerUps: Map<PowerUpType, int>.from(
        (json['powerUps'] as Map).map(
          (key, value) => MapEntry(
            PowerUpType.values.firstWhere((type) => type.name == key),
            value as int,
          ),
        ),
      ),
      isGameActive: json['isGameActive'] as bool,
      timeRemaining: json['timeRemaining'] as int,
      isTimerActive: json['isTimerActive'] as bool? ?? false,
      totalQuestionsAnswered: json['totalQuestionsAnswered'] as int? ?? 0,
      correctAnswersInSession: json['correctAnswersInSession'] as int? ?? 0,
      isShowingFeedback: json['isShowingFeedback'] as bool? ?? false,
      selectedAnswerIndex: json['selectedAnswerIndex'] as int?,
      lastAnswerWasCorrect: json['lastAnswerWasCorrect'] as bool?,
      disabledAnswerIndices:
          (json['disabledAnswerIndices'] as List?)?.cast<int>() ?? [],
    );
  }

  /// Converts the GameState to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'currentQuestionIndex': currentQuestionIndex,
      'score': score,
      'lives': lives,
      'streak': streak,
      'level': level,
      'questions': questions.map((q) => q.toJson()).toList(),
      'powerUps': powerUps.map((key, value) => MapEntry(key.name, value)),
      'isGameActive': isGameActive,
      'timeRemaining': timeRemaining,
      'isTimerActive': isTimerActive,
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'correctAnswersInSession': correctAnswersInSession,
      'isShowingFeedback': isShowingFeedback,
      'selectedAnswerIndex': selectedAnswerIndex,
      'lastAnswerWasCorrect': lastAnswerWasCorrect,
      'disabledAnswerIndices': disabledAnswerIndices,
    };
  }

  /// Creates a GameState from a JSON string
  factory GameState.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return GameState.fromJson(json);
  }

  /// Converts the GameState to a JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Creates a copy of this GameState with optional parameter overrides
  GameState copyWith({
    int? currentQuestionIndex,
    int? score,
    int? lives,
    int? streak,
    int? level,
    List<Question>? questions,
    Map<PowerUpType, int>? powerUps,
    bool? isGameActive,
    int? timeRemaining,
    bool? isTimerActive,
    int? totalQuestionsAnswered,
    int? correctAnswersInSession,
    bool? isShowingFeedback,
    int? selectedAnswerIndex,
    bool? lastAnswerWasCorrect,
    List<int>? disabledAnswerIndices,
  }) {
    return GameState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      lives: lives ?? this.lives,
      streak: streak ?? this.streak,
      level: level ?? this.level,
      questions: questions ?? this.questions,
      powerUps: powerUps ?? this.powerUps,
      isGameActive: isGameActive ?? this.isGameActive,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isTimerActive: isTimerActive ?? this.isTimerActive,
      totalQuestionsAnswered:
          totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      correctAnswersInSession:
          correctAnswersInSession ?? this.correctAnswersInSession,
      isShowingFeedback: isShowingFeedback ?? this.isShowingFeedback,
      selectedAnswerIndex: selectedAnswerIndex ?? this.selectedAnswerIndex,
      lastAnswerWasCorrect: lastAnswerWasCorrect ?? this.lastAnswerWasCorrect,
      disabledAnswerIndices:
          disabledAnswerIndices ?? this.disabledAnswerIndices,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameState) return false;
    return currentQuestionIndex == other.currentQuestionIndex &&
        score == other.score &&
        lives == other.lives &&
        streak == other.streak &&
        level == other.level &&
        questions.length == other.questions.length &&
        powerUps.length == other.powerUps.length &&
        isGameActive == other.isGameActive &&
        timeRemaining == other.timeRemaining &&
        isTimerActive == other.isTimerActive &&
        totalQuestionsAnswered == other.totalQuestionsAnswered &&
        correctAnswersInSession == other.correctAnswersInSession;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentQuestionIndex,
      score,
      lives,
      streak,
      level,
      questions.length,
      powerUps.length,
      isGameActive,
      timeRemaining,
      isTimerActive,
      totalQuestionsAnswered,
      correctAnswersInSession,
    );
  }

  @override
  String toString() {
    return 'GameState(level: $level, score: $score, lives: $lives, streak: $streak, '
        'currentQuestion: $currentQuestionIndex/${questions.length}, active: $isGameActive)';
  }
}
