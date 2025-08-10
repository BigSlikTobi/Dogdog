import 'dart:math';
import '../models/question.dart';
import '../models/enums.dart';
import 'question_service.dart';

/// Manages question pools with no-repeat logic and path-based filtering
class QuestionPoolManager {
  static final QuestionPoolManager _instance = QuestionPoolManager._internal();
  factory QuestionPoolManager() => _instance;
  QuestionPoolManager._internal();

  final QuestionService _questionService = QuestionService();
  final Random _random = Random();

  /// Gets shuffled questions for a specific path with exclusion logic
  ///
  /// [pathType] - The themed path to get questions for
  /// [excludeQuestionIds] - Set of question IDs to exclude (already answered)
  /// [count] - Number of questions to return
  /// [difficultyLevel] - Current difficulty level (1-5) for progression
  List<Question> getShuffledQuestions({
    required PathType pathType,
    required Set<String> excludeQuestionIds,
    required int count,
    required int difficultyLevel,
  }) {
    // Get all questions for the path
    final allQuestions = _getQuestionsForPath(pathType);

    // Filter out already answered questions
    final availableQuestions = allQuestions
        .where((q) => !excludeQuestionIds.contains(q.id))
        .toList();

    // Apply difficulty filtering based on progression
    final filteredQuestions = _filterByDifficulty(
      availableQuestions,
      difficultyLevel,
    );

    // If we don't have enough questions after filtering, expand the pool
    if (filteredQuestions.length < count) {
      return _expandQuestionPool(availableQuestions, count, difficultyLevel);
    }

    // Shuffle and return requested count
    filteredQuestions.shuffle(_random);
    return filteredQuestions.take(count).toList();
  }

  /// Filters questions based on path type and category matching
  List<Question> _getQuestionsForPath(PathType pathType) {
    final allQuestions = <Question>[];

    // Get questions from all difficulty levels
    for (final difficulty in Difficulty.values) {
      final questions = _questionService.getQuestionsByDifficulty(difficulty);
      allQuestions.addAll(questions);
    }

    // Filter questions based on path type
    return allQuestions.where((question) {
      return _isQuestionRelevantToPath(question, pathType);
    }).toList();
  }

  /// Determines if a question is relevant to a specific path
  bool _isQuestionRelevantToPath(Question question, PathType pathType) {
    final category = question.category.toLowerCase();
    final text = question.text.toLowerCase();

    switch (pathType) {
      case PathType.dogBreeds:
        return category.contains('hunderassen') ||
            category.contains('breed') ||
            category.contains('rasse') ||
            text.contains('rasse') ||
            text.contains('breed') ||
            text.contains('welche hunderasse') ||
            text.contains('chihuahua') ||
            text.contains('golden retriever') ||
            text.contains('dalmatiner') ||
            text.contains('bernhardiner') ||
            text.contains('border collie') ||
            text.contains('dackel') ||
            text.contains('chow chow') ||
            text.contains('bulldogge') ||
            text.contains('mops') ||
            // Fallback: include all questions if no specific matches
            true;

      case PathType.dogTraining:
        return category.contains('training') ||
            category.contains('verhalten') ||
            category.contains('behavior') ||
            category.contains('kommando') ||
            text.contains('training') ||
            text.contains('kommando') ||
            text.contains('erziehung') ||
            text.contains('gehorsam') ||
            // Fallback: include all questions if no specific matches
            true;

      case PathType.healthCare:
        return category.contains('gesundheit') ||
            category.contains('health') ||
            category.contains('medizin') ||
            category.contains('veterinär') ||
            category.contains('ernährung') ||
            category.contains('pflege') ||
            category.contains('physiologie') ||
            category.contains('anatomie') ||
            text.contains('gesund') ||
            text.contains('krank') ||
            text.contains('temperatur') ||
            text.contains('zähne') ||
            text.contains('schwangerschaft') ||
            text.contains('hecheln') ||
            // Fallback: include all questions if no specific matches
            true;

      case PathType.dogBehavior:
        return category.contains('verhalten') ||
            category.contains('behavior') ||
            category.contains('psychologie') ||
            category.contains('instinkt') ||
            category.contains('sinne') ||
            text.contains('verhalten') ||
            text.contains('warum') ||
            text.contains('wedeln') ||
            text.contains('bellen') ||
            text.contains('riechen') ||
            text.contains('hören') ||
            text.contains('glücklich') ||
            // Fallback: include all questions if no specific matches
            true;

      case PathType.dogHistory:
        return category.contains('geschichte') ||
            category.contains('history') ||
            category.contains('genetik') ||
            category.contains('evolution') ||
            category.contains('ursprung') ||
            category.contains('wissenschaft') ||
            category.contains('neurobiologie') ||
            text.contains('ursprünglich') ||
            text.contains('geschichte') ||
            text.contains('gezüchtet') ||
            text.contains('chromosomen') ||
            text.contains('gen') ||
            text.contains('kynologie') ||
            // Fallback: include all questions if no specific matches
            true;

      case PathType.breedAdventure:
        // Breed Adventure uses its own breed data, not questions
        return false;
    }
  }

  /// Filters questions based on difficulty progression
  List<Question> _filterByDifficulty(
    List<Question> questions,
    int difficultyLevel,
  ) {
    // Define difficulty distribution based on progression level
    final difficultyWeights = _getDifficultyWeights(difficultyLevel);

    final filteredQuestions = <Question>[];

    // Group questions by difficulty
    final questionsByDifficulty = <Difficulty, List<Question>>{};
    for (final question in questions) {
      questionsByDifficulty.putIfAbsent(question.difficulty, () => []);
      questionsByDifficulty[question.difficulty]!.add(question);
    }

    // Select questions based on weights
    for (final entry in difficultyWeights.entries) {
      final difficulty = entry.key;
      final weight = entry.value;
      final availableQuestions = questionsByDifficulty[difficulty] ?? [];

      if (availableQuestions.isNotEmpty && weight > 0) {
        final questionsToAdd = (questions.length * weight).round();
        availableQuestions.shuffle(_random);
        filteredQuestions.addAll(availableQuestions.take(questionsToAdd));
      }
    }

    return filteredQuestions;
  }

  /// Gets difficulty weights based on progression level
  Map<Difficulty, double> _getDifficultyWeights(int difficultyLevel) {
    switch (difficultyLevel) {
      case 1: // Chihuahua level (questions 1-10)
        return {
          Difficulty.easy: 0.8,
          Difficulty.medium: 0.2,
          Difficulty.hard: 0.0,
          Difficulty.expert: 0.0,
        };
      case 2: // Cocker Spaniel level (questions 11-20)
        return {
          Difficulty.easy: 0.6,
          Difficulty.medium: 0.3,
          Difficulty.hard: 0.1,
          Difficulty.expert: 0.0,
        };
      case 3: // German Shepherd level (questions 21-30)
        return {
          Difficulty.easy: 0.4,
          Difficulty.medium: 0.4,
          Difficulty.hard: 0.15,
          Difficulty.expert: 0.05,
        };
      case 4: // Great Dane level (questions 31-40)
        return {
          Difficulty.easy: 0.3,
          Difficulty.medium: 0.35,
          Difficulty.hard: 0.25,
          Difficulty.expert: 0.1,
        };
      case 5: // Deutsche Dogge level (questions 41-50)
      default:
        return {
          Difficulty.easy: 0.2,
          Difficulty.medium: 0.3,
          Difficulty.hard: 0.35,
          Difficulty.expert: 0.15,
        };
    }
  }

  /// Expands the question pool when not enough questions are available
  List<Question> _expandQuestionPool(
    List<Question> availableQuestions,
    int count,
    int difficultyLevel,
  ) {
    if (availableQuestions.isEmpty) {
      // Fallback to any available questions if path-specific ones are exhausted
      final allQuestions = <Question>[];
      for (final difficulty in Difficulty.values) {
        allQuestions.addAll(
          _questionService.getQuestionsByDifficulty(difficulty),
        );
      }
      allQuestions.shuffle(_random);
      return allQuestions.take(count).toList();
    }

    // If we have some questions but not enough, repeat them with shuffling
    final expandedQuestions = <Question>[];
    while (expandedQuestions.length < count) {
      final shuffledQuestions = List<Question>.from(availableQuestions);
      shuffledQuestions.shuffle(_random);
      expandedQuestions.addAll(shuffledQuestions);
    }

    return expandedQuestions.take(count).toList();
  }

  /// Resets the question pool for checkpoint fallback scenarios
  void resetQuestionPool({
    required PathType pathType,
    required Set<String> preserveAnsweredIds,
  }) {
    // This method can be used to reset question availability
    // while preserving certain answered question IDs for checkpoint scenarios
    // Implementation depends on how we want to handle checkpoint fallbacks

    // For now, this is a placeholder that could be extended to:
    // 1. Clear certain cached question states
    // 2. Reshuffle available questions
    // 3. Reset difficulty progression if needed
  }

  /// Gets the total number of available questions for a path
  int getAvailableQuestionCount({
    required PathType pathType,
    required Set<String> excludeQuestionIds,
  }) {
    final pathQuestions = _getQuestionsForPath(pathType);
    return pathQuestions
        .where((q) => !excludeQuestionIds.contains(q.id))
        .length;
  }

  /// Checks if enough questions are available for a path
  bool hasEnoughQuestions({
    required PathType pathType,
    required Set<String> excludeQuestionIds,
    required int requiredCount,
  }) {
    return getAvailableQuestionCount(
          pathType: pathType,
          excludeQuestionIds: excludeQuestionIds,
        ) >=
        requiredCount;
  }

  /// Gets questions for checkpoint fallback with reshuffling
  List<Question> getQuestionsForCheckpointRestart({
    required PathType pathType,
    required Set<String> excludeQuestionIds,
    required int count,
    required int checkpointLevel,
  }) {
    // Reset and reshuffle questions for checkpoint restart
    final questions = getShuffledQuestions(
      pathType: pathType,
      excludeQuestionIds: excludeQuestionIds,
      count: count,
      difficultyLevel: checkpointLevel,
    );

    // Additional shuffling for variety in restart scenarios
    questions.shuffle(_random);
    return questions;
  }

  /// Gets difficulty level based on question count in current path
  int getDifficultyLevelForQuestionCount(int questionCount) {
    if (questionCount <= 10) return 1;
    if (questionCount <= 20) return 2;
    if (questionCount <= 30) return 3;
    if (questionCount <= 40) return 4;
    return 5;
  }
}
