import 'package:flutter/material.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_spacing.dart';
import '../design_system/modern_shadows.dart';

/// A modern card widget with customizable styling, gradients, and accessibility features.
///
/// This widget provides a consistent card design throughout the app with support for:
/// - Customizable padding, shadows, and border radius
/// - Gradient backgrounds and custom colors
/// - Accessibility features and semantic labels
/// - Interactive states and animations
class ModernCard extends StatefulWidget {
  /// The child widget to display inside the card
  final Widget child;

  /// Custom padding for the card content. Defaults to [ModernSpacing.cardPaddingInsets]
  final EdgeInsetsGeometry? padding;

  /// Custom margin around the card. Defaults to [ModernSpacing.cardMargin]
  final EdgeInsetsGeometry? margin;

  /// Background color for the card. If null and no gradient is provided, uses [ModernColors.cardBackground]
  final Color? backgroundColor;

  /// Gradient colors for the background. Takes precedence over backgroundColor
  final List<Color>? gradientColors;

  /// Gradient begin alignment. Defaults to [Alignment.topLeft]
  final AlignmentGeometry gradientBegin;

  /// Gradient end alignment. Defaults to [Alignment.bottomRight]
  final AlignmentGeometry gradientEnd;

  /// Border radius for the card. Defaults to [ModernSpacing.borderRadiusMedium]
  final BorderRadius? borderRadius;

  /// Shadow elevation for the card. Defaults to [ModernShadows.card]
  final List<BoxShadow>? shadows;

  /// Width of the card. If null, uses available width
  final double? width;

  /// Height of the card. If null, uses intrinsic height
  final double? height;

  /// Whether the card should be interactive (respond to taps)
  final bool interactive;

  /// Callback when the card is tapped (only if interactive is true)
  final VoidCallback? onTap;

  /// Semantic label for accessibility
  final String? semanticLabel;

  /// Whether the card should have a border
  final bool hasBorder;

  /// Border color if hasBorder is true
  final Color? borderColor;

  /// Border width if hasBorder is true
  final double borderWidth;

  /// Creates a modern card widget
  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradientColors,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.borderRadius,
    this.shadows,
    this.width,
    this.height,
    this.interactive = false,
    this.onTap,
    this.semanticLabel,
    this.hasBorder = false,
    this.borderColor,
    this.borderWidth = 1.0,
  });

  /// Creates a card with gradient background
  const ModernCard.gradient({
    super.key,
    required this.child,
    required this.gradientColors,
    this.padding,
    this.margin,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.borderRadius,
    this.shadows,
    this.width,
    this.height,
    this.interactive = false,
    this.onTap,
    this.semanticLabel,
    this.hasBorder = false,
    this.borderColor,
    this.borderWidth = 1.0,
  }) : backgroundColor = null;

  /// Creates an interactive card that responds to taps
  const ModernCard.interactive({
    super.key,
    required this.child,
    required this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradientColors,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.borderRadius,
    this.shadows,
    this.width,
    this.height,
    this.semanticLabel,
    this.hasBorder = false,
    this.borderColor,
    this.borderWidth = 1.0,
  }) : interactive = true;

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.interactive) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.interactive) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.interactive) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectivePadding = widget.padding ?? ModernSpacing.cardPaddingInsets;
    final effectiveMargin =
        widget.margin ?? EdgeInsets.all(ModernSpacing.cardMargin);
    final effectiveBorderRadius =
        widget.borderRadius ?? ModernSpacing.borderRadiusMedium;
    final effectiveShadows =
        widget.shadows ??
        (_isPressed ? ModernShadows.buttonPressed : ModernShadows.card);

    // Determine background decoration
    Decoration decoration;
    if (widget.gradientColors != null && widget.gradientColors!.isNotEmpty) {
      decoration = BoxDecoration(
        gradient: LinearGradient(
          colors: widget.gradientColors!,
          begin: widget.gradientBegin,
          end: widget.gradientEnd,
        ),
        borderRadius: effectiveBorderRadius,
        boxShadow: effectiveShadows,
        border: widget.hasBorder
            ? Border.all(
                color: widget.borderColor ?? ModernColors.surfaceDark,
                width: widget.borderWidth,
              )
            : null,
      );
    } else {
      decoration = BoxDecoration(
        color: widget.backgroundColor ?? ModernColors.cardBackground,
        borderRadius: effectiveBorderRadius,
        boxShadow: effectiveShadows,
        border: widget.hasBorder
            ? Border.all(
                color: widget.borderColor ?? ModernColors.surfaceDark,
                width: widget.borderWidth,
              )
            : null,
      );
    }

    Widget cardWidget = Container(
      width: widget.width,
      height: widget.height,
      margin: effectiveMargin,
      decoration: decoration,
      child: Padding(padding: effectivePadding, child: widget.child),
    );

    // Add semantic label if provided
    if (widget.semanticLabel != null) {
      cardWidget = Semantics(label: widget.semanticLabel, child: cardWidget);
    }

    // Make interactive if needed
    if (widget.interactive && widget.onTap != null) {
      cardWidget = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }
}

/// Extension methods for creating common card variants
extension ModernCardVariants on ModernCard {
  /// Creates a card with difficulty-specific gradient colors
  static ModernCard forDifficulty({
    Key? key,
    required Widget child,
    required String difficulty,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    List<BoxShadow>? shadows,
    double? width,
    double? height,
    bool interactive = false,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    final gradientColors = ModernColors.getGradientForDifficulty(difficulty);

    return ModernCard.gradient(
      key: key,
      child: child,
      gradientColors: gradientColors,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      shadows: shadows,
      width: width,
      height: height,
      interactive: interactive,
      onTap: onTap,
      semanticLabel: semanticLabel,
    );
  }

  /// Creates a card with elevated appearance
  static ModernCard elevated({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    double? width,
    double? height,
    bool interactive = false,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return ModernCard(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      shadows: ModernShadows.large,
      width: width,
      height: height,
      interactive: interactive,
      onTap: onTap,
      semanticLabel: semanticLabel,
    );
  }

  /// Creates a card with subtle appearance
  static ModernCard subtle({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    double? width,
    double? height,
    bool interactive = false,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return ModernCard(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor ?? ModernColors.surfaceLight,
      borderRadius: borderRadius,
      shadows: ModernShadows.subtle,
      width: width,
      height: height,
      interactive: interactive,
      onTap: onTap,
      semanticLabel: semanticLabel,
    );
  }
}
