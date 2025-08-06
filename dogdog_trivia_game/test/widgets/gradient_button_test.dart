import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/widgets/gradient_button.dart';
import 'package:dogdog_trivia_game/design_system/modern_colors.dart';
import 'package:dogdog_trivia_game/design_system/modern_spacing.dart';
import 'package:dogdog_trivia_game/design_system/modern_shadows.dart';
import 'package:dogdog_trivia_game/design_system/modern_typography.dart';

void main() {
  group('GradientButton', () {
    testWidgets('should render button text', (WidgetTester tester) async {
      const buttonText = 'Test Button';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: buttonText,
              onPressed: () {},
              gradientColors: const [Colors.blue, Colors.purple],
            ),
          ),
        ),
      );

      expect(find.text(buttonText), findsOneWidget);
    });

    testWidgets('should apply gradient background', (
      WidgetTester tester,
    ) async {
      const gradientColors = [Colors.blue, Colors.purple];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Test',
              onPressed: () {},
              gradientColors: gradientColors,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      expect(gradient.colors, gradientColors);
      expect(gradient.begin, Alignment.topLeft);
      expect(gradient.end, Alignment.bottomRight);
    });

    testWidgets('should respond to tap when enabled', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Test',
              onPressed: () => tapped = true,
              gradientColors: const [Colors.blue, Colors.purple],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('should not respond to tap when disabled', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Test',
              onPressed: null,
              gradientColors: const [Colors.blue, Colors.purple],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isFalse);
    });

    testWidgets('should apply custom text style', (WidgetTester tester) async {
      const customTextStyle = TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Test',
              onPressed: () {},
              gradientColors: const [Colors.blue, Colors.purple],
              textStyle: customTextStyle,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Test'));
      expect(text.style?.fontSize, customTextStyle.fontSize);
      expect(text.style?.fontWeight, customTextStyle.fontWeight);
    });

    testWidgets('should apply custom border radius', (
      WidgetTester tester,
    ) async {
      const customRadius = BorderRadius.all(Radius.circular(20.0));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Test',
              onPressed: () {},
              gradientColors: const [Colors.blue, Colors.purple],
              borderRadius: customRadius,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.borderRadius, customRadius);
    });

    testWidgets('should expand width when expandWidth is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Test',
              onPressed: () {},
              gradientColors: const [Colors.blue, Colors.purple],
              expandWidth: true,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxWidth, double.infinity);
    });

    testWidgets('should display icon when provided', (
      WidgetTester tester,
    ) async {
      const iconData = Icons.star;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Test',
              onPressed: () {},
              gradientColors: const [Colors.blue, Colors.purple],
              icon: iconData,
            ),
          ),
        ),
      );

      expect(find.byIcon(iconData), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should show loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Test',
              onPressed: () {},
              gradientColors: const [Colors.blue, Colors.purple],
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test'), findsNothing);
    });

    testWidgets('should not respond to tap when loading', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Test',
              onPressed: () => tapped = true,
              gradientColors: const [Colors.blue, Colors.purple],
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isFalse);
    });

    group('GradientButton Constructors', () {
      testWidgets('should create primary button with purple gradient', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButton.primary(text: 'Primary', onPressed: () {}),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.colors, ModernColors.purpleGradient);
      });

      testWidgets('should create large button with large text style', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButton.large(
                text: 'Large',
                onPressed: () {},
                gradientColors: const [Colors.blue, Colors.purple],
              ),
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('Large'));
        expect(text.style?.fontSize, ModernTypography.buttonLarge.fontSize);
      });

      testWidgets('should create small button with small text style', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButton.small(
                text: 'Small',
                onPressed: () {},
                gradientColors: const [Colors.blue, Colors.purple],
              ),
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('Small'));
        expect(text.style?.fontSize, ModernTypography.buttonSmall.fontSize);
      });
    });

    group('GradientButton Variants', () {
      testWidgets('should create difficulty button with correct gradient', (
        WidgetTester tester,
      ) async {
        const difficulty = 'easy';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButtonVariants.forDifficulty(
                text: 'Easy',
                onPressed: () {},
                difficulty: difficulty,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(
          gradient.colors,
          ModernColors.getGradientForDifficulty(difficulty),
        );
      });

      testWidgets('should create success button with green gradient', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButtonVariants.success(
                text: 'Success',
                onPressed: () {},
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.colors, ModernColors.greenGradient);
      });

      testWidgets('should create warning button with yellow gradient', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButtonVariants.warning(
                text: 'Warning',
                onPressed: () {},
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.colors, ModernColors.yellowGradient);
      });

      testWidgets('should create danger button with red gradient', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButtonVariants.danger(
                text: 'Danger',
                onPressed: () {},
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.colors, ModernColors.redGradient);
      });
    });

    group('Accessibility', () {
      testWidgets('should have semantic button properties', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButton(
                text: 'Test Button',
                onPressed: () {},
                gradientColors: const [Colors.blue, Colors.purple],
              ),
            ),
          ),
        );

        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('should use custom semantic label when provided', (
        WidgetTester tester,
      ) async {
        const semanticLabel = 'Custom Button Label';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButton(
                text: 'Test',
                onPressed: () {},
                gradientColors: const [Colors.blue, Colors.purple],
                semanticLabel: semanticLabel,
              ),
            ),
          ),
        );

        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('should indicate disabled state in semantics', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButton(
                text: 'Disabled',
                onPressed: null,
                gradientColors: const [Colors.blue, Colors.purple],
              ),
            ),
          ),
        );

        expect(find.byType(Semantics), findsWidgets);
      });
    });

    group('Visual States', () {
      testWidgets('should have reduced opacity when disabled', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButton(
                text: 'Disabled',
                onPressed: null,
                gradientColors: const [Colors.blue, Colors.purple],
              ),
            ),
          ),
        );

        final opacity = tester.widget<Opacity>(find.byType(Opacity));
        expect(opacity.opacity, 0.6);
      });

      testWidgets('should have no shadows when disabled', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButton(
                text: 'Disabled',
                onPressed: null,
                gradientColors: const [Colors.blue, Colors.purple],
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.boxShadow, ModernShadows.none);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle empty gradient colors list', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButton(
                text: 'Test',
                onPressed: () {},
                gradientColors: const [],
              ),
            ),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('should handle very long text', (WidgetTester tester) async {
        const longText = 'This is a very long button text that might overflow';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButton(
                text: longText,
                onPressed: () {},
                gradientColors: const [Colors.blue, Colors.purple],
              ),
            ),
          ),
        );

        expect(find.text(longText), findsOneWidget);
      });

      testWidgets('should handle custom loading color', (
        WidgetTester tester,
      ) async {
        const customLoadingColor = Colors.red;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButton(
                text: 'Loading',
                onPressed: () {},
                gradientColors: const [Colors.blue, Colors.purple],
                isLoading: true,
                loadingColor: customLoadingColor,
              ),
            ),
          ),
        );

        final progressIndicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        final animation =
            progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
        expect(animation.value, customLoadingColor);
      });
    });
  });
}
