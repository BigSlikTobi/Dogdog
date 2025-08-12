import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dogdog_trivia_game/services/game_persistence_service.dart';
import 'package:dogdog_trivia_game/models/path_progress.dart';
import 'package:dogdog_trivia_game/models/game_session.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('GamePersistenceService Tests', () {
    late GamePersistenceService service;
    late DateTime testDate;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = GamePersistenceService();
      testDate = DateTime(2025, 8, 12);
    });

    tearDown(() async {
      // Clean up any stored data
      await service.clearAllData();
    });

    group('Path Progress Persistence', () {
      test('should save and load path progress correctly', () async {
        await service.initialize();

        final progress = PathProgress(
          pathType: PathType.dogBreeds,
          currentCheckpoint: Checkpoint.pug,
          answeredQuestionIds: ['q1', 'q2', 'q3'],
          powerUpInventory: {PowerUpType.fiftyFifty: 2, PowerUpType.hint: 1},
          correctAnswers: 8,
          totalQuestions: 10,
          bestAccuracy: 0.8,
          totalTimeSpent: 300,
          fallbackCount: 1,
          lastPlayed: testDate,
          isCompleted: false,
        );

        await service.savePathProgress(progress);
        final loadedProgress = await service.loadPathProgress(
          PathType.dogBreeds,
        );

        expect(loadedProgress, isNotNull);
        expect(loadedProgress!.pathType, PathType.dogBreeds);
        expect(loadedProgress.currentCheckpoint, Checkpoint.pug);
        expect(loadedProgress.answeredQuestionIds, ['q1', 'q2', 'q3']);
        expect(loadedProgress.powerUpInventory[PowerUpType.fiftyFifty], 2);
        expect(loadedProgress.powerUpInventory[PowerUpType.hint], 1);
        expect(loadedProgress.correctAnswers, 8);
        expect(loadedProgress.totalQuestions, 10);
        expect(loadedProgress.bestAccuracy, 0.8);
        expect(loadedProgress.totalTimeSpent, 300);
        expect(loadedProgress.fallbackCount, 1);
        expect(loadedProgress.isCompleted, false);
      });

      test('should return null for non-existent path progress', () async {
        await service.initialize();
        final progress = await service.loadPathProgress(PathType.dogBreeds);
        expect(progress, isNull);
      });

      test('should load all path progress correctly', () async {
        await service.initialize();

        final progress1 = PathProgress(
          pathType: PathType.dogBreeds,
          currentCheckpoint: Checkpoint.pug,
          lastPlayed: testDate,
        );

        final progress2 = PathProgress(
          pathType: PathType.dogTraining,
          currentCheckpoint: Checkpoint.cockerSpaniel,
          lastPlayed: testDate,
        );

        await service.savePathProgress(progress1);
        await service.savePathProgress(progress2);

        final allProgress = await service.loadAllPathProgress();

        expect(allProgress.length, 2);
        expect(allProgress[PathType.dogBreeds], isNotNull);
        expect(allProgress[PathType.dogTraining], isNotNull);
        expect(
          allProgress[PathType.dogBreeds]!.currentCheckpoint,
          Checkpoint.pug,
        );
        expect(
          allProgress[PathType.dogTraining]!.currentCheckpoint,
          Checkpoint.cockerSpaniel,
        );
      });

      test('should handle corrupted path progress data gracefully', () async {
        await service.initialize();

        // Manually add corrupted data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'path_progress_PathType.dogBreeds',
          'invalid json data',
        );

        final progress = await service.loadPathProgress(PathType.dogBreeds);
        expect(progress, isNull);
      });
    });

    group('Game Session Persistence', () {
      test('should save and load game session correctly', () async {
        await service.initialize();

        final session = GameSession(
          currentPath: PathType.dogBreeds,
          livesRemaining: 2,
          currentQuestionId: 'q123',
          sessionQuestionIds: ['q1', 'q2', 'q3'],
          powerUpsUsed: {PowerUpType.fiftyFifty: 1, PowerUpType.hint: 2},
          sessionStart: testDate,
          currentStreak: 5,
          bestStreak: 8,
          isPaused: false,
          sessionTimeSpent: 120,
        );

        await service.saveGameSession(session);
        final loadedSession = await service.loadGameSession();

        expect(loadedSession, isNotNull);
        expect(loadedSession!.currentPath, PathType.dogBreeds);
        expect(loadedSession.livesRemaining, 2);
        expect(loadedSession.currentQuestionId, 'q123');
        expect(loadedSession.sessionQuestionIds, ['q1', 'q2', 'q3']);
        expect(loadedSession.powerUpsUsed[PowerUpType.fiftyFifty], 1);
        expect(loadedSession.powerUpsUsed[PowerUpType.hint], 2);
        expect(loadedSession.currentStreak, 5);
        expect(loadedSession.bestStreak, 8);
        expect(loadedSession.isPaused, false);
        expect(loadedSession.sessionTimeSpent, 120);
      });

      test('should return null for non-existent game session', () async {
        await service.initialize();
        final session = await service.loadGameSession();
        expect(session, isNull);
      });

      test('should clear game session correctly', () async {
        await service.initialize();

        final session = GameSession(
          currentPath: PathType.dogBreeds,
          sessionStart: testDate,
        );

        await service.saveGameSession(session);
        expect(await service.loadGameSession(), isNotNull);

        await service.clearGameSession();
        expect(await service.loadGameSession(), isNull);
      });

      test('should handle corrupted game session data gracefully', () async {
        await service.initialize();

        // Manually add corrupted data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_session', 'invalid json data');

        final session = await service.loadGameSession();
        expect(session, isNull);
      });
    });

    group('Global Statistics', () {
      test('should save and load global statistics correctly', () async {
        await service.initialize();

        final stats = {
          'totalGamesPlayed': 50,
          'totalQuestionsAnswered': 1200,
          'totalCorrectAnswers': 960,
          'averageAccuracy': 0.8,
          'totalTimeSpent': 7200,
          'favoriteCategory': 'PathType.dogBreeds',
          'achievementsUnlocked': ['first_win', 'speed_demon', 'perfect_round'],
        };

        await service.saveGlobalStats(stats);
        final loadedStats = await service.loadGlobalStats();

        expect(loadedStats['totalGamesPlayed'], 50);
        expect(loadedStats['totalQuestionsAnswered'], 1200);
        expect(loadedStats['totalCorrectAnswers'], 960);
        expect(loadedStats['averageAccuracy'], 0.8);
        expect(loadedStats['totalTimeSpent'], 7200);
        expect(loadedStats['favoriteCategory'], 'PathType.dogBreeds');
        expect(loadedStats['achievementsUnlocked'], [
          'first_win',
          'speed_demon',
          'perfect_round',
        ]);
      });

      test(
        'should return default values for non-existent global statistics',
        () async {
          await service.initialize();
          final stats = await service.loadGlobalStats();
          expect(stats, isNotEmpty);
          expect(stats['totalQuestionsAnswered'], 0);
          expect(stats['totalCorrectAnswers'], 0);
        },
      );
    });

    group('Game Settings', () {
      test('should save and load game settings correctly', () async {
        await service.initialize();

        final settings = {
          'soundEnabled': true,
          'musicEnabled': false,
          'hapticFeedbackEnabled': true,
          'difficulty': 'medium',
          'theme': 'dark',
          'language': 'en',
          'tutorialCompleted': true,
        };

        await service.saveGameSettings(settings);
        final loadedSettings = await service.loadGameSettings();

        expect(loadedSettings['soundEnabled'], true);
        expect(loadedSettings['musicEnabled'], false);
        expect(loadedSettings['hapticFeedbackEnabled'], true);
        expect(loadedSettings['difficulty'], 'medium');
        expect(loadedSettings['theme'], 'dark');
        expect(loadedSettings['language'], 'en');
        expect(loadedSettings['tutorialCompleted'], true);
      });

      test(
        'should return default values for non-existent game settings',
        () async {
          await service.initialize();
          final settings = await service.loadGameSettings();
          expect(settings, isNotEmpty);
          expect(settings['soundEnabled'], true);
          expect(settings['musicEnabled'], true);
        },
      );
    });

    group('Data Migration', () {
      test('should migrate old save data correctly', () async {
        await service.initialize();

        // Simulate calling migration
        await service.migrateOldSaveData();

        // Check that migration flag is set
        final prefs = await SharedPreferences.getInstance();
        final migrationCompleted = prefs.getBool('checkpoint_migration_v1');
        expect(migrationCompleted, true);
      });
    });

    group('Data Management', () {
      test('should clear all data correctly', () async {
        await service.initialize();

        // Add some test data
        final progress = PathProgress(
          pathType: PathType.dogBreeds,
          lastPlayed: testDate,
        );

        final session = GameSession(sessionStart: testDate);

        await service.savePathProgress(progress);
        await service.saveGameSession(session);
        await service.saveGlobalStats({'test': 'data'});
        await service.saveGameSettings({'test': 'setting'});

        // Verify data exists
        expect(await service.loadPathProgress(PathType.dogBreeds), isNotNull);
        expect(await service.loadGameSession(), isNotNull);
        expect(await service.loadGlobalStats(), isNotEmpty);
        expect(await service.loadGameSettings(), isNotEmpty);

        // Clear all data
        await service.clearAllData();

        // Verify data is cleared (should return to defaults)
        expect(await service.loadPathProgress(PathType.dogBreeds), isNull);
        expect(await service.loadGameSession(), isNull);
        expect(await service.loadGlobalStats(), isNotEmpty); // Returns defaults
        expect(
          await service.loadGameSettings(),
          isNotEmpty,
        ); // Returns defaults
      });
    });

    test(
      'should initialize without SharedPreferences being pre-initialized',
      () async {
        // Create a new service instance
        final newService = GamePersistenceService();

        // Should initialize successfully
        await newService.initialize();

        // Should be able to save data
        final progress = PathProgress(
          pathType: PathType.dogBreeds,
          lastPlayed: testDate,
        );

        await newService.savePathProgress(progress);
        final loaded = await newService.loadPathProgress(PathType.dogBreeds);

        expect(loaded, isNotNull);
      },
    );
  });
}
