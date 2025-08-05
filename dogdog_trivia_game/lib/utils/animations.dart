import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Utility class for common animations used throughout the app
class AppAnimations {
  // Animation durations
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration extraSlowDuration = Duration(milliseconds: 800);

  // Animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;

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

           return SlideTransition(
             position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
               CurvedAnimation(
                 parent: animation,
                 curve: AppAnimations.smoothCurve,
               ),
             ),
             child: child,
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
          return ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: AppAnimations.bounceCurve,
              ),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: AppAnimations.slowDuration,
      );
}

enum SlideDirection { rightToLeft, leftToRight, topToBottom, bottomToTop }
