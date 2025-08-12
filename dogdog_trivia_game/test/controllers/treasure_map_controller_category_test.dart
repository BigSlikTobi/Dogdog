import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/controllers/treasure_map_controller.dart';
import 'package:dogdog_trivia_game/models/models.dart';

void main() {
  group('TreasureMapController Category Tests', () {
    late TreasureMapController controller;

    setUp(() {
      controller = TreasureMapController();
    });

    tearDown(() {
      controller.dispose();
    });

    group('Category Selection', () {
      test('should initialize with no selected category', () {
        expect(controller.selectedCategory, isNull);
        expect(controller.currentCategoryProgress, isNull);
      });

      test('should select a category and initialize progress', () {
        controller.selectCategory(QuestionCategory.dogTraining);

        expect(
          controller.selectedCategory,
          equals(QuestionCategory.dogTraining),
        );
        expect(controller.currentCategoryProgress, isNotNull);
        expect(
          controller.currentCategoryProgress!.category,
          equals(QuestionCategory.dogTraining),
        );
        expect(
          controller.currentCategoryProgress!.questionsAnswered,
          equals(0),
        );
      });

      test('should provide available categories', () {
        final categories = controller.availableCategories;

        expect(categories, isNotEmpty);
        expect(categories, contains(QuestionCategory.dogTraining));
        expect(categories, contains(QuestionCategory.dogBreeds));
        expect(categories, contains(QuestionCategory.dogBehavior));
        expect(categories, contains(QuestionCategory.dogHealth));
        expect(categories, contains(QuestionCategory.dogHistory));
      });

      test('should update available categories dynamically', () {
        final newCategories = [
          QuestionCategory.dogTraining,
          QuestionCategory.dogBreeds,
        ];

        controller.updateAvailableCategories(newCategories);

        expect(controller.availableCategories.length, equals(2));
        expect(controller.availableCategories, containsAll(newCategories));
      });
    });

    group('Category Progress Tracking', () {
      setUp(() {
        controller.selectCategory(QuestionCategory.dogTraining);
      });

      test('should track question progress for selected category', () {
        controller.incrementQuestionCount(
          isCorrect: true,
          scoreEarned: 10,
          questionId: 'DT_001',
        );

        final progress = controller.currentCategoryProgress!;
        expect(progress.questionsAnswered, equals(1));
        expect(progress.correctAnswers, equals(1));
        expect(progress.totalScore, equals(10));
        expect(progress.usedQuestionIds, contains('DT_001'));
        expect(progress.accuracy, equals(1.0));
      });

      test('should track incorrect answers', () {
        controller.incrementQuestionCount(
          isCorrect: false,
          scoreEarned: 0,
          questionId: 'DT_002',
        );

        final progress = controller.currentCategoryProgress!;
        expect(progress.questionsAnswered, equals(1));
        expect(progress.correctAnswers, equals(0));
        expect(progress.totalScore, equals(0));
        expect(progress.accuracy, equals(0.0));
      });

      test('should calculate accuracy correctly', () {
        // Answer 3 questions: 2 correct, 1 incorrect
        controller.incrementQuestionCount(isCorrect: true, scoreEarned: 10);
        controller.incrementQuestionCount(isCorrect: true, scoreEarned: 10);
        controller.incrementQuestionCount(isCorrect: false, scoreEarned: 0);

        final progress = controller.currentCategoryProgress!;
        expect(progress.questionsAnswered, equals(3));
        expect(progress.correctAnswers, equals(2));
        expect(progress.accuracy, closeTo(0.667, 0.001));
      });

      test('should track used question IDs to avoid repeats', () {
        controller.incrementQuestionCount(questionId: 'DT_001');
        controller.incrementQuestionCount(questionId: 'DT_002');
        controller.incrementQuestionCount(questionId: 'DT_003');

        final usedIds = controller.getUsedQuestionIds();
        expect(usedIds.length, equals(3));
        expect(usedIds, containsAll(['DT_001', 'DT_002', 'DT_003']));
      });
    });

    group('Multiple Category Management', () {
      test('should maintain separate progress for different categories', () {
        // Progress in Dog Training
        controller.selectCategory(QuestionCategory.dogTraining);
        controller.incrementQuestionCount(isCorrect: true, scoreEarned: 10);
        controller.incrementQuestionCount(isCorrect: true, scoreEarned: 10);

        // Switch to Dog Breeds
        controller.selectCategory(QuestionCategory.dogBreeds);
        controller.incrementQuestionCount(isCorrect: false, scoreEarned: 0);

        // Check Dog Training progress is preserved
        final trainingProgress = controller.getCategoryProgress(
          QuestionCategory.dogTraining,
        );
        expect(trainingProgress!.questionsAnswered, equals(2));
        expect(trainingProgress.correctAnswers, equals(2));

        // Check Dog Breeds progress is separate
        final breedsProgress = controller.getCategoryProgress(
          QuestionCategory.dogBreeds,
        );
        expect(breedsProgress!.questionsAnswered, equals(1));
        expect(breedsProgress.correctAnswers, equals(0));
      });

      test('should get all category progress', () {
        controller.selectCategory(QuestionCategory.dogTraining);
        controller.incrementQuestionCount(isCorrect: true);

        controller.selectCategory(QuestionCategory.dogBreeds);
        controller.incrementQuestionCount(isCorrect: true);

        final allProgress = controller.allCategoryProgress;
        expect(allProgress.length, equals(2));
        expect(allProgress.containsKey(QuestionCategory.dogTraining), isTrue);
        expect(allProgress.containsKey(QuestionCategory.dogBreeds), isTrue);
      });

      test('should check if category has progress', () {
        controller.selectCategory(QuestionCategory.dogTraining);
        controller.incrementQuestionCount(isCorrect: true);

        expect(
          controller.hasCategoryProgress(QuestionCategory.dogTraining),
          isTrue,
        );
        expect(
          controller.hasCategoryProgress(QuestionCategory.dogBreeds),
          isFalse,
        );
      });

      test('should get most recent category', () {
        controller.selectCategory(QuestionCategory.dogTraining);
        controller.incrementQuestionCount(isCorrect: true);

        // Small delay to ensure different timestamps
        Future.delayed(Duration(milliseconds: 1), () {
          controller.selectCategory(QuestionCategory.dogBreeds);
          controller.incrementQuestionCount(isCorrect: true);
        });

        final mostRecent = controller.getMostRecentCategory();
        expect(mostRecent, equals(QuestionCategory.dogBreeds));
      });

      test('should sort categories by progress', () {
        // Add different amounts of progress to categories
        controller.selectCategory(QuestionCategory.dogTraining);
        controller.incrementQuestionCount(isCorrect: true);
        controller.incrementQuestionCount(isCorrect: true);
        controller.incrementQuestionCount(isCorrect: true);

        controller.selectCategory(QuestionCategory.dogBreeds);
        controller.incrementQuestionCount(isCorrect: true);

        final sortedCategories = controller.getCategoriesByProgress();

        // Dog Training should be first (3 questions)
        expect(sortedCategories.first, equals(QuestionCategory.dogTraining));
        // Dog Breeds should be second (1 question)
        expect(sortedCategories[1], equals(QuestionCategory.dogBreeds));
        // Categories without progress should be at the end
        expect(sortedCategories.contains(QuestionCategory.dogBehavior), isTrue);
      });
    });

    group('Checkpoint Integration', () {
      setUp(() {
        controller.selectCategory(QuestionCategory.dogTraining);
      });

      test('should complete checkpoints based on question count', () {
        // Answer enough questions to reach first checkpoint (Chihuahua - 10 questions)
        for (int i = 0; i < 10; i++) {
          controller.incrementQuestionCount(isCorrect: true, scoreEarned: 10);
        }

        expect(controller.completedCheckpoints, contains(Checkpoint.chihuahua));
        expect(
          controller.lastCompletedCheckpoint,
          equals(Checkpoint.chihuahua),
        );

        final progress = controller.currentCategoryProgress!;
        expect(progress.completedCheckpoints, contains(Checkpoint.chihuahua));
        expect(progress.lastCompletedCheckpoint, equals(Checkpoint.chihuahua));
      });

      test('should show correct progress to next checkpoint', () {
        // Answer 5 questions (halfway to first checkpoint)
        for (int i = 0; i < 5; i++) {
          controller.incrementQuestionCount(isCorrect: true);
        }

        expect(controller.questionsToNextCheckpoint, equals(5));
        expect(controller.progressToNextCheckpoint, equals(0.5));

        final progress = controller.currentCategoryProgress!;
        expect(progress.questionsToNextCheckpoint, equals(5));
        expect(progress.progressToNextCheckpoint, equals(0.5));
      });

      test('should handle path completion', () {
        // Complete all checkpoints
        for (int i = 0; i < 60; i++) {
          // Enough for all checkpoints
          controller.incrementQuestionCount(isCorrect: true);
        }

        expect(controller.isPathCompleted, isTrue);

        final progress = controller.currentCategoryProgress!;
        expect(progress.isCompleted, isTrue);
        expect(progress.nextCheckpoint, isNull);
      });
    });

    group('Progress Reset', () {
      setUp(() {
        controller.selectCategory(QuestionCategory.dogTraining);
        controller.incrementQuestionCount(isCorrect: true, scoreEarned: 10);
        controller.incrementQuestionCount(isCorrect: true, scoreEarned: 10);
      });

      test('should reset specific category progress', () {
        controller.resetCategoryProgress(QuestionCategory.dogTraining);

        final progress = controller.currentCategoryProgress!;
        expect(progress.questionsAnswered, equals(0));
        expect(progress.correctAnswers, equals(0));
        expect(progress.totalScore, equals(0));
        expect(progress.usedQuestionIds, isEmpty);
      });

      test('should reset all category progress', () {
        controller.selectCategory(QuestionCategory.dogBreeds);
        controller.incrementQuestionCount(isCorrect: true);

        controller.resetAllCategoryProgress();

        expect(controller.selectedCategory, isNull);
        expect(controller.allCategoryProgress, isEmpty);
        expect(controller.currentQuestionCount, equals(0));
      });
    });

    group('Display Methods', () {
      setUp(() {
        controller.selectCategory(QuestionCategory.dogTraining);
      });

      test('should provide current segment display for category', () {
        controller.incrementQuestionCount(isCorrect: true);
        controller.incrementQuestionCount(isCorrect: true);

        final display = controller.currentSegmentDisplay;
        expect(display, contains('2/10'));
        expect(display, contains('Chihuahua'));
      });

      test('should show completion message when category is completed', () {
        // Complete all checkpoints
        for (int i = 0; i < 60; i++) {
          controller.incrementQuestionCount(isCorrect: true);
        }

        final display = controller.currentSegmentDisplay;
        expect(display, equals('Category Completed!'));
      });
    });

    group('Error Handling', () {
      test('should handle operations without selected category gracefully', () {
        // No category selected
        controller.incrementQuestionCount(isCorrect: true, scoreEarned: 10);

        expect(controller.currentCategoryProgress, isNull);
        expect(controller.getUsedQuestionIds(), isEmpty);
      });

      test('should handle invalid category gracefully', () {
        // This shouldn't throw an error
        final progress = controller.getCategoryProgress(
          QuestionCategory.dogHealth,
        );
        expect(progress, isNull);
      });
    });
  });
}
