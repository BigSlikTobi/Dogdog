import 'package:flutter/material.dart';
import 'dart:async';

/// A widget that displays success animations by alternating between success images.
///
/// This widget provides animated feedback for correct answers with support for:
/// - Alternating between success1.png and success2.png images
/// - Scale animations and proper timing controls
/// - Completion callbacks and animation state management
/// - Responsive scaling for different screen sizes
class SuccessAnimationWidget extends StatefulWidget {
  /// Duration for each image display
  final Duration imageDuration;

  /// Duration for the scale animation
  final Duration animationDuration;

  /// Number of times to alternate between images
  final int alternationCount;

  /// Scale factor for the animation
  final double scaleFactor;

  /// Width of the animation widget
  final double? width;

  /// Height of the animation widget
  final double? height;

  /// Callback when the animation completes
  final VoidCallback? onAnimationComplete;

  /// Callback when the widget is fully dismissed and should be removed
  final VoidCallback? onDismissComplete;

  /// Whether to start the animation automatically
  final bool autoStart;

  /// Semantic label for accessibility
  final String? semanticLabel;

  /// Custom curve for the scale animation
  final Curve animationCurve;

  /// Whether to loop the animation continuously
  final bool loop;

  /// Duration to wait before auto-dismissing the widget
  final Duration autoDismissDelay;

  /// Whether to automatically dismiss the widget after animation
  final bool autoDismiss;

  /// Whether to move the widget to bottom during dismissal
  final bool moveToBottom;

  /// Duration for the dismissal animation
  final Duration dismissAnimationDuration;

  /// Creates a success animation widget
  const SuccessAnimationWidget({
    super.key,
    this.imageDuration = const Duration(milliseconds: 300),
    this.animationDuration = const Duration(milliseconds: 200),
    this.alternationCount = 3,
    this.scaleFactor = 1.2,
    this.width,
    this.height,
    this.onAnimationComplete,
    this.onDismissComplete,
    this.autoStart = true,
    this.semanticLabel,
    this.animationCurve = Curves.elasticOut,
    this.loop = false,
    this.autoDismissDelay = const Duration(seconds: 1),
    this.autoDismiss = true,
    this.moveToBottom = true,
    this.dismissAnimationDuration = const Duration(milliseconds: 500),
  });

  /// Creates a quick success animation
  const SuccessAnimationWidget.quick({
    super.key,
    this.width,
    this.height,
    this.onAnimationComplete,
    this.onDismissComplete,
    this.autoStart = true,
    this.semanticLabel,
    this.loop = false,
    this.autoDismissDelay = const Duration(seconds: 1),
    this.autoDismiss = true,
    this.moveToBottom = true,
    this.dismissAnimationDuration = const Duration(milliseconds: 500),
  }) : imageDuration = const Duration(milliseconds: 200),
       animationDuration = const Duration(milliseconds: 150),
       alternationCount = 2,
       scaleFactor = 1.1,
       animationCurve = Curves.easeOut;

  /// Creates a celebration success animation
  const SuccessAnimationWidget.celebration({
    super.key,
    this.width,
    this.height,
    this.onAnimationComplete,
    this.onDismissComplete,
    this.autoStart = true,
    this.semanticLabel,
    this.loop = false,
    this.autoDismissDelay = const Duration(seconds: 1),
    this.autoDismiss = true,
    this.moveToBottom = true,
    this.dismissAnimationDuration = const Duration(milliseconds: 500),
  }) : imageDuration = const Duration(milliseconds: 400),
       animationDuration = const Duration(milliseconds: 300),
       alternationCount = 5,
       scaleFactor = 1.3,
       animationCurve = Curves.bounceOut;

  @override
  State<SuccessAnimationWidget> createState() => _SuccessAnimationWidgetState();
}

class _SuccessAnimationWidgetState extends State<SuccessAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _dismissController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _positionAnimation;

  Timer? _imageTimer;
  Timer? _dismissTimer;
  bool _showFirstImage = true;
  int _currentAlternation = 0;
  bool _isAnimating = false;
  bool _isDismissing = false;
  bool _isCompletelyDismissed = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor)
        .animate(
          CurvedAnimation(
            parent: _scaleController,
            curve: widget.animationCurve,
          ),
        );

    _dismissController = AnimationController(
      duration: widget.dismissAnimationDuration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _dismissController, curve: Curves.easeOut),
    );

    _positionAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, 1.0), // Move to bottom
        ).animate(
          CurvedAnimation(parent: _dismissController, curve: Curves.easeInOut),
        );

    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startAnimation();
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _imageTimer?.cancel();
    _dismissTimer?.cancel();
    _scaleController.dispose();
    _dismissController.dispose();
    super.dispose();
  }

  /// Starts the success animation
  void startAnimation() {
    if (_isDisposed || _isAnimating) return;

    setState(() {
      _isAnimating = true;
      _currentAlternation = 0;
      _showFirstImage = true;
    });

    _startImageAlternation();
  }

  /// Stops the animation
  void stopAnimation() {
    if (_isDisposed) return;

    _imageTimer?.cancel();
    _dismissTimer?.cancel();
    _scaleController.reset();
    _dismissController.reset();

    if (mounted) {
      setState(() {
        _isAnimating = false;
        _isDismissing = false;
        _isCompletelyDismissed = false;
        _currentAlternation = 0;
        _showFirstImage = true;
      });
    }
  }

  void _startImageAlternation() {
    if (_isDisposed || !_isAnimating) return;

    // Start scale animation
    _scaleController.forward().then((_) {
      if (_isDisposed || !_isAnimating) return;
      _scaleController.reverse();
    });

    // Schedule image alternation
    _imageTimer = Timer(widget.imageDuration, () {
      if (_isDisposed || !_isAnimating) return;

      if (mounted) {
        setState(() {
          _showFirstImage = !_showFirstImage;
          _currentAlternation++;
        });
      }

      if (_currentAlternation < widget.alternationCount * 2) {
        _startImageAlternation();
      } else {
        _completeAnimation();
      }
    });
  }

  void _completeAnimation() {
    if (_isDisposed) return;

    if (widget.loop) {
      // Restart the animation after a brief pause
      Timer(const Duration(milliseconds: 500), () {
        if (!_isDisposed && mounted) {
          startAnimation();
        }
      });
    } else {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }

      widget.onAnimationComplete?.call();

      // Start auto-dismiss if enabled
      if (widget.autoDismiss) {
        _startAutoDismiss();
      }
    }
  }

  void _startAutoDismiss() {
    if (_isDisposed || _isDismissing) return;

    _dismissTimer = Timer(widget.autoDismissDelay, () {
      if (_isDisposed || !mounted) return;

      setState(() {
        _isDismissing = true;
      });

      _dismissController.forward().then((_) {
        // Animation is now completely finished and invisible
        if (mounted) {
          setState(() {
            _isCompletelyDismissed = true;
          });

          // Call the dismiss complete callback to let parent remove the overlay
          widget.onDismissComplete?.call();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Return empty widget if completely dismissed
    if (_isCompletelyDismissed) {
      return const SizedBox.shrink();
    }

    Widget animationWidget = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isAnimating ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: _buildImageWidget(),
    );

    // Add semantic label if provided
    if (widget.semanticLabel != null) {
      animationWidget = Semantics(
        label: widget.semanticLabel,
        child: animationWidget,
      );
    }

    // Wrap with dismiss animations if dismissing
    if (_isDismissing) {
      animationWidget = AnimatedBuilder(
        animation: Listenable.merge([_opacityAnimation, _positionAnimation]),
        builder: (context, child) {
          Widget result = Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          );

          if (widget.moveToBottom) {
            result = SlideTransition(
              position: _positionAnimation,
              child: result,
            );
          }

          return result;
        },
        child: animationWidget,
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Center(child: animationWidget),
    );
  }

  Widget _buildImageWidget() {
    final imagePath = _showFirstImage
        ? 'assets/images/success1.png'
        : 'assets/images/success2.png';

    return Image.asset(
      imagePath,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to a simple success icon if images are not found
        return Icon(
          Icons.check_circle,
          size: widget.width ?? widget.height ?? 100,
          color: Colors.green,
        );
      },
    );
  }
}

/// Controller for managing success animation state
class SuccessAnimationController {
  final GlobalKey<_SuccessAnimationWidgetState> _key = GlobalKey();

  /// Gets the widget key for the animation
  GlobalKey<_SuccessAnimationWidgetState> get key => _key;

  /// Starts the animation
  void start() {
    _key.currentState?.startAnimation();
  }

  /// Stops the animation
  void stop() {
    _key.currentState?.stopAnimation();
  }

  /// Whether the animation is currently running
  bool get isAnimating => _key.currentState?._isAnimating ?? false;
}

/// Extension methods for creating common animation variants
extension SuccessAnimationVariants on SuccessAnimationWidget {
  /// Creates a success animation for correct answers
  static SuccessAnimationWidget correctAnswer({
    Key? key,
    double? width,
    double? height,
    VoidCallback? onAnimationComplete,
    VoidCallback? onDismissComplete,
    bool autoStart = true,
    String? semanticLabel,
  }) {
    return SuccessAnimationWidget(
      key: key,
      imageDuration: const Duration(milliseconds: 250),
      animationDuration: const Duration(milliseconds: 180),
      alternationCount: 3,
      scaleFactor: 1.15,
      width: width,
      height: height,
      onAnimationComplete: onAnimationComplete,
      onDismissComplete: onDismissComplete,
      autoStart: autoStart,
      semanticLabel: semanticLabel ?? 'Correct answer celebration',
      animationCurve: Curves.easeOutBack,
    );
  }

  /// Creates a success animation for level completion
  static SuccessAnimationWidget levelComplete({
    Key? key,
    double? width,
    double? height,
    VoidCallback? onAnimationComplete,
    VoidCallback? onDismissComplete,
    bool autoStart = true,
    String? semanticLabel,
  }) {
    return SuccessAnimationWidget.celebration(
      key: key,
      width: width,
      height: height,
      onAnimationComplete: onAnimationComplete,
      onDismissComplete: onDismissComplete,
      autoStart: autoStart,
      semanticLabel: semanticLabel ?? 'Level completed celebration',
    );
  }

  /// Creates a success animation for achievements
  static SuccessAnimationWidget achievement({
    Key? key,
    double? width,
    double? height,
    VoidCallback? onAnimationComplete,
    VoidCallback? onDismissComplete,
    bool autoStart = true,
    String? semanticLabel,
  }) {
    return SuccessAnimationWidget(
      key: key,
      imageDuration: const Duration(milliseconds: 350),
      animationDuration: const Duration(milliseconds: 250),
      alternationCount: 4,
      scaleFactor: 1.25,
      width: width,
      height: height,
      onAnimationComplete: onAnimationComplete,
      onDismissComplete: onDismissComplete,
      autoStart: autoStart,
      semanticLabel: semanticLabel ?? 'Achievement unlocked celebration',
      animationCurve: Curves.elasticOut,
    );
  }

  /// Creates a subtle success animation for minor victories
  static SuccessAnimationWidget subtle({
    Key? key,
    double? width,
    double? height,
    VoidCallback? onAnimationComplete,
    VoidCallback? onDismissComplete,
    bool autoStart = true,
    String? semanticLabel,
  }) {
    return SuccessAnimationWidget(
      key: key,
      imageDuration: const Duration(milliseconds: 200),
      animationDuration: const Duration(milliseconds: 150),
      alternationCount: 2,
      scaleFactor: 1.05,
      width: width,
      height: height,
      onAnimationComplete: onAnimationComplete,
      onDismissComplete: onDismissComplete,
      autoStart: autoStart,
      semanticLabel: semanticLabel ?? 'Success',
      animationCurve: Curves.easeOut,
    );
  }
}
