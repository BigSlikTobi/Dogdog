import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/widgets/lives_indicator.dart';

void main() {
  group('LivesIndicator', () {
    Future<void> pump(WidgetTester tester, int lives) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: LivesIndicator(lives: lives)),
          ),
        ),
      );
      // Allow animations to settle
      await tester.pumpAndSettle(const Duration(milliseconds: 250));
    }

    testWidgets('shows exactly 3 heart slots', (tester) async {
      await pump(tester, 3);
      final totalHearts = tester
          .widgetList<Icon>(find.byType(Icon))
          .where(
            (icon) =>
                icon.icon == Icons.favorite_rounded ||
                icon.icon == Icons.favorite_border_rounded,
          );
      expect(totalHearts.length, 3);
    });

    testWidgets('filled hearts equal current lives', (tester) async {
      for (final lives in [0, 1, 2, 3]) {
        await pump(tester, lives);
        final filled = tester
            .widgetList<Icon>(find.byType(Icon))
            .where((icon) => icon.icon == Icons.favorite_rounded);
        final empty = tester
            .widgetList<Icon>(find.byType(Icon))
            .where((icon) => icon.icon == Icons.favorite_border_rounded);
        expect(filled.length, lives);
        expect(empty.length, 3 - lives);
      }
    });

    testWidgets('clamps lives to 0..3 for display', (tester) async {
      await pump(tester, -2);
      expect(
        tester
            .widgetList<Icon>(find.byType(Icon))
            .where((i) => i.icon == Icons.favorite_rounded)
            .length,
        0,
      );

      await pump(tester, 99);
      expect(
        tester
            .widgetList<Icon>(find.byType(Icon))
            .where((i) => i.icon == Icons.favorite_rounded)
            .length,
        3,
      );
    });
  });
}
