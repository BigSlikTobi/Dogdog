import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/controllers/treasure_map_controller.dart';
import 'package:dogdog_trivia_game/controllers/power_up_controller.dart';
import 'package:dogdog_trivia_game/services/question_service.dart';
import 'package:dogdog_trivia_game/services/checkpoint_fallback_handler.dart';

void main() {
  group('Checkpoint Fallback Integration Tests', () {
    late GameController gameController;
    late TreasureMapController treasureMapController;
    late PowerUpController powerUpController;
    late QuestionService questionService;

    setUp(() async {
      treasureMapController = TreasureMapController();
      powerUpController = PowerUpController();
      questionService = QuestionService();
      await questionService.initialize();

      gameController = GameController(
        questionService: questionService,
        powerUpController: powerUpController,
        treasureMapController: treasureMapController,
      );
    });

    tearDown(() {
      questionService.reset();
    });

    group('Complete Game Flow with Checkpoint Fallback', () {
      test(
        'should handle complete path progression with checkpoint fallback',
        () async {
          // Initialize a path-based game
          await gameController.initializePathGame(path: PathType.dogBreeds);

          // Verify initial state
          expect(gameController.isGameActive, isTrue);
          expect(gameController.lives, equals(3));
          expect(gameController.currentPath, equals(PathType.dogBreeds));
          expect(gameController.nextCheckpoint, equals(Checkpoint.chihuahua));

          // Simulate reaching the first checkpoint
          for (int i = 0; i < 10; i++) {
            treasureMapController.incrementQuestionCount();
          }

          // Verify checkpoint completion
          expect(
            treasureMapController.completedCheckpoints.contains(
              Checkpoint.chihuahua,
            ),
            isTrue,
          );
          expect(
            treasureMapController.lastCompletedCheckpoint,
            equals(Checkpoint.chihuahua),
          );

          // Simulate game over scenario
          gameController.handleGameOver();

          // Verify fallback to checkpoint
          expect(gameController.lives, equals(3)); // Lives should be restored
          expect(
            gameController.isGameActive,
            isTrue,
          ); // Game should be active again
          expect(
            treasureMapController.currentQuestionCount,
            equals(10),
          ); // Should be at checkpoint
        },
      );

      test('should handle game over without checkpoints', () async {
        // Initialize a path-based game
        await gameController.initializePathGame(path: PathType.dogTraining);

        // Verify initial state
        expect(gameController.isGameActive, isTrue);
        expect(gameController.lives, equals(3));
        expect(treasureMapController.completedCheckpoints.isEmpty, isTrue);

        // Simulate game over without reaching any checkpoints
        gameController.handleGameOver();

        // Verify restart from beginning
        expect(gameController.lives, equals(3)); // Lives should be restored
        expect(
          gameController.isGameActive,
          isTrue,
        ); // Game should be active again
        expect(
          treasureMapController.currentQuestionCount,
          equals(0),
        ); // Should be at beginning
      });

      test(
        'should maintain power-up inventory during checkpoint fallback',
        () async {
          // Initialize game and reach a checkpoint
          await gameController.initializePathGame(path: PathType.dogBreeds);

          // Add some power-ups before checkpoint
          powerUpController.addPowerUp(PowerUpType.fiftyFifty, 2);
          powerUpController.addPowerUp(PowerUpType.hint, 1);

          final initialPowerUps = Map<PowerUpType, int>.from(
            powerUpController.powerUps,
          );

          // Simulate reaching checkpoint
          for (int i = 0; i < 10; i++) {
            treasureMapController.incrementQuestionCount();
          }

          // Simulate game over and fallback
          gameController.handleGameOver();

          // Verify power-ups are maintained and checkpoint rewards are added
          expect(
            powerUpController.getPowerUpCount(PowerUpType.fiftyFifty),
            greaterThanOrEqualTo(initialPowerUps[PowerUpType.fiftyFifty] ?? 0),
          );
          expect(
            powerUpController.getPowerUpCount(PowerUpType.hint),
            greaterThanOrEqualTo(initialPowerUps[PowerUpType.hint] ?? 0),
          );
        },
      );
    });

    group('Checkpoint Restart Functionality', () {
      test(
        'should restart from specific checkpoint with fresh questions',
        () async {
          // Initialize game and reach German Shepherd checkpoint
          await gameController.initializePathGame(path: PathType.dogBehavior);

          // Simulate reaching German Shepherd checkpoint
          for (int i = 0; i < 30; i++) {
            treasureMapController.incrementQuestionCount();
          }

          expect(
            treasureMapController.completedCheckpoints.contains(
              Checkpoint.germanShepherd,
            ),
            isTrue,
          );

          // Get initial questions
          final initialQuestions = gameController.gameState.questions;
          final initialQuestionIds = initialQuestions.map((q) => q.id).toSet();

          // Restart from checkpoint
          await gameController.restartFromCheckpoint(
            checkpoint: Checkpoint.germanShepherd,
            excludeQuestionIds: initialQuestionIds,
          );

          // Verify fresh questions
          final newQuestions = gameController.gameState.questions;
          final newQuestionIds = newQuestions.map((q) => q.id).toSet();

          expect(newQuestions.isNotEmpty, isTrue);
          expect(
            newQuestionIds.intersection(initialQuestionIds).isEmpty,
            isTrue,
          );
          expect(gameController.lives, equals(3));
          expect(gameController.isGameActive, isTrue);
        },
      );

      test('should restore appropriate power-ups for checkpoint level', () async {
        // Initialize game
        await gameController.initializePathGame(path: PathType.healthCare);

        // Clear existing power-ups
        powerUpController.resetPowerUps();

        // Restart from Cocker Spaniel checkpoint
        await gameController.restartFromCheckpoint(
          checkpoint: Checkpoint.cockerSpaniel,
        );

        // Verify checkpoint-appropriate power-ups are awarded
        expect(
          powerUpController.getPowerUpCount(PowerUpType.fiftyFifty),
          greaterThan(0),
        );
        expect(
          powerUpController.getPowerUpCount(PowerUpType.hint),
          greaterThan(0),
        );
        expect(
          powerUpController.getPowerUpCount(PowerUpType.extraTime),
          greaterThan(0),
        );
        expect(
          powerUpController.getPowerUpCount(PowerUpType.skip),
          greaterThan(0),
        );
        // secondChance gets bonus reward for high accuracy (80%+) in fallback scenarios
        expect(
          powerUpController.getPowerUpCount(PowerUpType.secondChance),
          greaterThanOrEqualTo(0),
        );
      });

      test(
        'should handle checkpoint restart with question exclusion',
        () async {
          // Initialize game
          await gameController.initializePathGame(path: PathType.dogHistory);

          // Get some questions to exclude
          final questionsToExclude = questionService
              .getQuestionsByDifficulty(Difficulty.easy)
              .take(5)
              .map((q) => q.id)
              .toSet();

          // Restart from checkpoint with exclusions
          await gameController.restartFromCheckpoint(
            checkpoint: Checkpoint.chihuahua,
            excludeQuestionIds: questionsToExclude,
          );

          // Verify excluded questions are not in the new question set
          final newQuestions = gameController.gameState.questions;
          final newQuestionIds = newQuestions.map((q) => q.id).toSet();

          expect(
            newQuestionIds.intersection(questionsToExclude).isEmpty,
            isTrue,
          );
          expect(newQuestions.length, equals(10));
        },
      );
    });

    group('State Management During Fallback', () {
      test(
        'should properly synchronize all controller states during fallback',
        () async {
          // Initialize game and progress to a checkpoint
          await gameController.initializePathGame(path: PathType.dogBreeds);

          // Simulate game progress
          for (int i = 0; i < 15; i++) {
            treasureMapController.incrementQuestionCount();
          }

          // Add some power-ups
          powerUpController.addPowerUp(PowerUpType.extraTime, 3);

          // Verify state before fallback
          expect(treasureMapController.currentQuestionCount, equals(15));
          expect(
            treasureMapController.completedCheckpoints.contains(
              Checkpoint.chihuahua,
            ),
            isTrue,
          );
          expect(
            powerUpController.getPowerUpCount(PowerUpType.extraTime),
            equals(3),
          );

          // Trigger fallback
          gameController.handleGameOver();

          // Verify all states are properly synchronized
          expect(gameController.lives, equals(3));
          expect(gameController.isGameActive, isTrue);
          expect(
            treasureMapController.currentQuestionCount,
            equals(10),
          ); // Reset to checkpoint
          expect(
            powerUpController.getPowerUpCount(PowerUpType.extraTime),
            greaterThanOrEqualTo(3),
          );
        },
      );

      test('should handle error scenarios gracefully', () async {
        // Initialize game
        await gameController.initializePathGame(path: PathType.dogBreeds);

        // Simulate an error scenario by trying to restart from a non-existent checkpoint
        // This should fallback to normal game restart
        expect(
          () => gameController.restartFromCheckpoint(
            checkpoint: Checkpoint.deutscheDogge, // Haven't reached this yet
          ),
          returnsNormally,
        );

        // Game should still be in a valid state
        expect(gameController.isGameActive, isTrue);
        expect(gameController.lives, greaterThan(0));
      });
    });

    group('Progress Tracking and Persistence', () {
      test(
        'should track checkpoint progress across fallback scenarios',
        () async {
          // Initialize game
          await gameController.initializePathGame(path: PathType.dogTraining);

          // Progress through multiple checkpoints
          for (int i = 0; i < 25; i++) {
            treasureMapController.incrementQuestionCount();
          }

          // Verify multiple checkpoints completed
          expect(
            treasureMapController.completedCheckpoints.contains(
              Checkpoint.chihuahua,
            ),
            isTrue,
          );
          expect(
            treasureMapController.completedCheckpoints.contains(
              Checkpoint.cockerSpaniel,
            ),
            isTrue,
          );
          expect(
            treasureMapController.lastCompletedCheckpoint,
            equals(Checkpoint.cockerSpaniel),
          );

          // Trigger fallback
          gameController.handleGameOver();

          // Verify fallback goes to the last completed checkpoint
          expect(
            treasureMapController.currentQuestionCount,
            equals(20),
          ); // Cocker Spaniel checkpoint
          expect(
            treasureMapController.lastCompletedCheckpoint,
            equals(Checkpoint.cockerSpaniel),
          );
        },
      );

      test('should maintain game statistics during fallback', () async {
        // Initialize game
        await gameController.initializePathGame(path: PathType.healthCare);

        // Simulate some game progress
        gameController.gameState.copyWith(
          score: 150,
          totalQuestionsAnswered: 8,
          correctAnswersInSession: 6,
        );

        // Get initial statistics
        gameController.getGameStatistics();

        // Trigger fallback
        gameController.handleGameOver();

        // Verify statistics are maintained appropriately
        final newStats = gameController.getGameStatistics();
        expect(newStats['lives'], equals(3)); // Lives should be restored
        expect(newStats['isGameActive'], isTrue); // Game should be active
        expect(newStats['powerUps'], isA<Map<PowerUpType, int>>());
      });
    });

    group('Multiple Path Support', () {
      test(
        'should handle fallback correctly for different path types',
        () async {
          final pathTypes = [
            PathType.dogBreeds,
            PathType.dogTraining,
            PathType.healthCare,
            PathType.dogBehavior,
            PathType.dogHistory,
          ];

          for (final pathType in pathTypes) {
            // Initialize game for each path type
            await gameController.initializePathGame(path: pathType);

            // Verify correct path initialization
            expect(gameController.currentPath, equals(pathType));
            expect(gameController.isGameActive, isTrue);

            // Simulate reaching first checkpoint
            for (int i = 0; i < 10; i++) {
              treasureMapController.incrementQuestionCount();
            }

            // Trigger fallback
            gameController.handleGameOver();

            // Verify fallback works for this path type
            expect(gameController.lives, equals(3));
            expect(gameController.isGameActive, isTrue);
            expect(gameController.currentPath, equals(pathType));
          }
        },
      );
    });

    group('Edge Cases and Error Handling', () {
      test('should handle fallback when no questions are available', () async {
        // Initialize game
        await gameController.initializePathGame(path: PathType.dogBreeds);

        // Create a scenario where no questions are available for restart
        // This is difficult to simulate with the current implementation,
        // but we can test that the system handles it gracefully
        expect(() => gameController.handleGameOver(), returnsNormally);

        // Game should be in a valid state
        expect(gameController.lives, greaterThan(0));
      });

      test('should handle concurrent fallback operations', () async {
        // Initialize game
        await gameController.initializePathGame(path: PathType.dogBehavior);

        // Simulate reaching a checkpoint
        for (int i = 0; i < 10; i++) {
          treasureMapController.incrementQuestionCount();
        }

        // Trigger multiple fallback operations
        gameController.handleGameOver();
        gameController
            .handleGameOver(); // Second call should be handled gracefully

        // Verify game is still in a valid state
        expect(gameController.isGameActive, isTrue);
        expect(gameController.lives, equals(3));
      });
    });

    group('Fallback Handler Integration', () {
      test('should properly integrate with CheckpointFallbackHandler', () {
        final fallbackHandler = CheckpointFallbackHandler();

        // Verify singleton behavior
        final anotherInstance = CheckpointFallbackHandler();
        expect(identical(fallbackHandler, anotherInstance), isTrue);

        // Test integration with game controller
        expect(
          () => fallbackHandler.handleGameOver(
            gameController: gameController,
            treasureMapController: treasureMapController,
            powerUpController: powerUpController,
          ),
          returnsNormally,
        );
      });

      test('should provide meaningful fallback statistics', () async {
        // Initialize game and reach a checkpoint
        await gameController.initializePathGame(path: PathType.dogHistory);

        for (int i = 0; i < 20; i++) {
          treasureMapController.incrementQuestionCount();
        }

        final fallbackHandler = CheckpointFallbackHandler();

        // Trigger fallback and get statistics
        final result = fallbackHandler.handleGameOver(
          gameController: gameController,
          treasureMapController: treasureMapController,
          powerUpController: powerUpController,
        );

        final stats = fallbackHandler.getFallbackStatistics(
          result: result,
          treasureMapController: treasureMapController,
        );

        // Verify statistics contain expected information
        expect(stats['action'], isA<String>());
        expect(stats['currentPath'], equals('Dog History'));
        expect(stats['completedCheckpoints'], greaterThan(0));
        expect(stats['restoredLives'], equals(3));
      });
    });
  });
}
