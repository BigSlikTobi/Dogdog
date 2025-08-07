import 'package:flutter/material.dart';
import '../utils/animations.dart';
import '../services/audio_service.dart';

/// An animated button widget with press effects and hover animations
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? elevation;
  final bool enabled;
  final Duration animationDuration;
  final double pressScale;
  final double hoverScale;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.enabled = true,
    this.animationDuration = AppAnimations.fastDuration,
    this.pressScale = 0.95,
    this.hoverScale = 1.02,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _elevationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _elevationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.pressScale).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _elevationAnimation =
        Tween<double>(
          begin: widget.elevation ?? 4.0,
          end: (widget.elevation ?? 4.0) * 0.5,
        ).animate(
          CurvedAnimation(
            parent: _elevationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _elevationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.enabled) return;

    setState(() {
      _isPressed = true;
    });

    _scaleController.forward();
    _elevationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.enabled) return;

    setState(() {
      _isPressed = false;
    });

    _scaleController.reverse();
    _elevationController.reverse();

    // Play button sound when tap is completed
    AudioService().playButtonSound();
  }

  void _onTapCancel() {
    if (!widget.enabled) return;

    setState(() {
      _isPressed = false;
    });

    _scaleController.reverse();
    _elevationController.reverse();
  }

  void _onHoverEnter(PointerEvent event) {
    if (!widget.enabled) return;

    setState(() {
      _isHovered = true;
    });
  }

  void _onHoverExit(PointerEvent event) {
    if (!widget.enabled) return;

    setState(() {
      _isHovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onHoverEnter,
      onExit: _onHoverExit,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.enabled ? widget.onPressed : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _elevationAnimation]),
          builder: (context, child) {
            double scale = _scaleAnimation.value;

            // Apply hover effect when not pressed
            if (_isHovered && !_isPressed) {
              scale = widget.hoverScale;
            }

            return Transform.scale(
              scale: scale,
              child: AnimatedContainer(
                duration: widget.animationDuration,
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color:
                      widget.backgroundColor ?? Theme.of(context).primaryColor,
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (widget.backgroundColor ??
                                  Theme.of(context).primaryColor)
                              .withValues(alpha: 0.3),
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value * 0.5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius:
                        widget.borderRadius ?? BorderRadius.circular(12),
                    onTap: widget.enabled ? widget.onPressed : null,
                    child: Container(
                      padding:
                          widget.padding ??
                          const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: widget.foregroundColor ?? Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A specialized animated button for primary actions with enhanced animations
class PrimaryAnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isLoading;

  const PrimaryAnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.enabled = true,
    this.isLoading = false,
  });

  @override
  State<PrimaryAnimatedButton> createState() => _PrimaryAnimatedButtonState();
}

class _PrimaryAnimatedButtonState extends State<PrimaryAnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _loadingController;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    if (widget.isLoading) {
      _loadingController.repeat();
    }
  }

  @override
  void didUpdateWidget(PrimaryAnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
      }
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.enabled && !widget.isLoading) {
      _rippleController.forward().then((_) {
        _rippleController.reset();
      });
      widget.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: _handleTap,
      enabled: widget.enabled && !widget.isLoading,
      backgroundColor: const Color(0xFF4A90E2), // Primary Blue
      foregroundColor: Colors.white,
      elevation: 6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple effect
          AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return Container(
                width: 100 * _rippleAnimation.value,
                height: 100 * _rippleAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(
                    alpha: 0.3 * (1 - _rippleAnimation.value),
                  ),
                ),
              );
            },
          ),
          // Button content
          widget.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                )
              : widget.child,
        ],
      ),
    );
  }
}

/// A specialized animated button for secondary actions
class SecondaryAnimatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool enabled;

  const SecondaryAnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onPressed,
      enabled: enabled,
      backgroundColor: const Color(0xFF8B5CF6), // Secondary Purple
      foregroundColor: Colors.white,
      elevation: 4,
      child: child,
    );
  }
}

/// A specialized animated button for outline style
class OutlineAnimatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final bool enabled;

  const OutlineAnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.borderColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = borderColor ?? const Color(0xFF8B5CF6);

    return AnimatedButton(
      onPressed: onPressed,
      enabled: enabled,
      backgroundColor: Colors.white,
      foregroundColor: color,
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}
