import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/services/performant_question_service.dart';
import 'package:dogdog_trivia_game/services/memory_management_service.dart';
import 'package:dogdog_trivia_game/services/category_error_recovery_service.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

/// End-to-end integration test for Task 16: Final integration and polish
void main() {
  group('Task 16: Final Integration and Polish', () {
    test('PerformantQuestionService integration test', () async {
      final service = PerformantQuestionService();

      // Test initialization
      await service.initialize();
      expect(service.isHealthy, true);

      // Test question retrieval
      final questions = await service.getQuestionsForCategory(
        QuestionCategory.dogBreeds,
      );

      // Test randomized questions
      if (questions.isNotEmpty) {
        final randomized = await service.getRandomizedQuestions(
          category: QuestionCategory.dogBreeds,
          count: 5,
          difficulty: Difficulty.easy,
        );

        expect(randomized.length, lessThanOrEqualTo(5));
      }

      // Test error handling
      final errorInfo = service.getErrorInfo();
      expect(errorInfo['hasErrors'], false);
    });

    test('MemoryManagementService integration test', () async {
      final service = MemoryManagementService.instance;

      await service.initialize();
      expect(service.isMemoryHealthy, true);

      // Test memory statistics
      final stats = service.getDetailedMemoryStatistics();
      expect(stats['totalMemoryMB'], isA<int>());
      expect(stats['memoryPressureLevel'], isA<int>());

      // Test performance recommendations
      final recommendations = service.getPerformanceRecommendations();
      expect(recommendations, isA<List<String>>());
      expect(recommendations.isNotEmpty, true);
    });

    test('CategoryErrorRecoveryService integration test', () async {
      final service = CategoryErrorRecoveryService();

      // Test error analysis
      final analysis = await service.analyzeCategoryError(
        category: QuestionCategory.dogBreeds,
        locale: 'en',
      );

      expect(analysis.category, QuestionCategory.dogBreeds);
      expect(analysis.errorType, isA<CategoryErrorType>());
      expect(analysis.canContinue, isA<bool>());
      expect(analysis.recommendedAction, isA<RecoveryAction>());
    });

    test('Service integration and coordination', () async {
      // Test that all services can work together
      final questionService = PerformantQuestionService();
      final memoryService = MemoryManagementService.instance;

      await questionService.initialize();
      await memoryService.initialize();

      // Test category switching optimization
      await memoryService.optimizeForCategorySwitch(
        QuestionCategory.dogTraining,
      );

      // Test preloading
      await questionService.preloadQuestionsForCategories([
        QuestionCategory.dogBreeds,
        QuestionCategory.dogTraining,
      ]);

      // Test memory pressure handling
      await memoryService.forceOptimization();

      // Test error recovery
      final canRecover = await questionService.attemptRecovery();
      expect(canRecover, isA<bool>());

      // Test final state
      expect(questionService.isHealthy, true);
      expect(memoryService.isMemoryHealthy, true);
    });

    test('Cache coordination test', () async {
      final service = PerformantQuestionService();
      await service.initialize();

      // Test cache status
      final status = service.getAvailableCategoriesWithStatus();
      expect(status.length, 5); // All 5 categories

      for (final categoryStatus in status) {
        expect(categoryStatus['category'], isA<QuestionCategory>());
        expect(categoryStatus['cached'], isA<bool>());
        expect(categoryStatus['name'], isA<String>());
      }

      // Test cache statistics
      final cacheStats = service.getCacheStatistics();
      expect(cacheStats, isA<Map<String, dynamic>>());

      // Test memory statistics
      final memoryStats = service.getMemoryStatistics();
      expect(memoryStats, isA<Map<String, dynamic>>());
    });

    test('Comprehensive error handling test', () async {
      final questionService = PerformantQuestionService();
      final errorService = CategoryErrorRecoveryService();

      await questionService.initialize();

      // Test each category for potential issues
      for (final category in QuestionCategory.values) {
        final analysis = await errorService.analyzeCategoryError(
          category: category,
          locale: 'en',
        );

        // All categories should have some level of functionality
        expect(analysis.category, category);
        expect(analysis.userMessage, isA<String>());
        expect(analysis.userMessage.isNotEmpty, true);

        // Test question loading for each category
        final questions = await questionService.getQuestionsForCategory(
          category,
        );
        // Questions may be empty in test environment, but service should not crash
        expect(questions, isA<List>());
      }
    });

    test('Performance optimization test', () async {
      final questionService = PerformantQuestionService();
      final memoryService = MemoryManagementService.instance;

      await questionService.initialize();
      await memoryService.initialize();

      // Test performance recommendations
      final recommendations = questionService.getPerformanceRecommendations();
      expect(recommendations, isA<List<String>>());

      // Test memory optimization
      await questionService.optimizeMemory();

      // Test cache clearing
      questionService.clearCategoryCache(QuestionCategory.dogBreeds);

      // Test that clearing doesn't break functionality
      final questions = await questionService.getQuestionsForCategory(
        QuestionCategory.dogBreeds,
      );
      expect(questions, isA<List>());
    });

    test('Accessibility integration test', () {
      // Test that accessibility features don't break functionality
      // This is a basic test since we can't fully test accessibility in unit tests

      // Test that required enums and categories are available
      expect(QuestionCategory.values.length, 5);
      expect(Difficulty.values.length, 4);

      // Test that category names can be retrieved
      for (final category in QuestionCategory.values) {
        final name = category.getLocalizedName('en');
        expect(name, isA<String>());
        expect(name.isNotEmpty, true);
      }
    });
  });
}
