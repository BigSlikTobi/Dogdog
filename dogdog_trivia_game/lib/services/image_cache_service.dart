import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Enhanced image cache service with memory management and optimization for sustained gameplay
class ImageCacheService {
  static ImageCacheService? _instance;
  static ImageCacheService get instance => _instance ??= ImageCacheService._();

  ImageCacheService._();

  // Configuration constants - optimized for memory efficiency
  static const int maxCacheItems =
      50; // Reduced from typical 100 to save memory
  static const int maxCacheSizeMB = 30; // Reduced from typical 50MB
  static const Duration retryDelay = Duration(milliseconds: 500);
  static const int maxRetries = 3;
  static const Duration cleanupInterval = Duration(minutes: 2);

  // Internal state
  bool _isInitialized = false;
  final Set<String> _cachedUrls = <String>{};
  final Set<String> _failedUrls = <String>{};
  final Map<String, DateTime> _lastAccessed = <String, DateTime>{};
  Timer? _cleanupTimer;
  int _memoryPressureLevel = 0; // 0=low, 1=medium, 2=high

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Configure Flutter's image cache with optimized settings
    PaintingBinding.instance.imageCache.maximumSize = maxCacheItems;
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        maxCacheSizeMB * 1024 * 1024;

    // Start periodic cleanup
    _startPeriodicCleanup();

    _isInitialized = true;
  }

  /// Dispose of resources
  void dispose() {
    _cleanupTimer?.cancel();
    _cachedUrls.clear();
    _failedUrls.clear();
    _lastAccessed.clear();
    _isInitialized = false;
  }

  /// Cache an image from URL
  Future<bool> cacheImage(BuildContext context, String imageUrl) async {
    if (!_isInitialized) await initialize();

    try {
      // Skip if already cached or failed recently
      if (_cachedUrls.contains(imageUrl)) {
        _lastAccessed[imageUrl] = DateTime.now();
        return true;
      }

      if (_failedUrls.contains(imageUrl)) {
        return false;
      }

      // Precache the image
      await precacheImage(
        CachedNetworkImageProvider(imageUrl),
        context,
        onError: (e, stack) {
          _failedUrls.add(imageUrl);
          debugPrint('Failed to cache image $imageUrl: $e');
        },
      );

      _cachedUrls.add(imageUrl);
      _lastAccessed[imageUrl] = DateTime.now();

      // Check memory pressure after loading
      await _checkMemoryPressure();

      return true;
    } catch (e) {
      _failedUrls.add(imageUrl);
      debugPrint('Failed to cache image $imageUrl: $e');
      return false;
    }
  }

  /// Preload multiple images
  Future<void> preloadImages(
      BuildContext context, List<String> imageUrls) async {
    final futures =
        imageUrls.map((url) => cacheImage(context, url)).toList();
    await Future.wait(futures, eagerError: false);
  }

  /// Check if image is cached
  bool isImageCached(String imageUrl) {
    return _cachedUrls.contains(imageUrl);
  }

  /// Clear the cache
  void clearCache() {
    PaintingBinding.instance.imageCache.clear();
    _cachedUrls.clear();
    _lastAccessed.clear();
    _memoryPressureLevel = 0;
  }

  /// Clear statistics (for memory optimization)
  void clearStatistics() {
    // Keep cache but clear tracking data
    _lastAccessed.clear();
  }

  /// Reset failed URLs to allow retry
  void resetFailedUrls() {
    _failedUrls.clear();
  }

  /// Get cache statistics
  ImageCacheStats getStatistics() {
    final imageCache = PaintingBinding.instance.imageCache;
    return ImageCacheStats(
      cachedImagesCount: _cachedUrls.length,
      failedImagesCount: _failedUrls.length,
      cacheSize: (imageCache.currentSizeBytes / (1024 * 1024)).round(),
      maxCacheSize: maxCacheSizeMB,
      memoryPressureLevel: _memoryPressureLevel,
    );
  }

  /// Start periodic cleanup to manage memory
  void _startPeriodicCleanup() {
    _cleanupTimer = Timer.periodic(cleanupInterval, (_) async {
      await _performMemoryManagement();
    });
  }

  /// Perform memory management based on pressure level
  Future<void> _performMemoryManagement() async {
    await _checkMemoryPressure();

    switch (_memoryPressureLevel) {
      case 0: // Low pressure - basic cleanup
        await _performBasicCleanup();
        break;
      case 1: // Medium pressure - moderate cleanup
        await _performModerateCleanup();
        break;
      case 2: // High pressure - aggressive cleanup
        await _performAggressiveCleanup();
        break;
    }
  }

  /// Check current memory pressure level
  Future<void> _checkMemoryPressure() async {
    final imageCache = PaintingBinding.instance.imageCache;
    final currentUsage =
        imageCache.currentSizeBytes / imageCache.maximumSizeBytes;

    if (currentUsage > 0.9) {
      _memoryPressureLevel = 2; // High pressure
    } else if (currentUsage > 0.7) {
      _memoryPressureLevel = 1; // Medium pressure
    } else {
      _memoryPressureLevel = 0; // Low pressure
    }
  }

  /// Basic cleanup - remove entries older than 30 minutes
  Future<void> _performBasicCleanup() async {
    final cutoffTime = DateTime.now().subtract(const Duration(minutes: 30));
    final toRemove = <String>[];

    for (final entry in _lastAccessed.entries) {
      if (entry.value.isBefore(cutoffTime)) {
        toRemove.add(entry.key);
      }
    }

    for (final url in toRemove) {
      _cachedUrls.remove(url);
      _lastAccessed.remove(url);
    }
  }

  /// Moderate cleanup - remove 30% of oldest entries
  Future<void> _performModerateCleanup() async {
    final entries = _lastAccessed.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final removeCount = (entries.length * 0.3).round();

    for (int i = 0; i < removeCount && i < entries.length; i++) {
      final url = entries[i].key;
      _cachedUrls.remove(url);
      _lastAccessed.remove(url);
    }
  }

  /// Aggressive cleanup - remove 50% of oldest entries and clear failed URLs
  Future<void> _performAggressiveCleanup() async {
    // Clear failed URLs to free up space
    _failedUrls.clear();

    // Remove 50% of oldest entries
    final entries = _lastAccessed.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final removeCount = (entries.length * 0.5).round();

    for (int i = 0; i < removeCount && i < entries.length; i++) {
      final url = entries[i].key;
      _cachedUrls.remove(url);
      _lastAccessed.remove(url);
    }

    // Force Flutter image cache cleanup
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}

/// Cache statistics for monitoring memory usage
class ImageCacheStats {
  final int cachedImagesCount;
  final int failedImagesCount;
  final int cacheSize; // in MB
  final int maxCacheSize; // in MB
  final int memoryPressureLevel;

  const ImageCacheStats({
    required this.cachedImagesCount,
    required this.failedImagesCount,
    required this.cacheSize,
    required this.maxCacheSize,
    required this.memoryPressureLevel,
  });

  @override
  String toString() {
    return 'ImageCacheStats(cached: $cachedImagesCount, failed: $failedImagesCount, '
        'size: ${cacheSize}MB/${maxCacheSize}MB, pressure: $memoryPressureLevel)';
  }
}
