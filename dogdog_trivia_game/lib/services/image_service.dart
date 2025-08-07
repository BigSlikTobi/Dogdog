import 'package:flutter/material.dart';

/// Service for optimized image loading and caching
///
/// This service provides:
/// - Efficient image loading and caching
/// - Fallback placeholders for image loading failures
/// - Support for different screen densities
/// - Memory-efficient image management
class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  // Cache for preloaded images
  final Map<String, ImageProvider> _imageCache = {};
  final Map<String, bool> _loadingStates = {};

  /// Preloads critical images for better performance
  static Future<void> preloadCriticalImages(BuildContext context) async {
    final instance = ImageService();

    // List of critical images to preload
    final criticalImages = [
      'assets/images/chihuahua.png',
      'assets/images/cocker.png',
      'assets/images/schaeferhund.png',
      'assets/images/dogge.png',
      'assets/images/success1.png',
      'assets/images/success2.png',
    ];

    // Ensure the widget tree is built before preloading
    await Future.delayed(Duration.zero);

    // Preload images in parallel
    try {
      await Future.wait(
        criticalImages.map(
          (imagePath) => instance._preloadImage(context, imagePath),
        ),
      );
    } catch (e) {
      debugPrint('Error preloading critical images: $e');
      // Continue without preloading - images will load on demand
    }
  }

  /// Preloads a single image
  Future<void> _preloadImage(BuildContext context, String imagePath) async {
    if (_imageCache.containsKey(imagePath) ||
        _loadingStates[imagePath] == true) {
      return;
    }

    _loadingStates[imagePath] = true;

    try {
      final imageProvider = AssetImage(imagePath);
      await precacheImage(imageProvider, context);
      _imageCache[imagePath] = imageProvider;
    } catch (e) {
      debugPrint('Failed to preload image: $imagePath - $e');
    } finally {
      _loadingStates[imagePath] = false;
    }
  }

  /// Gets an optimized image widget with fallback support
  static Widget getOptimizedImage({
    required String imagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Widget? placeholder,
    Widget? errorWidget,
    String? semanticLabel,
    bool enableMemoryCache = true,
  }) {
    return _OptimizedImageWidget(
      imagePath: imagePath,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      semanticLabel: semanticLabel,
      enableMemoryCache: enableMemoryCache,
    );
  }

  /// Gets a dog breed image with optimized loading
  static Widget getDogBreedImage({
    required String breedName,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Widget? placeholder,
    Widget? errorWidget,
    String? semanticLabel,
  }) {
    final imagePath = _getDogBreedImagePath(breedName);

    return getOptimizedImage(
      imagePath: imagePath,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder ?? _getDefaultDogPlaceholder(),
      errorWidget: errorWidget ?? _getDefaultDogErrorWidget(),
      semanticLabel: semanticLabel ?? '$breedName dog breed image',
    );
  }

  /// Gets a success animation image with optimized loading
  static Widget getSuccessImage({
    required bool isFirstImage,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Widget? placeholder,
    Widget? errorWidget,
    String? semanticLabel,
  }) {
    final imagePath = isFirstImage
        ? 'assets/images/success1.png'
        : 'assets/images/success2.png';

    return getOptimizedImage(
      imagePath: imagePath,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder ?? _getDefaultSuccessPlaceholder(),
      errorWidget: errorWidget ?? _getDefaultSuccessErrorWidget(),
      semanticLabel: semanticLabel ?? 'Success celebration image',
    );
  }

  /// Maps breed names to their image paths
  static String _getDogBreedImagePath(String breedName) {
    switch (breedName.toLowerCase()) {
      case 'chihuahua':
        return 'assets/images/chihuahua.png';
      case 'cocker':
      case 'cocker spaniel':
        return 'assets/images/cocker.png';
      case 'schaeferhund':
      case 'german shepherd':
        return 'assets/images/schaeferhund.png';
      case 'dogge':
      case 'great dane':
        return 'assets/images/dogge.png';
      case 'mops':
      case 'pug':
        return 'assets/images/mops.png';
      default:
        return 'assets/images/chihuahua.png'; // Default fallback
    }
  }

  /// Default placeholder for dog breed images
  static Widget _getDefaultDogPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  /// Default error widget for dog breed images
  static Widget _getDefaultDogErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.pets, size: 48, color: Colors.grey),
    );
  }

  /// Default placeholder for success images
  static Widget _getDefaultSuccessPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ),
    );
  }

  /// Default error widget for success images
  static Widget _getDefaultSuccessErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.check_circle, size: 48, color: Colors.green),
    );
  }

  /// Clears the image cache to free memory
  static void clearCache() {
    final instance = ImageService();
    instance._imageCache.clear();
    instance._loadingStates.clear();
  }

  /// Gets cache statistics for debugging
  static Map<String, dynamic> getCacheStats() {
    final instance = ImageService();
    return {
      'cachedImages': instance._imageCache.length,
      'loadingImages': instance._loadingStates.values
          .where((loading) => loading)
          .length,
      'cacheKeys': instance._imageCache.keys.toList(),
    };
  }
}

/// Internal optimized image widget with caching and error handling
class _OptimizedImageWidget extends StatefulWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? semanticLabel;
  final bool enableMemoryCache;

  const _OptimizedImageWidget({
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.errorWidget,
    this.semanticLabel,
    this.enableMemoryCache = true,
  });

  @override
  State<_OptimizedImageWidget> createState() => _OptimizedImageWidgetState();
}

class _OptimizedImageWidgetState extends State<_OptimizedImageWidget> {
  bool _hasError = false;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    if (_hasError && widget.errorWidget != null) {
      return _wrapWithSemantics(widget.errorWidget!);
    }

    Widget imageWidget = Image.asset(
      widget.imagePath,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      cacheWidth: widget.enableMemoryCache ? _calculateCacheWidth() : null,
      cacheHeight: widget.enableMemoryCache ? _calculateCacheHeight() : null,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _isLoading) {
              setState(() {
                _isLoading = false;
              });
            }
          });
          return child;
        }

        return widget.placeholder ??
            SizedBox(
              width: widget.width,
              height: widget.height,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
          }
        });

        return widget.errorWidget ??
            SizedBox(
              width: widget.width,
              height: widget.height,
              child: const Icon(Icons.error, color: Colors.grey),
            );
      },
    );

    return _wrapWithSemantics(imageWidget);
  }

  Widget _wrapWithSemantics(Widget child) {
    if (widget.semanticLabel != null) {
      return Semantics(label: widget.semanticLabel, image: true, child: child);
    }
    return child;
  }

  /// Calculates optimal cache width based on device pixel ratio
  int? _calculateCacheWidth() {
    if (widget.width == null) return null;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (widget.width! * devicePixelRatio).round();
  }

  /// Calculates optimal cache height based on device pixel ratio
  int? _calculateCacheHeight() {
    if (widget.height == null) return null;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (widget.height! * devicePixelRatio).round();
  }
}
