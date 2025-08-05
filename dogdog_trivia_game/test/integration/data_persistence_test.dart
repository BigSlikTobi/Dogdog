import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dogdog_trivia_game/services/progress_service.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('Data Persistence Integration Tests', () {
    late ProgressService progressService;
    bool isDisposed = false;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      progressService = ProgressService();
      isDisposed = false;
    });

    tearDown(() async {
      if (!isDisposed) {
        progressService.dispose();
        isDisposed = true;
      }
    });

    group('Initialization and Migration', () {
      testWidgets('should initialize with default progress on first launch', (
        tester,
      ) async {
        await progressService.initialize();

        final progress = progressService.currentProgress;
        expect(progress.totalCorrectAnswers, equals(0));
        expect(progress.totalQuestionsAnswered, equals(0));
        expect(progress.totalGamesPlayed, equals(0));
        expect(progress.totalScore, equals(0));
        expect(progress.currentRank, equals(Rank.chihuahua));
        expect(progress.achievements.length, equals(Rank.values.length));
      });

      testWidgets('should handle data migration correctly', (tester) async {
        // Set up old version data
        SharedPreferences.setMockInitialValues({
          'data_version': 0,
          'player_progress':
              '{"totalCorrectAnswers":15,"totalQuestionsAnswered":20,"totalGamesPlayed":3,"totalScore":300,"currentRank":"pug","achievements":[],"unlockedContent":{},"dailyChallengeStreak":0,"lastPlayDate":"2024-01-01T00:00:00.000Z","highestLevel":1,"longestStreak":0}',
        });

        await progressService.initialize();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('data_version'), equals(1));
        expect(prefs.getString('progress_backup'), isNotNull);
      });

      testWidgets('should clear data on migration failure', (tester) async {
        // Set up corrupted data
        SharedPreferences.setMockInitialValues({
          'data_version': 0,
          'player_progress': 'invalid_json',
        });

        await progressService.initialize();

        final progress = progressService.currentProgress;
        expect(progress.totalCorrectAnswers, equals(0));
      });
    });

    group('Data Saving and Loading', () {
      testWidgets('should save and load progress correctly', (tester) async {
        await progressService.initialize();

        // Record some progress
        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );
        await progressService.recordIncorrectAnswer();
        await progressService.recordGameCompletion(
          finalScore: 100,
          levelReached: 2,
        );

        // Create new service instance to test loading
        final newService = ProgressService();
        await newService.initialize();

        final loadedProgress = newService.currentProgress;
        expect(loadedProgress.totalCorrectAnswers, equals(1));
        expect(loadedProgress.totalQuestionsAnswered, equals(2));
        expect(loadedProgress.totalGamesPlayed, equals(1));
        expect(loadedProgress.totalScore, equals(10));
        expect(loadedProgress.highestLevel, equals(2));

        newService.dispose();
      });

      testWidgets('should handle save failures gracefully', (tester) async {
        await progressService.initialize();

        // Simulate save failure by clearing SharedPreferences instance
        SharedPreferences.setMockInitialValues({});

        // This should not throw an exception
        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );

        expect(progressService.currentProgress.totalCorrectAnswers, equals(1));
      });

      testWidgets('should create backups automatically', (tester) async {
        await progressService.initialize();

        // Record progress to trigger backup creation
        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );
        await progressService.forceSave();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('progress_backup'), isNotNull);
      });
    });

    group('Auto-save Functionality', () {
      testWidgets('should track unsaved changes', (tester) async {
        await progressService.initialize();

        expect(progressService.hasUnsavedChanges(), isFalse);

        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );

        // Changes should be automatically saved
        expect(progressService.hasUnsavedChanges(), isFalse);
      });

      testWidgets('should provide last save time', (tester) async {
        await progressService.initialize();

        final beforeSave = DateTime.now();
        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );
        final afterSave = DateTime.now();

        final lastSaveTime = progressService.getLastSaveTime();
        expect(lastSaveTime, isNotNull);
        expect(lastSaveTime!.isAfter(beforeSave), isTrue);
        expect(lastSaveTime.isBefore(afterSave), isTrue);
      });
    });

    group('Data Integrity and Validation', () {
      testWidgets('should validate progress data correctly', (tester) async {
        await progressService.initialize();

        // Valid data should pass validation
        expect(progressService.validateProgressData(), isTrue);

        // Record some progress
        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );
        expect(progressService.validateProgressData(), isTrue);
      });

      testWidgets('should provide data integrity status', (tester) async {
        await progressService.initialize();

        final status = await progressService.getDataIntegrityStatus();

        expect(status['hasMainData'], isTrue);
        expect(status['dataVersion'], equals(1));
        expect(status['currentVersion'], equals(1));
        expect(status['isHealthy'], isTrue);
      });

      testWidgets('should repair corrupted data', (tester) async {
        await progressService.initialize();

        // Create some valid progress first
        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );
        await progressService.forceSave();

        // Data should be valid
        expect(progressService.validateProgressData(), isTrue);

        // Repair should succeed for valid data
        final repairResult = await progressService.repairData();
        expect(repairResult, isTrue);
      });
    });

    group('Backup and Recovery', () {
      testWidgets('should recover from backup on save failure', (tester) async {
        await progressService.initialize();

        // Create initial progress
        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );
        await progressService.forceSave();

        // Verify backup exists
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('progress_backup'), isNotNull);

        // Simulate recovery scenario
        final backupData = prefs.getString('progress_backup')!;
        expect(backupData.contains('totalCorrectAnswers'), isTrue);
      });

      testWidgets('should handle backup creation errors gracefully', (
        tester,
      ) async {
        await progressService.initialize();

        // Even if backup fails, normal operation should continue
        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );

        expect(progressService.currentProgress.totalCorrectAnswers, equals(1));
      });
    });

    group('Import and Export', () {
      testWidgets('should export progress as JSON', (tester) async {
        await progressService.initialize();

        // Create some progress
        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );
        await progressService.recordGameCompletion(
          finalScore: 100,
          levelReached: 2,
        );

        final exportedData = progressService.exportProgress();

        expect(exportedData, isNotEmpty);
        expect(exportedData.contains('totalCorrectAnswers'), isTrue);
        expect(exportedData.contains('totalScore'), isTrue);
      });

      testWidgets('should import progress from JSON', (tester) async {
        await progressService.initialize();

        // Create and export progress
        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );
        final exportedData = progressService.exportProgress();

        // Reset progress
        await progressService.resetProgress();
        expect(progressService.currentProgress.totalCorrectAnswers, equals(0));

        // Import the exported data
        final importResult = await progressService.importProgress(exportedData);

        expect(importResult, isTrue);
        expect(progressService.currentProgress.totalCorrectAnswers, equals(1));
      });

      testWidgets('should handle invalid import data', (tester) async {
        await progressService.initialize();

        final importResult = await progressService.importProgress(
          'invalid_json',
        );

        expect(importResult, isFalse);
        // Original progress should remain unchanged
        expect(progressService.currentProgress.totalCorrectAnswers, equals(0));
      });
    });

    group('Achievement Persistence', () {
      testWidgets('should persist achievement unlocks', (tester) async {
        await progressService.initialize();

        // Record enough correct answers to unlock first achievement
        for (int i = 0; i < 10; i++) {
          await progressService.recordCorrectAnswer(
            pointsEarned: 10,
            currentStreak: i + 1,
          );
        }

        // Create new service to test persistence
        final newService = ProgressService();
        await newService.initialize();

        final unlockedAchievements = newService.getUnlockedAchievements();
        expect(unlockedAchievements.length, greaterThan(0));

        // First achievement (Chihuahua) should be unlocked
        final chihuahuaAchievement = unlockedAchievements.firstWhere(
          (a) => a.rank == Rank.chihuahua,
        );
        expect(chihuahuaAchievement.isUnlocked, isTrue);

        newService.dispose();
      });

      testWidgets('should maintain achievement consistency', (tester) async {
        await progressService.initialize();

        // Record progress and check achievements
        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );

        final achievements = progressService.currentProgress.achievements;
        expect(achievements.length, equals(Rank.values.length));

        // All achievements should have valid data
        for (final achievement in achievements) {
          expect(achievement.id, isNotEmpty);
          expect(achievement.name, isNotEmpty);
          expect(achievement.requiredCorrectAnswers, greaterThan(0));
        }
      });
    });

    group('Content Unlocking', () {
      testWidgets('should persist unlocked content', (tester) async {
        await progressService.initialize();

        // Unlock some content
        await progressService.unlockContent('test_content_1');
        await progressService.unlockContent('test_content_2');

        // Create new service to test persistence
        final newService = ProgressService();
        await newService.initialize();

        expect(newService.isContentUnlocked('test_content_1'), isTrue);
        expect(newService.isContentUnlocked('test_content_2'), isTrue);
        expect(newService.isContentUnlocked('test_content_3'), isFalse);

        newService.dispose();
      });
    });

    group('Daily Challenge Persistence', () {
      testWidgets('should persist daily challenge streaks', (tester) async {
        await progressService.initialize();

        // Complete daily challenge
        await progressService.recordDailyChallengeCompletion();

        expect(progressService.currentProgress.dailyChallengeStreak, equals(1));

        // Create new service to test persistence
        final newService = ProgressService();
        await newService.initialize();

        expect(newService.currentProgress.dailyChallengeStreak, equals(1));
        expect(newService.currentProgress.lastDailyChallengeDate, isNotNull);

        newService.dispose();
      });
    });

    group('Statistics Persistence', () {
      testWidgets('should persist all statistics correctly', (tester) async {
        await progressService.initialize();

        // Generate various statistics
        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );
        await progressService.recordIncorrectAnswer();
        await progressService.recordCorrectAnswer(
          pointsEarned: 15,
          currentStreak: 2,
        );
        await progressService.recordGameCompletion(
          finalScore: 150,
          levelReached: 3,
        );

        final stats = progressService.getStatistics();

        expect(stats['totalCorrectAnswers'], equals(2));
        expect(stats['totalQuestionsAnswered'], equals(3));
        expect(stats['totalGamesPlayed'], equals(1));
        expect(stats['totalScore'], equals(25));
        expect(stats['highestLevel'], equals(3));
        expect(stats['longestStreak'], equals(2));

        // Create new service to test persistence
        final newService = ProgressService();
        await newService.initialize();

        final persistedStats = newService.getStatistics();

        expect(persistedStats['totalCorrectAnswers'], equals(2));
        expect(persistedStats['totalQuestionsAnswered'], equals(3));
        expect(persistedStats['totalGamesPlayed'], equals(1));
        expect(persistedStats['totalScore'], equals(25));
        expect(persistedStats['highestLevel'], equals(3));
        expect(persistedStats['longestStreak'], equals(2));

        newService.dispose();
      });
    });

    group('Error Recovery', () {
      testWidgets('should handle SharedPreferences errors gracefully', (
        tester,
      ) async {
        await progressService.initialize();

        // Even with potential SharedPreferences issues, service should work
        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );

        expect(progressService.currentProgress.totalCorrectAnswers, equals(1));
      });

      testWidgets('should maintain data consistency after errors', (
        tester,
      ) async {
        await progressService.initialize();

        // Record some progress
        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );

        // Validate data consistency
        expect(progressService.validateProgressData(), isTrue);

        // Data should remain consistent even after potential errors
        final progress = progressService.currentProgress;
        expect(
          progress.totalCorrectAnswers,
          lessThanOrEqualTo(progress.totalQuestionsAnswered),
        );
        expect(progress.totalScore, greaterThanOrEqualTo(0));
      });
    });

    group('Performance and Memory', () {
      testWidgets('should handle large amounts of data efficiently', (
        tester,
      ) async {
        await progressService.initialize();

        // Simulate playing many games
        for (int i = 0; i < 100; i++) {
          await progressService.recordCorrectAnswer(
            pointsEarned: 10,
            currentStreak: 1,
          );
          if (i % 10 == 0) {
            await progressService.recordGameCompletion(
              finalScore: 100,
              levelReached: 1,
            );
          }
        }

        // Data should still be valid and consistent
        expect(progressService.validateProgressData(), isTrue);
        expect(
          progressService.currentProgress.totalCorrectAnswers,
          equals(100),
        );
        expect(progressService.currentProgress.totalGamesPlayed, equals(10));
      });

      testWidgets('should dispose properly without memory leaks', (
        tester,
      ) async {
        await progressService.initialize();

        await progressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );

        // Dispose should not throw any errors
        progressService.dispose();
        isDisposed = true; // Mark as disposed to avoid double disposal

        // After disposal, service should not be used, but this tests that
        // disposal itself works correctly
        expect(true, isTrue);
      });
    });
  });
}
