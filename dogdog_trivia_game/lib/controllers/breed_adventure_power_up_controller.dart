import '../models/enums.dart';
import '../models/breed_challenge.dart';
import '../controllers/power_up_controller.dart';

/// Extended power-up controller specifically for Dog Breeds Adventure game mode
class BreedAdventurePowerUpController extends PowerUpController {
  // Breed adventure specific configuration
  static const int extraTimeSeconds = 5; // Add 5 seconds for breed adventure
  static const int powerUpRewardThreshold = 5; // Every 5 correct answers

  // Track power-up usage for rewards
  int _correctAnswersCount = 0;
  int _lastRewardAt = 0;

  /// Initialize with breed adventure specific power-ups
  void initializeForBreedAdventure() {
    setPowerUps({
      PowerUpType.hint: 2,
      PowerUpType.extraTime: 2,
      PowerUpType.skip: 1,
      PowerUpType.secondChance: 1,
      PowerUpType.fiftyFifty: 0, // Not used in breed adventure
    });
  }

  /// Apply hint power-up for breed adventure
  /// Returns breed characteristics or additional information
  String? applyBreedHint(BreedChallenge challenge) {
    if (!usePowerUp(PowerUpType.hint)) {
      return null;
    }

    // Generate helpful hint about the breed
    return _generateBreedHint(challenge.correctBreedName);
  }

  /// Apply extra time power-up for breed adventure
  /// Returns the number of seconds to add (5 seconds for breed adventure)
  int applyBreedExtraTime() {
    if (!usePowerUp(PowerUpType.extraTime)) {
      return 0;
    }

    return extraTimeSeconds;
  }

  /// Apply skip power-up for breed adventure
  /// Returns true if skip was successful
  bool applyBreedSkip() {
    if (!usePowerUp(PowerUpType.skip)) {
      return false;
    }

    // Skip allows moving to next breed without penalty
    return true;
  }

  /// Apply second chance power-up for breed adventure
  /// Returns true if second chance was successful (restores one life)
  bool applyBreedSecondChance() {
    if (!usePowerUp(PowerUpType.secondChance)) {
      return false;
    }

    // Second chance restores one life in breed adventure
    return true;
  }

  /// Track correct answers and award power-ups
  void trackCorrectAnswer() {
    _correctAnswersCount++;

    // Check if player should receive a power-up reward
    if (_correctAnswersCount - _lastRewardAt >= powerUpRewardThreshold) {
      _awardRandomPowerUp();
      _lastRewardAt = _correctAnswersCount;
    }
  }

  /// Award a random power-up as a reward
  void _awardRandomPowerUp() {
    final availablePowerUps = [
      PowerUpType.hint,
      PowerUpType.extraTime,
      PowerUpType.skip,
      PowerUpType.secondChance,
    ];

    // Randomly select a power-up to award
    availablePowerUps.shuffle();
    final selectedPowerUp = availablePowerUps.first;

    addPowerUp(selectedPowerUp, 1);
  }

  /// Generate breed-specific hint text
  String _generateBreedHint(String breedName) {
    // This would ideally come from a breed database with characteristics
    // For now, provide generic helpful hints based on breed name patterns

    final breedLower = breedName.toLowerCase();

    if (breedLower.contains('shepherd')) {
      return 'This breed is known for herding and protecting livestock. They are intelligent and loyal working dogs.';
    } else if (breedLower.contains('retriever')) {
      return 'This breed was originally developed for retrieving waterfowl. They have a gentle mouth and love water.';
    } else if (breedLower.contains('terrier')) {
      return 'This breed was originally bred to hunt vermin. They are typically small to medium-sized with a feisty personality.';
    } else if (breedLower.contains('spaniel')) {
      return 'This breed is known for their hunting abilities, especially with birds. They have long, silky ears and a gentle nature.';
    } else if (breedLower.contains('bulldog')) {
      return 'This breed is known for their muscular build and distinctive flat face. They are gentle and good with children.';
    } else if (breedLower.contains('poodle')) {
      return 'This breed is highly intelligent and has a curly, hypoallergenic coat. They come in three sizes.';
    } else if (breedLower.contains('husky')) {
      return 'This breed was developed for sledding in cold climates. They have thick coats and striking blue or multicolored eyes.';
    } else if (breedLower.contains('collie')) {
      return 'This breed is known for their intelligence and herding abilities. They have long, flowing coats and pointed ears.';
    } else if (breedLower.contains('mastiff')) {
      return 'This breed is one of the largest dog breeds. They are gentle giants with a protective nature.';
    } else if (breedLower.contains('chihuahua')) {
      return 'This is the world\'s smallest dog breed. Despite their size, they have big personalities and are very loyal.';
    } else {
      // Generic hints for other breeds
      return 'Look carefully at the dog\'s size, coat type, ear shape, and facial features to identify this breed.';
    }
  }

  /// Reset tracking for new game
  void resetForNewGame() {
    _correctAnswersCount = 0;
    _lastRewardAt = 0;
    initializeForBreedAdventure();
  }

  /// Get power-up usage statistics
  Map<String, dynamic> getUsageStats() {
    return {
      'correctAnswers': _correctAnswersCount,
      'powerUpsAwarded': _correctAnswersCount ~/ powerUpRewardThreshold,
      'nextRewardIn':
          powerUpRewardThreshold - (_correctAnswersCount - _lastRewardAt),
    };
  }

  /// Check if player is close to earning a power-up reward
  bool isCloseToReward() {
    final answersUntilReward =
        powerUpRewardThreshold - (_correctAnswersCount - _lastRewardAt);
    return answersUntilReward <= 2;
  }

  /// Get celebration message for power-up usage
  String getPowerUpCelebrationMessage(PowerUpType powerUpType) {
    switch (powerUpType) {
      case PowerUpType.hint:
        return 'Breed knowledge revealed! 🧠';
      case PowerUpType.extraTime:
        return 'Extra time granted! ⏰';
      case PowerUpType.skip:
        return 'Question skipped successfully! ⏭️';
      case PowerUpType.secondChance:
        return 'Life restored! ❤️';
      case PowerUpType.fiftyFifty:
        return 'Options eliminated! ✂️';
    }
  }

  /// Get power-up description for breed adventure
  String getPowerUpDescription(PowerUpType powerUpType) {
    switch (powerUpType) {
      case PowerUpType.hint:
        return 'Reveals helpful information about the breed\'s characteristics and history.';
      case PowerUpType.extraTime:
        return 'Adds 5 extra seconds to the current question timer.';
      case PowerUpType.skip:
        return 'Skip the current question without losing a life.';
      case PowerUpType.secondChance:
        return 'Restores one life when you make an incorrect answer.';
      case PowerUpType.fiftyFifty:
        return 'Not available in Breed Adventure mode.';
    }
  }

  /// Check if power-up is available in breed adventure mode
  bool isPowerUpAvailableInBreedAdventure(PowerUpType powerUpType) {
    return powerUpType != PowerUpType.fiftyFifty;
  }
}
