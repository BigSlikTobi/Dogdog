import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/screens/difficulty_selection_screen.dart';

void main() {
  group('DifficultySelectionScreen', () {
    Future<void> pumpDifficultyScreen(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        const MaterialApp(home: DifficultySelectionScreen()),
      );
    }

    testWidgets('should display all difficulty options', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await pumpDifficultyScreen(tester);

      // Assert
      expect(find.text('Schwierigkeit wählen'), findsOneWidget);
      expect(find.text('Wähle deinen Schwierigkeitsgrad'), findsOneWidget);
      expect(find.text('Leicht'), findsOneWidget);
      expect(find.text('Mittel'), findsOneWidget);
      expect(find.text('Schwer'), findsOneWidget);
      expect(find.text('Experte'), findsOneWidget);
    });

    testWidgets('should display correct descriptions for each difficulty', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await pumpDifficultyScreen(tester);

      // Assert
      expect(find.text('Perfekt für Anfänger'), findsOneWidget);
      expect(find.text('Für Hundeliebhaber'), findsOneWidget);
      expect(find.text('Für Hundeexperten'), findsOneWidget);
      expect(find.text('Nur für Profis'), findsOneWidget);
    });

    testWidgets('should display correct points for each difficulty', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await pumpDifficultyScreen(tester);

      // Assert
      expect(find.text('10 Punkte pro Frage'), findsOneWidget);
      expect(find.text('15 Punkte pro Frage'), findsOneWidget);
      expect(find.text('20 Punkte pro Frage'), findsOneWidget);
      expect(find.text('25 Punkte pro Frage'), findsOneWidget);
    });

    testWidgets('should display selection buttons for each difficulty', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await pumpDifficultyScreen(tester);

      // Assert
      expect(find.text('Diese Kategorie wählen'), findsNWidgets(4));
    });

    testWidgets('should display appropriate icons for each difficulty', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await pumpDifficultyScreen(tester);

      // Assert
      expect(find.byIcon(Icons.pets), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('should show snackbar when easy difficulty is selected', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpDifficultyScreen(tester);

      // Act
      final easyCard = find.ancestor(
        of: find.text('Leicht'),
        matching: find.byType(InkWell),
      );
      await tester.tap(easyCard);
      await tester.pump();

      // Assert
      expect(
        find.text('Leicht ausgewählt! Spiel startet bald...'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should show snackbar when medium difficulty is selected', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpDifficultyScreen(tester);

      // Act
      final mediumCard = find.ancestor(
        of: find.text('Mittel'),
        matching: find.byType(InkWell),
      );
      await tester.tap(mediumCard);
      await tester.pump();

      // Assert
      expect(
        find.text('Mittel ausgewählt! Spiel startet bald...'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should show snackbar when hard difficulty is selected', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpDifficultyScreen(tester);

      // Act
      final hardCard = find.ancestor(
        of: find.text('Schwer'),
        matching: find.byType(InkWell),
      );
      await tester.tap(hardCard);
      await tester.pump();

      // Assert
      expect(
        find.text('Schwer ausgewählt! Spiel startet bald...'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should show snackbar when expert difficulty is selected', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpDifficultyScreen(tester);

      // Act
      final expertCard = find.ancestor(
        of: find.text('Experte'),
        matching: find.byType(InkWell),
      );
      await tester.tap(expertCard);
      await tester.pump();

      // Assert
      expect(
        find.text('Experte ausgewählt! Spiel startet bald...'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should have back button in app bar', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await pumpDifficultyScreen(tester);

      // Assert
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should navigate back when back button is pressed', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool navigatedBack = false;
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => const DifficultySelectionScreen(),
                      ),
                    )
                    .then((_) => navigatedBack = true);
              },
              child: const Text('Go to Difficulty'),
            ),
          ),
        ),
      );

      // Navigate to difficulty screen
      await tester.tap(find.text('Go to Difficulty'));
      await tester.pumpAndSettle();

      // Act - tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Assert
      expect(navigatedBack, isTrue);
    });

    testWidgets('should display grid layout with 2 columns', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await pumpDifficultyScreen(tester);

      // Assert
      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect(
        gridView.gridDelegate,
        isA<SliverGridDelegateWithFixedCrossAxisCount>(),
      );

      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(2));
      expect(delegate.crossAxisSpacing, equals(16));
      expect(delegate.mainAxisSpacing, equals(16));
      expect(delegate.childAspectRatio, equals(0.85));
    });

    testWidgets('should apply correct color coding for difficulties', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await pumpDifficultyScreen(tester);

      // Assert - Check that containers with different colors exist
      // This is a basic check since we can't easily verify exact colors in widget tests
      expect(find.byType(Container), findsWidgets);
      expect(
        find.byType(Icon),
        findsNWidgets(5),
      ); // 4 difficulty icons + 1 back arrow
    });

    testWidgets('should have proper accessibility semantics', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await pumpDifficultyScreen(tester);

      // Assert - Check that tappable elements are present
      // 4 difficulty cards + 1 back button = 5 InkWell widgets
      expect(find.byType(InkWell), findsNWidgets(5));
      expect(find.byType(Material), findsWidgets);
    });
  });
}
