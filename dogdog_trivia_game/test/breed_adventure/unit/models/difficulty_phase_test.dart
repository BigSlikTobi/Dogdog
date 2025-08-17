import 'package:flutter_test/flutter_test.dart';

import 'package:dogdog_trivia_game/models/breed_adventure/difficulty_phase.dart';

void main() {
  group('DifficultyPhase', () {
    group('Enum Values', () {
      test('should have correct enum values', () {
        expect(DifficultyPhase.values.length, equals(3));
        expect(DifficultyPhase.values, contains(DifficultyPhase.beginner));
        expect(DifficultyPhase.values, contains(DifficultyPhase.intermediate));
        expect(DifficultyPhase.values, contains(DifficultyPhase.expert));
      });

      test('should have correct difficulty ranges', () {
        expect(DifficultyPhase.beginner.difficulties, equals([1, 2]));
        expect(DifficultyPhase.intermediate.difficulties, equals([3, 4]));
        expect(DifficultyPhase.expert.difficulties, equals([5]));
      });

      test('should have correct display names', () {
        expect(DifficultyPhase.beginner.name, equals('Beginner'));
        expect(DifficultyPhase.intermediate.name, equals('Intermediate'));
        expect(DifficultyPhase.expert.name, equals('Expert'));
      });
    });

    group('Score Multipliers', () {
      test('should return correct score multipliers', () {
        expect(DifficultyPhase.beginner.scoreMultiplier, equals(1));
        expect(DifficultyPhase.intermediate.scoreMultiplier, equals(2));
        expect(DifficultyPhase.expert.scoreMultiplier, equals(3));
      });

      test('should increase multiplier with difficulty', () {
        final beginnerMultiplier = DifficultyPhase.beginner.scoreMultiplier;
        final intermediateMultiplier =
            DifficultyPhase.intermediate.scoreMultiplier;
        final expertMultiplier = DifficultyPhase.expert.scoreMultiplier;

        expect(beginnerMultiplier, lessThan(intermediateMultiplier));
        expect(intermediateMultiplier, lessThan(expertMultiplier));
      });
    });

    group('Localization Keys', () {
      test('should return correct localization keys', () {
        expect(
          DifficultyPhase.beginner.localizationKey,
          equals('breed_adventure_beginner'),
        );
        expect(
          DifficultyPhase.intermediate.localizationKey,
          equals('breed_adventure_intermediate'),
        );
        expect(
          DifficultyPhase.expert.localizationKey,
          equals('breed_adventure_expert'),
        );
      });

      test('should have unique localization keys', () {
        final keys = DifficultyPhase.values
            .map((phase) => phase.localizationKey)
            .toSet();
        expect(keys.length, equals(DifficultyPhase.values.length));
      });
    });

    group('Phase Navigation', () {
      test('should return correct next phase', () {
        expect(
          DifficultyPhase.beginner.nextPhase,
          equals(DifficultyPhase.intermediate),
        );
        expect(
          DifficultyPhase.intermediate.nextPhase,
          equals(DifficultyPhase.expert),
        );
        expect(DifficultyPhase.expert.nextPhase, isNull);
      });

      test('should check phase progression correctly', () {
        // Only expert phase has no next phase
        expect(DifficultyPhase.expert.nextPhase, isNull);

        // All other phases should have a next phase
        expect(DifficultyPhase.beginner.nextPhase, isNotNull);
        expect(DifficultyPhase.intermediate.nextPhase, isNotNull);
      });
    });

    group('Difficulty Checking', () {
      test('should check if difficulty belongs to phase', () {
        expect(DifficultyPhase.beginner.containsDifficulty(1), isTrue);
        expect(DifficultyPhase.beginner.containsDifficulty(2), isTrue);
        expect(DifficultyPhase.beginner.containsDifficulty(3), isFalse);

        expect(DifficultyPhase.intermediate.containsDifficulty(3), isTrue);
        expect(DifficultyPhase.intermediate.containsDifficulty(4), isTrue);
        expect(DifficultyPhase.intermediate.containsDifficulty(2), isFalse);
        expect(DifficultyPhase.intermediate.containsDifficulty(5), isFalse);

        expect(DifficultyPhase.expert.containsDifficulty(5), isTrue);
        expect(DifficultyPhase.expert.containsDifficulty(4), isFalse);
      });

      test('should handle invalid difficulty levels', () {
        for (final phase in DifficultyPhase.values) {
          expect(phase.containsDifficulty(0), isFalse);
          expect(phase.containsDifficulty(6), isFalse);
          expect(phase.containsDifficulty(-1), isFalse);
        }
      });
    });

    group('Helper Functions', () {
      test('should find phase by difficulty level', () {
        DifficultyPhase? findPhaseByDifficulty(int difficulty) {
          for (final phase in DifficultyPhase.values) {
            if (phase.containsDifficulty(difficulty)) {
              return phase;
            }
          }
          return null;
        }

        expect(findPhaseByDifficulty(1), equals(DifficultyPhase.beginner));
        expect(findPhaseByDifficulty(2), equals(DifficultyPhase.beginner));
        expect(findPhaseByDifficulty(3), equals(DifficultyPhase.intermediate));
        expect(findPhaseByDifficulty(4), equals(DifficultyPhase.intermediate));
        expect(findPhaseByDifficulty(5), equals(DifficultyPhase.expert));
        expect(findPhaseByDifficulty(6), isNull);
      });
    });

    group('Data Integrity', () {
      test('should have non-overlapping difficulty ranges', () {
        final allDifficulties = <int>{};

        for (final phase in DifficultyPhase.values) {
          for (final difficulty in phase.difficulties) {
            expect(
              allDifficulties.contains(difficulty),
              isFalse,
              reason: 'Difficulty $difficulty appears in multiple phases',
            );
            allDifficulties.add(difficulty);
          }
        }
      });

      test('should cover all expected difficulty levels', () {
        final allDifficulties = <int>{};

        for (final phase in DifficultyPhase.values) {
          allDifficulties.addAll(phase.difficulties);
        }

        expect(allDifficulties, equals({1, 2, 3, 4, 5}));
      });

      test('should have consistent enum ordering', () {
        final phases = DifficultyPhase.values;

        for (int i = 1; i < phases.length; i++) {
          final currentPhase = phases[i];
          final previousPhase = phases[i - 1];

          // Current phase should be harder than previous
          expect(
            currentPhase.scoreMultiplier,
            greaterThan(previousPhase.scoreMultiplier),
          );
        }
      });

      test('should have meaningful names', () {
        for (final phase in DifficultyPhase.values) {
          expect(phase.name, isNotEmpty);
          expect(phase.name, isA<String>());
          // Names should be title case
          expect(phase.name[0], equals(phase.name[0].toUpperCase()));
        }
      });

      test('should have proper localization keys', () {
        for (final phase in DifficultyPhase.values) {
          final key = phase.localizationKey;
          expect(key, isNotEmpty);
          expect(key, startsWith('breed_adventure_'));
          expect(key, isNot(contains(' '))); // No spaces in keys
        }
      });
    });
  });
}
