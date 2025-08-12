import 'dart:math';
import '../models/localized_question.dart';
import '../models/enums.dart';
import 'difficulty_progression.dart';

/// Enhanced question randomization utility with category and difficulty constraints
class QuestionRandomizer {
  final Random _random;

  QuestionRandomizer({Random? random}) : _random = random ?? Random();

  /// Randomizes questions within category and difficulty constraints
  List<LocalizedQuestion> randomizeQuestionsForCategory({
    required Map<String, List<LocalizedQuestion>> categoryPool,
    required int count,
    required Set<String> excludeIds,
    int? seed,
    bool shuffleWithinDifficulty = true,
    double varietyFactor = 0.3,
  }) {
    // Use seeded random if provided, otherwise use instance random
    final random = seed != null ? Random(seed) : _random;

    final progression = DifficultyProgression.getProgressionForQuestionCount(
      count,
    );
    final List<LocalizedQuestion> selectedQuestions = [];
    final Set<String> usedIds = Set.from(excludeIds);

    // Track question distribution for variety
    final Map<String, int> tagUsageCount = <String, int>{};
    final Map<String, int> difficultyUsageCount = <String, int>{};

    for (int i = 0; i < count && i < progression.length; i++) {
      final targetDifficulty = progression[i];

      final selectedQuestion = _selectQuestionWithConstraints(
        categoryPool: categoryPool,
        targetDifficulty: targetDifficulty,
        usedIds: usedIds,
        tagUsageCount: tagUsageCount,
        difficultyUsageCount: difficultyUsageCount,
        varietyFactor: varietyFactor,
        shuffleWithinDifficulty: shuffleWithinDifficulty,
        random: random,
      );

      if (selectedQuestion != null) {
        selectedQuestions.add(selectedQuestion);
        usedIds.add(selectedQuestion.id);

        // Update usage tracking
        difficultyUsageCount[selectedQuestion.difficulty] =
            (difficultyUsageCount[selectedQuestion.difficulty] ?? 0) + 1;

        for (final tag in selectedQuestion.tags) {
          tagUsageCount[tag] = (tagUsageCount[tag] ?? 0) + 1;
        }
      }
    }

    return selectedQuestions;
  }

  /// Selects a question with various constraints and variety considerations
  LocalizedQuestion? _selectQuestionWithConstraints({
    required Map<String, List<LocalizedQuestion>> categoryPool,
    required String targetDifficulty,
    required Set<String> usedIds,
    required Map<String, int> tagUsageCount,
    required Map<String, int> difficultyUsageCount,
    required double varietyFactor,
    required bool shuffleWithinDifficulty,
    required Random random,
  }) {
    // Try target difficulty first
    var candidates = _getCandidateQuestions(
      categoryPool[targetDifficulty] ?? [],
      usedIds,
    );

    if (candidates.isNotEmpty) {
      return _selectWithVariety(
        candidates,
        tagUsageCount,
        varietyFactor,
        shuffleWithinDifficulty,
        random,
      );
    }

    // Fallback to nearby difficulties
    final fallbackOrder = _getFallbackDifficultyOrder(targetDifficulty);

    for (final fallbackDifficulty in fallbackOrder) {
      candidates = _getCandidateQuestions(
        categoryPool[fallbackDifficulty] ?? [],
        usedIds,
      );

      if (candidates.isNotEmpty) {
        return _selectWithVariety(
          candidates,
          tagUsageCount,
          varietyFactor,
          shuffleWithinDifficulty,
          random,
        );
      }
    }

    return null;
  }

  /// Gets candidate questions excluding already used ones
  List<LocalizedQuestion> _getCandidateQuestions(
    List<LocalizedQuestion> pool,
    Set<String> usedIds,
  ) {
    return pool.where((q) => !usedIds.contains(q.id)).toList();
  }

  /// Selects a question with variety considerations
  LocalizedQuestion _selectWithVariety(
    List<LocalizedQuestion> candidates,
    Map<String, int> tagUsageCount,
    double varietyFactor,
    bool shuffleWithinDifficulty,
    Random random,
  ) {
    if (candidates.length == 1) {
      return candidates.first;
    }

    if (shuffleWithinDifficulty) {
      candidates.shuffle(random);
    }

    // Apply variety factor to prefer less-used tags
    if (varietyFactor > 0 && tagUsageCount.isNotEmpty) {
      candidates.sort((a, b) {
        final aTagScore = _calculateTagVarietyScore(a.tags, tagUsageCount);
        final bTagScore = _calculateTagVarietyScore(b.tags, tagUsageCount);
        return aTagScore.compareTo(bTagScore);
      });

      // Select from top variety candidates
      final varietyPoolSize = (candidates.length * varietyFactor).ceil().clamp(
        1,
        candidates.length,
      );
      final varietyPool = candidates.take(varietyPoolSize).toList();
      return varietyPool[random.nextInt(varietyPool.length)];
    }

    return candidates[random.nextInt(candidates.length)];
  }

  /// Calculates a variety score based on tag usage (lower = more variety)
  double _calculateTagVarietyScore(
    List<String> tags,
    Map<String, int> tagUsageCount,
  ) {
    if (tags.isEmpty) return 0.0;

    double totalUsage = 0.0;
    for (final tag in tags) {
      totalUsage += tagUsageCount[tag] ?? 0;
    }

    return totalUsage / tags.length;
  }

  /// Gets fallback difficulty order for a target difficulty
  List<String> _getFallbackDifficultyOrder(String targetDifficulty) {
    switch (targetDifficulty) {
      case 'easy':
        return ['easy+', 'medium', 'hard'];
      case 'easy+':
        return ['easy', 'medium', 'hard'];
      case 'medium':
        return ['easy+', 'easy', 'hard'];
      case 'hard':
        return ['medium', 'easy+', 'easy'];
      default:
        return ['easy', 'easy+', 'medium', 'hard'];
    }
  }

  /// Shuffles questions while maintaining difficulty progression
  List<LocalizedQuestion> shuffleWithinDifficultyGroups(
    List<LocalizedQuestion> questions,
  ) {
    if (questions.length <= 1) return questions;

    // Group questions by difficulty
    final Map<String, List<LocalizedQuestion>> difficultyGroups = {};
    final List<String> difficultyOrder = [];

    for (final question in questions) {
      if (!difficultyGroups.containsKey(question.difficulty)) {
        difficultyGroups[question.difficulty] = [];
        difficultyOrder.add(question.difficulty);
      }
      difficultyGroups[question.difficulty]!.add(question);
    }

    // Shuffle within each difficulty group
    final List<LocalizedQuestion> shuffledQuestions = [];
    for (final difficulty in difficultyOrder) {
      final group = difficultyGroups[difficulty]!;
      group.shuffle(_random);
      shuffledQuestions.addAll(group);
    }

    return shuffledQuestions;
  }

  /// Validates that questions respect category boundaries
  bool validateCategoryBoundaries(
    List<LocalizedQuestion> questions,
    QuestionCategory expectedCategory,
  ) {
    final expectedCategoryName = expectedCategory.displayName;
    return questions.every((q) => q.category == expectedCategoryName);
  }

  /// Validates difficulty progression
  bool validateDifficultyProgression(List<LocalizedQuestion> questions) {
    if (questions.length <= 1) return true;

    final difficulties = questions.map((q) => q.difficulty).toList();
    return DifficultyProgression.isValidProgression(difficulties);
  }

  /// Checks for question duplicates
  bool hasDuplicates(List<LocalizedQuestion> questions) {
    final ids = questions.map((q) => q.id).toSet();
    return ids.length != questions.length;
  }

  /// Analyzes question variety in a set
  QuestionVarietyAnalysis analyzeVariety(List<LocalizedQuestion> questions) {
    final Map<String, int> difficultyCount = {};
    final Map<String, int> tagCount = {};
    final Set<String> uniqueIds = {};

    for (final question in questions) {
      // Count difficulties
      difficultyCount[question.difficulty] =
          (difficultyCount[question.difficulty] ?? 0) + 1;

      // Count tags
      for (final tag in question.tags) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }

      // Track unique IDs
      uniqueIds.add(question.id);
    }

    return QuestionVarietyAnalysis(
      totalQuestions: questions.length,
      uniqueQuestions: uniqueIds.length,
      difficultyDistribution: difficultyCount,
      tagDistribution: tagCount,
      varietyScore: _calculateOverallVarietyScore(difficultyCount, tagCount),
    );
  }

  /// Calculates an overall variety score (0.0 to 1.0, higher = more variety)
  double _calculateOverallVarietyScore(
    Map<String, int> difficultyCount,
    Map<String, int> tagCount,
  ) {
    // Calculate entropy-based variety score
    double difficultyEntropy = _calculateEntropy(
      difficultyCount.values.toList(),
    );
    double tagEntropy = _calculateEntropy(tagCount.values.toList());

    // Weight difficulty variety more heavily than tag variety
    return (difficultyEntropy * 0.6 + tagEntropy * 0.4).clamp(0.0, 1.0);
  }

  /// Calculates entropy for a distribution
  double _calculateEntropy(List<int> distribution) {
    if (distribution.isEmpty) return 0.0;

    final total = distribution.reduce((a, b) => a + b);
    if (total == 0) return 0.0;

    double entropy = 0.0;
    for (final count in distribution) {
      if (count > 0) {
        final probability = count / total;
        entropy -= probability * (log(probability) / ln2);
      }
    }

    return entropy;
  }
}

/// Analysis result for question variety
class QuestionVarietyAnalysis {
  final int totalQuestions;
  final int uniqueQuestions;
  final Map<String, int> difficultyDistribution;
  final Map<String, int> tagDistribution;
  final double varietyScore;

  const QuestionVarietyAnalysis({
    required this.totalQuestions,
    required this.uniqueQuestions,
    required this.difficultyDistribution,
    required this.tagDistribution,
    required this.varietyScore,
  });

  bool get hasDuplicates => uniqueQuestions < totalQuestions;

  double get uniquenessRatio =>
      totalQuestions > 0 ? uniqueQuestions / totalQuestions : 0.0;

  @override
  String toString() {
    return 'QuestionVarietyAnalysis('
        'total: $totalQuestions, '
        'unique: $uniqueQuestions, '
        'variety: ${varietyScore.toStringAsFixed(2)}'
        ')';
  }
}
