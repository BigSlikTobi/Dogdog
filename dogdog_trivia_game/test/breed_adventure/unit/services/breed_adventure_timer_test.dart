import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

import 'package:dogdog_trivia_game/services/breed_adventure/breed_adventure_timer.dart';

void main() {
  group('BreedAdventureTimer', () {
    late BreedAdventureTimer timer;

    setUp(() {
      timer = BreedAdventureTimer.forTesting();
    });

    tearDown(() {
      if (timer.isRunning) {
        timer.stop();
      }
      timer.dispose();
    });

    group('Initialization', () {
      test('should initialize with correct default state', () {
        expect(timer.isRunning, isFalse);
        expect(timer.isPaused, isFalse);
        expect(timer.remainingSeconds, equals(0));
        expect(timer.state, equals(TimerState.inactive));
      });

      test('should provide timer stream', () {
        expect(timer.timerStream, isA<Stream<int>>());
      });
    });

    group('Timer Control', () {
      test('should start timer with specified duration', () async {
        timer.start(duration: 10);

        expect(timer.isRunning, isTrue);
        expect(timer.remainingSeconds, equals(10));

        await Future.delayed(const Duration(milliseconds: 1100));
        expect(timer.remainingSeconds, lessThan(10));
      });

      test('should start timer with default duration', () {
        timer.start();

        expect(timer.isRunning, isTrue);
        expect(timer.remainingSeconds, equals(10)); // Default duration
      });

      test('should stop timer', () async {
        timer.start(duration: 10);
        expect(timer.isRunning, isTrue);

        timer.stop();
        expect(timer.isRunning, isFalse);
        expect(timer.isActive, isFalse);
      });

      test('should pause and resume timer', () async {
        timer.start(duration: 10);
        await Future.delayed(const Duration(milliseconds: 1100));

        final timeBeforePause = timer.remainingSeconds;
        timer.pause();
        expect(timer.isPaused, isTrue);
        expect(timer.state, equals(TimerState.paused));

        await Future.delayed(const Duration(milliseconds: 1100));
        expect(timer.remainingSeconds, equals(timeBeforePause));

        timer.resume();
        expect(timer.isPaused, isFalse);
        expect(timer.isRunning, isTrue);
      });

      test('should reset timer', () {
        timer.start(duration: 10);
        timer.reset(duration: 15);

        expect(timer.isActive, isFalse);
        expect(timer.remainingSeconds, equals(15));
      });
    });

    group('Time Management', () {
      test('should add time to running timer', () async {
        timer.start(duration: 10);
        await Future.delayed(const Duration(milliseconds: 100));

        final timeBefore = timer.remainingSeconds;
        timer.addTime(5);

        expect(timer.remainingSeconds, equals(timeBefore + 5));
      });

      test('should handle maximum time limit when adding time', () {
        timer.start(duration: 25);
        timer.addTime(10);

        expect(timer.remainingSeconds, equals(30)); // Max allowed
      });

      test('should throw error when adding time to inactive timer', () {
        expect(() => timer.addTime(5), throwsStateError);
      });

      test('should throw error when adding negative time', () {
        timer.start(duration: 10);
        expect(() => timer.addTime(-5), throwsArgumentError);
      });
    });

    group('Timer States', () {
      test('should detect normal state', () {
        timer.start(duration: 10);
        expect(timer.state, equals(TimerState.normal));
      });

      test('should detect warning state', () {
        timer.start(duration: 5);
        expect(timer.state, equals(TimerState.warning));
      });

      test('should detect critical state', () {
        timer.start(duration: 3);
        expect(timer.state, equals(TimerState.critical));
      });

      test('should detect inactive state', () {
        expect(timer.state, equals(TimerState.inactive));
      });

      test('should track timer expiration', () async {
        timer.start(duration: 1);

        await Future.delayed(const Duration(milliseconds: 1100));

        expect(timer.hasExpired, isTrue);
        expect(timer.remainingSeconds, equals(0));
        expect(timer.state, equals(TimerState.expired));
      });
    });

    group('Timer Events', () {
      test('should emit timer updates through stream', () async {
        final updates = <int>[];
        late StreamSubscription subscription;

        subscription = timer.timerStream.listen((time) {
          updates.add(time);
          if (updates.length >= 3) {
            subscription.cancel();
          }
        });

        timer.start(duration: 5);

        await Future.delayed(const Duration(milliseconds: 2100));

        expect(updates, isNotEmpty);
        expect(updates.first, equals(5));
        expect(updates.last, lessThan(5));
      });

      test('should complete when timer reaches zero', () async {
        timer.timerStream.listen((time) {}, onDone: () {});

        timer.start(duration: 1);

        await Future.delayed(const Duration(milliseconds: 1500));

        expect(timer.isRunning, isFalse);
        expect(timer.remainingSeconds, equals(0));
      });
    });

    group('Progress Tracking', () {
      test('should calculate elapsed time correctly', () async {
        timer.start(duration: 10);

        await Future.delayed(const Duration(milliseconds: 1100));

        final elapsed = timer.getElapsedTime(originalDuration: 10);
        expect(elapsed, greaterThan(0));
        expect(elapsed, lessThanOrEqualTo(10));
      });

      test('should calculate progress correctly', () async {
        timer.start(duration: 10);

        await Future.delayed(const Duration(milliseconds: 1100));

        final progress = timer.getProgress(originalDuration: 10);
        expect(progress, greaterThan(0.0));
        expect(progress, lessThanOrEqualTo(1.0));
      });

      test('should return zero elapsed time for inactive timer', () {
        final elapsed = timer.getElapsedTime();
        expect(elapsed, equals(0));
      });

      test('should return zero progress for inactive timer', () {
        final progress = timer.getProgress();
        expect(progress, equals(0.0));
      });
    });

    group('Edge Cases', () {
      test('should handle rapid start/stop cycles', () {
        for (int i = 0; i < 10; i++) {
          timer.start(duration: 5);
          timer.stop();
        }

        expect(timer.isRunning, isFalse);
        expect(timer.isActive, isFalse);
      });

      test('should handle pause/resume without start', () {
        timer.pause();
        expect(timer.isPaused, isFalse);

        timer.resume();
        expect(timer.isRunning, isFalse);
      });

      test('should handle multiple pause calls', () {
        timer.start(duration: 10);
        timer.pause();
        timer.pause();

        expect(timer.isPaused, isTrue);

        timer.resume();
        expect(timer.isRunning, isTrue);
      });

      test('should handle multiple resume calls', () {
        timer.start(duration: 10);
        timer.pause();
        timer.resume();
        timer.resume();

        expect(timer.isRunning, isTrue);
        expect(timer.isPaused, isFalse);
      });

      test('should handle invalid duration arguments', () {
        expect(() => timer.start(duration: -1), throwsArgumentError);
        expect(() => timer.start(duration: 50), throwsArgumentError);
        expect(() => timer.reset(duration: -1), throwsArgumentError);
        expect(() => timer.reset(duration: 50), throwsArgumentError);
      });
    });

    group('State Consistency', () {
      test('should maintain consistent state during operations', () async {
        timer.start(duration: 10);
        expect(timer.isRunning, isTrue);
        expect(timer.isPaused, isFalse);
        expect(timer.isActive, isTrue);

        timer.pause();
        expect(timer.isRunning, isFalse);
        expect(timer.isPaused, isTrue);
        expect(timer.isActive, isTrue);

        timer.resume();
        expect(timer.isRunning, isTrue);
        expect(timer.isPaused, isFalse);
        expect(timer.isActive, isTrue);

        timer.stop();
        expect(timer.isRunning, isFalse);
        expect(timer.isPaused, isFalse);
        expect(timer.isActive, isFalse);
      });

      test('should handle timer completion gracefully', () async {
        timer.start(duration: 1);

        await Future.delayed(const Duration(milliseconds: 1500));

        expect(timer.isRunning, isFalse);
        expect(timer.isPaused, isFalse);
        expect(timer.isActive, isTrue); // Still active but expired
        expect(timer.hasExpired, isTrue);
        expect(timer.remainingSeconds, equals(0));
      });
    });

    group('State Properties', () {
      test('should correctly identify warning states', () {
        timer.start(duration: 4);
        expect(timer.isWarning, isTrue);
        expect(timer.isCritical, isFalse);
      });

      test('should correctly identify critical states', () {
        timer.start(duration: 2);
        expect(timer.isCritical, isTrue);
        expect(timer.isWarning, isFalse);
      });

      test('should handle boundary conditions', () {
        timer.start(duration: 5);
        expect(timer.isWarning, isTrue);

        timer.reset(duration: 3);
        timer.start(duration: 3);
        expect(timer.isCritical, isTrue);
      });
    });

    group('Performance', () {
      test('should handle high frequency operations efficiently', () async {
        timer.start(duration: 5);

        // Rapid pause/resume cycles
        for (int i = 0; i < 10; i++) {
          timer.pause();
          timer.resume();
        }

        expect(timer.isRunning, isTrue);
        expect(timer.isPaused, isFalse);
      });

      test('should dispose cleanly', () {
        timer.start(duration: 10);
        expect(timer.isRunning, isTrue);

        timer.dispose();

        // After disposal, timer should be stopped
        expect(timer.isRunning, isFalse);
        expect(timer.isActive, isFalse);
      });
    });
  });

  group('TimerState Extension', () {
    test('should provide correct color names', () {
      expect(TimerState.inactive.colorName, equals('grey'));
      expect(TimerState.normal.colorName, equals('green'));
      expect(TimerState.warning.colorName, equals('orange'));
      expect(TimerState.critical.colorName, equals('red'));
      expect(TimerState.expired.colorName, equals('darkRed'));
      expect(TimerState.paused.colorName, equals('blue'));
    });

    test('should provide correct display names', () {
      expect(TimerState.inactive.displayName, equals('Inactive'));
      expect(TimerState.normal.displayName, equals('Normal'));
      expect(TimerState.warning.displayName, equals('Warning'));
      expect(TimerState.critical.displayName, equals('Critical'));
      expect(TimerState.expired.displayName, equals('Expired'));
      expect(TimerState.paused.displayName, equals('Paused'));
    });

    test('should correctly identify urgent states', () {
      expect(TimerState.critical.isUrgent, isTrue);
      expect(TimerState.expired.isUrgent, isTrue);
      expect(TimerState.warning.isUrgent, isFalse);
      expect(TimerState.normal.isUrgent, isFalse);
    });

    test('should correctly identify active states', () {
      expect(TimerState.normal.isActive, isTrue);
      expect(TimerState.warning.isActive, isTrue);
      expect(TimerState.critical.isActive, isTrue);
      expect(TimerState.expired.isActive, isTrue);
      expect(TimerState.paused.isActive, isTrue);
      expect(TimerState.inactive.isActive, isFalse);
    });
  });
}
