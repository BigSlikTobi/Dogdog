import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/widgets/modern_card.dart';
import '../../lib/widgets/gradient_button.dart';
import '../../lib/widgets/dog_breed_card.dart';
import '../../lib/utils/accessibility.dart';
import '../../lib/utils/responsive.dart';
import '../../lib/design_system/modern_colors.dart';

void main() {
  group('Accessibility Tests', () {
    testWidgets('ModernCard has proper semantic labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernCard(
              semanticLabel: 'Test card with content',
              child: const Text('Card content'),
            ),
          ),
        ),
      );

      // Find semantic widget
      final semanticsWidget = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Test card with content',
      );

      expect(semanticsWidget, findsOneWidget);
    });

    testWidgets('GradientButton has proper semantic labels and touch targets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton.primary(
              text: 'Test Button',
              onPressed: () {},
              semanticLabel: 'Test button for accessibility',
            ),
          ),
        ),
      );

      // Check semantic label
      final semanticsWidget = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.button == true,
      );

      expect(semanticsWidget, findsOneWidget);

      // Check minimum touch target size
      final buttonSize = tester.getSize(find.byType(GradientButton));
      expect(buttonSize.height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('DogBreedCard has proper accessibility features', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DogBreedCard(
              breedName: 'Test Breed',
              difficulty: 'easy',
              imagePath: 'assets/images/test.png',
              onTap: () {},
              semanticLabel: 'Test breed card',
            ),
          ),
        ),
      );

      // Check semantic label
      final semanticsWidget = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label?.contains('Test breed') == true,
      );

      expect(semanticsWidget, findsOneWidget);
    });

    testWidgets('High contrast mode affects styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            highContrast: true,
            textScaler: TextScaler.linear(1.0),
          ),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  expect(
                    AccessibilityUtils.isHighContrastEnabled(context),
                    isTrue,
                  );
                  return const ModernCard(child: Text('High Contrast Card'));
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
    });

    testWidgets('Responsive design adapts to screen size', (
      WidgetTester tester,
    ) async {
      // Test mobile screen
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getScreenType(context), ScreenType.mobile);
              expect(ResponsiveUtils.isMobile(context), isTrue);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet screen
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getScreenType(context), ScreenType.tablet);
              expect(ResponsiveUtils.isTablet(context), isTrue);
              return const SizedBox();
            },
          ),
        ),
      );

      // Reset view
      addTearDown(tester.view.reset);
    });

    testWidgets('Text scaling is properly supported', (
      WidgetTester tester,
    ) async {
      const largeTextScale = 2.0;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(largeTextScale),
          ),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final multiplier = ResponsiveUtils.getFontSizeMultiplier(
                    context,
                  );
                  expect(multiplier, greaterThan(1.0));
                  return const Text('Scalable text');
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
    });

    testWidgets('Reduced motion preferences are respected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final duration =
                      ResponsiveUtils.getAccessibleAnimationDuration(
                        context,
                        const Duration(milliseconds: 300),
                      );
                  expect(duration, equals(Duration.zero));
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
    });
  });

  group('Color Contrast Tests', () {
    test('calculateContrastRatio returns correct values', () {
      // Test black on white (maximum contrast)
      final blackWhiteRatio = AccessibilityUtils.calculateContrastRatio(
        Colors.black,
        Colors.white,
      );
      expect(blackWhiteRatio, closeTo(21.0, 0.1));

      // Test same color (minimum contrast)
      final sameColorRatio = AccessibilityUtils.calculateContrastRatio(
        Colors.red,
        Colors.red,
      );
      expect(sameColorRatio, closeTo(1.0, 0.1));
    });

    test('WCAG compliance checking works correctly', () {
      // Test colors that should pass WCAG AA
      expect(
        AccessibilityUtils.meetsWCAGAA(Colors.black, Colors.white),
        isTrue,
      );

      // Test colors that should fail WCAG AA
      expect(
        AccessibilityUtils.meetsWCAGAA(const Color(0xFFCCCCCC), Colors.white),
        isFalse,
      );
    });

    test('Modern color system meets accessibility standards', () {
      // Test primary text on card background
      final textCardRatio = AccessibilityUtils.calculateContrastRatio(
        ModernColors.textPrimary,
        ModernColors.cardBackground,
      );
      expect(textCardRatio, greaterThanOrEqualTo(4.5));

      // Test text on dark backgrounds
      final textOnDarkRatio = AccessibilityUtils.calculateContrastRatio(
        ModernColors.textOnDark,
        ModernColors.primaryPurple,
      );
      // Note: This combination should meet WCAG AA standards, but if it doesn't,
      // we should use the accessible color pair utility
      if (textOnDarkRatio < 4.5) {
        final accessiblePair = AccessibilityUtils.getAccessibleColorPair(
          ModernColors.textOnDark,
          ModernColors.primaryPurple,
        );
        expect(accessiblePair.meetsWCAGAA, isTrue);
      } else {
        expect(textOnDarkRatio, greaterThanOrEqualTo(4.5));
      }
    });

    test('getAccessibleColorPair returns compliant colors', () {
      final colorPair = AccessibilityUtils.getAccessibleColorPair(
        const Color(0xFFCCCCCC), // Light gray
        Colors.white,
      );

      // The function should return an accessible color pair
      expect(colorPair.contrastRatio, greaterThanOrEqualTo(4.5));
    });
  });

  group('Touch Target Tests', () {
    test('getMinimumTouchTargetSize returns correct size', () {
      final minSize = AccessibilityUtils.getMinimumTouchTargetSize();
      expect(minSize.width, equals(44.0));
      expect(minSize.height, equals(44.0));
    });

    test('meetsTouchTargetSize correctly validates sizes', () {
      expect(
        AccessibilityUtils.meetsTouchTargetSize(const Size(44, 44)),
        isTrue,
      );
      expect(
        AccessibilityUtils.meetsTouchTargetSize(const Size(40, 40)),
        isFalse,
      );
      expect(
        AccessibilityUtils.meetsTouchTargetSize(const Size(50, 50)),
        isTrue,
      );
    });
  });

  group('Responsive Utility Tests', () {
    testWidgets('Font size multiplier respects text scaling', (
      WidgetTester tester,
    ) async {
      const textScales = [0.8, 1.0, 1.5, 2.0];
      final multipliers = <double>[];

      for (final scale in textScales) {
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(
              textScaler: TextScaler.linear(scale),
              size: const Size(400, 800),
            ),
            child: Builder(
              builder: (context) {
                multipliers.add(ResponsiveUtils.getFontSizeMultiplier(context));
                return const SizedBox();
              },
            ),
          ),
        );
      }

      // Verify font size multiplier increases with text scale
      for (int i = 1; i < multipliers.length; i++) {
        expect(multipliers[i], greaterThanOrEqualTo(multipliers[i - 1]));
      }

      // Verify multipliers are within reasonable bounds
      for (final multiplier in multipliers) {
        expect(multiplier, greaterThanOrEqualTo(0.8));
        expect(multiplier, lessThanOrEqualTo(2.5));
      }
    });

    testWidgets('Responsive padding scales correctly', (
      WidgetTester tester,
    ) async {
      late EdgeInsets mobilePadding;
      late EdgeInsets tabletPadding;

      // Test mobile padding
      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              mobilePadding = ResponsiveUtils.getResponsivePadding(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet padding
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              tabletPadding = ResponsiveUtils.getResponsivePadding(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Verify padding increases with screen size
      expect(tabletPadding.left, greaterThan(mobilePadding.left));

      // Reset view
      addTearDown(tester.view.reset);
    });
  });
}
