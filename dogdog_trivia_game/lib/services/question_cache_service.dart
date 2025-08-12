import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/localized_question.dart';
import '../models/enums.dart';

/// High-performance caching service for question data with lazy loading and memory management
class QuestionCacheService {
  static QuestionCacheService? _instance;
  static QuestionCacheService get instance =>
      _instance ??= QuestionCacheService._();

  QuestionCacheService._();

  // Configuration
  static const int maxCachedCategories = 3; // Keep only 3 categories in memory
  static const int maxQuestionsPerCategory =
      200; // Limit questions per category
  static const Duration cacheExpiration = Duration(
    hours: 1,
  ); // Cache expiry time

  // Cache state
  final Map<QuestionCategory, List<LocalizedQuestion>> _categoryQuestionCache =
      {};
  final Map<QuestionCategory, DateTime> _categoryLoadTime = {};
  final Map<QuestionCategory, bool> _categoryLoadingState = {};

  // Parsed raw data cache
  Map<String, dynamic>? _rawQuestionsData;
  DateTime? _rawDataLoadTime;

  // Memory management
  final List<QuestionCategory> _accessOrder = []; // LRU tracking
  bool _isInitialized = false;

  /// Initialize the cache service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadRawQuestionsData();
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) print('Failed to initialize QuestionCacheService: $e');
      rethrow;
    }
  }

  /// Load raw questions data from JSON file (cached)
  Future<void> _loadRawQuestionsData() async {
    // Check if we have cached raw data that's still fresh
    if (_rawQuestionsData != null && _rawDataLoadTime != null) {
      final age = DateTime.now().difference(_rawDataLoadTime!);
      if (age < cacheExpiration) {
        return; // Use cached data
      }
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/questions_fixed.json',
      );
      _rawQuestionsData = json.decode(jsonString) as Map<String, dynamic>;
      _rawDataLoadTime = DateTime.now();
    } catch (e) {
      if (kDebugMode) print('Failed to load questions_fixed.json: $e');
      rethrow;
    }
  }

  /// Get questions for a specific category with lazy loading
  Future<List<LocalizedQuestion>> getQuestionsForCategory(
    QuestionCategory category,
  ) async {
    // Return cached data if available and fresh
    if (_categoryQuestionCache.containsKey(category) &&
        _isCategoryFresh(category)) {
      _updateAccessOrder(category);
      return _categoryQuestionCache[category]!;
    }

    // Check if already loading to prevent duplicate requests
    if (_categoryLoadingState[category] == true) {
      // Wait for existing load to complete
      while (_categoryLoadingState[category] == true) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      if (_categoryQuestionCache.containsKey(category)) {
        _updateAccessOrder(category);
        return _categoryQuestionCache[category]!;
      }
    }

    // Start loading
    return await _loadCategoryQuestions(category);
  }

  /// Load and cache questions for a specific category
  Future<List<LocalizedQuestion>> _loadCategoryQuestions(
    QuestionCategory category,
  ) async {
    _categoryLoadingState[category] = true;

    try {
      // Ensure raw data is loaded
      if (_rawQuestionsData == null) {
        await _loadRawQuestionsData();
      }

      final questions = <LocalizedQuestion>[];
      final categoryData =
          _rawQuestionsData!['categories'] as Map<String, dynamic>?;

      if (categoryData == null) {
        throw Exception('No categories found in questions data');
      }

      final categoryName = _getCategoryJsonKey(category);
      final categoryQuestions = categoryData[categoryName] as List<dynamic>?;

      if (categoryQuestions != null) {
        // Limit the number of questions per category for memory efficiency
        final limitedQuestions = categoryQuestions.take(
          maxQuestionsPerCategory,
        );

        for (final questionData in limitedQuestions) {
          try {
            final question = LocalizedQuestion.fromJson(
              questionData as Map<String, dynamic>,
            );
            questions.add(question);
          } catch (e) {
            if (kDebugMode) print('Failed to parse question: $e');
            // Continue with other questions
          }
        }
      }

      // Cache the questions
      _categoryQuestionCache[category] = questions;
      _categoryLoadTime[category] = DateTime.now();
      _updateAccessOrder(category);

      // Perform memory management
      await _performMemoryManagement();

      return questions;
    } catch (e) {
      if (kDebugMode)
        print('Failed to load questions for category $category: $e');
      rethrow;
    } finally {
      _categoryLoadingState[category] = false;
    }
  }

  /// Update access order for LRU cache management
  void _updateAccessOrder(QuestionCategory category) {
    _accessOrder.remove(category);
    _accessOrder.add(category);
  }

  /// Check if category data is still fresh
  bool _isCategoryFresh(QuestionCategory category) {
    final loadTime = _categoryLoadTime[category];
    if (loadTime == null) return false;

    final age = DateTime.now().difference(loadTime);
    return age < cacheExpiration;
  }

  /// Perform memory management by evicting least recently used categories
  Future<void> _performMemoryManagement() async {
    if (_categoryQuestionCache.length <= maxCachedCategories) {
      return;
    }

    // Calculate categories to evict (oldest first)
    final categoriesToEvict = _accessOrder
        .take(_accessOrder.length - maxCachedCategories)
        .toList();

    for (final category in categoriesToEvict) {
      _evictCategory(category);
    }
  }

  /// Evict a specific category from cache
  void _evictCategory(QuestionCategory category) {
    _categoryQuestionCache.remove(category);
    _categoryLoadTime.remove(category);
    _accessOrder.remove(category);
    if (kDebugMode) print('Evicted category $category from cache');
  }

  /// Get the JSON key for a category
  String _getCategoryJsonKey(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.dogTraining:
        return 'dogTraining';
      case QuestionCategory.dogBreeds:
        return 'dogBreeds';
      case QuestionCategory.dogBehavior:
        return 'dogBehavior';
      case QuestionCategory.dogHealth:
        return 'dogHealth';
      case QuestionCategory.dogHistory:
        return 'dogHistory';
    }
  }

  /// Preload specific categories for better performance
  Future<void> preloadCategories(List<QuestionCategory> categories) async {
    final futures = categories.map(
      (category) => getQuestionsForCategory(category),
    );
    await Future.wait(futures, eagerError: false);
  }

  /// Get cache statistics for monitoring
  Map<String, dynamic> getCacheStatistics() {
    return {
      'cachedCategories': _categoryQuestionCache.keys.toList(),
      'totalCachedQuestions': _categoryQuestionCache.values.fold<int>(
        0,
        (sum, questions) => sum + questions.length,
      ),
      'memoryUsageApprox': _estimateMemoryUsage(),
      'accessOrder': _accessOrder,
      'isRawDataCached': _rawQuestionsData != null,
      'rawDataAge': _rawDataLoadTime != null
          ? DateTime.now().difference(_rawDataLoadTime!).inMinutes
          : null,
    };
  }

  /// Estimate memory usage in KB
  int _estimateMemoryUsage() {
    int totalSize = 0;

    // Estimate size of cached questions (rough approximation)
    for (final questions in _categoryQuestionCache.values) {
      totalSize += questions.length * 2; // Approximate 2KB per question
    }

    // Add raw data size estimate
    if (_rawQuestionsData != null) {
      totalSize += 500; // Approximate 500KB for raw JSON
    }

    return totalSize;
  }

  /// Clear all caches (for memory pressure situations)
  void clearAllCaches() {
    _categoryQuestionCache.clear();
    _categoryLoadTime.clear();
    _categoryLoadingState.clear();
    _accessOrder.clear();
    _rawQuestionsData = null;
    _rawDataLoadTime = null;
    if (kDebugMode) print('Cleared all question caches');
  }

  /// Clear cache for specific category
  void clearCategoryCache(QuestionCategory category) {
    _evictCategory(category);
  }

  /// Check if category is currently cached
  bool isCategoryCached(QuestionCategory category) {
    return _categoryQuestionCache.containsKey(category) &&
        _isCategoryFresh(category);
  }

  /// Force refresh category cache
  Future<List<LocalizedQuestion>> refreshCategory(
    QuestionCategory category,
  ) async {
    _evictCategory(category);
    return await getQuestionsForCategory(category);
  }
}
