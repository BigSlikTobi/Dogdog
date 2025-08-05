import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Utility class for accessibility features and helpers
class AccessibilityUtils {
  /// Check if high contrast mode is enabled
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Check if screen reader is enabled
  static bool isScreenReaderEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Check if user prefers reduced motion
  static bool prefersReducedMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Get text scale factor with reasonable limits
  static double getTextScaleFactor(BuildContext context) {
    final textScaler = MediaQuery.of(context).textScaler;
    final scaleFactor =
        textScaler.scale(16.0) / 16.0; // Get scale factor relative to 16px
    return scaleFactor.clamp(0.8, 2.0);
  }

  /// Create semantic label for buttons with context
  static String createButtonLabel(
    String text, {
    String? hint,
    bool? isEnabled,
  }) {
    final buffer = StringBuffer(text);

    if (hint != null) {
      buffer.write(', $hint');
    }

    if (isEnabled == false) {
      buffer.write(', disabled');
    }

    return buffer.toString();
  }

  /// Create semantic label for game elements
  static String createGameElementLabel({
    required String element,
    required String value,
    String? context,
  }) {
    final buffer = StringBuffer('$element: $value');

    if (context != null) {
      buffer.write(', $context');
    }

    return buffer.toString();
  }

  /// Create semantic label for progress indicators
  static String createProgressLabel({
    required String type,
    required int current,
    required int total,
    String? additionalInfo,
  }) {
    final buffer = StringBuffer('$type: $current of $total');

    if (additionalInfo != null) {
      buffer.write(', $additionalInfo');
    }

    return buffer.toString();
  }

  /// Announce important game events to screen readers
  static void announceToScreenReader(
    BuildContext context,
    String message, {
    Assertiveness assertiveness = Assertiveness.polite,
  }) {
    if (isScreenReaderEnabled(context)) {
      SemanticsService.announce(
        message,
        TextDirection.ltr,
        assertiveness: assertiveness,
      );
    }
  }

  /// Create focus node with proper disposal
  static FocusNode createManagedFocusNode() {
    return FocusNode(debugLabel: 'ManagedFocusNode');
  }

  /// Get high contrast colors
  static ColorScheme getHighContrastColors(BuildContext context) {
    if (isHighContrastEnabled(context)) {
      return const ColorScheme.highContrastLight(
        primary: Colors.black,
        onPrimary: Colors.white,
        secondary: Colors.black,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        error: Colors.red,
        onError: Colors.white,
      );
    }
    return Theme.of(context).colorScheme;
  }

  /// Get accessible text style with proper contrast
  static TextStyle getAccessibleTextStyle(
    BuildContext context,
    TextStyle baseStyle,
  ) {
    final colorScheme = getHighContrastColors(context);
    final textScaleFactor = getTextScaleFactor(context);

    return baseStyle.copyWith(
      color: colorScheme.onSurface,
      fontSize: (baseStyle.fontSize ?? 16) * textScaleFactor,
      fontWeight: isHighContrastEnabled(context)
          ? FontWeight.bold
          : baseStyle.fontWeight,
    );
  }

  /// Create accessible card decoration
  static BoxDecoration getAccessibleCardDecoration(BuildContext context) {
    final colorScheme = getHighContrastColors(context);

    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: isHighContrastEnabled(context)
          ? Border.all(color: colorScheme.onSurface, width: 2)
          : null,
      boxShadow: isHighContrastEnabled(context)
          ? null
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }

  /// Create accessible circular decoration
  static BoxDecoration getAccessibleCircularDecoration(BuildContext context) {
    final colorScheme = getHighContrastColors(context);

    return BoxDecoration(
      color: colorScheme.surface,
      shape: BoxShape.circle,
      border: isHighContrastEnabled(context)
          ? Border.all(color: colorScheme.onSurface, width: 2)
          : null,
      boxShadow: isHighContrastEnabled(context)
          ? null
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }

  /// Create accessible button decoration
  static BoxDecoration getAccessibleButtonDecoration(
    BuildContext context, {
    required Color backgroundColor,
    bool isPressed = false,
  }) {
    final colorScheme = getHighContrastColors(context);

    return BoxDecoration(
      color: isHighContrastEnabled(context)
          ? colorScheme.primary
          : backgroundColor,
      borderRadius: BorderRadius.circular(12),
      border: isHighContrastEnabled(context)
          ? Border.all(color: colorScheme.onPrimary, width: 2)
          : null,
      boxShadow: isHighContrastEnabled(context) || isPressed
          ? null
          : [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }
}

/// Widget that provides accessibility-aware theming
class AccessibilityTheme extends StatelessWidget {
  final Widget child;

  const AccessibilityTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (AccessibilityUtils.isHighContrastEnabled(context)) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: AccessibilityUtils.getHighContrastColors(context),
          textTheme: Theme.of(context).textTheme.apply(
            bodyColor: Colors.black,
            displayColor: Colors.black,
            fontSizeFactor: AccessibilityUtils.getTextScaleFactor(context),
          ),
        ),
        child: child,
      );
    }

    return child;
  }
}

/// Widget that provides semantic information for game elements
class GameElementSemantics extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final String? value;
  final bool? enabled;
  final VoidCallback? onTap;

  const GameElementSemantics({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.value,
    this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      enabled: enabled,
      button: onTap != null,
      onTap: onTap,
      child: child,
    );
  }
}

/// Widget that manages focus for keyboard navigation
class FocusableGameElement extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool autofocus;

  const FocusableGameElement({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.autofocus = false,
  });

  @override
  State<FocusableGameElement> createState() => _FocusableGameElementState();
}

class _FocusableGameElementState extends State<FocusableGameElement> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = AccessibilityUtils.createManagedFocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: (node, event) {
        if (event.logicalKey.keyLabel == 'Enter' ||
            event.logicalKey.keyLabel == 'Space') {
          widget.onTap?.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: _focusNode.hasFocus
              ? BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).focusColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Semantics(
            label: widget.semanticLabel,
            button: widget.onTap != null,
            focusable: true,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
