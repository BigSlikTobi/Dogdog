import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/screens/dog_breeds_adventure_screen.dart';
import 'package:dogdog_trivia_game/widgets/breed_adventure/loading_error_states.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DogBreedsAdventureScreen Widget Tests', () {
    testWidgets('should display loading state initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: DogBreedsAdventureScreen()),
      );

      // Should show loading state initially
      expect(find.byType(GameInitializingState), findsOneWidget);
    });

    testWidgets('should have proper scaffold structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: DogBreedsAdventureScreen()),
      );

      // Should have scaffold with proper structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    testWidgets('should have gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DogBreedsAdventureScreen()),
      );

      // Should find containers with gradient decoration
      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasGradient = containers.any((container) {
        final decoration = container.decoration;
        return decoration is BoxDecoration && decoration.gradient != null;
      });

      expect(hasGradient, isTrue);
    });

    testWidgets('should handle widget lifecycle properly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: DogBreedsAdventureScreen()),
      );

      // Should not throw during initial build
      expect(tester.takeException(), isNull);

      // Should handle disposal properly
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('should display stack for overlays', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: DogBreedsAdventureScreen()),
      );

      // Should have at least one stack for overlays
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
    });
  });

  group('Basic Functionality Tests', () {
    testWidgets('should handle navigation setup', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const DogBreedsAdventureScreen(),
          routes: {'/home': (context) => const Scaffold(body: Text('Home'))},
        ),
      );

      // Should not throw during navigation setup
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle basic widget operations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: DogBreedsAdventureScreen()),
      );

      // Basic pump operations should work
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
