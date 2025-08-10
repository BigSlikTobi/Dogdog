/// Enum representing the three difficulty phases in Dog Breeds Adventure
enum DifficultyPhase {
  beginner(difficulties: [1, 2], name: 'Beginner'),
  intermediate(difficulties: [3, 4], name: 'Intermediate'),
  expert(difficulties: [5], name: 'Expert');

  const DifficultyPhase({required this.difficulties, required this.name});

  /// List of difficulty levels included in this phase
  final List<int> difficulties;

  /// Display name for the phase
  final String name;

  /// Returns the score multiplier for this difficulty phase
  int get scoreMultiplier {
    switch (this) {
      case DifficultyPhase.beginner:
        return 1;
      case DifficultyPhase.intermediate:
        return 2;
      case DifficultyPhase.expert:
        return 3;
    }
  }

  /// Returns the next difficulty phase, or null if this is the final phase
  DifficultyPhase? get nextPhase {
    switch (this) {
      case DifficultyPhase.beginner:
        return DifficultyPhase.intermediate;
      case DifficultyPhase.intermediate:
        return DifficultyPhase.expert;
      case DifficultyPhase.expert:
        return null;
    }
  }

  /// Returns true if the given difficulty level belongs to this phase
  bool containsDifficulty(int difficulty) {
    return difficulties.contains(difficulty);
  }

  /// Returns the display name with localization key
  String get localizationKey {
    switch (this) {
      case DifficultyPhase.beginner:
        return 'breed_adventure_beginner';
      case DifficultyPhase.intermediate:
        return 'breed_adventure_intermediate';
      case DifficultyPhase.expert:
        return 'breed_adventure_expert';
    }
  }
}
