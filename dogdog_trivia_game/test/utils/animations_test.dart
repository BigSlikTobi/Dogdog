import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/utils/animations.dart';

void main() {
  group('AppAnimations', () {
    late AnimationController controller;

    setUp(() {
      controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: const TestVSync(),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('slideFromBottom creates correct slide transition', (
      tester,
    ) async {
      const testWidget = Text('Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppAnimations.slideFromBottom(
              child: testWidget,
              animation: controller,
            ),
          ),
        ),
      );

      // Initially should be off-screen (bottom)
      expect(find.byWidget(testWidget), findsOneWidget);

      // Start animation
      controller.forward();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Should be animating
      expect(controller.value, greaterThan(0.0));
      expect(controller.value, lessThan(1.0));

      // Complete animation
      await tester.pump(const Duration(milliseconds: 300));
      expect(controller.value, equals(1.0));
    });

    testWidgets('slideFromRight creates correct slide transition', (
      tester,
    ) async {
      const testWidget = Text('Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppAnimations.slideFromRight(
              child: testWidget,
              animation: controller,
            ),
          ),
        ),
      );

      expect(find.byWidget(testWidget), findsOneWidget);

      controller.forward();
      await tester.pumpAndSettle();
      expect(controller.value, equals(1.0));
    });

    testWidgets('fadeIn creates correct fade transition', (tester) async {
      const testWidget = Text('Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppAnimations.fadeIn(
              child: testWidget,
              animation: controller,
            ),
          ),
        ),
      );

      expect(find.byWidget(testWidget), findsOneWidget);

      controller.forward();
      await tester.pumpAndSettle();
      expect(controller.value, equals(1.0));
    });

    testWidgets('scaleWithBounce creates correct scale transition', (
      tester,
    ) async {
      const testWidget = Text('Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppAnimations.scaleWithBounce(
              child: testWidget,
              animation: controller,
            ),
          ),
        ),
      );

      expect(find.byWidget(testWidget), findsOneWidget);

      controller.forward();
      await tester.pumpAndSettle();
      expect(controller.value, equals(1.0));
    });

    testWidgets('fadeAndScale combines fade and scale effects', (tester) async {
      const testWidget = Text('Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppAnimations.fadeAndScale(
              child: testWidget,
              animation: controller,
            ),
          ),
        ),
      );

      expect(find.byWidget(testWidget), findsOneWidget);

      controller.forward();
      await tester.pumpAndSettle();
      expect(controller.value, equals(1.0));
    });

    testWidgets('celebration animation completes successfully', (tester) async {
      const testWidget = Text('Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppAnimations.celebration(
              child: testWidget,
              animation: controller,
            ),
          ),
        ),
      );

      expect(find.byWidget(testWidget), findsOneWidget);

      controller.forward();
      await tester.pumpAndSettle();
      expect(controller.value, equals(1.0));
    });
  });

  group('Custom Page Routes', () {
    testWidgets('SlidePageRoute performs slide transition', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: const Scaffold(body: Text('Home'))),
      );

      expect(find.text('Home'), findsOneWidget);

      // Navigate with slide transition
      await tester.tap(find.text('Home'));
      await tester.pump();

      // Push new route
      Navigator.of(tester.element(find.text('Home'))).push(
        SlidePageRoute(
          child: const Scaffold(body: Text('New Page')),
          direction: SlideDirection.rightToLeft,
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('New Page'), findsOneWidget);
    });

    testWidgets('FadePageRoute performs fade transition', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: const Scaffold(body: Text('Home'))),
      );

      expect(find.text('Home'), findsOneWidget);

      // Navigate with fade transition
      Navigator.of(
        tester.element(find.text('Home')),
      ).push(FadePageRoute(child: const Scaffold(body: Text('New Page'))));

      await tester.pumpAndSettle();
      expect(find.text('New Page'), findsOneWidget);
    });

    testWidgets('ScalePageRoute performs scale transition', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: const Scaffold(body: Text('Home'))),
      );

      expect(find.text('Home'), findsOneWidget);

      // Navigate with scale transition
      Navigator.of(
        tester.element(find.text('Home')),
      ).push(ScalePageRoute(child: const Scaffold(body: Text('New Page'))));

      await tester.pumpAndSettle();
      expect(find.text('New Page'), findsOneWidget);
    });
  });

  group('Animation Performance', () {
    testWidgets('animations complete within expected duration', (tester) async {
      final performanceController = AnimationController(
        duration: AppAnimations.normalDuration,
        vsync: const TestVSync(),
      );

      const testWidget = Text('Performance Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppAnimations.fadeAndScale(
              child: testWidget,
              animation: performanceController,
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();

      performanceController.forward();
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Animation should complete within reasonable time (allowing some buffer)
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
      expect(performanceController.value, equals(1.0));

      performanceController.dispose();
    });

    testWidgets('multiple animations can run simultaneously', (tester) async {
      final controller1 = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: const TestVSync(),
      );
      final controller2 = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: const TestVSync(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppAnimations.fadeIn(
                  child: const Text('Animation 1'),
                  animation: controller1,
                ),
                AppAnimations.scaleWithBounce(
                  child: const Text('Animation 2'),
                  animation: controller2,
                ),
              ],
            ),
          ),
        ),
      );

      // Start both animations
      controller1.forward();
      controller2.forward();

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Both should be animating (controller1 should be done, controller2 still going)
      expect(controller1.value, greaterThan(0.0));
      expect(controller2.value, greaterThan(0.0));

      await tester.pumpAndSettle();

      // Both should complete
      expect(controller1.value, equals(1.0));
      expect(controller2.value, equals(1.0));

      controller1.dispose();
      controller2.dispose();
    });
  });
}
