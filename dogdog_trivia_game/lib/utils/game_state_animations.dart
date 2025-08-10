import 'package:flutter/material.dart';

/// Provides smooth animations and transitions for game state changes
class GameStateAnimations {
  /// Creates a page route transition with smooth animation
  static Route<T> createSlideTransition<T>({
    required Widget child,
    Offset? begin,
    Duration? duration,
    Curve? curve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration ?? const Duration(milliseconds: 300),
      reverseTransitionDuration: duration ?? const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideBegin = begin ?? const Offset(1.0, 0.0);
        final slideTween = Tween(
          begin: slideBegin,
          end: Offset.zero,
        ).chain(CurveTween(curve: curve ?? Curves.easeOutCubic));

        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        );

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }

  /// Creates a scale transition for game components
  static Route<T> createScaleTransition<T>({
    required Widget child,
    double? begin,
    Duration? duration,
    Curve? curve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration ?? const Duration(milliseconds: 400),
      reverseTransitionDuration: duration ?? const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleBegin = begin ?? 0.0;
        final scaleTween = Tween(
          begin: scaleBegin,
          end: 1.0,
        ).chain(CurveTween(curve: curve ?? Curves.elasticOut));

        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }

  /// Creates a fade transition for seamless screen changes
  static Route<T> createFadeTransition<T>({
    required Widget child,
    Duration? duration,
    Curve? curve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration ?? const Duration(milliseconds: 250),
      reverseTransitionDuration: duration ?? const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: curve ?? Curves.easeInOut),
        );

        return FadeTransition(opacity: fadeAnimation, child: child);
      },
    );
  }

  /// Creates a hero transition for smooth component integration
  static Widget createHeroTransition({
    required String heroTag,
    required Widget child,
    Duration? duration,
  }) {
    return Hero(
      tag: heroTag,
      transitionOnUserGestures: true,
      flightShuttleBuilder:
          (context, animation, direction, fromContext, toContext) {
            final hero = direction == HeroFlightDirection.push
                ? toContext.widget
                : fromContext.widget;
            return ScaleTransition(
              scale: animation.drive(
                Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).chain(CurveTween(curve: Curves.fastOutSlowIn)),
              ),
              child: hero,
            );
          },
      child: child,
    );
  }

  /// Animates game state changes with smooth transitions
  static Widget buildGameStateTransition({
    required Widget child,
    required bool isVisible,
    required AnimationController controller,
    Offset? slideOffset,
    double? scaleBegin,
    Duration? delay,
  }) {
    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: delay != null
          ? Interval(
              delay.inMilliseconds / controller.duration!.inMilliseconds,
              1.0,
              curve: Curves.easeOutCubic,
            )
          : Curves.easeOutCubic,
    );

    final Animation<Offset> slideAnimation = slideOffset != null
        ? Tween<Offset>(begin: slideOffset, end: Offset.zero).animate(animation)
        : Tween<Offset>(
            begin: Offset.zero,
            end: Offset.zero,
          ).animate(animation);

    final Animation<double> scaleAnimation = scaleBegin != null
        ? Tween<double>(begin: scaleBegin, end: 1.0).animate(animation)
        : Tween<double>(begin: 1.0, end: 1.0).animate(animation);

    final Animation<double> fadeAnimation = Tween<double>(
      begin: 0.0,
      end: isVisible ? 1.0 : 0.0,
    ).animate(animation);

    if (slideOffset != null && scaleBegin != null) {
      return SlideTransition(
        position: slideAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        ),
      );
    } else if (slideOffset != null) {
      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(opacity: fadeAnimation, child: child),
      );
    } else if (scaleBegin != null) {
      return ScaleTransition(
        scale: scaleAnimation,
        child: FadeTransition(opacity: fadeAnimation, child: child),
      );
    } else {
      return FadeTransition(opacity: fadeAnimation, child: child);
    }
  }

  /// Creates a staggered animation for multiple elements
  static List<Widget> buildStaggeredAnimations({
    required List<Widget> children,
    required AnimationController controller,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Offset? slideOffset,
    double? scaleBegin,
  }) {
    return children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;
      final delay = Duration(milliseconds: staggerDelay.inMilliseconds * index);

      return buildGameStateTransition(
        child: child,
        isVisible: true,
        controller: controller,
        slideOffset: slideOffset,
        scaleBegin: scaleBegin,
        delay: delay,
      );
    }).toList();
  }

  /// Creates a bouncing animation for interactive elements
  static Widget buildBouncingButton({
    required Widget child,
    required VoidCallback onPressed,
    Duration? duration,
  }) {
    return _BouncingButton(
      onPressed: onPressed,
      duration: duration ?? const Duration(milliseconds: 150),
      child: child,
    );
  }

  /// Creates a pulsing animation for attention-grabbing elements
  static Widget buildPulsingWidget({
    required Widget child,
    Duration? duration,
    double? minOpacity,
    double? maxOpacity,
  }) {
    return _PulsingWidget(
      duration: duration ?? const Duration(milliseconds: 1500),
      minOpacity: minOpacity ?? 0.5,
      maxOpacity: maxOpacity ?? 1.0,
      child: child,
    );
  }

  /// Creates a shimmer effect for loading states
  static Widget buildShimmerEffect({
    required Widget child,
    Duration? duration,
    List<Color>? colors,
  }) {
    return _ShimmerEffect(
      duration: duration ?? const Duration(milliseconds: 1500),
      colors:
          colors ?? [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
      child: child,
    );
  }
}

/// Internal bouncing button implementation
class _BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Duration duration;

  const _BouncingButton({
    required this.child,
    required this.onPressed,
    required this.duration,
  });

  @override
  State<_BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<_BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Internal pulsing widget implementation
class _PulsingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minOpacity;
  final double maxOpacity;

  const _PulsingWidget({
    required this.child,
    required this.duration,
    required this.minOpacity,
    required this.maxOpacity,
  });

  @override
  State<_PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<_PulsingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _opacityAnimation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(opacity: _opacityAnimation.value, child: widget.child);
      },
    );
  }
}

/// Internal shimmer effect implementation
class _ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final List<Color> colors;

  const _ShimmerEffect({
    required this.child,
    required this.duration,
    required this.colors,
  });

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: widget.colors,
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 - 2 * _animation.value, 0.0),
              end: Alignment(1.0 - 2 * _animation.value, 0.0),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
