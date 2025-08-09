import 'package:flutter/foundation.dart';
import '../models/enums.dart';

/// Controller for managing treasure map progression and checkpoint tracking
class TreasureMapController extends ChangeNotifier {
  PathType _currentPath = PathType.dogBreeds;
  int _currentQuestionCount = 0;
  Checkpoint? _lastCompletedCheckpoint;
  final Set<Checkpoint> _completedCheckpoints = <Checkpoint>{};

  /// Current selected path
  PathType get currentPath => _currentPath;

  /// Current number of questions answered in this path
  int get currentQuestionCount => _currentQuestionCount;

  /// Last checkpoint that was completed
  Checkpoint? get lastCompletedCheckpoint => _lastCompletedCheckpoint;

  /// Set of all completed checkpoints
  Set<Checkpoint> get completedCheckpoints =>
      Set.unmodifiable(_completedCheckpoints);

  /// Get the next checkpoint to reach
  Checkpoint? get nextCheckpoint {
    for (final checkpoint in Checkpoint.values) {
      if (!_completedCheckpoints.contains(checkpoint)) {
        return checkpoint;
      }
    }
    return null; // All checkpoints completed
  }

  /// Get number of questions remaining to reach the next checkpoint
  int get questionsToNextCheckpoint {
    final next = nextCheckpoint;
    if (next == null) return 0;
    return next.questionsRequired - _currentQuestionCount;
  }

  /// Get progress percentage to the next checkpoint (0.0 to 1.0)
  double get progressToNextCheckpoint {
    final next = nextCheckpoint;
    if (next == null) return 1.0;

    final previousCheckpointQuestions =
        _lastCompletedCheckpoint?.questionsRequired ?? 0;
    final questionsInCurrentSegment =
        _currentQuestionCount - previousCheckpointQuestions;
    final questionsNeededForSegment =
        next.questionsRequired - previousCheckpointQuestions;

    if (questionsNeededForSegment <= 0) return 1.0;
    return (questionsInCurrentSegment / questionsNeededForSegment).clamp(
      0.0,
      1.0,
    );
  }

  /// Check if the current path is completed (all checkpoints reached)
  bool get isPathCompleted =>
      _completedCheckpoints.length == Checkpoint.values.length;

  /// Initialize a new path
  void initializePath(PathType path) {
    _currentPath = path;
    _currentQuestionCount = 0;
    _lastCompletedCheckpoint = null;
    _completedCheckpoints.clear();
    notifyListeners();
  }

  /// Increment the question count and check for checkpoint completion
  void incrementQuestionCount() {
    _currentQuestionCount++;
    _checkForCheckpointCompletion();
    notifyListeners();
  }

  /// Mark a checkpoint as completed
  void completeCheckpoint(Checkpoint checkpoint) {
    if (!_completedCheckpoints.contains(checkpoint)) {
      _completedCheckpoints.add(checkpoint);
      _lastCompletedCheckpoint = checkpoint;
      notifyListeners();
    }
  }

  /// Reset progress to a specific checkpoint (for fallback scenarios)
  void resetToCheckpoint(Checkpoint checkpoint) {
    _currentQuestionCount = checkpoint.questionsRequired;
    _lastCompletedCheckpoint = checkpoint;

    // Remove any checkpoints that come after this one
    _completedCheckpoints.removeWhere(
      (c) => c.questionsRequired > checkpoint.questionsRequired,
    );

    // Ensure this checkpoint is marked as completed
    _completedCheckpoints.add(checkpoint);

    notifyListeners();
  }

  /// Reset the entire path progress
  void resetPath() {
    _currentQuestionCount = 0;
    _lastCompletedCheckpoint = null;
    _completedCheckpoints.clear();
    notifyListeners();
  }

  /// Check if a checkpoint should be completed based on current question count
  void _checkForCheckpointCompletion() {
    for (final checkpoint in Checkpoint.values) {
      if (_currentQuestionCount >= checkpoint.questionsRequired &&
          !_completedCheckpoints.contains(checkpoint)) {
        completeCheckpoint(checkpoint);
        break; // Only complete one checkpoint at a time
      }
    }
  }

  /// Get the current checkpoint segment (for UI display)
  String get currentSegmentDisplay {
    final next = nextCheckpoint;
    if (next == null) {
      return 'Path Completed!';
    }

    final previousQuestions = _lastCompletedCheckpoint?.questionsRequired ?? 0;
    final questionsInSegment = _currentQuestionCount - previousQuestions;
    final questionsNeeded = next.questionsRequired - previousQuestions;

    return '$questionsInSegment/$questionsNeeded questions to ${next.displayName}';
  }
}
