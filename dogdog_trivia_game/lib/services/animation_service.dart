import 'package:flutter/material.dart';
import '../services/accessibility_service.dart';

/// Service for managing enhanced animations and transitions throughout the game
class AnimationService {
  static final AnimationService _instance = AnimationService._internal();
  factory AnimationService() => _instance;
  AnimationService._internal();

  /// Standard animation durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 400);
  static const Duration longDuration = Duration(milliseconds: 600);
  static const Duration extraLongDuration = Duration(milliseconds: 800);

  /// Standard animation curves
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve springCurve = Curves.elasticInOut;
  static const Curve slideInCurve = Curves.easeOutCubic;
  static const Curve slideOutCurve = Curves.easeInCubic;

  /// Get animation duration considering accessibility settings
  Duration getDuration(Duration baseDuration) {
    return AccessibilityService().getAnimationDuration(baseDuration);
  }

  /// Check if animations should be disabled
  bool shouldDisableAnimations() {
    return AccessibilityService().shouldDisableAnimations();
  }

  /// Create a fade transition
  Widget createFadeTransition({
    required Animation<double> animation,
    required Widget child,
    Curve curve = standardCurve,
  }) {
    if (shouldDisableAnimations()) {
      return child;
    }

    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: curve),
      child: child,
    );
  }

  /// Create a slide transition
  Widget createSlideTransition({
    required Animation<double> animation,
    required Widget child,
    Offset begin = const Offset(0, 1),
    Offset end = Offset.zero,
    Curve curve = slideInCurve,
  }) {
    if (shouldDisableAnimations()) {
      return child;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(parent: animation, curve: curve)),
      child: child,
    );
  }

  /// Create a scale transition
  Widget createScaleTransition({
    required Animation<double> animation,
    required Widget child,
    double begin = 0.0,
    double end = 1.0,
    Curve curve = bounceCurve,
  }) {
    if (shouldDisableAnimations()) {
      return child;
    }

    return ScaleTransition(
      scale: Tween<double>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(parent: animation, curve: curve)),
      child: child,
    );
  }

  /// Create a rotation transition
  Widget createRotationTransition({
    required Animation<double> animation,
    required Widget child,
    double begin = 0.0,
    double end = 1.0,
    Curve curve = standardCurve,
  }) {
    if (shouldDisableAnimations()) {
      return child;
    }

    return RotationTransition(
      turns: Tween<double>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(parent: animation, curve: curve)),
      child: child,
    );
  }

  /// Create a progress celebration animation
  Widget createProgressCelebration({
    required Animation<double> animation,
    required Widget child,
  }) {
    if (shouldDisableAnimations()) {
      return child;
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value;
        final scale = 1.0 + (0.2 * progress);
        final rotation = progress * 0.1;

        return Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: rotation,
            child: Opacity(opacity: 1.0 - (progress * 0.3), child: child),
          ),
        );
      },
    );
  }

  /// Create a checkpoint completion animation
  Widget createCheckpointAnimation({
    required Animation<double> animation,
    required Widget child,
  }) {
    if (shouldDisableAnimations()) {
      return child;
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value;

        // Multi-stage animation
        if (progress < 0.3) {
          // Stage 1: Scale up
          final stageProgress = progress / 0.3;
          return Transform.scale(
            scale: 1.0 + (stageProgress * 0.5),
            child: child,
          );
        } else if (progress < 0.7) {
          // Stage 2: Bounce and glow
          final stageProgress = (progress - 0.3) / 0.4;
          final bounce = 1.5 - (stageProgress * 0.5);

          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withValues(alpha: stageProgress * 0.6),
                  blurRadius: 20 * stageProgress,
                  spreadRadius: 5 * stageProgress,
                ),
              ],
            ),
            child: Transform.scale(scale: bounce, child: child),
          );
        } else {
          // Stage 3: Settle to normal with sparkle effect
          final stageProgress = (progress - 0.7) / 0.3;
          final finalScale = 1.5 - (stageProgress * 0.5);

          return Transform.scale(scale: finalScale, child: child);
        }
      },
    );
  }

  /// Create a power-up usage animation
  Widget createPowerUpAnimation({
    required Animation<double> animation,
    required Widget child,
    required Color effectColor,
  }) {
    if (shouldDisableAnimations()) {
      return child;
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value;

        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: effectColor.withValues(alpha: progress * 0.8),
                blurRadius: 30 * progress,
                spreadRadius: 10 * progress,
              ),
            ],
          ),
          child: Transform.scale(
            scale: 1.0 + (progress * 0.3),
            child: Opacity(opacity: 1.0 - (progress * 0.3), child: child),
          ),
        );
      },
    );
  }

  /// Create a streak bonus animation
  Widget createStreakAnimation({
    required Animation<double> animation,
    required Widget child,
    required int streakCount,
  }) {
    if (shouldDisableAnimations()) {
      return child;
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value;
        final intensity = (streakCount / 5.0).clamp(0.0, 1.0);

        // Pulsing effect that gets stronger with higher streaks
        final scale = 1.0 + (0.1 * intensity * progress);
        final glow = progress * intensity;

        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: glow * 0.6),
                blurRadius: 15 * glow,
                spreadRadius: 3 * glow,
              ),
            ],
          ),
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );
  }

  /// Create a timer warning animation
  Widget createTimerWarningAnimation({
    required Animation<double> animation,
    required Widget child,
  }) {
    if (shouldDisableAnimations()) {
      return Container(
        decoration: const BoxDecoration(color: Colors.red),
        child: child,
      );
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value;
        final pulseValue = (progress * 2) % 1.0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1 + (pulseValue * 0.2)),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3 + (pulseValue * 0.4)),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Transform.scale(
            scale: 1.0 + (pulseValue * 0.05),
            child: child,
          ),
        );
      },
    );
  }

  /// Create a milestone achievement animation
  Widget createMilestoneAnimation({
    required Animation<double> animation,
    required Widget child,
  }) {
    if (shouldDisableAnimations()) {
      return child;
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value;

        // Complex celebration animation
        final bounce = Curves.elasticOut.transform(progress);
        final sparkle = (progress * 4) % 1.0;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Sparkle background
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.yellow.withValues(alpha: sparkle * 0.4),
                    Colors.orange.withValues(alpha: sparkle * 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Main content with bounce
            Transform.scale(scale: bounce, child: child),
          ],
        );
      },
    );
  }

  /// Create a page transition
  Widget createPageTransition({
    required Widget child,
    required Animation<double> animation,
    PageTransitionType type = PageTransitionType.slide,
  }) {
    if (shouldDisableAnimations()) {
      return child;
    }

    switch (type) {
      case PageTransitionType.fade:
        return createFadeTransition(animation: animation, child: child);
      case PageTransitionType.slide:
        return createSlideTransition(animation: animation, child: child);
      case PageTransitionType.scale:
        return createScaleTransition(animation: animation, child: child);
      case PageTransitionType.rotation:
        return createRotationTransition(animation: animation, child: child);
    }
  }

  /// Create an animated counter
  Widget createAnimatedCounter({
    required Animation<double> animation,
    required int startValue,
    required int endValue,
    required TextStyle textStyle,
  }) {
    if (shouldDisableAnimations()) {
      return Text('$endValue', style: textStyle);
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value;
        final currentValue =
            startValue + ((endValue - startValue) * progress).round();

        return Text('$currentValue', style: textStyle);
      },
    );
  }
}

/// Types of page transitions available
enum PageTransitionType { fade, slide, scale, rotation }
