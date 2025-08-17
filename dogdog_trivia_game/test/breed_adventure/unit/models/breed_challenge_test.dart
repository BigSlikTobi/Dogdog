import 'package:flutter_test/flutter_test.dart';

import 'package:dogdog_trivia_game/models/breed_adventure/breed_challenge.dart';
import 'package:dogdog_trivia_game/models/breed_adventure/difficulty_phase.dart';

void main() {
  group('BreedChallenge', () {
    late BreedChallenge challenge;

    setUp(() {
      challenge = const BreedChallenge(
        correctBreedName: 'Golden Retriever',
        correctImageUrl: 'correct_image.jpg',
        incorrectImageUrl: 'incorrect_image.jpg',
        correctImageIndex: 0,
        phase: DifficultyPhase.beginner,
      );
    });

    group('Constructor', () {
      test('should create instance with all required fields', () {
        expect(challenge.correctBreedName, equals('Golden Retriever'));
        expect(challenge.correctImageUrl, equals('correct_image.jpg'));
        expect(challenge.incorrectImageUrl, equals('incorrect_image.jpg'));
        expect(challenge.correctImageIndex, equals(0));
        expect(challenge.phase, equals(DifficultyPhase.beginner));
      });

      test('should create instance with correct image at index 1', () {
        final challenge1 = const BreedChallenge(
          correctBreedName: 'Poodle',
          correctImageUrl: 'poodle.jpg',
          incorrectImageUrl: 'labrador.jpg',
          correctImageIndex: 1,
          phase: DifficultyPhase.intermediate,
        );

        expect(challenge1.correctImageIndex, equals(1));
        expect(challenge1.phase, equals(DifficultyPhase.intermediate));
      });
    });

    group('getImageUrl', () {
      test('should return correct image URL for correct index', () {
        expect(challenge.getImageUrl(0), equals('correct_image.jpg'));
      });

      test('should return incorrect image URL for incorrect index', () {
        expect(challenge.getImageUrl(1), equals('incorrect_image.jpg'));
      });

      test('should handle challenge with correct image at index 1', () {
        final challenge1 = const BreedChallenge(
          correctBreedName: 'Poodle',
          correctImageUrl: 'poodle.jpg',
          incorrectImageUrl: 'labrador.jpg',
          correctImageIndex: 1,
          phase: DifficultyPhase.expert,
        );

        expect(challenge1.getImageUrl(0), equals('labrador.jpg'));
        expect(challenge1.getImageUrl(1), equals('poodle.jpg'));
      });
    });

    group('isCorrectSelection', () {
      test('should return true for correct selection', () {
        expect(challenge.isCorrectSelection(0), isTrue);
        expect(challenge.isCorrectSelection(1), isFalse);
      });

      test('should return false for incorrect selection', () {
        expect(challenge.isCorrectSelection(1), isFalse);
      });

      test('should handle challenge with correct image at index 1', () {
        final challenge1 = const BreedChallenge(
          correctBreedName: 'Poodle',
          correctImageUrl: 'poodle.jpg',
          incorrectImageUrl: 'labrador.jpg',
          correctImageIndex: 1,
          phase: DifficultyPhase.expert,
        );

        expect(challenge1.isCorrectSelection(0), isFalse);
        expect(challenge1.isCorrectSelection(1), isTrue);
      });
    });

    group('imageUrls getter', () {
      test('should return images in correct order for correctImageIndex 0', () {
        final urls = challenge.imageUrls;
        expect(urls.length, equals(2));
        expect(urls[0], equals('correct_image.jpg'));
        expect(urls[1], equals('incorrect_image.jpg'));
      });

      test('should return images in correct order for correctImageIndex 1', () {
        final challenge1 = const BreedChallenge(
          correctBreedName: 'Poodle',
          correctImageUrl: 'poodle.jpg',
          incorrectImageUrl: 'labrador.jpg',
          correctImageIndex: 1,
          phase: DifficultyPhase.expert,
        );

        final urls = challenge1.imageUrls;
        expect(urls.length, equals(2));
        expect(urls[0], equals('labrador.jpg'));
        expect(urls[1], equals('poodle.jpg'));
      });
    });

    group('Equality and HashCode', () {
      test('should be equal to identical challenge', () {
        final identicalChallenge = const BreedChallenge(
          correctBreedName: 'Golden Retriever',
          correctImageUrl: 'correct_image.jpg',
          incorrectImageUrl: 'incorrect_image.jpg',
          correctImageIndex: 0,
          phase: DifficultyPhase.beginner,
        );

        expect(challenge, equals(identicalChallenge));
        expect(challenge.hashCode, equals(identicalChallenge.hashCode));
      });

      test('should not be equal to different challenge', () {
        final differentChallenge = const BreedChallenge(
          correctBreedName: 'Poodle',
          correctImageUrl: 'correct_image.jpg',
          incorrectImageUrl: 'incorrect_image.jpg',
          correctImageIndex: 0,
          phase: DifficultyPhase.beginner,
        );

        expect(challenge, isNot(equals(differentChallenge)));
        expect(challenge.hashCode, isNot(equals(differentChallenge.hashCode)));
      });

      test('should not be equal when correctImageIndex differs', () {
        final differentIndexChallenge = const BreedChallenge(
          correctBreedName: 'Golden Retriever',
          correctImageUrl: 'correct_image.jpg',
          incorrectImageUrl: 'incorrect_image.jpg',
          correctImageIndex: 1, // Different index
          phase: DifficultyPhase.beginner,
        );

        expect(challenge, isNot(equals(differentIndexChallenge)));
      });

      test('should not be equal when phase differs', () {
        final differentPhaseChallenge = const BreedChallenge(
          correctBreedName: 'Golden Retriever',
          correctImageUrl: 'correct_image.jpg',
          incorrectImageUrl: 'incorrect_image.jpg',
          correctImageIndex: 0,
          phase: DifficultyPhase.expert, // Different phase
        );

        expect(challenge, isNot(equals(differentPhaseChallenge)));
      });

      test('should not be equal when image URLs differ', () {
        final differentUrlChallenge = const BreedChallenge(
          correctBreedName: 'Golden Retriever',
          correctImageUrl: 'different_correct.jpg', // Different URL
          incorrectImageUrl: 'incorrect_image.jpg',
          correctImageIndex: 0,
          phase: DifficultyPhase.beginner,
        );

        expect(challenge, isNot(equals(differentUrlChallenge)));
      });
    });

    group('toString', () {
      test('should provide meaningful string representation', () {
        final stringRepr = challenge.toString();

        expect(stringRepr, contains('BreedChallenge'));
        expect(stringRepr, contains('Golden Retriever'));
        expect(stringRepr, contains('correctImageIndex: 0'));
        expect(stringRepr, contains('phase: DifficultyPhase.beginner'));
      });

      test('should handle different phases in string representation', () {
        final expertChallenge = const BreedChallenge(
          correctBreedName: 'Siberian Husky',
          correctImageUrl: 'husky.jpg',
          incorrectImageUrl: 'malamute.jpg',
          correctImageIndex: 1,
          phase: DifficultyPhase.expert,
        );

        final stringRepr = expertChallenge.toString();
        expect(stringRepr, contains('Siberian Husky'));
        expect(stringRepr, contains('correctImageIndex: 1'));
        expect(stringRepr, contains('phase: DifficultyPhase.expert'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty breed name', () {
        final emptyNameChallenge = const BreedChallenge(
          correctBreedName: '',
          correctImageUrl: 'correct.jpg',
          incorrectImageUrl: 'incorrect.jpg',
          correctImageIndex: 0,
          phase: DifficultyPhase.beginner,
        );

        expect(emptyNameChallenge.correctBreedName, equals(''));
        expect(emptyNameChallenge.isCorrectSelection(0), isTrue);
      });

      test('should handle empty image URLs', () {
        final emptyUrlChallenge = const BreedChallenge(
          correctBreedName: 'Test Breed',
          correctImageUrl: '',
          incorrectImageUrl: '',
          correctImageIndex: 0,
          phase: DifficultyPhase.beginner,
        );

        expect(emptyUrlChallenge.getImageUrl(0), equals(''));
        expect(emptyUrlChallenge.getImageUrl(1), equals(''));
        expect(emptyUrlChallenge.imageUrls, equals(['', '']));
      });

      test('should handle all difficulty phases', () {
        final phases = [
          DifficultyPhase.beginner,
          DifficultyPhase.intermediate,
          DifficultyPhase.expert,
        ];

        for (final phase in phases) {
          final phaseChallenge = BreedChallenge(
            correctBreedName: 'Test Breed',
            correctImageUrl: 'correct.jpg',
            incorrectImageUrl: 'incorrect.jpg',
            correctImageIndex: 0,
            phase: phase,
          );

          expect(phaseChallenge.phase, equals(phase));
        }
      });
    });

    group('Validation', () {
      test('should maintain correctImageIndex constraint', () {
        // Test both valid indices
        const challenge0 = BreedChallenge(
          correctBreedName: 'Breed',
          correctImageUrl: 'correct.jpg',
          incorrectImageUrl: 'incorrect.jpg',
          correctImageIndex: 0,
          phase: DifficultyPhase.beginner,
        );

        const challenge1 = BreedChallenge(
          correctBreedName: 'Breed',
          correctImageUrl: 'correct.jpg',
          incorrectImageUrl: 'incorrect.jpg',
          correctImageIndex: 1,
          phase: DifficultyPhase.beginner,
        );

        expect(challenge0.correctImageIndex, equals(0));
        expect(challenge1.correctImageIndex, equals(1));

        // Verify behavior is consistent
        expect(challenge0.isCorrectSelection(0), isTrue);
        expect(challenge0.isCorrectSelection(1), isFalse);
        expect(challenge1.isCorrectSelection(0), isFalse);
        expect(challenge1.isCorrectSelection(1), isTrue);
      });

      test('should handle randomized positioning correctly', () {
        final challenges = [
          const BreedChallenge(
            correctBreedName: 'Breed A',
            correctImageUrl: 'a_correct.jpg',
            incorrectImageUrl: 'a_incorrect.jpg',
            correctImageIndex: 0,
            phase: DifficultyPhase.beginner,
          ),
          const BreedChallenge(
            correctBreedName: 'Breed B',
            correctImageUrl: 'b_correct.jpg',
            incorrectImageUrl: 'b_incorrect.jpg',
            correctImageIndex: 1,
            phase: DifficultyPhase.intermediate,
          ),
        ];

        for (final challenge in challenges) {
          final correctIndex = challenge.correctImageIndex;
          final incorrectIndex = correctIndex == 0 ? 1 : 0;

          expect(challenge.isCorrectSelection(correctIndex), isTrue);
          expect(challenge.isCorrectSelection(incorrectIndex), isFalse);
          expect(
            challenge.getImageUrl(correctIndex),
            equals(challenge.correctImageUrl),
          );
          expect(
            challenge.getImageUrl(incorrectIndex),
            equals(challenge.incorrectImageUrl),
          );
        }
      });
    });
  });
}
