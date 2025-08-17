import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'breed_adventure_performance_monitor.dart';

/// Frame rate optimizer for smooth 60fps animations in breed adventure
class FrameRateOptimizer {
  static FrameRateOptimizer? _instance;
  static FrameRateOptimizer get instance =>
      _instance ??= FrameRateOptimizer._();

  FrameRateOptimizer._();

  // Performance configuration
  static const double targetFrameTime = 16.67; // 60 FPS = 16.67ms per frame
  static const double warningFrameTime = 20.0; // Warning at 50 FPS
  static const double criticalFrameTime = 33.33; // Critical at 30 FPS

  // Animation optimization settings
  bool _reduceAnimations = false;
  bool _skipNonEssentialAnimations = false;
  AnimationQuality _currentQuality = AnimationQuality.high;

  // Frame pacing
  Timer? _framePacingTimer;
  bool _isOptimizing = false;

  /// Initialize frame rate optimization
  void initialize() {
    if (_isOptimizing) return;

    _startFrameOptimization();
    _isOptimizing = true;

    debugPrint('FrameRateOptimizer initialized for 60fps target');
  }

  /// Start frame rate optimization monitoring
  void _startFrameOptimization() {
    // Monitor frame times and adjust quality accordingly
    Timer.periodic(const Duration(seconds: 2), (_) {
      _analyzeAndOptimizeFrameRate();
    });
  }

  /// Analyze frame rate and adjust animation quality
  void _analyzeAndOptimizeFrameRate() {
    final performanceMonitor = BreedAdventurePerformanceMonitor.instance;
    final stats = performanceMonitor.getPerformanceStats();

    // Determine if we need to reduce animation quality
    if (stats.averageFPS < 45.0) {
      _setAnimationQuality(AnimationQuality.low);
    } else if (stats.averageFPS < 55.0) {
      _setAnimationQuality(AnimationQuality.medium);
    } else {
      _setAnimationQuality(AnimationQuality.high);
    }

    // Enable animation reduction if performance is poor
    _reduceAnimations = stats.averageFPS < 40.0;
    _skipNonEssentialAnimations = stats.averageFPS < 30.0;

    debugPrint(
      'Frame rate optimization: FPS=${stats.averageFPS.toStringAsFixed(1)}, '
      'Quality=$_currentQuality, Reduce=$_reduceAnimations',
    );
  }

  /// Set animation quality level
  void _setAnimationQuality(AnimationQuality quality) {
    if (_currentQuality == quality) return;

    _currentQuality = quality;
    debugPrint('Animation quality changed to: $quality');
  }

  /// Get optimized animation duration based on current performance
  Duration getOptimizedDuration(
    Duration originalDuration, {
    bool isEssential = true,
  }) {
    if (!isEssential && _skipNonEssentialAnimations) {
      return Duration.zero; // Skip non-essential animations
    }

    switch (_currentQuality) {
      case AnimationQuality.low:
        return Duration(
          milliseconds: (originalDuration.inMilliseconds * 0.5).round(),
        );
      case AnimationQuality.medium:
        return Duration(
          milliseconds: (originalDuration.inMilliseconds * 0.75).round(),
        );
      case AnimationQuality.high:
        return originalDuration;
    }
  }

  /// Get optimized animation curve based on performance
  Curve getOptimizedCurve(Curve originalCurve, {bool isEssential = true}) {
    if (!isEssential && _skipNonEssentialAnimations) {
      return Curves.linear; // Simplest curve for non-essential animations
    }

    switch (_currentQuality) {
      case AnimationQuality.low:
        return Curves.linear; // Simplest curve for better performance
      case AnimationQuality.medium:
        return Curves.easeInOut; // Moderate curve complexity
      case AnimationQuality.high:
        return originalCurve; // Use original curve
    }
  }

  /// Create optimized animation controller
  AnimationController createOptimizedController({
    required Duration duration,
    required TickerProvider vsync,
    bool isEssential = true,
    String? debugLabel,
  }) {
    final optimizedDuration = getOptimizedDuration(
      duration,
      isEssential: isEssential,
    );

    if (optimizedDuration == Duration.zero) {
      // Return a dummy controller that completes immediately
      final controller = AnimationController(
        duration: const Duration(milliseconds: 1),
        vsync: vsync,
      );
      controller.value = 1.0; // Complete immediately
      return controller;
    }

    final controller = AnimationController(
      duration: optimizedDuration,
      vsync: vsync,
      debugLabel: debugLabel,
    );

    // Track animation performance
    if (debugLabel != null) {
      BreedAdventurePerformanceMonitor.instance.trackAnimationStart(
        debugLabel,
        controller,
      );
    }

    return controller;
  }

  /// Create performance-optimized transition
  Widget createOptimizedTransition({
    required Widget child,
    required Animation<double> animation,
    AnimationType type = AnimationType.fade,
    bool isEssential = true,
  }) {
    if (!isEssential && _skipNonEssentialAnimations) {
      return child; // Skip transition entirely
    }

    switch (type) {
      case AnimationType.fade:
        return _createOptimizedFadeTransition(child, animation);
      case AnimationType.scale:
        return _createOptimizedScaleTransition(child, animation);
      case AnimationType.slide:
        return _createOptimizedSlideTransition(child, animation);
      case AnimationType.rotation:
        return _currentQuality == AnimationQuality.low
            ? child // Skip rotation in low quality
            : _createOptimizedRotationTransition(child, animation);
    }
  }

  /// Create optimized fade transition
  Widget _createOptimizedFadeTransition(
    Widget child,
    Animation<double> animation,
  ) {
    switch (_currentQuality) {
      case AnimationQuality.low:
        // Use simple opacity changes with fewer intermediate values
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final opacity = animation.value > 0.5 ? 1.0 : 0.0;
            return Opacity(opacity: opacity, child: child);
          },
          child: child,
        );
      case AnimationQuality.medium:
      case AnimationQuality.high:
        return FadeTransition(opacity: animation, child: child);
    }
  }

  /// Create optimized scale transition
  Widget _createOptimizedScaleTransition(
    Widget child,
    Animation<double> animation,
  ) {
    switch (_currentQuality) {
      case AnimationQuality.low:
        // Use transform instead of ScaleTransition for better performance
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(scale: animation.value, child: child);
          },
          child: child,
        );
      case AnimationQuality.medium:
      case AnimationQuality.high:
        return ScaleTransition(scale: animation, child: child);
    }
  }

  /// Create optimized slide transition
  Widget _createOptimizedSlideTransition(
    Widget child,
    Animation<double> animation,
  ) {
    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(animation);

    switch (_currentQuality) {
      case AnimationQuality.low:
        // Simplified sliding with fewer intermediate positions
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final progress = animation.value;
            final offset = progress > 0.5
                ? Offset.zero
                : const Offset(0.0, 1.0);
            return Transform.translate(
              offset: Offset(
                offset.dx * MediaQuery.of(context).size.width,
                offset.dy * MediaQuery.of(context).size.height,
              ),
              child: child,
            );
          },
          child: child,
        );
      case AnimationQuality.medium:
      case AnimationQuality.high:
        return SlideTransition(position: offsetAnimation, child: child);
    }
  }

  /// Create optimized rotation transition
  Widget _createOptimizedRotationTransition(
    Widget child,
    Animation<double> animation,
  ) {
    final rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(animation);

    return RotationTransition(turns: rotationAnimation, child: child);
  }

  /// Optimize widget rebuild frequency
  Widget optimizeRebuilds({
    required Widget child,
    required bool shouldRebuild,
    String? debugLabel,
  }) {
    if (_currentQuality == AnimationQuality.low) {
      // Reduce rebuild frequency in low quality mode
      return RepaintBoundary(
        child: shouldRebuild ? child : const SizedBox.shrink(),
      );
    }

    return RepaintBoundary(child: child);
  }

  /// Schedule animation with frame pacing
  Future<void> scheduleAnimation(VoidCallback animationCallback) async {
    if (_currentQuality == AnimationQuality.low) {
      // In low quality mode, wait for next frame
      await SchedulerBinding.instance.endOfFrame;
    }

    animationCallback();
  }

  /// Get current animation quality
  AnimationQuality get currentQuality => _currentQuality;

  /// Check if animations should be reduced
  bool get shouldReduceAnimations => _reduceAnimations;

  /// Check if non-essential animations should be skipped
  bool get shouldSkipNonEssentialAnimations => _skipNonEssentialAnimations;

  /// Force set animation quality (for testing or user preferences)
  void forceAnimationQuality(AnimationQuality quality) {
    _currentQuality = quality;
    debugPrint('Animation quality forced to: $quality');
  }

  /// Reset to automatic optimization
  void resetToAutoOptimization() {
    _reduceAnimations = false;
    _skipNonEssentialAnimations = false;
    _currentQuality = AnimationQuality.high;
    debugPrint('Reset to automatic frame rate optimization');
  }

  /// Dispose of the optimizer
  void dispose() {
    _framePacingTimer?.cancel();
    _isOptimizing = false;
  }
}

/// Animation quality levels for performance optimization
enum AnimationQuality {
  low, // Minimal animations, simple curves, reduced duration
  medium, // Moderate animations, standard curves, normal duration
  high, // Full animations, complex curves, full duration
}

/// Animation types for optimization
enum AnimationType { fade, scale, slide, rotation }

/// Extension for easy access to frame rate optimization
extension AnimationControllerOptimization on AnimationController {
  /// Start animation with frame rate optimization
  TickerFuture forwardOptimized({bool isEssential = true}) {
    final optimizer = FrameRateOptimizer.instance;

    if (!isEssential && optimizer.shouldSkipNonEssentialAnimations) {
      value = 1.0;
      return TickerFuture.complete();
    }

    return forward();
  }

  /// Reverse animation with frame rate optimization
  TickerFuture reverseOptimized({bool isEssential = true}) {
    final optimizer = FrameRateOptimizer.instance;

    if (!isEssential && optimizer.shouldSkipNonEssentialAnimations) {
      value = 0.0;
      return TickerFuture.complete();
    }

    return reverse();
  }
}
