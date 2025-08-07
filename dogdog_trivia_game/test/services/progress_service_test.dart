import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dogdog_trivia_game/services/progress_service.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('ProgressService', () {
    late ProgressService progressService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      progressService = ProgressService();
      await progressService.initialize();
    });

    tearDown(() {
      progressService.dispose();
    });

    test('should initialize with default values', () {
      final progress = progressService.currentProgress;
      expect(progress.totalCorrectAnswers, 0);
      expect(progress.totalQuestionsAnswered, 0);
      expect(progress.totalGamesPlayed, 0);
      expect(progress.totalScore, 0);
      expect(progress.currentRank, Rank.chihuahua);
      expect(progress.longestStreak, 0);
    });

    test('should record correct answer', () async {
      final achievements = await progressService.recordCorrectAnswer(
        pointsEarned: Difficulty.easy.points,
        currentStreak: 1,
      );

      final progress = progressService.currentProgress;
      expect(progress.totalCorrectAnswers, 1);
      expect(progress.totalQuestionsAnswered, 1);
      expect(progress.totalScore, Difficulty.easy.points);
      expect(progress.longestStreak, 1);
      expect(achievements, isA<List>());
    });

    test('should record incorrect answer', () async {
      // First record a correct answer
      await progressService.recordCorrectAnswer(
        pointsEarned: Difficulty.easy.points,
        currentStreak: 1,
      );

      // Then record an incorrect answer
      await progressService.recordIncorrectAnswer();

      final progress = progressService.currentProgress;
      expect(progress.totalCorrectAnswers, 1);
      expect(progress.totalQuestionsAnswered, 2);
      expect(progress.accuracy, 0.5); // 1 correct out of 2 total
    });

    test('should track longest streak', () async {
      await progressService.recordCorrectAnswer(
        pointsEarned: 10,
        currentStreak: 5,
      );

      final progress = progressService.currentProgress;
      expect(progress.longestStreak, 5);

      // Record another with higher streak
      await progressService.recordCorrectAnswer(
        pointsEarned: 10,
        currentStreak: 8,
      );

      final updatedProgress = progressService.currentProgress;
      expect(updatedProgress.longestStreak, 8);
    });

    test('should progress through ranks based on correct answers', () async {
      final initialProgress = progressService.currentProgress;
      expect(initialProgress.currentRank, Rank.chihuahua);

      // Record enough correct answers to reach next rank
      for (int i = 0; i < Rank.pug.requiredCorrectAnswers; i++) {
        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: i + 1,
        );
      }

      final finalProgress = progressService.currentProgress;
      expect(finalProgress.currentRank, Rank.pug);
    });

    test('should calculate accuracy correctly', () {
      final initialProgress = progressService.currentProgress;
      expect(initialProgress.accuracy, 0.0); // No questions answered yet
    });

    test('should record game completion', () async {
      await progressService.recordGameCompletion(
        finalScore: 100,
        levelReached: 5,
      );

      final progress = progressService.currentProgress;
      expect(progress.totalGamesPlayed, 1);
      expect(progress.highestLevel, 5);
    });
  });
}
