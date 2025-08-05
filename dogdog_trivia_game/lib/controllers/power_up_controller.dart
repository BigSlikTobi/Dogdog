import 'package:flutter/foundation.dart';
import '../models/enums.dart';
import '../models/question.dart';

/// Controller class that manages power-up inventory and functionality
class PowerUpController extends ChangeNotifier {
  Map<PowerUpType, int> _powerUps = {
    for (PowerUpType type in PowerUpType.values) type: 0,
  };

  /// Current power-up inventory
  Map<PowerUpType, int> get powerUps => Map.unmodifiable(_powerUps);

  /// Gets the count of a specific power-up type
  int getPowerUpCount(PowerUpType type) {
    return _powerUps[type] ?? 0;
  }

  /// Checks if a power-up is available for use
  bool canUsePowerUp(PowerUpType type) {
    return getPowerUpCount(type) > 0;
  }

  /// Adds power-ups to the inventory
  void addPowerUp(PowerUpType type, int count) {
    if (count <= 0) return;

    _powerUps[type] = (_powerUps[type] ?? 0) + count;
    notifyListeners();
  }

  /// Adds multiple power-ups at once
  void addPowerUps(Map<PowerUpType, int> powerUpsToAdd) {
    bool hasChanges = false;

    for (final entry in powerUpsToAdd.entries) {
      if (entry.value > 0) {
        _powerUps[entry.key] = (_powerUps[entry.key] ?? 0) + entry.value;
        hasChanges = true;
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  /// Uses a power-up (decrements count by 1)
  /// Returns true if the power-up was successfully used
  bool usePowerUp(PowerUpType type) {
    if (!canUsePowerUp(type)) {
      return false;
    }

    _powerUps[type] = _powerUps[type]! - 1;
    notifyListeners();
    return true;
  }

  /// Applies the 50/50 power-up effect to a question
  /// Returns a list of answer indices that should be disabled (2 wrong answers)
  List<int> applyFiftyFifty(Question question) {
    if (!canUsePowerUp(PowerUpType.fiftyFifty)) {
      return [];
    }

    final correctIndex = question.correctAnswerIndex;
    final wrongIndices = <int>[];

    // Collect all wrong answer indices
    for (int i = 0; i < question.answers.length; i++) {
      if (i != correctIndex) {
        wrongIndices.add(i);
      }
    }

    // Shuffle and take first 2 wrong answers to remove
    wrongIndices.shuffle();
    final indicesToRemove = wrongIndices.take(2).toList();

    return indicesToRemove;
  }

  /// Gets the hint text for a question (if available)
  /// Returns null if no hint is available or power-up cannot be used
  String? applyHint(Question question) {
    if (!canUsePowerUp(PowerUpType.hint)) {
      return null;
    }

    return question.hint;
  }

  /// Applies extra time power-up
  /// Returns the number of seconds to add to the timer
  int applyExtraTime() {
    if (!canUsePowerUp(PowerUpType.extraTime)) {
      return 0;
    }

    return 10; // Add 10 seconds as specified in requirements
  }

  /// Applies skip power-up
  /// Returns true if skip was successful
  bool applySkip() {
    return canUsePowerUp(PowerUpType.skip);
  }

  /// Applies second chance power-up
  /// Returns true if second chance was successful
  bool applySecondChance() {
    return canUsePowerUp(PowerUpType.secondChance);
  }

  /// Sets the power-up inventory (used for loading saved state)
  void setPowerUps(Map<PowerUpType, int> newPowerUps) {
    _powerUps = Map.from(newPowerUps);
    notifyListeners();
  }

  /// Resets all power-ups to zero
  void resetPowerUps() {
    _powerUps = {for (PowerUpType type in PowerUpType.values) type: 0};
    notifyListeners();
  }

  /// Gets total count of all power-ups
  int get totalPowerUpCount {
    return _powerUps.values.fold(0, (sum, count) => sum + count);
  }

  /// Converts power-ups to JSON format for persistence
  Map<String, dynamic> toJson() {
    return _powerUps.map((key, value) => MapEntry(key.name, value));
  }

  /// Loads power-ups from JSON format
  void fromJson(Map<String, dynamic> json) {
    final newPowerUps = <PowerUpType, int>{};

    for (final entry in json.entries) {
      try {
        final powerUpType = PowerUpType.values.firstWhere(
          (type) => type.name == entry.key,
        );
        newPowerUps[powerUpType] = entry.value as int;
      } catch (e) {
        debugPrint('Unknown power-up type: ${entry.key}');
      }
    }

    // Ensure all power-up types are present
    for (final type in PowerUpType.values) {
      newPowerUps[type] ??= 0;
    }

    _powerUps = newPowerUps;
    notifyListeners();
  }

  @override
  String toString() {
    return 'PowerUpController(powerUps: $_powerUps)';
  }
}
