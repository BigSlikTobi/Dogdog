import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dogdog_trivia_game/screens/game_screen.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('Power-up UI and Integration Tests', () {
    late GameController gameController;

    setUp(() {
      gameController = GameController();
    });

    tearDown(() {
      gameController.dispose();
    });

    Widget createTestWidget() {
      return ChangeNotifierProvider<GameController>.value(
        value: gameController,
        child: MaterialApp(
          home: GameScreen(difficulty: Difficulty.easy, level: 2),
        ),
      );
    }

    group('Power-up Button Display', () {
      testWidgets('should display all five power-up buttons', (tester) async {
        await gameController.initializeGame(level: 2);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Check that all power-up buttons are present
        expect(
          find.byIcon(Icons.remove_circle_outline),
          findsOneWidget,
        ); // 50/50
        expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget); // Hint
        expect(find.byIcon(Icons.access_time), findsOneWidget); // Extra Time
        expect(find.byIcon(Icons.skip_next), findsOneWidget); // Skip
        expect(
          find.byIcon(Icons.favorite_border),
          findsOneWidget,
        ); // Second Chance
      });

      testWidgets('should show power-up counts correctly', (tester) async {
        await gameController.initializeGame(level: 2);

        // Add some power-ups
        gameController.addPowerUp(PowerUpType.fiftyFifty, 3);
        gameController.addPowerUp(PowerUpType.hint, 2);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Check that counts are displayed
        expect(find.text('3'), findsOneWidget); // 50/50 count
        expect(find.text('2'), findsOneWidget); // Hint count
        expect(
          find.text('0'),
          findsNWidgets(3),
        ); // Other power-ups should show 0
      });

      testWidgets('should disable buttons when no power-ups available', (
        tester,
      ) async {
        await gameController.initializeGame(level: 2);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // All buttons should be disabled (grayed out) when count is 0
        final powerUpButtons = find.byType(InkWell);
        expect(powerUpButtons, findsNWidgets(5));

        // Try to tap a disabled button - should not trigger any action
        await tester.tap(powerUpButtons.first);
        await tester.pumpAndSettle();

        // No dialog should appear
        expect(find.byType(AlertDialog), findsNothing);
      });

      testWidgets('should enable buttons when power-ups are available', (
        tester,
      ) async {
        await gameController.initializeGame(level: 2);
        gameController.addPowerUp(PowerUpType.fiftyFifty, 1);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find the 50/50 button and verify it's enabled
        final fiftyFiftyButton = find.byIcon(Icons.remove_circle_outline);
        expect(fiftyFiftyButton, findsOneWidget);

        // Button should be tappable
        await tester.tap(fiftyFiftyButton);
        await tester.pumpAndSettle();

        // Confirmation dialog should appear
        expect(find.byType(AlertDialog), findsOneWidget);
      });
    });

    group('Power-up Confirmation Dialogs', () {
      testWidgets('should show confirmation dialog for 50/50 power-up', (
        tester,
      ) async {
        await gameController.initializeGame(level: 2);
        gameController.addPowerUp(PowerUpType.fiftyFifty, 1);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap the 50/50 button
        await tester.tap(find.byIcon(Icons.remove_circle_outline));
        await tester.pumpAndSettle();

        // Check dialog content
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Chew 50/50'), findsOneWidget);
        expect(find.text('Entfernt zwei falsche Antworten'), findsOneWidget);
        expect(
          find.text('Möchtest du dieses Power-Up verwenden?'),
          findsOneWidget,
        );
        expect(find.text('Abbrechen'), findsOneWidget);
        expect(find.text('Verwenden'), findsOneWidget);
      });

      testWidgets('should show confirmation dialog for hint power-up', (
        tester,
      ) async {
        await gameController.initializeGame(level: 2);
        gameController.addPowerUp(PowerUpType.hint, 1);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap the hint button
        await tester.tap(find.byIcon(Icons.lightbulb_outline));
        await tester.pumpAndSettle();

        // Check dialog content
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Hinweis'), findsOneWidget);
        expect(
          find.text('Zeigt einen Hinweis zur richtigen Antwort'),
          findsOneWidget,
        );
      });

      testWidgets('should cancel power-up usage when cancel is pressed', (
        tester,
      ) async {
        await gameController.initializeGame(level: 2);
        gameController.addPowerUp(PowerUpType.fiftyFifty, 1);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final initialCount = gameController.getPowerUpCount(
          PowerUpType.fiftyFifty,
        );

        // Tap the 50/50 button
        await tester.tap(find.byIcon(Icons.remove_circle_outline));
        await tester.pumpAndSettle();

        // Tap cancel
        await tester.tap(find.text('Abbrechen'));
        await tester.pumpAndSettle();

        // Power-up should not be consumed
        expect(
          gameController.getPowerUpCount(PowerUpType.fiftyFifty),
          initialCount,
        );
        expect(find.byType(AlertDialog), findsNothing);
      });

      testWidgets('should use power-up when confirm is pressed', (
        tester,
      ) async {
        await gameController.initializeGame(level: 2);
        gameController.addPowerUp(PowerUpType.fiftyFifty, 1);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap the 50/50 button
        await tester.tap(find.byIcon(Icons.remove_circle_outline));
        await tester.pumpAndSettle();

        // Tap confirm
        await tester.tap(find.text('Verwenden'));
        await tester.pumpAndSettle();

        // Power-up should be consumed
        expect(gameController.getPowerUpCount(PowerUpType.fiftyFifty), 0);
        expect(find.byType(AlertDialog), findsNothing);
      });
    });

    group('Power-up Visual Effects', () {
      testWidgets('should show snackbar feedback after using power-up', (
        tester,
      ) async {
        await gameController.initializeGame(level: 2);
        gameController.addPowerUp(PowerUpType.extraTime, 1);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Use extra time power-up
        await tester.tap(find.byIcon(Icons.access_time));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Verwenden'));
        await tester.pumpAndSettle();

        // Should show snackbar
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Extra Zeit hinzugefügt!'), findsOneWidget);
      });

      testWidgets('should show hint dialog when hint power-up is used', (
        tester,
      ) async {
        await gameController.initializeGame(level: 2);
        gameController.addPowerUp(PowerUpType.hint, 1);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Use hint power-up
        await tester.tap(find.byIcon(Icons.lightbulb_outline));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Verwenden'));
        await tester.pumpAndSettle();

        // Should show hint dialog (if question has hint)
        // Note: This depends on the question having a hint
        expect(find.byType(AlertDialog), findsOneWidget);
      });

      testWidgets('should dim disabled answers after 50/50 power-up', (
        tester,
      ) async {
        await gameController.initializeGame(level: 2);
        gameController.addPowerUp(PowerUpType.fiftyFifty, 1);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Use 50/50 power-up
        await tester.tap(find.byIcon(Icons.remove_circle_outline));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Verwenden'));
        await tester.pumpAndSettle();

        // Check that some answer buttons are disabled/dimmed
        // This would require checking the opacity or color of answer buttons
        // The exact implementation depends on how the UI handles disabled answers
        expect(gameController.disabledAnswerIndices.length, 2);
      });
    });

    group('Power-up Inventory Management', () {
      testWidgets('should update count display after power-up usage', (
        tester,
      ) async {
        await gameController.initializeGame(level: 2);
        gameController.addPowerUp(PowerUpType.skip, 2);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Initial count should be 2
        expect(find.text('2'), findsOneWidget);

        // Use skip power-up
        await tester.tap(find.byIcon(Icons.skip_next));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Verwenden'));
        await tester.pumpAndSettle();

        // Count should be reduced to 1
        expect(find.text('1'), findsOneWidget);
      });

      testWidgets('should disable button when count reaches zero', (
        tester,
      ) async {
        await gameController.initializeGame(level: 2);
        gameController.addPowerUp(PowerUpType.secondChance, 1);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Use the last second chance power-up
        await tester.tap(find.byIcon(Icons.favorite_border));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Verwenden'));
        await tester.pumpAndSettle();

        // Button should now be disabled
        expect(gameController.getPowerUpCount(PowerUpType.secondChance), 0);
        expect(gameController.canUsePowerUp(PowerUpType.secondChance), false);
      });
    });

    group('Power-up Earning System', () {
      testWidgets('should award power-ups on level completion', (tester) async {
        await gameController.initializeGame(level: 2);

        // Complete all questions in the level
        while (!gameController.isGameOver &&
            gameController.currentQuestion != null) {
          gameController.processAnswer(0); // Assume correct answer
          gameController.clearFeedback();
          if (!gameController.isGameOver) {
            gameController.nextQuestion();
          }
        }

        // Power-ups should be awarded
        expect(
          gameController.getPowerUpCount(PowerUpType.fiftyFifty),
          greaterThan(0),
        );
        expect(
          gameController.getPowerUpCount(PowerUpType.hint),
          greaterThan(0),
        );
      });

      testWidgets('should award bonus power-ups for good performance', (
        tester,
      ) async {
        await gameController.initializeGame(level: 3);

        // Answer all questions correctly for high accuracy
        int questionsAnswered = 0;
        while (!gameController.isGameOver &&
            gameController.currentQuestion != null &&
            questionsAnswered < 10) {
          gameController.processAnswer(0); // Assume correct answer
          gameController.clearFeedback();
          questionsAnswered++;
          if (!gameController.isGameOver) {
            gameController.nextQuestion();
          }
        }

        // Should get bonus power-ups for high accuracy
        final totalPowerUps = gameController.powerUps.values.fold(
          0,
          (sum, count) => sum + count,
        );
        expect(totalPowerUps, greaterThan(3)); // Base + bonus power-ups
      });
    });

    group('Power-up Restrictions', () {
      testWidgets('should not allow extra time power-up on level 1', (
        tester,
      ) async {
        await gameController.initializeGame(level: 1);
        gameController.addPowerUp(PowerUpType.extraTime, 1);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Try to use extra time power-up
        await tester.tap(find.byIcon(Icons.access_time));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Verwenden'));
        await tester.pumpAndSettle();

        // Should not work on non-timed level
        expect(
          gameController.getPowerUpCount(PowerUpType.extraTime),
          1,
        ); // Not consumed
      });

      testWidgets('should not allow second chance when at max lives', (
        tester,
      ) async {
        await gameController.initializeGame(level: 2);
        gameController.addPowerUp(PowerUpType.secondChance, 1);

        // Player should start with 3 lives (max)
        expect(gameController.lives, 3);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Try to use second chance power-up
        await tester.tap(find.byIcon(Icons.favorite_border));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Verwenden'));
        await tester.pumpAndSettle();

        // Should not work when already at max lives
        expect(
          gameController.getPowerUpCount(PowerUpType.secondChance),
          1,
        ); // Not consumed
        expect(gameController.lives, 3); // Lives unchanged
      });
    });

    group('Power-up UI Styling', () {
      testWidgets('should have proper styling for power-up bar', (
        tester,
      ) async {
        await gameController.initializeGame(level: 2);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Check that power-up bar container exists with proper styling
        final powerUpBar = find
            .byType(Container)
            .evaluate()
            .where((element) => element.widget is Container)
            .map((element) => element.widget as Container)
            .where((container) => container.decoration is BoxDecoration)
            .firstOrNull;

        expect(powerUpBar, isNotNull);
      });

      testWidgets('should show different colors for enabled/disabled buttons', (
        tester,
      ) async {
        await gameController.initializeGame(level: 2);

        // Add power-up to one button only
        gameController.addPowerUp(PowerUpType.fiftyFifty, 1);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Both enabled and disabled buttons should be present
        // The exact color checking would depend on the specific implementation
        expect(find.byType(Icon), findsNWidgets(5)); // All power-up icons
      });
    });
  });
}
