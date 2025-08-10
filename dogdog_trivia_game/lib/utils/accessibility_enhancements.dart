import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';

/// Enhanced accessibility features for screen readers and high contrast support
class AccessibilityEnhancements {
  /// Provides semantic descriptions for game elements
  static String getGameElementDescription({
    required String elementType,
    required String? state,
    required String? value,
    String? hint,
  }) {
    final buffer = StringBuffer();
    buffer.write(elementType);

    if (state != null) {
      buffer.write(', $state');
    }

    if (value != null) {
      buffer.write(', $value');
    }

    if (hint != null) {
      buffer.write('. $hint');
    }

    return buffer.toString();
  }

  /// Creates accessible button with proper semantics
  static Widget buildAccessibleButton({
    required Widget child,
    required VoidCallback onPressed,
    required String semanticLabel,
    String? hint,
    bool enabled = true,
    bool selected = false,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: true,
      enabled: enabled,
      selected: selected,
      onTap: enabled ? onPressed : null,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }

  /// Creates accessible image with proper description
  static Widget buildAccessibleImage({
    required Widget image,
    required String semanticLabel,
    String? description,
    bool isDecorative = false,
  }) {
    if (isDecorative) {
      return ExcludeSemantics(child: image);
    }

    return Semantics(label: semanticLabel, image: true, child: image);
  }

  /// Creates accessible game score display
  static Widget buildAccessibleScore({
    required Widget child,
    required int score,
    required String scoreType,
    String? additionalInfo,
  }) {
    final semanticValue =
        'Current $scoreType: $score${additionalInfo != null ? ', $additionalInfo' : ''}';

    return Semantics(
      label: semanticValue,
      value: score.toString(),
      liveRegion: true,
      child: child,
    );
  }

  /// Creates accessible timer display
  static Widget buildAccessibleTimer({
    required Widget child,
    required int seconds,
    bool isUrgent = false,
  }) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final timeLabel = minutes > 0
        ? '$minutes minutes and $remainingSeconds seconds remaining'
        : '$remainingSeconds seconds remaining';

    return Semantics(
      label: timeLabel,
      value: seconds.toString(),
      liveRegion: true,
      child: child,
    );
  }

  /// Creates accessible game progress indicator
  static Widget buildAccessibleProgress({
    required Widget child,
    required double progress,
    required String progressType,
    String? description,
  }) {
    final percentage = (progress * 100).round();
    final semanticValue =
        '$progressType: $percentage percent complete${description != null ? ', $description' : ''}';

    return Semantics(label: semanticValue, value: '$percentage%', child: child);
  }

  /// Provides haptic feedback for game events
  static void provideHapticFeedback(GameHapticType type) {
    switch (type) {
      case GameHapticType.correct:
        HapticFeedback.lightImpact();
        break;
      case GameHapticType.incorrect:
        HapticFeedback.mediumImpact();
        break;
      case GameHapticType.gameOver:
        HapticFeedback.heavyImpact();
        break;
      case GameHapticType.powerUp:
        HapticFeedback.selectionClick();
        break;
      case GameHapticType.button:
        HapticFeedback.selectionClick();
        break;
    }
  }

  /// Announces important game events to screen readers
  static void announceToScreenReader(
    BuildContext context,
    String message, {
    bool isPolite = true,
  }) {
    // Use SemanticsService to announce messages
    SemanticsService.announce(
      message,
      isPolite ? TextDirection.ltr : TextDirection.rtl,
    );
  }

  /// Creates high contrast aware container
  static Widget buildHighContrastContainer({
    required Widget child,
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 2.0,
    BorderRadius? borderRadius,
  }) {
    return Builder(
      builder: (context) {
        final isHighContrast = MediaQuery.of(context).highContrast;

        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: isHighContrast
                ? Border.all(
                    color: borderColor ?? Theme.of(context).dividerColor,
                    width: borderWidth,
                  )
                : null,
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          child: child,
        );
      },
    );
  }

  /// Creates high contrast aware text
  static Widget buildHighContrastText({
    required String text,
    TextStyle? style,
    Color? highContrastColor,
    double? highContrastFontWeight,
  }) {
    return Builder(
      builder: (context) {
        final isHighContrast = MediaQuery.of(context).highContrast;
        final theme = Theme.of(context);

        TextStyle effectiveStyle = style ?? theme.textTheme.bodyMedium!;

        if (isHighContrast) {
          effectiveStyle = effectiveStyle.copyWith(
            color: highContrastColor ?? theme.colorScheme.onSurface,
            fontWeight: highContrastFontWeight != null
                ? FontWeight.values[(highContrastFontWeight * 8).round().clamp(
                    0,
                    8,
                  )]
                : FontWeight.bold,
          );
        }

        return Text(text, style: effectiveStyle);
      },
    );
  }

  /// Creates accessible card for game elements
  static Widget buildAccessibleCard({
    required Widget child,
    required String semanticLabel,
    String? hint,
    VoidCallback? onTap,
    bool isSelected = false,
    Color? backgroundColor,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: onTap != null,
      selected: isSelected,
      child: buildHighContrastContainer(
        backgroundColor: backgroundColor,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }

  /// Creates accessible list with proper navigation
  static Widget buildAccessibleList({
    required List<Widget> children,
    required String listDescription,
    ScrollController? controller,
  }) {
    return Semantics(
      label: listDescription,
      child: ListView.builder(
        controller: controller,
        itemCount: children.length,
        itemBuilder: (context, index) {
          return Semantics(
            sortKey: OrdinalSortKey(index.toDouble()),
            child: children[index],
          );
        },
      ),
    );
  }

  /// Creates accessible grid with proper navigation
  static Widget buildAccessibleGrid({
    required List<Widget> children,
    required String gridDescription,
    required int crossAxisCount,
    ScrollController? controller,
  }) {
    return Semantics(
      label: gridDescription,
      child: GridView.builder(
        controller: controller,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) {
          final row = index ~/ crossAxisCount;
          final col = index % crossAxisCount;
          return Semantics(
            sortKey: OrdinalSortKey(index.toDouble()),
            label: 'Row ${row + 1}, Column ${col + 1}',
            child: children[index],
          );
        },
      ),
    );
  }

  /// Creates accessible form field
  static Widget buildAccessibleFormField({
    required Widget child,
    required String label,
    String? hint,
    String? errorText,
    bool isRequired = false,
  }) {
    return Semantics(
      label: label + (isRequired ? ' (required)' : ''),
      hint: hint,
      textField: true,
      child: child,
    );
  }

  /// Wraps content with reduced motion awareness
  static Widget buildReducedMotionWrapper({
    required Widget child,
    required Widget reducedMotionChild,
  }) {
    return Builder(
      builder: (context) {
        final disableAnimations = MediaQuery.of(context).disableAnimations;
        return disableAnimations ? reducedMotionChild : child;
      },
    );
  }

  /// Creates accessible navigation breadcrumb
  static Widget buildAccessibleBreadcrumb({
    required List<String> breadcrumbItems,
    required int currentIndex,
    List<VoidCallback?>? onTapItems,
  }) {
    return Semantics(
      label:
          'Navigation breadcrumb, current page: ${breadcrumbItems[currentIndex]}',
      child: Wrap(
        children: breadcrumbItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isCurrent = index == currentIndex;
          final onTap = onTapItems?[index];

          return Semantics(
            label: item + (isCurrent ? ' (current)' : ''),
            button: onTap != null && !isCurrent,
            selected: isCurrent,
            child: InkWell(
              onTap: !isCurrent ? onTap : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  item,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    decoration: !isCurrent && onTap != null
                        ? TextDecoration.underline
                        : null,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Types of haptic feedback for different game events
enum GameHapticType { correct, incorrect, gameOver, powerUp, button }

/// Accessibility theme wrapper for consistent contrast and sizing
class AccessibilityTheme extends StatelessWidget {
  final Widget child;

  const AccessibilityTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final isHighContrast = mediaQuery.highContrast;
        final isLargeText = mediaQuery.textScaler.scale(1.0) > 1.2;

        // Return themed content based on accessibility needs
        return Theme(
          data: Theme.of(context).copyWith(
            // Enhanced contrast for high contrast mode
            colorScheme: isHighContrast
                ? ColorScheme.fromSeed(
                    seedColor: Theme.of(context).primaryColor,
                    brightness: Theme.of(context).brightness,
                  )
                : Theme.of(context).colorScheme,
            // Enhanced text theme for large text
            textTheme: isLargeText
                ? Theme.of(context).textTheme.apply(fontSizeFactor: 1.1)
                : Theme.of(context).textTheme,
          ),
          child: child,
        );
      },
    );
  }
}
