import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/models/game_session.dart';
import 'package:dogdog_trivia_game/models/path_progress.dart';
import 'package:dogdog_trivia_game/services/game_persistence_service.dart';
import 'package:dogdog_trivia_game/controllers/treasure_map_controller.dart';
import 'package:dogdog_trivia_game/controllers/power_up_controller.dart';
import 'package:dogdog_trivia_game/controllers/persistent_timer_controller.dart';
import '../helpers/test_helper.dart';

// Mock persistence service that throws errors
class FailingPersistenceService extends GamePersistenceService {
  @override
  Future<void> initialize() async {
    throw Exception('Simulated persistence initialization failure');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameController Enhanced State Management Tests', () {
    setUp(() {
      TestHelper.setUpTestEnvironment();
    });
    late GameController gameController;
    late GamePersistenceService mockPersistenceService;
    late TreasureMapController treasureMapController;
    late PowerUpController powerUpController;
    late PersistentTimerController timerController;

    setUp(() async {
      // Create mock services and controllers
      mockPersistenceService = GamePersistenceService();
      treasureMapController = TreasureMapController();
      powerUpController = PowerUpController();
      timerController = PersistentTimerController();

      // Initialize persistence service
      await mockPersistenceService.initialize();

      gameController = GameController(
        persistenceService: mockPersistenceService,
        treasureMapController: treasureMapController,
        powerUpController: powerUpController,
        timerController: timerController,
      );
    });

    test('should initialize game with path successfully', () async {
      await gameController.initializeGameWithPath(
        pathType: PathType.dogBreeds,
        resumeSession: false,
      );

      expect(gameController.currentPath, PathType.dogBreeds);
      expect(gameController.hasActiveSession, true);
      expect(gameController.currentPathProgress, isNotNull);
      expect(gameController.currentSession, isNotNull);
      expect(gameController.isGameActive, true);
    });

    test('should create new session when none exists', () async {
      await gameController.initializeGameWithPath(
        pathType: PathType.dogTraining,
        resumeSession: true,
      );

      final session = gameController.currentSession;
      expect(session, isNotNull);
      expect(session!.currentPath, PathType.dogTraining);
      expect(session.livesRemaining, 3);
      expect(session.currentStreak, 0);
      expect(session.sessionQuestionIds, isEmpty);
    });

    test('should load existing path progress if available', () async {
      // Create and save initial progress
      final initialProgress = PathProgress(
        pathType: PathType.healthCare,
        lastPlayed: DateTime.now(),
        correctAnswers: 5,
        totalQuestions: 8,
        powerUpInventory: {PowerUpType.fiftyFifty: 2},
      );

      await mockPersistenceService.savePathProgress(initialProgress);

      // Initialize game with same path
      await gameController.initializeGameWithPath(
        pathType: PathType.healthCare,
        resumeSession: false,
      );

      final loadedProgress = gameController.currentPathProgress;
      expect(loadedProgress, isNotNull);
      expect(loadedProgress!.pathType, PathType.healthCare);
      expect(loadedProgress.correctAnswers, 5);
      expect(loadedProgress.totalQuestions, 8);
      expect(loadedProgress.powerUpInventory[PowerUpType.fiftyFifty], 2);
    });

    test('should resume existing session for same path', () async {
      // Create and save a session
      final existingSession = GameSession(
        currentPath: PathType.dogBehavior,
        livesRemaining: 2,
        currentStreak: 3,
        sessionStart: DateTime.now(),
      );

      await mockPersistenceService.saveGameSession(existingSession);

      // Initialize game with resumption
      await gameController.initializeGameWithPath(
        pathType: PathType.dogBehavior,
        resumeSession: true,
      );

      final session = gameController.currentSession;
      expect(session, isNotNull);
      expect(session!.currentPath, PathType.dogBehavior);
      expect(session.livesRemaining, 2);
      expect(session.currentStreak, 3);
    });

    test('should reject session for different path', () async {
      // Create session for different path
      final existingSession = GameSession(
        currentPath: PathType.dogHistory,
        livesRemaining: 1,
        sessionStart: DateTime.now(),
      );

      await mockPersistenceService.saveGameSession(existingSession);

      // Try to initialize with different path
      await gameController.initializeGameWithPath(
        pathType: PathType.dogBreeds,
        resumeSession: true,
      );

      final session = gameController.currentSession;
      expect(session, isNotNull);
      expect(session!.currentPath, PathType.dogBreeds);
      expect(session.livesRemaining, 3); // New session with full lives
    });

    test('should sync power-ups from path progress', () async {
      // Create progress with power-ups
      final progressWithPowerUps = PathProgress(
        pathType: PathType.dogBreeds,
        lastPlayed: DateTime.now(),
        powerUpInventory: {
          PowerUpType.fiftyFifty: 3,
          PowerUpType.hint: 2,
          PowerUpType.extraTime: 1,
        },
      );

      await mockPersistenceService.savePathProgress(progressWithPowerUps);

      await gameController.initializeGameWithPath(
        pathType: PathType.dogBreeds,
        resumeSession: false,
      );

      // Check power-ups are synced
      expect(powerUpController.getPowerUpCount(PowerUpType.fiftyFifty), 3);
      expect(powerUpController.getPowerUpCount(PowerUpType.hint), 2);
      expect(powerUpController.getPowerUpCount(PowerUpType.extraTime), 1);
    });

    test('should update treasure map controller with path', () async {
      await gameController.initializeGameWithPath(
        pathType: PathType.dogHistory,
        resumeSession: false,
      );

      expect(treasureMapController.currentPath, PathType.dogHistory);
    });

    test('should handle initialization errors gracefully', () async {
      // Create controller with failing persistence service
      final corruptedController = GameController(
        persistenceService: FailingPersistenceService(),
      );

      // Should throw exception due to persistence failure
      expect(
        () => corruptedController.initializeGameWithPath(
          pathType: PathType.dogBreeds,
          resumeSession: false,
        ),
        throwsException,
      );
    });

    test('should preserve state consistency across method calls', () async {
      await gameController.initializeGameWithPath(
        pathType: PathType.dogTraining,
        resumeSession: false,
      );

      // Verify consistent state
      expect(gameController.currentPath, PathType.dogTraining);
      expect(
        gameController.currentPathProgress?.pathType,
        PathType.dogTraining,
      );
      expect(gameController.currentSession?.currentPath, PathType.dogTraining);
      expect(treasureMapController.currentPath, PathType.dogTraining);
    });

    test(
      'should maintain backwards compatibility with legacy initializeGame',
      () async {
        // Should still work without persistence
        await gameController.initializeGame(level: 2);

        expect(gameController.isGameActive, true);
        expect(gameController.level, 2);
        expect(gameController.lives, 3);

        // But persistence-related getters should return null
        expect(gameController.currentPathProgress, isNull);
        expect(gameController.currentSession, isNull);
        expect(gameController.hasActiveSession, false);
      },
    );
  });
}
