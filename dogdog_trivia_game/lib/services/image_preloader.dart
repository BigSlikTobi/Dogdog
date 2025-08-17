import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Simple and reliable image preloader for iPhone profile mode
class ImagePreloader {
  static ImagePreloader? _instance;
  static ImagePreloader get instance => _instance ??= ImagePreloader._();

  ImagePreloader._();

  final Set<String> _preloadedUrls = {};
  final Set<String> _failedUrls = {};

  /// Preload critical breed images at app startup
  Future<void> preloadCriticalBreedImages(BuildContext context) async {
    if (!context.mounted) return;

    debugPrint(
      'Starting preload of critical breed images for iPhone optimization',
    );

    // List of most common breed images that should be cached
    final criticalImageUrls = [
      'https://sluyywhdnyuabvgibbou.supabase.co/storage/v1/object/public/puppies/labrador-retriever_1_1024x1024_20250809T120349Z.png',
      'https://sluyywhdnyuabvgibbou.supabase.co/storage/v1/object/public/puppies/golden-retriever_1_1024x1024_20250809T111315Z.png',
      'https://sluyywhdnyuabvgibbou.supabase.co/storage/v1/object/public/puppies/german-shepherd_1_1024x1024_20250809T111315Z.png',
      'https://sluyywhdnyuabvgibbou.supabase.co/storage/v1/object/public/puppies/chihuahua_1_1024x1024_20250809T111315Z.png',
      'https://sluyywhdnyuabvgibbou.supabase.co/storage/v1/object/public/puppies/bulldog_1_1024x1024_20250809T111315Z.png',
    ];

    int successCount = 0;

    // Preload images in parallel with timeout
    final futures = criticalImageUrls.map(
      (url) => _preloadSingleImage(context, url).timeout(
        const Duration(seconds: 8), // Shorter timeout for profile mode
        onTimeout: () {
          debugPrint('Timeout preloading: $url');
          _failedUrls.add(url);
          return false;
        },
      ),
    );

    final results = await Future.wait(futures, eagerError: false);
    successCount = results.where((success) => success).length;

    debugPrint(
      'Preloaded $successCount/${criticalImageUrls.length} critical images',
    );

    // Check if context is still valid before proceeding
    if (!context.mounted) return;

    // Also force cache some local assets as fallbacks
    await _preloadLocalAssets(context);
  }

  /// Preload a single network image
  Future<bool> _preloadSingleImage(BuildContext context, String url) async {
    if (_preloadedUrls.contains(url) || _failedUrls.contains(url)) {
      return _preloadedUrls.contains(url);
    }

    if (!context.mounted) return false;

    try {
      final imageProvider = CachedNetworkImageProvider(
        url,
        headers: const {
          'User-Agent': 'DogDog-TriviGame/1.0',
          'Accept': 'image/*',
          'Cache-Control': 'max-age=86400', // 24 hours
        },
      );

      await precacheImage(imageProvider, context);
      _preloadedUrls.add(url);

      debugPrint('✅ Preloaded: ${_extractBreedName(url)}');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to preload: ${_extractBreedName(url)} - $e');
      _failedUrls.add(url);
      return false;
    }
  }

  /// Preload local asset images as fallbacks
  Future<void> _preloadLocalAssets(BuildContext context) async {
    if (!context.mounted) return;

    final localAssets = [
      'assets/images/chihuahua.png',
      'assets/images/cocker.png',
      'assets/images/schaeferhund.png',
      'assets/images/dogge.png',
      'assets/images/mops.png',
      'assets/images/success1.png',
      'assets/images/success2.png',
    ];

    try {
      final futures = localAssets.map((asset) async {
        try {
          await precacheImage(AssetImage(asset), context);
          debugPrint('✅ Preloaded local asset: $asset');
        } catch (e) {
          debugPrint('❌ Failed to preload local asset: $asset - $e');
        }
      });

      await Future.wait(futures, eagerError: false);
      debugPrint('Local asset preloading completed');
    } catch (e) {
      debugPrint('Error preloading local assets: $e');
    }
  }

  /// Extract breed name from URL for logging
  String _extractBreedName(String url) {
    try {
      final uri = Uri.parse(url);
      final filename = uri.pathSegments.last;
      final nameWithoutExtension = filename.split('.').first;
      final parts = nameWithoutExtension.split('_');
      if (parts.isNotEmpty) {
        return parts.first.replaceAll('-', ' ');
      }
    } catch (e) {
      // Ignore extraction errors
    }
    return 'Unknown';
  }

  /// Check if an image URL was successfully preloaded
  bool isPreloaded(String url) => _preloadedUrls.contains(url);

  /// Check if an image URL failed to preload
  bool hasFailed(String url) => _failedUrls.contains(url);

  /// Get statistics for debugging
  Map<String, int> getStats() => {
    'preloaded': _preloadedUrls.length,
    'failed': _failedUrls.length,
  };

  /// Clear all cached state (for testing)
  void clear() {
    _preloadedUrls.clear();
    _failedUrls.clear();
  }
}
