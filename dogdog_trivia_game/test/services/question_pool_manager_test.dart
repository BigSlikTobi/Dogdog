import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/models/question.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/services/question_pool_manager.dart';
import 'package:dogdog_trivia_game/services/question_service.dart';

void main() {
  group('QuestionPoolManager', () {
    late QuestionPoolManager questionPoolManager;
    late QuestionService questionService;

    setUp(() async {
      questionPoolManager = QuestionPoolManager();
      questionService = QuestionService();
      await questionService.initialize();
    });

    tearDown(() {
      questionService.reset();
    });

    group('getShuffledQuestions', () {
      test('returns requested number of questions when available', () {
        final questions = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: <String>{},
          count: 5,
          difficultyLevel: 1,
        );

        expect(questions.length, equals(5));
      });

      test('excludes questions with provided IDs', () {
        // First, get some questions to exclude
        final initialQuestions = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: <String>{},
          count: 3,
          difficultyLevel: 1,
        );

        final excludeIds = initialQuestions.map((q) => q.id).toSet();

        // Get new questions excluding the initial ones
        final newQuestions = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: excludeIds,
          count: 3,
          difficultyLevel: 1,
        );

        // Verify no overlap
        final newQuestionIds = newQuestions.map((q) => q.id).toSet();
        expect(newQuestionIds.intersection(excludeIds).isEmpty, isTrue);
      });

      test('applies difficulty filtering based on level', () {
        // Level 1 should have mostly easy questions
        final level1Questions = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: <String>{},
          count: 10,
          difficultyLevel: 1,
        );

        final easyCount = level1Questions
            .where((q) => q.difficulty == Difficulty.easy)
            .length;
        final expertCount = level1Questions
            .where((q) => q.difficulty == Difficulty.expert)
            .length;

        // Level 1 should have more easy questions and no expert questions
        expect(easyCount, greaterThanOrEqualTo(expertCount));
        expect(expertCount, equals(0));
      });

      test('handles different path types correctly', () {
        final breedQuestions = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: <String>{},
          count: 5,
          difficultyLevel: 1,
        );

        final behaviorQuestions = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBehavior,
          excludeQuestionIds: <String>{},
          count: 5,
          difficultyLevel: 1,
        );

        // Questions should be different for different paths
        final breedIds = breedQuestions.map((q) => q.id).toSet();
        final behaviorIds = behaviorQuestions.map((q) => q.id).toSet();

        // There might be some overlap, but they shouldn't be identical
        expect(breedIds, isNot(equals(behaviorIds)));
      });

      test('expands pool when not enough questions available', () {
        // Create a large exclude set to force pool expansion
        final allQuestions = <Question>[];
        for (final difficulty in Difficulty.values) {
          allQuestions.addAll(
            questionService.getQuestionsByDifficulty(difficulty),
          );
        }

        final excludeIds = allQuestions
            .take(allQuestions.length - 2) // Leave only 2 questions
            .map((q) => q.id)
            .toSet();

        final questions = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: excludeIds,
          count: 5,
          difficultyLevel: 1,
        );

        // Should still return 5 questions even with limited pool
        expect(questions.length, equals(5));
      });
    });

    group('difficulty progression', () {
      test('getDifficultyLevelForQuestionCount returns correct levels', () {
        expect(
          questionPoolManager.getDifficultyLevelForQuestionCount(5),
          equals(1),
        );
        expect(
          questionPoolManager.getDifficultyLevelForQuestionCount(15),
          equals(2),
        );
        expect(
          questionPoolManager.getDifficultyLevelForQuestionCount(25),
          equals(3),
        );
        expect(
          questionPoolManager.getDifficultyLevelForQuestionCount(35),
          equals(4),
        );
        expect(
          questionPoolManager.getDifficultyLevelForQuestionCount(45),
          equals(5),
        );
      });

      test('higher levels include more difficult questions', () {
        final level1Questions = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: <String>{},
          count: 20,
          difficultyLevel: 1,
        );

        final level5Questions = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: <String>{},
          count: 20,
          difficultyLevel: 5,
        );

        final level1EasyCount = level1Questions
            .where((q) => q.difficulty == Difficulty.easy)
            .length;
        final level5EasyCount = level5Questions
            .where((q) => q.difficulty == Difficulty.easy)
            .length;

        // Level 1 should have more easy questions than level 5
        expect(level1EasyCount, greaterThanOrEqualTo(level5EasyCount));

        // Verify that level 5 has some harder questions
        final level5HardCount = level5Questions
            .where(
              (q) =>
                  q.difficulty == Difficulty.hard ||
                  q.difficulty == Difficulty.expert,
            )
            .length;
        expect(level5HardCount, greaterThan(0));
      });
    });

    group('question availability', () {
      test('getAvailableQuestionCount returns correct count', () {
        final totalCount = questionPoolManager.getAvailableQuestionCount(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: <String>{},
        );

        expect(totalCount, greaterThan(0));

        // Exclude some questions and verify count decreases
        final someQuestions = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: <String>{},
          count: 3,
          difficultyLevel: 1,
        );

        final excludeIds = someQuestions.map((q) => q.id).toSet();
        final reducedCount = questionPoolManager.getAvailableQuestionCount(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: excludeIds,
        );

        expect(reducedCount, equals(totalCount - 3));
      });

      test('hasEnoughQuestions returns correct boolean', () {
        expect(
          questionPoolManager.hasEnoughQuestions(
            pathType: PathType.dogBreeds,
            excludeQuestionIds: <String>{},
            requiredCount: 5,
          ),
          isTrue,
        );

        // Create scenario with insufficient questions
        final allQuestions = <Question>[];
        for (final difficulty in Difficulty.values) {
          allQuestions.addAll(
            questionService.getQuestionsByDifficulty(difficulty),
          );
        }

        final excludeIds = allQuestions
            .take(allQuestions.length - 2) // Leave only 2 questions
            .map((q) => q.id)
            .toSet();

        expect(
          questionPoolManager.hasEnoughQuestions(
            pathType: PathType.dogBreeds,
            excludeQuestionIds: excludeIds,
            requiredCount: 10,
          ),
          isFalse,
        );
      });
    });

    group('checkpoint restart functionality', () {
      test('getQuestionsForCheckpointRestart provides fresh questions', () {
        final initialQuestions = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: <String>{},
          count: 5,
          difficultyLevel: 2,
        );

        final excludeIds = initialQuestions.map((q) => q.id).toSet();

        final restartQuestions = questionPoolManager
            .getQuestionsForCheckpointRestart(
              pathType: PathType.dogBreeds,
              excludeQuestionIds: excludeIds,
              count: 5,
              checkpointLevel: 2,
            );

        expect(restartQuestions.length, equals(5));

        // Verify no overlap with excluded questions
        final restartIds = restartQuestions.map((q) => q.id).toSet();
        expect(restartIds.intersection(excludeIds).isEmpty, isTrue);
      });

      test('checkpoint restart maintains difficulty level', () {
        final restartQuestions = questionPoolManager
            .getQuestionsForCheckpointRestart(
              pathType: PathType.dogBreeds,
              excludeQuestionIds: <String>{},
              count: 10,
              checkpointLevel: 1, // Should be mostly easy
            );

        final easyCount = restartQuestions
            .where((q) => q.difficulty == Difficulty.easy)
            .length;
        final expertCount = restartQuestions
            .where((q) => q.difficulty == Difficulty.expert)
            .length;

        // Level 1 checkpoint should have more easy questions or equal
        expect(easyCount, greaterThanOrEqualTo(expertCount));
        // And should have no expert questions at level 1
        expect(expertCount, equals(0));
      });
    });

    group('path-specific question filtering', () {
      test('dog breeds path returns breed-related questions', () {
        final breedQuestions = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: <String>{},
          count: 10,
          difficultyLevel: 1,
        );

        // Check if questions are breed-related
        final breedRelatedCount = breedQuestions.where((q) {
          final text = q.text.toLowerCase();
          final category = q.category.toLowerCase();
          return text.contains('rasse') ||
              text.contains('breed') ||
              category.contains('hunderassen') ||
              category.contains('breed');
        }).length;

        // At least some questions should be breed-related
        expect(breedRelatedCount, greaterThan(0));
      });

      test('different paths return different question sets', () {
        final breedQuestions = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: <String>{},
          count: 5,
          difficultyLevel: 1,
        );

        final healthQuestions = questionPoolManager.getShuffledQuestions(
          pathType: PathType.healthCare,
          excludeQuestionIds: <String>{},
          count: 5,
          difficultyLevel: 1,
        );

        final breedIds = breedQuestions.map((q) => q.id).toSet();
        final healthIds = healthQuestions.map((q) => q.id).toSet();

        // Different paths should generally return different questions
        // (though some overlap is possible with limited question pool)
        expect(breedIds, isNot(equals(healthIds)));
      });
    });

    group('shuffling and randomization', () {
      test('questions are shuffled between calls', () {
        final questions1 = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: <String>{},
          count: 10,
          difficultyLevel: 1,
        );

        final questions2 = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: <String>{},
          count: 10,
          difficultyLevel: 1,
        );

        final ids1 = questions1.map((q) => q.id).toList();
        final ids2 = questions2.map((q) => q.id).toList();

        // Order should be different (with high probability)
        // Note: There's a small chance they could be the same due to randomness
        expect(ids1, isNot(equals(ids2)));
      });

      test('maintains variety in question selection', () {
        final questions = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: <String>{},
          count: 20,
          difficultyLevel: 3,
        );

        // Check for variety in difficulties
        final difficulties = questions.map((q) => q.difficulty).toSet();
        expect(difficulties.length, greaterThan(1));

        // Check for variety in categories
        final categories = questions.map((q) => q.category).toSet();
        expect(categories.length, greaterThanOrEqualTo(1));
      });
    });

    group('edge cases', () {
      test('handles empty exclude set', () {
        final questions = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: <String>{},
          count: 5,
          difficultyLevel: 1,
        );

        expect(questions.length, equals(5));
      });

      test('handles zero count request', () {
        final questions = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: <String>{},
          count: 0,
          difficultyLevel: 1,
        );

        expect(questions.isEmpty, isTrue);
      });

      test('handles invalid difficulty level gracefully', () {
        final questions = questionPoolManager.getShuffledQuestions(
          pathType: PathType.dogBreeds,
          excludeQuestionIds: <String>{},
          count: 5,
          difficultyLevel: 999, // Invalid level
        );

        expect(questions.length, equals(5));
        // Should default to highest level behavior
      });
    });

    group('resetQuestionPool', () {
      test('resetQuestionPool executes without error', () {
        expect(
          () => questionPoolManager.resetQuestionPool(
            pathType: PathType.dogBreeds,
            preserveAnsweredIds: <String>{'test_id'},
          ),
          returnsNormally,
        );
      });
    });
  });
}
