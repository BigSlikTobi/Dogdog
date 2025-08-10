import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/models/models.dart';
import 'package:dogdog_trivia_game/services/breed_service.dart';

void main() {
  group('BreedService Core Functionality Tests', () {
    late BreedService breedService;

    setUp(() {
      breedService = BreedService.forTesting();
    });

    group('Breed Localization', () {
      test('should return German breed names for German locale', () {
        const locale = Locale('de');

        expect(
          breedService.getLocalizedBreedName('German Shepherd Dog', locale),
          equals('Deutscher Schäferhund'),
        );
        expect(
          breedService.getLocalizedBreedName('Golden Retriever', locale),
          equals('Golden Retriever'),
        );
        expect(
          breedService.getLocalizedBreedName('Dalmatian', locale),
          equals('Dalmatiner'),
        );
        expect(
          breedService.getLocalizedBreedName('French Bulldog', locale),
          equals('Französische Bulldogge'),
        );
      });

      test('should return Spanish breed names for Spanish locale', () {
        const locale = Locale('es');

        expect(
          breedService.getLocalizedBreedName('German Shepherd Dog', locale),
          equals('Pastor Alemán'),
        );
        expect(
          breedService.getLocalizedBreedName('Golden Retriever', locale),
          equals('Golden Retriever'),
        );
        expect(
          breedService.getLocalizedBreedName('Dalmatian', locale),
          equals('Dálmata'),
        );
        expect(
          breedService.getLocalizedBreedName('French Bulldog', locale),
          equals('Bulldog Francés'),
        );
      });

      test('should return English breed names for English locale', () {
        const locale = Locale('en');

        expect(
          breedService.getLocalizedBreedName('German Shepherd Dog', locale),
          equals('German Shepherd Dog'),
        );
        expect(
          breedService.getLocalizedBreedName('Golden Retriever', locale),
          equals('Golden Retriever'),
        );
        expect(
          breedService.getLocalizedBreedName('French Bulldog', locale),
          equals('French Bulldog'),
        );
      });

      test('should fallback to English when translation not available', () {
        const locale = Locale('de');

        expect(
          breedService.getLocalizedBreedName('Unknown Breed', locale),
          equals('Unknown Breed'),
        );
      });

      test('should fallback to original name when no translation exists', () {
        const locale = Locale('fr'); // Unsupported language

        expect(
          breedService.getLocalizedBreedName('German Shepherd Dog', locale),
          equals('German Shepherd Dog'),
        );
      });

      test('should handle partial breed name matches', () {
        const locale = Locale('de');

        // Test with breed name that contains a translatable part
        expect(
          breedService.getLocalizedBreedName('Dachshund (Standard)', locale),
          equals('Dackel'),
        );
        expect(
          breedService.getLocalizedBreedName('Yorkshire Terrier', locale),
          equals('Yorkshire Terrier'),
        );
      });

      test('should return supported languages', () {
        final languages = breedService.getSupportedLanguages();

        expect(languages, containsAll(['en', 'de', 'es']));
        expect(languages.length, equals(3));
      });

      test('should check if breed has translation', () {
        expect(breedService.hasTranslation('German Shepherd Dog'), isTrue);
        expect(breedService.hasTranslation('Golden Retriever'), isTrue);
        expect(breedService.hasTranslation('Unknown Breed'), isFalse);
        expect(
          breedService.hasTranslation('Dachshund (Standard)'),
          isTrue,
        ); // Partial match
      });
    });

    group('Difficulty Phase Logic', () {
      test('should correctly identify difficulty phases', () {
        expect(DifficultyPhase.beginner.containsDifficulty(1), isTrue);
        expect(DifficultyPhase.beginner.containsDifficulty(2), isTrue);
        expect(DifficultyPhase.beginner.containsDifficulty(3), isFalse);

        expect(DifficultyPhase.intermediate.containsDifficulty(3), isTrue);
        expect(DifficultyPhase.intermediate.containsDifficulty(4), isTrue);
        expect(DifficultyPhase.intermediate.containsDifficulty(5), isFalse);

        expect(DifficultyPhase.expert.containsDifficulty(5), isTrue);
        expect(DifficultyPhase.expert.containsDifficulty(4), isFalse);
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
    });

    group('Breed Challenge Logic', () {
      test('should create valid breed challenge', () {
        const challenge = BreedChallenge(
          correctBreedName: 'Golden Retriever',
          correctImageUrl: 'https://example.com/golden-retriever.jpg',
          incorrectImageUrl: 'https://example.com/beagle.jpg',
          correctImageIndex: 0,
          phase: DifficultyPhase.intermediate,
        );

        expect(
          challenge.getImageUrl(0),
          equals('https://example.com/golden-retriever.jpg'),
        );
        expect(
          challenge.getImageUrl(1),
          equals('https://example.com/beagle.jpg'),
        );
        expect(challenge.isCorrectSelection(0), isTrue);
        expect(challenge.isCorrectSelection(1), isFalse);

        final imageUrls = challenge.imageUrls;
        expect(imageUrls.length, equals(2));
        expect(
          imageUrls[0],
          equals('https://example.com/golden-retriever.jpg'),
        );
        expect(imageUrls[1], equals('https://example.com/beagle.jpg'));
      });

      test('should handle different correct image positions', () {
        const challenge1 = BreedChallenge(
          correctBreedName: 'Beagle',
          correctImageUrl: 'https://example.com/beagle.jpg',
          incorrectImageUrl: 'https://example.com/collie.jpg',
          correctImageIndex: 1,
          phase: DifficultyPhase.beginner,
        );

        expect(
          challenge1.getImageUrl(0),
          equals('https://example.com/collie.jpg'),
        );
        expect(
          challenge1.getImageUrl(1),
          equals('https://example.com/beagle.jpg'),
        );
        expect(challenge1.isCorrectSelection(0), isFalse);
        expect(challenge1.isCorrectSelection(1), isTrue);
      });
    });

    group('Service State Management', () {
      test('should track initialization state', () {
        expect(breedService.isInitialized, isFalse);

        // Since we can't easily mock the asset loading in this test,
        // we'll just verify the state tracking works
      });

      test('should throw exception when not initialized', () {
        expect(
          () =>
              breedService.getBreedsByDifficultyPhase(DifficultyPhase.beginner),
          throwsException,
        );
      });

      test('should reset properly', () {
        breedService.reset();
        expect(breedService.isInitialized, isFalse);
      });
    });

    group('Singleton Pattern', () {
      test('should return same instance', () {
        final instance1 = BreedService.instance;
        final instance2 = BreedService.instance;

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('Breed Model Integration', () {
      test('should work with Breed model', () {
        const breed = Breed(
          name: 'Golden Retriever',
          imageUrl: 'https://example.com/golden-retriever.jpg',
          difficulty: 3,
        );

        expect(
          DifficultyPhase.intermediate.containsDifficulty(breed.difficulty),
          isTrue,
        );
        expect(
          DifficultyPhase.beginner.containsDifficulty(breed.difficulty),
          isFalse,
        );
        expect(
          DifficultyPhase.expert.containsDifficulty(breed.difficulty),
          isFalse,
        );
      });
    });

    group('Error Handling', () {
      test('should handle invalid breed names gracefully', () {
        const locale = Locale('en');

        expect(breedService.getLocalizedBreedName('', locale), equals(''));
        expect(
          breedService.getLocalizedBreedName('   ', locale),
          equals('   '),
        );
        expect(
          breedService.getLocalizedBreedName('Unknown Breed', locale),
          equals('Unknown Breed'),
        );
      });

      test('should handle null-like inputs gracefully', () {
        expect(breedService.hasTranslation(''), isFalse);
        expect(breedService.getSupportedLanguages().isNotEmpty, isTrue);
      });
    });
  });
}
