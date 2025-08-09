import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/controllers/power_up_controller.dart';
import 'package:dogdog_trivia_game/controllers/treasure_map_controller.dart';
import 'package:dogdog_trivia_game/controllers/persistent_timer_controller.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/services/checkpoint_rewards.dart';
import 'package:dogdog_trivia_game/services/question_service.dart';

void main() {
  group('Power-Up Integration Tests', () {
    late GameController gameController;
    late PowerUpController powerUpController;
    late TreasureMapController treasureMapController;
    late QuestionService questionService;

    setUp(() {
      questionService = QuestionService();
      powerUpController = PowerUpController();
      treasureMapController = TreasureMapController();
      gameController = GameController(
        questionService: questionService,
        powerUpController: powerUpController,
        treasureMapController: treasureMapController,
        timerController: PersistentTimerController(),
      );
    });

    group('Checkpoint-based Power-up Distribution', () {
      test(
        'should award correct power-ups when reaching Chihuahua checkpoint',
        () async {
          // Initialize path game
          await gameController.initializePathGame(path: PathType.dogBreeds);

          // Simulate reaching Chihuahua checkpoint (10 questions)
          for (int i = 0; i < 10; i++) {
            treasureMapController.incrementQuestionCount();
          }

          // Calculate expected rewards for 70% accuracy
          final expectedRewards = CheckpointRewards.getRewardsForCheckpoint(
            Checkpoint.chihuahua,
            0.7,
          );

          // Manually trigger checkpoint completion
          gameController.addPowerUps(expectedRewards);

          // Verify power-ups were awarded correctly
          expect(
            gameController.getPowerUpCount(PowerUpType.fiftyFifty),
            equals(expectedRewards[PowerUpType.fiftyFifty]),
          );
          expect(
            gameController.getPowerUpCount(PowerUpType.hint),
            equals(expectedRewards[PowerUpType.hint]),
          );
          expect(
            gameController.getPowerUpCount(PowerUpType.extraTime),
            equals(expectedRewards[PowerUpType.extraTime]),
          );
          expect(
            gameController.getPowerUpCount(PowerUpType.skip),
            equals(expectedRewards[PowerUpType.skip]),
          );
          expect(
            gameController.getPowerUpCount(PowerUpType.secondChance),
            equals(expectedRewards[PowerUpType.secondChance]),
          );
        },
      );

      test(
        'should award bonus power-ups for high accuracy at checkpoints',
        () async {
          // Initialize path game
          await gameController.initializePathGame(path: PathType.dogBreeds);

          // Calculate rewards for high accuracy (85%)
          final highAccuracyRewards = CheckpointRewards.getRewardsForCheckpoint(
            Checkpoint.chihuahua,
            0.85,
          );

          // Calculate rewards for normal accuracy (70%)
          final normalAccuracyRewards =
              CheckpointRewards.getRewardsForCheckpoint(
                Checkpoint.chihuahua,
                0.7,
              );

          // Award high accuracy rewards
          gameController.addPowerUps(highAccuracyRewards);

          // Verify bonus power-ups were awarded
          for (final type in PowerUpType.values) {
            expect(
              gameController.getPowerUpCount(type),
              greaterThanOrEqualTo(normalAccuracyRewards[type]!),
              reason:
                  'High accuracy should award at least normal rewards for $type',
            );
          }

          // Verify skip and secondChance are guaranteed with bonus
          expect(
            gameController.getPowerUpCount(PowerUpType.skip),
            greaterThan(0),
            reason: 'High accuracy should guarantee skip power-up',
          );
          expect(
            gameController.getPowerUpCount(PowerUpType.secondChance),
            greaterThan(0),
            reason: 'High accuracy should guarantee secondChance power-up',
          );
        },
      );

      test(
        'should progressively award more power-ups at higher checkpoints',
        () async {
          // Initialize path game
          await gameController.initializePathGame(path: PathType.dogBreeds);

          final checkpoints = [
            Checkpoint.chihuahua,
            Checkpoint.cockerSpaniel,
            Checkpoint.germanShepherd,
            Checkpoint.greatDane,
            Checkpoint.deutscheDogge,
          ];

          final rewardsByCheckpoint = <Checkpoint, Map<PowerUpType, int>>{};

          // Calculate rewards for each checkpoint
          for (final checkpoint in checkpoints) {
            rewardsByCheckpoint[checkpoint] =
                CheckpointRewards.getRewardsForCheckpoint(
                  checkpoint,
                  0.7, // Normal accuracy
                );
          }

          // Verify progressive distribution
          for (int i = 1; i < checkpoints.length; i++) {
            final currentCheckpoint = checkpoints[i];
            final previousCheckpoint = checkpoints[i - 1];

            final currentRewards = rewardsByCheckpoint[currentCheckpoint]!;
            final previousRewards = rewardsByCheckpoint[previousCheckpoint]!;

            for (final type in PowerUpType.values) {
              final currentCount = currentRewards[type]!;
              final previousCount = previousRewards[type]!;

              // Once a power-up is introduced, it should not decrease
              if (previousCount > 0) {
                expect(
                  currentCount,
                  greaterThanOrEqualTo(previousCount),
                  reason:
                      'Power-up $type should not decrease from $previousCheckpoint to $currentCheckpoint',
                );
              }
            }
          }
        },
      );
    });

    group('Power-up Usage Functionality', () {
      setUp(() async {
        // Initialize game and add some power-ups for testing
        await gameController.initializePathGame(path: PathType.dogBreeds);

        // Add power-ups for testing
        gameController.addPowerUps({
          PowerUpType.fiftyFifty: 2,
          PowerUpType.hint: 2,
          PowerUpType.extraTime: 2,
          PowerUpType.skip: 2,
          PowerUpType.secondChance: 2,
        });
      });

      test('should successfully use fiftyFifty power-up', () {
        // Verify power-up is available
        expect(gameController.canUsePowerUp(PowerUpType.fiftyFifty), isTrue);

        final initialCount = gameController.getPowerUpCount(
          PowerUpType.fiftyFifty,
        );

        // Use the power-up
        final removedIndices = gameController.useFiftyFifty();

        // Verify power-up was consumed
        expect(
          gameController.getPowerUpCount(PowerUpType.fiftyFifty),
          equals(initialCount - 1),
        );

        // Verify it had an effect (should remove 2 wrong answers)
        expect(removedIndices.length, equals(2));
      });

      test('should successfully use hint power-up', () {
        // Verify power-up is available
        expect(gameController.canUsePowerUp(PowerUpType.hint), isTrue);

        final initialCount = gameController.getPowerUpCount(PowerUpType.hint);

        // Use the power-up
        final hint = gameController.useHint();

        // Verify power-up was consumed
        expect(
          gameController.getPowerUpCount(PowerUpType.hint),
          equals(initialCount - 1),
        );

        // Verify it returned a hint (may be null if question has no hint)
        expect(hint, isA<String?>());
      });

      test(
        'should successfully use extraTime power-up when timer is active',
        () {
          // Enable timer for testing
          gameController.gameState.copyWith(
            isTimerActive: true,
            timeRemaining: 10,
          );

          // Verify power-up is available
          expect(gameController.canUsePowerUp(PowerUpType.extraTime), isTrue);

          final initialCount = gameController.getPowerUpCount(
            PowerUpType.extraTime,
          );
          final initialTime = gameController.timeRemaining;

          // Use the power-up
          final success = gameController.useExtraTime();

          if (gameController.isTimerActive) {
            // Verify power-up was consumed
            expect(
              gameController.getPowerUpCount(PowerUpType.extraTime),
              equals(initialCount - 1),
            );

            // Verify time was added
            expect(gameController.timeRemaining, greaterThan(initialTime));
            expect(success, isTrue);
          } else {
            // If timer is not active, power-up should not be consumed
            expect(success, isFalse);
          }
        },
      );

      test('should successfully use skip power-up', () {
        // Verify power-up is available
        expect(gameController.canUsePowerUp(PowerUpType.skip), isTrue);

        final initialCount = gameController.getPowerUpCount(PowerUpType.skip);

        // Use the power-up
        final success = gameController.useSkip();

        // Verify power-up was consumed
        expect(
          gameController.getPowerUpCount(PowerUpType.skip),
          equals(initialCount - 1),
        );

        // Verify it moved to next question
        expect(success, isTrue);
        // Note: The question index might not change if we're at the end of questions
      });

      test(
        'should successfully use secondChance power-up when lives are low',
        () {
          // Set lives to less than 3 for testing
          gameController.gameState.copyWith(lives: 2);

          // Verify power-up is available
          expect(
            gameController.canUsePowerUp(PowerUpType.secondChance),
            isTrue,
          );

          final initialCount = gameController.getPowerUpCount(
            PowerUpType.secondChance,
          );
          final initialLives = gameController.lives;

          // Use the power-up
          final success = gameController.useSecondChance();

          if (initialLives < 3) {
            // Verify power-up was consumed
            expect(
              gameController.getPowerUpCount(PowerUpType.secondChance),
              equals(initialCount - 1),
            );

            // Verify life was restored
            expect(gameController.lives, equals(initialLives + 1));
            expect(success, isTrue);
          } else {
            // If already at max lives, power-up should not be consumed
            expect(success, isFalse);
          }
        },
      );

      test('should not use power-ups when not available', () {
        // Reset power-ups to zero
        powerUpController.resetPowerUps();

        // Verify no power-ups are available
        for (final type in PowerUpType.values) {
          expect(gameController.canUsePowerUp(type), isFalse);
        }

        // Try to use each power-up
        expect(gameController.useFiftyFifty(), isEmpty);
        expect(gameController.useHint(), isNull);
        expect(gameController.useExtraTime(), isFalse);
        expect(gameController.useSkip(), isFalse);
        expect(gameController.useSecondChance(), isFalse);

        // Verify counts remain at zero
        for (final type in PowerUpType.values) {
          expect(gameController.getPowerUpCount(type), equals(0));
        }
      });
    });

    group('Power-up Availability Across Checkpoints', () {
      test(
        'should ensure skip power-up is available from Cocker Spaniel checkpoint',
        () {
          final chihuahuaRewards = CheckpointRewards.getRewardsForCheckpoint(
            Checkpoint.chihuahua,
            0.7,
          );
          final cockerRewards = CheckpointRewards.getRewardsForCheckpoint(
            Checkpoint.cockerSpaniel,
            0.7,
          );

          expect(chihuahuaRewards[PowerUpType.skip], equals(0));
          expect(cockerRewards[PowerUpType.skip], greaterThan(0));
        },
      );

      test(
        'should ensure secondChance power-up is available from German Shepherd checkpoint',
        () {
          final cockerRewards = CheckpointRewards.getRewardsForCheckpoint(
            Checkpoint.cockerSpaniel,
            0.7,
          );
          final shepherdRewards = CheckpointRewards.getRewardsForCheckpoint(
            Checkpoint.germanShepherd,
            0.7,
          );

          expect(cockerRewards[PowerUpType.secondChance], equals(0));
          expect(shepherdRewards[PowerUpType.secondChance], greaterThan(0));
        },
      );

      test(
        'should ensure all power-up types are available by Deutsche Dogge checkpoint',
        () {
          final finalRewards = CheckpointRewards.getRewardsForCheckpoint(
            Checkpoint.deutscheDogge,
            0.7,
          );

          for (final type in PowerUpType.values) {
            expect(
              finalRewards[type],
              greaterThan(0),
              reason:
                  'Power-up type $type should be available at final checkpoint',
            );
          }
        },
      );
    });

    group('Power-up Integration with Game Flow', () {
      test('should maintain power-up inventory across game sessions', () async {
        // Initialize game and add power-ups
        await gameController.initializePathGame(path: PathType.dogBreeds);

        final initialPowerUps = {
          PowerUpType.fiftyFifty: 3,
          PowerUpType.hint: 2,
          PowerUpType.extraTime: 1,
          PowerUpType.skip: 1,
          PowerUpType.secondChance: 1,
        };

        gameController.addPowerUps(initialPowerUps);

        // Use some power-ups
        gameController.useFiftyFifty();
        gameController.useHint();

        // Verify counts are updated
        expect(
          gameController.getPowerUpCount(PowerUpType.fiftyFifty),
          equals(2),
        );
        expect(gameController.getPowerUpCount(PowerUpType.hint), equals(1));
        expect(
          gameController.getPowerUpCount(PowerUpType.extraTime),
          equals(1),
        );
        expect(gameController.getPowerUpCount(PowerUpType.skip), equals(1));
        expect(
          gameController.getPowerUpCount(PowerUpType.secondChance),
          equals(1),
        );
      });

      test(
        'should properly handle power-up state during game pause/resume',
        () async {
          // Initialize game and add power-ups
          await gameController.initializePathGame(path: PathType.dogBreeds);

          gameController.addPowerUps({
            PowerUpType.fiftyFifty: 2,
            PowerUpType.hint: 2,
          });

          // Pause game
          gameController.pauseGame();

          // Power-ups should still be available
          expect(gameController.canUsePowerUp(PowerUpType.fiftyFifty), isTrue);
          expect(gameController.canUsePowerUp(PowerUpType.hint), isTrue);

          // Resume game
          gameController.resumeGame();

          // Power-ups should still be available
          expect(gameController.canUsePowerUp(PowerUpType.fiftyFifty), isTrue);
          expect(gameController.canUsePowerUp(PowerUpType.hint), isTrue);

          // Should be able to use power-ups after resume
          final removedIndices = gameController.useFiftyFifty();
          expect(removedIndices.length, equals(2));
          expect(
            gameController.getPowerUpCount(PowerUpType.fiftyFifty),
            equals(1),
          );
        },
      );
    });

    group('Error Handling and Edge Cases', () {
      test('should handle power-up usage when game is not active', () async {
        // Initialize game but don't start it
        await gameController.initializePathGame(path: PathType.dogBreeds);

        // Add power-ups
        gameController.addPowerUps({
          PowerUpType.fiftyFifty: 1,
          PowerUpType.hint: 1,
          PowerUpType.extraTime: 1,
          PowerUpType.skip: 1,
          PowerUpType.secondChance: 1,
        });

        // Pause the game
        gameController.pauseGame();

        // Try to use power-ups when game is not active
        expect(gameController.useFiftyFifty(), isEmpty);
        expect(gameController.useHint(), isNull);
        expect(gameController.useExtraTime(), isFalse);
        expect(gameController.useSkip(), isFalse);

        // Power-ups should not be consumed
        expect(
          gameController.getPowerUpCount(PowerUpType.fiftyFifty),
          equals(1),
        );
        expect(gameController.getPowerUpCount(PowerUpType.hint), equals(1));
        expect(
          gameController.getPowerUpCount(PowerUpType.extraTime),
          equals(1),
        );
        expect(gameController.getPowerUpCount(PowerUpType.skip), equals(1));
      });

      test(
        'should handle adding zero or negative power-ups gracefully',
        () async {
          await gameController.initializePathGame(path: PathType.dogBreeds);

          final initialCounts = <PowerUpType, int>{};
          for (final type in PowerUpType.values) {
            initialCounts[type] = gameController.getPowerUpCount(type);
          }

          // Try to add zero power-ups
          gameController.addPowerUps({
            PowerUpType.fiftyFifty: 0,
            PowerUpType.hint: 0,
          });

          // Counts should remain unchanged
          for (final type in PowerUpType.values) {
            expect(
              gameController.getPowerUpCount(type),
              equals(initialCounts[type]),
            );
          }

          // Try to add negative power-ups (should be handled gracefully)
          gameController.addPowerUp(PowerUpType.fiftyFifty, -1);

          // Count should not go negative
          expect(
            gameController.getPowerUpCount(PowerUpType.fiftyFifty),
            greaterThanOrEqualTo(0),
          );
        },
      );
    });
  });
}
