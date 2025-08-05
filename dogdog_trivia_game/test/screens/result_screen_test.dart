import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dogdog_trivia_game/screens/result_screen.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/models/question.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('ResultScreen Widget Tests', () {
    late GameController gameController;
    late Question testQuestion;

    setUp(() {
      gameController = GameController();
      testQuestion = const Question(
        id: 'test-1',
        text: 'Welche Hunderasse ist bekannt für ihre blaue Zunge?',
        answers: ['Golden Retriever', 'Chow-Chow', 'Labrador', 'Beagle'],
        correctAnswerIndex: 1,
        funFact:
            'Chow-Chows sind eine der wenigen Hunderassen mit einer natürlich blauen Zunge!',
        difficulty: Difficulty.medium,
        category: 'Rassen',
        hint: 'Diese Rasse stammt aus China.',
      );
    });

    Widget createResultScreen({
      required bool isCorrect,
      int pointsEarned = 15,
      int livesLost = 0,
    }) {
      return MaterialApp(
        home: ChangeNotifierProvider.value(
          value: gameController,
          child: ResultScreen(
            isCorrect: isCorrect,
            question: testQuestion,
            pointsEarned: pointsEarned,
            livesLost: livesLost,
          ),
        ),
      );
    }

    testWidgets('displays correct answer feedback', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createResultScreen(isCorrect: true));
      await tester.pumpAndSettle();

      // Check for correct feedback elements
      expect(find.text('Richtig!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Should not show correct answer text for correct answers
      expect(find.text('Die richtige Antwort war:'), findsNothing);
    });

    testWidgets('displays incorrect answer feedback', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createResultScreen(isCorrect: false));
      await tester.pumpAndSettle();

      // Check for incorrect feedback elements
      expect(find.text('Falsch!'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);

      // Should show correct answer for incorrect answers
      expect(find.text('Die richtige Antwort war:'), findsOneWidget);
      expect(find.text('Chow-Chow'), findsOneWidget);
    });

    testWidgets('displays fun fact card', (WidgetTester tester) async {
      await tester.pumpWidget(createResultScreen(isCorrect: true));
      await tester.pumpAndSettle();

      // Check for fun fact elements
      expect(find.text('Wusstest du schon?'), findsOneWidget);
      expect(find.text(testQuestion.funFact), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
    });

    testWidgets('displays score update for correct answers', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createResultScreen(isCorrect: true, pointsEarned: 15),
      );
      await tester.pumpAndSettle();

      // Check for score update display
      expect(find.text('+15 Punkte'), findsOneWidget);
      expect(find.byIcon(Icons.add_circle), findsOneWidget);
    });

    testWidgets('does not display score update for incorrect answers', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createResultScreen(isCorrect: false, pointsEarned: 0),
      );
      await tester.pumpAndSettle();

      // Should not show score update for 0 points
      expect(find.text('+0 Punkte'), findsNothing);
      expect(find.byIcon(Icons.add_circle), findsNothing);
    });

    testWidgets('displays lives correctly', (WidgetTester tester) async {
      // Initialize game controller with specific lives count
      await gameController.initializeGame(level: 1);

      await tester.pumpWidget(createResultScreen(isCorrect: true));
      await tester.pumpAndSettle();

      // Check for lives display - should have at least one heart icon
      expect(find.byIcon(Icons.favorite), findsAtLeastNWidgets(1));
    });

    testWidgets('displays next question button', (WidgetTester tester) async {
      await tester.pumpWidget(createResultScreen(isCorrect: true));
      await tester.pumpAndSettle();

      // Check for next question button
      expect(find.text('Nächste Frage'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('handles animation completion', (WidgetTester tester) async {
      await tester.pumpWidget(createResultScreen(isCorrect: true));

      // Pump initial frame
      await tester.pump();

      // Pump through animation duration
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 1000));

      // Should complete without errors
      await tester.pumpAndSettle();

      expect(find.byType(ResultScreen), findsOneWidget);
    });

    testWidgets('handles different point values', (WidgetTester tester) async {
      // Test with different point values
      await tester.pumpWidget(
        createResultScreen(
          isCorrect: true,
          pointsEarned: 30, // 2x multiplier
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('+30 Punkte'), findsOneWidget);
    });

    testWidgets('handles different difficulty levels', (
      WidgetTester tester,
    ) async {
      final hardQuestion = testQuestion.copyWith(
        difficulty: Difficulty.hard,
        funFact: 'Dies ist ein schwieriger Fakt über Hunde.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: gameController,
            child: ResultScreen(
              isCorrect: true,
              question: hardQuestion,
              pointsEarned: 20,
              livesLost: 0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Dies ist ein schwieriger Fakt über Hunde.'),
        findsOneWidget,
      );
      expect(find.text('+20 Punkte'), findsOneWidget);
    });
  });
}
