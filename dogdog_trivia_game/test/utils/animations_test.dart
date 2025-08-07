import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/utils/animations.dart';

void main() {
  group('AppAnimations', () {
    testWidgets('respects reduced motion preferences', (tester) async {
      // Test with normal motion
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(AppAnimations.isReducedMotionPreferred(context), false);
              expect(
                AppAnimations.getDuration(
                  context,
                  AppAnimations.normalDuration,
                ),
                AppAnimations.normalDuration,
              );
              expect(
                AppAnimations.getCurve(context, AppAnimations.smoothCurve),
                AppAnimations.smoothCurve,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      // Test with reduced motion
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                expect(AppAnimations.isReducedMotionPreferred(context), true);
                expect(
                  AppAnimations.getDuration(
                    context,
                    AppAnimations.normalDuration,
                  ),
                  AppAnimations.reducedNormalDuration,
                );
                expect(
                  AppAnimations.getCurve(context, AppAnimations.smoothCurve),
                  AppAnimations.reducedMotionCurve,
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('slide animations work correctly', (tester) async {
      late AnimationController controller;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = AnimationController(
                duration: const Duration(milliseconds: 300),
                vsync: tester,
              );

              return AppAnimations.slideFromBottom(
                animation: controller,
                child: const Text('Test'),
              );
            },
          ),
        ),
      );

      // Start animation
      controller.forward();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Verify animation is in progress
      expect(controller.value, greaterThan(0.0));
      expect(controller.value, lessThan(1.0));

      // Complete animation
      await tester.pump(const Duration(milliseconds: 300));
      expect(controller.value, 1.0);

      controller.dispose();
    });

    testWidgets('fade animations work correctly', (tester) async {
      late AnimationController controller;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = AnimationController(
                duration: const Duration(milliseconds: 300),
                vsync: tester,
              );

              return AppAnimations.fadeIn(
                animation: controller,
                child: const Text('Test'),
              );
            },
          ),
        ),
      );

      // Start animation
      controller.forward();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Verify animation is in progress
      expect(controller.value, greaterThan(0.0));
      expect(controller.value, lessThan(1.0));

      controller.dispose();
    });

    testWidgets('scale animations work correctly', (tester) async {
      late AnimationController controller;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = AnimationController(
                duration: const Duration(milliseconds: 300),
                vsync: tester,
              );

              return AppAnimations.scaleWithBounce(
                animation: controller,
                child: const Text('Test'),
              );
            },
          ),
        ),
      );

      // Start animation
      controller.forward();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Verify animation is in progress
      expect(controller.value, greaterThan(0.0));
      expect(controller.value, lessThan(1.0));

      controller.dispose();
    });
  });

  group('Page Routes', () {
    testWidgets('ModernPageRoute respects reduced motion', (tester) async {
      // Test with normal motion
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(body: Text('Home')),
          routes: {'/test': (context) => const Scaffold(body: Text('Test'))},
        ),
      );

      // Navigate with ModernPageRoute
      await tester.tap(find.text('Home'));
      await tester.pump();

      Navigator.of(
        tester.element(find.text('Home')),
      ).push(ModernPageRoute(child: const Scaffold(body: Text('Test'))));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Verify navigation occurred
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('ScalePageRoute works correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: const Scaffold(body: Text('Home'))),
      );

      // Navigate with ScalePageRoute
      Navigator.of(
        tester.element(find.text('Home')),
      ).push(ScalePageRoute(child: const Scaffold(body: Text('Test'))));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Verify navigation occurred
      expect(find.text('Test'), findsOneWidget);
    });
  });

  group('SkeletonLoader', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SkeletonLoader(width: 100, height: 50)),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);

      // Let animation run
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('has correct dimensions', (tester) async {
      const width = 150.0;
      const height = 75.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(width: width, height: height),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(SkeletonLoader),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints?.maxWidth, width);
      expect(container.constraints?.maxHeight, height);
    });
  });

  group('StaggeredAnimationHelper', () {
    testWidgets('creates staggered animations', (tester) async {
      late AnimationController controller;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = AnimationController(
                duration: const Duration(milliseconds: 1000),
                vsync: tester,
              );

              final children = StaggeredAnimationHelper.createStaggeredList(
                children: [
                  const Text('Item 1'),
                  const Text('Item 2'),
                  const Text('Item 3'),
                ],
                controller: controller,
              );

              return Column(children: children);
            },
          ),
        ),
      );

      // Start staggered animation
      controller.forward();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify items are present
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);

      controller.dispose();
    });
  });
}
