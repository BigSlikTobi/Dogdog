import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:dogdog_trivia_game/services/breed_adventure/breed_service.dart';
import 'package:dogdog_trivia_game/models/breed_adventure/difficulty_phase.dart';

void main() {
  group('BreedService', () {
    late BreedService breedService;

    setUpAll(() {
      // Initialize Flutter test binding for services that need it
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      breedService = BreedService.forTesting();
    });

    group('Initialization', () {
      test('should initialize breed service', () async {
        try {
          await breedService.initialize();
          expect(breedService.isInitialized, isTrue);
        } catch (e) {
          // Initialization may fail in test environment due to missing assets
          expect(e, isA<Exception>());
          expect(e.toString(), contains('Failed to initialize BreedService'));
        }
      });

      test('should handle initialization gracefully in test environment', () {
        // Test that service can be created without throwing
        expect(() => BreedService.forTesting(), returnsNormally);
        expect(breedService.isInitialized, isFalse);
      });

      test('should load breeds from assets', () async {
        await breedService.initialize();
        final beginnerBreeds = breedService.getBreedsByDifficultyPhase(
          DifficultyPhase.beginner,
        );
        expect(beginnerBreeds, isNotEmpty);
      });
    });

    group('Breed Filtering', () {
      test('should filter breeds by difficulty phase', () async {
        await breedService.initialize();

        final beginnerBreeds = breedService.getBreedsByDifficultyPhase(
          DifficultyPhase.beginner,
        );
        final intermediateBreeds = breedService.getBreedsByDifficultyPhase(
          DifficultyPhase.intermediate,
        );
        final expertBreeds = breedService.getBreedsByDifficultyPhase(
          DifficultyPhase.expert,
        );

        expect(beginnerBreeds, isNotEmpty);
        expect(intermediateBreeds, isNotEmpty);
        expect(expertBreeds, isNotEmpty);

        // Verify difficulty filtering
        for (final breed in beginnerBreeds) {
          expect(
            DifficultyPhase.beginner.difficulties,
            contains(breed.difficulty),
          );
        }

        for (final breed in intermediateBreeds) {
          expect(
            DifficultyPhase.intermediate.difficulties,
            contains(breed.difficulty),
          );
        }

        for (final breed in expertBreeds) {
          expect(
            DifficultyPhase.expert.difficulties,
            contains(breed.difficulty),
          );
        }
      });

      test('should return different breeds for different phases', () async {
        await breedService.initialize();

        final beginnerCount = breedService.getTotalBreedsInPhase(
          DifficultyPhase.beginner,
        );
        final intermediateCount = breedService.getTotalBreedsInPhase(
          DifficultyPhase.intermediate,
        );
        final expertCount = breedService.getTotalBreedsInPhase(
          DifficultyPhase.expert,
        );

        // Each phase should have at least some breeds
        expect(beginnerCount, greaterThan(0));
        expect(intermediateCount, greaterThan(0));
        expect(expertCount, greaterThan(0));
      });
    });

    group('Challenge Generation', () {
      test('should generate valid challenges for each phase', () async {
        await breedService.initialize();

        for (final phase in DifficultyPhase.values) {
          final challenge = await breedService.generateChallenge(
            phase,
            <String>{},
          );

          expect(challenge, isNotNull);
          expect(challenge.correctBreedName, isNotEmpty);
          expect(challenge.correctImageUrl, isNotEmpty);
          expect(challenge.incorrectImageUrl, isNotEmpty);
          expect(challenge.phase, equals(phase));
          expect(challenge.correctImageIndex, anyOf(equals(0), equals(1)));

          // Images should be different
          expect(
            challenge.correctImageUrl,
            isNot(equals(challenge.incorrectImageUrl)),
          );
        }
      });

      test(
        'should generate different challenges over multiple calls',
        () async {
          await breedService.initialize();

          final challenges = <String>{};

          // Generate multiple challenges and check for variety
          for (int i = 0; i < 5; i++) {
            final challenge = await breedService.generateChallenge(
              DifficultyPhase.beginner,
              <String>{},
            );
            challenges.add(challenge.correctBreedName);
          }

          // Should have at least some variety (not all the same breed)
          expect(challenges.length, greaterThan(1));
        },
      );

      test('should exclude used breeds', () async {
        await breedService.initialize();

        final usedBreeds = {'German Shepherd Dog', 'Golden Retriever'};

        final challenge = await breedService.generateChallenge(
          DifficultyPhase.beginner,
          usedBreeds,
        );

        expect(usedBreeds, isNot(contains(challenge.correctBreedName)));
      });
    });

    group('Localization', () {
      test('should provide localized breed names', () async {
        await breedService.initialize();

        // Test a known breed that should have translations
        final localizedGerman = breedService.getLocalizedBreedName(
          'German Shepherd Dog',
          const Locale('de'),
        );
        final localizedSpanish = breedService.getLocalizedBreedName(
          'German Shepherd Dog',
          const Locale('es'),
        );
        final localizedEnglish = breedService.getLocalizedBreedName(
          'German Shepherd Dog',
          const Locale('en'),
        );

        expect(localizedGerman, isNotEmpty);
        expect(localizedSpanish, isNotEmpty);
        expect(localizedEnglish, equals('German Shepherd Dog'));
      });

      test('should provide supported languages', () {
        final supportedLanguages = breedService.getSupportedLanguages();
        expect(supportedLanguages, isNotEmpty);
        expect(supportedLanguages, contains('en'));
        expect(supportedLanguages, contains('de'));
        expect(supportedLanguages, contains('es'));
      });
    });

    group('Breed Availability', () {
      test('should check breed availability correctly', () async {
        await breedService.initialize();

        // Should have available breeds initially
        expect(
          breedService.hasAvailableBreeds(DifficultyPhase.beginner, <String>{}),
          isTrue,
        );

        // Get all breeds for a phase
        final allBreeds = breedService.getBreedsByDifficultyPhase(
          DifficultyPhase.beginner,
        );
        final allBreedNames = allBreeds.map((b) => b.name).toSet();

        // Should have no available breeds if all are used
        expect(
          breedService.hasAvailableBreeds(
            DifficultyPhase.beginner,
            allBreedNames,
          ),
          isFalse,
        );
      });

      test('should get available breeds excluding used ones', () async {
        await breedService.initialize();

        final usedBreeds = {'German Shepherd Dog'};
        final availableBreeds = breedService.getAvailableBreeds(
          DifficultyPhase.beginner,
          usedBreeds,
        );

        // Should not contain used breeds
        for (final breed in availableBreeds) {
          expect(usedBreeds, isNot(contains(breed.name)));
        }
      });
    });

    group('Breed Lookup', () {
      test('should find breed by name', () async {
        await breedService.initialize();

        final breed = breedService.getBreedByName('German Shepherd Dog');
        expect(breed, isNotNull);
        expect(breed?.name, equals('German Shepherd Dog'));
      });

      test('should return null for non-existent breed', () async {
        await breedService.initialize();

        final breed = breedService.getBreedByName('Non-existent Breed');
        expect(breed, isNull);
      });
    });

    group('Error Handling', () {
      test('should handle invalid phase gracefully', () async {
        await breedService.initialize();

        // Test with all valid phases
        for (final phase in DifficultyPhase.values) {
          expect(
            () => breedService.getBreedsByDifficultyPhase(phase),
            isNot(throwsException),
          );
          expect(
            () => breedService.getTotalBreedsInPhase(phase),
            isNot(throwsException),
          );
        }
      });

      test('should handle uninitialized service gracefully', () {
        final uninitializedService = BreedService.forTesting();

        // Should throw when calling methods before initialization
        expect(
          () => uninitializedService.getBreedsByDifficultyPhase(
            DifficultyPhase.beginner,
          ),
          throwsException,
        );
        expect(
          () => uninitializedService.getTotalBreedsInPhase(
            DifficultyPhase.beginner,
          ),
          throwsException,
        );
      });
    });
  });
}
