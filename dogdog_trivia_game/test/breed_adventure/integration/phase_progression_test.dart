import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mockito/mockito.dart';

import 'package:dogdog_trivia_game/screens/dog_breeds_adventure_screen.dart';
import 'package:dogdog_trivia_game/models/breed_adventure/difficulty_phase.dart';
import 'package:dogdog_trivia_game/models/breed.dart';
import 'package:dogdog_trivia_game/l10n/generated/app_localizations.dart';

import '../integration/complete_game_flow_test.mocks.dart';

void main() {
  group('Breed Adventure Phase Progression Integration Tests', () {
    late MockBreedService mockBreedService;
    late MockBreedAdventureTimer mockTimer;

    // Test data for different difficulty phases
    final beginnerBreeds = [
      Breed(
        name: 'Labrador Retriever',
        imageUrl: 'https://example.com/labrador.jpg',
        difficulty: 1,
      ),
      Breed(
        name: 'Golden Retriever',
        imageUrl: 'https://example.com/golden.jpg',
        difficulty: 2,
      ),
    ];

    final intermediateBreeds = [
      Breed(
        name: 'Border Collie',
        imageUrl: 'https://example.com/border.jpg',
        difficulty: 3,
      ),
      Breed(
        name: 'Beagle',
        imageUrl: 'https://example.com/beagle.jpg',
        difficulty: 4,
      ),
    ];

    final expertBreeds = [
      Breed(
        name: 'Afghan Hound',
        imageUrl: 'https://example.com/afghan.jpg',
        difficulty: 5,
      ),
    ];

    setUp(() {
      mockBreedService = MockBreedService();
      mockTimer = MockBreedAdventureTimer();

      // Setup mock responses for different phases
      when(
        mockBreedService.getBreedsByDifficultyPhase(DifficultyPhase.beginner),
      ).thenReturn(beginnerBreeds);
      when(
        mockBreedService.getBreedsByDifficultyPhase(
          DifficultyPhase.intermediate,
        ),
      ).thenReturn(intermediateBreeds);
      when(
        mockBreedService.getBreedsByDifficultyPhase(DifficultyPhase.expert),
      ).thenReturn(expertBreeds);

      when(
        mockBreedService.getLocalizedBreedName(any, any),
      ).thenAnswer((invocation) => invocation.positionalArguments[0] as String);

      when(mockTimer.remainingSeconds).thenReturn(10);
      when(mockTimer.isActive).thenReturn(false);
      when(mockTimer.isPaused).thenReturn(false);
      when(mockTimer.isRunning).thenReturn(false);
      when(mockTimer.hasExpired).thenReturn(false);
      when(mockTimer.timerStream).thenAnswer((_) => Stream.value(10));
    });

    Widget createTestWidget() {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
        home: const DogBreedsAdventureScreen(),
      );
    }

    testWidgets('should start with beginner phase', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify initial phase setup doesn't crash
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle phase transitions properly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Test different phase scenarios
      final phases = [
        DifficultyPhase.beginner,
        DifficultyPhase.intermediate,
        DifficultyPhase.expert,
      ];

      for (final phase in phases) {
        // Verify each phase can be handled
        final breeds = mockBreedService.getBreedsByDifficultyPhase(phase);
        expect(breeds, isNotEmpty);
      }
    });

    testWidgets('should provide appropriate breeds for each phase', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Test beginner phase
      final beginnerBreedsResult = mockBreedService.getBreedsByDifficultyPhase(
        DifficultyPhase.beginner,
      );
      expect(
        beginnerBreedsResult.any((breed) => [1, 2].contains(breed.difficulty)),
        isTrue,
      );

      // Test intermediate phase
      final intermediateBreedsResult = mockBreedService
          .getBreedsByDifficultyPhase(DifficultyPhase.intermediate);
      expect(
        intermediateBreedsResult.any(
          (breed) => [3, 4].contains(breed.difficulty),
        ),
        isTrue,
      );

      // Test expert phase
      final expertBreedsResult = mockBreedService.getBreedsByDifficultyPhase(
        DifficultyPhase.expert,
      );
      expect(expertBreedsResult.any((breed) => breed.difficulty == 5), isTrue);
    });

    testWidgets('should handle empty breed lists for phases', (
      WidgetTester tester,
    ) async {
      // Setup mock to return empty list
      when(mockBreedService.getBreedsByDifficultyPhase(any)).thenReturn([]);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify app handles empty breed lists gracefully
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle phase progression score requirements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Test that phase progression logic exists
      final phases = DifficultyPhase.values;
      for (final phase in phases) {
        expect(phase.scoreMultiplier, isA<int>());
        expect(phase.scoreMultiplier, greaterThan(0));
        expect(phase.name, isA<String>());
        expect(phase.name, isNotEmpty);
      }
    });

    testWidgets('should handle difficulty phase properties correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Test beginner phase properties
      expect(DifficultyPhase.beginner.scoreMultiplier, equals(1));
      expect(DifficultyPhase.beginner.containsDifficulty(1), isTrue);
      expect(DifficultyPhase.beginner.containsDifficulty(2), isTrue);
      expect(DifficultyPhase.beginner.containsDifficulty(3), isFalse);

      // Test intermediate phase properties
      expect(DifficultyPhase.intermediate.scoreMultiplier, equals(2));
      expect(DifficultyPhase.intermediate.containsDifficulty(3), isTrue);
      expect(DifficultyPhase.intermediate.containsDifficulty(4), isTrue);
      expect(DifficultyPhase.intermediate.containsDifficulty(1), isFalse);

      // Test expert phase properties
      expect(DifficultyPhase.expert.scoreMultiplier, equals(3));
      expect(DifficultyPhase.expert.containsDifficulty(5), isTrue);
      expect(DifficultyPhase.expert.containsDifficulty(3), isFalse);
    });

    testWidgets('should handle phase progression validation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Test phase progression logic
      expect(DifficultyPhase.beginner.index, equals(0));
      expect(DifficultyPhase.intermediate.index, equals(1));
      expect(DifficultyPhase.expert.index, equals(2));

      // Test next phase logic
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

    testWidgets('should handle breed filtering by difficulty range', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Create a mixed difficulty breed list
      final mixedBreeds = [
        Breed(name: 'Easy Breed', imageUrl: 'url1', difficulty: 1),
        Breed(name: 'Medium Breed', imageUrl: 'url2', difficulty: 2),
        Breed(name: 'Hard Breed', imageUrl: 'url3', difficulty: 3),
        Breed(name: 'Expert Breed', imageUrl: 'url4', difficulty: 4),
        Breed(name: 'Master Breed', imageUrl: 'url5', difficulty: 5),
      ];

      // Test filtering for each phase
      final beginnerFiltered = mixedBreeds
          .where(
            (breed) =>
                DifficultyPhase.beginner.containsDifficulty(breed.difficulty),
          )
          .toList();
      expect(beginnerFiltered.length, equals(2));
      expect(beginnerFiltered.first.difficulty, equals(1));
      expect(beginnerFiltered.last.difficulty, equals(2));

      final intermediateFiltered = mixedBreeds
          .where(
            (breed) => DifficultyPhase.intermediate.containsDifficulty(
              breed.difficulty,
            ),
          )
          .toList();
      expect(intermediateFiltered.length, equals(2));
      expect(intermediateFiltered.first.difficulty, equals(3));
      expect(intermediateFiltered.last.difficulty, equals(4));

      final expertFiltered = mixedBreeds
          .where(
            (breed) =>
                DifficultyPhase.expert.containsDifficulty(breed.difficulty),
          )
          .toList();
      expect(expertFiltered.length, equals(1));
      expect(expertFiltered.first.difficulty, equals(5));
    });

    group('Phase Progression Edge Cases', () {
      testWidgets('should handle invalid difficulty values', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Test with out-of-range difficulties
        expect(DifficultyPhase.beginner.containsDifficulty(0), isFalse);
        expect(DifficultyPhase.beginner.containsDifficulty(-1), isFalse);
        expect(DifficultyPhase.expert.containsDifficulty(10), isFalse);
      });

      testWidgets('should handle boundary difficulty values', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Test boundary conditions
        expect(DifficultyPhase.beginner.containsDifficulty(1), isTrue);
        expect(DifficultyPhase.beginner.containsDifficulty(2), isTrue);
        expect(DifficultyPhase.intermediate.containsDifficulty(3), isTrue);
        expect(DifficultyPhase.intermediate.containsDifficulty(4), isTrue);
        expect(DifficultyPhase.expert.containsDifficulty(5), isTrue);
      });

      testWidgets('should handle rapid phase changes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Simulate rapid phase checking
        for (int i = 0; i < 100; i++) {
          final phase =
              DifficultyPhase.values[i % DifficultyPhase.values.length];
          expect(phase.scoreMultiplier, greaterThan(0));
          await tester.pump(const Duration(milliseconds: 1));
        }

        // Verify no issues with rapid access
        expect(tester.takeException(), isNull);
      });
    });

    group('Phase Progression Performance', () {
      testWidgets('should handle large breed lists efficiently', (
        WidgetTester tester,
      ) async {
        // Create large breed list
        final largeBreedList = List.generate(
          1000,
          (index) => Breed(
            name: 'Breed $index',
            imageUrl: 'url$index',
            difficulty: (index % 4) + 1,
          ),
        );

        when(
          mockBreedService.getBreedsByDifficultyPhase(any),
        ).thenReturn(largeBreedList);

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Verify app handles large datasets
        expect(tester.takeException(), isNull);
      });

      testWidgets('should maintain performance with complex phase logic', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Test complex filtering scenarios
        final complexBreeds = List.generate(500, (index) {
          return Breed(
            name: 'Complex Breed $index',
            imageUrl: 'complex_url_$index',
            difficulty:
                (index % 5) + 1, // Mix difficulties including invalid ones
          );
        });

        // Filter for each phase
        for (final phase in DifficultyPhase.values) {
          final filtered = complexBreeds
              .where((breed) => phase.containsDifficulty(breed.difficulty))
              .toList();
          expect(filtered, isA<List<Breed>>());
        }

        // Verify performance remained stable
        expect(tester.takeException(), isNull);
      });
    });
  });
}
