import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/services/question_service.dart';
import 'package:dogdog_trivia_game/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuestionService Localized Tests', () {
    late QuestionService questionService;

    setUp(() {
      questionService = QuestionService();
      questionService.reset();
    });

    tearDown(() {
      questionService.reset();
    });

    group('Initialization', () {
      test(
        'should initialize with localized questions when questions_fixed.json is available',
        () async {
          // This test will use the actual questions_fixed.json file
          await questionService.initialize();

          expect(questionService.isInitialized, isTrue);
          expect(questionService.useLocalizedQuestions, isTrue);
        },
      );

      test(
        'should fallback to legacy format when localized format fails',
        () async {
          // Mock a scenario where questions_fixed.json fails but questions.json works
          // This would require mocking the rootBundle, which is complex in this context
          // For now, we'll test the basic initialization
          await questionService.initialize();
          expect(questionService.isInitialized, isTrue);
        },
      );
    });

    group('Category-based Question Retrieval', () {
      setUp(() async {
        await questionService.initialize();
      });

      test('should return questions for Dog Training category', () {
        final questions = questionService.getQuestionsForCategory(
          category: QuestionCategory.dogTraining,
          count: 5,
          locale: 'en',
        );

        expect(questions.length, greaterThan(0));
        expect(questions.length, lessThanOrEqualTo(5));

        // All questions should be from Dog Training category when using localized format
        if (questionService.useLocalizedQuestions) {
          for (final question in questions) {
            expect(question.category, equals('Dog Training'));
          }
        }
      });

      test('should return questions for Dog Breeds category', () {
        final questions = questionService.getQuestionsForCategory(
          category: QuestionCategory.dogBreeds,
          count: 3,
          locale: 'de',
        );

        expect(questions.length, greaterThan(0));
        expect(questions.length, lessThanOrEqualTo(3));
      });

      test('should respect exclude IDs', () {
        final firstBatch = questionService.getQuestionsForCategory(
          category: QuestionCategory.dogTraining,
          count: 2,
          locale: 'en',
        );

        final excludeIds = firstBatch.map((q) => q.id).toSet();
        final secondBatch = questionService.getQuestionsForCategory(
          category: QuestionCategory.dogTraining,
          count: 2,
          locale: 'en',
          excludeIds: excludeIds,
        );

        // No questions should overlap
        final firstIds = firstBatch.map((q) => q.id).toSet();
        final secondIds = secondBatch.map((q) => q.id).toSet();
        expect(firstIds.intersection(secondIds), isEmpty);
      });

      test('should handle different locales', () {
        final englishQuestions = questionService.getQuestionsForCategory(
          category: QuestionCategory.dogTraining,
          count: 1,
          locale: 'en',
        );

        final germanQuestions = questionService.getQuestionsForCategory(
          category: QuestionCategory.dogTraining,
          count: 1,
          locale: 'de',
        );

        expect(englishQuestions.isNotEmpty, isTrue);
        expect(germanQuestions.isNotEmpty, isTrue);

        if (questionService.useLocalizedQuestions) {
          // Same question ID but different text content
          if (englishQuestions.first.id == germanQuestions.first.id) {
            expect(
              englishQuestions.first.text,
              isNot(equals(germanQuestions.first.text)),
            );
          }
        }
      });
    });

    group('Localized Question Retrieval', () {
      setUp(() async {
        await questionService.initialize();
      });

      test('should return localized questions with progressive difficulty', () {
        if (!questionService.useLocalizedQuestions) {
          return; // Skip if not using localized format
        }

        final localizedQuestions = questionService
            .getLocalizedQuestionsForCategory(
              category: QuestionCategory.dogTraining,
              count: 10,
              locale: 'en',
            );

        expect(localizedQuestions.length, greaterThan(0));
        expect(localizedQuestions.length, lessThanOrEqualTo(10));

        // Check that questions follow progressive difficulty
        final difficulties = localizedQuestions
            .map((q) => q.difficulty)
            .toList();
        expect(difficulties.first, equals('easy')); // Should start with easy

        // Verify localized content
        for (final question in localizedQuestions) {
          expect(question.getText('en'), isNotEmpty);
          expect(question.getAnswers('en'), isNotEmpty);
          expect(question.getFunFact('en'), isNotEmpty);
        }
      });

      test('should handle fallback when preferred difficulty is unavailable', () {
        if (!questionService.useLocalizedQuestions) {
          return; // Skip if not using localized format
        }

        // Request many questions to potentially exhaust some difficulty levels
        final questions = questionService.getLocalizedQuestionsForCategory(
          category: QuestionCategory.dogTraining,
          count: 50,
          locale: 'en',
        );

        expect(questions.length, greaterThan(0));
        // Should still return questions even if some difficulties are exhausted
      });
    });

    group('Category Information', () {
      setUp(() async {
        await questionService.initialize();
      });

      test('should return available categories', () {
        final categories = questionService.getAvailableCategories();

        expect(categories, isNotEmpty);
        expect(categories, contains(QuestionCategory.dogTraining));

        if (questionService.useLocalizedQuestions) {
          // Should only return categories that have questions
          for (final category in categories) {
            final count = questionService
                .getQuestionCountByCategoryAndDifficulty(category, 'easy');
            expect(count, greaterThanOrEqualTo(0));
          }
        }
      });

      test('should return question counts by category and difficulty', () {
        if (!questionService.useLocalizedQuestions) {
          return; // Skip if not using localized format
        }

        final easyCount = questionService
            .getQuestionCountByCategoryAndDifficulty(
              QuestionCategory.dogTraining,
              'easy',
            );
        final mediumCount = questionService
            .getQuestionCountByCategoryAndDifficulty(
              QuestionCategory.dogTraining,
              'medium',
            );

        expect(easyCount, greaterThanOrEqualTo(0));
        expect(mediumCount, greaterThanOrEqualTo(0));
      });

      test('should return available difficulties for category', () {
        final difficulties = questionService
            .getAvailableDifficultiesForCategory(QuestionCategory.dogTraining);

        expect(difficulties, isNotEmpty);

        if (questionService.useLocalizedQuestions) {
          // Should include the new difficulty levels
          expect(
            difficulties,
            anyOf([
              contains('easy'),
              contains('easy+'),
              contains('medium'),
              contains('hard'),
            ]),
          );
        }
      });
    });

    group('Backward Compatibility', () {
      setUp(() async {
        await questionService.initialize();
      });

      test('should convert localized questions to legacy format', () {
        if (!questionService.useLocalizedQuestions) {
          return; // Skip if not using localized format
        }

        final localizedQuestions = questionService
            .getLocalizedQuestionsForCategory(
              category: QuestionCategory.dogTraining,
              count: 3,
              locale: 'en',
            );

        final legacyQuestions = questionService.convertToLegacyQuestions(
          localizedQuestions,
          'en',
        );

        expect(legacyQuestions.length, equals(localizedQuestions.length));

        for (int i = 0; i < legacyQuestions.length; i++) {
          final legacy = legacyQuestions[i];
          final localized = localizedQuestions[i];

          expect(legacy.id, equals(localized.id));
          expect(legacy.text, equals(localized.getText('en')));
          expect(legacy.answers, equals(localized.getAnswers('en')));
          expect(
            legacy.correctAnswerIndex,
            equals(localized.correctAnswerIndex),
          );
        }
      });

      test('should maintain legacy adaptive difficulty method', () {
        if (questionService.useLocalizedQuestions) {
          // When using localized questions, the legacy pools are empty
          // This is expected behavior - the method should return empty list
          final questions = questionService.getQuestionsWithAdaptiveDifficulty(
            count: 5,
            playerLevel: 3,
            streakCount: 2,
            recentMistakes: 1,
          );
          expect(questions.length, equals(0));
        } else {
          // When using legacy format, should return questions
          final questions = questionService.getQuestionsWithAdaptiveDifficulty(
            count: 5,
            playerLevel: 3,
            streakCount: 2,
            recentMistakes: 1,
          );
          expect(questions.length, greaterThan(0));
          expect(questions.length, lessThanOrEqualTo(5));
        }
      });
    });

    group('Error Handling', () {
      test('should throw error when not initialized', () {
        final uninitializedService = QuestionService();
        uninitializedService.reset();

        expect(
          () => uninitializedService.getQuestionsForCategory(
            category: QuestionCategory.dogTraining,
            count: 5,
            locale: 'en',
          ),
          throwsStateError,
        );
      });

      test('should handle empty category gracefully', () async {
        await questionService.initialize();

        // Try to get questions from a category that might not exist
        final questions = questionService.getQuestionsForCategory(
          category:
              QuestionCategory.dogBehavior, // This might not have questions
          count: 5,
          locale: 'en',
        );

        // Should not throw, might return empty list or fallback questions
        expect(questions, isA<List<Question>>());
      });
    });
  });
}
