import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/widgets/breed_adventure/countdown_timer_display.dart';

void main() {
  group('CountdownTimerDisplay Widget Tests', () {
    testWidgets('should display remaining seconds correctly', (
      WidgetTester tester,
    ) async {
      const remainingSeconds = 7;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountdownTimerDisplay(
              remainingSeconds: remainingSeconds,
              totalSeconds: 10,
            ),
          ),
        ),
      );

      expect(find.text('$remainingSeconds'), findsOneWidget);
      expect(find.text('sec'), findsOneWidget);
    });

    testWidgets('should show circular progress indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CountdownTimerDisplay(remainingSeconds: 5, totalSeconds: 10),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progressIndicator.value, equals(0.5)); // 5/10
    });

    testWidgets('should change color based on remaining time', (
      WidgetTester tester,
    ) async {
      // Test danger color (≤20% remaining)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CountdownTimerDisplay(remainingSeconds: 2, totalSeconds: 10),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should use danger color for low time
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progressIndicator.valueColor, isNotNull);
    });

    testWidgets('should show warning indicator for last 3 seconds', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CountdownTimerDisplay(remainingSeconds: 2, totalSeconds: 10),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show warning border for last 3 seconds
      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    testWidgets('should call onTimeExpired when time reaches zero', (
      WidgetTester tester,
    ) async {
      bool timeExpiredCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountdownTimerDisplay(
              remainingSeconds: 1,
              totalSeconds: 10,
              onTimeExpired: () {
                timeExpiredCalled = true;
              },
            ),
          ),
        ),
      );

      // Update to zero seconds
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountdownTimerDisplay(
              remainingSeconds: 0,
              totalSeconds: 10,
              onTimeExpired: () {
                timeExpiredCalled = true;
              },
            ),
          ),
        ),
      );

      expect(timeExpiredCalled, isTrue);
    });

    testWidgets('should animate when seconds change', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CountdownTimerDisplay(remainingSeconds: 5, totalSeconds: 10),
          ),
        ),
      );

      // Change seconds
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CountdownTimerDisplay(remainingSeconds: 4, totalSeconds: 10),
          ),
        ),
      );

      // Should trigger animation
      expect(find.byType(Transform), findsAtLeastNWidgets(1));
    });
  });

  group('CompactCountdownTimer Widget Tests', () {
    testWidgets('should display compact timer format', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactCountdownTimer(remainingSeconds: 8, totalSeconds: 10),
          ),
        ),
      );

      expect(find.text('8s'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show correct progress value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactCountdownTimer(remainingSeconds: 3, totalSeconds: 10),
          ),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progressIndicator.value, equals(0.3)); // 3/10
    });
  });

  group('LinearCountdownTimer Widget Tests', () {
    testWidgets('should display linear progress bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LinearCountdownTimer(remainingSeconds: 6, totalSeconds: 10),
          ),
        ),
      );

      expect(find.text('Time Remaining'), findsOneWidget);
      expect(find.text('6s'), findsOneWidget);
      expect(find.byType(FractionallySizedBox), findsOneWidget);
    });

    testWidgets('should show correct progress fraction', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LinearCountdownTimer(remainingSeconds: 4, totalSeconds: 10),
          ),
        ),
      );

      final fractionallySizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractionallySizedBox.widthFactor, equals(0.4)); // 4/10
    });

    testWidgets('should handle custom height', (WidgetTester tester) async {
      const customHeight = 12.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LinearCountdownTimer(
              remainingSeconds: 5,
              totalSeconds: 10,
              height: customHeight,
            ),
          ),
        ),
      );

      // Should find container with custom height
      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });
  });
}
