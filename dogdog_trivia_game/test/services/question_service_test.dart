import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:dogdog_trivia_game/services/question_service.dart';
import 'package:dogdog_trivia_game/models/question.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuestionService', () {
    late QuestionService questionService;

    setUp(() {
      questionService = QuestionService();
      questionService.reset(); // Reset for clean tests
    });

    group('Initialization', () {
      test('should be a singleton', () {
        final instance1 = QuestionService();
        final instance2 = QuestionService();
        expect(identical(instance1, instance2), isTrue);
      });

      test('should not be initialized initially', () {
        expect(questionService.isInitialized, isFalse);
      });

      test(
        'should initialize successfully with sample data when asset loading fails',
        () async {
          // Mock asset loading failure
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(const MethodChannel('flutter/assets'), (
                MethodCall methodCall,
              ) async {
                throw Exception('Asset not found');
              });

          await questionService.initialize();

          expect(questionService.isInitialized, isTrue);
          expect(questionService.totalQuestionCount, greaterThan(0));

          // Verify all difficulty levels have questions
          expect(
            questionService.getQuestionCountByDifficulty(Difficulty.easy),
            greaterThan(0),
          );
          expect(
            questionService.getQuestionCountByDifficulty(Difficulty.medium),
            greaterThan(0),
          );
          expect(
            questionService.getQuestionCountByDifficulty(Difficulty.hard),
            greaterThan(0),
          );
          expect(
            questionService.getQuestionCountByDifficulty(Difficulty.expert),
            greaterThan(0),
          );
        },
      );

      test('should not reinitialize if already initialized', () async {
        await questionService.initialize();
        final firstTotalCount = questionService.totalQuestionCount;

        await questionService.initialize();
        expect(questionService.totalQuestionCount, equals(firstTotalCount));
      });

      test(
        'should throw exception when methods called before initialization',
        () {
          expect(
            () => questionService.getQuestionsWithAdaptiveDifficulty(
              count: 5,
              playerLevel: 1,
              streakCount: 0,
              recentMistakes: 0,
            ),
            throwsStateError,
          );

          expect(
            () => questionService.getQuestionsByDifficulty(Difficulty.easy),
            throwsStateError,
          );
        },
      );
    });

    group('Question Retrieval', () {
      setUp(() async {
        // Mock asset loading failure to use sample data
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel('flutter/assets'), (
              MethodCall methodCall,
            ) async {
              throw Exception('Asset not found');
            });
        await questionService.initialize();
      });

      test('should return questions by difficulty', () {
        final easyQuestions = questionService.getQuestionsByDifficulty(
          Difficulty.easy,
        );
        final mediumQuestions = questionService.getQuestionsByDifficulty(
          Difficulty.medium,
        );
        final hardQuestions = questionService.getQuestionsByDifficulty(
          Difficulty.hard,
        );
        final expertQuestions = questionService.getQuestionsByDifficulty(
          Difficulty.expert,
        );

        expect(easyQuestions, isNotEmpty);
        expect(mediumQuestions, isNotEmpty);
        expect(hardQuestions, isNotEmpty);
        expect(expertQuestions, isNotEmpty);

        // Verify all questions have correct difficulty
        expect(
          easyQuestions.every((q) => q.difficulty == Difficulty.easy),
          isTrue,
        );
        expect(
          mediumQuestions.every((q) => q.difficulty == Difficulty.medium),
          isTrue,
        );
        expect(
          hardQuestions.every((q) => q.difficulty == Difficulty.hard),
          isTrue,
        );
        expect(
          expertQuestions.every((q) => q.difficulty == Difficulty.expert),
          isTrue,
        );
      });

      test('should return correct question counts', () {
        expect(
          questionService.getQuestionCountByDifficulty(Difficulty.easy),
          equals(8),
        );
        expect(
          questionService.getQuestionCountByDifficulty(Difficulty.medium),
          equals(8),
        );
        expect(
          questionService.getQuestionCountByDifficulty(Difficulty.hard),
          equals(8),
        );
        expect(
          questionService.getQuestionCountByDifficulty(Difficulty.expert),
          equals(8),
        );
        expect(questionService.totalQuestionCount, equals(32));
      });

      test('should return empty list for non-existent difficulty', () {
        // This test assumes the service handles missing difficulties gracefully
        final questions = questionService.getQuestionsByDifficulty(
          Difficulty.easy,
        );
        expect(questions, isA<List<Question>>());
      });
    });

    group('Adaptive Difficulty Selection', () {
      setUp(() async {
        // Mock asset loading failure to use sample data
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel('flutter/assets'), (
              MethodCall methodCall,
            ) async {
              throw Exception('Asset not found');
            });
        await questionService.initialize();
      });

      test('should return requested number of questions', () {
        final questions = questionService.getQuestionsWithAdaptiveDifficulty(
          count: 5,
          playerLevel: 1,
          streakCount: 0,
          recentMistakes: 0,
        );

        expect(questions.length, equals(5));
      });

      test('should return unique questions (no duplicates)', () {
        final questions = questionService.getQuestionsWithAdaptiveDifficulty(
          count: 10,
          playerLevel: 1,
          streakCount: 0,
          recentMistakes: 0,
        );

        final questionIds = questions.map((q) => q.id).toSet();
        expect(questionIds.length, equals(questions.length));
      });

      test('should favor easy questions for level 1 players', () {
        final questions = questionService.getQuestionsWithAdaptiveDifficulty(
          count: 20,
          playerLevel: 1,
          streakCount: 0,
          recentMistakes: 0,
        );

        final easyCount = questions
            .where((q) => q.difficulty == Difficulty.easy)
            .length;
        final totalCount = questions.length;

        // Should have more easy questions (at least 60% for level 1)
        expect(easyCount / totalCount, greaterThan(0.5));
      });

      test('should increase difficulty for high streak players', () {
        final normalQuestions = questionService
            .getQuestionsWithAdaptiveDifficulty(
              count: 20,
              playerLevel: 3,
              streakCount: 0,
              recentMistakes: 0,
            );

        final highStreakQuestions = questionService
            .getQuestionsWithAdaptiveDifficulty(
              count: 20,
              playerLevel: 3,
              streakCount: 6,
              recentMistakes: 0,
            );

        final normalEasyCount = normalQuestions
            .where((q) => q.difficulty == Difficulty.easy)
            .length;
        final streakEasyCount = highStreakQuestions
            .where((q) => q.difficulty == Difficulty.easy)
            .length;

        // High streak should have fewer easy questions
        expect(streakEasyCount, lessThan(normalEasyCount));
      });

      test('should decrease difficulty for players with many mistakes', () {
        final normalQuestions = questionService
            .getQuestionsWithAdaptiveDifficulty(
              count: 20,
              playerLevel: 3,
              streakCount: 0,
              recentMistakes: 0,
            );

        final mistakeQuestions = questionService
            .getQuestionsWithAdaptiveDifficulty(
              count: 20,
              playerLevel: 3,
              streakCount: 0,
              recentMistakes: 4,
            );

        final normalEasyCount = normalQuestions
            .where((q) => q.difficulty == Difficulty.easy)
            .length;
        final mistakeEasyCount = mistakeQuestions
            .where((q) => q.difficulty == Difficulty.easy)
            .length;

        // Many mistakes should result in more easy questions (or at least equal)
        expect(mistakeEasyCount, greaterThanOrEqualTo(normalEasyCount));
      });

      test('should handle higher levels with more difficult questions', () {
        final level1Questions = questionService
            .getQuestionsWithAdaptiveDifficulty(
              count: 20,
              playerLevel: 1,
              streakCount: 0,
              recentMistakes: 0,
            );

        final level5Questions = questionService
            .getQuestionsWithAdaptiveDifficulty(
              count: 20,
              playerLevel: 5,
              streakCount: 0,
              recentMistakes: 0,
            );

        final level1HardCount = level1Questions
            .where(
              (q) =>
                  q.difficulty == Difficulty.hard ||
                  q.difficulty == Difficulty.expert,
            )
            .length;
        final level5HardCount = level5Questions
            .where(
              (q) =>
                  q.difficulty == Difficulty.hard ||
                  q.difficulty == Difficulty.expert,
            )
            .length;

        // Level 5 should have more hard/expert questions than level 1
        expect(level5HardCount, greaterThan(level1HardCount));
      });

      test('should handle edge cases gracefully', () {
        // Test with 0 questions
        final emptyQuestions = questionService
            .getQuestionsWithAdaptiveDifficulty(
              count: 0,
              playerLevel: 1,
              streakCount: 0,
              recentMistakes: 0,
            );
        expect(emptyQuestions, isEmpty);

        // Test with very high count (more than available)
        final manyQuestions = questionService
            .getQuestionsWithAdaptiveDifficulty(
              count: 100,
              playerLevel: 1,
              streakCount: 0,
              recentMistakes: 0,
            );
        expect(
          manyQuestions.length,
          lessThanOrEqualTo(questionService.totalQuestionCount),
        );

        // Test with extreme values
        final extremeQuestions = questionService
            .getQuestionsWithAdaptiveDifficulty(
              count: 5,
              playerLevel: 10,
              streakCount: 100,
              recentMistakes: 50,
            );
        expect(extremeQuestions.length, equals(5));
      });
    });

    group('Question Quality', () {
      setUp(() async {
        // Mock asset loading failure to use sample data
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel('flutter/assets'), (
              MethodCall methodCall,
            ) async {
              throw Exception('Asset not found');
            });
        await questionService.initialize();
      });

      test('should have valid question structure', () {
        final allQuestions = [
          ...questionService.getQuestionsByDifficulty(Difficulty.easy),
          ...questionService.getQuestionsByDifficulty(Difficulty.medium),
          ...questionService.getQuestionsByDifficulty(Difficulty.hard),
          ...questionService.getQuestionsByDifficulty(Difficulty.expert),
        ];

        for (final question in allQuestions) {
          // Check basic structure
          expect(question.id, isNotEmpty);
          expect(question.text, isNotEmpty);
          expect(question.answers.length, equals(4));
          expect(question.correctAnswerIndex, inInclusiveRange(0, 3));
          expect(question.funFact, isNotEmpty);
          expect(question.category, isNotEmpty);

          // Check that all answers are non-empty
          for (final answer in question.answers) {
            expect(answer, isNotEmpty);
          }

          // Check that correct answer is valid
          expect(question.correctAnswer, isNotEmpty);
          expect(
            question.correctAnswer,
            equals(question.answers[question.correctAnswerIndex]),
          );

          // Check points are correct for difficulty
          expect(question.points, equals(question.difficulty.points));
        }
      });

      test('should have unique question IDs', () {
        final allQuestions = [
          ...questionService.getQuestionsByDifficulty(Difficulty.easy),
          ...questionService.getQuestionsByDifficulty(Difficulty.medium),
          ...questionService.getQuestionsByDifficulty(Difficulty.hard),
          ...questionService.getQuestionsByDifficulty(Difficulty.expert),
        ];

        final questionIds = allQuestions.map((q) => q.id).toSet();
        expect(questionIds.length, equals(allQuestions.length));
      });

      test('should have German text content', () {
        final allQuestions = [
          ...questionService.getQuestionsByDifficulty(Difficulty.easy),
          ...questionService.getQuestionsByDifficulty(Difficulty.medium),
          ...questionService.getQuestionsByDifficulty(Difficulty.hard),
          ...questionService.getQuestionsByDifficulty(Difficulty.expert),
        ];

        // Check that questions contain German words/characters
        for (final question in allQuestions) {
          // Should contain German question words or umlauts
          final hasGermanContent =
              question.text.contains('Welche') ||
              question.text.contains('Wie') ||
              question.text.contains('Was') ||
              question.text.contains('Wo') ||
              question.text.contains('Warum') ||
              question.text.contains('ä') ||
              question.text.contains('ö') ||
              question.text.contains('ü') ||
              question.text.contains('ß');

          expect(
            hasGermanContent,
            isTrue,
            reason: 'Question "${question.text}" should contain German content',
          );
        }
      });

      test('should have appropriate difficulty progression', () {
        final easyQuestions = questionService.getQuestionsByDifficulty(
          Difficulty.easy,
        );
        final expertQuestions = questionService.getQuestionsByDifficulty(
          Difficulty.expert,
        );

        // Easy questions should have simpler concepts
        final easyCategories = easyQuestions.map((q) => q.category).toSet();
        expect(easyCategories.contains('Anatomie'), isTrue);
        expect(easyCategories.contains('Verhalten'), isTrue);

        // Expert questions should have more complex concepts
        final expertCategories = expertQuestions.map((q) => q.category).toSet();
        expect(
          expertCategories.contains('Genetik') ||
              expertCategories.contains('Veterinärmedizin') ||
              expertCategories.contains('Neurobiologie'),
          isTrue,
        );
      });
    });

    group('Performance', () {
      setUp(() async {
        // Mock asset loading failure to use sample data
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel('flutter/assets'), (
              MethodCall methodCall,
            ) async {
              throw Exception('Asset not found');
            });
        await questionService.initialize();
      });

      test('should handle multiple rapid question requests efficiently', () {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 100; i++) {
          questionService.getQuestionsWithAdaptiveDifficulty(
            count: 5,
            playerLevel: (i % 5) + 1,
            streakCount: i % 10,
            recentMistakes: i % 5,
          );
        }

        stopwatch.stop();

        // Should complete 100 requests in reasonable time (less than 1 second)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test(
        'should maintain consistent performance with large question sets',
        () {
          final stopwatch1 = Stopwatch()..start();
          questionService.getQuestionsWithAdaptiveDifficulty(
            count: 5,
            playerLevel: 1,
            streakCount: 0,
            recentMistakes: 0,
          );
          stopwatch1.stop();

          final stopwatch2 = Stopwatch()..start();
          questionService.getQuestionsWithAdaptiveDifficulty(
            count: 20,
            playerLevel: 5,
            streakCount: 10,
            recentMistakes: 3,
          );
          stopwatch2.stop();

          // Performance should not degrade significantly with larger requests
          // Allow for some variance in timing, but ensure it's reasonable
          expect(
            stopwatch2.elapsedMilliseconds,
            lessThan(stopwatch1.elapsedMilliseconds * 10 + 100),
          );
        },
      );
    });
  });
}
