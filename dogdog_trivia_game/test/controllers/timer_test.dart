import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('Timer System Tests', () {
    late GameController gameController;

    setUp(() {
      gameController = GameController();
    });

    tearDown(() {
      // Ensure timer is stopped before disposing
      gameController.pauseGame();
      gameController.dispose();
    });

    group('Timer Initialization', () {
      test('should not activate timer for level 1', () async {
        await gameController.initializeGame(level: 1);

        expect(gameController.isTimerActive, false);
        expect(gameController.timeRemaining, 0);
      });

      test('should activate timer for level 2 with 20 seconds', () async {
        await gameController.initializeGame(level: 2);

        expect(gameController.isTimerActive, true);
        expect(gameController.timeRemaining, 20);
      });

      test('should activate timer for level 3 with 15 seconds', () async {
        await gameController.initializeGame(level: 3);

        expect(gameController.isTimerActive, true);
        expect(gameController.timeRemaining, 15);
      });

      test('should activate timer for level 4 with 12 seconds', () async {
        await gameController.initializeGame(level: 4);

        expect(gameController.isTimerActive, true);
        expect(gameController.timeRemaining, 12);
      });

      test('should activate timer for level 5 with 10 seconds', () async {
        await gameController.initializeGame(level: 5);

        expect(gameController.isTimerActive, true);
        expect(gameController.timeRemaining, 10);
      });
    });

    group('Timer State Management', () {
      test('should pause timer when game is paused', () async {
        await gameController.initializeGame(level: 2);

        expect(gameController.isGameActive, true);
        expect(gameController.isTimerActive, true);

        // Pause the game
        gameController.pauseGame();
        expect(gameController.isGameActive, false);
      });

      test('should resume timer when game is resumed', () async {
        await gameController.initializeGame(level: 2);

        // Pause the game
        gameController.pauseGame();
        expect(gameController.isGameActive, false);

        // Resume the game
        gameController.resumeGame();
        expect(gameController.isGameActive, true);
      });

      test('should not resume timer if game is over', () async {
        await gameController.initializeGame(level: 2);

        // Simulate game over by losing all lives
        while (gameController.lives > 0) {
          gameController.processAnswer(1); // Wrong answer
          gameController.clearFeedback();
          if (!gameController.isGameOver) {
            gameController.nextQuestion();
          }
        }

        expect(gameController.isGameOver, true);

        // Try to resume - should not work
        gameController.resumeGame();
        expect(gameController.isGameActive, false);
      });
    });

    group('Extra Time Power-up Integration', () {
      test('should add extra time when power-up is used', () async {
        await gameController.initializeGame(level: 2);

        // Add extra time power-up to inventory
        gameController.addPowerUp(PowerUpType.extraTime, 1);

        final timeBeforePowerUp = gameController.timeRemaining;

        // Use extra time power-up
        final success = gameController.useExtraTime();
        expect(success, true);

        // Should have 10 more seconds
        expect(gameController.timeRemaining, timeBeforePowerUp + 10);

        // Power-up should be consumed
        expect(gameController.getPowerUpCount(PowerUpType.extraTime), 0);
      });

      test(
        'should not allow extra time power-up on non-timed levels',
        () async {
          await gameController.initializeGame(level: 1);

          // Add extra time power-up to inventory
          gameController.addPowerUp(PowerUpType.extraTime, 1);

          // Try to use extra time power-up
          final success = gameController.useExtraTime();
          expect(success, false);

          // Power-up should not be consumed
          expect(gameController.getPowerUpCount(PowerUpType.extraTime), 1);
        },
      );

      test(
        'should not allow extra time power-up when game is not active',
        () async {
          await gameController.initializeGame(level: 2);

          // Add extra time power-up to inventory
          gameController.addPowerUp(PowerUpType.extraTime, 1);

          // Pause the game
          gameController.pauseGame();

          // Try to use extra time power-up
          final success = gameController.useExtraTime();
          expect(success, false);

          // Power-up should not be consumed
          expect(gameController.getPowerUpCount(PowerUpType.extraTime), 1);
        },
      );

      test(
        'should not allow extra time power-up when no power-ups available',
        () async {
          await gameController.initializeGame(level: 2);

          // Try to use extra time power-up without having any
          final success = gameController.useExtraTime();
          expect(success, false);
        },
      );
    });

    group('Timer Logic', () {
      test('should reset timer when moving to next question', () async {
        await gameController.initializeGame(level: 2);

        // Answer a question correctly
        gameController.processAnswer(0); // Assuming first answer is correct
        gameController.clearFeedback();
        gameController.nextQuestion();

        expect(gameController.timeRemaining, 20); // Reset to full time
      });

      test('should reset timer correctly after game restart', () async {
        await gameController.initializeGame(level: 3);

        // Restart game
        await gameController.restartGame();

        // Timer should be reset to full time
        expect(gameController.timeRemaining, 15);
        expect(gameController.isTimerActive, true);
      });
    });

    group('Timer Visual Feedback', () {
      test('should provide correct timer progress calculation', () async {
        await gameController.initializeGame(level: 2);

        final totalTime = gameController.gameState.timeLimitForLevel;
        expect(totalTime, 20);

        // At start, progress should be 1.0 (full time)
        final initialProgress = gameController.timeRemaining / totalTime;
        expect(initialProgress, 1.0);
      });

      test('should handle timer limits correctly for all levels', () async {
        // Test all level timer limits
        final expectedTimes = {1: 0, 2: 20, 3: 15, 4: 12, 5: 10};

        for (final entry in expectedTimes.entries) {
          await gameController.initializeGame(level: entry.key);
          expect(gameController.gameState.timeLimitForLevel, entry.value);
          expect(gameController.timeRemaining, entry.value);
          expect(gameController.isTimerActive, entry.value > 0);
        }
      });
    });
  });
}
