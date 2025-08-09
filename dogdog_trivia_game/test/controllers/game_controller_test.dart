import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/controllers/persistent_timer_controller.dart';
import 'package:dogdog_trivia_game/services/question_service.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('GameController', () {
    late GameController gameController;
    late QuestionService questionService;

    setUp(() async {
      questionService = QuestionService();
      await questionService.initialize();
      final timerController = PersistentTimerController();
      gameController = GameController(
        questionService: questionService,
        timerController: timerController,
      );
    });

    tearDown(() {
      gameController.dispose();
    });

    test('should initialize with default game state', () {
      expect(gameController.isGameActive, isFalse);
      expect(gameController.isGameOver, isFalse);
      expect(gameController.score, 0);
      expect(gameController.lives, 3);
      expect(gameController.streak, 0);
      expect(gameController.level, 1);
      expect(gameController.currentQuestion, isNull);
    });

    test('should initialize game and load first question', () async {
      await gameController.initializeGame(level: 1);

      expect(gameController.isGameActive, isTrue);
      expect(gameController.currentQuestion, isNotNull);
      expect(gameController.level, 1);
      expect(gameController.lives, 3);
    });

    test('should handle correct answer', () async {
      await gameController.initializeGame(level: 1);
      final question = gameController.currentQuestion!;
      final correctAnswerIndex = question.correctAnswerIndex;

      final initialScore = gameController.score;
      final initialStreak = gameController.streak;

      final wasCorrect = gameController.processAnswer(correctAnswerIndex);

      expect(wasCorrect, isTrue);
      expect(gameController.score, greaterThan(initialScore));
      expect(gameController.streak, initialStreak + 1);
      expect(gameController.lives, 3); // Lives should not decrease
    });

    test('should handle incorrect answer', () async {
      await gameController.initializeGame(level: 1);
      final question = gameController.currentQuestion!;

      // Find an incorrect answer index
      int incorrectIndex = 0;
      if (incorrectIndex == question.correctAnswerIndex) {
        incorrectIndex = 1;
      }

      final initialLives = gameController.lives;

      final wasCorrect = gameController.processAnswer(incorrectIndex);

      expect(wasCorrect, isFalse);
      expect(gameController.lives, initialLives - 1);
      expect(gameController.streak, 0); // Streak should reset
    });

    test('should end game when lives reach zero', () async {
      await gameController.initializeGame(level: 1);

      // Answer incorrectly until lives are depleted
      while (gameController.lives > 0 && !gameController.isGameOver) {
        final question = gameController.currentQuestion!;
        int incorrectIndex = 0;
        if (incorrectIndex == question.correctAnswerIndex) {
          incorrectIndex = 1;
        }
        gameController.processAnswer(incorrectIndex);
        if (gameController.lives > 0) {
          gameController.nextQuestion();
        }
      }

      expect(gameController.isGameOver, isTrue);
      expect(gameController.isGameActive, isFalse);
    });

    test('should reset game state', () async {
      await gameController.initializeGame(level: 1);
      gameController.processAnswer(0); // Answer a question

      gameController.resetGame();

      expect(gameController.isGameActive, isFalse);
      expect(gameController.isGameOver, isFalse);
      expect(gameController.score, 0);
      expect(gameController.lives, 3);
      expect(gameController.streak, 0);
      expect(gameController.currentQuestion, isNull);
    });

    test('should support power-ups', () async {
      await gameController.initializeGame(level: 1);

      // Add some power-ups
      gameController.addPowerUp(PowerUpType.hint, 2);
      gameController.addPowerUp(PowerUpType.fiftyFifty, 1);

      expect(gameController.powerUps[PowerUpType.hint], 2);
      expect(gameController.powerUps[PowerUpType.fiftyFifty], 1);
      expect(gameController.canUsePowerUp(PowerUpType.hint), isTrue);
    });
  });
}
