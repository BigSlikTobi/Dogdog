import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/models/path_progress.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('PathProgress Tests', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 8, 9, 10, 30, 0);
    });

    test('should create PathProgress with default values', () {
      final progress = PathProgress(
        pathType: PathType.dogBreeds,
        lastPlayed: testDate,
      );

      expect(progress.pathType, PathType.dogBreeds);
      expect(progress.currentCheckpoint, Checkpoint.chihuahua);
      expect(progress.answeredQuestionIds, isEmpty);
      expect(progress.powerUpInventory, isEmpty);
      expect(progress.correctAnswers, 0);
      expect(progress.totalQuestions, 0);
      expect(progress.bestAccuracy, 0.0);
      expect(progress.totalTimeSpent, 0);
      expect(progress.fallbackCount, 0);
      expect(progress.lastPlayed, testDate);
      expect(progress.isCompleted, false);
    });

    test('should calculate current accuracy correctly', () {
      final progress = PathProgress(
        pathType: PathType.dogBreeds,
        lastPlayed: testDate,
        correctAnswers: 8,
        totalQuestions: 10,
      );

      expect(progress.currentAccuracy, 80.0);
    });

    test('should return 0 accuracy when no questions answered', () {
      final progress = PathProgress(
        pathType: PathType.dogBreeds,
        lastPlayed: testDate,
      );

      expect(progress.currentAccuracy, 0.0);
    });

    test('should get next checkpoint correctly', () {
      final progressAtFirst = PathProgress(
        pathType: PathType.dogBreeds,
        lastPlayed: testDate,
        currentCheckpoint: Checkpoint.chihuahua,
      );

      final progressAtLast = PathProgress(
        pathType: PathType.dogBreeds,
        lastPlayed: testDate,
        currentCheckpoint: Checkpoint.deutscheDogge,
      );

      expect(progressAtFirst.nextCheckpoint, Checkpoint.cockerSpaniel);
      expect(progressAtLast.nextCheckpoint, Checkpoint.deutscheDogge);
    });

    test('should check if question has been answered', () {
      final progress = PathProgress(
        pathType: PathType.dogBreeds,
        lastPlayed: testDate,
        answeredQuestionIds: ['q1', 'q2', 'q3'],
      );

      expect(progress.hasAnsweredQuestion('q1'), true);
      expect(progress.hasAnsweredQuestion('q4'), false);
    });

    test('should add answered question', () {
      final progress = PathProgress(
        pathType: PathType.dogBreeds,
        lastPlayed: testDate,
        answeredQuestionIds: ['q1', 'q2'],
      );

      final updated = progress.addAnsweredQuestion('q3');

      expect(updated.answeredQuestionIds, ['q1', 'q2', 'q3']);
      expect(progress.answeredQuestionIds, ['q1', 'q2']); // Original unchanged
    });

    test('should not add duplicate answered question', () {
      final progress = PathProgress(
        pathType: PathType.dogBreeds,
        lastPlayed: testDate,
        answeredQuestionIds: ['q1', 'q2'],
      );

      final updated = progress.addAnsweredQuestion('q1');

      expect(updated.answeredQuestionIds, ['q1', 'q2']);
      expect(updated, same(progress)); // Should return same instance
    });

    test('should add power-ups to inventory', () {
      final progress = PathProgress(
        pathType: PathType.dogBreeds,
        lastPlayed: testDate,
        powerUpInventory: {PowerUpType.fiftyFifty: 2},
      );

      final updated = progress.addPowerUps({
        PowerUpType.fiftyFifty: 1,
        PowerUpType.hint: 3,
      });

      expect(updated.powerUpInventory[PowerUpType.fiftyFifty], 3);
      expect(updated.powerUpInventory[PowerUpType.hint], 3);
    });

    test('should use power-up correctly', () {
      final progress = PathProgress(
        pathType: PathType.dogBreeds,
        lastPlayed: testDate,
        powerUpInventory: {PowerUpType.fiftyFifty: 3},
      );

      final updated = progress.usePowerUp(PowerUpType.fiftyFifty);

      expect(updated.powerUpInventory[PowerUpType.fiftyFifty], 2);
    });

    test('should not use power-up when count is 0', () {
      final progress = PathProgress(
        pathType: PathType.dogBreeds,
        lastPlayed: testDate,
        powerUpInventory: {PowerUpType.fiftyFifty: 0},
      );

      final updated = progress.usePowerUp(PowerUpType.fiftyFifty);

      expect(updated, same(progress)); // Should return same instance
    });

    test('should advance checkpoint correctly', () {
      final progress = PathProgress(
        pathType: PathType.dogBreeds,
        lastPlayed: testDate,
        currentCheckpoint: Checkpoint.chihuahua,
      );

      final updated = progress.advanceCheckpoint();

      expect(updated.currentCheckpoint, Checkpoint.cockerSpaniel);
      expect(updated.isCompleted, false);
      expect(updated.lastPlayed.isAfter(testDate), true);
    });

    test('should mark as completed when reaching final checkpoint', () {
      final progress = PathProgress(
        pathType: PathType.dogBreeds,
        lastPlayed: testDate,
        currentCheckpoint: Checkpoint.greatDane,
      );

      final updated = progress.advanceCheckpoint();

      expect(updated.currentCheckpoint, Checkpoint.deutscheDogge);
      expect(updated.isCompleted, true);
    });

    test('should update session stats correctly', () {
      final progress = PathProgress(
        pathType: PathType.dogBreeds,
        lastPlayed: testDate,
        correctAnswers: 5,
        totalQuestions: 8,
        bestAccuracy: 60.0,
        totalTimeSpent: 120,
      );

      final updated = progress.updateSessionStats(
        correctAnswers: 3,
        totalQuestions: 5,
        timeSpent: 90,
      );

      expect(updated.correctAnswers, 8);
      expect(updated.totalQuestions, 13);
      expect(updated.currentAccuracy.round(), 62); // 8/13 ≈ 61.5%
      expect(updated.bestAccuracy.round(), 62); // New best
      expect(updated.totalTimeSpent, 210);
      expect(updated.lastPlayed.isAfter(testDate), true);
    });

    test('should serialize to and from Map correctly', () {
      final original = PathProgress(
        pathType: PathType.healthCare,
        currentCheckpoint: Checkpoint.greatDane,
        answeredQuestionIds: ['q1', 'q2', 'q3'],
        powerUpInventory: {PowerUpType.fiftyFifty: 2, PowerUpType.hint: 1},
        correctAnswers: 8,
        totalQuestions: 12,
        bestAccuracy: 75.5,
        totalTimeSpent: 300,
        fallbackCount: 1,
        lastPlayed: testDate,
        isCompleted: false,
      );

      final map = original.toMap();
      final restored = PathProgress.fromMap(map);

      expect(restored.pathType, original.pathType);
      expect(restored.currentCheckpoint, original.currentCheckpoint);
      expect(restored.answeredQuestionIds, original.answeredQuestionIds);
      expect(restored.powerUpInventory, original.powerUpInventory);
      expect(restored.correctAnswers, original.correctAnswers);
      expect(restored.totalQuestions, original.totalQuestions);
      expect(restored.bestAccuracy, original.bestAccuracy);
      expect(restored.totalTimeSpent, original.totalTimeSpent);
      expect(restored.fallbackCount, original.fallbackCount);
      expect(restored.lastPlayed, original.lastPlayed);
      expect(restored.isCompleted, original.isCompleted);
    });

    test('should handle malformed data gracefully in fromMap', () {
      final malformedMap = {
        'pathType': 'NonExistentPath',
        'currentCheckpoint': 'NonExistentCheckpoint',
        'powerUpInventory': {'NonExistentPowerUp': 5},
      };

      final progress = PathProgress.fromMap(malformedMap);

      expect(progress.pathType, PathType.dogBreeds); // Default fallback
      expect(
        progress.currentCheckpoint,
        Checkpoint.chihuahua,
      ); // Default fallback
      expect(progress.powerUpInventory, isEmpty); // Invalid power-ups ignored
    });
  });
}
