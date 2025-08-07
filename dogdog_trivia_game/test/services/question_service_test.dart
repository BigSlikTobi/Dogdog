import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/services/question_service.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('QuestionService', () {
    late QuestionService questionService;

    setUp(() {
      questionService = QuestionService();
      questionService.reset();
    });

    test('should be a singleton', () {
      final instance1 = QuestionService();
      final instance2 = QuestionService();
      expect(identical(instance1, instance2), isTrue);
    });

    test('should initialize with sample data', () async {
      expect(questionService.isInitialized, isFalse);

      await questionService.initialize();

      expect(questionService.isInitialized, isTrue);
      expect(questionService.totalQuestionCount, greaterThan(0));
    });

    test('should provide questions for all difficulty levels', () async {
      await questionService.initialize();

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
    });

    test('should get adaptive questions based on player performance', () async {
      await questionService.initialize();

      final questions = questionService.getQuestionsWithAdaptiveDifficulty(
        count: 5,
        playerLevel: 1,
        streakCount: 0,
        recentMistakes: 0,
      );

      expect(questions.length, 5);
      // For new players (level 1), should get mostly easy questions
      expect(questions.any((q) => q.difficulty == Difficulty.easy), isTrue);
    });

    test('should increase difficulty for high-performing players', () async {
      await questionService.initialize();

      final questions = questionService.getQuestionsWithAdaptiveDifficulty(
        count: 5,
        playerLevel: 5,
        streakCount: 10,
        recentMistakes: 0,
      );

      expect(questions.length, 5);
      // Should contain harder questions for experienced players
      expect(
        questions.any((q) => q.difficulty.index > Difficulty.easy.index),
        isTrue,
      );
    });

    test('should throw error when not initialized', () {
      expect(
        () => questionService.getQuestionsWithAdaptiveDifficulty(
          count: 5,
          playerLevel: 1,
          streakCount: 0,
          recentMistakes: 0,
        ),
        throwsStateError,
      );
    });
  });
}
