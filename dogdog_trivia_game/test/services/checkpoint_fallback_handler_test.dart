import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/models/question.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/controllers/treasure_map_controller.dart';
import 'package:dogdog_trivia_game/controllers/power_up_controller.dart';
import 'package:dogdog_trivia_game/services/checkpoint_fallback_handler.dart';
import 'package:dogdog_trivia_game/services/question_service.dart';

void main() {
  group('CheckpointFallbackHandler', () {
    late CheckpointFallbackHandler fallbackHandler;
    late GameController gameController;
    late TreasureMapController treasureMapController;
    late PowerUpController powerUpController;
    late QuestionService questionService;

    setUp(() async {
      fallbackHandler = CheckpointFallbackHandler();
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

    group('handleGameOver', () {
      test('should reset to last checkpoint when checkpoint exists', () {
        // Arrange
        treasureMapController.initializePath(PathType.dogBreeds);
        treasureMapController.completeCheckpoint(Checkpoint.chihuahua);

        // Act
        final result = fallbackHandler.handleGameOver(
          gameController: gameController,
          treasureMapController: treasureMapController,
          powerUpController: powerUpController,
        );

        // Assert
        expect(result.action, equals(FallbackAction.resetToCheckpoint));
        expect(result.checkpoint, equals(Checkpoint.chihuahua));
        expect(result.restoredLives, equals(3));
        expect(result.awardedPowerUps.isNotEmpty, isTrue);
        expect(result.message.contains('Chihuahua checkpoint'), isTrue);
      });

      test('should restart from beginning when no checkpoints exist', () {
        // Arrange
        treasureMapController.initializePath(PathType.dogBreeds);
        // No checkpoints completed

        // Act
        final result = fallbackHandler.handleGameOver(
          gameController: gameController,
          treasureMapController: treasureMapController,
          powerUpController: powerUpController,
        );

        // Assert
        expect(result.action, equals(FallbackAction.restartFromBeginning));
        expect(result.checkpoint, isNull);
        expect(result.restoredLives, equals(3));
        expect(result.awardedPowerUps.isEmpty, isTrue);
        expect(result.message.contains('Starting fresh'), isTrue);
      });

      test('should handle different checkpoint types correctly', () {
        // Test each checkpoint type
        final checkpoints = [
          Checkpoint.chihuahua,
          Checkpoint.cockerSpaniel,
          Checkpoint.germanShepherd,
          Checkpoint.greatDane,
          Checkpoint.deutscheDogge,
        ];

        for (final checkpoint in checkpoints) {
          // Arrange
          treasureMapController.initializePath(PathType.dogBreeds);
          treasureMapController.completeCheckpoint(checkpoint);

          // Act
          final result = fallbackHandler.handleGameOver(
            gameController: gameController,
            treasureMapController: treasureMapController,
            powerUpController: powerUpController,
          );

          // Assert
          expect(result.action, equals(FallbackAction.resetToCheckpoint));
          expect(result.checkpoint, equals(checkpoint));
          expect(result.restoredLives, equals(3));
          expect(result.message.isNotEmpty, isTrue);
          expect(result.message.toLowerCase().contains('checkpoint'), isTrue);
        }
      });

      test('should award appropriate power-ups for checkpoint fallback', () {
        // Arrange
        treasureMapController.initializePath(PathType.dogBreeds);
        treasureMapController.completeCheckpoint(Checkpoint.germanShepherd);

        // Act
        final result = fallbackHandler.handleGameOver(
          gameController: gameController,
          treasureMapController: treasureMapController,
          powerUpController: powerUpController,
        );

        // Assert
        expect(result.awardedPowerUps.isNotEmpty, isTrue);
        expect(
          result.awardedPowerUps.containsKey(PowerUpType.fiftyFifty),
          isTrue,
        );
        expect(result.awardedPowerUps.containsKey(PowerUpType.hint), isTrue);
        expect(
          result.awardedPowerUps.containsKey(PowerUpType.extraTime),
          isTrue,
        );
        expect(result.awardedPowerUps.containsKey(PowerUpType.skip), isTrue);
        expect(
          result.awardedPowerUps.containsKey(PowerUpType.secondChance),
          isTrue,
        );
      });
    });

    group('canPerformCheckpointFallback', () {
      test('should return true when checkpoint exists', () {
        // Arrange
        treasureMapController.initializePath(PathType.dogBreeds);
        treasureMapController.completeCheckpoint(Checkpoint.chihuahua);

        // Act
        final canFallback = fallbackHandler.canPerformCheckpointFallback(
          treasureMapController: treasureMapController,
        );

        // Assert
        expect(canFallback, isTrue);
      });

      test('should return false when no checkpoints exist', () {
        // Arrange
        treasureMapController.initializePath(PathType.dogBreeds);
        // No checkpoints completed

        // Act
        final canFallback = fallbackHandler.canPerformCheckpointFallback(
          treasureMapController: treasureMapController,
        );

        // Assert
        expect(canFallback, isFalse);
      });
    });

    group('getQuestionsForCheckpointRestart', () {
      test('should return questions for checkpoint restart', () {
        // Act
        final questions = fallbackHandler.getQuestionsForCheckpointRestart(
          pathType: PathType.dogBreeds,
          checkpoint: Checkpoint.chihuahua,
          excludeQuestionIds: <String>{},
          count: 5,
        );

        // Assert
        expect(questions.length, equals(5));
      });

      test('should exclude specified question IDs', () {
        // Arrange
        final initialQuestions = fallbackHandler
            .getQuestionsForCheckpointRestart(
              pathType: PathType.dogBreeds,
              checkpoint: Checkpoint.chihuahua,
              excludeQuestionIds: <String>{},
              count: 3,
            );
        final excludeIds = initialQuestions.map((q) => q.id).toSet();

        // Act
        final newQuestions = fallbackHandler.getQuestionsForCheckpointRestart(
          pathType: PathType.dogBreeds,
          checkpoint: Checkpoint.chihuahua,
          excludeQuestionIds: excludeIds,
          count: 3,
        );

        // Assert
        final newQuestionIds = newQuestions.map((q) => q.id).toSet();
        expect(newQuestionIds.intersection(excludeIds).isEmpty, isTrue);
      });

      test(
        'should provide appropriate difficulty for different checkpoints',
        () {
          final checkpoints = [
            Checkpoint.chihuahua,
            Checkpoint.cockerSpaniel,
            Checkpoint.germanShepherd,
            Checkpoint.greatDane,
            Checkpoint.deutscheDogge,
          ];

          for (final checkpoint in checkpoints) {
            // Act
            final questions = fallbackHandler.getQuestionsForCheckpointRestart(
              pathType: PathType.dogBreeds,
              checkpoint: checkpoint,
              excludeQuestionIds: <String>{},
              count: 10,
            );

            // Assert
            expect(questions.length, equals(10));

            // For early checkpoints, should have more easy questions
            if (checkpoint == Checkpoint.chihuahua) {
              final easyCount = questions
                  .where((q) => q.difficulty == Difficulty.easy)
                  .length;
              final expertCount = questions
                  .where((q) => q.difficulty == Difficulty.expert)
                  .length;
              expect(easyCount, greaterThanOrEqualTo(expertCount));
            }
          }
        },
      );
    });

    group('hasEnoughQuestionsForRestart', () {
      test('should return true when enough questions are available', () {
        // Act
        final hasEnough = fallbackHandler.hasEnoughQuestionsForRestart(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: <String>{},
          requiredCount: 5,
        );

        // Assert
        expect(hasEnough, isTrue);
      });

      test('should return false when not enough questions are available', () {
        // Arrange - create a large exclude set
        final allQuestions = <Question>[];
        for (final difficulty in Difficulty.values) {
          allQuestions.addAll(
            questionService.getQuestionsByDifficulty(difficulty),
          );
        }
        final excludeIds = allQuestions
            .take(allQuestions.length - 2) // Leave only 2 questions
            .map((q) => q.id)
            .toSet();

        // Act
        final hasEnough = fallbackHandler.hasEnoughQuestionsForRestart(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: excludeIds,
          requiredCount: 10,
        );

        // Assert
        expect(hasEnough, isFalse);
      });
    });

    group('getFallbackStatistics', () {
      test(
        'should return comprehensive statistics for checkpoint fallback',
        () {
          // Arrange
          treasureMapController.initializePath(PathType.dogBreeds);
          treasureMapController.completeCheckpoint(Checkpoint.chihuahua);

          final result = fallbackHandler.handleGameOver(
            gameController: gameController,
            treasureMapController: treasureMapController,
            powerUpController: powerUpController,
          );

          // Act
          final stats = fallbackHandler.getFallbackStatistics(
            result: result,
            treasureMapController: treasureMapController,
          );

          // Assert
          expect(stats['action'], equals('resetToCheckpoint'));
          expect(stats['checkpoint'], equals('Chihuahua'));
          expect(stats['currentPath'], equals('Dog Breeds'));
          expect(stats['completedCheckpoints'], equals(1));
          expect(stats['restoredLives'], equals(3));
          expect(stats['awardedPowerUps'], greaterThan(0));
          expect(stats['message'], isA<String>());
        },
      );

      test('should return statistics for path restart', () {
        // Arrange
        treasureMapController.initializePath(PathType.dogTraining);
        // No checkpoints completed

        final result = fallbackHandler.handleGameOver(
          gameController: gameController,
          treasureMapController: treasureMapController,
          powerUpController: powerUpController,
        );

        // Act
        final stats = fallbackHandler.getFallbackStatistics(
          result: result,
          treasureMapController: treasureMapController,
        );

        // Assert
        expect(stats['action'], equals('restartFromBeginning'));
        expect(stats['checkpoint'], isNull);
        expect(stats['currentPath'], equals('Dog Training'));
        expect(stats['completedCheckpoints'], equals(0));
        expect(stats['restoredLives'], equals(3));
        expect(stats['awardedPowerUps'], equals(0));
      });
    });

    group('fallback messages', () {
      test('should provide appropriate messages for each checkpoint', () {
        final checkpoints = [
          Checkpoint.chihuahua,
          Checkpoint.cockerSpaniel,
          Checkpoint.germanShepherd,
          Checkpoint.greatDane,
          Checkpoint.deutscheDogge,
        ];

        for (final checkpoint in checkpoints) {
          // Arrange
          treasureMapController.initializePath(PathType.dogBreeds);
          treasureMapController.completeCheckpoint(checkpoint);

          // Act
          final result = fallbackHandler.handleGameOver(
            gameController: gameController,
            treasureMapController: treasureMapController,
            powerUpController: powerUpController,
          );

          // Assert
          expect(result.message.isNotEmpty, isTrue);
          expect(result.message.toLowerCase().contains('checkpoint'), isTrue);
          expect(result.message.toLowerCase().contains('power-up'), isTrue);
        }
      });

      test('should provide encouraging messages for path restart', () {
        // Arrange
        treasureMapController.initializePath(PathType.dogHistory);

        // Act
        final result = fallbackHandler.handleGameOver(
          gameController: gameController,
          treasureMapController: treasureMapController,
          powerUpController: powerUpController,
        );

        // Assert
        expect(result.message.contains('Dog History'), isTrue);
        expect(result.message.toLowerCase().contains('fresh'), isTrue);
        expect(result.message.toLowerCase().contains('luck'), isTrue);
      });
    });

    group('error handling', () {
      test('should handle singleton instance correctly', () {
        // Act
        final instance1 = CheckpointFallbackHandler();
        final instance2 = CheckpointFallbackHandler();

        // Assert
        expect(identical(instance1, instance2), isTrue);
      });

      test('should handle edge cases gracefully', () {
        // Test with minimal setup
        final minimalTreasureMapController = TreasureMapController();
        final minimalPowerUpController = PowerUpController();
        final minimalGameController = GameController();

        // Act & Assert - should not throw
        expect(
          () => fallbackHandler.handleGameOver(
            gameController: minimalGameController,
            treasureMapController: minimalTreasureMapController,
            powerUpController: minimalPowerUpController,
          ),
          returnsNormally,
        );
      });
    });

    group('CheckpointFallbackResult', () {
      test('should create result with all properties', () {
        // Act
        final result = CheckpointFallbackResult(
          action: FallbackAction.resetToCheckpoint,
          checkpoint: Checkpoint.chihuahua,
          message: 'Test message',
          restoredLives: 3,
          awardedPowerUps: {PowerUpType.fiftyFifty: 2},
        );

        // Assert
        expect(result.action, equals(FallbackAction.resetToCheckpoint));
        expect(result.checkpoint, equals(Checkpoint.chihuahua));
        expect(result.message, equals('Test message'));
        expect(result.restoredLives, equals(3));
        expect(result.awardedPowerUps[PowerUpType.fiftyFifty], equals(2));
      });

      test('should have meaningful toString representation', () {
        // Act
        final result = CheckpointFallbackResult(
          action: FallbackAction.resetToCheckpoint,
          checkpoint: Checkpoint.chihuahua,
          message: 'Test message',
          restoredLives: 3,
          awardedPowerUps: {PowerUpType.fiftyFifty: 2},
        );

        // Assert
        final stringRep = result.toString();
        expect(stringRep.contains('resetToCheckpoint'), isTrue);
        expect(stringRep.contains('Chihuahua'), isTrue);
        expect(stringRep.contains('3'), isTrue);
      });
    });

    group('FallbackAction enum', () {
      test('should have all required actions', () {
        // Assert
        expect(FallbackAction.values.length, equals(3));
        expect(
          FallbackAction.values.contains(FallbackAction.resetToCheckpoint),
          isTrue,
        );
        expect(
          FallbackAction.values.contains(FallbackAction.restartFromBeginning),
          isTrue,
        );
        expect(FallbackAction.values.contains(FallbackAction.error), isTrue);
      });
    });
  });
}
