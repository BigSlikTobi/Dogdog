import 'dart:convert';
import 'enums.dart';
import 'question.dart';

/// Model representing a localized trivia question with multilingual support
class LocalizedQuestion {
  final String id;
  final String category;
  final String difficulty; // 'easy', 'easy+', 'medium', 'hard'
  final Map<String, String> text; // Localized question text
  final Map<String, List<String>> answers; // Localized answer options
  final int correctAnswerIndex;
  final Map<String, String> hint; // Localized hints
  final Map<String, String> funFact; // Localized fun facts
  final String ageRange;
  final List<String> tags;

  const LocalizedQuestion({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.text,
    required this.answers,
    required this.correctAnswerIndex,
    required this.hint,
    required this.funFact,
    required this.ageRange,
    required this.tags,
  });

  /// Returns the question text for the specified locale, with fallback to German
  String getText(String locale) {
    return text[locale] ?? text['de'] ?? text.values.first;
  }

  /// Returns the answer options for the specified locale, with fallback to German
  List<String> getAnswers(String locale) {
    return answers[locale] ?? answers['de'] ?? answers.values.first;
  }

  /// Returns the correct answer text for the specified locale
  String getCorrectAnswer(String locale) {
    final localizedAnswers = getAnswers(locale);
    return localizedAnswers[correctAnswerIndex];
  }

  /// Returns the hint for the specified locale, with fallback to German
  String getHint(String locale) {
    return hint[locale] ?? hint['de'] ?? hint.values.first;
  }

  /// Returns the fun fact for the specified locale, with fallback to German
  String getFunFact(String locale) {
    return funFact[locale] ?? funFact['de'] ?? funFact.values.first;
  }

  /// Returns the points awarded for answering this question correctly based on difficulty
  int get points {
    switch (difficulty) {
      case 'easy':
        return 10;
      case 'easy+':
        return 12;
      case 'medium':
        return 15;
      case 'hard':
        return 20;
      default:
        return 10;
    }
  }

  /// Converts difficulty string to Difficulty enum for backward compatibility
  Difficulty get difficultyEnum {
    switch (difficulty) {
      case 'easy':
      case 'easy+':
        return Difficulty.easy;
      case 'medium':
        return Difficulty.medium;
      case 'hard':
        return Difficulty.hard;
      default:
        return Difficulty.easy;
    }
  }

  /// Creates a LocalizedQuestion from a JSON map
  factory LocalizedQuestion.fromJson(Map<String, dynamic> json) {
    return LocalizedQuestion(
      id: json['id'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      text: Map<String, String>.from(json['text'] as Map),
      answers: (json['answers'] as Map).map(
        (key, value) =>
            MapEntry(key as String, List<String>.from(value as List)),
      ),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      hint: Map<String, String>.from(json['hint'] as Map),
      funFact: Map<String, String>.from(json['funFact'] as Map),
      ageRange: json['ageRange'] as String? ?? '8-12',
      tags: List<String>.from(json['tags'] as List? ?? []),
    );
  }

  /// Converts the LocalizedQuestion to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'difficulty': difficulty,
      'text': text,
      'answers': answers,
      'correctAnswerIndex': correctAnswerIndex,
      'hint': hint,
      'funFact': funFact,
      'ageRange': ageRange,
      'tags': tags,
    };
  }

  /// Creates a LocalizedQuestion from a JSON string
  factory LocalizedQuestion.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return LocalizedQuestion.fromJson(json);
  }

  /// Converts the LocalizedQuestion to a JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Creates a copy of this LocalizedQuestion with optional parameter overrides
  LocalizedQuestion copyWith({
    String? id,
    String? category,
    String? difficulty,
    Map<String, String>? text,
    Map<String, List<String>>? answers,
    int? correctAnswerIndex,
    Map<String, String>? hint,
    Map<String, String>? funFact,
    String? ageRange,
    List<String>? tags,
  }) {
    return LocalizedQuestion(
      id: id ?? this.id,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      text: text ?? this.text,
      answers: answers ?? this.answers,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      hint: hint ?? this.hint,
      funFact: funFact ?? this.funFact,
      ageRange: ageRange ?? this.ageRange,
      tags: tags ?? this.tags,
    );
  }

  /// Converts this LocalizedQuestion to the legacy Question format for backward compatibility
  Question toLegacyQuestion(String locale) {
    return Question(
      id: id,
      text: getText(locale),
      answers: getAnswers(locale),
      correctAnswerIndex: correctAnswerIndex,
      funFact: getFunFact(locale),
      difficulty: difficultyEnum,
      category: category,
      hint: getHint(locale),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LocalizedQuestion) return false;
    return id == other.id &&
        category == other.category &&
        difficulty == other.difficulty &&
        correctAnswerIndex == other.correctAnswerIndex &&
        ageRange == other.ageRange;
  }

  @override
  int get hashCode {
    return Object.hash(id, category, difficulty, correctAnswerIndex, ageRange);
  }

  @override
  String toString() {
    return 'LocalizedQuestion(id: $id, category: $category, difficulty: $difficulty)';
  }
}
