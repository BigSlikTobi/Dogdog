import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/controllers/power_up_controller.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/models/question.dart';

void main() {
  group('PowerUpController', () {
    late PowerUpController controller;

    setUp(() {
      controller = PowerUpController();
    });

    group('Initialization', () {
      test('should initialize with zero power-ups', () {
        for (final type in PowerUpType.values) {
          expect(controller.getPowerUpCount(type), equals(0));
          expect(controller.canUsePowerUp(type), isFalse);
        }
        expect(controller.totalPowerUpCount, equals(0));
      });
    });

    group('Adding Power-ups', () {
      test('should add single power-up correctly', () {
        controller.addPowerUp(PowerUpType.fiftyFifty, 3);

        expect(controller.getPowerUpCount(PowerUpType.fiftyFifty), equals(3));
        expect(controller.canUsePowerUp(PowerUpType.fiftyFifty), isTrue);
        expect(controller.totalPowerUpCount, equals(3));
      });

      test('should not add negative or zero power-ups', () {
        controller.addPowerUp(PowerUpType.hint, -1);
        controller.addPowerUp(PowerUpType.extraTime, 0);

        expect(controller.getPowerUpCount(PowerUpType.hint), equals(0));
        expect(controller.getPowerUpCount(PowerUpType.extraTime), equals(0));
      });

      test('should add multiple power-ups at once', () {
        final powerUpsToAdd = {
          PowerUpType.fiftyFifty: 2,
          PowerUpType.hint: 3,
          PowerUpType.extraTime: 1,
        };

        controller.addPowerUps(powerUpsToAdd);

        expect(controller.getPowerUpCount(PowerUpType.fiftyFifty), equals(2));
        expect(controller.getPowerUpCount(PowerUpType.hint), equals(3));
        expect(controller.getPowerUpCount(PowerUpType.extraTime), equals(1));
        expect(controller.totalPowerUpCount, equals(6));
      });

      test('should accumulate power-ups when added multiple times', () {
        controller.addPowerUp(PowerUpType.skip, 2);
        controller.addPowerUp(PowerUpType.skip, 3);

        expect(controller.getPowerUpCount(PowerUpType.skip), equals(5));
      });
    });

    group('Using Power-ups', () {
      test('should use power-up and decrement count', () {
        controller.addPowerUp(PowerUpType.secondChance, 2);

        expect(controller.usePowerUp(PowerUpType.secondChance), isTrue);
        expect(controller.getPowerUpCount(PowerUpType.secondChance), equals(1));
        expect(controller.canUsePowerUp(PowerUpType.secondChance), isTrue);

        expect(controller.usePowerUp(PowerUpType.secondChance), isTrue);
        expect(controller.getPowerUpCount(PowerUpType.secondChance), equals(0));
        expect(controller.canUsePowerUp(PowerUpType.secondChance), isFalse);
      });

      test('should not use power-up when count is zero', () {
        expect(controller.usePowerUp(PowerUpType.fiftyFifty), isFalse);
        expect(controller.getPowerUpCount(PowerUpType.fiftyFifty), equals(0));
      });
    });

    group('50/50 Power-up', () {
      test('should return two wrong answer indices', () {
        controller.addPowerUp(PowerUpType.fiftyFifty, 1);

        final question = Question(
          id: 'test1',
          text: 'Test question?',
          answers: ['Wrong 1', 'Correct', 'Wrong 2', 'Wrong 3'],
          correctAnswerIndex: 1,
          funFact: 'Test fact',
          difficulty: Difficulty.easy,
          category: 'test',
          hint: 'Test hint',
        );

        final removedIndices = controller.applyFiftyFifty(question);

        expect(removedIndices.length, equals(2));
        expect(
          removedIndices.contains(1),
          isFalse,
        ); // Should not remove correct answer

        // All removed indices should be wrong answers
        for (final index in removedIndices) {
          expect(index, isNot(equals(1)));
          expect(index, isIn([0, 2, 3]));
        }
      });

      test('should return empty list when power-up not available', () {
        final question = Question(
          id: 'test1',
          text: 'Test question?',
          answers: ['Wrong 1', 'Correct', 'Wrong 2', 'Wrong 3'],
          correctAnswerIndex: 1,
          funFact: 'Test fact',
          difficulty: Difficulty.easy,
          category: 'test',
        );

        final removedIndices = controller.applyFiftyFifty(question);
        expect(removedIndices, isEmpty);
      });
    });

    group('Hint Power-up', () {
      test('should return hint text when available', () {
        controller.addPowerUp(PowerUpType.hint, 1);

        final question = Question(
          id: 'test1',
          text: 'Test question?',
          answers: ['A', 'B', 'C', 'D'],
          correctAnswerIndex: 1,
          funFact: 'Test fact',
          difficulty: Difficulty.easy,
          category: 'test',
          hint: 'This is a hint',
        );

        final hint = controller.applyHint(question);
        expect(hint, equals('This is a hint'));
      });

      test('should return null when power-up not available', () {
        final question = Question(
          id: 'test1',
          text: 'Test question?',
          answers: ['A', 'B', 'C', 'D'],
          correctAnswerIndex: 1,
          funFact: 'Test fact',
          difficulty: Difficulty.easy,
          category: 'test',
          hint: 'This is a hint',
        );

        final hint = controller.applyHint(question);
        expect(hint, isNull);
      });

      test('should return hint even if question hint is null', () {
        controller.addPowerUp(PowerUpType.hint, 1);

        final question = Question(
          id: 'test1',
          text: 'Test question?',
          answers: ['A', 'B', 'C', 'D'],
          correctAnswerIndex: 1,
          funFact: 'Test fact',
          difficulty: Difficulty.easy,
          category: 'test',
          hint: null,
        );

        final hint = controller.applyHint(question);
        expect(hint, isNull);
      });
    });

    group('Extra Time Power-up', () {
      test('should return 10 seconds when power-up available', () {
        controller.addPowerUp(PowerUpType.extraTime, 1);

        final extraTime = controller.applyExtraTime();
        expect(extraTime, equals(10));
      });

      test('should return 0 when power-up not available', () {
        final extraTime = controller.applyExtraTime();
        expect(extraTime, equals(0));
      });
    });

    group('Skip Power-up', () {
      test('should return true when power-up available', () {
        controller.addPowerUp(PowerUpType.skip, 1);

        final canSkip = controller.applySkip();
        expect(canSkip, isTrue);
      });

      test('should return false when power-up not available', () {
        final canSkip = controller.applySkip();
        expect(canSkip, isFalse);
      });
    });

    group('Second Chance Power-up', () {
      test('should return true when power-up available', () {
        controller.addPowerUp(PowerUpType.secondChance, 1);

        final canUseSecondChance = controller.applySecondChance();
        expect(canUseSecondChance, isTrue);
      });

      test('should return false when power-up not available', () {
        final canUseSecondChance = controller.applySecondChance();
        expect(canUseSecondChance, isFalse);
      });
    });

    group('State Management', () {
      test('should set power-ups correctly', () {
        final newPowerUps = {
          PowerUpType.fiftyFifty: 3,
          PowerUpType.hint: 2,
          PowerUpType.extraTime: 1,
          PowerUpType.skip: 4,
          PowerUpType.secondChance: 0,
        };

        controller.setPowerUps(newPowerUps);

        expect(controller.getPowerUpCount(PowerUpType.fiftyFifty), equals(3));
        expect(controller.getPowerUpCount(PowerUpType.hint), equals(2));
        expect(controller.getPowerUpCount(PowerUpType.extraTime), equals(1));
        expect(controller.getPowerUpCount(PowerUpType.skip), equals(4));
        expect(controller.getPowerUpCount(PowerUpType.secondChance), equals(0));
      });

      test('should reset all power-ups to zero', () {
        controller.addPowerUp(PowerUpType.fiftyFifty, 5);
        controller.addPowerUp(PowerUpType.hint, 3);

        controller.resetPowerUps();

        for (final type in PowerUpType.values) {
          expect(controller.getPowerUpCount(type), equals(0));
        }
        expect(controller.totalPowerUpCount, equals(0));
      });
    });

    group('JSON Serialization', () {
      test('should convert to JSON correctly', () {
        controller.addPowerUp(PowerUpType.fiftyFifty, 2);
        controller.addPowerUp(PowerUpType.hint, 1);

        final json = controller.toJson();

        expect(json['fiftyFifty'], equals(2));
        expect(json['hint'], equals(1));
        expect(json['extraTime'], equals(0));
        expect(json['skip'], equals(0));
        expect(json['secondChance'], equals(0));
      });

      test('should load from JSON correctly', () {
        final json = {
          'fiftyFifty': 3,
          'hint': 2,
          'extraTime': 1,
          'skip': 0,
          'secondChance': 4,
        };

        controller.fromJson(json);

        expect(controller.getPowerUpCount(PowerUpType.fiftyFifty), equals(3));
        expect(controller.getPowerUpCount(PowerUpType.hint), equals(2));
        expect(controller.getPowerUpCount(PowerUpType.extraTime), equals(1));
        expect(controller.getPowerUpCount(PowerUpType.skip), equals(0));
        expect(controller.getPowerUpCount(PowerUpType.secondChance), equals(4));
      });

      test('should handle unknown power-up types in JSON', () {
        final json = {'fiftyFifty': 2, 'unknownPowerUp': 5, 'hint': 1};

        controller.fromJson(json);

        expect(controller.getPowerUpCount(PowerUpType.fiftyFifty), equals(2));
        expect(controller.getPowerUpCount(PowerUpType.hint), equals(1));
        // Other power-ups should be 0
        expect(controller.getPowerUpCount(PowerUpType.extraTime), equals(0));
      });

      test(
        'should ensure all power-up types are present after loading JSON',
        () {
          final json = {'fiftyFifty': 2};

          controller.fromJson(json);

          // All power-up types should be present, even if not in JSON
          for (final type in PowerUpType.values) {
            expect(controller.powerUps.containsKey(type), isTrue);
          }
        },
      );
    });

    group('Immutability', () {
      test('should return unmodifiable map for powerUps getter', () {
        controller.addPowerUp(PowerUpType.fiftyFifty, 1);

        final powerUps = controller.powerUps;

        expect(() => powerUps[PowerUpType.hint] = 5, throwsUnsupportedError);
      });
    });
  });
}
