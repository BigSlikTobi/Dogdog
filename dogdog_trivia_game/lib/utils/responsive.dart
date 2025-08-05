import 'package:flutter/material.dart';

/// Utility class for responsive design calculations and breakpoints
class ResponsiveUtils {
  /// Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Get the current screen type based on width
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }

  /// Check if the current screen is mobile
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }

  /// Check if the current screen is tablet
  static bool isTablet(BuildContext context) {
    return getScreenType(context) == ScreenType.tablet;
  }

  /// Check if the current screen is desktop
  static bool isDesktop(BuildContext context) {
    return getScreenType(context) == ScreenType.desktop;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.all(16.0);
      case ScreenType.tablet:
        return const EdgeInsets.all(24.0);
      case ScreenType.desktop:
        return const EdgeInsets.all(32.0);
    }
  }

  /// Get responsive font size multiplier
  static double getFontSizeMultiplier(BuildContext context) {
    final screenType = getScreenType(context);
    final textScaler = MediaQuery.of(context).textScaler;

    double baseMultiplier;
    switch (screenType) {
      case ScreenType.mobile:
        baseMultiplier = 1.0;
        break;
      case ScreenType.tablet:
        baseMultiplier = 1.1;
        break;
      case ScreenType.desktop:
        baseMultiplier = 1.2;
        break;
    }

    // Respect user's text scaling preferences
    final scaleFactor =
        textScaler.scale(16.0) / 16.0; // Get scale factor relative to 16px
    return baseMultiplier * scaleFactor.clamp(0.8, 2.0);
  }

  /// Get responsive button size
  static Size getResponsiveButtonSize(BuildContext context) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobile:
        return const Size(double.infinity, 56);
      case ScreenType.tablet:
        return const Size(double.infinity, 64);
      case ScreenType.desktop:
        return const Size(double.infinity, 72);
    }
  }

  /// Get responsive grid columns for answer choices
  static int getAnswerGridColumns(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final screenType = getScreenType(context);

    if (orientation == Orientation.landscape &&
        screenType != ScreenType.mobile) {
      return 4; // Single row in landscape on larger screens
    }
    return 2; // 2x2 grid for mobile or portrait
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobile:
        return baseSpacing;
      case ScreenType.tablet:
        return baseSpacing * 1.2;
      case ScreenType.desktop:
        return baseSpacing * 1.4;
    }
  }

  /// Get maximum content width for better readability on large screens
  static double getMaxContentWidth(BuildContext context) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobile:
        return double.infinity;
      case ScreenType.tablet:
        return 600;
      case ScreenType.desktop:
        return 800;
    }
  }

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final fontSizeMultiplier = getFontSizeMultiplier(context);
    return baseSize * fontSizeMultiplier;
  }
}

/// Enum for different screen types
enum ScreenType { mobile, tablet, desktop }

/// Widget that provides responsive layout capabilities
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveUtils.getScreenType(context);
    return builder(context, screenType);
  }
}

/// Widget that constrains content width for better readability
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ResponsiveContainer({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);
    final responsivePadding =
        padding ?? ResponsiveUtils.getResponsivePadding(context);

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: responsivePadding,
        child: child,
      ),
    );
  }
}
