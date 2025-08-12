import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/category_progress.dart';
import '../models/enums.dart';
import 'progress_service.dart';

/// Service for managing category-specific progress with enhanced persistence and integrity
class CategoryProgressService {
  static final CategoryProgressService _instance =
      CategoryProgressService._internal();
  factory CategoryProgressService() => _instance;
  CategoryProgressService._internal();

  final ProgressService _progressService = ProgressService();
  Timer? _backupTimer;

  static const String _categoryProgressKey = 'category_progress';
  static const String _lastSelectedCategoryKey = 'last_selected_category';
  static const String _progressBackupKey = 'category_progress_backup';
  static const String _integrityCheckKey = 'last_integrity_check';

  /// Initialize the service and start periodic backups
  Future<void> initialize() async {
    await _progressService.initialize();
    _startPeriodicBackups();
    await _performIntegrityCheck();
  }

  /// Start periodic backups every 5 minutes
  void _startPeriodicBackups() {
    _backupTimer?.cancel();
    _backupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _createAutomaticBackup();
    });
  }

  /// Save category progress with validation
  Future<bool> saveCategoryProgress(
    Map<QuestionCategory, CategoryProgress> progress,
  ) async {
    try {
      // Validate data before saving
      final validatedProgress = await _validateAndFixProgress(progress);

      final progressData = <String, dynamic>{};
      for (final entry in validatedProgress.entries) {
        progressData[entry.key.name] = entry.value.toJson();
      }

      await _progressService.saveCustomData(_categoryProgressKey, progressData);

      // Update last save timestamp
      await _progressService.saveCustomData('last_progress_save', {
        'timestamp': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Failed to save category progress: $e');
      return false;
    }
  }

  /// Load category progress with integrity validation
  Future<Map<QuestionCategory, CategoryProgress>> loadCategoryProgress() async {
    try {
      final progressData = await _progressService.loadCustomData(
        _categoryProgressKey,
      );

      if (progressData is Map<String, dynamic>) {
        final progress = <QuestionCategory, CategoryProgress>{};

        for (final entry in progressData.entries) {
          try {
            final category = QuestionCategory.values.firstWhere(
              (c) => c.name == entry.key,
              orElse: () => QuestionCategory.dogBreeds,
            );

            final categoryProgress = CategoryProgress.fromJson(
              entry.value as Map<String, dynamic>,
            );

            progress[category] = categoryProgress;
          } catch (e) {
            debugPrint('Failed to load progress for category ${entry.key}: $e');
          }
        }

        // Validate loaded data
        return await _validateAndFixProgress(progress);
      }
    } catch (e) {
      debugPrint('Failed to load category progress: $e');
    }

    return {};
  }

  /// Save the last selected category
  Future<bool> saveLastSelectedCategory(QuestionCategory category) async {
    try {
      await _progressService.saveCustomData(_lastSelectedCategoryKey, {
        'categoryName': category.name,
      });
      return true;
    } catch (e) {
      debugPrint('Failed to save last selected category: $e');
      return false;
    }
  }

  /// Load the last selected category
  Future<QuestionCategory?> loadLastSelectedCategory() async {
    try {
      final categoryData = await _progressService.loadCustomData(
        _lastSelectedCategoryKey,
      );

      if (categoryData is Map<String, dynamic> &&
          categoryData['categoryName'] is String) {
        final categoryName = categoryData['categoryName'] as String;
        return QuestionCategory.values.firstWhere(
          (c) => c.name == categoryName,
          orElse: () => QuestionCategory.dogBreeds,
        );
      }
    } catch (e) {
      debugPrint('Failed to load last selected category: $e');
    }
    return null;
  }

  /// Create a backup of current progress
  Future<bool> createBackup(
    Map<QuestionCategory, CategoryProgress> progress,
  ) async {
    try {
      final backup = {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0',
        'categoryProgress': {},
      };

      for (final entry in progress.entries) {
        final categoryProgress =
            backup['categoryProgress'] as Map<String, dynamic>;
        categoryProgress[entry.key.name] = entry.value.toJson();
      }

      await _progressService.saveCustomData(_progressBackupKey, backup);
      return true;
    } catch (e) {
      debugPrint('Failed to create progress backup: $e');
      return false;
    }
  }

  /// Restore progress from backup
  Future<Map<QuestionCategory, CategoryProgress>?> restoreFromBackup() async {
    try {
      final backup = await _progressService.loadCustomData(_progressBackupKey);

      if (backup is Map<String, dynamic> &&
          backup['categoryProgress'] is Map<String, dynamic>) {
        final progressData = backup['categoryProgress'] as Map<String, dynamic>;
        final progress = <QuestionCategory, CategoryProgress>{};

        for (final entry in progressData.entries) {
          try {
            final category = QuestionCategory.values.firstWhere(
              (c) => c.name == entry.key,
              orElse: () => QuestionCategory.dogBreeds,
            );

            final categoryProgress = CategoryProgress.fromJson(
              entry.value as Map<String, dynamic>,
            );

            progress[category] = categoryProgress;
          } catch (e) {
            debugPrint(
              'Failed to restore progress for category ${entry.key}: $e',
            );
          }
        }

        return progress;
      }
    } catch (e) {
      debugPrint('Failed to restore from backup: $e');
    }
    return null;
  }

  /// Validate and fix progress data integrity
  Future<Map<QuestionCategory, CategoryProgress>> _validateAndFixProgress(
    Map<QuestionCategory, CategoryProgress> progress,
  ) async {
    final validatedProgress = <QuestionCategory, CategoryProgress>{};
    bool hasIssues = false;

    for (final entry in progress.entries) {
      final category = entry.key;
      final categoryProgress = entry.value;

      // Validate basic constraints
      var fixedProgress = categoryProgress;

      // Fix negative values
      if (categoryProgress.questionsAnswered < 0 ||
          categoryProgress.correctAnswers < 0) {
        hasIssues = true;
        fixedProgress = categoryProgress.copyWith(
          questionsAnswered: categoryProgress.questionsAnswered
              .clamp(0, double.infinity)
              .toInt(),
          correctAnswers: categoryProgress.correctAnswers
              .clamp(0, double.infinity)
              .toInt(),
        );
      }

      // Fix impossible correct answers
      if (fixedProgress.correctAnswers > fixedProgress.questionsAnswered) {
        hasIssues = true;
        fixedProgress = fixedProgress.copyWith(
          correctAnswers: fixedProgress.questionsAnswered,
        );
      }

      // Validate checkpoint consistency
      final maxCheckpointQuestions = fixedProgress.completedCheckpoints.isEmpty
          ? 0
          : fixedProgress.completedCheckpoints
                .map((c) => c.questionsRequired)
                .reduce((a, b) => a > b ? a : b);

      if (fixedProgress.questionsAnswered < maxCheckpointQuestions) {
        hasIssues = true;

        // Remove invalid checkpoints
        final validCheckpoints = fixedProgress.completedCheckpoints
            .where(
              (c) => c.questionsRequired <= fixedProgress.questionsAnswered,
            )
            .toSet();

        fixedProgress = fixedProgress.copyWith(
          completedCheckpoints: validCheckpoints,
          lastCompletedCheckpoint: validCheckpoints.isEmpty
              ? null
              : validCheckpoints.reduce(
                  (a, b) => a.questionsRequired > b.questionsRequired ? a : b,
                ),
        );
      }

      validatedProgress[category] = fixedProgress;
    }

    if (hasIssues) {
      debugPrint('Fixed data integrity issues in category progress');
    }

    return validatedProgress;
  }

  /// Perform periodic integrity check
  Future<void> _performIntegrityCheck() async {
    try {
      final lastCheck = await _progressService.loadCustomData(
        _integrityCheckKey,
      );
      final now = DateTime.now();

      // Check if we need to perform integrity check (once per day)
      if (lastCheck is Map<String, dynamic> &&
          lastCheck['timestamp'] is String) {
        final lastCheckTime = DateTime.tryParse(
          lastCheck['timestamp'] as String,
        );
        if (lastCheckTime != null && now.difference(lastCheckTime).inDays < 1) {
          return; // Skip check if done recently
        }
      }

      // Load and validate current progress
      final progress = await loadCategoryProgress();
      await saveCategoryProgress(progress);

      // Update last check timestamp
      await _progressService.saveCustomData(_integrityCheckKey, {
        'timestamp': now.toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error during integrity check: $e');
    }
  }

  /// Create automatic backup
  Future<void> _createAutomaticBackup() async {
    try {
      final progress = await loadCategoryProgress();
      if (progress.isNotEmpty) {
        await createBackup(progress);
      }
    } catch (e) {
      debugPrint('Error creating automatic backup: $e');
    }
  }

  /// Get progress statistics
  Future<Map<String, dynamic>> getProgressStatistics() async {
    try {
      final progress = await loadCategoryProgress();

      int totalQuestions = 0;
      int totalCorrect = 0;
      int totalScore = 0;
      int completedCategories = 0;

      for (final categoryProgress in progress.values) {
        totalQuestions += categoryProgress.questionsAnswered;
        totalCorrect += categoryProgress.correctAnswers;
        totalScore += categoryProgress.totalScore;

        if (categoryProgress.isCompleted) {
          completedCategories++;
        }
      }

      return {
        'totalCategories': QuestionCategory.values.length,
        'categoriesWithProgress': progress.length,
        'completedCategories': completedCategories,
        'totalQuestions': totalQuestions,
        'totalCorrect': totalCorrect,
        'totalScore': totalScore,
        'overallAccuracy': totalQuestions > 0
            ? totalCorrect / totalQuestions
            : 0.0,
      };
    } catch (e) {
      debugPrint('Error getting progress statistics: $e');
      return {};
    }
  }

  /// Dispose the service
  void dispose() {
    _backupTimer?.cancel();
  }
}
