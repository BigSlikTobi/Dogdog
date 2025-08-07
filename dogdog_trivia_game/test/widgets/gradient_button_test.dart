import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/widgets/gradient_button.dart';

void main() {
  group('GradientButton', () {
    testWidgets('should display text and respond to tap', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Test Button',
              gradientColors: const [Colors.blue, Colors.purple],
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);

      await tester.tap(find.byType(GradientButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('should handle null onPressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton(
              text: 'Disabled Button',
              gradientColors: const [Colors.grey, Colors.blueGrey],
              onPressed: null,
            ),
          ),
        ),
      );

      expect(find.text('Disabled Button'), findsOneWidget);

      // Should not throw when tapped while disabled
      await tester.tap(find.byType(GradientButton));
      await tester.pump();
    });
  });
}
