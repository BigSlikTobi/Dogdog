import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dogdog_trivia_game/services/progress_service.dart';
import 'package:dogdog_trivia_game/models/player_progress.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('ProgressService', () {
    late ProgressService progressService;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      progressService = ProgressService();
      await progressService.initialize();
    });

    group('Initialization', () {
      test('should initialize with default progress for new user', () async {
        final progress = progressService.currentProgress;

        expect(progress.totalCorrectAnswers, equals(0));
        expect(progress.totalQuestionsAnswered, equals(0));
        expect(progress.totalGamesPlayed, equals(0));
        expect(progress.totalScore, equals(0));
        expect(progress.currentRank, equals(Rank.chihuahua));
        expect(progress.achievements.length, equals(Rank.values.length));
        expect(progress.unlockedContent.isEmpty, isTrue);
        expect(progress.dailyChallengeStreak, equals(0));
        expect(progress.highestLevel, equals(1));
        expect(progress.longestStreak, equals(0));
      });

      test('should load existing progress from SharedPreferences', () async {
        // Setup existing progress
        final existingProgress = PlayerProgress.initial().copyWith(
          totalCorrectAnswers: 15,
          totalScore: 150,
          currentRank: Rank.pug,
        );

        SharedPreferences.setMockInitialValues({
          'player_progress': existingProgress.toJsonString(),
        });

        final newService = ProgressService();
        await newService.initialize();

        expect(newService.currentProgress.totalCorrectAnswers, equals(15));
        expect(newService.currentProgress.totalScore, equals(150));
        expect(newService.currentProgress.currentRank, equals(Rank.pug));
      });

      test('should handle corrupted progress data gracefully', () async {
        SharedPreferences.setMockInitialValues({
          'player_progress': 'invalid_json',
        });

        final newService = ProgressService();
        await newService.initialize();

        // Should fall back to initial progress
        expect(newService.currentProgress.totalCorrectAnswers, equals(0));
        expect(newService.currentProgress.currentRank, equals(Rank.chihuahua));
      });
    });

    group('Recording Correct Answers', () {
      test('should update progress after correct answer', () async {
        final newlyUnlocked = await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );

        final progress = progressService.currentProgress;
        expect(progress.totalCorrectAnswers, equals(1));
        expect(progress.totalQuestionsAnswered, equals(1));
        expect(progress.totalScore, equals(10));
        expect(progress.longestStreak, equals(1));
        expect(newlyUnlocked.isEmpty, isTrue); // No achievements unlocked yet
      });

      test('should unlock Chihuahua rank after 10 correct answers', () async {
        // Record 9 correct answers first
        for (int i = 0; i < 9; i++) {
          await progressService.recordCorrectAnswer(
            pointsEarned: 10,
            currentStreak: i + 1,
          );
        }

        // The 10th correct answer should unlock Chihuahua
        final newlyUnlocked = await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 10,
        );

        expect(newlyUnlocked.length, equals(1));
        expect(newlyUnlocked.first.rank, equals(Rank.chihuahua));
        expect(
          progressService.currentProgress.currentRank,
          equals(Rank.chihuahua),
        );
      });

      test('should unlock Pug rank after 25 correct answers', () async {
        // Record 24 correct answers first
        for (int i = 0; i < 24; i++) {
          await progressService.recordCorrectAnswer(
            pointsEarned: 10,
            currentStreak: 1,
          );
        }

        // The 25th correct answer should unlock Pug
        final newlyUnlocked = await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );

        expect(newlyUnlocked.length, equals(1));
        expect(newlyUnlocked.first.rank, equals(Rank.pug));
        expect(progressService.currentProgress.currentRank, equals(Rank.pug));
      });

      test('should update longest streak correctly', () async {
        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 5,
        );

        expect(progressService.currentProgress.longestStreak, equals(5));

        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 3,
        );

        // Should keep the longest streak
        expect(progressService.currentProgress.longestStreak, equals(5));

        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 8,
        );

        // Should update to new longest streak
        expect(progressService.currentProgress.longestStreak, equals(8));
      });
    });

    group('Recording Incorrect Answers', () {
      test(
        'should update questions answered but not correct answers',
        () async {
          await progressService.recordIncorrectAnswer();

          final progress = progressService.currentProgress;
          expect(progress.totalCorrectAnswers, equals(0));
          expect(progress.totalQuestionsAnswered, equals(1));
          expect(progress.totalScore, equals(0));
        },
      );
    });

    group('Game Completion', () {
      test('should record game completion with level progress', () async {
        await progressService.recordGameCompletion(
          finalScore: 150,
          levelReached: 3,
        );

        final progress = progressService.currentProgress;
        expect(progress.totalGamesPlayed, equals(1));
        expect(progress.highestLevel, equals(3));
      });

      test('should only update highest level if new level is higher', () async {
        await progressService.recordGameCompletion(
          finalScore: 150,
          levelReached: 5,
        );

        expect(progressService.currentProgress.highestLevel, equals(5));

        await progressService.recordGameCompletion(
          finalScore: 100,
          levelReached: 3,
        );

        // Should keep the highest level
        expect(progressService.currentProgress.highestLevel, equals(5));
      });
    });

    group('Daily Challenges', () {
      test('should start daily challenge streak at 1', () async {
        await progressService.recordDailyChallengeCompletion();

        expect(progressService.currentProgress.dailyChallengeStreak, equals(1));
        expect(
          progressService.currentProgress.lastDailyChallengeDate,
          isNotNull,
        );
      });

      test('should increment streak for consecutive days', () async {
        // Set up a specific date for the first challenge
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final progressWithYesterday = progressService.currentProgress.copyWith(
          dailyChallengeStreak: 1,
          lastDailyChallengeDate: yesterday,
        );

        // Manually set the progress to simulate yesterday's challenge
        SharedPreferences.setMockInitialValues({
          'player_progress': progressWithYesterday.toJsonString(),
        });

        final newService = ProgressService();
        await newService.initialize();

        // Record today's challenge (should increment streak)
        await newService.recordDailyChallengeCompletion();

        expect(newService.currentProgress.dailyChallengeStreak, equals(2));
      });
    });

    group('Content Management', () {
      test('should unlock and track content', () async {
        expect(progressService.isContentUnlocked('breed_card_1'), isFalse);

        await progressService.unlockContent('breed_card_1');

        expect(progressService.isContentUnlocked('breed_card_1'), isTrue);
      });

      test('should handle multiple content unlocks', () async {
        await progressService.unlockContent('breed_card_1');
        await progressService.unlockContent('theme_blue');
        await progressService.unlockContent('avatar_puppy');

        expect(progressService.isContentUnlocked('breed_card_1'), isTrue);
        expect(progressService.isContentUnlocked('theme_blue'), isTrue);
        expect(progressService.isContentUnlocked('avatar_puppy'), isTrue);
        expect(progressService.isContentUnlocked('nonexistent'), isFalse);
      });
    });

    group('Achievement Management', () {
      test('should return correct unlocked achievements', () async {
        // Initially no achievements unlocked
        expect(progressService.getUnlockedAchievements().isEmpty, isTrue);

        // Unlock Chihuahua rank
        for (int i = 0; i < 10; i++) {
          await progressService.recordCorrectAnswer(
            pointsEarned: 10,
            currentStreak: 1,
          );
        }

        final unlocked = progressService.getUnlockedAchievements();
        expect(unlocked.length, equals(1));
        expect(unlocked.first.rank, equals(Rank.chihuahua));
      });

      test('should return correct locked achievements', () async {
        final locked = progressService.getLockedAchievements();
        expect(locked.length, equals(Rank.values.length));

        // Unlock one achievement
        for (int i = 0; i < 10; i++) {
          await progressService.recordCorrectAnswer(
            pointsEarned: 10,
            currentStreak: 1,
          );
        }

        final stillLocked = progressService.getLockedAchievements();
        expect(stillLocked.length, equals(Rank.values.length - 1));
      });
    });

    group('Rank Progress', () {
      test('should calculate progress to next rank correctly', () async {
        // At 0 correct answers, progress to Chihuahua (10 required) should be 0
        expect(progressService.getProgressToNextRank(), equals(0.0));

        // At 5 correct answers, progress should be 0.5
        for (int i = 0; i < 5; i++) {
          await progressService.recordCorrectAnswer(
            pointsEarned: 10,
            currentStreak: 1,
          );
        }
        expect(progressService.getProgressToNextRank(), equals(0.5));

        // At 10 correct answers (Chihuahua unlocked), progress to Pug should be 0
        for (int i = 0; i < 5; i++) {
          await progressService.recordCorrectAnswer(
            pointsEarned: 10,
            currentStreak: 1,
          );
        }
        expect(progressService.getProgressToNextRank(), equals(0.0));
      });

      test('should return correct next rank', () async {
        expect(progressService.getNextRank(), equals(Rank.chihuahua));

        // Unlock Chihuahua
        for (int i = 0; i < 10; i++) {
          await progressService.recordCorrectAnswer(
            pointsEarned: 10,
            currentStreak: 1,
          );
        }
        expect(progressService.getNextRank(), equals(Rank.pug));

        // Unlock Pug
        for (int i = 0; i < 15; i++) {
          await progressService.recordCorrectAnswer(
            pointsEarned: 10,
            currentStreak: 1,
          );
        }
        expect(progressService.getNextRank(), equals(Rank.cockerSpaniel));
      });

      test('should return null for next rank when at max rank', () async {
        // Unlock Great Dane (100 correct answers)
        for (int i = 0; i < 100; i++) {
          await progressService.recordCorrectAnswer(
            pointsEarned: 10,
            currentStreak: 1,
          );
        }

        expect(
          progressService.currentProgress.currentRank,
          equals(Rank.greatDane),
        );
        expect(progressService.getNextRank(), isNull);
        expect(progressService.getProgressToNextRank(), equals(1.0));
      });
    });

    group('Data Persistence', () {
      test('should persist progress across service instances', () async {
        // Record some progress
        await progressService.recordCorrectAnswer(
          pointsEarned: 15,
          currentStreak: 1,
        );
        await progressService.recordGameCompletion(
          finalScore: 150,
          levelReached: 2,
        );

        // Create new service instance
        final newService = ProgressService();
        await newService.initialize();

        // Should load the same progress
        expect(newService.currentProgress.totalCorrectAnswers, equals(1));
        expect(newService.currentProgress.totalScore, equals(15));
        expect(newService.currentProgress.totalGamesPlayed, equals(1));
        expect(newService.currentProgress.highestLevel, equals(2));
      });
    });

    group('Progress Reset', () {
      test('should reset all progress to initial state', () async {
        // Record some progress
        for (int i = 0; i < 15; i++) {
          await progressService.recordCorrectAnswer(
            pointsEarned: 10,
            currentStreak: 1,
          );
        }
        await progressService.unlockContent('test_content');

        // Reset progress
        await progressService.resetProgress();

        final progress = progressService.currentProgress;
        expect(progress.totalCorrectAnswers, equals(0));
        expect(progress.totalScore, equals(0));
        expect(progress.currentRank, equals(Rank.chihuahua));
        expect(progress.unlockedContent.isEmpty, isTrue);
        expect(progress.unlockedAchievements.isEmpty, isTrue);
      });
    });

    group('Import/Export', () {
      test('should export progress as JSON string', () async {
        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );

        final exported = progressService.exportProgress();
        expect(exported, isA<String>());
        expect(exported.contains('totalCorrectAnswers'), isTrue);
      });

      test('should import valid progress JSON', () async {
        final testProgress = PlayerProgress.initial().copyWith(
          totalCorrectAnswers: 20,
          totalScore: 200,
        );

        final success = await progressService.importProgress(
          testProgress.toJsonString(),
        );

        expect(success, isTrue);
        expect(progressService.currentProgress.totalCorrectAnswers, equals(20));
        expect(progressService.currentProgress.totalScore, equals(200));
      });

      test('should handle invalid import JSON gracefully', () async {
        final success = await progressService.importProgress('invalid_json');
        expect(success, isFalse);
      });
    });

    group('Statistics', () {
      test('should provide comprehensive statistics', () async {
        // Record some progress
        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 3,
        );
        await progressService.recordIncorrectAnswer();
        await progressService.recordGameCompletion(
          finalScore: 100,
          levelReached: 2,
        );

        final stats = progressService.getStatistics();

        expect(stats['totalCorrectAnswers'], equals(1));
        expect(stats['totalQuestionsAnswered'], equals(2));
        expect(stats['totalGamesPlayed'], equals(1));
        expect(stats['totalScore'], equals(10));
        expect(stats['accuracy'], equals(0.5));
        expect(stats['averageScore'], equals(10.0));
        expect(stats['currentRank'], equals(Rank.chihuahua));
        expect(stats['highestLevel'], equals(2));
        expect(stats['longestStreak'], equals(3));
        expect(stats['unlockedAchievements'], equals(0));
        expect(stats['totalAchievements'], equals(Rank.values.length));
      });
    });

    group('First Launch', () {
      test('should detect first launch correctly', () async {
        final isFirst = await progressService.isFirstLaunch();
        expect(isFirst, isTrue);

        // Second call should return false
        final isSecond = await progressService.isFirstLaunch();
        expect(isSecond, isFalse);
      });
    });
  });
}
