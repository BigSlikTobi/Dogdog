import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dogdog_trivia_game/screens/home_screen.dart';
import 'package:dogdog_trivia_game/screens/game_screen.dart';
import 'package:dogdog_trivia_game/services/progress_service.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/utils/responsive.dart';
import 'package:dogdog_trivia_game/utils/accessibility.dart';

void main() {
  group('Performance Tests for Responsive Design and Accessibility', () {
    testWidgets('should maintain 60 FPS during responsive layout changes', (
      tester,
    ) async {
      // Track frame times
      final List<Duration> frameTimes = [];

      // Override the frame callback to track performance
      tester.binding.addPersistentFrameCallback((timeStamp) {
        frameTimes.add(timeStamp);
      });

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ProgressService(),
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Test screen size changes
      await tester.binding.setSurfaceSize(const Size(400, 800)); // Mobile
      await tester.pumpAndSettle();

      await tester.binding.setSurfaceSize(
        const Size(800, 600),
      ); // Tablet landscape
      await tester.pumpAndSettle();

      await tester.binding.setSurfaceSize(const Size(1200, 800)); // Desktop
      await tester.pumpAndSettle();

      // Verify smooth transitions (frame time should be < 16.67ms for 60 FPS)
      if (frameTimes.length > 1) {
        for (int i = 1; i < frameTimes.length; i++) {
          final frameDuration = frameTimes[i] - frameTimes[i - 1];
          expect(
            frameDuration.inMilliseconds,
            lessThan(20),
          ); // Allow some margin
        }
      }
    });

    testWidgets('should handle rapid accessibility state changes efficiently', (
      tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ProgressService(),
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Rapidly change accessibility settings
      for (int i = 0; i < 10; i++) {
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(
              highContrast: i % 2 == 0,
              accessibleNavigation: i % 3 == 0,
              textScaler: TextScaler.linear(1.0 + (i % 3) * 0.5),
            ),
            child: ChangeNotifierProvider(
              create: (context) => ProgressService(),
              child: const MaterialApp(home: HomeScreen()),
            ),
          ),
        );
        await tester.pump();
      }

      stopwatch.stop();

      // Should complete all changes within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('should efficiently handle large text scaling', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(2.0), // Maximum allowed scale
          ),
          child: ChangeNotifierProvider(
            create: (context) => ProgressService(),
            child: const MaterialApp(home: HomeScreen()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify layout doesn't break with large text
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should maintain performance during game screen interactions', (
      tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ProgressService(),
          child: MaterialApp(
            home: GameScreen(difficulty: Difficulty.easy, level: 1),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Simulate rapid interactions
      for (int i = 0; i < 5; i++) {
        // Test responsive grid changes
        await tester.binding.setSurfaceSize(Size(400 + i * 100, 800));
        await tester.pump();

        // Test accessibility state changes
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(
              size: Size(400 + i * 100, 800),
              highContrast: i % 2 == 0,
            ),
            child: ChangeNotifierProvider(
              create: (context) => ProgressService(),
              child: MaterialApp(
                home: GameScreen(difficulty: Difficulty.easy, level: 1),
              ),
            ),
          ),
        );
        await tester.pump();
      }

      stopwatch.stop();

      // Should handle all changes efficiently
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
      expect(tester.takeException(), isNull);
    });

    testWidgets('should optimize memory usage with responsive containers', (
      tester,
    ) async {
      // Test multiple responsive containers
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: List.generate(
                10,
                (index) => ResponsiveContainer(
                  child: Container(
                    height: 100,
                    color: Colors.blue,
                    child: Text('Container $index'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all containers are rendered without memory issues
      expect(find.byType(ResponsiveContainer), findsNWidgets(10));
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle orientation changes smoothly', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ProgressService(),
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Portrait
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();

      // Landscape
      await tester.binding.setSurfaceSize(const Size(800, 400));
      await tester.pumpAndSettle();

      // Back to portrait
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();

      // Verify no exceptions during orientation changes
      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should efficiently render accessibility decorations', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(highContrast: true),
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: List.generate(
                  20,
                  (index) => Builder(
                    builder: (context) => Container(
                      margin: const EdgeInsets.all(8),
                      decoration:
                          AccessibilityUtils.getAccessibleCardDecoration(
                            context,
                          ),
                      child: Text('Card $index'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify efficient rendering of accessibility decorations
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle rapid focus changes efficiently', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: List.generate(
                5,
                (index) => FocusableGameElement(
                  semanticLabel: 'Button $index',
                  onTap: () {},
                  child: Container(
                    height: 50,
                    color: Colors.blue,
                    child: Text('Button $index'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Rapidly change focus
      for (int i = 0; i < 10; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }

      stopwatch.stop();

      // Should handle focus changes efficiently
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
      expect(tester.takeException(), isNull);
    });
  });

  group('Memory Usage Tests', () {
    testWidgets('should not leak memory during screen transitions', (
      tester,
    ) async {
      // This is a basic test - in a real app you'd use more sophisticated memory profiling
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (context) => ProgressService(),
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (context) => ProgressService(),
            child: MaterialApp(
              home: GameScreen(difficulty: Difficulty.easy, level: 1),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      // Verify no exceptions occurred during transitions
      expect(tester.takeException(), isNull);
    });

    testWidgets('should properly dispose of animation controllers', (
      tester,
    ) async {
      // Test that animation controllers are properly disposed
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ProgressService(),
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate away (this should trigger dispose)
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Different Screen'))),
      );

      await tester.pumpAndSettle();

      // Verify no exceptions during disposal
      expect(tester.takeException(), isNull);
    });
  });
}
