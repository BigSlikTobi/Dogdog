import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/breed.dart';
import '../services/image_service.dart';

/// Enhanced image cache manager specifically optimized for iPhone profile mode
/// and network-constrained environments
class EnhancedImageCacheManager {
  static EnhancedImageCacheManager? _instance;
  static EnhancedImageCacheManager get instance =>
      _instance ??= EnhancedImageCacheManager._();

  EnhancedImageCacheManager._();

  // Track image loading status
  final Set<String> _preloadedImages = <String>{};
  final Set<String> _failedImages = <String>{};
  final Map<String, String> _fallbackMap = <String, String>{};

  bool _isInitialized = false;

  /// Initialize the enhanced cache manager with aggressive preloading
  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    debugPrint(
      'Initializing EnhancedImageCacheManager for iPhone optimization',
    );

    // Configure Flutter's image cache with iPhone-optimized settings
    _configureImageCache();

    // Build fallback mapping for known breeds
    _buildFallbackMapping();

    _isInitialized = true;
    debugPrint('EnhancedImageCacheManager initialized successfully');
  }

  /// Configure Flutter's image cache with optimal settings for iPhone
  void _configureImageCache() {
    final imageCache = PaintingBinding.instance.imageCache;

    // Increase cache limits for better performance on iPhone
    imageCache.maximumSize = 150; // Increased from typical 100
    imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50MB cache

    debugPrint(
      'Image cache configured: ${imageCache.maximumSize} items, ${imageCache.maximumSizeBytes ~/ (1024 * 1024)}MB',
    );
  }

  /// Build mapping between network URLs and local asset fallbacks
  void _buildFallbackMapping() {
    // Known breed mappings for local fallbacks
    _fallbackMap.addAll({
      'chihuahua': 'assets/images/chihuahua.png',
      'cocker': 'assets/images/cocker.png',
      'schaeferhund': 'assets/images/schaeferhund.png',
      'german-shepherd': 'assets/images/schaeferhund.png',
      'dogge': 'assets/images/dogge.png',
      'great-dane': 'assets/images/dogge.png',
      'mops': 'assets/images/mops.png',
      'pug': 'assets/images/mops.png',
      'labrador': 'assets/images/chihuahua.png', // Fallback to available image
      'labrador-retriever':
          'assets/images/chihuahua.png', // Fallback to available image
    });

    debugPrint('Fallback mapping built for ${_fallbackMap.length} breeds');
  }

  /// Aggressively preload critical images for immediate gameplay
  Future<void> preloadCriticalImages(
    BuildContext context,
    List<Breed> criticalBreeds,
  ) async {
    if (!_isInitialized) {
      await initialize(context);
    }

    debugPrint(
      'Starting aggressive preload of ${criticalBreeds.length} critical images',
    );

    // Use parallel loading with timeout for iPhone optimization
    final futures = criticalBreeds.map(
      (breed) =>
          _preloadSingleImage(context, breed.imageUrl, breed.name).timeout(
            const Duration(seconds: 10), // Timeout for profile mode
            onTimeout: () {
              debugPrint('Timeout preloading ${breed.name}, will try fallback');
              _failedImages.add(breed.imageUrl);
              return false;
            },
          ),
    );

    final results = await Future.wait(futures, eagerError: false);
    final successCount = results.where((success) => success).length;

    debugPrint(
      'Preloaded $successCount/${criticalBreeds.length} critical images',
    );
  }

  /// Preload a single image with fallback handling
  Future<bool> _preloadSingleImage(
    BuildContext context,
    String imageUrl,
    String breedName,
  ) async {
    try {
      // First try to preload the network image
      final imageProvider = CachedNetworkImageProvider(
        imageUrl,
        headers: const {
          'User-Agent': 'DogDog-TriviGame/1.0',
          'Accept': 'image/*',
        },
      );

      // Store the context before async operation
      final contextIsValid = context.mounted;
      if (!contextIsValid) return false;

      await precacheImage(imageProvider, context);
      _preloadedImages.add(imageUrl);

      debugPrint('Successfully preloaded network image for $breedName');
      return true;
    } catch (e) {
      debugPrint('Failed to preload network image for $breedName: $e');
      _failedImages.add(imageUrl);

      // Check if context is still valid before proceeding
      if (!context.mounted) return false;

      // Try to preload local fallback
      return await _preloadFallbackImage(context, breedName);
    }
  }

  /// Preload local fallback image
  Future<bool> _preloadFallbackImage(
    BuildContext context,
    String breedName,
  ) async {
    try {
      final normalizedName = breedName.toLowerCase().replaceAll(' ', '-');
      final fallbackPath = _fallbackMap[normalizedName];

      // Store the context before async operation
      final contextIsValid = context.mounted;
      if (!contextIsValid) return false;

      if (fallbackPath != null) {
        await precacheImage(AssetImage(fallbackPath), context);
        debugPrint('Preloaded fallback image for $breedName: $fallbackPath');
        return true;
      }

      // If no specific fallback, preload a default image
      await precacheImage(
        const AssetImage('assets/images/chihuahua.png'),
        context,
      );
      debugPrint('Preloaded default fallback for $breedName');
      return true;
    } catch (e) {
      debugPrint('Failed to preload fallback for $breedName: $e');
      return false;
    }
  }

  /// Background preload with lower priority for non-critical images
  Future<void> backgroundPreload(
    BuildContext context,
    List<Breed> breeds,
  ) async {
    if (!_isInitialized) return;

    debugPrint('Starting background preload of ${breeds.length} images');

    // Staggered loading to avoid overwhelming the device
    for (int i = 0; i < breeds.length; i++) {
      final breed = breeds[i];

      // Skip if already processed
      if (_preloadedImages.contains(breed.imageUrl) ||
          _failedImages.contains(breed.imageUrl)) {
        continue;
      }

      // Add delay between background loads
      await Future.delayed(Duration(milliseconds: 200 * i));

      // Check if context is still valid after delay
      if (!context.mounted) return;

      // Load in background without blocking
      unawaited(_preloadSingleImage(context, breed.imageUrl, breed.name));
    }
  }

  /// Get the appropriate image widget with fallback support
  Widget getOptimizedImage({
    required String imageUrl,
    required String breedName,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    // Check if we should immediately use fallback
    if (_failedImages.contains(imageUrl)) {
      return _getFallbackImage(
        breedName: breedName,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    }

    // Return network image with enhanced caching
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,

      // Enhanced caching settings
      memCacheWidth: width?.round(),
      memCacheHeight: height?.round(),

      // Optimized for iPhone profile mode
      httpHeaders: const {
        'User-Agent': 'DogDog-TriviGame/1.0',
        'Accept': 'image/*',
        'Cache-Control': 'max-age=31536000', // 1 year cache
      },

      placeholder: (context, url) =>
          placeholder ?? const CircularProgressIndicator(),

      errorWidget: (context, url, error) {
        // Mark as failed and return fallback
        _failedImages.add(imageUrl);
        debugPrint('Image failed for $breedName, using fallback: $error');

        return _getFallbackImage(
          breedName: breedName,
          width: width,
          height: height,
          fit: fit,
          placeholder: placeholder,
          errorWidget: errorWidget,
        );
      },

      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }

  /// Get local fallback image
  Widget _getFallbackImage({
    required String breedName,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return ImageService.getDogBreedImage(
      breedName: breedName,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }

  /// Clear cache and reset state
  void clearCache() {
    _preloadedImages.clear();
    _failedImages.clear();
    PaintingBinding.instance.imageCache.clear();
    debugPrint('Image cache cleared');
  }

  /// Get cache statistics
  Map<String, dynamic> getStatistics() {
    return {
      'preloadedImages': _preloadedImages.length,
      'failedImages': _failedImages.length,
      'fallbackMappings': _fallbackMap.length,
      'isInitialized': _isInitialized,
    };
  }
}
