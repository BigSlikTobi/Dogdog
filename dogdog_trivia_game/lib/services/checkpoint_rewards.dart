import '../models/enums.dart';

/// Service class that manages power-up distribution based on checkpoint achievements
class CheckpointRewards {
  /// Gets the power-up rewards for completing a specific checkpoint
  ///
  /// [checkpoint] - The checkpoint that was completed
  /// [accuracy] - The accuracy percentage (0.0 to 1.0) achieved at this checkpoint
  ///
  /// Returns a map of power-up types to their awarded counts
  static Map<PowerUpType, int> getRewardsForCheckpoint(
    Checkpoint checkpoint,
    double accuracy,
  ) {
    final baseRewards = _getBaseRewards(checkpoint);
    final bonusRewards = _getBonusRewards(checkpoint, accuracy);

    // Merge base and bonus rewards
    final totalRewards = <PowerUpType, int>{};
    for (final type in PowerUpType.values) {
      totalRewards[type] = (baseRewards[type] ?? 0) + (bonusRewards[type] ?? 0);
    }

    return totalRewards;
  }

  /// Gets the base power-up rewards for each checkpoint
  /// These are the guaranteed rewards regardless of performance
  static Map<PowerUpType, int> _getBaseRewards(Checkpoint checkpoint) {
    switch (checkpoint) {
      case Checkpoint.chihuahua:
        return {
          PowerUpType.fiftyFifty: 2,
          PowerUpType.hint: 2,
          PowerUpType.extraTime: 1,
          PowerUpType.skip: 0,
          PowerUpType.secondChance: 0,
        };
      case Checkpoint.pug:
        return {
          PowerUpType.fiftyFifty: 2,
          PowerUpType.hint: 2,
          PowerUpType.extraTime: 1,
          PowerUpType.skip: 1,
          PowerUpType.secondChance: 0,
        };
      case Checkpoint.cockerSpaniel:
        return {
          PowerUpType.fiftyFifty: 2,
          PowerUpType.hint: 2,
          PowerUpType.extraTime: 2,
          PowerUpType.skip: 1,
          PowerUpType.secondChance: 0,
        };
      case Checkpoint.germanShepherd:
        return {
          PowerUpType.fiftyFifty: 2,
          PowerUpType.hint: 2,
          PowerUpType.extraTime: 2,
          PowerUpType.skip: 2,
          PowerUpType.secondChance: 1,
        };
      case Checkpoint.greatDane:
        return {
          PowerUpType.fiftyFifty: 3,
          PowerUpType.hint: 3,
          PowerUpType.extraTime: 3,
          PowerUpType.skip: 3,
          PowerUpType.secondChance: 3,
        };
      case Checkpoint.deutscheDogge:
        return {
          PowerUpType.fiftyFifty: 4,
          PowerUpType.hint: 4,
          PowerUpType.extraTime: 4,
          PowerUpType.skip: 4,
          PowerUpType.secondChance: 4,
        };
    }
  }

  /// Gets bonus power-up rewards based on performance
  /// High accuracy (80%+) gets bonus power-ups including guaranteed skip and secondChance
  static Map<PowerUpType, int> _getBonusRewards(
    Checkpoint checkpoint,
    double accuracy,
  ) {
    if (accuracy >= 0.8) {
      // 80%+ accuracy gets bonus power-ups including skip and secondChance
      return {
        PowerUpType.fiftyFifty: 1,
        PowerUpType.hint: 1,
        PowerUpType.extraTime: 1,
        PowerUpType.skip: 1,
        PowerUpType.secondChance: 1,
      };
    }
    return {
      PowerUpType.fiftyFifty: 0,
      PowerUpType.hint: 0,
      PowerUpType.extraTime: 0,
      PowerUpType.skip: 0,
      PowerUpType.secondChance: 0,
    };
  }

  /// Gets the total number of power-ups that would be awarded for a checkpoint
  /// Useful for UI display purposes
  static int getTotalRewardCount(Checkpoint checkpoint, double accuracy) {
    final rewards = getRewardsForCheckpoint(checkpoint, accuracy);
    return rewards.values.fold(0, (sum, count) => sum + count);
  }

  /// Gets a preview of rewards for a checkpoint (for UI display)
  /// Returns both base and potential bonus rewards
  static Map<String, Map<PowerUpType, int>> getRewardPreview(
    Checkpoint checkpoint,
  ) {
    return {
      'base': _getBaseRewards(checkpoint),
      'bonus': _getBonusRewards(checkpoint, 0.8), // Show bonus for 80% accuracy
    };
  }

  /// Validates that all power-up types are properly distributed across checkpoints
  /// Returns true if the distribution is balanced
  static bool validateDistribution() {
    // Check that all power-up types are available by Deutsche Dogge checkpoint
    final finalRewards = _getBaseRewards(Checkpoint.deutscheDogge);

    for (final type in PowerUpType.values) {
      if ((finalRewards[type] ?? 0) == 0) {
        return false; // Power-up type not available at final checkpoint
      }
    }

    // Check progressive distribution - each checkpoint should have equal or more rewards
    final checkpoints = Checkpoint.values;
    for (int i = 1; i < checkpoints.length; i++) {
      final currentRewards = _getBaseRewards(checkpoints[i]);
      final previousRewards = _getBaseRewards(checkpoints[i - 1]);

      for (final type in PowerUpType.values) {
        final currentCount = currentRewards[type] ?? 0;
        final previousCount = previousRewards[type] ?? 0;

        // Allow for some power-ups to be introduced later (skip, secondChance)
        // but once introduced, they should not decrease
        if (previousCount > 0 && currentCount < previousCount) {
          return false; // Regression in power-up count
        }
      }
    }

    return true;
  }
}
