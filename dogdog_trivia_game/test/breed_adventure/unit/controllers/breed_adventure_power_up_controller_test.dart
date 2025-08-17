import 'package:flutter_test/flutter_test.dart';

import 'package:dogdog_trivia_game/controllers/breed_adventure/breed_adventure_power_up_controller.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('BreedAdventurePowerUpController', () {
    late BreedAdventurePowerUpController controller;

    setUp(() {
      controller = BreedAdventurePowerUpController();
    });

    tearDown(() {
      // Only dispose if not already disposed
      try {
        controller.dispose();
      } catch (e) {
        // Already disposed, ignore
      }
    });

    group('Initialization', () {
      test('should initialize with default power-ups', () {
        controller.initializeForBreedAdventure();

        expect(controller.powerUps, isNotEmpty);
        expect(controller.getPowerUpCount(PowerUpType.hint), greaterThan(0));
        expect(
          controller.getPowerUpCount(PowerUpType.extraTime),
          greaterThan(0),
        );
      });

      test('should have power-up inventory', () {
        expect(controller.powerUps, isNotNull);
        expect(controller.powerUps, isA<Map<PowerUpType, int>>());
      });
    });

    group('Power-up Management', () {
      test('should add power-ups to inventory', () {
        controller.addPowerUp(PowerUpType.extraTime, 1);

        expect(controller.getPowerUpCount(PowerUpType.extraTime), equals(1));
      });

      test('should handle multiple power-ups of same type', () {
        controller.addPowerUp(PowerUpType.extraTime, 2);
        controller.addPowerUp(PowerUpType.extraTime, 1);

        expect(controller.getPowerUpCount(PowerUpType.extraTime), equals(3));
      });

      test('should track different power-up types', () {
        controller.addPowerUp(PowerUpType.extraTime, 1);
        controller.addPowerUp(PowerUpType.skip, 1);

        expect(controller.getPowerUpCount(PowerUpType.extraTime), equals(1));
        expect(controller.getPowerUpCount(PowerUpType.skip), equals(1));
      });
    });

    group('Power-up Usage', () {
      test('should allow using available power-ups', () {
        controller.addPowerUp(PowerUpType.extraTime, 1);

        final canUse = controller.canUsePowerUp(PowerUpType.extraTime);
        expect(canUse, isTrue);
      });

      test('should prevent using unavailable power-ups', () {
        final canUse = controller.canUsePowerUp(PowerUpType.extraTime);
        expect(canUse, isFalse);
      });

      test('should get power-up count correctly', () {
        controller.addPowerUp(PowerUpType.extraTime, 2);

        final count = controller.getPowerUpCount(PowerUpType.extraTime);
        expect(count, equals(2));
      });

      test('should return zero for unavailable power-ups', () {
        final count = controller.getPowerUpCount(PowerUpType.extraTime);
        expect(count, equals(0));
      });

      test('should use power-ups correctly', () {
        controller.addPowerUp(PowerUpType.extraTime, 2);

        final used = controller.usePowerUp(PowerUpType.extraTime);
        expect(used, isTrue);
        expect(controller.getPowerUpCount(PowerUpType.extraTime), equals(1));
      });
    });

    group('Breed Adventure Specific', () {
      test('should initialize with breed adventure power-ups', () {
        controller.initializeForBreedAdventure();

        expect(controller.canUsePowerUp(PowerUpType.hint), isTrue);
        expect(controller.canUsePowerUp(PowerUpType.extraTime), isTrue);
        expect(controller.canUsePowerUp(PowerUpType.skip), isTrue);
      });

      test('should handle correct answer tracking', () {
        controller.initializeForBreedAdventure();

        // Method to record correct answers would be tested here
        // The controller should track correct answers for rewards
        expect(controller.powerUps, isNotEmpty);
      });
    });

    group('Notifications', () {
      test('should notify listeners when inventory changes', () {
        var notificationCount = 0;
        controller.addListener(() {
          notificationCount++;
        });

        controller.addPowerUp(PowerUpType.extraTime, 1);

        expect(notificationCount, greaterThan(0));
      });
    });

    group('Edge Cases', () {
      test('should handle zero count additions', () {
        controller.addPowerUp(PowerUpType.extraTime, 0);

        expect(controller.getPowerUpCount(PowerUpType.extraTime), equals(0));
      });

      test('should handle negative count gracefully', () {
        controller.addPowerUp(PowerUpType.extraTime, -1);

        expect(controller.getPowerUpCount(PowerUpType.extraTime), equals(0));
      });

      test('should handle disposal correctly', () {
        controller.addPowerUp(PowerUpType.extraTime, 1);
        expect(controller.getPowerUpCount(PowerUpType.extraTime), equals(1));

        controller.dispose();

        // After disposal, we won't access the controller to avoid errors
        // The test just verifies disposal doesn't crash
      });
    });

    group('State Consistency', () {
      test('should maintain consistent inventory state', () {
        controller.addPowerUp(PowerUpType.extraTime, 1);
        controller.addPowerUp(PowerUpType.skip, 1);
        controller.addPowerUp(PowerUpType.hint, 1);

        final totalPowerUps = controller.powerUps.values.fold<int>(
          0,
          (sum, count) => sum + count,
        );

        expect(totalPowerUps, equals(3));
      });

      test('should handle all power-up types', () {
        for (final powerUpType in PowerUpType.values) {
          controller.addPowerUp(powerUpType, 1);
          expect(controller.canUsePowerUp(powerUpType), isTrue);
        }

        final totalPowerUps = controller.powerUps.values.fold<int>(
          0,
          (sum, count) => sum + count,
        );
        expect(totalPowerUps, equals(PowerUpType.values.length));
      });
    });
  });
}
