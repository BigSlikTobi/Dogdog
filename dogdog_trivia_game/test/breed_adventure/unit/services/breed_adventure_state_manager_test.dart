import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dogdog_trivia_game/models/breed_adventure/breed_adventure_game_state.dart';
import 'package:dogdog_trivia_game/models/breed_adventure/difficulty_phase.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/services/breed_adventure/breed_adventure_state_manager.dart';
import 'package:dogdog_trivia_game/services/game_persistence_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('BreedAdventureStateManager', () {
    late BreedAdventureStateManager stateManager;
    late GamePersistenceService persistence;

    setUp(() async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});

      stateManager = BreedAdventureStateManager.instance;
      persistence = GamePersistenceService();

      await stateManager.initialize();
    });

    tearDown(() {
      stateManager.dispose();
    });

    group('State Validation', () {
      test('should validate correct game state', () {
        final validState = BreedAdventureGameState(
          score: 100,
          correctAnswers: 5,
          totalQuestions: 8,
          currentPhase: DifficultyPhase.beginner,
          usedBreeds: {'breed1', 'breed2'},
          powerUps: {PowerUpType.extraTime: 1, PowerUpType.skip: 2},
          isGameActive: true,
          gameStartTime: DateTime.now(),
          consecutiveCorrect: 3,
          timeRemaining: 8,
        );

        expect(stateManager.validateCurrentState(validState), isTrue);
      });

      test('should reject invalid game state with negative score', () {
        final invalidState = BreedAdventureGameState(
          score: -100,
          correctAnswers: 5,
          totalQuestions: 8,
          currentPhase: DifficultyPhase.beginner,
          usedBreeds: {'breed1', 'breed2'},
          powerUps: {PowerUpType.extraTime: 1},
          isGameActive: true,
        );

        expect(stateManager.validateCurrentState(invalidState), isFalse);
      });

      test(
        'should reject state with more correct answers than total questions',
        () {
          final invalidState = BreedAdventureGameState(
            score: 100,
            correctAnswers: 10,
            totalQuestions: 8,
            currentPhase: DifficultyPhase.beginner,
            usedBreeds: {'breed1', 'breed2'},
            powerUps: {PowerUpType.extraTime: 1},
            isGameActive: true,
          );

          expect(stateManager.validateCurrentState(invalidState), isFalse);
        },
      );

      test('should reject state with suspicious power-up count', () {
        final invalidState = BreedAdventureGameState(
          score: 100,
          correctAnswers: 5,
          totalQuestions: 8,
          currentPhase: DifficultyPhase.beginner,
          usedBreeds: {'breed1', 'breed2'},
          powerUps: {PowerUpType.extraTime: 25}, // Too many
          isGameActive: true,
        );

        expect(stateManager.validateCurrentState(invalidState), isFalse);
      });

      test('should reject state with phase progression inconsistency', () {
        final invalidState = BreedAdventureGameState(
          score: 100,
          correctAnswers: 2,
          totalQuestions: 3,
          currentPhase: DifficultyPhase
              .expert, // Should not be expert with so few questions
          usedBreeds: {'breed1', 'breed2'},
          powerUps: {PowerUpType.extraTime: 1},
          isGameActive: true,
        );

        expect(stateManager.validateCurrentState(invalidState), isFalse);
      });
    });

    group('State Persistence', () {
      test('should save and load game state correctly', () async {
        final originalState = BreedAdventureGameState(
          score: 150,
          correctAnswers: 7,
          totalQuestions: 10,
          currentPhase: DifficultyPhase.intermediate,
          usedBreeds: {'breed1', 'breed2', 'breed3'},
          powerUps: {PowerUpType.extraTime: 1, PowerUpType.skip: 2},
          isGameActive: true,
          gameStartTime: DateTime.now(),
          consecutiveCorrect: 2,
          timeRemaining: 5,
          currentHint: 'Test hint',
        );

        await stateManager.saveGameState(originalState);
        final loadedState = await stateManager.loadGameState();

        expect(loadedState, isNotNull);
        expect(loadedState!.score, equals(originalState.score));
        expect(
          loadedState.correctAnswers,
          equals(originalState.correctAnswers),
        );
        expect(
          loadedState.totalQuestions,
          equals(originalState.totalQuestions),
        );
        expect(loadedState.currentPhase, equals(originalState.currentPhase));
        expect(loadedState.usedBreeds, equals(originalState.usedBreeds));
        expect(loadedState.powerUps, equals(originalState.powerUps));
        expect(loadedState.isGameActive, equals(originalState.isGameActive));
        expect(
          loadedState.consecutiveCorrect,
          equals(originalState.consecutiveCorrect),
        );
        expect(loadedState.timeRemaining, equals(originalState.timeRemaining));
        expect(loadedState.currentHint, equals(originalState.currentHint));
      });

      test('should return null when no saved state exists', () async {
        final loadedState = await stateManager.loadGameState();
        expect(loadedState, isNull);
      });

      test('should clear saved state successfully', () async {
        final state = BreedAdventureGameState(
          score: 100,
          correctAnswers: 5,
          totalQuestions: 8,
          currentPhase: DifficultyPhase.beginner,
          usedBreeds: {'breed1'},
          powerUps: {PowerUpType.extraTime: 1},
          isGameActive: true,
        );

        await stateManager.saveGameState(state);
        await stateManager.clearSavedState();
        final loadedState = await stateManager.loadGameState();

        expect(loadedState, isNull);
      });

      test('should handle corrupted state data gracefully', () async {
        // Manually corrupt the saved data
        await persistence.initialize();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('breed_adventure_state', 'invalid_json');

        final loadedState = await stateManager.loadGameState();
        expect(loadedState, isNull);
      });
    });

    group('State Recovery', () {
      test('should provide recovery state from history', () async {
        // Add multiple states to history
        final state1 = BreedAdventureGameState(
          score: 50,
          correctAnswers: 3,
          totalQuestions: 5,
          currentPhase: DifficultyPhase.beginner,
          usedBreeds: {'breed1'},
          powerUps: {PowerUpType.extraTime: 2},
          isGameActive: true,
        );

        final state2 = BreedAdventureGameState(
          score: 100,
          correctAnswers: 5,
          totalQuestions: 8,
          currentPhase: DifficultyPhase.beginner,
          usedBreeds: {'breed1', 'breed2'},
          powerUps: {PowerUpType.extraTime: 1},
          isGameActive: true,
        );

        await stateManager.saveGameState(state1);
        await stateManager.saveGameState(state2);

        final recoveryState = stateManager.getRecoveryState();
        expect(recoveryState, isNotNull);
        expect(
          recoveryState!.score,
          equals(100),
        ); // Should be the latest valid state
      });

      test('should return null when no recovery state available', () {
        final recoveryState = stateManager.getRecoveryState();
        expect(recoveryState, isNull);
      });
    });

    group('Game Activity Management', () {
      test('should track game activity correctly', () {
        expect(
          stateManager.validateCurrentState(BreedAdventureGameState.initial()),
          isTrue,
        );

        stateManager.setGameActive(true);
        // No direct way to check _isGameActive, but it affects behavior

        stateManager.setGameActive(false);
        // Game is now inactive
      });
    });

    group('Statistics Update', () {
      test('should update game statistics after completion', () async {
        final finalState = BreedAdventureGameState(
          score: 200,
          correctAnswers: 8,
          totalQuestions: 10,
          currentPhase: DifficultyPhase.intermediate,
          usedBreeds: {'breed1', 'breed2', 'breed3'},
          powerUps: {PowerUpType.extraTime: 0, PowerUpType.skip: 1},
          isGameActive: false,
          gameStartTime: DateTime.now().subtract(const Duration(minutes: 5)),
          consecutiveCorrect: 3,
        );

        await stateManager.updateGameStatistics(
          finalState: finalState,
          gameDuration: 300, // 5 minutes
          powerUpsUsed: 2,
        );

        final stats = await persistence.loadBreedAdventureStatistics();
        expect(stats['gamesPlayed'], equals(1));
        expect(stats['totalScore'], equals(200));
        expect(stats['totalCorrectAnswers'], equals(8));
        expect(stats['totalQuestions'], equals(10));
        expect(stats['powerUpsUsed'], equals(2));
        expect(stats['totalTimePlayed'], equals(300));
      });
    });

    group('JSON Serialization', () {
      test('should serialize and deserialize game state correctly', () {
        final originalState = BreedAdventureGameState(
          score: 150,
          correctAnswers: 7,
          totalQuestions: 10,
          currentPhase: DifficultyPhase.intermediate,
          usedBreeds: {'breed1', 'breed2', 'breed3'},
          powerUps: {
            PowerUpType.extraTime: 1,
            PowerUpType.skip: 2,
            PowerUpType.hint: 0,
          },
          isGameActive: true,
          gameStartTime: DateTime(2024, 1, 1, 12, 0, 0),
          consecutiveCorrect: 3,
          timeRemaining: 7,
          currentHint: 'Test hint',
        );

        final json = originalState.toJson();
        final deserializedState = BreedAdventureGameState.fromJson(json);

        expect(deserializedState.score, equals(originalState.score));
        expect(
          deserializedState.correctAnswers,
          equals(originalState.correctAnswers),
        );
        expect(
          deserializedState.totalQuestions,
          equals(originalState.totalQuestions),
        );
        expect(
          deserializedState.currentPhase,
          equals(originalState.currentPhase),
        );
        expect(deserializedState.usedBreeds, equals(originalState.usedBreeds));
        expect(deserializedState.powerUps, equals(originalState.powerUps));
        expect(
          deserializedState.isGameActive,
          equals(originalState.isGameActive),
        );
        expect(
          deserializedState.gameStartTime,
          equals(originalState.gameStartTime),
        );
        expect(
          deserializedState.consecutiveCorrect,
          equals(originalState.consecutiveCorrect),
        );
        expect(
          deserializedState.timeRemaining,
          equals(originalState.timeRemaining),
        );
        expect(
          deserializedState.currentHint,
          equals(originalState.currentHint),
        );
      });

      test('should handle null gameStartTime in JSON', () {
        final stateWithoutStartTime = BreedAdventureGameState(
          score: 100,
          correctAnswers: 5,
          totalQuestions: 8,
          currentPhase: DifficultyPhase.beginner,
          usedBreeds: {'breed1'},
          powerUps: {PowerUpType.extraTime: 1},
          isGameActive: false,
          gameStartTime: null,
        );

        final json = stateWithoutStartTime.toJson();
        final deserializedState = BreedAdventureGameState.fromJson(json);

        expect(deserializedState.gameStartTime, isNull);
      });

      test('should handle malformed JSON gracefully', () {
        final malformedJson = {
          'score': 'invalid', // Should be int
          'correctAnswers': 5,
          'totalQuestions': 8,
        };

        expect(
          () => BreedAdventureGameState.fromJson(malformedJson),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('State Validation with copyWithValidation', () {
      test('should create valid state with copyWithValidation', () {
        final originalState = BreedAdventureGameState.initial();

        final newState = originalState.copyWithValidation(
          score: 100,
          correctAnswers: 5,
          totalQuestions: 8,
        );

        expect(newState.score, equals(100));
        expect(newState.correctAnswers, equals(5));
        expect(newState.totalQuestions, equals(8));
      });

      test(
        'should throw StateError for invalid state with copyWithValidation',
        () {
          final originalState = BreedAdventureGameState.initial();

          expect(
            () => originalState.copyWithValidation(
              score: -100, // Invalid negative score
              correctAnswers: 5,
              totalQuestions: 8,
            ),
            throwsStateError,
          );
        },
      );

      test('should throw StateError for logically inconsistent state', () {
        final originalState = BreedAdventureGameState.initial();

        expect(
          () => originalState.copyWithValidation(
            correctAnswers: 10,
            totalQuestions: 5, // More correct than total
          ),
          throwsStateError,
        );
      });
    });
  });
}
