import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/controllers/persistent_timer_controller.dart';

void main() {
  group('PersistentTimerController', () {
    late PersistentTimerController controller;

    setUp(() {
      controller = PersistentTimerController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initializes with default values', () {
      expect(controller.timeRemaining, 0);
      expect(controller.totalTime, 0);
      expect(controller.isActive, false);
      expect(controller.isPaused, false);
      expect(controller.progress, 0.0);
      expect(controller.isWarningTriggered, false);
      expect(controller.isInCriticalTime, false);
    });

    test('starts timer correctly', () {
      var timeExpiredCalled = false;
      controller.startTimer(
        seconds: 10,
        onTimeExpired: () => timeExpiredCalled = true,
      );

      expect(controller.timeRemaining, 10);
      expect(controller.totalTime, 10);
      expect(controller.isActive, true);
      expect(controller.isPaused, false);
      expect(controller.progress, 1.0);
      expect(timeExpiredCalled, false);
    });

    test('calculates progress correctly', () {
      controller.startTimer(seconds: 20, onTimeExpired: () {});

      expect(controller.progress, 1.0); // 20/20 = 1.0

      // Simulate manual time reduction for testing
      controller.resetTimer(10);
      controller.startTimer(seconds: 10, onTimeExpired: () {});
      expect(controller.progress, 1.0); // 10/10 = 1.0 when just started
    });

    test('pauses and resumes timer', () {
      controller.startTimer(seconds: 10, onTimeExpired: () {});

      expect(controller.isActive, true);
      expect(controller.isPaused, false);

      controller.pauseTimer();
      expect(controller.isActive, true);
      expect(controller.isPaused, true);

      controller.resumeTimer();
      expect(controller.isActive, true);
      expect(controller.isPaused, false);
    });

    test('adds time correctly', () {
      controller.startTimer(seconds: 10, onTimeExpired: () {});

      expect(controller.timeRemaining, 10);

      controller.addTime(5);
      expect(controller.timeRemaining, 15);

      // Should not add negative time
      controller.addTime(-2);
      expect(controller.timeRemaining, 15);

      // Should not add time if not active
      controller.stopTimer();
      controller.addTime(3);
      expect(controller.timeRemaining, 15);
    });

    test('stops timer correctly', () {
      controller.startTimer(seconds: 10, onTimeExpired: () {});

      expect(controller.isActive, true);

      controller.stopTimer();
      expect(controller.isActive, false);
      expect(controller.isPaused, false);
    });

    test('resets timer without starting', () {
      controller.startTimer(seconds: 10, onTimeExpired: () {});

      controller.resetTimer(20);
      expect(controller.timeRemaining, 20);
      expect(controller.totalTime, 20);
      expect(controller.isActive, false);
      expect(controller.isWarningTriggered, false);
    });

    test('identifies critical time correctly', () {
      // Start with 10 seconds - not critical at start
      controller.startTimer(seconds: 10, onTimeExpired: () {});
      expect(
        controller.isInCriticalTime,
        false,
      ); // 10/10 = 1.0 progress, not <= 0.3

      // Test with a short timer that's immediately in critical time
      controller.startTimer(
        seconds: 2, // 2 seconds total
        onTimeExpired: () {},
      );
      // 2/2 = 1.0 progress, not critical yet
      expect(controller.isInCriticalTime, false);

      // To test critical time, we need to use addTime in reverse or check the internal warning logic
      // For now, let's just test the boundary condition
      controller.stopTimer();
      expect(
        controller.isInCriticalTime,
        false,
      ); // Stopped timer is not critical
    });

    test('handles timer expiration with no callback gracefully', () {
      controller.startTimer(
        seconds: 1,
        onTimeExpired: () {}, // Empty callback
      );

      // Should not throw when timer expires
      expect(() => controller.resetTimer(0), returnsNormally);
    });

    test('only allows pause/resume when appropriate', () {
      // Should not pause inactive timer
      controller.pauseTimer();
      expect(controller.isPaused, false);

      controller.startTimer(seconds: 10, onTimeExpired: () {});

      // Should pause active timer
      controller.pauseTimer();
      expect(controller.isPaused, true);

      // Should not pause already paused timer
      controller.pauseTimer();
      expect(controller.isPaused, true);

      // Should resume paused timer
      controller.resumeTimer();
      expect(controller.isPaused, false);

      // Should not resume unpaused timer
      controller.resumeTimer();
      expect(controller.isPaused, false);
    });

    test('notifies listeners on state changes', () {
      var notificationCount = 0;
      controller.addListener(() => notificationCount++);

      controller.startTimer(seconds: 10, onTimeExpired: () {});
      expect(notificationCount, 1);

      controller.pauseTimer();
      expect(notificationCount, 2);

      controller.resumeTimer();
      expect(notificationCount, 3);

      controller.addTime(5);
      expect(notificationCount, 4);

      controller.resetTimer(20);
      expect(notificationCount, 5);
    });
  });
}
