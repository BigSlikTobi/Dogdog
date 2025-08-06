import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/widgets/modern_card.dart';
import 'package:dogdog_trivia_game/design_system/modern_colors.dart';
import 'package:dogdog_trivia_game/design_system/modern_spacing.dart';
import 'package:dogdog_trivia_game/design_system/modern_shadows.dart';

void main() {
  group('ModernCard', () {
    testWidgets('should render child widget', (WidgetTester tester) async {
      const testText = 'Test Content';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ModernCard(child: Text(testText))),
        ),
      );

      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('should apply default styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ModernCard(child: Text('Test'))),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, ModernColors.cardBackground);
      expect(decoration.borderRadius, ModernSpacing.borderRadiusMedium);
      expect(decoration.boxShadow, ModernShadows.card);
    });

    testWidgets('should apply custom background color', (
      WidgetTester tester,
    ) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernCard(backgroundColor: customColor, child: Text('Test')),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, customColor);
    });

    testWidgets('should apply gradient background', (
      WidgetTester tester,
    ) async {
      const gradientColors = [Colors.blue, Colors.purple];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernCard.gradient(
              gradientColors: gradientColors,
              child: Text('Test'),
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

    testWidgets('should apply custom margin', (WidgetTester tester) async {
      const customMargin = EdgeInsets.all(30.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernCard(margin: customMargin, child: Text('Test')),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.margin, customMargin);
    });

    testWidgets('should apply custom border radius', (
      WidgetTester tester,
    ) async {
      const customRadius = BorderRadius.all(Radius.circular(20.0));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernCard(borderRadius: customRadius, child: Text('Test')),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.borderRadius, customRadius);
    });

    testWidgets('should apply custom shadows', (WidgetTester tester) async {
      const customShadows = [
        BoxShadow(color: Colors.red, offset: Offset(5, 5), blurRadius: 10),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernCard(shadows: customShadows, child: Text('Test')),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.boxShadow, customShadows);
    });

    testWidgets('should add border when hasBorder is true', (
      WidgetTester tester,
    ) async {
      const borderColor = Colors.red;
      const borderWidth = 2.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModernCard(
              hasBorder: true,
              borderColor: borderColor,
              borderWidth: borderWidth,
              child: Text('Test'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;

      expect(border.top.color, borderColor);
      expect(border.top.width, borderWidth);
    });

    group('Interactive ModernCard', () {
      testWidgets('should respond to tap when interactive', (
        WidgetTester tester,
      ) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ModernCard.interactive(
                onTap: () => tapped = true,
                child: const Text('Test'),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(GestureDetector), warnIfMissed: false);
        expect(tapped, isTrue);
      });

      testWidgets('should have GestureDetector when interactive', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ModernCard.interactive(
                onTap: () {},
                child: const Text('Test'),
              ),
            ),
          ),
        );

        expect(find.byType(GestureDetector), findsOneWidget);
      });

      testWidgets('should not be interactive when interactive is false', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ModernCard(interactive: false, child: Text('Test')),
            ),
          ),
        );

        expect(find.byType(GestureDetector), findsNothing);
      });
    });

    group('ModernCard Variants', () {
      testWidgets('should create difficulty card with correct gradient', (
        WidgetTester tester,
      ) async {
        const difficulty = 'easy';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ModernCardVariants.forDifficulty(
                difficulty: difficulty,
                child: const Text('Test'),
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

      testWidgets('should create elevated card with large shadows', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ModernCardVariants.elevated(child: const Text('Test')),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.boxShadow, ModernShadows.large);
      });

      testWidgets(
        'should create subtle card with light background and subtle shadows',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ModernCardVariants.subtle(child: const Text('Test')),
              ),
            ),
          );

          final container = tester.widget<Container>(
            find.byType(Container).first,
          );
          final decoration = container.decoration as BoxDecoration;

          expect(decoration.color, ModernColors.surfaceLight);
          expect(decoration.boxShadow, ModernShadows.subtle);
        },
      );
    });

    group('Accessibility', () {
      testWidgets('should add semantic widget when label provided', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ModernCard(semanticLabel: 'Test Card', child: Text('Test')),
            ),
          ),
        );

        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('should be focusable when interactive', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ModernCard.interactive(
                onTap: () {},
                child: const Text('Interactive Card'),
              ),
            ),
          ),
        );

        expect(find.byType(GestureDetector), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle empty gradient colors list', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ModernCard.gradient(
                gradientColors: [],
                child: Text('Test'),
              ),
            ),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('should handle null onTap with interactive true', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ModernCard(
                interactive: true,
                onTap: null,
                child: Text('Test'),
              ),
            ),
          ),
        );

        expect(find.byType(GestureDetector), findsNothing);
      });
    });
  });
}
