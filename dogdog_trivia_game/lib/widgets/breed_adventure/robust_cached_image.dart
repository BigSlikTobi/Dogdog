import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../services/image_service.dart';
import 'loading_error_states.dart';

/// A robust cached image widget that provides fallbacks for network connectivity issues
/// especially important for iPhone in profile mode where network access may be limited
class RobustCachedImage extends StatefulWidget {
  final String imageUrl;
  final String? breedName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? semanticLabel;
  final VoidCallback? onImageFailure;

  const RobustCachedImage({
    super.key,
    required this.imageUrl,
    this.breedName,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.semanticLabel,
    this.onImageFailure,
  });

  @override
  State<RobustCachedImage> createState() => _RobustCachedImageState();
}

class _RobustCachedImageState extends State<RobustCachedImage> {
  bool _hasNetworkFailed = false;
  bool _isUsingFallback = false;
  int _retryCount = 0;
  static const int maxRetries = 2;

  @override
  Widget build(BuildContext context) {
    // If we've exhausted network attempts and have a breed name, try local asset
    if (_hasNetworkFailed && widget.breedName != null && !_isUsingFallback) {
      return _buildLocalAssetFallback();
    }

    // If we're explicitly using fallback, show the local asset
    if (_isUsingFallback) {
      return _buildLocalAssetFallback();
    }

    // For iPhone in profile mode, be more aggressive with caching
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,

      // Enhanced caching configuration for better iPhone support
      memCacheWidth: widget.width?.round(),
      memCacheHeight: widget.height?.round(),

      placeholder: (context, url) =>
          widget.placeholder ?? const BreedImageLoading(),

      errorWidget: (context, url, error) {
        debugPrint('Network image failed for $url: $error');

        // On error, try fallback strategies
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleImageError(error);
        });

        return widget.errorWidget ?? _buildErrorWithRetry();
      },

      // Enhanced error handling for better reliability
      httpHeaders: const {
        'User-Agent': 'DogDog-TriviGame/1.0',
        'Accept': 'image/*',
      },

      // Longer timeout for slower connections
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),

      // Force refresh on certain errors
      cacheKey: _retryCount > 0
          ? '${widget.imageUrl}_retry_$_retryCount'
          : null,
    );
  }

  void _handleImageError(dynamic error) {
    if (!mounted) return;

    setState(() {
      _retryCount++;

      // If we've tried multiple times or have a local fallback available, switch to fallback
      if (_retryCount >= maxRetries || widget.breedName != null) {
        _hasNetworkFailed = true;
        _isUsingFallback = widget.breedName != null;
      }
    });

    // Notify parent of image failure
    widget.onImageFailure?.call();
  }

  Widget _buildLocalAssetFallback() {
    if (widget.breedName == null) {
      return _buildErrorWithRetry();
    }

    return ImageService.getDogBreedImage(
      breedName: widget.breedName!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: widget.placeholder,
      errorWidget: _buildErrorWithRetry(),
      semanticLabel: widget.semanticLabel,
    );
  }

  Widget _buildErrorWithRetry() {
    return BreedImageError(
      width: widget.width,
      height: widget.height,
      onRetry: _canRetry() ? _handleRetry : null,
      errorMessage: _hasNetworkFailed
          ? 'Network image failed to load'
          : 'Image could not be loaded',
    );
  }

  bool _canRetry() {
    return _retryCount < maxRetries && !_isUsingFallback;
  }

  void _handleRetry() {
    if (!mounted || !_canRetry()) return;

    setState(() {
      _hasNetworkFailed = false;
      _isUsingFallback = false;
      _retryCount++;
    });
  }
}

/// Extension to identify breed names from URLs for better fallback mapping
extension BreedNameExtractor on String {
  String? extractBreedName() {
    try {
      // Extract breed name from Supabase URLs like:
      // https://...../labrador-retriever_1_1024x1024_20250809T120349Z.png
      final uri = Uri.parse(this);
      final filename = uri.pathSegments.last;

      // Remove file extension and timestamp
      final nameWithoutExtension = filename.split('.').first;
      final parts = nameWithoutExtension.split('_');

      if (parts.isNotEmpty) {
        final breedPart = parts.first;

        // Convert hyphenated breed names to proper format
        return breedPart
            .split('-')
            .map(
              (word) => word.isNotEmpty
                  ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                  : word,
            )
            .join(' ');
      }
    } catch (e) {
      debugPrint('Could not extract breed name from URL: $this');
    }
    return null;
  }
}
