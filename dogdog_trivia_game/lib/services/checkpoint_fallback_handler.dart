import 'package:flutter/foundation.dart';
import '../models/enums.dart';
import '../models/question.dart';
import '../controllers/game_controller.dart';
import '../controllers/treasure_map_controller.dart';
import '../controllers/power_up_controller.dart';
import '../services/question_pool_manager.dart';
import '../services/checkpoint_rewards.dart';

/// Handles checkpoint fallback scenarios when players run out of lives
class CheckpointFallbackHandler {
  static final CheckpointFallbackHandler _instance =
      CheckpointFallbackHandler._internal();
  factory CheckpointFallbackHandler() => _instance;
  CheckpointFallbackHandler._internal();

  final QuestionPoolManager _questionPoolManager = QuestionPoolManager();

  /// Handles game over scenarios with checkpoint fallback logic
  ///
  /// [gameController] - The game controller managing the current game state
  /// [treasureMapController] - The treasure map controller tracking progress
  /// [powerUpController] - The power-up controller managing inventory
  ///
  /// Returns a [CheckpointFallbackResult] indicating what action was taken
  CheckpointFallbackResult handleGameOver({
    required GameController gameController,
    required TreasureMapController treasureMapController,
    required PowerUpController powerUpController,
  }) {
    final lastCheckpoint = treasureMapController.lastCompletedCheckpoint;

    if (lastCheckpoint != null) {
      // Reset to last completed checkpoint
      return _resetToCheckpoint(
        checkpoint: lastCheckpoint,
        gameController: gameController,
        treasureMapController: treasureMapController,
        powerUpController: powerUpController,
      );
    } else {
      // No checkpoints reached, restart from beginning
      return _restartFromBeginning(
        gameController: gameController,
        treasureMapController: treasureMapController,
        powerUpController: powerUpController,
      );
    }
  }

  /// Resets the player to their last completed checkpoint with restored lives
  CheckpointFallbackResult _resetToCheckpoint({
    required Checkpoint checkpoint,
    required GameController gameController,
    required TreasureMapController treasureMapController,
    required PowerUpController powerUpController,
  }) {
    try {
      // Reset treasure map progress to the checkpoint
      treasureMapController.resetToCheckpoint(checkpoint);

      // Restore checkpoint power-ups (maintain earned power-ups from that checkpoint)
      final checkpointRewards = CheckpointRewards.getRewardsForCheckpoint(
        checkpoint,
        0.8, // Assume good performance for fallback scenario
      );

      // Add the checkpoint rewards to current inventory
      powerUpController.addPowerUps(checkpointRewards);

      // Reset and reshuffle question pool for fresh questions
      _resetQuestionPoolForCheckpoint(
        pathType: treasureMapController.currentPath,
        checkpoint: checkpoint,
      );

      return CheckpointFallbackResult(
        action: FallbackAction.resetToCheckpoint,
        checkpoint: checkpoint,
        message: _getCheckpointFallbackMessage(checkpoint),
        restoredLives: 3,
        awardedPowerUps: checkpointRewards,
      );
    } catch (error, stackTrace) {
      debugPrint('Error in checkpoint fallback: $error');
      debugPrint('Stack trace: $stackTrace');

      // Fallback to restart if checkpoint reset fails
      return _restartFromBeginning(
        gameController: gameController,
        treasureMapController: treasureMapController,
        powerUpController: powerUpController,
      );
    }
  }

  /// Restarts the game from the beginning of the selected path
  CheckpointFallbackResult _restartFromBeginning({
    required GameController gameController,
    required TreasureMapController treasureMapController,
    required PowerUpController powerUpController,
  }) {
    try {
      // Reset treasure map to beginning
      treasureMapController.resetPath();

      // Reset question pool for the path
      _resetQuestionPoolForPath(treasureMapController.currentPath);

      return CheckpointFallbackResult(
        action: FallbackAction.restartFromBeginning,
        checkpoint: null,
        message: _getPathRestartMessage(treasureMapController.currentPath),
        restoredLives: 3,
        awardedPowerUps: {},
      );
    } catch (error, stackTrace) {
      debugPrint('Error in path restart: $error');
      debugPrint('Stack trace: $stackTrace');

      return CheckpointFallbackResult(
        action: FallbackAction.error,
        checkpoint: null,
        message: 'An error occurred. Please restart the game.',
        restoredLives: 3,
        awardedPowerUps: {},
      );
    }
  }

  /// Resets the question pool for checkpoint restart scenarios
  void _resetQuestionPoolForCheckpoint({
    required PathType pathType,
    required Checkpoint checkpoint,
  }) {
    // Reset question pool while preserving answered IDs from completed checkpoints
    final preserveAnsweredIds = <String>{};

    // In a real implementation, we would load the answered question IDs
    // from persistent storage for the completed checkpoints
    // For now, we'll reset the pool completely for fresh questions

    _questionPoolManager.resetQuestionPool(
      pathType: pathType,
      preserveAnsweredIds: preserveAnsweredIds,
    );
  }

  /// Resets the question pool for path restart scenarios
  void _resetQuestionPoolForPath(PathType pathType) {
    // Complete reset for path restart
    _questionPoolManager.resetQuestionPool(
      pathType: pathType,
      preserveAnsweredIds: <String>{},
    );
  }

  /// Gets a user-friendly message explaining the checkpoint fallback
  String _getCheckpointFallbackMessage(Checkpoint checkpoint) {
    switch (checkpoint) {
      case Checkpoint.chihuahua:
        return 'Don\'t worry! You\'ve been reset to the Chihuahua checkpoint. '
            'Your progress and power-ups have been restored. Keep going!';
      case Checkpoint.pug:
        return 'You\'ve been reset to the Pug checkpoint. '
            'Your earned power-ups are still with you. Keep pushing forward!';
      case Checkpoint.cockerSpaniel:
        return 'You\'ve been reset to the Cocker Spaniel checkpoint. '
            'Your earned power-ups are still with you. Try again!';
      case Checkpoint.germanShepherd:
        return 'Back to the German Shepherd checkpoint! '
            'You\'ve kept all your earned power-ups. You can do this!';
      case Checkpoint.greatDane:
        return 'Reset to the Great Dane checkpoint. '
            'You\'re so close to the end! Use your power-ups wisely.';
      case Checkpoint.deutscheDogge:
        return 'You\'ve reached the final checkpoint! '
            'All your power-ups are restored. One more push to victory!';
    }
  }

  /// Gets a user-friendly message explaining the path restart
  String _getPathRestartMessage(PathType pathType) {
    return 'Starting fresh on the ${pathType.displayName} path. '
        'You haven\'t reached any checkpoints yet, but every expert started here. '
        'Good luck on your treasure hunt!';
  }

  /// Validates that a checkpoint fallback can be performed
  bool canPerformCheckpointFallback({
    required TreasureMapController treasureMapController,
  }) {
    return treasureMapController.lastCompletedCheckpoint != null;
  }

  /// Gets the next available questions for checkpoint restart
  /// This ensures fresh questions are provided after fallback
  List<Question> getQuestionsForCheckpointRestart({
    required PathType pathType,
    required Checkpoint checkpoint,
    required Set<String> excludeQuestionIds,
    required int count,
  }) {
    final checkpointLevel = _getCheckpointDifficultyLevel(checkpoint);

    return _questionPoolManager.getQuestionsForCheckpointRestart(
      pathType: pathType,
      excludeQuestionIds: excludeQuestionIds,
      count: count,
      checkpointLevel: checkpointLevel,
    );
  }

  /// Gets the difficulty level for a checkpoint
  int _getCheckpointDifficultyLevel(Checkpoint checkpoint) {
    switch (checkpoint) {
      case Checkpoint.chihuahua:
        return 1;
      case Checkpoint.pug:
        return 2;
      case Checkpoint.cockerSpaniel:
        return 3;
      case Checkpoint.germanShepherd:
        return 4;
      case Checkpoint.greatDane:
        return 5;
      case Checkpoint.deutscheDogge:
        return 6;
    }
  }

  /// Checks if enough questions are available for checkpoint restart
  bool hasEnoughQuestionsForRestart({
    required PathType pathType,
    required Set<String> excludeQuestionIds,
    required int requiredCount,
  }) {
    return _questionPoolManager.hasEnoughQuestions(
      pathType: pathType,
      excludeQuestionIds: excludeQuestionIds,
      requiredCount: requiredCount,
    );
  }

  /// Gets statistics about the fallback operation for debugging
  Map<String, dynamic> getFallbackStatistics({
    required CheckpointFallbackResult result,
    required TreasureMapController treasureMapController,
  }) {
    return {
      'action': result.action.name,
      'checkpoint': result.checkpoint?.displayName,
      'currentPath': treasureMapController.currentPath.displayName,
      'completedCheckpoints': treasureMapController.completedCheckpoints.length,
      'questionsAnswered': treasureMapController.currentQuestionCount,
      'restoredLives': result.restoredLives,
      'awardedPowerUps': result.awardedPowerUps.length,
      'message': result.message,
    };
  }
}

/// Represents the result of a checkpoint fallback operation
class CheckpointFallbackResult {
  final FallbackAction action;
  final Checkpoint? checkpoint;
  final String message;
  final int restoredLives;
  final Map<PowerUpType, int> awardedPowerUps;

  const CheckpointFallbackResult({
    required this.action,
    required this.checkpoint,
    required this.message,
    required this.restoredLives,
    required this.awardedPowerUps,
  });

  @override
  String toString() {
    return 'CheckpointFallbackResult('
        'action: $action, '
        'checkpoint: ${checkpoint?.displayName}, '
        'message: $message, '
        'restoredLives: $restoredLives, '
        'awardedPowerUps: ${awardedPowerUps.length})';
  }
}

/// Enum representing the different fallback actions that can be taken
enum FallbackAction { resetToCheckpoint, restartFromBeginning, error }
