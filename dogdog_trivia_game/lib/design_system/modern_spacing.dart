import 'package:flutter/material.dart';

/// Modern spacing system for the DogDog trivia game redesign.
/// Provides consistent spacing units and padding/margin definitions.
class ModernSpacing {
  // Private constructor to prevent instantiation
  ModernSpacing._();

  // Base spacing units (8px grid system)
  static const double xs = 4.0; // Extra small
  static const double sm = 8.0; // Small
  static const double md = 16.0; // Medium (base unit)
  static const double lg = 24.0; // Large
  static const double xl = 32.0; // Extra large
  static const double xxl = 48.0; // Extra extra large
  static const double xxxl = 64.0; // Extra extra extra large

  // Semantic spacing values
  static const double tiny = xs;
  static const double small = sm;
  static const double medium = md;
  static const double large = lg;
  static const double huge = xl;
  static const double massive = xxl;

  // Component-specific spacing
  static const double cardPadding = lg;
  static const double cardMargin = md;
  static const double buttonPadding = md;
  static const double screenPadding = lg;
  static const double sectionSpacing = xl;
  static const double elementSpacing = md;

  // Border radius values
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusRound = 50.0;

  // Common EdgeInsets
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);

  // Horizontal padding
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(
    horizontal: xs,
  );
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(
    horizontal: sm,
  );
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(
    horizontal: md,
  );
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(
    horizontal: lg,
  );
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(
    horizontal: xl,
  );

  // Vertical padding
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(
    vertical: xs,
  );
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(
    vertical: sm,
  );
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(
    vertical: md,
  );
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(
    vertical: lg,
  );
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(
    vertical: xl,
  );

  // Component-specific padding
  static const EdgeInsets cardPaddingInsets = EdgeInsets.all(cardPadding);
  static const EdgeInsets buttonPaddingInsets = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
  static const EdgeInsets screenPaddingInsets = EdgeInsets.all(screenPadding);

  // Asymmetric padding
  static const EdgeInsets paddingTop = EdgeInsets.only(top: md);
  static const EdgeInsets paddingBottom = EdgeInsets.only(bottom: md);
  static const EdgeInsets paddingLeft = EdgeInsets.only(left: md);
  static const EdgeInsets paddingRight = EdgeInsets.only(right: md);

  // Safe area padding
  static const EdgeInsets safeAreaPadding = EdgeInsets.only(
    top: lg,
    bottom: lg,
    left: md,
    right: md,
  );

  // SizedBox spacing widgets
  static const SizedBox spaceXS = SizedBox(height: xs, width: xs);
  static const SizedBox spaceSM = SizedBox(height: sm, width: sm);
  static const SizedBox spaceMD = SizedBox(height: md, width: md);
  static const SizedBox spaceLG = SizedBox(height: lg, width: lg);
  static const SizedBox spaceXL = SizedBox(height: xl, width: xl);
  static const SizedBox spaceXXL = SizedBox(height: xxl, width: xxl);

  // Horizontal spacing
  static const SizedBox horizontalSpaceXS = SizedBox(width: xs);
  static const SizedBox horizontalSpaceSM = SizedBox(width: sm);
  static const SizedBox horizontalSpaceMD = SizedBox(width: md);
  static const SizedBox horizontalSpaceLG = SizedBox(width: lg);
  static const SizedBox horizontalSpaceXL = SizedBox(width: xl);

  // Vertical spacing
  static const SizedBox verticalSpaceXS = SizedBox(height: xs);
  static const SizedBox verticalSpaceSM = SizedBox(height: sm);
  static const SizedBox verticalSpaceMD = SizedBox(height: md);
  static const SizedBox verticalSpaceLG = SizedBox(height: lg);
  static const SizedBox verticalSpaceXL = SizedBox(height: xl);

  // BorderRadius definitions
  static const BorderRadius borderRadiusSmall = BorderRadius.all(
    Radius.circular(radiusSmall),
  );
  static const BorderRadius borderRadiusMedium = BorderRadius.all(
    Radius.circular(radiusMedium),
  );
  static const BorderRadius borderRadiusLarge = BorderRadius.all(
    Radius.circular(radiusLarge),
  );
  static const BorderRadius borderRadiusXLarge = BorderRadius.all(
    Radius.circular(radiusXLarge),
  );
  static const BorderRadius borderRadiusRound = BorderRadius.all(
    Radius.circular(radiusRound),
  );

  // Helper methods for dynamic spacing
  static EdgeInsets symmetric({double? horizontal, double? vertical}) {
    return EdgeInsets.symmetric(
      horizontal: horizontal ?? 0,
      vertical: vertical ?? 0,
    );
  }

  static EdgeInsets only({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return EdgeInsets.only(
      top: top ?? 0,
      bottom: bottom ?? 0,
      left: left ?? 0,
      right: right ?? 0,
    );
  }

  static SizedBox space(double size) {
    return SizedBox(height: size, width: size);
  }

  static SizedBox horizontalSpace(double width) {
    return SizedBox(width: width);
  }

  static SizedBox verticalSpace(double height) {
    return SizedBox(height: height);
  }

  static BorderRadius borderRadius(double radius) {
    return BorderRadius.all(Radius.circular(radius));
  }

  // Responsive spacing helpers
  static double responsive(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1200 && desktop != null) {
      return desktop;
    } else if (screenWidth >= 768 && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  static EdgeInsets responsivePadding(
    BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1200 && desktop != null) {
      return desktop;
    } else if (screenWidth >= 768 && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }
}
