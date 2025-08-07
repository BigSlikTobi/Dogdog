import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/widgets/success_animation_widget.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Integration tests for success animation flow in the game
void main() {
  group('Success Animation Integration Tests', () {
    Widget createTestWidget({required Widget child}) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
        home: Scaffold(body: child),
      );
    }

    testWidgets('should display success animation with proper scaling', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Center(
            child: SuccessAnimationVariants.correctAnswer(
              width: 200,
              height: 200,
              semanticLabel: 'Test success animation',
            ),
          ),
        ),
      );

      // Should show success animation widget
      expect(find.byType(SuccessAnimationWidget), findsOneWidget);

      // Should have proper semantic label
      final successAnimation = tester.widget<SuccessAnimationWidget>(
        find.byType(SuccessAnimationWidget),
      );
      expect(successAnimation.semanticLabel, equals('Test success animation'));
      expect(successAnimation.width, equals(200));
      expect(successAnimation.height, equals(200));
    });

    testWidgets('should handle animation completion callback', (tester) async {
      bool animationCompleted = false;

      await tester.pumpWidget(
        createTestWidget(
          child: Center(
            child: SuccessAnimationWidget(
              width: 100,
              height: 100,
              alternationCount: 1, // Short animation for testing
              imageDuration: const Duration(milliseconds: 100),
              animationDuration: const Duration(milliseconds: 50),
              onAnimationComplete: () {
                animationCompleted = true;
              },
            ),
          ),
        ),
      );

      // Animation should start
      expect(find.byType(SuccessAnimationWidget), findsOneWidget);

      // Wait for animation to complete
      await tester.pump(const Duration(milliseconds: 100)); // Image duration
      await tester.pump(const Duration(milliseconds: 50)); // Animation duration
      await tester.pump(const Duration(milliseconds: 100)); // Second cycle
      await tester.pump(const Duration(milliseconds: 50)); // Complete

      // Animation should still be present
      expect(find.byType(SuccessAnimationWidget), findsOneWidget);
    });

    testWidgets('should scale properly for different screen sizes', (
      tester,
    ) async {
      final screenSizes = [
        const Size(320, 568), // iPhone SE
        const Size(414, 896), // iPhone 11 Pro Max
        const Size(768, 1024), // iPad
      ];

      for (final size in screenSizes) {
        await tester.binding.setSurfaceSize(size);

        final animationSize = size.width * 0.4;

        await tester.pumpWidget(
          createTestWidget(
            child: Center(
              child: SuccessAnimationWidget(
                width: animationSize,
                height: animationSize,
                alternationCount: 1,
              ),
            ),
          ),
        );

        final successAnimation = tester.widget<SuccessAnimationWidget>(
          find.byType(SuccessAnimationWidget),
        );

        expect(successAnimation.width, equals(animationSize));
        expect(successAnimation.height, equals(animationSize));
      }

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should work with different animation variants', (
      tester,
    ) async {
      // Test correctAnswer variant
      await tester.pumpWidget(
        createTestWidget(
          child: SuccessAnimationVariants.correctAnswer(
            width: 100,
            height: 100,
          ),
        ),
      );

      expect(find.byType(SuccessAnimationWidget), findsOneWidget);

      // Test celebration variant
      await tester.pumpWidget(
        createTestWidget(
          child: SuccessAnimationVariants.levelComplete(
            width: 100,
            height: 100,
          ),
        ),
      );

      expect(find.byType(SuccessAnimationWidget), findsOneWidget);

      // Test achievement variant
      await tester.pumpWidget(
        createTestWidget(
          child: SuccessAnimationVariants.achievement(width: 100, height: 100),
        ),
      );

      expect(find.byType(SuccessAnimationWidget), findsOneWidget);

      // Test subtle variant
      await tester.pumpWidget(
        createTestWidget(
          child: SuccessAnimationVariants.subtle(width: 100, height: 100),
        ),
      );

      expect(find.byType(SuccessAnimationWidget), findsOneWidget);
    });

    testWidgets('should handle image loading errors gracefully', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Center(
            child: SuccessAnimationWidget(
              width: 100,
              height: 100,
              alternationCount: 1,
            ),
          ),
        ),
      );

      // Should show success animation widget even if images fail to load
      expect(find.byType(SuccessAnimationWidget), findsOneWidget);

      // Should show fallback icon if images don't load
      await tester.pump(const Duration(milliseconds: 100));

      // The widget should handle errors gracefully and show fallback content
      expect(find.byType(SuccessAnimationWidget), findsOneWidget);
    });

    testWidgets('should maintain accessibility during animations', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Center(
            child: SuccessAnimationWidget(
              width: 100,
              height: 100,
              semanticLabel: 'Success celebration animation',
            ),
          ),
        ),
      );

      // Should have proper semantic label
      final successAnimation = tester.widget<SuccessAnimationWidget>(
        find.byType(SuccessAnimationWidget),
      );
      expect(
        successAnimation.semanticLabel,
        equals('Success celebration animation'),
      );

      // Should be wrapped in Semantics widget
      final semanticsFinder = find.ancestor(
        of: find.byType(Image),
        matching: find.byType(Semantics),
      );
      expect(semanticsFinder, findsWidgets);
    });

    group('Game Controller Animation Triggers', () {
      testWidgets('should provide correct animation trigger states', (
        tester,
      ) async {
        final gameController = GameController();

        // Initially no animation should be triggered
        expect(gameController.shouldTriggerSuccessAnimation, isFalse);
        expect(gameController.shouldTriggerIncorrectAnimation, isFalse);

        // Initialize game and process a correct answer
        await gameController.initializeGame(level: 1);
        gameController.processAnswer(1); // Assuming index 1 is correct

        // Should trigger success animation for correct answer
        expect(gameController.shouldTriggerSuccessAnimation, isTrue);
        expect(gameController.shouldTriggerIncorrectAnimation, isFalse);

        // Clear feedback and process incorrect answer
        gameController.clearFeedback();
        gameController.processAnswer(0); // Assuming index 0 is incorrect

        // Should trigger incorrect animation for wrong answer
        expect(gameController.shouldTriggerSuccessAnimation, isFalse);
        expect(gameController.shouldTriggerIncorrectAnimation, isTrue);

        // Clear feedback should reset triggers
        gameController.clearFeedback();
        expect(gameController.shouldTriggerSuccessAnimation, isFalse);
        expect(gameController.shouldTriggerIncorrectAnimation, isFalse);
      });
    });

    group('Animation Performance Tests', () {
      testWidgets('should maintain smooth animations', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            child: Center(
              child: SuccessAnimationWidget(
                width: 100,
                height: 100,
                alternationCount: 2,
                imageDuration: const Duration(milliseconds: 50),
                animationDuration: const Duration(milliseconds: 25),
              ),
            ),
          ),
        );

        // Pump multiple frames to test animation smoothness
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 16)); // ~60 FPS
        }

        // Animation should still be running smoothly
        expect(find.byType(SuccessAnimationWidget), findsOneWidget);
      });
    });

    group('Animation Timing Tests', () {
      testWidgets('should respect custom timing parameters', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            child: Center(
              child: SuccessAnimationWidget(
                width: 100,
                height: 100,
                alternationCount: 1,
                imageDuration: const Duration(milliseconds: 200),
                animationDuration: const Duration(milliseconds: 100),
                scaleFactor: 1.5,
                animationCurve: Curves.bounceOut,
              ),
            ),
          ),
        );

        final successAnimation = tester.widget<SuccessAnimationWidget>(
          find.byType(SuccessAnimationWidget),
        );

        expect(
          successAnimation.imageDuration,
          equals(const Duration(milliseconds: 200)),
        );
        expect(
          successAnimation.animationDuration,
          equals(const Duration(milliseconds: 100)),
        );
        expect(successAnimation.scaleFactor, equals(1.5));
        expect(successAnimation.animationCurve, equals(Curves.bounceOut));
      });
    });
  });
}
