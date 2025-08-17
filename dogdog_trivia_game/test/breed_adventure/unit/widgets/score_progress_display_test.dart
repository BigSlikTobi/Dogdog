import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/widgets/breed_adventure/score_progress_display.dart';
import 'package:dogdog_trivia_game/models/breed_adventure/difficulty_phase.dart';

void main() {
  group('ScoreProgressDisplay', () {
    testWidgets('displays score and progress correctly', (
      WidgetTester tester,
    ) async {
      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreProgressDisplay(
              score: 150,
              correctAnswers: 3,
              totalQuestions: 5,
              currentPhase: DifficultyPhase.beginner,
              livesRemaining: 2,
              accuracy: 60.0,
              showAnimations: false,
            ),
          ),
        ),
      );

      // Verify the widget is rendered
      expect(find.byType(ScoreProgressDisplay), findsOneWidget);

      // Verify score is displayed
      expect(find.text('150'), findsOneWidget);

      // Verify progress text is displayed with "correct" suffix
      expect(find.text('3/5 correct'), findsOneWidget);

      // Verify lives indicator is present
      expect(find.byIcon(Icons.favorite), findsAtLeastNWidgets(1));
    });

    testWidgets('displays different phases correctly', (
      WidgetTester tester,
    ) async {
      // Test expert phase
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreProgressDisplay(
              score: 500,
              correctAnswers: 8,
              totalQuestions: 10,
              currentPhase: DifficultyPhase.expert,
              livesRemaining: 1,
              accuracy: 80.0,
              showAnimations: false,
            ),
          ),
        ),
      );

      expect(find.byType(ScoreProgressDisplay), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
      expect(find.text('8/10 correct'), findsOneWidget);
    });

    testWidgets('handles zero questions correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreProgressDisplay(
              score: 0,
              correctAnswers: 0,
              totalQuestions: 0,
              currentPhase: DifficultyPhase.beginner,
              showAnimations: false,
            ),
          ),
        ),
      );

      expect(find.byType(ScoreProgressDisplay), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });
  });

  group('CompactScoreDisplay', () {
    testWidgets('displays compact score correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactScoreDisplay(
              score: 200,
              correctAnswers: 4,
              totalQuestions: 6,
              currentPhase: DifficultyPhase.intermediate,
            ),
          ),
        ),
      );

      expect(find.byType(CompactScoreDisplay), findsOneWidget);
      expect(find.text('200'), findsOneWidget);
      expect(find.text('4/6'), findsOneWidget);
    });
  });
}
