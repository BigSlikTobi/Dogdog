import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dogdog_trivia_game/screens/path_selection_screen.dart';
import 'package:dogdog_trivia_game/controllers/treasure_map_controller.dart';

void main() {
  group('PathSelectionScreen Basic Tests', () {
    testWidgets('renders all path options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => TreasureMapController(),
            child: const PathSelectionScreen(),
          ),
        ),
      );

      await tester.pump();

      // Check basic rendering
      expect(find.byType(PathSelectionScreen), findsOneWidget);
      expect(find.text('Choose Your Learning Path'), findsOneWidget);
      expect(find.text('Dog Breeds'), findsOneWidget);
      expect(find.text('Dog Training'), findsOneWidget);
      expect(find.text('Health & Care'), findsOneWidget);
      expect(find.text('Dog Behavior'), findsOneWidget);
      expect(find.text('Dog History'), findsOneWidget);
    });
  });
}
