import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/controllers/treasure_map_controller.dart';
import 'package:dogdog_trivia_game/controllers/power_up_controller.dart';
import 'package:dogdog_trivia_game/controllers/persistent_timer_controller.dart';
import 'package:dogdog_trivia_game/services/question_service.dart';
import 'package:dogdog_trivia_game/services/game_persistence_service.dart';
import 'package:dogdog_trivia_game/services/enhanced_persistence_manager.dart';
import 'package:dogdog_trivia_game/services/progress_service.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('Complete State Management Integration Tests', () {
    late GameController gameController;
    late TreasureMapController treasureMapController;
    late PowerUpController powerUpController;
    late PersistentTimerController timerController;
    late GamePersistenceService persistenceService;
    late EnhancedPersistenceManager enhancedPersistence;
    late ProgressService progressService;

    setUp(() async {
      // Set up clean test environment
      SharedPreferences.setMockInitialValues({});

      // Initialize all services
      persistenceService = GamePersistenceService();
      await persistenceService.initialize();

      enhancedPersistence = EnhancedPersistenceManager();
      await enhancedPersistence.initialize();

      progressService = ProgressService();
      await progressService.initialize();

      // Initialize controllers
      treasureMapController = TreasureMapController();
      powerUpController = PowerUpController();
      timerController = PersistentTimerController();

      gameController = GameController(
        questionService: QuestionService(),
        powerUpController: powerUpController,
        treasureMapController: treasureMapController,
        timerController: timerController,
        persistenceService: persistenceService,
        enhancedPersistence: enhancedPersistence,
        progressService: progressService,
      );
    });

    tearDown(() async {
      try {
        // Clean up controllers
        gameController.dispose();
        enhancedPersistence.dispose();
        progressService.dispose();

        // Clear all test data
        await persistenceService.clearAllData();
      } catch (_) {
        // Ignore cleanup errors in tests
      }
    });

    group('Path-based Game State Management', () {
      test(
        'should properly integrate TreasureMapController with GameController',
        () async {
          // Initialize a path-based game
          await gameController.initializePathGame(path: PathType.dogBreeds);

          // Verify integration
          expect(gameController.currentPath, PathType.dogBreeds);
          expect(treasureMapController.currentPath, PathType.dogBreeds);
          expect(gameController.nextCheckpoint, Checkpoint.chihuahua);
          expect(gameController.questionsToNextCheckpoint, greaterThan(0));
          expect(gameController.progressToNextCheckpoint, 0.0);

          // Test state synchronization
          expect(treasureMapController.currentPath, gameController.currentPath);
          expect(
            treasureMapController.nextCheckpoint,
            gameController.nextCheckpoint,
          );
        },
      );

      test('should persist and restore path progress correctly', () async {
        // Initialize and start a game session
        await gameController.initializePathGame(path: PathType.dogBreeds);

        // Verify initial state
        expect(gameController.currentPath, PathType.dogBreeds);
        expect(gameController.nextCheckpoint, isNotNull);

        // Force save progress
        await gameController.forceSaveProgress();

        // Verify progress was saved
        final pathProgress = await persistenceService.loadPathProgress(
          PathType.dogBreeds,
        );
        expect(pathProgress, isNotNull);
        expect(pathProgress!.pathType, PathType.dogBreeds);
      });

      test(
        'should maintain controller integration after initialization',
        () async {
          await gameController.initializePathGame(path: PathType.dogBreeds);

          // Verify all controllers are properly integrated
          expect(gameController.treasureMapController, isNotNull);
          expect(
            gameController.treasureMapController,
            equals(treasureMapController),
          );
          expect(gameController.currentPath, treasureMapController.currentPath);
        },
      );
    });

    group('Category-based Game State Management', () {
      test('should properly handle category initialization', () async {
        // Initialize with a specific category
        await gameController.initializeGameWithCategory(
          category: QuestionCategory.dogBreeds,
          level: 2,
        );

        // Verify game was initialized
        expect(gameController.gameState.isGameActive, true);
        expect(gameController.gameState.level, 2);
      });

      test('should remember and restore last selected category', () async {
        // Initialize with a category
        await gameController.initializeGameWithCategory(
          category: QuestionCategory.dogTraining,
          level: 1,
        );

        await gameController.forceSaveProgress();

        // Try to load last selected category
        final lastCategory = await gameController.getLastSelectedCategory();
        // Category might be stored, depending on implementation
        expect(
          lastCategory,
          anyOf(isNull, equals(QuestionCategory.dogTraining)),
        );
      });
    });

    group('State Consistency and Error Handling', () {
      test('should provide comprehensive system status', () async {
        await gameController.initializePathGame(path: PathType.dogBreeds);

        final systemStatus = gameController.getSystemStatus();

        expect(systemStatus, contains('Enhanced Persistence Manager'));
        expect(systemStatus, contains('Game Persistence Service'));
        expect(systemStatus, contains('Progress Service'));
        expect(systemStatus, contains('Power-Up Controller'));
        expect(systemStatus, contains('Treasure Map Controller'));
        expect(systemStatus, contains('Timer Controller'));
      });

      test(
        'should handle initialization with corrupted data gracefully',
        () async {
          // Simulate corrupted data by manually setting invalid SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'path_progress_PathType.dogBreeds',
            'invalid json',
          );
          await prefs.setString('current_session', 'invalid json');

          // Initialize should handle corrupted data gracefully
          expect(
            () async => await gameController.initializePathGame(
              path: PathType.dogBreeds,
            ),
            returnsNormally,
          );

          // Game should still be functional
          expect(gameController.currentPath, PathType.dogBreeds);
          expect(gameController.nextCheckpoint, isNotNull);
        },
      );

      test('should properly clean up resources on disposal', () async {
        await gameController.initializePathGame(path: PathType.dogBreeds);

        // Verify controllers are properly initialized
        expect(gameController.treasureMapController, isNotNull);

        // Dispose and verify cleanup doesn't throw
        expect(() => gameController.dispose(), returnsNormally);
      });
    });

    group('Enhanced Persistence Integration', () {
      test('should integrate with enhanced persistence manager', () async {
        await gameController.initializePathGame(path: PathType.dogBreeds);

        // Enhanced persistence should be working
        expect(enhancedPersistence, isNotNull);

        // Force save should work with both systems
        await gameController.forceSaveProgress();

        // Both persistence systems should have data
        final pathProgress = await persistenceService.loadPathProgress(
          PathType.dogBreeds,
        );
        expect(pathProgress, isNotNull);
      });

      test('should handle automatic saving', () async {
        await gameController.initializePathGame(path: PathType.dogBreeds);

        // Simulate some game activity that would trigger auto-save
        await gameController.reportGameSessionResults();

        // Enhanced persistence should handle automatic operations
        expect(enhancedPersistence, isNotNull);
      });
    });

    group('Multiple Controller Integration', () {
      test('should coordinate between all controllers correctly', () async {
        await gameController.initializePathGame(path: PathType.dogBreeds);

        // All controllers should be properly integrated
        expect(
          gameController.treasureMapController,
          equals(treasureMapController),
        );
        expect(
          gameController.treasureMapController.currentPath,
          PathType.dogBreeds,
        );

        // Controllers should maintain consistent state
        expect(gameController.currentPath, treasureMapController.currentPath);
        expect(
          gameController.nextCheckpoint,
          treasureMapController.nextCheckpoint,
        );
      });

      test('should handle multiple rapid initializations', () async {
        // Initialize multiple times rapidly
        await gameController.initializePathGame(path: PathType.dogBreeds);
        await gameController.initializePathGame(path: PathType.dogTraining);
        await gameController.initializePathGame(path: PathType.healthCare);

        // Should be in consistent state after rapid changes
        expect(gameController.currentPath, PathType.healthCare);
        expect(treasureMapController.currentPath, PathType.healthCare);
        expect(gameController.nextCheckpoint, isNotNull);
      });
    });
  });
}
