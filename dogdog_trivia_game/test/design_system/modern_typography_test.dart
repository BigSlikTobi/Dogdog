import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/design_system/modern_typography.dart';
import 'package:dogdog_trivia_game/design_system/modern_colors.dart';

void main() {
  group('ModernTypography', () {
    test('should have correct heading styles', () {
      expect(ModernTypography.headingLarge.fontSize, 28);
      expect(ModernTypography.headingLarge.fontWeight, FontWeight.bold);
      expect(ModernTypography.headingLarge.height, 1.2);
      expect(ModernTypography.headingLarge.letterSpacing, -0.5);
      expect(ModernTypography.headingLarge.color, ModernColors.textPrimary);

      expect(ModernTypography.headingMedium.fontSize, 24);
      expect(ModernTypography.headingMedium.fontWeight, FontWeight.w600);
      expect(ModernTypography.headingMedium.height, 1.3);
      expect(ModernTypography.headingMedium.letterSpacing, -0.3);

      expect(ModernTypography.headingSmall.fontSize, 20);
      expect(ModernTypography.headingSmall.fontWeight, FontWeight.w600);
      expect(ModernTypography.headingSmall.height, 1.3);
      expect(ModernTypography.headingSmall.letterSpacing, -0.2);
    });

    test('should have correct body styles', () {
      expect(ModernTypography.bodyLarge.fontSize, 18);
      expect(ModernTypography.bodyLarge.fontWeight, FontWeight.normal);
      expect(ModernTypography.bodyLarge.height, 1.4);
      expect(ModernTypography.bodyLarge.letterSpacing, 0);
      expect(ModernTypography.bodyLarge.color, ModernColors.textPrimary);

      expect(ModernTypography.bodyMedium.fontSize, 16);
      expect(ModernTypography.bodyMedium.fontWeight, FontWeight.normal);
      expect(ModernTypography.bodyMedium.height, 1.5);
      expect(ModernTypography.bodyMedium.letterSpacing, 0);

      expect(ModernTypography.bodySmall.fontSize, 14);
      expect(ModernTypography.bodySmall.fontWeight, FontWeight.normal);
      expect(ModernTypography.bodySmall.height, 1.5);
      expect(ModernTypography.bodySmall.letterSpacing, 0.1);
      expect(ModernTypography.bodySmall.color, ModernColors.textSecondary);
    });

    test('should have correct button styles', () {
      expect(ModernTypography.buttonLarge.fontSize, 18);
      expect(ModernTypography.buttonLarge.fontWeight, FontWeight.w600);
      expect(ModernTypography.buttonLarge.height, 1.2);
      expect(ModernTypography.buttonLarge.letterSpacing, 0.5);
      expect(ModernTypography.buttonLarge.color, ModernColors.textOnDark);

      expect(ModernTypography.buttonMedium.fontSize, 16);
      expect(ModernTypography.buttonMedium.fontWeight, FontWeight.w600);
      expect(ModernTypography.buttonMedium.height, 1.2);
      expect(ModernTypography.buttonMedium.letterSpacing, 0.3);

      expect(ModernTypography.buttonSmall.fontSize, 14);
      expect(ModernTypography.buttonSmall.fontWeight, FontWeight.w600);
      expect(ModernTypography.buttonSmall.height, 1.2);
      expect(ModernTypography.buttonSmall.letterSpacing, 0.3);
    });

    test('should have correct caption and label styles', () {
      expect(ModernTypography.caption.fontSize, 12);
      expect(ModernTypography.caption.fontWeight, FontWeight.normal);
      expect(ModernTypography.caption.height, 1.4);
      expect(ModernTypography.caption.letterSpacing, 0.4);
      expect(ModernTypography.caption.color, ModernColors.textLight);

      expect(ModernTypography.label.fontSize, 12);
      expect(ModernTypography.label.fontWeight, FontWeight.w500);
      expect(ModernTypography.label.height, 1.3);
      expect(ModernTypography.label.letterSpacing, 0.5);
      expect(ModernTypography.label.color, ModernColors.textSecondary);
    });

    test('should have correct display styles', () {
      expect(ModernTypography.displayLarge.fontSize, 36);
      expect(ModernTypography.displayLarge.fontWeight, FontWeight.bold);
      expect(ModernTypography.displayLarge.height, 1.1);
      expect(ModernTypography.displayLarge.letterSpacing, -1.0);
      expect(ModernTypography.displayLarge.color, ModernColors.textPrimary);

      expect(ModernTypography.displayMedium.fontSize, 32);
      expect(ModernTypography.displayMedium.fontWeight, FontWeight.bold);
      expect(ModernTypography.displayMedium.height, 1.1);
      expect(ModernTypography.displayMedium.letterSpacing, -0.8);
    });

    test('should apply color variations correctly', () {
      const testColor = Color(0xFF123456);
      final styledText = ModernTypography.withColor(
        ModernTypography.bodyMedium,
        testColor,
      );
      expect(styledText.color, testColor);

      final secondaryText = ModernTypography.withSecondaryColor(
        ModernTypography.bodyMedium,
      );
      expect(secondaryText.color, ModernColors.textSecondary);

      final lightText = ModernTypography.withLightColor(
        ModernTypography.bodyMedium,
      );
      expect(lightText.color, ModernColors.textLight);

      final onDarkText = ModernTypography.withOnDarkColor(
        ModernTypography.bodyMedium,
      );
      expect(onDarkText.color, ModernColors.textOnDark);
    });

    test('should apply weight variations correctly', () {
      final boldText = ModernTypography.bold(ModernTypography.bodyMedium);
      expect(boldText.fontWeight, FontWeight.bold);

      final semiBoldText = ModernTypography.semiBold(
        ModernTypography.bodyMedium,
      );
      expect(semiBoldText.fontWeight, FontWeight.w600);

      final mediumText = ModernTypography.medium(ModernTypography.bodyMedium);
      expect(mediumText.fontWeight, FontWeight.w500);

      final customWeightText = ModernTypography.withWeight(
        ModernTypography.bodyMedium,
        FontWeight.w300,
      );
      expect(customWeightText.fontWeight, FontWeight.w300);
    });

    test('should apply size variations correctly', () {
      const testSize = 20.0;
      final resizedText = ModernTypography.withSize(
        ModernTypography.bodyMedium,
        testSize,
      );
      expect(resizedText.fontSize, testSize);
    });

    test('should apply accessibility scale correctly', () {
      const scale = 1.5;
      final scaledText = ModernTypography.withAccessibilityScale(
        ModernTypography.bodyMedium,
        scale,
      );
      expect(
        scaledText.fontSize,
        ModernTypography.bodyMedium.fontSize! * scale,
      );
    });

    test('should have correct theme-specific text styles', () {
      expect(ModernTypography.questionText, ModernTypography.headingMedium);
      expect(ModernTypography.answerText, ModernTypography.bodyLarge);
      expect(ModernTypography.scoreText, ModernTypography.displayMedium);
      expect(ModernTypography.timerText, ModernTypography.headingSmall);
      expect(ModernTypography.achievementTitle, ModernTypography.headingSmall);
      expect(
        ModernTypography.achievementDescription,
        ModernTypography.bodySmall,
      );
      expect(ModernTypography.difficultyTitle, ModernTypography.headingMedium);
      expect(
        ModernTypography.difficultyDescription,
        ModernTypography.bodyMedium,
      );
    });

    test('should handle null fontSize in accessibility scale', () {
      const styleWithoutFontSize = TextStyle();
      final scaledText = ModernTypography.withAccessibilityScale(
        styleWithoutFontSize,
        1.5,
      );
      expect(scaledText.fontSize, 16 * 1.5); // Default fontSize is 16
    });
  });
}
