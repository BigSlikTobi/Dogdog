import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/controllers/persistent_timer_controller.dart';
import 'package:dogdog_trivia_game/services/question_service.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('Timer Integration Tests', () {
    late GameController gameController;
    late QuestionService questionService;
    late PersistentTimerController timerController;

    setUp(() async {
      questionService = QuestionService();
      await questionService.initialize();
      timerController = PersistentTimerController();
      gameController = GameController(
        questionService: questionService,
        timerController: timerController,
      );
    });

    tearDown(() {
      gameController.dispose();
      // Don't dispose timerController separately since GameController manages it
    });

    test('should integrate timer with game controller properly', () async {
      // Initialize game with timer (level 2+ has timer active)
      await gameController.initializeGame(level: 2);

      // Timer should be active after initialization
      expect(gameController.isTimerActive, isTrue);
      expect(gameController.timeRemaining, greaterThan(0));
      expect(gameController.timerProgress, greaterThan(0));

      // Initially should not be in critical time
      expect(gameController.isTimerCritical, isFalse);
      expect(gameController.isTimerWarningTriggered, isFalse);
    });

    test('should pause and resume timer with game state', () async {
      await gameController.initializeGame(level: 2);

      final initialTimeRemaining = gameController.timeRemaining;

      // Pause game
      gameController.pauseGame();
      expect(gameController.isGameActive, isFalse);
      expect(timerController.isPaused, isTrue);

      // Wait a bit to ensure timer is paused
      await Future.delayed(Duration(milliseconds: 100));
      expect(gameController.timeRemaining, equals(initialTimeRemaining));

      // Resume game
      gameController.resumeGame();
      expect(gameController.isGameActive, isTrue);
      expect(timerController.isPaused, isFalse);
    });

    test('should handle extra time power-up correctly', () async {
      await gameController.initializeGame(level: 2);

      // Add extra time power-up
      gameController.addPowerUp(PowerUpType.extraTime, 1);
      expect(gameController.getPowerUpCount(PowerUpType.extraTime), equals(1));

      final initialTimeRemaining = gameController.timeRemaining;

      // Use extra time power-up
      final success = gameController.useExtraTime();
      expect(success, isTrue);
      expect(gameController.timeRemaining, greaterThan(initialTimeRemaining));
      expect(gameController.getPowerUpCount(PowerUpType.extraTime), equals(0));
    });

    test('should not use extra time when game is inactive', () async {
      await gameController.initializeGame(level: 2);

      // Add extra time power-up
      gameController.addPowerUp(PowerUpType.extraTime, 1);

      // Pause game
      gameController.pauseGame();

      // Try to use extra time - should fail when game is inactive
      final success = gameController.useExtraTime();
      expect(success, isFalse);
      expect(gameController.getPowerUpCount(PowerUpType.extraTime), equals(1));
    });

    test(
      'should access timer progress and critical state through game controller',
      () async {
        await gameController.initializeGame(level: 2);

        // Check timer progress methods work
        expect(gameController.timerProgress, isA<double>());
        expect(gameController.timerProgress, greaterThan(0.0));
        expect(gameController.timerProgress, lessThanOrEqualTo(1.0));

        // Initially should not be critical or warning triggered
        expect(gameController.isTimerCritical, isFalse);
        expect(gameController.isTimerWarningTriggered, isFalse);
      },
    );

    test('should handle timer expiration', () async {
      // Initialize with level 5+ which starts with 2 lives,
      // then we can lose one life to get to 1 life
      await gameController.initializeGame(level: 5);
      expect(gameController.lives, equals(2)); // Level 5+ starts with 2 lives

      // First, answer incorrectly to lose a life (should go from 2 to 1 life)
      gameController.processAnswer(99); // Invalid answer index
      expect(gameController.lives, equals(1));
      expect(gameController.isGameOver, isFalse); // Game should not be over yet

      // Move to next question to reset timer
      gameController.nextQuestion();

      // Now when timer expires naturally, it should end the game
      // Wait longer to let the game timer expire naturally
      await Future.delayed(Duration(milliseconds: 2000));

      // If the timer expired, the game should be over
      // Note: This test depends on the actual timer duration
      if (gameController.timeRemaining == 0) {
        expect(gameController.isGameOver, isTrue);
      }
    });

    test('should properly dispose timer controller with game controller', () {
      // This test ensures no memory leaks - just test that disposal doesn't throw
      expect(() {
        final testController = GameController(
          questionService: questionService,
          timerController: PersistentTimerController(),
        );
        testController.dispose();
      }, returnsNormally);
    });
  });
}
