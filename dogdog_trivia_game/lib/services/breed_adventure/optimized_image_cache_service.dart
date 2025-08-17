import 'dart:async';
import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/error_service.dart';
import '../../models/enums.dart';

/// Advanced image cache service with LRU eviction, preloading, and memory optimization
class OptimizedImageCacheService {
  static OptimizedImageCacheService? _instance;
  static OptimizedImageCacheService get instance =>
      _instance ??= OptimizedImageCacheService._();

  OptimizedImageCacheService._();

  // Configuration constants
  static const int maxCacheSize = 100;
  static const int maxMemoryMB = 50;
  static const Duration preloadDelay = Duration(
    milliseconds: 200,
  ); // Reduced from 500ms
  static const Duration retryDelay = Duration(milliseconds: 800);
  static const int maxRetries = 3;
  static const int preloadBatchSize =
      8; // Increased from 5 to preload more aggressively

  // LRU Cache for image providers
  final LinkedHashMap<String, ImageProvider> _cache = LinkedHashMap();
  final Queue<String> _lruQueue = Queue();
  final Set<String> _failedUrls = <String>{};
  final Set<String> _preloadingUrls = <String>{};

  // Memory tracking
  int _currentMemoryUsageMB = 0;
  int _totalImagesLoaded = 0;
  int _cacheHits = 0;
  int _cacheMisses = 0;

  // Performance monitoring
  final List<Duration> _loadTimes = [];
  DateTime? _lastCleanup;

  bool _isInitialized = false;
  Timer? _preloadTimer;
  Timer? _memoryCleanupTimer;

  /// Initialize the optimized cache service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Configure Flutter's image cache with optimal settings
    PaintingBinding.instance.imageCache.maximumSize = maxCacheSize;
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        maxMemoryMB * 1024 * 1024;

    // Start periodic memory cleanup
    _startMemoryCleanup();

    _isInitialized = true;
    debugPrint(
      'OptimizedImageCacheService initialized with $maxCacheSize max items, ${maxMemoryMB}MB max memory',
    );
  }

  /// Get optimized image with LRU caching
  Future<ImageProvider> getOptimizedImage(String url) async {
    if (!_isInitialized) await initialize();

    // Check cache first
    if (_cache.containsKey(url)) {
      _updateLRU(url);
      _cacheHits++;
      return _cache[url]!;
    }

    _cacheMisses++;

    // Check if URL previously failed
    if (_failedUrls.contains(url)) {
      // Retry failed URLs after some time
      _failedUrls.remove(url);
    }

    // Load and cache the image
    final stopwatch = Stopwatch()..start();
    try {
      final imageProvider = await _loadWithRetry(url);
      stopwatch.stop();

      _addToCache(url, imageProvider);
      _recordLoadTime(stopwatch.elapsed);

      return imageProvider;
    } catch (e, stack) {
      stopwatch.stop();
      _failedUrls.add(url);
      debugPrint('Failed to load optimized image $url: $e');
      await ErrorService().recordError(
        ErrorType.network,
        'Failed to load optimized image: $url',
        severity: ErrorSeverity.medium,
        stackTrace: stack,
        originalError: e,
      );
      rethrow;
    }
  }

  /// Preload next images in background with intelligent batching
  Future<void> preloadNextImages(List<String> urls) async {
    if (!_isInitialized) await initialize();

    // Take only the next batch to avoid overwhelming memory
    final batch = urls
        .take(preloadBatchSize)
        .where(
          (url) =>
              !_cache.containsKey(url) &&
              !_failedUrls.contains(url) &&
              !_preloadingUrls.contains(url),
        )
        .toList();

    if (batch.isEmpty) return;

    // Mark as preloading to avoid duplicates
    _preloadingUrls.addAll(batch);

    // Preload with staggered delays to avoid blocking UI
    // Use shorter delays for first few images (priority loading)
    for (int i = 0; i < batch.length; i++) {
      final url = batch[i];
      // First 3 images get shorter delays (100ms, 200ms, 300ms)
      // Remaining images get standard delays
      final delay = i < 3
          ? Duration(milliseconds: 100 * (i + 1))
          : preloadDelay * (i + 1);

      _preloadTimer = Timer(delay, () async {
        try {
          await getOptimizedImage(url);
          debugPrint('Preloaded image: $url');
        } catch (e) {
          debugPrint('Failed to preload image $url: $e');
        } finally {
          _preloadingUrls.remove(url);
        }
      });
    }
  }

  /// Preload critical images immediately without delay for current game challenge
  Future<void> preloadCriticalImages(List<String> urls) async {
    if (!_isInitialized) await initialize();

    final criticalUrls = urls
        .where(
          (url) =>
              !_cache.containsKey(url) &&
              !_failedUrls.contains(url) &&
              !_preloadingUrls.contains(url),
        )
        .toList();

    if (criticalUrls.isEmpty) return;

    // Mark as preloading to avoid duplicates
    _preloadingUrls.addAll(criticalUrls);

    try {
      // Load all critical images immediately in parallel
      await Future.wait(
        criticalUrls.map((url) async {
          try {
            await getOptimizedImage(url);
            debugPrint('Critical image preloaded: $url');
          } catch (e) {
            debugPrint('Failed to preload critical image $url: $e');
          } finally {
            _preloadingUrls.remove(url);
          }
        }),
        eagerError: false,
      );
    } catch (e) {
      debugPrint('Error in critical image preloading: $e');
      // Clean up preloading markers
      for (final url in criticalUrls) {
        _preloadingUrls.remove(url);
      }
    }
  }

  /// Load image with retry mechanism and performance tracking
  Future<ImageProvider> _loadWithRetry(String url) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        final imageProvider = CachedNetworkImageProvider(url);

        // Pre-resolve the image to ensure it's actually loaded
        final completer = Completer<ImageProvider>();
        final imageStream = imageProvider.resolve(const ImageConfiguration());

        late ImageStreamListener listener;
        listener = ImageStreamListener(
          (ImageInfo image, bool synchronousCall) {
            if (!completer.isCompleted) {
              completer.complete(imageProvider);
            }
            imageStream.removeListener(listener);
          },
          onError: (dynamic exception, StackTrace? stackTrace) {
            if (!completer.isCompleted) {
              completer.completeError(exception);
            }
            imageStream.removeListener(listener);
            // Log error to ErrorService
            ErrorService().recordError(
              ErrorType.network,
              'Image stream error for $url',
              severity: ErrorSeverity.medium,
              stackTrace: stackTrace,
              originalError: exception,
            );
          },
        );

        imageStream.addListener(listener);

        return await completer.future;
      } catch (e, stack) {
        attempts++;
        if (attempts >= maxRetries) {
          await ErrorService().recordError(
            ErrorType.network,
            'Failed to load image after $maxRetries attempts: $url',
            severity: ErrorSeverity.high,
            stackTrace: stack,
            originalError: e,
          );
          rethrow;
        }

        // Wait before retry with exponential backoff
        await Future.delayed(retryDelay * attempts);
      }
    }

    throw Exception('Failed to load image after $maxRetries attempts');
  }

  /// Add image to cache with LRU management
  void _addToCache(String url, ImageProvider imageProvider) {
    // Remove oldest items if cache is full
    while (_cache.length >= maxCacheSize) {
      _evictOldest();
    }

    _cache[url] = imageProvider;
    _updateLRU(url);
    _totalImagesLoaded++;

    // Estimate memory usage (rough calculation)
    _currentMemoryUsageMB = (_cache.length * 0.5)
        .round(); // Assume ~0.5MB per image
  }

  /// Update LRU queue for accessed URL
  void _updateLRU(String url) {
    _lruQueue.remove(url);
    _lruQueue.addLast(url);
  }

  /// Evict oldest item from cache
  void _evictOldest() {
    if (_lruQueue.isEmpty) return;

    final oldest = _lruQueue.removeFirst();
    _cache.remove(oldest);
  }

  /// Record load time for performance monitoring
  void _recordLoadTime(Duration loadTime) {
    _loadTimes.add(loadTime);

    // Keep only recent load times (last 100)
    if (_loadTimes.length > 100) {
      _loadTimes.removeAt(0);
    }
  }

  /// Start periodic memory cleanup
  void _startMemoryCleanup() {
    _memoryCleanupTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _performMemoryCleanup();
    });
  }

  /// Perform intelligent memory cleanup
  void _performMemoryCleanup() {
    final now = DateTime.now();
    _lastCleanup = now;

    // Check memory pressure
    final memoryPressure = _currentMemoryUsageMB / maxMemoryMB;

    if (memoryPressure > 0.8) {
      // High memory pressure - aggressive cleanup
      _performAggressiveCleanup();
    } else if (memoryPressure > 0.6) {
      // Medium memory pressure - moderate cleanup
      _performModerateCleanup();
    } else {
      // Low memory pressure - basic cleanup
      _performBasicCleanup();
    }

    debugPrint(
      'Memory cleanup completed. Cache size: ${_cache.length}, Memory: ${_currentMemoryUsageMB}MB',
    );
  }

  /// Basic cleanup - remove oldest 20% of items
  void _performBasicCleanup() {
    final removeCount = (_cache.length * 0.2).round();
    for (int i = 0; i < removeCount && _lruQueue.isNotEmpty; i++) {
      _evictOldest();
    }
  }

  /// Moderate cleanup - remove oldest 40% of items
  void _performModerateCleanup() {
    final removeCount = (_cache.length * 0.4).round();
    for (int i = 0; i < removeCount && _lruQueue.isNotEmpty; i++) {
      _evictOldest();
    }

    // Clear failed URLs to allow retries
    _failedUrls.clear();
  }

  /// Aggressive cleanup - remove oldest 60% of items and clear all failed URLs
  void _performAggressiveCleanup() {
    final removeCount = (_cache.length * 0.6).round();
    for (int i = 0; i < removeCount && _lruQueue.isNotEmpty; i++) {
      _evictOldest();
    }

    // Clear all failed URLs and preloading queue
    _failedUrls.clear();
    _preloadingUrls.clear();

    // Force Flutter image cache cleanup
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Get performance statistics
  ImageCachePerformanceStats getPerformanceStats() {
    double averageLoadTime = 0;
    if (_loadTimes.isNotEmpty) {
      final totalMs = _loadTimes.fold<int>(
        0,
        (sum, duration) => sum + duration.inMilliseconds,
      );
      averageLoadTime = totalMs / _loadTimes.length;
    }

    return ImageCachePerformanceStats(
      cacheSize: _cache.length,
      maxCacheSize: maxCacheSize,
      memoryUsageMB: _currentMemoryUsageMB,
      maxMemoryMB: maxMemoryMB,
      totalImagesLoaded: _totalImagesLoaded,
      cacheHits: _cacheHits,
      cacheMisses: _cacheMisses,
      failedUrls: _failedUrls.length,
      averageLoadTimeMs: averageLoadTime,
      hitRate: _cacheHits + _cacheMisses > 0
          ? _cacheHits / (_cacheHits + _cacheMisses)
          : 0.0,
      lastCleanup: _lastCleanup,
    );
  }

  /// Clear all caches and reset statistics
  void clearCache() {
    _cache.clear();
    _lruQueue.clear();
    _failedUrls.clear();
    _preloadingUrls.clear();
    _loadTimes.clear();
    _currentMemoryUsageMB = 0;
    _cacheHits = 0;
    _cacheMisses = 0;
    _totalImagesLoaded = 0;

    // Clear Flutter's image cache
    PaintingBinding.instance.imageCache.clear();
  }

  /// Check if image is cached
  bool isImageCached(String url) {
    return _cache.containsKey(url);
  }

  /// Reset failed URLs to allow retries
  void resetFailedUrls() {
    _failedUrls.clear();
  }

  /// Dispose of the service
  void dispose() {
    _preloadTimer?.cancel();
    _memoryCleanupTimer?.cancel();
    clearCache();
    _isInitialized = false;
  }
}

/// Performance statistics for image cache monitoring
class ImageCachePerformanceStats {
  final int cacheSize;
  final int maxCacheSize;
  final int memoryUsageMB;
  final int maxMemoryMB;
  final int totalImagesLoaded;
  final int cacheHits;
  final int cacheMisses;
  final int failedUrls;
  final double averageLoadTimeMs;
  final double hitRate;
  final DateTime? lastCleanup;

  const ImageCachePerformanceStats({
    required this.cacheSize,
    required this.maxCacheSize,
    required this.memoryUsageMB,
    required this.maxMemoryMB,
    required this.totalImagesLoaded,
    required this.cacheHits,
    required this.cacheMisses,
    required this.failedUrls,
    required this.averageLoadTimeMs,
    required this.hitRate,
    this.lastCleanup,
  });

  @override
  String toString() {
    return 'ImageCachePerformanceStats('
        'cache: $cacheSize/$maxCacheSize, '
        'memory: ${memoryUsageMB}MB/${maxMemoryMB}MB, '
        'loaded: $totalImagesLoaded, '
        'hits: $cacheHits, '
        'misses: $cacheMisses, '
        'failed: $failedUrls, '
        'avgLoadTime: ${averageLoadTimeMs.toStringAsFixed(1)}ms, '
        'hitRate: ${(hitRate * 100).toStringAsFixed(1)}%'
        ')';
  }
}
