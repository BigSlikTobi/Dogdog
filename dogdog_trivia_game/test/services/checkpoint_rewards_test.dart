import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/services/checkpoint_rewards.dart';

void main() {
  group('CheckpointRewards', () {
    group('getRewardsForCheckpoint', () {
      test('should return correct base rewards for Chihuahua checkpoint', () {
        final rewards = CheckpointRewards.getRewardsForCheckpoint(
          Checkpoint.chihuahua,
          0.7, // Below bonus threshold
        );

        expect(rewards[PowerUpType.fiftyFifty], equals(2));
        expect(rewards[PowerUpType.hint], equals(2));
        expect(rewards[PowerUpType.extraTime], equals(1));
        expect(rewards[PowerUpType.skip], equals(0));
        expect(rewards[PowerUpType.secondChance], equals(0));
      });

      test(
        'should return correct base rewards for Cocker Spaniel checkpoint',
        () {
          final rewards = CheckpointRewards.getRewardsForCheckpoint(
            Checkpoint.cockerSpaniel,
            0.7, // Below bonus threshold
          );

          expect(rewards[PowerUpType.fiftyFifty], equals(2));
          expect(rewards[PowerUpType.hint], equals(2));
          expect(rewards[PowerUpType.extraTime], equals(2));
          expect(rewards[PowerUpType.skip], equals(1));
          expect(rewards[PowerUpType.secondChance], equals(0));
        },
      );

      test(
        'should return correct base rewards for German Shepherd checkpoint',
        () {
          final rewards = CheckpointRewards.getRewardsForCheckpoint(
            Checkpoint.germanShepherd,
            0.7, // Below bonus threshold
          );

          expect(rewards[PowerUpType.fiftyFifty], equals(2));
          expect(rewards[PowerUpType.hint], equals(2));
          expect(rewards[PowerUpType.extraTime], equals(2));
          expect(rewards[PowerUpType.skip], equals(2));
          expect(rewards[PowerUpType.secondChance], equals(1));
        },
      );

      test('should return correct base rewards for Great Dane checkpoint', () {
        final rewards = CheckpointRewards.getRewardsForCheckpoint(
          Checkpoint.greatDane,
          0.7, // Below bonus threshold
        );

        expect(rewards[PowerUpType.fiftyFifty], equals(3));
        expect(rewards[PowerUpType.hint], equals(3));
        expect(rewards[PowerUpType.extraTime], equals(3));
        expect(rewards[PowerUpType.skip], equals(3));
        expect(rewards[PowerUpType.secondChance], equals(3));
      });

      test(
        'should return correct base rewards for Deutsche Dogge checkpoint',
        () {
          final rewards = CheckpointRewards.getRewardsForCheckpoint(
            Checkpoint.deutscheDogge,
            0.7, // Below bonus threshold
          );

          expect(rewards[PowerUpType.fiftyFifty], equals(4));
          expect(rewards[PowerUpType.hint], equals(4));
          expect(rewards[PowerUpType.extraTime], equals(4));
          expect(rewards[PowerUpType.skip], equals(4));
          expect(rewards[PowerUpType.secondChance], equals(4));
        },
      );

      test('should add bonus rewards for 80%+ accuracy', () {
        final baseRewards = CheckpointRewards.getRewardsForCheckpoint(
          Checkpoint.chihuahua,
          0.7, // Below bonus threshold
        );

        final bonusRewards = CheckpointRewards.getRewardsForCheckpoint(
          Checkpoint.chihuahua,
          0.8, // At bonus threshold
        );

        // Each power-up type should have 1 more with bonus
        expect(
          bonusRewards[PowerUpType.fiftyFifty],
          equals(baseRewards[PowerUpType.fiftyFifty]! + 1),
        );
        expect(
          bonusRewards[PowerUpType.hint],
          equals(baseRewards[PowerUpType.hint]! + 1),
        );
        expect(
          bonusRewards[PowerUpType.extraTime],
          equals(baseRewards[PowerUpType.extraTime]! + 1),
        );
        expect(
          bonusRewards[PowerUpType.skip],
          equals(baseRewards[PowerUpType.skip]! + 1),
        );
        expect(
          bonusRewards[PowerUpType.secondChance],
          equals(baseRewards[PowerUpType.secondChance]! + 1),
        );
      });

      test('should add bonus rewards for 90%+ accuracy', () {
        final bonusRewards = CheckpointRewards.getRewardsForCheckpoint(
          Checkpoint.chihuahua,
          0.9, // High accuracy
        );

        // Should still get the same bonus as 80% (bonus is binary)
        expect(
          bonusRewards[PowerUpType.fiftyFifty],
          equals(3),
        ); // 2 base + 1 bonus
        expect(bonusRewards[PowerUpType.hint], equals(3)); // 2 base + 1 bonus
        expect(
          bonusRewards[PowerUpType.extraTime],
          equals(2),
        ); // 1 base + 1 bonus
        expect(bonusRewards[PowerUpType.skip], equals(1)); // 0 base + 1 bonus
        expect(
          bonusRewards[PowerUpType.secondChance],
          equals(1),
        ); // 0 base + 1 bonus
      });

      test('should not add bonus rewards for accuracy below 80%', () {
        final rewards79 = CheckpointRewards.getRewardsForCheckpoint(
          Checkpoint.chihuahua,
          0.79, // Just below threshold
        );

        expect(rewards79[PowerUpType.fiftyFifty], equals(2)); // Base only
        expect(rewards79[PowerUpType.hint], equals(2)); // Base only
        expect(rewards79[PowerUpType.extraTime], equals(1)); // Base only
        expect(rewards79[PowerUpType.skip], equals(0)); // Base only
        expect(rewards79[PowerUpType.secondChance], equals(0)); // Base only
      });

      test('should ensure all power-up types are included in rewards', () {
        for (final checkpoint in Checkpoint.values) {
          final rewards = CheckpointRewards.getRewardsForCheckpoint(
            checkpoint,
            0.5,
          );

          // All power-up types should be present in the map
          for (final type in PowerUpType.values) {
            expect(
              rewards.containsKey(type),
              isTrue,
              reason: 'Missing power-up type $type for checkpoint $checkpoint',
            );
            expect(
              rewards[type],
              isA<int>(),
              reason: 'Invalid count for power-up type $type',
            );
            expect(
              rewards[type]! >= 0,
              isTrue,
              reason: 'Negative count for power-up type $type',
            );
          }
        }
      });
    });

    group('getTotalRewardCount', () {
      test('should return correct total count for each checkpoint', () {
        // Test without bonus
        expect(
          CheckpointRewards.getTotalRewardCount(Checkpoint.chihuahua, 0.7),
          equals(5),
        ); // 2+2+1+0+0
        expect(
          CheckpointRewards.getTotalRewardCount(Checkpoint.cockerSpaniel, 0.7),
          equals(7),
        ); // 2+2+2+1+0
        expect(
          CheckpointRewards.getTotalRewardCount(Checkpoint.germanShepherd, 0.7),
          equals(9),
        ); // 2+2+2+2+1
        expect(
          CheckpointRewards.getTotalRewardCount(Checkpoint.greatDane, 0.7),
          equals(15),
        ); // 3+3+3+3+3
        expect(
          CheckpointRewards.getTotalRewardCount(Checkpoint.deutscheDogge, 0.7),
          equals(20),
        ); // 4+4+4+4+4

        // Test with bonus (should add 5 to each)
        expect(
          CheckpointRewards.getTotalRewardCount(Checkpoint.chihuahua, 0.8),
          equals(10),
        ); // 5 + 5 bonus
        expect(
          CheckpointRewards.getTotalRewardCount(Checkpoint.cockerSpaniel, 0.8),
          equals(12),
        ); // 7 + 5 bonus
      });
    });

    group('getRewardPreview', () {
      test('should return both base and bonus reward previews', () {
        final preview = CheckpointRewards.getRewardPreview(
          Checkpoint.chihuahua,
        );

        expect(preview.containsKey('base'), isTrue);
        expect(preview.containsKey('bonus'), isTrue);

        final baseRewards = preview['base']!;
        final bonusRewards = preview['bonus']!;

        // Base rewards should match expected values
        expect(baseRewards[PowerUpType.fiftyFifty], equals(2));
        expect(baseRewards[PowerUpType.hint], equals(2));
        expect(baseRewards[PowerUpType.extraTime], equals(1));

        // Bonus rewards should be 1 for each type
        expect(bonusRewards[PowerUpType.fiftyFifty], equals(1));
        expect(bonusRewards[PowerUpType.hint], equals(1));
        expect(bonusRewards[PowerUpType.extraTime], equals(1));
        expect(bonusRewards[PowerUpType.skip], equals(1));
        expect(bonusRewards[PowerUpType.secondChance], equals(1));
      });
    });

    group('validateDistribution', () {
      test('should validate that distribution is balanced', () {
        expect(CheckpointRewards.validateDistribution(), isTrue);
      });

      test(
        'should ensure all power-up types are available by final checkpoint',
        () {
          final finalRewards = CheckpointRewards.getRewardsForCheckpoint(
            Checkpoint.deutscheDogge,
            0.0, // No bonus
          );

          for (final type in PowerUpType.values) {
            expect(
              finalRewards[type]! > 0,
              isTrue,
              reason:
                  'Power-up type $type should be available at final checkpoint',
            );
          }
        },
      );

      test('should ensure progressive distribution across checkpoints', () {
        final checkpoints = Checkpoint.values;

        for (int i = 1; i < checkpoints.length; i++) {
          final currentRewards = CheckpointRewards.getRewardsForCheckpoint(
            checkpoints[i],
            0.0, // No bonus
          );
          final previousRewards = CheckpointRewards.getRewardsForCheckpoint(
            checkpoints[i - 1],
            0.0, // No bonus
          );

          for (final type in PowerUpType.values) {
            final currentCount = currentRewards[type]!;
            final previousCount = previousRewards[type]!;

            // Once a power-up is introduced, it should not decrease
            if (previousCount > 0) {
              expect(
                currentCount >= previousCount,
                isTrue,
                reason:
                    'Power-up $type count should not decrease from ${checkpoints[i - 1]} to ${checkpoints[i]}',
              );
            }
          }
        }
      });
    });

    group('power-up availability progression', () {
      test('should introduce skip power-up at Cocker Spaniel checkpoint', () {
        final chihuahuaRewards = CheckpointRewards.getRewardsForCheckpoint(
          Checkpoint.chihuahua,
          0.0,
        );
        final cockerRewards = CheckpointRewards.getRewardsForCheckpoint(
          Checkpoint.cockerSpaniel,
          0.0,
        );

        expect(chihuahuaRewards[PowerUpType.skip], equals(0));
        expect(cockerRewards[PowerUpType.skip], equals(1));
      });

      test(
        'should introduce secondChance power-up at German Shepherd checkpoint',
        () {
          final cockerRewards = CheckpointRewards.getRewardsForCheckpoint(
            Checkpoint.cockerSpaniel,
            0.0,
          );
          final shepherdRewards = CheckpointRewards.getRewardsForCheckpoint(
            Checkpoint.germanShepherd,
            0.0,
          );

          expect(cockerRewards[PowerUpType.secondChance], equals(0));
          expect(shepherdRewards[PowerUpType.secondChance], equals(1));
        },
      );

      test(
        'should ensure skip and secondChance are guaranteed with high accuracy bonus',
        () {
          // Even at Chihuahua checkpoint, high accuracy should guarantee skip and secondChance
          final bonusRewards = CheckpointRewards.getRewardsForCheckpoint(
            Checkpoint.chihuahua,
            0.8,
          );

          expect(bonusRewards[PowerUpType.skip], equals(1)); // 0 base + 1 bonus
          expect(
            bonusRewards[PowerUpType.secondChance],
            equals(1),
          ); // 0 base + 1 bonus
        },
      );
    });
  });
}
