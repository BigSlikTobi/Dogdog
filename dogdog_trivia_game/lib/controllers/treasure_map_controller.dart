import 'package:flutter/foundation.dart';
import '../models/enums.dart';
import '../models/category_progress.dart';
import '../services/progress_service.dart';
import '../services/category_progress_service.dart';

/// Controller for managing treasure map progression and checkpoint tracking with category support
class TreasureMapController extends ChangeNotifier {
  PathType _currentPath = PathType.dogBreeds;
  QuestionCategory? _selectedCategory;
  int _currentQuestionCount = 0;
  Checkpoint? _lastCompletedCheckpoint;
  final Set<Checkpoint> _completedCheckpoints = <Checkpoint>{};

  // Category-specific progress tracking
  final Map<QuestionCategory, CategoryProgress> _categoryProgress = {};
  final ProgressService _progressService = ProgressService();
  final CategoryProgressService _categoryProgressService =
      CategoryProgressService();

  // Available categories (can be dynamically updated)
  final List<QuestionCategory> _availableCategories = [
    QuestionCategory.dogTraining,
    QuestionCategory.dogBreeds,
    QuestionCategory.dogBehavior,
    QuestionCategory.dogHealth,
    QuestionCategory.dogHistory,
  ];

  /// Current selected path
  PathType get currentPath => _currentPath;

  /// Currently selected question category
  QuestionCategory? get selectedCategory => _selectedCategory;

  /// Current number of questions answered in this path
  int get currentQuestionCount => _currentQuestionCount;

  /// Last checkpoint that was completed
  Checkpoint? get lastCompletedCheckpoint => _lastCompletedCheckpoint;

  /// Set of all completed checkpoints
  Set<Checkpoint> get completedCheckpoints =>
      Set.unmodifiable(_completedCheckpoints);

  /// Available categories for selection
  List<QuestionCategory> get availableCategories =>
      List.unmodifiable(_availableCategories);

  /// Get progress for the currently selected category
  CategoryProgress? get currentCategoryProgress {
    if (_selectedCategory == null) return null;
    return _categoryProgress[_selectedCategory];
  }

  /// Get progress for a specific category
  CategoryProgress? getCategoryProgress(QuestionCategory category) {
    return _categoryProgress[category];
  }

  /// Get all category progress data
  Map<QuestionCategory, CategoryProgress> get allCategoryProgress =>
      Map.unmodifiable(_categoryProgress);

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

  /// Initialize the controller and load saved progress
  Future<void> initialize() async {
    await _categoryProgressService.initialize();
    await _loadCategoryProgress();
    await _restoreLastSelectedCategory();
    notifyListeners();
  }

  /// Restore the last selected category if available
  Future<void> _restoreLastSelectedCategory() async {
    try {
      final lastCategory = await _loadLastSelectedCategory();
      if (lastCategory != null) {
        // Only restore if we don't already have a selected category
        if (_selectedCategory == null) {
          selectCategory(lastCategory);
        }
      }
    } catch (e) {
      debugPrint('Failed to restore last selected category: $e');
    }
  }

  /// Select a category for the treasure map journey
  void selectCategory(QuestionCategory category) {
    _selectedCategory = category;

    // Initialize category progress if it doesn't exist
    if (!_categoryProgress.containsKey(category)) {
      _categoryProgress[category] = CategoryProgress.initial(category);
    }

    // Update current path state based on category progress
    final categoryProgress = _categoryProgress[category]!;
    _currentQuestionCount = categoryProgress.questionsAnswered;
    _lastCompletedCheckpoint = categoryProgress.lastCompletedCheckpoint;
    _completedCheckpoints.clear();
    _completedCheckpoints.addAll(categoryProgress.completedCheckpoints);

    notifyListeners();
  }

  /// Initialize a new path
  void initializePath(PathType path) {
    _currentPath = path;
    _currentQuestionCount = 0;
    _lastCompletedCheckpoint = null;
    _completedCheckpoints.clear();
    notifyListeners();
  }

  /// Increment the question count and check for checkpoint completion
  void incrementQuestionCount({
    bool isCorrect = false,
    int scoreEarned = 0,
    String? questionId,
  }) {
    _currentQuestionCount++;

    // Update category-specific progress
    if (_selectedCategory != null) {
      _updateCategoryProgress(
        isCorrect: isCorrect,
        scoreEarned: scoreEarned,
        questionId: questionId,
      );
    }

    _checkForCheckpointCompletion();
    notifyListeners();
  }

  /// Update progress for the currently selected category
  void _updateCategoryProgress({
    required bool isCorrect,
    required int scoreEarned,
    String? questionId,
  }) {
    if (_selectedCategory == null) return;

    final currentProgress =
        _categoryProgress[_selectedCategory] ??
        CategoryProgress.initial(_selectedCategory!);

    final updatedUsedIds = questionId != null
        ? [...currentProgress.usedQuestionIds, questionId]
        : currentProgress.usedQuestionIds;

    _categoryProgress[_selectedCategory!] = currentProgress.copyWith(
      questionsAnswered: currentProgress.questionsAnswered + 1,
      correctAnswers: isCorrect
          ? currentProgress.correctAnswers + 1
          : currentProgress.correctAnswers,
      totalScore: currentProgress.totalScore + scoreEarned,
      usedQuestionIds: updatedUsedIds,
      lastPlayedAt: DateTime.now(),
      completedCheckpoints: Set.from(_completedCheckpoints),
      lastCompletedCheckpoint: _lastCompletedCheckpoint,
    );

    // Auto-save progress after each update
    saveCategoryProgress();
  }

  /// Update category progress from game session results
  Future<void> updateProgressFromGameSession({
    required QuestionCategory category,
    required int questionsAnswered,
    required int correctAnswers,
    required int scoreEarned,
    required List<String> answeredQuestionIds,
    Set<Checkpoint>? newCheckpoints,
  }) async {
    try {
      final currentProgress =
          _categoryProgress[category] ?? CategoryProgress.initial(category);

      // Merge used question IDs to avoid duplicates
      final allUsedIds = <String>{
        ...currentProgress.usedQuestionIds,
        ...answeredQuestionIds,
      }.toList();

      // Update completed checkpoints
      final updatedCheckpoints = <Checkpoint>{
        ...currentProgress.completedCheckpoints,
        if (newCheckpoints != null) ...newCheckpoints,
      };

      // Find the latest completed checkpoint
      Checkpoint? latestCheckpoint;
      if (updatedCheckpoints.isNotEmpty) {
        latestCheckpoint = updatedCheckpoints.reduce(
          (a, b) => a.questionsRequired > b.questionsRequired ? a : b,
        );
      }

      _categoryProgress[category] = currentProgress.copyWith(
        questionsAnswered:
            currentProgress.questionsAnswered + questionsAnswered,
        correctAnswers: currentProgress.correctAnswers + correctAnswers,
        totalScore: currentProgress.totalScore + scoreEarned,
        usedQuestionIds: allUsedIds,
        lastPlayedAt: DateTime.now(),
        completedCheckpoints: updatedCheckpoints,
        lastCompletedCheckpoint: latestCheckpoint,
      );

      // Update current state if this is the selected category
      if (_selectedCategory == category) {
        final updatedProgress = _categoryProgress[category]!;
        _currentQuestionCount = updatedProgress.questionsAnswered;
        _lastCompletedCheckpoint = updatedProgress.lastCompletedCheckpoint;
        _completedCheckpoints.clear();
        _completedCheckpoints.addAll(updatedProgress.completedCheckpoints);
      }

      await saveCategoryProgress();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to update progress from game session: $e');
    }
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
    if (_selectedCategory != null) {
      final categoryProgress = _categoryProgress[_selectedCategory];
      return categoryProgress?.currentSegmentDisplay ?? 'No progress';
    }

    final next = nextCheckpoint;
    if (next == null) {
      return 'Path Completed!';
    }

    final previousQuestions = _lastCompletedCheckpoint?.questionsRequired ?? 0;
    final questionsInSegment = _currentQuestionCount - previousQuestions;
    final questionsNeeded = next.questionsRequired - previousQuestions;

    return '$questionsInSegment/$questionsNeeded questions to ${next.displayName}';
  }

  /// Save category progress to persistent storage
  Future<void> saveCategoryProgress() async {
    try {
      await _categoryProgressService.saveCategoryProgress(_categoryProgress);
      await _saveLastSelectedCategory();
    } catch (e) {
      debugPrint('Failed to save category progress: $e');
    }
  }

  /// Save the last selected category for memory
  Future<void> _saveLastSelectedCategory() async {
    try {
      if (_selectedCategory != null) {
        await _categoryProgressService.saveLastSelectedCategory(
          _selectedCategory!,
        );
      }
    } catch (e) {
      debugPrint('Failed to save last selected category: $e');
    }
  }

  /// Load the last selected category from storage (public method)
  Future<QuestionCategory?> loadLastSelectedCategory() async {
    return await _loadLastSelectedCategory();
  }

  /// Load the last selected category from storage
  Future<QuestionCategory?> _loadLastSelectedCategory() async {
    try {
      return await _categoryProgressService.loadLastSelectedCategory();
    } catch (e) {
      debugPrint('Failed to load last selected category: $e');
    }
    return null;
  }

  /// Load category progress from persistent storage
  Future<void> _loadCategoryProgress() async {
    try {
      final progressData = await _progressService.loadCustomData(
        'category_progress',
      );

      if (progressData is Map<String, dynamic>) {
        _categoryProgress.clear();

        for (final entry in progressData.entries) {
          try {
            final category = QuestionCategory.values.firstWhere(
              (c) => c.name == entry.key,
              orElse: () => QuestionCategory.dogBreeds,
            );

            final progress = CategoryProgress.fromJson(
              entry.value as Map<String, dynamic>,
            );
            _categoryProgress[category] = progress;
          } catch (e) {
            debugPrint('Failed to load progress for category ${entry.key}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load category progress: $e');
    }
  }

  /// Reset progress for a specific category
  void resetCategoryProgress(QuestionCategory category) {
    _categoryProgress[category] = CategoryProgress.initial(category);

    if (_selectedCategory == category) {
      _currentQuestionCount = 0;
      _lastCompletedCheckpoint = null;
      _completedCheckpoints.clear();
    }

    saveCategoryProgress();
    notifyListeners();
  }

  /// Reset all category progress
  void resetAllCategoryProgress() {
    _categoryProgress.clear();
    _selectedCategory = null;
    _currentQuestionCount = 0;
    _lastCompletedCheckpoint = null;
    _completedCheckpoints.clear();

    saveCategoryProgress();
    notifyListeners();
  }

  /// Get used question IDs for the current category to avoid repeats
  List<String> getUsedQuestionIds() {
    if (_selectedCategory == null) return [];
    return _categoryProgress[_selectedCategory]?.usedQuestionIds ?? [];
  }

  /// Check if a category has any progress
  bool hasCategoryProgress(QuestionCategory category) {
    final progress = _categoryProgress[category];
    return progress != null && progress.questionsAnswered > 0;
  }

  /// Get the most recently played category
  QuestionCategory? getMostRecentCategory() {
    if (_categoryProgress.isEmpty) return null;

    return _categoryProgress.entries
        .reduce(
          (a, b) => a.value.lastPlayedAt.isAfter(b.value.lastPlayedAt) ? a : b,
        )
        .key;
  }

  /// Get categories sorted by progress (most progress first)
  List<QuestionCategory> getCategoriesByProgress() {
    final categoriesWithProgress = _categoryProgress.entries.toList();
    categoriesWithProgress.sort(
      (a, b) => b.value.questionsAnswered.compareTo(a.value.questionsAnswered),
    );

    final sortedCategories = categoriesWithProgress.map((e) => e.key).toList();

    // Add categories without progress at the end
    for (final category in _availableCategories) {
      if (!sortedCategories.contains(category)) {
        sortedCategories.add(category);
      }
    }

    return sortedCategories;
  }

  /// Update available categories (for dynamic category management)
  void updateAvailableCategories(List<QuestionCategory> categories) {
    _availableCategories.clear();
    _availableCategories.addAll(categories);
    notifyListeners();
  }

  /// Validates the integrity of category progress data
  Future<bool> validateProgressIntegrity() async {
    try {
      bool hasIssues = false;
      final fixedProgress = <QuestionCategory, CategoryProgress>{};

      for (final entry in _categoryProgress.entries) {
        final category = entry.key;
        final progress = entry.value;

        // Validate basic constraints
        if (progress.correctAnswers > progress.questionsAnswered) {
          debugPrint(
            'Data integrity issue: More correct answers than total for $category',
          );
          hasIssues = true;

          // Fix by capping correct answers
          fixedProgress[category] = progress.copyWith(
            correctAnswers: progress.questionsAnswered,
          );
        } else if (progress.questionsAnswered < 0 ||
            progress.correctAnswers < 0) {
          debugPrint('Data integrity issue: Negative values for $category');
          hasIssues = true;

          // Fix by resetting to zero
          fixedProgress[category] = progress.copyWith(
            questionsAnswered: progress.questionsAnswered
                .clamp(0, double.infinity)
                .toInt(),
            correctAnswers: progress.correctAnswers
                .clamp(0, double.infinity)
                .toInt(),
          );
        }

        // Validate checkpoint consistency
        final maxCheckpointQuestions = progress.completedCheckpoints.isEmpty
            ? 0
            : progress.completedCheckpoints
                  .map((c) => c.questionsRequired)
                  .reduce((a, b) => a > b ? a : b);

        if (progress.questionsAnswered < maxCheckpointQuestions) {
          debugPrint(
            'Data integrity issue: Questions answered less than checkpoint requirements for $category',
          );
          hasIssues = true;

          // Fix by adjusting questions answered or removing invalid checkpoints
          final validCheckpoints = progress.completedCheckpoints
              .where((c) => c.questionsRequired <= progress.questionsAnswered)
              .toSet();

          fixedProgress[category] = progress.copyWith(
            completedCheckpoints: validCheckpoints,
            lastCompletedCheckpoint: validCheckpoints.isEmpty
                ? null
                : validCheckpoints.reduce(
                    (a, b) => a.questionsRequired > b.questionsRequired ? a : b,
                  ),
          );
        }
      }

      // Apply fixes if any issues were found
      if (hasIssues) {
        for (final entry in fixedProgress.entries) {
          _categoryProgress[entry.key] = entry.value;
        }
        await saveCategoryProgress();
        debugPrint(
          'Fixed ${fixedProgress.length} category progress integrity issues',
        );
      }

      return !hasIssues;
    } catch (e) {
      debugPrint('Error validating progress integrity: $e');
      return false;
    }
  }

  /// Creates a backup of current progress data
  Future<Map<String, dynamic>> createProgressBackup() async {
    try {
      final backup = <String, dynamic>{
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0',
        'categoryProgress': {},
        'selectedCategory': _selectedCategory?.name,
      };

      for (final entry in _categoryProgress.entries) {
        backup['categoryProgress'][entry.key.name] = entry.value.toJson();
      }

      return backup;
    } catch (e) {
      debugPrint('Error creating progress backup: $e');
      return {};
    }
  }

  /// Restores progress from a backup
  Future<bool> restoreProgressFromBackup(Map<String, dynamic> backup) async {
    try {
      if (backup['categoryProgress'] is Map<String, dynamic>) {
        final progressData = backup['categoryProgress'] as Map<String, dynamic>;
        _categoryProgress.clear();

        for (final entry in progressData.entries) {
          try {
            final category = QuestionCategory.values.firstWhere(
              (c) => c.name == entry.key,
              orElse: () => QuestionCategory.dogBreeds,
            );

            final progress = CategoryProgress.fromJson(
              entry.value as Map<String, dynamic>,
            );
            _categoryProgress[category] = progress;
          } catch (e) {
            debugPrint(
              'Failed to restore progress for category ${entry.key}: $e',
            );
          }
        }

        // Restore selected category if available
        if (backup['selectedCategory'] is String) {
          try {
            final categoryName = backup['selectedCategory'] as String;
            final category = QuestionCategory.values.firstWhere(
              (c) => c.name == categoryName,
            );
            selectCategory(category);
          } catch (e) {
            debugPrint('Failed to restore selected category: $e');
          }
        }

        await saveCategoryProgress();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error restoring progress from backup: $e');
    }
    return false;
  }

  @override
  void dispose() {
    saveCategoryProgress();
    super.dispose();
  }
}
