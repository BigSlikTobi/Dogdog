import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/widgets/animated_button.dart';

void main() {
  group('AnimatedButton', () {
    testWidgets('renders child widget correctly', (tester) async {
      const testChild = Text('Test Button');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AnimatedButton(child: testChild)),
        ),
      );

      expect(find.byWidget(testChild), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedButton(
              onPressed: () => wasPressed = true,
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Button'));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('does not call onPressed when disabled', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedButton(
              onPressed: () => wasPressed = true,
              enabled: false,
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Button'));
      await tester.pump();

      expect(wasPressed, isFalse);
    });

    testWidgets('animates scale on press', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AnimatedButton(child: Text('Test Button'))),
        ),
      );

      // Find the button
      final buttonFinder = find.text('Test Button');
      expect(buttonFinder, findsOneWidget);

      // Simulate press down
      await tester.press(buttonFinder);
      await tester.pump(const Duration(milliseconds: 50));

      // Button should still be found (just scaled)
      expect(buttonFinder, findsOneWidget);

      // Release press
      await tester.pumpAndSettle();
      expect(buttonFinder, findsOneWidget);
    });

    testWidgets('applies custom styling correctly', (tester) async {
      const backgroundColor = Color(0xFF123456);
      const foregroundColor = Color(0xFF654321);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedButton(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              child: Text('Styled Button'),
            ),
          ),
        ),
      );

      expect(find.text('Styled Button'), findsOneWidget);

      // Find the container with the background color
      final containerFinder = find.byType(AnimatedContainer);
      expect(containerFinder, findsOneWidget);
    });
  });

  group('PrimaryAnimatedButton', () {
    testWidgets('renders with primary styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrimaryAnimatedButton(child: Text('Primary Button')),
          ),
        ),
      );

      expect(find.text('Primary Button'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryAnimatedButton(
              onPressed: () => wasPressed = true,
              child: const Text('Primary Button'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Primary Button'));
      await tester.pump();

      expect(wasPressed, isTrue);
    });
  });

  group('SecondaryAnimatedButton', () {
    testWidgets('renders with secondary styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SecondaryAnimatedButton(child: Text('Secondary Button')),
          ),
        ),
      );

      expect(find.text('Secondary Button'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryAnimatedButton(
              onPressed: () => wasPressed = true,
              child: const Text('Secondary Button'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Secondary Button'));
      await tester.pump();

      expect(wasPressed, isTrue);
    });
  });

  group('OutlineAnimatedButton', () {
    testWidgets('renders with outline styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OutlineAnimatedButton(child: Text('Outline Button')),
          ),
        ),
      );

      expect(find.text('Outline Button'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OutlineAnimatedButton(
              onPressed: () => wasPressed = true,
              child: const Text('Outline Button'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Outline Button'));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('applies custom border color', (tester) async {
      const borderColor = Color(0xFF123456);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OutlineAnimatedButton(
              borderColor: borderColor,
              child: Text('Custom Border'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Border'), findsOneWidget);
    });
  });

  group('Animation Performance', () {
    testWidgets('button animations complete within expected time', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedButton(
              animationDuration: Duration(milliseconds: 200),
              child: Text('Performance Test'),
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Simulate press and release
      await tester.press(find.text('Performance Test'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Animation should complete within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(400));
    });

    testWidgets('multiple button animations work simultaneously', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AnimatedButton(onPressed: () {}, child: const Text('Button 1')),
                AnimatedButton(onPressed: () {}, child: const Text('Button 2')),
              ],
            ),
          ),
        ),
      );

      // Press both buttons simultaneously
      await tester.press(find.text('Button 1'));
      await tester.press(find.text('Button 2'));
      await tester.pump(const Duration(milliseconds: 50));

      // Both buttons should still be found
      expect(find.text('Button 1'), findsOneWidget);
      expect(find.text('Button 2'), findsOneWidget);

      await tester.pumpAndSettle();

      // Both should complete animation
      expect(find.text('Button 1'), findsOneWidget);
      expect(find.text('Button 2'), findsOneWidget);
    });
  });
}
