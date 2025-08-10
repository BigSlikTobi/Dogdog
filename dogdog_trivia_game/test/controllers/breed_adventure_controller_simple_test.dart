import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/models/models.dart';
import 'package:dogdog_trivia_game/controllers/breed_adventure_controller.dart';
import 'package:dogdog_trivia_game/controllers/breed_adventure_power_up_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BreedAdventureController Core Tests', () {
    late BreedAdventureController controller;

    setUp(() {
      controller = BreedAdventureController();
    });

    tearDown(() {
      try {
        controller.dispose();
      } catch (e) {
        // Ignore disposal errors in tests
      }
    });

    group('Initialization and Basic Properties', () {
      test('should initialize with correct default values', () {
        expect(controller.isInitialized, isFalse);
        expect(controller.isGameActive, isFalse);
        expect(controller.currentScore, equals(0));
        expect(controller.correctAnswers, equals(0));
        expect(controller.currentPhase, equals(DifficultyPhase.beginner));
        expect(controller.currentChallenge, isNull);
        expect(controller.livesRemaining, equals(3));
        expect(controller.accuracy, equals(0.0));
      });

      test('should have correct configuration constants', () {
        expect(BreedAdventureController.baseScore, equals(100));
        expect(BreedAdventureController.timeBonus, equals(10));
        expect(BreedAdventureController.streakBonus, equals(50));
        expect(BreedAdventureController.powerUpRewardThreshold, equals(5));
        expect(BreedAdventureController.maxLives, equals(3));
      });

      test('should provide access to game state', () {
        final gameState = controller.gameState;

        expect(gameState, isA<BreedAdventureGameState>());
        expect(gameState.score, equals(0));
        expect(gameState.correctAnswers, equals(0));
        expect(gameState.totalQuestions, equals(0));
        expect(gameState.currentPhase, equals(DifficultyPhase.beginner));
        expect(gameState.isGameActive, isFalse);
      });

      test('should provide access to power-up inventory', () {
        final powerUps = controller.powerUpInventory;

        expect(powerUps, isA<Map<PowerUpType, int>>());
        expect(powerUps.length, equals(PowerUpType.values.length));
      });
    });

    group('Game Statistics', () {
      test('should provide comprehensive game statistics', () {
        final stats = controller.getGameStatistics();

        expect(stats, isA<GameStatistics>());
        expect(stats.score, equals(0));
        expect(stats.correctAnswers, equals(0));
        expect(stats.totalQuestions, equals(0));
        expect(stats.accuracy, equals(0.0));
        expect(stats.currentPhase, equals(DifficultyPhase.beginner));
        expect(stats.gameDuration, equals(0));
        expect(stats.powerUpsUsed, greaterThanOrEqualTo(0));
        expect(stats.livesRemaining, equals(3));
      });

      test('should format statistics string correctly', () {
        final stats = controller.getGameStatistics();
        final statsString = stats.toString();

        expect(statsString, contains('score: 0'));
        expect(statsString, contains('correctAnswers: 0'));
        expect(statsString, contains('accuracy: 0.0%'));
        expect(statsString, contains('livesRemaining: 3'));
      });
    });

    group('State Management', () {
      test('should reset to initial state', () {
        controller.reset();

        expect(controller.isGameActive, isFalse);
        expect(controller.currentScore, equals(0));
        expect(controller.correctAnswers, equals(0));
        expect(controller.currentChallenge, isNull);
        expect(controller.currentPhase, equals(DifficultyPhase.beginner));
      });

      test('should handle pause and resume when game is not active', () {
        // Should not throw when game is not active
        controller.pauseGame();
        controller.resumeGame();

        expect(controller.isGameActive, isFalse);
      });

      test('should handle end game when game is not active', () async {
        // Should not throw when game is not active
        await controller.endGame();

        expect(controller.isGameActive, isFalse);
      });
    });

    group('Power-up System Integration', () {
      test('should not use power-ups when game is not active', () async {
        final success = await controller.usePowerUp(PowerUpType.hint);

        expect(success, isFalse);
      });

      test('should handle power-up usage attempts gracefully', () async {
        // Should not throw even when conditions are not met
        await controller.usePowerUp(PowerUpType.hint);
        await controller.usePowerUp(PowerUpType.extraTime);
        await controller.usePowerUp(PowerUpType.skip);
        await controller.usePowerUp(PowerUpType.secondChance);
        await controller.usePowerUp(PowerUpType.fiftyFifty);

        // No exceptions should be thrown
      });
    });

    group('Timer Integration', () {
      test('should provide time remaining access', () {
        final timeRemaining = controller.timeRemaining;

        expect(timeRemaining, isA<int>());
        expect(timeRemaining, greaterThanOrEqualTo(0));
      });
    });

    group('Error Handling', () {
      test('should handle image selection when game is not active', () async {
        // Should not throw when game is not active
        await controller.selectImage(0);
        await controller.selectImage(1);

        expect(controller.currentScore, equals(0));
      });

      test(
        'should handle invalid image selection indices gracefully',
        () async {
          // Should not throw for invalid indices
          await controller.selectImage(-1);
          await controller.selectImage(2);
          await controller.selectImage(999);

          expect(controller.currentScore, equals(0));
        },
      );

      test(
        'should throw error when starting game without initialization',
        () async {
          expect(
            () async => await controller.startGame(),
            throwsA(isA<StateError>()),
          );
        },
      );
    });

    group('Difficulty Phase Logic', () {
      test('should start with beginner phase', () {
        expect(controller.currentPhase, equals(DifficultyPhase.beginner));
      });

      test('should provide access to phase properties', () {
        final phase = controller.currentPhase;

        expect(phase.difficulties, equals([1, 2]));
        expect(phase.scoreMultiplier, equals(1));
        expect(phase.name, equals('Beginner'));
      });
    });

    group('Disposal and Cleanup', () {
      test('should dispose properly', () {
        // Create a separate controller for this test
        final testController = BreedAdventureController();
        testController.dispose();
        // Should not throw
      });

      test('should handle multiple dispose calls', () {
        // Create a separate controller for this test
        final testController = BreedAdventureController();
        testController.dispose();

        // Second dispose should throw FlutterError (expected behavior)
        expect(() => testController.dispose(), throwsA(isA<FlutterError>()));
      });
    });

    group('Game State Properties', () {
      test('should calculate lives remaining correctly', () {
        expect(controller.livesRemaining, equals(3));

        // Lives remaining is based on incorrect answers
        // Since no game is active, should remain at max
      });

      test('should provide game duration access', () {
        final duration = controller.gameDurationSeconds;

        expect(duration, isA<int>());
        expect(duration, greaterThanOrEqualTo(0));
      });

      test('should provide accuracy calculation', () {
        final accuracy = controller.accuracy;

        expect(accuracy, isA<double>());
        expect(accuracy, greaterThanOrEqualTo(0.0));
        expect(accuracy, lessThanOrEqualTo(100.0));
      });
    });

    group('Configuration Validation', () {
      test('should have reasonable configuration values', () {
        expect(BreedAdventureController.baseScore, greaterThan(0));
        expect(BreedAdventureController.timeBonus, greaterThan(0));
        expect(BreedAdventureController.streakBonus, greaterThan(0));
        expect(BreedAdventureController.powerUpRewardThreshold, greaterThan(0));
        expect(BreedAdventureController.maxLives, greaterThan(0));
      });
    });

    group('Dependency Injection', () {
      test('should accept custom dependencies', () {
        final customPowerUpController = BreedAdventurePowerUpController();

        final customController = BreedAdventureController(
          powerUpController: customPowerUpController,
        );

        expect(customController, isA<BreedAdventureController>());
        customController.dispose();
      });

      test('should use default dependencies when none provided', () {
        final defaultController = BreedAdventureController();

        expect(defaultController, isA<BreedAdventureController>());
        expect(
          defaultController.powerUpInventory,
          isA<Map<PowerUpType, int>>(),
        );

        defaultController.dispose();
      });
    });
  });

  group('GameStatistics Tests', () {
    test('should create statistics with all required fields', () {
      const stats = GameStatistics(
        score: 1500,
        correctAnswers: 10,
        totalQuestions: 12,
        accuracy: 83.3,
        currentPhase: DifficultyPhase.intermediate,
        gameDuration: 120,
        powerUpsUsed: 3,
        livesRemaining: 2,
      );

      expect(stats.score, equals(1500));
      expect(stats.correctAnswers, equals(10));
      expect(stats.totalQuestions, equals(12));
      expect(stats.accuracy, equals(83.3));
      expect(stats.currentPhase, equals(DifficultyPhase.intermediate));
      expect(stats.gameDuration, equals(120));
      expect(stats.powerUpsUsed, equals(3));
      expect(stats.livesRemaining, equals(2));
    });

    test('should provide readable string representation', () {
      const stats = GameStatistics(
        score: 1500,
        correctAnswers: 10,
        totalQuestions: 12,
        accuracy: 83.3,
        currentPhase: DifficultyPhase.intermediate,
        gameDuration: 120,
        powerUpsUsed: 3,
        livesRemaining: 2,
      );

      final statsString = stats.toString();

      expect(statsString, contains('score: 1500'));
      expect(statsString, contains('correctAnswers: 10'));
      expect(statsString, contains('totalQuestions: 12'));
      expect(statsString, contains('accuracy: 83.3%'));
      expect(statsString, contains('phase: DifficultyPhase.intermediate'));
      expect(statsString, contains('duration: 120s'));
      expect(statsString, contains('powerUpsUsed: 3'));
      expect(statsString, contains('livesRemaining: 2'));
    });
  });
}
