import 'package:flutter/material.dart';
import 'modern_colors.dart';

/// Modern typography system for the DogDog trivia game redesign.
/// Provides consistent text styles with proper hierarchy and accessibility.
class ModernTypography {
  // Private constructor to prevent instantiation
  ModernTypography._();

  // Font family (using system default for better cross-platform support)
  static const String _fontFamily = 'System';

  // Heading Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
    color: ModernColors.textPrimary,
    fontFamily: _fontFamily,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
    color: ModernColors.textPrimary,
    fontFamily: _fontFamily,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
    color: ModernColors.textPrimary,
    fontFamily: _fontFamily,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.4,
    letterSpacing: 0,
    color: ModernColors.textPrimary,
    fontFamily: _fontFamily,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0,
    color: ModernColors.textPrimary,
    fontFamily: _fontFamily,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0.1,
    color: ModernColors.textSecondary,
    fontFamily: _fontFamily,
  );

  // Button Styles
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
    color: ModernColors.textOnDark,
    fontFamily: _fontFamily,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.3,
    color: ModernColors.textOnDark,
    fontFamily: _fontFamily,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.3,
    color: ModernColors.textOnDark,
    fontFamily: _fontFamily,
  );

  // Caption and Label Styles
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    letterSpacing: 0.4,
    color: ModernColors.textLight,
    fontFamily: _fontFamily,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
    color: ModernColors.textSecondary,
    fontFamily: _fontFamily,
  );

  // Display Styles (for large text like scores)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    height: 1.1,
    letterSpacing: -1.0,
    color: ModernColors.textPrimary,
    fontFamily: _fontFamily,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.1,
    letterSpacing: -0.8,
    color: ModernColors.textPrimary,
    fontFamily: _fontFamily,
  );

  // Helper methods for color variations
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withSecondaryColor(TextStyle style) {
    return style.copyWith(color: ModernColors.textSecondary);
  }

  static TextStyle withLightColor(TextStyle style) {
    return style.copyWith(color: ModernColors.textLight);
  }

  static TextStyle withOnDarkColor(TextStyle style) {
    return style.copyWith(color: ModernColors.textOnDark);
  }

  // Helper methods for weight variations
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.bold);
  }

  static TextStyle semiBold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w600);
  }

  static TextStyle medium(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w500);
  }

  // Helper methods for size variations
  static TextStyle withSize(TextStyle style, double fontSize) {
    return style.copyWith(fontSize: fontSize);
  }

  // Accessibility helper - scales text based on system settings
  static TextStyle withAccessibilityScale(TextStyle style, double scale) {
    return style.copyWith(fontSize: (style.fontSize ?? 16) * scale);
  }

  // Theme-specific text styles
  static TextStyle get questionText => headingMedium;
  static TextStyle get answerText => bodyLarge;
  static TextStyle get scoreText => displayMedium;
  static TextStyle get timerText => headingSmall;
  static TextStyle get achievementTitle => headingSmall;
  static TextStyle get achievementDescription => bodySmall;
  static TextStyle get difficultyTitle => headingMedium;
  static TextStyle get difficultyDescription => bodyMedium;
}
