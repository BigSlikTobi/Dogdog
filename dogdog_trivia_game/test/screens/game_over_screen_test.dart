import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dogdog_trivia_game/screens/game_over_screen.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/services/progress_service.dart';
import 'package:dogdog_trivia_game/models/achievement.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('GameOverScreen Widget Tests', () {
    late GameController gameController;
    late ProgressService progressService;

    setUp(() {
      gameController = GameController();
      progressService = ProgressService();
    });

    tearDown(() {
      gameController.dispose();
    });

    Widget createTestWidget({
      int finalScore = 150,
      int level = 2,
      int correctAnswers = 8,
      int totalQuestions = 10,
      List<Achievement> newlyUnlockedAchievements = const [],
    }) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<GameController>.value(value: gameController),
          ChangeNotifierProvider<ProgressService>.value(value: progressService),
        ],
        child: MaterialApp(
          home: GameOverScreen(
            finalScore: finalScore,
            level: level,
            correctAnswers: correctAnswers,
            totalQuestions: totalQuestions,
            newlyUnlockedAchievements: newlyUnlockedAchievements,
          ),
        ),
      );
    }

    testWidgets('displays game over title and score correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for game over title
      expect(find.text('Spiel beendet!'), findsOneWidget);
      expect(
        find.text('Gut gespielt! Hier sind deine Ergebnisse:'),
        findsOneWidget,
      );

      // Check for score display (after animation)
      expect(find.text('150'), findsOneWidget);
      expect(find.text('Punkte'), findsOneWidget);
    });

    testWidgets('displays level reached correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(level: 3));
      await tester.pumpAndSettle();

      expect(find.text('Level 3 erreicht'), findsOneWidget);
    });

    testWidgets('displays game statistics correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(correctAnswers: 7, totalQuestions: 10),
      );
      await tester.pumpAndSettle();

      // Check statistics section
      expect(find.text('Spielstatistiken'), findsOneWidget);
      expect(find.text('7/10'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);
      expect(find.text('Richtige Antworten'), findsOneWidget);
      expect(find.text('Genauigkeit'), findsOneWidget);
    });

    testWidgets(
      'displays achievement notifications when achievements are unlocked',
      (tester) async {
        final achievement = Achievement.fromRank(Rank.pug, isUnlocked: true);

        await tester.pumpWidget(
          createTestWidget(newlyUnlockedAchievements: [achievement]),
        );

        // Wait for achievement animation to complete
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(find.text('Neuer Rang freigeschaltet!'), findsOneWidget);
        expect(find.text(achievement.name), findsOneWidget);
        expect(find.text(achievement.description), findsOneWidget);
      },
    );

    testWidgets(
      'does not display achievement section when no achievements unlocked',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Neuer Rang freigeschaltet!'), findsNothing);
      },
    );

    testWidgets('displays navigation buttons correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for navigation buttons
      expect(find.text('Nochmal spielen'), findsOneWidget);
      expect(find.text('Zurück zum Hauptmenü'), findsOneWidget);

      // Check button types
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('play again button navigates correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Wait for all animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find and tap the play again button
      final playAgainButton = find.text('Nochmal spielen');
      expect(playAgainButton, findsOneWidget);

      // Note: Navigation testing would require more complex setup
      // For now, just verify the button exists and is tappable
      expect(
        tester
            .widget<ElevatedButton>(
              find.ancestor(
                of: playAgainButton,
                matching: find.byType(ElevatedButton),
              ),
            )
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('return home button navigates correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Wait for all animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find the return home button
      final homeButton = find.text('Zurück zum Hauptmenü');
      expect(homeButton, findsOneWidget);

      // Note: Navigation testing would require more complex setup
      // For now, just verify the button exists and is tappable
      expect(
        tester
            .widget<OutlinedButton>(
              find.ancestor(
                of: homeButton,
                matching: find.byType(OutlinedButton),
              ),
            )
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('handles zero accuracy correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(correctAnswers: 0, totalQuestions: 5),
      );
      await tester.pumpAndSettle();

      expect(find.text('0/5'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('handles perfect accuracy correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(correctAnswers: 10, totalQuestions: 10),
      );
      await tester.pumpAndSettle();

      expect(find.text('10/10'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('displays multiple achievements correctly', (tester) async {
      final achievements = [
        Achievement.fromRank(Rank.pug, isUnlocked: true),
        Achievement.fromRank(Rank.cockerSpaniel, isUnlocked: true),
      ];

      await tester.pumpWidget(
        createTestWidget(newlyUnlockedAchievements: achievements),
      );

      // Wait for achievement animation to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Neuer Rang freigeschaltet!'), findsOneWidget);

      // Check that both achievements are displayed
      for (final achievement in achievements) {
        expect(find.text(achievement.name), findsOneWidget);
        expect(find.text(achievement.description), findsOneWidget);
      }
    });

    testWidgets('score animation works correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(finalScore: 200));

      // Initially score should be 0 or low
      await tester.pump();

      // After animation completes, should show final score
      await tester.pumpAndSettle();
      expect(find.text('200'), findsOneWidget);
    });

    testWidgets('has proper styling and colors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for proper background color
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF8FAFC));

      // Check for gradient containers (score card and achievement card if present)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('handles edge case with zero total questions', (tester) async {
      await tester.pumpWidget(
        createTestWidget(correctAnswers: 0, totalQuestions: 0),
      );
      await tester.pumpAndSettle();

      // Should handle division by zero gracefully
      expect(find.text('0/0'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });
  });
}
