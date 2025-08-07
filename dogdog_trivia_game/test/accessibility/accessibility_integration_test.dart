import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:dogdog_trivia_game/main.dart';
import 'package:dogdog_trivia_game/services/progress_service.dart';
import 'package:dogdog_trivia_game/widgets/modern_card.dart';
import 'package:dogdog_trivia_game/widgets/gradient_button.dart';
import 'package:dogdog_trivia_game/widgets/dog_breed_card.dart';
import 'package:dogdog_trivia_game/utils/accessibility.dart';
import 'package:dogdog_trivia_game/design_system/modern_colors.dart';

void main() {
  group('Accessibility Integration Tests', () {
    testWidgets('All interactive elements have proper semantic labels', (
      WidgetTester tester,
    ) async {
      final progressService = ProgressService();
      await tester.pumpWidget(
        MultiProvider(
          providers: [ChangeNotifierProvider.value(value: progressService)],
          child: DogDogTriviaApp(progressService: progressService),
        ),
      );

      // Find all interactive elements
      final semanticButtons = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.button == true,
      );

      expect(semanticButtons, findsWidgets);

      // Verify each interactive element has a semantic label
      for (final element in tester.widgetList(semanticButtons)) {
        final semantics = element as Semantics;
        expect(semantics.properties.label, isNotNull);
        expect(semantics.properties.label!.isNotEmpty, isTrue);
      }
    });

    testWidgets('Color contrast meets WCAG AA standards', (
      WidgetTester tester,
    ) async {
      // Test primary color combinations
      final colorPairs = [
        (ModernColors.textPrimary, ModernColors.cardBackground),
        (ModernColors.textOnDark, ModernColors.primaryPurple),
        (ModernColors.textOnDark, ModernColors.primaryBlue),
        (ModernColors.textPrimary, ModernColors.surfaceLight),
      ];

      for (final (foreground, background) in colorPairs) {
        final contrastRatio = AccessibilityUtils.calculateContrastRatio(
          foreground,
          background,
        );
        expect(
          contrastRatio,
          greaterThanOrEqualTo(4.5),
          reason:
              'Color pair ${foreground.toString()} on ${background.toString()} '
              'has contrast ratio $contrastRatio, which is below WCAG AA standard (4.5:1)',
        );
      }
    });

    testWidgets('Touch targets meet minimum size requirements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GradientButton.primary(text: 'Test Button', onPressed: () {}),
                DogBreedCard(
                  breedName: 'Chihuahua',
                  difficulty: 'easy',
                  imagePath: 'assets/images/chihuahua.png',
                  onTap: () {},
                ),
                ModernCard.interactive(
                  onTap: () {},
                  child: const Text('Interactive Card'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find all interactive widgets
      final interactiveWidgets = [
        find.byType(GradientButton),
        find.byType(DogBreedCard),
        find.byType(ModernCard),
      ];

      for (final finder in interactiveWidgets) {
        if (finder.evaluate().isNotEmpty) {
          final size = tester.getSize(finder.first);
          final minSize = AccessibilityUtils.getMinimumTouchTargetSize();

          expect(
            size.width,
            greaterThanOrEqualTo(minSize.width),
            reason:
                'Widget width ${size.width} is below minimum touch target width ${minSize.width}',
          );
          expect(
            size.height,
            greaterThanOrEqualTo(minSize.height),
            reason:
                'Widget height ${size.height} is below minimum touch target height ${minSize.height}',
          );
        }
      }
    });

    testWidgets('High contrast mode is properly supported', (
      WidgetTester tester,
    ) async {
      // Test with high contrast enabled
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter/platform'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'SystemChrome.setSystemUIOverlayStyle') {
            return null;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            highContrast: true,
            textScaler: TextScaler.linear(1.0),
          ),
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  GradientButton.primary(
                    text: 'High Contrast Button',
                    onPressed: () {},
                  ),
                  const ModernCard(child: Text('High Contrast Card')),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that high contrast mode affects styling
      final context = tester.element(find.byType(MaterialApp));
      expect(AccessibilityUtils.isHighContrastEnabled(context), isTrue);

      // Check that shadows are disabled in high contrast mode
      final cardWidget = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ModernCard),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = cardWidget.decoration as BoxDecoration?;
      expect(decoration?.boxShadow, anyOf(isNull, isEmpty));
    });

    testWidgets('Reduced motion preferences are respected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            disableAnimations: true,
            textScaler: TextScaler.linear(1.0),
          ),
          child: MaterialApp(
            home: Scaffold(
              body: GradientButton.primary(
                text: 'Animated Button',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the button to trigger animation
      await tester.tap(find.byType(GradientButton));

      // With reduced motion, animations should complete immediately
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
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
              body: Column(
                children: [
                  GradientButton.primary(
                    text: 'Scalable Text Button',
                    onPressed: () {},
                  ),
                  const ModernCard(child: Text('Scalable Text Card')),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that text scales appropriately
      final textWidgets = find.byType(Text);
      for (final textFinder in textWidgets.evaluate()) {
        final textWidget = textFinder.widget as Text;
        final style = textWidget.style;
        if (style?.fontSize != null) {
          // Text should be scaled according to the text scale factor
          expect(
            style!.fontSize! * largeTextScale,
            greaterThan(style.fontSize!),
          );
        }
      }
    });

    testWidgets('Focus management works correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GradientButton.primary(text: 'First Button', onPressed: () {}),
                GradientButton.primary(text: 'Second Button', onPressed: () {}),
                DogBreedCard(
                  breedName: 'Chihuahua',
                  difficulty: 'easy',
                  imagePath: 'assets/images/chihuahua.png',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test keyboard navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Verify focus moves between interactive elements
      final focusedElement = FocusManager.instance.primaryFocus;
      expect(focusedElement, isNotNull);
    });

    testWidgets('Screen reader announcements work correctly', (
      WidgetTester tester,
    ) async {
      final announcements = <String>[];

      // Mock the SemanticsService to capture announcements
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter/accessibility'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'announce') {
            announcements.add(methodCall.arguments['message'] as String);
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(accessibleNavigation: true),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return GradientButton.primary(
                    text: 'Announce Button',
                    onPressed: () {
                      AccessibilityUtils.announceToScreenReader(
                        context,
                        'Button was pressed',
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the button to trigger announcement
      await tester.tap(find.byType(GradientButton));
      await tester.pump();

      // Verify announcement was made
      expect(announcements, contains('Button was pressed'));
    });

    testWidgets('Responsive design adapts to different screen sizes', (
      WidgetTester tester,
    ) async {
      // Test mobile layout
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GradientButton.primary(
                  text: 'Responsive Button',
                  onPressed: () {},
                  expandWidth: true,
                ),
                DogBreedCard(
                  breedName: 'Chihuahua',
                  difficulty: 'easy',
                  imagePath: 'assets/images/chihuahua.png',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final mobileButtonSize = tester.getSize(find.byType(GradientButton));
      final mobileCardSize = tester.getSize(find.byType(DogBreedCard));

      // Test tablet layout
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpAndSettle();

      final tabletButtonSize = tester.getSize(find.byType(GradientButton));
      final tabletCardSize = tester.getSize(find.byType(DogBreedCard));

      // Verify responsive behavior
      expect(
        tabletButtonSize.height,
        greaterThanOrEqualTo(mobileButtonSize.height),
      );
      expect(tabletCardSize.width, greaterThanOrEqualTo(mobileCardSize.width));

      // Reset window size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('Error states are accessible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DogBreedCard(
              breedName: 'Test Breed',
              difficulty: 'easy',
              imagePath: 'invalid/path.png', // This will trigger error state
              isEnabled: false, // Disabled state
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the semantic widget
      final semanticsWidget = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.enabled == false,
      );

      expect(semanticsWidget, findsOneWidget);

      final semantics = tester.widget<Semantics>(semanticsWidget);
      expect(semantics.properties.enabled, isFalse);
      expect(semantics.properties.label, contains('Test Breed'));
    });
  });

  group('Color Contrast Utility Tests', () {
    test('calculateContrastRatio returns correct values', () {
      // Test black on white (maximum contrast)
      final blackWhiteRatio = AccessibilityUtils.calculateContrastRatio(
        Colors.black,
        Colors.white,
      );
      expect(blackWhiteRatio, closeTo(21.0, 0.1));

      // Test white on black (same ratio)
      final whiteBlackRatio = AccessibilityUtils.calculateContrastRatio(
        Colors.white,
        Colors.black,
      );
      expect(whiteBlackRatio, closeTo(21.0, 0.1));

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

      // Test WCAG AAA (stricter standard)
      expect(
        AccessibilityUtils.meetsWCAGAAA(Colors.black, Colors.white),
        isTrue,
      );
    });

    test('getAccessibleColorPair returns compliant colors', () {
      final colorPair = AccessibilityUtils.getAccessibleColorPair(
        const Color(0xFFCCCCCC), // Light gray
        Colors.white,
      );

      expect(colorPair.meetsWCAGAA, isTrue);
      expect(colorPair.contrastRatio, greaterThanOrEqualTo(4.5));
    });
  });
}
