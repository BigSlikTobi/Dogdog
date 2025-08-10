import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/models/models.dart';

void main() {
  group('Breed Model Tests', () {
    test('should create Breed from JSON correctly', () {
      final json = {
        'breed': 'Golden Retriever',
        'url': 'https://example.com/golden-retriever.jpg',
        'difficulty': '3',
      };

      final breed = Breed.fromJson(json);

      expect(breed.name, equals('Golden Retriever'));
      expect(
        breed.imageUrl,
        equals('https://example.com/golden-retriever.jpg'),
      );
      expect(breed.difficulty, equals(3));
    });

    test('should convert Breed to JSON correctly', () {
      const breed = Breed(
        name: 'German Shepherd',
        imageUrl: 'https://example.com/german-shepherd.jpg',
        difficulty: 4,
      );

      final json = breed.toJson();

      expect(json['breed'], equals('German Shepherd'));
      expect(json['url'], equals('https://example.com/german-shepherd.jpg'));
      expect(json['difficulty'], equals('4'));
    });

    test('should handle equality correctly', () {
      const breed1 = Breed(
        name: 'Beagle',
        imageUrl: 'https://example.com/beagle.jpg',
        difficulty: 2,
      );

      const breed2 = Breed(
        name: 'Beagle',
        imageUrl: 'https://example.com/beagle.jpg',
        difficulty: 2,
      );

      const breed3 = Breed(
        name: 'Bulldog',
        imageUrl: 'https://example.com/bulldog.jpg',
        difficulty: 2,
      );

      expect(breed1, equals(breed2));
      expect(breed1, isNot(equals(breed3)));
    });
  });

  group('DifficultyPhase Tests', () {
    test('should contain correct difficulty levels', () {
      expect(DifficultyPhase.beginner.difficulties, equals([1, 2]));
      expect(DifficultyPhase.intermediate.difficulties, equals([3, 4]));
      expect(DifficultyPhase.expert.difficulties, equals([5]));
    });

    test('should have correct score multipliers', () {
      expect(DifficultyPhase.beginner.scoreMultiplier, equals(1));
      expect(DifficultyPhase.intermediate.scoreMultiplier, equals(2));
      expect(DifficultyPhase.expert.scoreMultiplier, equals(3));
    });

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

    test('should correctly identify if difficulty belongs to phase', () {
      expect(DifficultyPhase.beginner.containsDifficulty(1), isTrue);
      expect(DifficultyPhase.beginner.containsDifficulty(2), isTrue);
      expect(DifficultyPhase.beginner.containsDifficulty(3), isFalse);

      expect(DifficultyPhase.intermediate.containsDifficulty(3), isTrue);
      expect(DifficultyPhase.intermediate.containsDifficulty(4), isTrue);
      expect(DifficultyPhase.intermediate.containsDifficulty(5), isFalse);

      expect(DifficultyPhase.expert.containsDifficulty(5), isTrue);
      expect(DifficultyPhase.expert.containsDifficulty(4), isFalse);
    });
  });

  group('BreedChallenge Tests', () {
    test('should return correct image URL for index', () {
      const challenge = BreedChallenge(
        correctBreedName: 'Dalmatian',
        correctImageUrl: 'https://example.com/dalmatian.jpg',
        incorrectImageUrl: 'https://example.com/beagle.jpg',
        correctImageIndex: 0,
        phase: DifficultyPhase.beginner,
      );

      expect(
        challenge.getImageUrl(0),
        equals('https://example.com/dalmatian.jpg'),
      );
      expect(
        challenge.getImageUrl(1),
        equals('https://example.com/beagle.jpg'),
      );
    });

    test('should correctly identify correct selection', () {
      const challenge = BreedChallenge(
        correctBreedName: 'Poodle',
        correctImageUrl: 'https://example.com/poodle.jpg',
        incorrectImageUrl: 'https://example.com/collie.jpg',
        correctImageIndex: 1,
        phase: DifficultyPhase.intermediate,
      );

      expect(challenge.isCorrectSelection(0), isFalse);
      expect(challenge.isCorrectSelection(1), isTrue);
    });

    test('should return image URLs in correct order', () {
      const challenge = BreedChallenge(
        correctBreedName: 'Boxer',
        correctImageUrl: 'https://example.com/boxer.jpg',
        incorrectImageUrl: 'https://example.com/bulldog.jpg',
        correctImageIndex: 0,
        phase: DifficultyPhase.beginner,
      );

      final imageUrls = challenge.imageUrls;
      expect(imageUrls.length, equals(2));
      expect(imageUrls[0], equals('https://example.com/boxer.jpg'));
      expect(imageUrls[1], equals('https://example.com/bulldog.jpg'));
    });
  });

  group('BreedAdventureGameState Tests', () {
    test('should create initial state correctly', () {
      final initialState = BreedAdventureGameState.initial();

      expect(initialState.score, equals(0));
      expect(initialState.correctAnswers, equals(0));
      expect(initialState.totalQuestions, equals(0));
      expect(initialState.currentPhase, equals(DifficultyPhase.beginner));
      expect(initialState.usedBreeds, isEmpty);
      expect(initialState.isGameActive, isFalse);
      expect(initialState.consecutiveCorrect, equals(0));
      expect(initialState.timeRemaining, equals(10));
      expect(initialState.powerUps[PowerUpType.hint], equals(2));
      expect(initialState.powerUps[PowerUpType.extraTime], equals(2));
      expect(initialState.powerUps[PowerUpType.skip], equals(1));
      expect(initialState.powerUps[PowerUpType.secondChance], equals(1));
    });

    test('should calculate accuracy correctly', () {
      final state = BreedAdventureGameState.initial().copyWith(
        correctAnswers: 8,
        totalQuestions: 10,
      );

      expect(state.accuracy, equals(80.0));
    });

    test('should identify power-up reward eligibility', () {
      final state1 = BreedAdventureGameState.initial().copyWith(
        consecutiveCorrect: 5,
      );

      final state2 = BreedAdventureGameState.initial().copyWith(
        consecutiveCorrect: 3,
      );

      expect(state1.shouldReceivePowerUpReward, isTrue);
      expect(state2.shouldReceivePowerUpReward, isFalse);
    });

    test('should check power-up availability correctly', () {
      final state = BreedAdventureGameState.initial();

      expect(state.hasPowerUp(PowerUpType.hint), isTrue);
      expect(state.hasPowerUp(PowerUpType.extraTime), isTrue);
      expect(state.hasPowerUp(PowerUpType.skip), isTrue);
      expect(state.hasPowerUp(PowerUpType.secondChance), isTrue);

      final emptyState = state.copyWith(
        powerUps: {
          PowerUpType.hint: 0,
          PowerUpType.extraTime: 0,
          PowerUpType.skip: 0,
          PowerUpType.secondChance: 0,
        },
      );

      expect(emptyState.hasPowerUp(PowerUpType.hint), isFalse);
    });

    test('should copy with updated values correctly', () {
      final initialState = BreedAdventureGameState.initial();
      final updatedState = initialState.copyWith(
        score: 100,
        correctAnswers: 5,
        currentPhase: DifficultyPhase.intermediate,
        isGameActive: true,
      );

      expect(updatedState.score, equals(100));
      expect(updatedState.correctAnswers, equals(5));
      expect(updatedState.currentPhase, equals(DifficultyPhase.intermediate));
      expect(updatedState.isGameActive, isTrue);
      // Unchanged values should remain the same
      expect(updatedState.totalQuestions, equals(0));
      expect(updatedState.consecutiveCorrect, equals(0));
    });
  });

  group('PathType Integration Tests', () {
    test('should include breedAdventure in PathType enum', () {
      final allPathTypes = PathType.values;
      expect(allPathTypes, contains(PathType.breedAdventure));
    });

    test('should have correct display name for breedAdventure', () {
      expect(PathType.breedAdventure.displayName, equals('Breed Adventure'));
    });

    test('should have correct description for breedAdventure', () {
      expect(
        PathType.breedAdventure.description,
        equals(
          'Test your breed identification skills with timed picture challenges',
        ),
      );
    });
  });
}
