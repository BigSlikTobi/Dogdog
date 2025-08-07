import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utility class for common animations used throughout the app
class AppAnimations {
  // Animation durations
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration extraSlowDuration = Duration(milliseconds: 800);

  // Reduced motion durations (for accessibility)
  static const Duration reducedFastDuration = Duration(milliseconds: 50);
  static const Duration reducedNormalDuration = Duration(milliseconds: 100);
  static const Duration reducedSlowDuration = Duration(milliseconds: 150);

  // Animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;
  static const Curve reducedMotionCurve = Curves.linear;

  /// Check if reduced motion is preferred for accessibility
  static bool isReducedMotionPreferred(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Get appropriate duration based on accessibility preferences
  static Duration getDuration(BuildContext context, Duration normalDuration) {
    if (isReducedMotionPreferred(context)) {
      if (normalDuration == fastDuration) return reducedFastDuration;
      if (normalDuration == normalDuration) return reducedNormalDuration;
      if (normalDuration == slowDuration) return reducedSlowDuration;
      return Duration(
        milliseconds: (normalDuration.inMilliseconds * 0.3).round(),
      );
    }
    return normalDuration;
  }

  /// Get appropriate curve based on accessibility preferences
  static Curve getCurve(BuildContext context, Curve normalCurve) {
    return isReducedMotionPreferred(context) ? reducedMotionCurve : normalCurve;
  }

  /// Creates a slide transition from bottom to top
  static Widget slideFromBottom({
    required Widget child,
    required Animation<double> animation,
    double offset = 1.0,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0.0, offset),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: smoothCurve)),
      child: child,
    );
  }

  /// Creates a slide transition from right to left
  static Widget slideFromRight({
    required Widget child,
    required Animation<double> animation,
    double offset = 1.0,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(offset, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: smoothCurve)),
      child: child,
    );
  }

  /// Creates a fade transition
  static Widget fadeIn({
    required Widget child,
    required Animation<double> animation,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(parent: animation, curve: defaultCurve)),
      child: child,
    );
  }

  /// Creates a scale transition with bounce effect
  static Widget scaleWithBounce({
    required Widget child,
    required Animation<double> animation,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(parent: animation, curve: bounceCurve)),
      child: child,
    );
  }

  /// Creates a combined fade and scale transition
  static Widget fadeAndScale({
    required Widget child,
    required Animation<double> animation,
    double scaleBegin = 0.8,
    double scaleEnd = 1.0,
    double fadeBegin = 0.0,
    double fadeEnd = 1.0,
  }) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: fadeBegin,
        end: fadeEnd,
      ).animate(CurvedAnimation(parent: animation, curve: defaultCurve)),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: scaleBegin,
          end: scaleEnd,
        ).animate(CurvedAnimation(parent: animation, curve: bounceCurve)),
        child: child,
      ),
    );
  }

  /// Creates a rotation animation
  static Widget rotate({
    required Widget child,
    required Animation<double> animation,
    double turns = 1.0,
  }) {
    return RotationTransition(
      turns: Tween<double>(
        begin: 0.0,
        end: turns,
      ).animate(CurvedAnimation(parent: animation, curve: defaultCurve)),
      child: child,
    );
  }

  /// Creates a celebration animation with multiple effects
  static Widget celebration({
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final bounceValue = Curves.elasticOut.transform(animation.value);
        final rotationValue = animation.value * 0.1; // Small rotation

        return Transform.scale(
          scale: 1.0 + (bounceValue * 0.2),
          child: Transform.rotate(angle: rotationValue, child: child),
        );
      },
      child: child,
    );
  }

  /// Creates a shimmer loading effect
  static Widget shimmer({
    required Widget child,
    required Animation<double> animation,
    Color baseColor = const Color(0xFFE5E7EB),
    Color highlightColor = const Color(0xFFF3F4F6),
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [0.0, animation.value, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }

  /// Creates a pulse animation
  static Widget pulse({
    required Widget child,
    required Animation<double> animation,
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale =
            minScale +
            (maxScale - minScale) *
                (0.5 + 0.5 * math.sin(animation.value * 2 * math.pi));
        return Transform.scale(scale: scale, child: child);
      },
      child: child,
    );
  }

  /// Creates a wave animation for progress indicators
  static Widget wave({
    required Widget child,
    required Animation<double> animation,
    double amplitude = 10.0,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            amplitude * math.sin(animation.value * 2 * math.pi),
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Custom page route with slide transition
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final SlideDirection direction;

  SlidePageRoute({
    required this.child,
    this.direction = SlideDirection.rightToLeft,
    super.settings,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           Offset begin;
           switch (direction) {
             case SlideDirection.rightToLeft:
               begin = const Offset(1.0, 0.0);
               break;
             case SlideDirection.leftToRight:
               begin = const Offset(-1.0, 0.0);
               break;
             case SlideDirection.topToBottom:
               begin = const Offset(0.0, -1.0);
               break;
             case SlideDirection.bottomToTop:
               begin = const Offset(0.0, 1.0);
               break;
           }

           // Add fade effect to slide transition
           return SlideTransition(
             position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
               CurvedAnimation(
                 parent: animation,
                 curve: AppAnimations.smoothCurve,
               ),
             ),
             child: FadeTransition(opacity: animation, child: child),
           );
         },
         transitionDuration: AppAnimations.normalDuration,
       );
}

/// Custom page route with fade transition
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  FadePageRoute({required this.child, super.settings})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: AppAnimations.normalDuration,
      );
}

/// Custom page route with scale transition
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  ScalePageRoute({required this.child, super.settings})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final isReducedMotion = AppAnimations.isReducedMotionPreferred(
            context,
          );
          final curve = AppAnimations.getCurve(
            context,
            AppAnimations.bounceCurve,
          );
          final duration = AppAnimations.getDuration(
            context,
            AppAnimations.slowDuration,
          );

          // Simplified transition for reduced motion
          if (isReducedMotion) {
            return FadeTransition(opacity: animation, child: child);
          }

          return ScaleTransition(
            scale: Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(CurvedAnimation(parent: animation, curve: curve)),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: AppAnimations.slowDuration,
      );
}

/// Modern page route with combined slide and scale transition
class ModernPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final SlideDirection direction;

  ModernPageRoute({
    required this.child,
    this.direction = SlideDirection.rightToLeft,
    super.settings,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final isReducedMotion = AppAnimations.isReducedMotionPreferred(
             context,
           );
           final curve = AppAnimations.getCurve(
             context,
             AppAnimations.smoothCurve,
           );

           Offset begin;
           switch (direction) {
             case SlideDirection.rightToLeft:
               begin = const Offset(1.0, 0.0);
               break;
             case SlideDirection.leftToRight:
               begin = const Offset(-1.0, 0.0);
               break;
             case SlideDirection.topToBottom:
               begin = const Offset(0.0, -1.0);
               break;
             case SlideDirection.bottomToTop:
               begin = const Offset(0.0, 1.0);
               break;
           }

           // Simplified transition for reduced motion
           if (isReducedMotion) {
             return FadeTransition(opacity: animation, child: child);
           }

           // Combined slide, scale, and fade transition
           return SlideTransition(
             position: Tween<Offset>(
               begin: begin,
               end: Offset.zero,
             ).animate(CurvedAnimation(parent: animation, curve: curve)),
             child: ScaleTransition(
               scale: Tween<double>(
                 begin: 0.9,
                 end: 1.0,
               ).animate(CurvedAnimation(parent: animation, curve: curve)),
               child: FadeTransition(opacity: animation, child: child),
             ),
           );
         },
         transitionDuration: AppAnimations.normalDuration,
       );
}

/// Hero page route for smooth element transitions
class HeroPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final String heroTag;

  HeroPageRoute({required this.child, required this.heroTag, super.settings})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: AppAnimations.bounceCurve,
                ),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: AppAnimations.slowDuration,
      );
}

/// Skeleton loading widget for content placeholders
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        color: Colors.grey[300],
      ),
      child: AppAnimations.shimmer(
        animation: _animation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Staggered animation helper for lists
class StaggeredAnimationHelper {
  static List<Widget> createStaggeredList({
    required List<Widget> children,
    required AnimationController controller,
    Duration staggerDelay = const Duration(milliseconds: 100),
  }) {
    return children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;

      final delay = staggerDelay.inMilliseconds * index;
      final totalDuration = controller.duration!.inMilliseconds;
      final animationStart = delay / totalDuration;
      final animationEnd =
          (delay + AppAnimations.normalDuration.inMilliseconds) / totalDuration;

      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(
            animationStart.clamp(0.0, 1.0),
            animationEnd.clamp(0.0, 1.0),
            curve: AppAnimations.smoothCurve,
          ),
        ),
      );

      return AppAnimations.fadeAndScale(animation: animation, child: child);
    }).toList();
  }
}

/// Button press animation mixin
mixin ButtonPressAnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late AnimationController pressController;
  late Animation<double> pressAnimation;

  @override
  void initState() {
    super.initState();
    pressController = AnimationController(
      duration: AppAnimations.fastDuration,
      vsync: this,
    );
    pressAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    pressController.dispose();
    super.dispose();
  }

  void animatePress() {
    pressController.forward().then((_) {
      pressController.reverse();
    });
  }

  Widget buildPressableWidget(Widget child) {
    return AnimatedBuilder(
      animation: pressAnimation,
      builder: (context, child) {
        return Transform.scale(scale: pressAnimation.value, child: child);
      },
      child: child,
    );
  }
}

enum SlideDirection { rightToLeft, leftToRight, topToBottom, bottomToTop }
