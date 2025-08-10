import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/controllers/breed_adventure_power_up_controller.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/models/breed_challenge.dart';
import 'package:dogdog_trivia_game/models/difficulty_phase.dart';

void main() {
  group('BreedAdventurePowerUpController Tests', () {
    late BreedAdventurePowerUpController controller;

    setUp(() {
      controller = BreedAdventurePowerUpController();
    });

    group('Initialization', () {
      test('should initialize with correct power-ups for breed adventure', () {
        controller.initializeForBreedAdventure();

        expect(controller.getPowerUpCount(PowerUpType.hint), equals(2));
        expect(controller.getPowerUpCount(PowerUpType.extraTime), equals(2));
        expect(controller.getPowerUpCount(PowerUpType.skip), equals(1));
        expect(controller.getPowerUpCount(PowerUpType.secondChance), equals(1));
        expect(controller.getPowerUpCount(PowerUpType.fiftyFifty), equals(0));
      });

      test('should reset for new game correctly', () {
        controller.trackCorrectAnswer();
        controller.trackCorrectAnswer();
        controller.usePowerUp(PowerUpType.hint);

        controller.resetForNewGame();

        expect(controller.getPowerUpCount(PowerUpType.hint), equals(2));
        expect(controller.getUsageStats()['correctAnswers'], equals(0));
      });
    });

    group('Power-up Applications', () {
      setUp(() {
        controller.initializeForBreedAdventure();
      });

      test('should apply breed hint correctly', () {
        final challenge = BreedChallenge(
          correctBreedName: 'German Shepherd Dog',
          correctImageUrl: 'test1.jpg',
          incorrectImageUrl: 'test2.jpg',
          correctImageIndex: 0,
          phase: DifficultyPhase.beginner,
        );

        final hint = controller.applyBreedHint(challenge);

        expect(hint, isNotNull);
        expect(hint, contains('herding'));
        expect(controller.getPowerUpCount(PowerUpType.hint), equals(1));
      });

      test('should apply extra time correctly', () {
        final extraTime = controller.applyBreedExtraTime();

        expect(extraTime, equals(5));
        expect(controller.getPowerUpCount(PowerUpType.extraTime), equals(1));
      });

      test('should apply skip correctly', () {
        final success = controller.applyBreedSkip();

        expect(success, isTrue);
        expect(controller.getPowerUpCount(PowerUpType.skip), equals(0));
      });

      test('should apply second chance correctly', () {
        final success = controller.applyBreedSecondChance();

        expect(success, isTrue);
        expect(controller.getPowerUpCount(PowerUpType.secondChance), equals(0));
      });

      test('should not apply power-ups when not available', () {
        // Use all hints
        controller.usePowerUp(PowerUpType.hint);
        controller.usePowerUp(PowerUpType.hint);

        final challenge = BreedChallenge(
          correctBreedName: 'Golden Retriever',
          correctImageUrl: 'test1.jpg',
          incorrectImageUrl: 'test2.jpg',
          correctImageIndex: 0,
          phase: DifficultyPhase.beginner,
        );

        final hint = controller.applyBreedHint(challenge);
        expect(hint, isNull);
      });
    });

    group('Reward System', () {
      setUp(() {
        controller.initializeForBreedAdventure();
      });

      test('should track correct answers', () {
        controller.trackCorrectAnswer();
        controller.trackCorrectAnswer();

        final stats = controller.getUsageStats();
        expect(stats['correctAnswers'], equals(2));
      });

      test('should award power-up after threshold', () {
        final initialTotal = controller.totalPowerUpCount;

        // Track 5 correct answers to trigger reward
        for (int i = 0; i < 5; i++) {
          controller.trackCorrectAnswer();
        }

        final finalTotal = controller.totalPowerUpCount;
        expect(finalTotal, equals(initialTotal + 1));
      });

      test('should calculate next reward correctly', () {
        controller.trackCorrectAnswer();
        controller.trackCorrectAnswer();

        final stats = controller.getUsageStats();
        expect(stats['nextRewardIn'], equals(3));
      });

      test('should identify when close to reward', () {
        expect(controller.isCloseToReward(), isFalse);

        // Track 3 correct answers (2 away from reward)
        for (int i = 0; i < 3; i++) {
          controller.trackCorrectAnswer();
        }

        expect(controller.isCloseToReward(), isTrue);
      });
    });

    group('Breed Hint Generation', () {
      setUp(() {
        controller.initializeForBreedAdventure();
      });

      test('should generate specific hints for known breeds', () {
        final shepherdChallenge = BreedChallenge(
          correctBreedName: 'German Shepherd Dog',
          correctImageUrl: 'test1.jpg',
          incorrectImageUrl: 'test2.jpg',
          correctImageIndex: 0,
          phase: DifficultyPhase.beginner,
        );

        final hint = controller.applyBreedHint(shepherdChallenge);
        expect(hint, contains('herding'));

        final retrieverChallenge = BreedChallenge(
          correctBreedName: 'Golden Retriever',
          correctImageUrl: 'test1.jpg',
          incorrectImageUrl: 'test2.jpg',
          correctImageIndex: 0,
          phase: DifficultyPhase.beginner,
        );

        final retrieverHint = controller.applyBreedHint(retrieverChallenge);
        expect(retrieverHint, contains('retrieving'));
      });

      test('should generate generic hint for unknown breeds', () {
        final unknownChallenge = BreedChallenge(
          correctBreedName: 'Unknown Breed',
          correctImageUrl: 'test1.jpg',
          incorrectImageUrl: 'test2.jpg',
          correctImageIndex: 0,
          phase: DifficultyPhase.beginner,
        );

        final hint = controller.applyBreedHint(unknownChallenge);
        expect(hint, contains('Look carefully'));
      });
    });

    group('Power-up Information', () {
      test('should provide celebration messages', () {
        final hintMessage = controller.getPowerUpCelebrationMessage(
          PowerUpType.hint,
        );
        expect(hintMessage, contains('Breed knowledge'));

        final timeMessage = controller.getPowerUpCelebrationMessage(
          PowerUpType.extraTime,
        );
        expect(timeMessage, contains('Extra time'));
      });

      test('should provide descriptions', () {
        final hintDesc = controller.getPowerUpDescription(PowerUpType.hint);
        expect(hintDesc, contains('characteristics'));

        final timeDesc = controller.getPowerUpDescription(
          PowerUpType.extraTime,
        );
        expect(timeDesc, contains('5 extra seconds'));
      });

      test('should identify available power-ups', () {
        expect(
          controller.isPowerUpAvailableInBreedAdventure(PowerUpType.hint),
          isTrue,
        );
        expect(
          controller.isPowerUpAvailableInBreedAdventure(PowerUpType.extraTime),
          isTrue,
        );
        expect(
          controller.isPowerUpAvailableInBreedAdventure(PowerUpType.skip),
          isTrue,
        );
        expect(
          controller.isPowerUpAvailableInBreedAdventure(
            PowerUpType.secondChance,
          ),
          isTrue,
        );
        expect(
          controller.isPowerUpAvailableInBreedAdventure(PowerUpType.fiftyFifty),
          isFalse,
        );
      });
    });

    group('Configuration', () {
      test('should have correct configuration constants', () {
        expect(BreedAdventurePowerUpController.extraTimeSeconds, equals(5));
        expect(
          BreedAdventurePowerUpController.powerUpRewardThreshold,
          equals(5),
        );
      });
    });
  });
}
