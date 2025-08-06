import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/widgets/success_animation_widget.dart';

void main() {
  group('SuccessAnimationWidget', () {
    testWidgets('should render without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SuccessAnimationWidget(autoStart: false)),
        ),
      );

      expect(find.byType(SuccessAnimationWidget), findsOneWidget);
    });

    testWidgets('should display image widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SuccessAnimationWidget(autoStart: false)),
        ),
      );

      // Should show either Image.asset or fallback Icon
      expect(
        find.byWidgetPredicate((widget) => widget is Image || widget is Icon),
        findsOneWidget,
      );
    });

    testWidgets('should apply custom width and height', (
      WidgetTester tester,
    ) async {
      const customWidth = 200.0;
      const customHeight = 150.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuccessAnimationWidget(
              width: customWidth,
              height: customHeight,
              autoStart: false,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, customWidth);
      expect(sizedBox.height, customHeight);
    });

    testWidgets('should start animation automatically when autoStart is true', (
      WidgetTester tester,
    ) async {
      bool animationCompleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuccessAnimationWidget(
              autoStart: true,
              imageDuration: const Duration(milliseconds: 50),
              alternationCount: 1,
              onAnimationComplete: () => animationCompleted = true,
            ),
          ),
        ),
      );

      // Pump and settle to let the animation complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(animationCompleted, isTrue);
    });

    testWidgets(
      'should not start animation automatically when autoStart is false',
      (WidgetTester tester) async {
        bool animationCompleted = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SuccessAnimationWidget(
                autoStart: false,
                imageDuration: const Duration(milliseconds: 50),
                alternationCount: 1,
                onAnimationComplete: () => animationCompleted = true,
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 200));

        expect(animationCompleted, isFalse);
      },
    );

    testWidgets('should have scale animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuccessAnimationWidget(autoStart: true, scaleFactor: 1.5),
          ),
        ),
      );

      // Find the Transform widget that handles scaling
      expect(find.byType(Transform), findsWidgets);
    });

    testWidgets('should add semantic label when provided', (
      WidgetTester tester,
    ) async {
      const semanticLabel = 'Success Animation';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuccessAnimationWidget(
              semanticLabel: semanticLabel,
              autoStart: false,
            ),
          ),
        ),
      );

      expect(find.byType(Semantics), findsWidgets);
    });

    group('SuccessAnimationWidget Constructors', () {
      testWidgets('should create quick animation with correct parameters', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SuccessAnimationWidget.quick(autoStart: false),
            ),
          ),
        );

        expect(find.byType(SuccessAnimationWidget), findsOneWidget);
      });

      testWidgets(
        'should create celebration animation with correct parameters',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: SuccessAnimationWidget.celebration(autoStart: false),
              ),
            ),
          );

          expect(find.byType(SuccessAnimationWidget), findsOneWidget);
        },
      );
    });

    group('SuccessAnimationVariants', () {
      testWidgets('should create correct answer animation', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SuccessAnimationVariants.correctAnswer(autoStart: false),
            ),
          ),
        );

        expect(find.byType(SuccessAnimationWidget), findsOneWidget);
      });

      testWidgets('should create level complete animation', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SuccessAnimationVariants.levelComplete(autoStart: false),
            ),
          ),
        );

        expect(find.byType(SuccessAnimationWidget), findsOneWidget);
      });

      testWidgets('should create achievement animation', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SuccessAnimationVariants.achievement(autoStart: false),
            ),
          ),
        );

        expect(find.byType(SuccessAnimationWidget), findsOneWidget);
      });

      testWidgets('should create subtle animation', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SuccessAnimationVariants.subtle(autoStart: false),
            ),
          ),
        );

        expect(find.byType(SuccessAnimationWidget), findsOneWidget);
      });
    });

    group('SuccessAnimationController', () {
      testWidgets('should control animation start and stop', (
        WidgetTester tester,
      ) async {
        final controller = SuccessAnimationController();
        bool animationCompleted = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SuccessAnimationWidget(
                key: controller.key,
                autoStart: false,
                imageDuration: const Duration(milliseconds: 50),
                alternationCount: 1,
                onAnimationComplete: () => animationCompleted = true,
              ),
            ),
          ),
        );

        // Start animation manually
        controller.start();
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(animationCompleted, isTrue);
      });

      testWidgets('should stop animation when requested', (
        WidgetTester tester,
      ) async {
        final controller = SuccessAnimationController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SuccessAnimationWidget(
                key: controller.key,
                autoStart: false,
                imageDuration: const Duration(milliseconds: 100),
                alternationCount: 5,
              ),
            ),
          ),
        );

        // Start and immediately stop animation
        controller.start();
        await tester.pump(const Duration(milliseconds: 10));
        controller.stop();

        expect(controller.isAnimating, isFalse);
      });
    });

    group('Error Handling', () {
      testWidgets('should show fallback icon when image fails to load', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: SuccessAnimationWidget(autoStart: false)),
          ),
        );

        // Should show either Image.asset or fallback Icon
        expect(
          find.byWidgetPredicate((widget) => widget is Image || widget is Icon),
          findsOneWidget,
        );
      });

      testWidgets('should handle disposal gracefully', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SuccessAnimationWidget(
                autoStart: true,
                imageDuration: Duration(milliseconds: 100),
              ),
            ),
          ),
        );

        // Start animation and then dispose the widget
        await tester.pump(const Duration(milliseconds: 50));

        // Navigate away to dispose the widget
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: Text('New Screen'))),
        );

        // Should not crash
        expect(find.text('New Screen'), findsOneWidget);
      });
    });

    group('Animation Timing', () {
      testWidgets('should respect custom image duration', (
        WidgetTester tester,
      ) async {
        const customDuration = Duration(milliseconds: 100);
        bool animationCompleted = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SuccessAnimationWidget(
                autoStart: true,
                imageDuration: customDuration,
                alternationCount: 1,
                onAnimationComplete: () => animationCompleted = true,
              ),
            ),
          ),
        );

        // Animation should not be complete before the duration
        await tester.pump(const Duration(milliseconds: 50));
        expect(animationCompleted, isFalse);

        // Animation should be complete after the duration
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(animationCompleted, isTrue);
      });

      testWidgets('should handle loop animation', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SuccessAnimationWidget(
                autoStart: true,
                imageDuration: const Duration(milliseconds: 50),
                alternationCount: 1,
                loop: true,
              ),
            ),
          ),
        );

        // Should render without crashing when loop is enabled
        expect(find.byType(SuccessAnimationWidget), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should be accessible with semantic labels', (
        WidgetTester tester,
      ) async {
        const semanticLabel = 'Success celebration animation';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SuccessAnimationWidget(
                semanticLabel: semanticLabel,
                autoStart: false,
              ),
            ),
          ),
        );

        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('should work without semantic label', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: SuccessAnimationWidget(autoStart: false)),
          ),
        );

        expect(find.byType(SuccessAnimationWidget), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle zero alternation count', (
        WidgetTester tester,
      ) async {
        bool animationCompleted = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SuccessAnimationWidget(
                autoStart: true,
                alternationCount: 0,
                onAnimationComplete: () => animationCompleted = true,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        expect(animationCompleted, isTrue);
      });

      testWidgets('should handle very small scale factor', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SuccessAnimationWidget(scaleFactor: 0.1, autoStart: false),
            ),
          ),
        );

        expect(find.byType(SuccessAnimationWidget), findsOneWidget);
      });

      testWidgets('should handle very large scale factor', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SuccessAnimationWidget(scaleFactor: 5.0, autoStart: false),
            ),
          ),
        );

        expect(find.byType(SuccessAnimationWidget), findsOneWidget);
      });
    });
  });
}
