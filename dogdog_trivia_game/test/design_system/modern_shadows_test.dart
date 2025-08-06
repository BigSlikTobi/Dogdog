import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/design_system/modern_shadows.dart';

void main() {
  group('ModernShadows', () {
    test('should have correct elevation constants', () {
      expect(ModernShadows.elevation0, 0.0);
      expect(ModernShadows.elevation1, 1.0);
      expect(ModernShadows.elevation2, 2.0);
      expect(ModernShadows.elevation3, 3.0);
      expect(ModernShadows.elevation4, 4.0);
      expect(ModernShadows.elevation6, 6.0);
      expect(ModernShadows.elevation8, 8.0);
      expect(ModernShadows.elevation12, 12.0);
      expect(ModernShadows.elevation16, 16.0);
      expect(ModernShadows.elevation24, 24.0);
    });

    test('should have empty shadow list for none', () {
      expect(ModernShadows.none, isEmpty);
    });

    test('should have correct subtle shadow', () {
      expect(ModernShadows.subtle, hasLength(1));
      final shadow = ModernShadows.subtle.first;
      expect(shadow.offset, const Offset(0, 1));
      expect(shadow.blurRadius, 2);
      expect(shadow.spreadRadius, 0);
    });

    test('should have correct small shadow', () {
      expect(ModernShadows.small, hasLength(1));
      final shadow = ModernShadows.small.first;
      expect(shadow.offset, const Offset(0, 2));
      expect(shadow.blurRadius, 4);
      expect(shadow.spreadRadius, 0);
    });

    test('should have correct medium shadow', () {
      expect(ModernShadows.medium, hasLength(2));
      final firstShadow = ModernShadows.medium.first;
      expect(firstShadow.offset, const Offset(0, 4));
      expect(firstShadow.blurRadius, 8);
      expect(firstShadow.spreadRadius, 0);

      final secondShadow = ModernShadows.medium.last;
      expect(secondShadow.offset, const Offset(0, 2));
      expect(secondShadow.blurRadius, 4);
      expect(secondShadow.spreadRadius, 0);
    });

    test('should have correct large shadow', () {
      expect(ModernShadows.large, hasLength(2));
      final firstShadow = ModernShadows.large.first;
      expect(firstShadow.offset, const Offset(0, 8));
      expect(firstShadow.blurRadius, 16);
      expect(firstShadow.spreadRadius, 0);

      final secondShadow = ModernShadows.large.last;
      expect(secondShadow.offset, const Offset(0, 4));
      expect(secondShadow.blurRadius, 8);
      expect(secondShadow.spreadRadius, 0);
    });

    test('should have correct extra large shadow', () {
      expect(ModernShadows.extraLarge, hasLength(2));
      final firstShadow = ModernShadows.extraLarge.first;
      expect(firstShadow.offset, const Offset(0, 12));
      expect(firstShadow.blurRadius, 24);
      expect(firstShadow.spreadRadius, 0);

      final secondShadow = ModernShadows.extraLarge.last;
      expect(secondShadow.offset, const Offset(0, 6));
      expect(secondShadow.blurRadius, 12);
      expect(secondShadow.spreadRadius, 0);
    });

    test('should have correct component-specific shadows', () {
      expect(ModernShadows.card, ModernShadows.medium);
      expect(ModernShadows.button, ModernShadows.small);
      expect(ModernShadows.floatingButton, ModernShadows.large);
      expect(ModernShadows.modal, ModernShadows.extraLarge);
      expect(ModernShadows.tooltip, ModernShadows.small);
      expect(ModernShadows.dropdown, ModernShadows.medium);
    });

    test('should have correct interactive state shadows', () {
      expect(ModernShadows.buttonPressed, hasLength(1));
      final pressedShadow = ModernShadows.buttonPressed.first;
      expect(pressedShadow.offset, const Offset(0, 1));
      expect(pressedShadow.blurRadius, 2);
      expect(pressedShadow.spreadRadius, 0);

      expect(ModernShadows.buttonHover, hasLength(1));
      final hoverShadow = ModernShadows.buttonHover.first;
      expect(hoverShadow.offset, const Offset(0, 4));
      expect(hoverShadow.blurRadius, 12);
      expect(hoverShadow.spreadRadius, 0);

      expect(ModernShadows.cardHover, hasLength(2));
      final cardHoverFirst = ModernShadows.cardHover.first;
      expect(cardHoverFirst.offset, const Offset(0, 6));
      expect(cardHoverFirst.blurRadius, 16);
      expect(cardHoverFirst.spreadRadius, 0);
    });

    test('should create colored shadow correctly', () {
      const testColor = Color(0xFF123456);
      const opacity = 0.5;
      final coloredShadow = ModernShadows.colored(testColor, opacity: opacity);

      expect(coloredShadow, hasLength(1));
      final shadow = coloredShadow.first;
      expect(shadow.color, testColor.withValues(alpha: opacity));
      expect(shadow.offset, const Offset(0, 4));
      expect(shadow.blurRadius, 12);
      expect(shadow.spreadRadius, 0);
    });

    test('should create glow shadow correctly', () {
      const testColor = Color(0xFF123456);
      const opacity = 0.6;
      const blur = 10.0;
      final glowShadow = ModernShadows.glow(
        testColor,
        opacity: opacity,
        blur: blur,
      );

      expect(glowShadow, hasLength(1));
      final shadow = glowShadow.first;
      expect(shadow.color, testColor.withValues(alpha: opacity));
      expect(shadow.offset, const Offset(0, 0));
      expect(shadow.blurRadius, blur);
      expect(shadow.spreadRadius, 2);
    });

    test('should have correct inner shadow', () {
      expect(ModernShadows.inner, hasLength(1));
      final shadow = ModernShadows.inner.first;
      expect(shadow.offset, const Offset(0, 2));
      expect(shadow.blurRadius, 4);
      expect(shadow.spreadRadius, -2);
    });

    test('should create custom shadow correctly', () {
      const testColor = Color(0xFF123456);
      const offset = Offset(5, 10);
      const blurRadius = 15.0;
      const spreadRadius = 3.0;
      const opacity = 0.8;

      final customShadow = ModernShadows.custom(
        color: testColor,
        offset: offset,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
        opacity: opacity,
      );

      expect(customShadow, hasLength(1));
      final shadow = customShadow.first;
      expect(shadow.color, testColor.withValues(alpha: opacity));
      expect(shadow.offset, offset);
      expect(shadow.blurRadius, blurRadius);
      expect(shadow.spreadRadius, spreadRadius);
    });

    test('should return correct shadow by elevation', () {
      expect(ModernShadows.byElevation(0), ModernShadows.none);
      expect(ModernShadows.byElevation(-1), ModernShadows.none);
      expect(ModernShadows.byElevation(1), ModernShadows.subtle);
      expect(ModernShadows.byElevation(2), ModernShadows.small);
      expect(ModernShadows.byElevation(4), ModernShadows.medium);
      expect(ModernShadows.byElevation(8), ModernShadows.large);
      expect(ModernShadows.byElevation(16), ModernShadows.extraLarge);
    });

    test('should lerp between shadow lists correctly', () {
      final lerpedShadows = ModernShadows.lerp(
        ModernShadows.small,
        ModernShadows.medium,
        0.5,
      );

      expect(lerpedShadows, hasLength(2));
      // The lerp should create intermediate shadows between small and medium
      expect(lerpedShadows.first.offset.dy, greaterThan(2));
      expect(lerpedShadows.first.offset.dy, lessThan(4));
    });

    test('should handle empty shadow lists in lerp', () {
      final lerpFromEmpty = ModernShadows.lerp([], ModernShadows.small, 0.5);
      expect(lerpFromEmpty, hasLength(1));

      final lerpToEmpty = ModernShadows.lerp(ModernShadows.small, [], 0.5);
      expect(lerpToEmpty, hasLength(1));

      final lerpBothEmpty = ModernShadows.lerp([], [], 0.5);
      expect(lerpBothEmpty, isEmpty);
    });

    test('should return correct material elevation shadows', () {
      final elevation0 = ModernShadows.materialElevation(0);
      expect(elevation0, ModernShadows.none);

      final elevation1 = ModernShadows.materialElevation(1);
      expect(elevation1, hasLength(3));

      final elevation2 = ModernShadows.materialElevation(2);
      expect(elevation2, hasLength(3));

      final elevation3 = ModernShadows.materialElevation(3);
      expect(elevation3, hasLength(3));

      final elevation4 = ModernShadows.materialElevation(4);
      expect(elevation4, hasLength(3));

      final elevationDefault = ModernShadows.materialElevation(99);
      expect(elevationDefault, ModernShadows.medium);
    });

    test('should have correct shadow color opacity values', () {
      // Test that shadow colors have appropriate opacity
      final subtleShadow = ModernShadows.subtle.first;
      expect(subtleShadow.color.a, lessThan(0.2));

      final smallShadow = ModernShadows.small.first;
      expect(smallShadow.color.a, lessThan(0.3));

      final mediumShadow = ModernShadows.medium.first;
      expect(mediumShadow.color.a, lessThan(0.3));
    });
  });
}
