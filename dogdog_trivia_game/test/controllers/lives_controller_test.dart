import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/controllers/lives_controller.dart';

void main() {
  group('LivesController', () {
    late LivesController controller;

    setUp(() {
      controller = LivesController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initializes with 3 lives by default', () {
      expect(controller.currentLives, 3);
      expect(controller.maxLives, 3);
      expect(controller.isGameOver, false);
    });

    test('initializes with custom values', () {
      final customController = LivesController(initialLives: 2, maxLives: 5);
      expect(customController.currentLives, 2);
      expect(customController.maxLives, 5);
      expect(customController.isGameOver, false);
      customController.dispose();
    });

    test('clamps initial lives to valid range', () {
      final controller1 = LivesController(initialLives: -1);
      expect(controller1.currentLives, 0);
      controller1.dispose();

      final controller2 = LivesController(initialLives: 10, maxLives: 3);
      expect(controller2.currentLives, 3);
      controller2.dispose();
    });

    test('loses life correctly', () {
      expect(controller.currentLives, 3);

      controller.loseLife();
      expect(controller.currentLives, 2);
      expect(controller.isGameOver, false);

      controller.loseLife();
      expect(controller.currentLives, 1);
      expect(controller.isGameOver, false);

      controller.loseLife();
      expect(controller.currentLives, 0);
      expect(controller.isGameOver, true);

      // Should not go below 0
      controller.loseLife();
      expect(controller.currentLives, 0);
      expect(controller.isGameOver, true);
    });

    test('restores life correctly', () {
      controller.setLives(1);
      expect(controller.currentLives, 1);

      controller.restoreLife();
      expect(controller.currentLives, 2);

      controller.restoreLife();
      expect(controller.currentLives, 3);

      // Should not go above max
      controller.restoreLife();
      expect(controller.currentLives, 3);
    });

    test('resets lives to max', () {
      controller.setLives(1);
      expect(controller.currentLives, 1);

      controller.resetLives();
      expect(controller.currentLives, 3);
    });

    test('setLives clamps to valid range', () {
      controller.setLives(-5);
      expect(controller.currentLives, 0);

      controller.setLives(10);
      expect(controller.currentLives, 3);

      controller.setLives(2);
      expect(controller.currentLives, 2);
    });

    test('notifies listeners on changes', () {
      var notificationCount = 0;
      controller.addListener(() => notificationCount++);

      controller.loseLife();
      expect(notificationCount, 1);

      controller.restoreLife();
      expect(notificationCount, 2);

      controller.resetLives();
      expect(notificationCount, 2); // Reset to same value (3) should not notify

      controller.setLives(2);
      expect(notificationCount, 3);

      // Setting same value should not notify
      controller.setLives(2);
      expect(notificationCount, 3);
    });

    test('game over logic works correctly', () {
      expect(controller.isGameOver, false);

      controller.setLives(1);
      expect(controller.isGameOver, false);

      controller.setLives(0);
      expect(controller.isGameOver, true);
    });
  });
}
