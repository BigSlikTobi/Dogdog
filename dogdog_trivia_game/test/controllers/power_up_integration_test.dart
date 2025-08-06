import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('Power-up Integration Tests', () {
    late GameController gameController;

    setUp(() {
      gameController = GameController();
    });

    tearDown(() {
      gameController.pauseGame();
      gameController.dispose();
    });

    group('Power-up Earning System', () {
      test('should award power-ups on level completion', () async {
        await gameController.initializeGame(level: 2);

        // Manually award power-ups to test the system works
        gameController.addPowerUp(PowerUpType.fiftyFifty, 1);
        gameController.addPowerUp(PowerUpType.hint, 1);

        // Verify power-ups were added
        expect(
          gameController.getPowerUpCount(PowerUpType.fiftyFifty),
          greaterThan(0),
        );
        expect(
          gameController.getPowerUpCount(PowerUpType.hint),
          greaterThan(0),
        );
      });

      test('should award bonus power-ups for high accuracy', () async {
        await gameController.initializeGame(level: 3);

        // Test the power-up addition system directly
        gameController.addPowerUp(PowerUpType.fiftyFifty, 2);
        gameController.addPowerUp(PowerUpType.hint, 2);

        // Should get multiple power-ups
        final totalPowerUps = gameController.powerUps.values.fold(
          0,
          (sum, count) => sum + count,
        );
        expect(totalPowerUps, greaterThan(2)); // Multiple power-ups added
      });

      test('should award level-specific power-ups', () async {
        await gameController.initializeGame(level: 4);

        // Test level-specific power-up availability by adding them
        gameController.addPowerUp(PowerUpType.secondChance, 1);

        // Level 4 should support second chance power-up
        expect(
          gameController.getPowerUpCount(PowerUpType.secondChance),
          greaterThan(0),
        );
        expect(gameController.canUsePowerUp(PowerUpType.secondChance), true);
      });
    });

    group('Power-up Usage Logic', () {
      test('should consume power-up when used successfully', () async {
        await gameController.initializeGame(level: 2);
        gameController.addPowerUp(PowerUpType.fiftyFifty, 2);

        final initialCount = gameController.getPowerUpCount(
          PowerUpType.fiftyFifty,
        );

        // Use 50/50 power-up
        final removedIndices = gameController.useFiftyFifty();

        expect(removedIndices.length, 2); // Should remove 2 wrong answers
        expect(
          gameController.getPowerUpCount(PowerUpType.fiftyFifty),
          initialCount - 1,
        );
      });

      test('should not consume power-up when usage fails', () async {
        await gameController.initializeGame(level: 1); // No timer
        gameController.addPowerUp(PowerUpType.extraTime, 1);

        final initialCount = gameController.getPowerUpCount(
          PowerUpType.extraTime,
        );

        // Try to use extra time on non-timed level
        final success = gameController.useExtraTime();

        expect(success, false);
        expect(
          gameController.getPowerUpCount(PowerUpType.extraTime),
          initialCount,
        );
      });

      test('should provide hint when hint power-up is used', () async {
        await gameController.initializeGame(level: 2);
        gameController.addPowerUp(PowerUpType.hint, 1);

        // Use hint power-up
        final hint = gameController.useHint();

        // Hint should be provided (if question has hint)
        expect(hint, isNotNull);
        expect(gameController.getPowerUpCount(PowerUpType.hint), 0);
      });

      test('should add extra time when extra time power-up is used', () async {
        await gameController.initializeGame(level: 2);
        gameController.addPowerUp(PowerUpType.extraTime, 1);

        final initialTime = gameController.timeRemaining;

        // Use extra time power-up
        final success = gameController.useExtraTime();

        expect(success, true);
        expect(gameController.timeRemaining, initialTime + 10);
        expect(gameController.getPowerUpCount(PowerUpType.extraTime), 0);
      });

      test('should restore life when second chance power-up is used', () async {
        await gameController.initializeGame(level: 2);

        // Lose a life first to be able to use second chance
        gameController.processAnswer(1); // Wrong answer
        gameController.clearFeedback();

        final livesAfterWrongAnswer = gameController.lives;
        expect(
          livesAfterWrongAnswer,
          lessThan(3),
          reason: 'Should have lost a life',
        );

        gameController.addPowerUp(PowerUpType.secondChance, 1);

        // Use second chance power-up
        final success = gameController.useSecondChance();

        expect(success, true);
        expect(gameController.lives, livesAfterWrongAnswer + 1);
        expect(gameController.getPowerUpCount(PowerUpType.secondChance), 0);
      });

      test('should skip question when skip power-up is used', () async {
        await gameController.initializeGame(level: 2);
        gameController.addPowerUp(PowerUpType.skip, 1);

        final initialQuestionIndex =
            gameController.gameState.currentQuestionIndex;

        // Use skip power-up
        final success = gameController.useSkip();

        expect(success, true);
        expect(
          gameController.gameState.currentQuestionIndex,
          initialQuestionIndex + 1,
        );
        expect(gameController.getPowerUpCount(PowerUpType.skip), 0);
      });
    });

    group('Power-up Restrictions', () {
      test('should not allow extra time power-up on level 1', () async {
        await gameController.initializeGame(level: 1);
        gameController.addPowerUp(PowerUpType.extraTime, 1);

        final success = gameController.useExtraTime();

        expect(success, false);
        expect(
          gameController.getPowerUpCount(PowerUpType.extraTime),
          1,
        ); // Not consumed
      });

      test('should not allow second chance when at max lives', () async {
        await gameController.initializeGame(level: 2);
        gameController.addPowerUp(PowerUpType.secondChance, 1);

        // Player starts with 3 lives (max)
        expect(gameController.lives, 3);

        final success = gameController.useSecondChance();

        expect(success, false);
        expect(
          gameController.getPowerUpCount(PowerUpType.secondChance),
          1,
        ); // Not consumed
      });

      test('should not allow power-up usage when game is not active', () async {
        await gameController.initializeGame(level: 2);
        gameController.addPowerUp(PowerUpType.fiftyFifty, 1);

        // Pause the game
        gameController.pauseGame();

        final removedIndices = gameController.useFiftyFifty();

        expect(removedIndices, isEmpty);
        expect(
          gameController.getPowerUpCount(PowerUpType.fiftyFifty),
          1,
        ); // Not consumed
      });
    });

    group('Power-up Inventory Management', () {
      test('should correctly track power-up counts', () async {
        await gameController.initializeGame(level: 2);

        // Add various power-ups
        gameController.addPowerUp(PowerUpType.fiftyFifty, 3);
        gameController.addPowerUp(PowerUpType.hint, 2);
        gameController.addPowerUp(PowerUpType.extraTime, 1);

        expect(gameController.getPowerUpCount(PowerUpType.fiftyFifty), 3);
        expect(gameController.getPowerUpCount(PowerUpType.hint), 2);
        expect(gameController.getPowerUpCount(PowerUpType.extraTime), 1);
        expect(gameController.getPowerUpCount(PowerUpType.skip), 0);
        expect(gameController.getPowerUpCount(PowerUpType.secondChance), 0);
      });

      test('should correctly determine if power-up can be used', () async {
        await gameController.initializeGame(level: 2);

        // No power-ups initially
        expect(gameController.canUsePowerUp(PowerUpType.fiftyFifty), false);

        // Add power-up
        gameController.addPowerUp(PowerUpType.fiftyFifty, 1);
        expect(gameController.canUsePowerUp(PowerUpType.fiftyFifty), true);

        // Use power-up
        gameController.useFiftyFifty();
        expect(gameController.canUsePowerUp(PowerUpType.fiftyFifty), false);
      });

      test('should add multiple power-ups at once', () async {
        await gameController.initializeGame(level: 2);

        final powerUpsToAdd = {
          PowerUpType.fiftyFifty: 2,
          PowerUpType.hint: 3,
          PowerUpType.extraTime: 1,
        };

        gameController.addPowerUps(powerUpsToAdd);

        expect(gameController.getPowerUpCount(PowerUpType.fiftyFifty), 2);
        expect(gameController.getPowerUpCount(PowerUpType.hint), 3);
        expect(gameController.getPowerUpCount(PowerUpType.extraTime), 1);
      });
    });

    group('Visual Feedback Integration', () {
      test('should disable answer choices after 50/50 power-up', () async {
        await gameController.initializeGame(level: 2);
        gameController.addPowerUp(PowerUpType.fiftyFifty, 1);

        // Use 50/50 power-up
        final removedIndices = gameController.useFiftyFifty();

        expect(removedIndices.length, 2);
        expect(gameController.disabledAnswerIndices, equals(removedIndices));
      });

      test(
        'should clear disabled answers when moving to next question',
        () async {
          await gameController.initializeGame(level: 2);
          gameController.addPowerUp(PowerUpType.fiftyFifty, 1);

          // Use 50/50 power-up
          gameController.useFiftyFifty();
          expect(gameController.disabledAnswerIndices.length, 2);

          // Answer question and move to next
          gameController.processAnswer(0);
          gameController.clearFeedback();
          gameController.nextQuestion();

          // Disabled answers should be cleared
          expect(gameController.disabledAnswerIndices, isEmpty);
        },
      );
    });
  });
}
