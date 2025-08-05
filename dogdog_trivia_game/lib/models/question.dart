import 'dart:convert';
import 'enums.dart';

/// Model representing a trivia question about dogs
class Question {
  final String id;
  final String text;
  final List<String> answers;
  final int correctAnswerIndex;
  final String funFact;
  final Difficulty difficulty;
  final String category;
  final String? hint;

  const Question({
    required this.id,
    required this.text,
    required this.answers,
    required this.correctAnswerIndex,
    required this.funFact,
    required this.difficulty,
    required this.category,
    this.hint,
  });

  /// Returns the correct answer text
  String get correctAnswer => answers[correctAnswerIndex];

  /// Returns the points awarded for answering this question correctly
  int get points => difficulty.points;

  /// Creates a Question from a JSON map
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      answers: List<String>.from(json['answers'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      funFact: json['funFact'] as String,
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.easy,
      ),
      category: json['category'] as String,
      hint: json['hint'] as String?,
    );
  }

  /// Converts the Question to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'answers': answers,
      'correctAnswerIndex': correctAnswerIndex,
      'funFact': funFact,
      'difficulty': difficulty.name,
      'category': category,
      'hint': hint,
    };
  }

  /// Creates a Question from a JSON string
  factory Question.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return Question.fromJson(json);
  }

  /// Converts the Question to a JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Creates a copy of this Question with optional parameter overrides
  Question copyWith({
    String? id,
    String? text,
    List<String>? answers,
    int? correctAnswerIndex,
    String? funFact,
    Difficulty? difficulty,
    String? category,
    String? hint,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      answers: answers ?? this.answers,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      funFact: funFact ?? this.funFact,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      hint: hint ?? this.hint,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Question) return false;
    return id == other.id &&
        text == other.text &&
        answers.length == other.answers.length &&
        answers.every((answer) => other.answers.contains(answer)) &&
        correctAnswerIndex == other.correctAnswerIndex &&
        funFact == other.funFact &&
        difficulty == other.difficulty &&
        category == other.category &&
        hint == other.hint;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      text,
      answers,
      correctAnswerIndex,
      funFact,
      difficulty,
      category,
      hint,
    );
  }

  @override
  String toString() {
    return 'Question(id: $id, text: $text, difficulty: $difficulty, category: $category)';
  }
}
