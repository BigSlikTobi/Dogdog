import 'package:flutter_test/flutter_test.dart';

import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('PowerUpType', () {
    group('Enum Values', () {
      test('should have exactly 5 power-up types', () {
        expect(PowerUpType.values.length, equals(5));
      });

      test('should contain all expected power-up types', () {
        expect(PowerUpType.values, contains(PowerUpType.fiftyFifty));
        expect(PowerUpType.values, contains(PowerUpType.hint));
        expect(PowerUpType.values, contains(PowerUpType.extraTime));
        expect(PowerUpType.values, contains(PowerUpType.skip));
        expect(PowerUpType.values, contains(PowerUpType.secondChance));
      });

      test('should have unique values', () {
        final values = PowerUpType.values.toSet();
        expect(values.length, equals(PowerUpType.values.length));
      });
    });

    group('String Representation', () {
      test('should have consistent toString format', () {
        for (final powerUp in PowerUpType.values) {
          final string = powerUp.toString();
          expect(string, startsWith('PowerUpType.'));
          expect(string, isNot(isEmpty));
        }
      });

      test('should have specific string representations', () {
        expect(
          PowerUpType.fiftyFifty.toString(),
          equals('PowerUpType.fiftyFifty'),
        );
        expect(PowerUpType.hint.toString(), equals('PowerUpType.hint'));
        expect(
          PowerUpType.extraTime.toString(),
          equals('PowerUpType.extraTime'),
        );
        expect(PowerUpType.skip.toString(), equals('PowerUpType.skip'));
        expect(
          PowerUpType.secondChance.toString(),
          equals('PowerUpType.secondChance'),
        );
      });
    });

    group('Enum Ordering', () {
      test('should maintain consistent order', () {
        final expectedOrder = [
          PowerUpType.fiftyFifty,
          PowerUpType.hint,
          PowerUpType.extraTime,
          PowerUpType.skip,
          PowerUpType.secondChance,
        ];

        expect(PowerUpType.values, equals(expectedOrder));
      });

      test('should have consistent indices', () {
        expect(PowerUpType.fiftyFifty.index, equals(0));
        expect(PowerUpType.hint.index, equals(1));
        expect(PowerUpType.extraTime.index, equals(2));
        expect(PowerUpType.skip.index, equals(3));
        expect(PowerUpType.secondChance.index, equals(4));
      });
    });

    group('Equality and HashCode', () {
      test('should be equal to itself', () {
        for (final powerUp in PowerUpType.values) {
          expect(powerUp, equals(powerUp));
          expect(powerUp.hashCode, equals(powerUp.hashCode));
        }
      });

      test('should not be equal to different power-ups', () {
        for (int i = 0; i < PowerUpType.values.length; i++) {
          for (int j = i + 1; j < PowerUpType.values.length; j++) {
            final powerUp1 = PowerUpType.values[i];
            final powerUp2 = PowerUpType.values[j];

            expect(powerUp1, isNot(equals(powerUp2)));
          }
        }
      });
    });

    group('Usage in Collections', () {
      test('should work correctly in Sets', () {
        final powerUpSet = <PowerUpType>{};

        for (final powerUp in PowerUpType.values) {
          powerUpSet.add(powerUp);
        }

        expect(powerUpSet.length, equals(PowerUpType.values.length));

        for (final powerUp in PowerUpType.values) {
          expect(powerUpSet.contains(powerUp), isTrue);
        }
      });

      test('should work correctly in Maps', () {
        final powerUpMap = <PowerUpType, int>{};

        for (int i = 0; i < PowerUpType.values.length; i++) {
          powerUpMap[PowerUpType.values[i]] = i;
        }

        expect(powerUpMap.length, equals(PowerUpType.values.length));

        for (int i = 0; i < PowerUpType.values.length; i++) {
          expect(powerUpMap[PowerUpType.values[i]], equals(i));
        }
      });

      test('should maintain order in Lists', () {
        final powerUpList = PowerUpType.values.toList();

        expect(powerUpList[0], equals(PowerUpType.fiftyFifty));
        expect(powerUpList[1], equals(PowerUpType.hint));
        expect(powerUpList[2], equals(PowerUpType.extraTime));
        expect(powerUpList[3], equals(PowerUpType.skip));
        expect(powerUpList[4], equals(PowerUpType.secondChance));
      });
    });

    group('Practical Usage', () {
      test('should support switch statements', () {
        String getPowerUpDescription(PowerUpType powerUp) {
          switch (powerUp) {
            case PowerUpType.fiftyFifty:
              return 'Eliminates two wrong answers';
            case PowerUpType.hint:
              return 'Provides a helpful hint';
            case PowerUpType.extraTime:
              return 'Adds extra time to the timer';
            case PowerUpType.skip:
              return 'Skips the current question';
            case PowerUpType.secondChance:
              return 'Allows another attempt';
          }
        }

        for (final powerUp in PowerUpType.values) {
          final description = getPowerUpDescription(powerUp);
          expect(description, isNotEmpty);
          expect(description, isA<String>());
        }
      });

      test('should work with for-in loops', () {
        final names = <String>[];

        for (final powerUp in PowerUpType.values) {
          names.add(powerUp.name);
        }

        expect(names.length, equals(5));
        expect(names, contains('fiftyFifty'));
        expect(names, contains('hint'));
        expect(names, contains('extraTime'));
        expect(names, contains('skip'));
        expect(names, contains('secondChance'));
      });

      test('should support mapping operations', () {
        final powerUpNames = PowerUpType.values
            .map((powerUp) => powerUp.name)
            .toList();

        expect(
          powerUpNames,
          equals(['fiftyFifty', 'hint', 'extraTime', 'skip', 'secondChance']),
        );
      });

      test('should support filtering operations', () {
        final timeRelatedPowerUps = PowerUpType.values
            .where(
              (powerUp) =>
                  powerUp.name.contains('Time') ||
                  powerUp.name.contains('Chance'),
            )
            .toList();

        expect(timeRelatedPowerUps, contains(PowerUpType.extraTime));
        expect(timeRelatedPowerUps, contains(PowerUpType.secondChance));
      });
    });

    group('Name Property', () {
      test('should have correct name property values', () {
        expect(PowerUpType.fiftyFifty.name, equals('fiftyFifty'));
        expect(PowerUpType.hint.name, equals('hint'));
        expect(PowerUpType.extraTime.name, equals('extraTime'));
        expect(PowerUpType.skip.name, equals('skip'));
        expect(PowerUpType.secondChance.name, equals('secondChance'));
      });

      test('should have unique names', () {
        final names = PowerUpType.values.map((p) => p.name).toSet();
        expect(names.length, equals(PowerUpType.values.length));
      });
    });

    group('Edge Cases', () {
      test('should handle iteration correctly', () {
        var count = 0;
        for (final _ in PowerUpType.values) {
          count++;
        }
        expect(count, equals(5));
      });

      test('should support isEmpty/isNotEmpty checks', () {
        expect(PowerUpType.values.isEmpty, isFalse);
        expect(PowerUpType.values.isNotEmpty, isTrue);
      });

      test('should support first and last access', () {
        expect(PowerUpType.values.first, equals(PowerUpType.fiftyFifty));
        expect(PowerUpType.values.last, equals(PowerUpType.secondChance));
      });
    });
  });
}
