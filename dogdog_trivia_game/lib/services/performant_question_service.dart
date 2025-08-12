import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/localized_question.dart';
import '../models/enums.dart';
import 'question_cache_service.dart';
import 'memory_management_service.dart';

/// Enhanced Question Service with performance optimizations and caching (Task 14)
class PerformantQuestionService {
  static final PerformantQuestionService _instance =
      PerformantQuestionService._internal();
  factory PerformantQuestionService() => _instance;
  PerformantQuestionService._internal();

  // Legacy question pools for fallback
  final Random _random = Random();

  // Performance-optimized services
  QuestionCacheService? _cacheService;
  MemoryManagementService? _memoryService;

  // State management
  bool _isInitialized = false;
  final bool _useLocalizedQuestions = true;
  QuestionCategory? _currentCategory;
  Map<String, dynamic>? _errorInfo;

  /// Initialize the service with caching and memory management
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize cache and memory services
      _cacheService ??= QuestionCacheService.instance;
      _memoryService ??= MemoryManagementService.instance;

      await _cacheService!.initialize();
      await _memoryService!.initialize();

      _isInitialized = true;
      if (kDebugMode) {
        print('PerformantQuestionService initialized with caching');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize PerformantQuestionService: $e');
      }
      rethrow;
    }
  }

  /// Get questions for a specific category with caching optimization
  Future<List<LocalizedQuestion>> getQuestionsForCategory(
    QuestionCategory category, {
    bool forceRefresh = false,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Update current category for memory optimization
      if (_currentCategory != category) {
        _currentCategory = category;
        await _memoryService?.optimizeForCategorySwitch(category);
      }

      // Get questions from cache
      List<LocalizedQuestion> questions;
      if (forceRefresh) {
        questions = await _cacheService?.refreshCategory(category) ?? [];
      } else {
        questions =
            await _cacheService?.getQuestionsForCategory(category) ?? [];
      }

      // Clear any previous errors
      _errorInfo = null;

      return questions;
    } catch (e) {
      _errorInfo = {
        'hasErrors': true,
        'message': 'Failed to load questions for $category: $e',
        'severity': 'medium',
        'canRetry': true,
      };
      if (kDebugMode) {
        print('Error getting questions for category $category: $e');
      }
      return [];
    }
  }

  /// Get randomized questions with difficulty progression and caching
  Future<List<LocalizedQuestion>> getRandomizedQuestions({
    required QuestionCategory category,
    required int count,
    required Difficulty difficulty,
    List<String>? excludeIds,
    bool shuffleAnswers = true,
  }) async {
    try {
      // Get all questions for the category (cached)
      final allQuestions = await getQuestionsForCategory(category);

      if (allQuestions.isEmpty) {
        throw Exception('No questions available for category $category');
      }

      // Filter by difficulty and exclude used questions
      var filteredQuestions = allQuestions.where((q) {
        return _compareDifficulty(q.difficulty, difficulty) &&
            (excludeIds == null || !excludeIds.contains(q.id));
      }).toList();

      // If not enough questions at exact difficulty, include adjacent difficulties
      if (filteredQuestions.length < count) {
        final adjacentDifficulties = _getAdjacentDifficulties(difficulty);

        for (final adjDifficulty in adjacentDifficulties) {
          final additional = allQuestions.where((q) {
            return _compareDifficulty(q.difficulty, adjDifficulty) &&
                (excludeIds == null || !excludeIds.contains(q.id)) &&
                !filteredQuestions.any((existing) => existing.id == q.id);
          }).toList();

          filteredQuestions.addAll(additional);

          if (filteredQuestions.length >= count) break;
        }
      }

      // Shuffle and take required count
      filteredQuestions.shuffle(_random);
      final selectedQuestions = filteredQuestions.take(count).toList();

      // Shuffle answers if requested
      if (shuffleAnswers) {
        for (final question in selectedQuestions) {
          _shuffleQuestionAnswers(question);
        }
      }

      return selectedQuestions;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting randomized questions: $e');
      }
      return [];
    }
  }

  /// Get adjacent difficulties for fallback
  List<Difficulty> _getAdjacentDifficulties(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return [Difficulty.medium];
      case Difficulty.medium:
        return [Difficulty.easy, Difficulty.hard];
      case Difficulty.hard:
        return [Difficulty.medium, Difficulty.expert];
      case Difficulty.expert:
        return [Difficulty.hard];
    }
  }

  /// Compare string difficulty with enum difficulty
  bool _compareDifficulty(
    String questionDifficulty,
    Difficulty targetDifficulty,
  ) {
    final normalizedDifficulty = questionDifficulty.toLowerCase();

    switch (targetDifficulty) {
      case Difficulty.easy:
        return normalizedDifficulty == 'easy' ||
            normalizedDifficulty == 'easy+';
      case Difficulty.medium:
        return normalizedDifficulty == 'medium';
      case Difficulty.hard:
        return normalizedDifficulty == 'hard';
      case Difficulty.expert:
        return normalizedDifficulty == 'expert' ||
            normalizedDifficulty == 'very hard';
    }
  }

  /// Shuffle answers for a question (simplified implementation)
  void _shuffleQuestionAnswers(LocalizedQuestion question) {
    // Note: LocalizedQuestion doesn't have direct correctAnswer/incorrectAnswers getters
    // This is a placeholder implementation. In practice, you'd need to:
    // 1. Get the answers from question.answers for current locale
    // 2. Shuffle them while tracking the correct answer index
    // 3. Create a new question instance with shuffled answers

    // For now, we'll just acknowledge that the question should be shuffled
    // The actual shuffling would happen in the UI layer or require
    // modifying the LocalizedQuestion class to support answer shuffling
  }

  /// Preload questions for better performance
  Future<void> preloadQuestionsForCategories(
    List<QuestionCategory> categories,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    await _cacheService?.preloadCategories(categories);
    if (kDebugMode) {
      print('Preloaded questions for ${categories.length} categories');
    }
  }

  /// Get cache statistics for monitoring
  Map<String, dynamic> getCacheStatistics() {
    return _cacheService?.getCacheStatistics() ?? {};
  }

  /// Get memory statistics for monitoring
  Map<String, dynamic> getMemoryStatistics() {
    return _memoryService?.getDetailedMemoryStatistics() ?? {};
  }

  /// Get performance recommendations
  List<String> getPerformanceRecommendations() {
    return _memoryService?.getPerformanceRecommendations() ?? [];
  }

  /// Force memory optimization
  Future<void> optimizeMemory() async {
    await _memoryService?.forceOptimization();
  }

  /// Check if category is cached
  bool isCategoryCached(QuestionCategory category) {
    return _cacheService?.isCategoryCached(category) ?? false;
  }

  /// Get error information
  Map<String, dynamic> getErrorInfo() {
    return _errorInfo ??
        {
          'hasErrors': false,
          'message': '',
          'severity': 'none',
          'canRetry': false,
        };
  }

  /// Attempt recovery from errors
  Future<bool> attemptRecovery() async {
    try {
      if (_currentCategory != null) {
        // Try to refresh current category
        await _cacheService?.refreshCategory(_currentCategory!);
        _errorInfo = null;
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Recovery attempt failed: $e');
      }
      return false;
    }
  }

  /// Get available categories with cache status
  List<Map<String, dynamic>> getAvailableCategoriesWithStatus() {
    return QuestionCategory.values.map((category) {
      return {
        'category': category,
        'cached': _cacheService?.isCategoryCached(category) ?? false,
        'name': category.toString().split('.').last,
      };
    }).toList();
  }

  /// Clear cache for specific category
  void clearCategoryCache(QuestionCategory category) {
    _cacheService?.clearCategoryCache(category);
  }

  /// Clear all caches (for memory pressure)
  void clearAllCaches() {
    _cacheService?.clearAllCaches();
  }

  /// Get total questions count for category (cached)
  Future<int> getQuestionCountForCategory(QuestionCategory category) async {
    try {
      final questions = await getQuestionsForCategory(category);
      return questions.length;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting question count for $category: $e');
      }
      return 0;
    }
  }

  /// Check if service is healthy
  bool get isHealthy =>
      _isInitialized && (_memoryService?.isMemoryHealthy ?? true);

  /// Get current category
  QuestionCategory? get currentCategory => _currentCategory;

  /// Check if using localized questions
  bool get useLocalizedQuestions => _useLocalizedQuestions;
}

/// Legacy compatibility layer
class QuestionService {
  static final QuestionService _instance = QuestionService._internal();
  factory QuestionService() => _instance;
  QuestionService._internal();

  final PerformantQuestionService _performantService =
      PerformantQuestionService();

  // Delegate all calls to the performant service for backward compatibility
  Future<void> initialize() => _performantService.initialize();

  Future<List<LocalizedQuestion>> getQuestionsForCategory(
    QuestionCategory category, {
    bool forceRefresh = false,
  }) => _performantService.getQuestionsForCategory(
    category,
    forceRefresh: forceRefresh,
  );

  Future<List<LocalizedQuestion>> getRandomizedQuestions({
    required QuestionCategory category,
    required int count,
    required Difficulty difficulty,
    List<String>? excludeIds,
    bool shuffleAnswers = true,
  }) => _performantService.getRandomizedQuestions(
    category: category,
    count: count,
    difficulty: difficulty,
    excludeIds: excludeIds,
    shuffleAnswers: shuffleAnswers,
  );

  Map<String, dynamic> getErrorInfo() => _performantService.getErrorInfo();
  Future<bool> attemptRecovery() => _performantService.attemptRecovery();
}
