/// Utility class for managing difficulty progression in treasure map journeys
class DifficultyProgression {
  /// Maps the number of questions to appropriate difficulty progression
  static List<String> getProgressionForQuestionCount(int count) {
    if (count <= 10) {
      // Short journey: mostly easy with some progression
      return List.generate(count, (index) {
        if (index < 4) return 'easy';
        if (index < 7) return 'easy+';
        if (index < 9) return 'medium';
        return 'hard';
      });
    } else if (count <= 20) {
      // Medium journey: balanced progression
      return List.generate(count, (index) {
        if (index < 6) return 'easy';
        if (index < 10) return 'easy+';
        if (index < 16) return 'medium';
        return 'hard';
      });
    } else if (count <= 30) {
      // Long journey: gradual progression
      return List.generate(count, (index) {
        if (index < 8) return 'easy';
        if (index < 14) return 'easy+';
        if (index < 24) return 'medium';
        return 'hard';
      });
    } else {
      // Very long journey: extended progression
      return List.generate(count, (index) {
        final progress = index / count;
        if (progress < 0.25) return 'easy';
        if (progress < 0.45) return 'easy+';
        if (progress < 0.75) return 'medium';
        return 'hard';
      });
    }
  }

  /// Gets the difficulty for a specific question index in a journey
  static String getDifficultyForQuestionIndex(
    int questionIndex,
    int totalQuestions,
  ) {
    final progression = getProgressionForQuestionCount(totalQuestions);
    if (questionIndex >= 0 && questionIndex < progression.length) {
      return progression[questionIndex];
    }
    return 'easy'; // Default fallback
  }

  /// Gets the expected difficulty distribution for a given question count
  static Map<String, int> getDifficultyDistribution(int questionCount) {
    final progression = getProgressionForQuestionCount(questionCount);
    final distribution = <String, int>{
      'easy': 0,
      'easy+': 0,
      'medium': 0,
      'hard': 0,
    };

    for (final difficulty in progression) {
      distribution[difficulty] = (distribution[difficulty] ?? 0) + 1;
    }

    return distribution;
  }

  /// Validates if a difficulty progression is appropriate for treasure map
  static bool isValidProgression(List<String> difficulties) {
    if (difficulties.isEmpty) return false;

    // Must start with easy
    if (difficulties.first != 'easy') return false;

    // Check for proper progression (no jumping backwards significantly)
    final difficultyOrder = ['easy', 'easy+', 'medium', 'hard'];
    int maxDifficultyIndex = 0;

    for (final difficulty in difficulties) {
      final currentIndex = difficultyOrder.indexOf(difficulty);
      if (currentIndex == -1) return false; // Invalid difficulty

      // Allow staying at same level or progressing, but not regressing too much
      if (currentIndex < maxDifficultyIndex - 1) return false;

      maxDifficultyIndex = maxDifficultyIndex > currentIndex
          ? maxDifficultyIndex
          : currentIndex;
    }

    return true;
  }

  /// Gets the next logical difficulty level
  static String getNextDifficulty(String currentDifficulty) {
    switch (currentDifficulty) {
      case 'easy':
        return 'easy+';
      case 'easy+':
        return 'medium';
      case 'medium':
        return 'hard';
      case 'hard':
      default:
        return 'hard';
    }
  }

  /// Gets the previous difficulty level
  static String getPreviousDifficulty(String currentDifficulty) {
    switch (currentDifficulty) {
      case 'hard':
        return 'medium';
      case 'medium':
        return 'easy+';
      case 'easy+':
        return 'easy';
      case 'easy':
      default:
        return 'easy';
    }
  }

  /// Converts new difficulty format to legacy Difficulty enum
  static String mapToLegacyDifficulty(String newDifficulty) {
    switch (newDifficulty) {
      case 'easy':
      case 'easy+':
        return 'easy';
      case 'medium':
        return 'medium';
      case 'hard':
        return 'hard';
      default:
        return 'easy';
    }
  }

  /// Gets difficulty weight for scoring purposes
  static double getDifficultyWeight(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 1.0;
      case 'easy+':
        return 1.2;
      case 'medium':
        return 1.5;
      case 'hard':
        return 2.0;
      default:
        return 1.0;
    }
  }

  /// Determines if a difficulty level is considered advanced
  static bool isAdvancedDifficulty(String difficulty) {
    return difficulty == 'medium' || difficulty == 'hard';
  }

  /// Gets a human-readable description of the difficulty
  static String getDifficultyDescription(String difficulty, String locale) {
    switch (difficulty) {
      case 'easy':
        switch (locale) {
          case 'de':
            return 'Leicht - Perfekt für Anfänger';
          case 'es':
            return 'Fácil - Perfecto para principiantes';
          default:
            return 'Easy - Perfect for beginners';
        }
      case 'easy+':
        switch (locale) {
          case 'de':
            return 'Leicht+ - Etwas herausfordernder';
          case 'es':
            return 'Fácil+ - Un poco más desafiante';
          default:
            return 'Easy+ - Slightly more challenging';
        }
      case 'medium':
        switch (locale) {
          case 'de':
            return 'Mittel - Für Hundeliebhaber';
          case 'es':
            return 'Medio - Para amantes de los perros';
          default:
            return 'Medium - For dog lovers';
        }
      case 'hard':
        switch (locale) {
          case 'de':
            return 'Schwer - Für Hundeexperten';
          case 'es':
            return 'Difícil - Para expertos en perros';
          default:
            return 'Hard - For dog experts';
        }
      default:
        return difficulty;
    }
  }
}
