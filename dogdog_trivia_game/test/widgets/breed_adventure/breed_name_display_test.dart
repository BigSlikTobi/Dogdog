import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/widgets/breed_adventure/breed_name_display.dart';

void main() {
  group('BreedNameDisplay Widget Tests', () {
    testWidgets('should display breed name correctly', (
      WidgetTester tester,
    ) async {
      const breedName = 'German Shepherd Dog';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BreedNameDisplay(breedName: breedName)),
        ),
      );

      expect(find.text(breedName), findsOneWidget);
      expect(find.text('Which image shows a'), findsOneWidget);
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('should handle long breed names with ellipsis', (
      WidgetTester tester,
    ) async {
      const longBreedName =
          'This is a very long breed name that should be truncated';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BreedNameDisplay(breedName: longBreedName)),
        ),
      );

      final textWidget = tester.widget<Text>(find.text(longBreedName));
      expect(textWidget.maxLines, equals(2));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should animate when visibility changes', (
      WidgetTester tester,
    ) async {
      const breedName = 'Golden Retriever';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BreedNameDisplay(breedName: breedName, isVisible: false),
          ),
        ),
      );

      // Initially not visible
      expect(find.text(breedName), findsOneWidget);

      // Change to visible
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BreedNameDisplay(breedName: breedName, isVisible: true),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text(breedName), findsOneWidget);
    });

    testWidgets('should animate when breed name changes', (
      WidgetTester tester,
    ) async {
      const initialBreed = 'Labrador';
      const newBreed = 'Poodle';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BreedNameDisplay(breedName: initialBreed)),
        ),
      );

      expect(find.text(initialBreed), findsOneWidget);

      // Change breed name
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BreedNameDisplay(breedName: newBreed)),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text(newBreed), findsOneWidget);
      expect(find.text(initialBreed), findsNothing);
    });
  });

  group('CompactBreedNameDisplay Widget Tests', () {
    testWidgets('should display breed name in compact format', (
      WidgetTester tester,
    ) async {
      const breedName = 'Beagle';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CompactBreedNameDisplay(breedName: breedName)),
        ),
      );

      expect(find.text(breedName), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text(breedName));
      expect(textWidget.maxLines, equals(1));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should apply custom text color', (WidgetTester tester) async {
      const breedName = 'Bulldog';
      const customColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactBreedNameDisplay(
              breedName: breedName,
              textColor: customColor,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text(breedName));
      expect(textWidget.style?.color, equals(customColor));
    });

    testWidgets('should apply custom text style', (WidgetTester tester) async {
      const breedName = 'Chihuahua';
      const customStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.w300);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactBreedNameDisplay(
              breedName: breedName,
              textStyle: customStyle,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text(breedName));
      expect(textWidget.style?.fontSize, equals(customStyle.fontSize));
      expect(textWidget.style?.fontWeight, equals(customStyle.fontWeight));
    });
  });
}
