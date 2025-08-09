import 'package:flutter/material.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_spacing.dart';
import '../design_system/modern_shadows.dart';
import '../design_system/modern_typography.dart';
import '../utils/accessibility.dart';
import '../utils/responsive.dart';

/// A modern gradient button widget with animations and accessibility features.
///
/// This widget provides a consistent button design throughout the app with support for:
/// - Customizable gradient colors and styling
/// - Press animations and visual feedback states
/// - Accessibility support and proper focus management
/// - Different button sizes and styles
class GradientButton extends StatefulWidget {
  /// The text to display on the button
  final String text;

  /// Callback when the button is pressed
  final VoidCallback? onPressed;

  /// Gradient colors for the button background
  final List<Color> gradientColors;

  /// Gradient begin alignment. Defaults to [Alignment.topLeft]
  final AlignmentGeometry gradientBegin;

  /// Gradient end alignment. Defaults to [Alignment.bottomRight]
  final AlignmentGeometry gradientEnd;

  /// Text style for the button text. Defaults to [ModernTypography.buttonMedium]
  final TextStyle? textStyle;

  /// Padding inside the button. Defaults to [ModernSpacing.buttonPaddingInsets]
  final EdgeInsetsGeometry? padding;

  /// Margin around the button
  final EdgeInsetsGeometry? margin;

  /// Border radius for the button. Defaults to [ModernSpacing.borderRadiusMedium]
  final BorderRadius? borderRadius;

  /// Shadow elevation for the button. Defaults to [ModernShadows.button]
  final List<BoxShadow>? shadows;

  /// Width of the button. If null, uses intrinsic width
  final double? width;

  /// Height of the button. If null, uses intrinsic height
  final double? height;

  /// Whether the button should expand to fill available width
  final bool expandWidth;

  /// Icon to display before the text
  final IconData? icon;

  /// Size of the icon
  final double iconSize;

  /// Space between icon and text
  final double iconSpacing;

  /// Semantic label for accessibility
  final String? semanticLabel;

  /// Whether the button is loading
  final bool isLoading;

  /// Color of the loading indicator
  final Color? loadingColor;

  /// Creates a gradient button widget
  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.gradientColors,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.textStyle,
    this.padding,
    this.margin,
    this.borderRadius,
    this.shadows,
    this.width,
    this.height,
    this.expandWidth = false,
    this.icon,
    this.iconSize = 20.0,
    this.iconSpacing = 8.0,
    this.semanticLabel,
    this.isLoading = false,
    this.loadingColor,
  });

  /// Creates a primary gradient button with default purple gradient
  const GradientButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.textStyle,
    this.padding,
    this.margin,
    this.borderRadius,
    this.shadows,
    this.width,
    this.height,
    this.expandWidth = false,
    this.icon,
    this.iconSize = 20.0,
    this.iconSpacing = 8.0,
    this.semanticLabel,
    this.isLoading = false,
    this.loadingColor,
  }) : gradientColors = ModernColors.purpleGradient,
       gradientBegin = Alignment.topLeft,
       gradientEnd = Alignment.bottomRight;

  /// Creates a large gradient button
  const GradientButton.large({
    super.key,
    required this.text,
    required this.onPressed,
    required this.gradientColors,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.margin,
    this.borderRadius,
    this.shadows,
    this.width,
    this.height,
    this.expandWidth = false,
    this.icon,
    this.iconSpacing = 8.0,
    this.semanticLabel,
    this.isLoading = false,
    this.loadingColor,
  }) : textStyle = ModernTypography.buttonLarge,
       padding = const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
       iconSize = 24.0;

  /// Creates a small gradient button
  const GradientButton.small({
    super.key,
    required this.text,
    required this.onPressed,
    required this.gradientColors,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.margin,
    this.borderRadius,
    this.shadows,
    this.width,
    this.height,
    this.expandWidth = false,
    this.icon,
    this.iconSpacing = 6.0,
    this.semanticLabel,
    this.isLoading = false,
    this.loadingColor,
  }) : textStyle = ModernTypography.buttonSmall,
       padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
       iconSize = 16.0;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
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

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use responsive and accessible spacing
    final effectivePadding =
        widget.padding ??
        EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
          vertical: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
        );
    final effectiveMargin = widget.margin ?? EdgeInsets.zero;
    final effectiveBorderRadius =
        widget.borderRadius ?? ModernSpacing.borderRadiusMedium;

    // Use accessible text style
    final baseTextStyle = widget.textStyle ?? ModernTypography.buttonMedium;
    final effectiveTextStyle = ResponsiveUtils.getAccessibleTextStyle(
      context,
      baseTextStyle,
    );

    // Adjust shadows for high contrast mode
    final effectiveShadows = AccessibilityUtils.isHighContrastEnabled(context)
        ? ModernShadows.none
        : (widget.shadows ??
              (_isPressed
                  ? ModernShadows.buttonPressed
                  : ModernShadows.button));

    final isEnabled = widget.onPressed != null && !widget.isLoading;

    // Respect reduced motion preferences
    final animationDuration = ResponsiveUtils.getAccessibleAnimationDuration(
      context,
      const Duration(milliseconds: 150),
    );
    _animationController.duration = animationDuration;

    // Ensure minimum touch target size
    final minTouchSize = AccessibilityUtils.getMinimumTouchTargetSize();
    final buttonHeight = widget.height; // Remove fixed height constraint

    Widget buttonContent;

    if (widget.isLoading) {
      buttonContent = SizedBox(
        width: 20.0,
        height: 20.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.loadingColor ?? ModernColors.textOnDark,
          ),
        ),
      );
    } else if (widget.icon != null) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            size: widget.iconSize,
            color: effectiveTextStyle.color,
          ),
          SizedBox(width: widget.iconSpacing),
          Flexible(
            child: Text(
              widget.text,
              style: effectiveTextStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    } else {
      buttonContent = Text(
        widget.text,
        style: effectiveTextStyle,
        textAlign: TextAlign.center,
      );
    }

    Widget button = AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _opacityAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: isEnabled ? _opacityAnimation.value : 0.6,
            child: Container(
              width: widget.expandWidth ? double.infinity : widget.width,
              height: buttonHeight,
              constraints: BoxConstraints(
                minHeight: minTouchSize.height, // Ensure minimum touch target
              ),
              margin: effectiveMargin,
              decoration: BoxDecoration(
                gradient: widget.gradientColors.length >= 2
                    ? LinearGradient(
                        colors: widget.gradientColors,
                        begin: widget.gradientBegin,
                        end: widget.gradientEnd,
                      )
                    : null,
                color: widget.gradientColors.length < 2
                    ? (widget.gradientColors.isNotEmpty
                          ? widget.gradientColors.first
                          : ModernColors.primaryPurple)
                    : null,
                borderRadius: effectiveBorderRadius,
                boxShadow: isEnabled ? effectiveShadows : ModernShadows.none,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? widget.onPressed : null,
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  borderRadius: effectiveBorderRadius,
                  child: Container(
                    padding: effectivePadding,
                    child: Center(child: buttonContent),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    // Add semantic label if provided
    if (widget.semanticLabel != null) {
      button = Semantics(
        label: widget.semanticLabel,
        button: true,
        enabled: isEnabled,
        child: button,
      );
    } else {
      button = Semantics(
        label: widget.text,
        button: true,
        enabled: isEnabled,
        child: button,
      );
    }

    return button;
  }
}

/// Extension methods for creating common button variants
extension GradientButtonVariants on GradientButton {
  /// Creates a button with difficulty-specific gradient colors
  static GradientButton forDifficulty({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    required String difficulty,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    List<BoxShadow>? shadows,
    double? width,
    double? height,
    bool expandWidth = false,
    IconData? icon,
    double iconSize = 20.0,
    double iconSpacing = 8.0,
    String? semanticLabel,
    bool isLoading = false,
    Color? loadingColor,
  }) {
    final gradientColors = ModernColors.getGradientForDifficulty(difficulty);

    return GradientButton(
      key: key,
      text: text,
      onPressed: onPressed,
      gradientColors: gradientColors,
      textStyle: textStyle,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      shadows: shadows,
      width: width,
      height: height,
      expandWidth: expandWidth,
      icon: icon,
      iconSize: iconSize,
      iconSpacing: iconSpacing,
      semanticLabel: semanticLabel,
      isLoading: isLoading,
      loadingColor: loadingColor,
    );
  }

  /// Creates a success button with green gradient
  static GradientButton success({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    List<BoxShadow>? shadows,
    double? width,
    double? height,
    bool expandWidth = false,
    IconData? icon,
    double iconSize = 20.0,
    double iconSpacing = 8.0,
    String? semanticLabel,
    bool isLoading = false,
    Color? loadingColor,
  }) {
    return GradientButton(
      key: key,
      text: text,
      onPressed: onPressed,
      gradientColors: ModernColors.greenGradient,
      textStyle: textStyle,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      shadows: shadows,
      width: width,
      height: height,
      expandWidth: expandWidth,
      icon: icon,
      iconSize: iconSize,
      iconSpacing: iconSpacing,
      semanticLabel: semanticLabel,
      isLoading: isLoading,
      loadingColor: loadingColor,
    );
  }

  /// Creates a warning button with yellow gradient
  static GradientButton warning({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    List<BoxShadow>? shadows,
    double? width,
    double? height,
    bool expandWidth = false,
    IconData? icon,
    double iconSize = 20.0,
    double iconSpacing = 8.0,
    String? semanticLabel,
    bool isLoading = false,
    Color? loadingColor,
  }) {
    return GradientButton(
      key: key,
      text: text,
      onPressed: onPressed,
      gradientColors: ModernColors.yellowGradient,
      textStyle: textStyle,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      shadows: shadows,
      width: width,
      height: height,
      expandWidth: expandWidth,
      icon: icon,
      iconSize: iconSize,
      iconSpacing: iconSpacing,
      semanticLabel: semanticLabel,
      isLoading: isLoading,
      loadingColor: loadingColor,
    );
  }

  /// Creates a danger button with red gradient
  static GradientButton danger({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    List<BoxShadow>? shadows,
    double? width,
    double? height,
    bool expandWidth = false,
    IconData? icon,
    double iconSize = 20.0,
    double iconSpacing = 8.0,
    String? semanticLabel,
    bool isLoading = false,
    Color? loadingColor,
  }) {
    return GradientButton(
      key: key,
      text: text,
      onPressed: onPressed,
      gradientColors: ModernColors.redGradient,
      textStyle: textStyle,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      shadows: shadows,
      width: width,
      height: height,
      expandWidth: expandWidth,
      icon: icon,
      iconSize: iconSize,
      iconSpacing: iconSpacing,
      semanticLabel: semanticLabel,
      isLoading: isLoading,
      loadingColor: loadingColor,
    );
  }
}
