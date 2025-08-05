import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/screens/game_screen.dart';
import 'package:dogdog_trivia_game/screens/home_screen.dart';
import 'package:dogdog_trivia_game/widgets/animated_button.dart';
import 'package:dogdog_trivia_game/widgets/loading_animation.dart';
import 'package:dogdog_trivia_game/services/progress_service.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('Comprehensive Performance Tests', () {
    testWidgets('60 FPS animation performance test', (
      WidgetTester tester,
    ) async {
      // Track frame times during animation
      final List<Duration> frameTimes = [];

      // Override frame callback to measure performance
      tester.binding.addPersistentFrameCallback((timeStamp) {
        frameTimes.add(timeStamp);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedButton(
              onPressed: () {},
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      // Trigger animation by tapping button
      await tester.tap(find.byType(AnimatedButton));

      // Pump frames for animation duration (simulate 1 second at 60 FPS)
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16)); // ~60 FPS
      }

      // Verify frame rate consistency
      if (frameTimes.length > 10) {
        int smoothFrames = 0;
        for (int i = 1; i < frameTimes.length; i++) {
          final frameDuration = frameTimes[i] - frameTimes[i - 1];
          if (frameDuration.inMilliseconds <= 20) {
            // 20ms threshold for 50+ FPS
            smoothFrames++;
          }
        }

        // At least 80% of frames should be smooth
        final smoothPercentage = smoothFrames / (frameTimes.length - 1);
        expect(smoothPercentage, greaterThan(0.8));
      }
    });

    testWidgets('Loading animation performance', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingAnimation())),
      );

      // Run animation for several cycles (2 seconds worth)
      for (int i = 0; i < 120; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      stopwatch.stop();

      // Verify animation runs smoothly without blocking
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(2500),
      ); // 2.5 seconds for 120 frames
    });

    testWidgets('Memory usage during extended game session', (
      WidgetTester tester,
    ) async {
      // Simulate a complete game session with multiple screens
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GameController()),
            ChangeNotifierProvider(create: (_) => ProgressService()),
          ],
          child: MaterialApp(
            home: GameScreen(difficulty: Difficulty.easy, level: 1),
          ),
        ),
      );

      // Initial memory baseline
      await tester.pump();
      final initialWidgetCount = tester.allWidgets.length;

      // Simulate multiple question cycles
      for (int i = 0; i < 50; i++) {
        // Simulate question display and answer
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Trigger state changes to simulate gameplay
        final gameController = Provider.of<GameController>(
          tester.element(find.byType(GameScreen)),
          listen: false,
        );

        // Simulate answer selection and progression
        gameController.processAnswer(i % 4);
        await tester.pump();

        if (i % 10 == 0) {
          // Periodically trigger more intensive operations
          await tester.pumpAndSettle();
        }
      }

      // Verify memory usage hasn't grown excessively
      final finalWidgetCount = tester.allWidgets.length;
      expect(
        finalWidgetCount,
        lessThan(initialWidgetCount * 3),
      ); // Allow some growth but not excessive
    });

    testWidgets('Screen transition performance', (WidgetTester tester) async {
      final transitionTimes = <Duration>[];

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GameController()),
            ChangeNotifierProvider(create: (_) => ProgressService()),
          ],
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/game': (context) =>
                  GameScreen(difficulty: Difficulty.easy, level: 1),
            },
          ),
        ),
      );

      // Measure navigation performance
      for (int i = 0; i < 10; i++) {
        final stopwatch = Stopwatch()..start();

        // Navigate to game screen
        Navigator.of(
          tester.element(find.byType(HomeScreen)),
        ).pushNamed('/game');
        await tester.pumpAndSettle();

        stopwatch.stop();
        transitionTimes.add(stopwatch.elapsed);

        // Navigate back
        Navigator.of(tester.element(find.byType(GameScreen))).pop();
        await tester.pumpAndSettle();
      }

      // Verify consistent transition performance
      final averageTransitionTime =
          transitionTimes
              .map((time) => time.inMilliseconds)
              .reduce((a, b) => a + b) /
          transitionTimes.length;

      expect(
        averageTransitionTime,
        lessThan(300),
      ); // 300ms threshold for smooth transitions
    });

    testWidgets('Large widget tree rendering performance', (
      WidgetTester tester,
    ) async {
      // Test performance with large number of widgets
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  500,
                  (index) => Card(
                    child: ListTile(
                      title: Text('Item $index'),
                      subtitle: Text('Description for item $index'),
                      leading: CircleAvatar(child: Text('$index')),
                      trailing: const Icon(Icons.arrow_forward),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Scroll through the list
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -10000),
      );
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Verify scrolling performance
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(2000),
      ); // 2 second threshold
    });

    testWidgets('Animation cleanup and disposal test', (
      WidgetTester tester,
    ) async {
      // Test that animations are properly disposed
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: List.generate(20, (index) {
                    return AnimatedButton(
                      onPressed: () {},
                      child: Text('Button $index'),
                    );
                  }),
                ),
              );
            },
          ),
        ),
      );

      // Trigger animations
      for (int i = 0; i < 20; i++) {
        await tester.tap(find.text('Button $i'));
        await tester.pump();
      }

      // Let animations run
      await tester.pump(const Duration(milliseconds: 500));

      // Remove widgets by replacing with empty scaffold
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      // Verify no animation controllers are left running
      expect(find.byType(AnimatedButton), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('CPU usage during intensive game operations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GameController()),
            ChangeNotifierProvider(create: (_) => ProgressService()),
          ],
          child: MaterialApp(
            home: GameScreen(difficulty: Difficulty.easy, level: 1),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Simulate intensive game operations
      final gameController = Provider.of<GameController>(
        tester.element(find.byType(GameScreen)),
        listen: false,
      );

      // Rapid state changes and calculations
      for (int i = 0; i < 200; i++) {
        gameController.processAnswer(i % 4);
        if (i % 10 == 0) {
          gameController.nextQuestion();
        }
        await tester.pump();
      }

      stopwatch.stop();

      // Verify operations complete in reasonable time
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(3000),
      ); // 3 second threshold
    });

    testWidgets('Memory leak detection over multiple cycles', (
      WidgetTester tester,
    ) async {
      // Track widget creation and disposal over multiple cycles
      final List<int> widgetCounts = [];

      // Create and destroy widgets multiple times
      for (int cycle = 0; cycle < 15; cycle++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: List.generate(100, (index) {
                  return Container(
                    key: ValueKey('container_${cycle}_$index'),
                    width: 50,
                    height: 50,
                    color: Colors.blue,
                    child: Text('$index'),
                  );
                }),
              ),
            ),
          ),
        );

        await tester.pump();
        widgetCounts.add(tester.allWidgets.length);

        // Clear widgets
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        await tester.pump();
      }

      // Verify no excessive widget accumulation
      expect(
        tester.allWidgets.length,
        lessThan(200),
      ); // Should be minimal after cleanup

      // Check that widget counts don't grow continuously
      if (widgetCounts.length > 5) {
        final firstHalf = widgetCounts.take(widgetCounts.length ~/ 2).toList();
        final secondHalf = widgetCounts.skip(widgetCounts.length ~/ 2).toList();

        final firstAverage =
            firstHalf.reduce((a, b) => a + b) / firstHalf.length;
        final secondAverage =
            secondHalf.reduce((a, b) => a + b) / secondHalf.length;

        // Second half shouldn't be significantly larger (indicating memory leaks)
        expect(secondAverage, lessThan(firstAverage * 1.5));
      }
    });

    testWidgets('Responsive layout performance under size changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GameController()),
            ChangeNotifierProvider(create: (_) => ProgressService()),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Rapidly change screen sizes to test responsive performance
      final sizes = [
        const Size(320, 568), // iPhone SE
        const Size(375, 667), // iPhone 8
        const Size(414, 896), // iPhone 11
        const Size(768, 1024), // iPad
        const Size(1024, 768), // iPad landscape
        const Size(1200, 800), // Desktop
      ];

      for (final size in sizes) {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpAndSettle();
      }

      stopwatch.stop();

      // Should handle all size changes efficiently
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Animation performance under stress', (
      WidgetTester tester,
    ) async {
      // Test multiple simultaneous animations
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemCount: 50,
              itemBuilder: (context, index) {
                return AnimatedButton(onPressed: () {}, child: Text('$index'));
              },
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Trigger multiple animations simultaneously
      for (int i = 0; i < 20; i++) {
        await tester.tap(find.text('$i'));
      }

      // Let animations run
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      stopwatch.stop();

      // Should handle multiple animations without significant performance degradation
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      expect(tester.takeException(), isNull);
    });
  });

  group('Cross-Platform Performance Tests', () {
    testWidgets('Platform-specific widget performance', (
      WidgetTester tester,
    ) async {
      // Test performance with platform-specific widgets
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // Material Design components
                const Card(child: ListTile(title: Text('Material Card'))),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Material Button'),
                ),
                const CircularProgressIndicator(),

                // Custom game widgets
                AnimatedButton(
                  onPressed: () {},
                  child: const Text('Game Button'),
                ),
                const LoadingAnimation(),
              ],
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Interact with widgets
      await tester.tap(find.text('Material Button'));
      await tester.tap(find.text('Game Button'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should render and interact smoothly
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Text rendering performance with different scales', (
      WidgetTester tester,
    ) async {
      final textScales = [0.8, 1.0, 1.2, 1.5, 2.0];

      for (final scale in textScales) {
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: List.generate(
                    50,
                    (index) => Text('Text item $index with scale $scale'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify no exceptions with different text scales
        expect(tester.takeException(), isNull);
      }
    });
  });
}
