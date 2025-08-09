import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dogdog_trivia_game/screens/treasure_map_screen.dart';
import 'package:dogdog_trivia_game/controllers/treasure_map_controller.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('Simple Integration Tests', () {
    testWidgets('treasure map screen renders directly', (
      WidgetTester tester,
    ) async {
      final controller = TreasureMapController();
      controller.initializePath(PathType.dogBreeds);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: controller,
            child: const TreasureMapScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(TreasureMapScreen), findsOneWidget);
      expect(find.text('Dog Breeds Adventure'), findsOneWidget);
    });
  });
}
