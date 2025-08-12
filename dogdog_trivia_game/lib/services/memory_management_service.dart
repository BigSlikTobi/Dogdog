import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/enums.dart';
import 'question_cache_service.dart';
import 'localization_cache_service.dart';
import 'image_cache_service.dart';

/// Memory management service that coordinates all cache services for optimal performance
class MemoryManagementService {
  static MemoryManagementService? _instance;
  static MemoryManagementService get instance =>
      _instance ??= MemoryManagementService._();

  MemoryManagementService._();

  // Configuration
  static const Duration monitoringInterval = Duration(minutes: 1);
  static const int memoryPressureThresholdMB = 100; // Alert at 100MB usage

  // Services
  late final QuestionCacheService _questionCache;
  late final LocalizationCacheService _localizationCache;
  late final ImageCacheService _imageCache;

  // Monitoring state
  Timer? _monitoringTimer;
  bool _isInitialized = false;
  int _memoryPressureLevel = 0; // 0=low, 1=medium, 2=high
  final List<String> _performanceLog = [];

  /// Initialize the memory management service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _questionCache = QuestionCacheService.instance;
    _localizationCache = LocalizationCacheService.instance;
    _imageCache = ImageCacheService.instance;

    await _questionCache.initialize();
    await _imageCache.initialize();

    _startMemoryMonitoring();
    _isInitialized = true;

    _logPerformance('MemoryManagementService initialized');
  }

  /// Start continuous memory monitoring
  void _startMemoryMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(monitoringInterval, (_) async {
      await _performMemoryCheck();
    });
  }

  /// Perform comprehensive memory check and optimization
  Future<void> _performMemoryCheck() async {
    try {
      final memoryStats = getDetailedMemoryStatistics();
      final totalMemoryMB = memoryStats['totalMemoryMB'] as int;

      // Determine memory pressure level
      final previousPressure = _memoryPressureLevel;
      _memoryPressureLevel = _calculateMemoryPressure(totalMemoryMB);

      // Log significant changes
      if (_memoryPressureLevel != previousPressure) {
        _logPerformance(
          'Memory pressure changed from $previousPressure to $_memoryPressureLevel (${totalMemoryMB}MB)',
        );
      }

      // Trigger cleanup based on pressure level
      await _performPressureBasedCleanup();
    } catch (e) {
      if (kDebugMode) {
        print('Memory check failed: $e');
      }
    }
  }

  /// Calculate memory pressure level based on usage
  int _calculateMemoryPressure(int totalMemoryMB) {
    if (totalMemoryMB < 50) return 0; // Low pressure
    if (totalMemoryMB < 100) return 1; // Medium pressure
    return 2; // High pressure
  }

  /// Perform cleanup based on current memory pressure
  Future<void> _performPressureBasedCleanup() async {
    switch (_memoryPressureLevel) {
      case 0: // Low pressure - minimal cleanup
        // Do nothing or light maintenance
        break;
      case 1: // Medium pressure - moderate cleanup
        await _performModerateCleanup();
        break;
      case 2: // High pressure - aggressive cleanup
        await _performAggressiveCleanup();
        break;
    }
  }

  /// Moderate cleanup for medium memory pressure
  Future<void> _performModerateCleanup() async {
    // Clean expired localization cache entries
    _localizationCache.clearCache();

    // Evict least recently used question categories
    final questionStats = _questionCache.getCacheStatistics();
    final cachedCategories =
        questionStats['cachedCategories'] as List<QuestionCategory>;

    if (cachedCategories.length > 2) {
      // Keep only the 2 most recently accessed categories
      final toEvict = cachedCategories.take(cachedCategories.length - 2);
      for (final category in toEvict) {
        _questionCache.clearCategoryCache(category);
      }
    }

    _logPerformance(
      'Performed moderate cleanup - evicted ${cachedCategories.length > 2 ? cachedCategories.length - 2 : 0} question categories',
    );
  }

  /// Aggressive cleanup for high memory pressure
  Future<void> _performAggressiveCleanup() async {
    // Clear all caches
    _questionCache.clearAllCaches();
    _localizationCache.clearCache();

    // Force image cache cleanup
    _imageCache.clearCache();

    // Force garbage collection hint
    // Note: Dart doesn't have explicit GC, but clearing references helps

    _logPerformance('Performed aggressive cleanup - cleared all caches');
  }

  /// Preload resources for optimal performance
  Future<void> preloadOptimalResources({
    required QuestionCategory primaryCategory,
    List<QuestionCategory>? secondaryCategories,
    required String locale,
  }) async {
    try {
      // Initialize localization cache
      _localizationCache.initialize(locale);

      // Preload primary category questions
      await _questionCache.getQuestionsForCategory(primaryCategory);

      // Preload secondary categories in background
      if (secondaryCategories != null) {
        unawaited(_questionCache.preloadCategories(secondaryCategories));
      }

      _logPerformance('Preloaded resources for category: $primaryCategory');
    } catch (e) {
      if (kDebugMode) {
        print('Failed to preload resources: $e');
      }
    }
  }

  /// Optimize for category switch
  Future<void> optimizeForCategorySwitch(QuestionCategory newCategory) async {
    // Preload new category questions
    await _questionCache.getQuestionsForCategory(newCategory);

    // If we're at medium+ memory pressure, evict unused categories
    if (_memoryPressureLevel >= 1) {
      final questionStats = _questionCache.getCacheStatistics();
      final cachedCategories =
          questionStats['cachedCategories'] as List<QuestionCategory>;

      for (final category in cachedCategories) {
        if (category != newCategory) {
          _questionCache.clearCategoryCache(category);
        }
      }
    }

    _logPerformance('Optimized for category switch to: $newCategory');
  }

  /// Get comprehensive memory statistics
  Map<String, dynamic> getDetailedMemoryStatistics() {
    final questionStats = _questionCache.getCacheStatistics();
    final localizationStats = _localizationCache.getCacheStatistics();
    final imageStats = _imageCache.getStatistics();

    final totalMemoryMB =
        (questionStats['memoryUsageApprox'] as int) +
        ((localizationStats['memoryUsageApproxKB'] as int) ~/ 1024) +
        (imageStats.cacheSize);

    return {
      'totalMemoryMB': totalMemoryMB,
      'memoryPressureLevel': _memoryPressureLevel,
      'questionCache': questionStats,
      'localizationCache': localizationStats,
      'imageCache': {
        'cachedImagesCount': imageStats.cachedImagesCount,
        'failedImagesCount': imageStats.failedImagesCount,
        'cacheSizeMB': imageStats.cacheSize,
        'memoryPressureLevel': imageStats.memoryPressureLevel,
      },
      'performanceLog': _performanceLog.take(10).toList(), // Last 10 entries
    };
  }

  /// Get performance recommendations
  List<String> getPerformanceRecommendations() {
    final recommendations = <String>[];
    final stats = getDetailedMemoryStatistics();
    final totalMemoryMB = stats['totalMemoryMB'] as int;

    if (totalMemoryMB > 150) {
      recommendations.add('Consider clearing unused question categories');
    }

    if (totalMemoryMB > 100) {
      recommendations.add('Enable aggressive memory management');
    }

    final questionStats = stats['questionCache'] as Map<String, dynamic>;
    final cachedCategories =
        questionStats['cachedCategories'] as List<QuestionCategory>;

    if (cachedCategories.length > 3) {
      recommendations.add('Too many categories cached simultaneously');
    }

    final imageStats = stats['imageCache'] as Map<String, dynamic>;
    if ((imageStats['cacheSizeMB'] as int) > 50) {
      recommendations.add('Image cache is consuming significant memory');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Memory usage is optimal');
    }

    return recommendations;
  }

  /// Force memory optimization
  Future<void> forceOptimization() async {
    await _performAggressiveCleanup();
    _logPerformance('Force optimization completed');
  }

  /// Log performance events
  void _logPerformance(String message) {
    final timestamp = DateTime.now().toIso8601String();
    _performanceLog.add('[$timestamp] $message');

    // Keep only last 50 entries
    if (_performanceLog.length > 50) {
      _performanceLog.removeAt(0);
    }

    if (kDebugMode) {
      print('MemoryManagement: $message');
    }
  }

  /// Dispose and cleanup
  void dispose() {
    _monitoringTimer?.cancel();
    _performanceLog.clear();
    _isInitialized = false;
  }

  /// Get current memory pressure level
  int get memoryPressureLevel => _memoryPressureLevel;

  /// Check if memory usage is healthy
  bool get isMemoryHealthy => _memoryPressureLevel < 2;
}

/// Extension to make unawaited calls clearer
extension UnawaiterHelper on MemoryManagementService {
  void unawaited(Future<void> future) {
    future.catchError((e) {
      if (kDebugMode) {
        print('Background operation failed: $e');
      }
    });
  }
}
