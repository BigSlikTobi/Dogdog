import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/services/breed_adventure_timer.dart';

void main() {
  group('BreedAdventureTimer Tests', () {
    late BreedAdventureTimer timer;

    setUp(() {
      timer = BreedAdventureTimer.forTesting();
    });

    tearDown(() {
      timer.dispose();
    });

    group('Initialization and Basic Properties', () {
      test('should initialize with correct default values', () {
        expect(timer.remainingSeconds, equals(0));
        expect(timer.isActive, isFalse);
        expect(timer.isPaused, isFalse);
        expect(timer.isRunning, isFalse);
        expect(timer.hasExpired, isFalse);
        expect(timer.state, equals(TimerState.inactive));
      });

      test('should provide timer stream', () {
        expect(timer.timerStream, isA<Stream<int>>());
      });

      test('should have correct configuration constants', () {
        expect(BreedAdventureTimer.defaultDuration, equals(10));
        expect(BreedAdventureTimer.extraTimeBonus, equals(5));
        expect(BreedAdventureTimer.minTimeRemaining, equals(0));
        expect(BreedAdventureTimer.maxTimeAllowed, equals(30));
      });
    });

    group('Timer Start and Stop', () {
      test('should start timer with default duration', () {
        timer.start();

        expect(timer.remainingSeconds, equals(10));
        expect(timer.isActive, isTrue);
        expect(timer.isPaused, isFalse);
        expect(timer.isRunning, isTrue);
        expect(timer.state, equals(TimerState.normal));
      });

      test('should start timer with custom duration', () {
        timer.start(duration: 15);

        expect(timer.remainingSeconds, equals(15));
        expect(timer.isActive, isTrue);
        expect(timer.isRunning, isTrue);
      });

      test('should stop timer properly', () {
        timer.start();
        timer.stop();

        expect(timer.isActive, isFalse);
        expect(timer.isPaused, isFalse);
        expect(timer.isRunning, isFalse);
        expect(timer.state, equals(TimerState.inactive));
      });

      test('should handle multiple starts by stopping previous timer', () {
        timer.start(duration: 5);
        expect(timer.remainingSeconds, equals(5));

        timer.start(duration: 8);
        expect(timer.remainingSeconds, equals(8));
        expect(timer.isActive, isTrue);
      });

      test('should throw error for negative duration', () {
        expect(() => timer.start(duration: -1), throwsA(isA<ArgumentError>()));
      });

      test('should throw error for duration exceeding maximum', () {
        expect(() => timer.start(duration: 35), throwsA(isA<ArgumentError>()));
      });
    });

    group('Timer Reset', () {
      test('should reset timer with default duration', () {
        timer.start();
        timer.reset();

        expect(timer.remainingSeconds, equals(10));
        expect(timer.isActive, isFalse);
        expect(timer.state, equals(TimerState.inactive));
      });

      test('should reset timer with custom duration', () {
        timer.start(duration: 5);
        timer.reset(duration: 8);

        expect(timer.remainingSeconds, equals(8));
        expect(timer.isActive, isFalse);
      });

      test('should throw error for negative reset duration', () {
        expect(() => timer.reset(duration: -1), throwsA(isA<ArgumentError>()));
      });

      test('should throw error for reset duration exceeding maximum', () {
        expect(() => timer.reset(duration: 35), throwsA(isA<ArgumentError>()));
      });
    });

    group('Pause and Resume', () {
      test('should pause active timer', () {
        timer.start();
        timer.pause();

        expect(timer.isActive, isTrue);
        expect(timer.isPaused, isTrue);
        expect(timer.isRunning, isFalse);
        expect(timer.state, equals(TimerState.paused));
      });

      test('should resume paused timer', () {
        timer.start();
        timer.pause();
        timer.resume();

        expect(timer.isActive, isTrue);
        expect(timer.isPaused, isFalse);
        expect(timer.isRunning, isTrue);
      });

      test('should not pause inactive timer', () {
        timer.pause();

        expect(timer.isActive, isFalse);
        expect(timer.isPaused, isFalse);
      });

      test('should not resume non-paused timer', () {
        timer.start();
        timer.resume(); // Should not change state

        expect(timer.isActive, isTrue);
        expect(timer.isPaused, isFalse);
        expect(timer.isRunning, isTrue);
      });

      test('should not resume inactive timer', () {
        timer.resume();

        expect(timer.isActive, isFalse);
        expect(timer.isPaused, isFalse);
      });
    });

    group('Add Time (Extra Time Power-up)', () {
      test('should add time to active timer', () {
        timer.start(duration: 5);
        timer.addTime(3);

        expect(timer.remainingSeconds, equals(8));
      });

      test('should add extra time bonus correctly', () {
        timer.start();
        timer.addTime(BreedAdventureTimer.extraTimeBonus);

        expect(timer.remainingSeconds, equals(15));
      });

      test('should cap time at maximum allowed', () {
        timer.start(duration: 28);
        timer.addTime(5);

        expect(
          timer.remainingSeconds,
          equals(BreedAdventureTimer.maxTimeAllowed),
        );
      });

      test('should throw error when adding time to inactive timer', () {
        expect(() => timer.addTime(5), throwsA(isA<StateError>()));
      });

      test('should throw error for negative time addition', () {
        timer.start();

        expect(() => timer.addTime(-1), throwsA(isA<ArgumentError>()));
      });
    });

    group('Timer States', () {
      test('should return normal state for timer > 5 seconds', () {
        timer.start(duration: 8);

        expect(timer.state, equals(TimerState.normal));
        expect(timer.isCritical, isFalse);
        expect(timer.isWarning, isFalse);
      });

      test('should return warning state for timer 3-5 seconds', () {
        timer.start(duration: 4);

        expect(timer.state, equals(TimerState.warning));
        expect(timer.isWarning, isTrue);
        expect(timer.isCritical, isFalse);
      });

      test('should return critical state for timer 1-3 seconds', () {
        timer.start(duration: 2);

        expect(timer.state, equals(TimerState.critical));
        expect(timer.isCritical, isTrue);
        expect(timer.isWarning, isFalse);
      });

      test('should return expired state for timer at 0', () {
        timer.start(duration: 0);

        expect(timer.state, equals(TimerState.expired));
        expect(timer.hasExpired, isTrue);
      });

      test('should return paused state when paused', () {
        timer.start();
        timer.pause();

        expect(timer.state, equals(TimerState.paused));
      });

      test('should return inactive state when not active', () {
        expect(timer.state, equals(TimerState.inactive));
      });
    });

    group('Progress and Elapsed Time', () {
      test('should calculate elapsed time correctly', () {
        timer.start(duration: 10);

        expect(timer.getElapsedTime(), equals(0));
        expect(timer.getElapsedTime(originalDuration: 10), equals(0));
      });

      test('should calculate progress correctly', () {
        timer.start(duration: 10);

        expect(timer.getProgress(originalDuration: 10), equals(0.0));
      });

      test('should handle zero original duration in progress calculation', () {
        timer.start(duration: 5);

        expect(timer.getProgress(originalDuration: 0), equals(1.0));
      });

      test('should return zero elapsed time for inactive timer', () {
        expect(timer.getElapsedTime(), equals(0));
        expect(timer.getProgress(), equals(0.0));
      });

      test('should clamp progress between 0.0 and 1.0', () {
        timer.start(duration: 15);

        final progress = timer.getProgress(originalDuration: 10);
        expect(progress, greaterThanOrEqualTo(0.0));
        expect(progress, lessThanOrEqualTo(1.0));
      });
    });

    group('Timer Stream', () {
      test('should emit initial value when timer starts', () async {
        final streamValues = <int>[];
        final subscription = timer.timerStream.listen(streamValues.add);

        timer.start(duration: 5);

        // Wait a bit for the stream to emit
        await Future.delayed(const Duration(milliseconds: 10));

        expect(streamValues, contains(5));

        await subscription.cancel();
      });

      test('should emit values when time is added', () async {
        final streamValues = <int>[];
        final subscription = timer.timerStream.listen(streamValues.add);

        timer.start(duration: 5);
        await Future.delayed(const Duration(milliseconds: 10));

        timer.addTime(3);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(streamValues, contains(5));
        expect(streamValues, contains(8));

        await subscription.cancel();
      });

      test('should emit values when timer is reset', () async {
        final streamValues = <int>[];
        final subscription = timer.timerStream.listen(streamValues.add);

        timer.start(duration: 5);
        await Future.delayed(const Duration(milliseconds: 10));

        timer.reset(duration: 8);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(streamValues, contains(5));
        expect(streamValues, contains(8));

        await subscription.cancel();
      });

      test('should handle multiple stream listeners', () async {
        final streamValues1 = <int>[];
        final streamValues2 = <int>[];

        final subscription1 = timer.timerStream.listen(streamValues1.add);
        final subscription2 = timer.timerStream.listen(streamValues2.add);

        timer.start(duration: 3);
        await Future.delayed(const Duration(milliseconds: 10));

        expect(streamValues1, contains(3));
        expect(streamValues2, contains(3));

        await subscription1.cancel();
        await subscription2.cancel();
      });
    });

    group('Timer Countdown Integration', () {
      test('should countdown properly over time', () async {
        timer.start(duration: 3);

        expect(timer.remainingSeconds, equals(3));

        // Wait for countdown
        await Future.delayed(const Duration(milliseconds: 1100));
        expect(timer.remainingSeconds, equals(2));

        await Future.delayed(const Duration(milliseconds: 1000));
        expect(timer.remainingSeconds, equals(1));

        await Future.delayed(const Duration(milliseconds: 1000));
        expect(timer.remainingSeconds, equals(0));
        expect(timer.hasExpired, isTrue);
      });

      test('should emit countdown values through stream', () async {
        final streamValues = <int>[];
        final subscription = timer.timerStream.listen(streamValues.add);

        timer.start(duration: 2);

        // Wait for countdown to complete
        await Future.delayed(const Duration(milliseconds: 2200));

        expect(streamValues, contains(2));
        expect(streamValues, contains(1));
        expect(streamValues, contains(0));

        await subscription.cancel();
      });

      test('should not countdown when paused', () async {
        timer.start(duration: 3);

        await Future.delayed(const Duration(milliseconds: 500));
        timer.pause();

        final remainingBeforePause = timer.remainingSeconds;

        await Future.delayed(const Duration(milliseconds: 1500));

        expect(timer.remainingSeconds, equals(remainingBeforePause));
        expect(timer.isPaused, isTrue);
      });

      test('should resume countdown after pause', () async {
        timer.start(duration: 3);

        await Future.delayed(const Duration(milliseconds: 1100));
        expect(timer.remainingSeconds, equals(2));

        timer.pause();
        await Future.delayed(const Duration(milliseconds: 500));

        timer.resume();
        await Future.delayed(const Duration(milliseconds: 1100));

        expect(timer.remainingSeconds, equals(1));
      });
    });

    group('Disposal and Cleanup', () {
      test('should dispose properly', () {
        timer.start();
        timer.dispose();

        expect(timer.isActive, isFalse);
        expect(timer.isPaused, isFalse);
      });

      test('should handle multiple dispose calls', () {
        timer.start();
        timer.dispose();
        timer.dispose(); // Should not throw

        expect(timer.isActive, isFalse);
      });
    });

    group('Singleton Pattern', () {
      test('should return same instance', () {
        final instance1 = BreedAdventureTimer.instance;
        final instance2 = BreedAdventureTimer.instance;

        expect(identical(instance1, instance2), isTrue);
      });

      test('should reset instance for testing', () {
        final originalInstance = BreedAdventureTimer.instance;
        originalInstance.resetInstance();

        final newInstance = BreedAdventureTimer.instance;
        expect(identical(originalInstance, newInstance), isFalse);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle zero duration start', () {
        timer.start(duration: 0);

        expect(timer.remainingSeconds, equals(0));
        expect(timer.isActive, isTrue);
        expect(timer.hasExpired, isTrue);
        expect(timer.state, equals(TimerState.expired));
      });

      test('should handle maximum duration start', () {
        timer.start(duration: BreedAdventureTimer.maxTimeAllowed);

        expect(
          timer.remainingSeconds,
          equals(BreedAdventureTimer.maxTimeAllowed),
        );
        expect(timer.isActive, isTrue);
      });

      test('should handle adding zero time', () {
        timer.start(duration: 5);
        timer.addTime(0);

        expect(timer.remainingSeconds, equals(5));
      });

      test('should handle pause/resume on expired timer', () {
        timer.start(duration: 0);

        timer.pause();
        expect(timer.state, equals(TimerState.paused));

        timer.resume();
        expect(timer.hasExpired, isTrue);
      });
    });
  });

  group('TimerState Extension Tests', () {
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

    test('should identify urgent states correctly', () {
      expect(TimerState.critical.isUrgent, isTrue);
      expect(TimerState.expired.isUrgent, isTrue);
      expect(TimerState.warning.isUrgent, isFalse);
      expect(TimerState.normal.isUrgent, isFalse);
      expect(TimerState.inactive.isUrgent, isFalse);
      expect(TimerState.paused.isUrgent, isFalse);
    });

    test('should identify active states correctly', () {
      expect(TimerState.normal.isActive, isTrue);
      expect(TimerState.warning.isActive, isTrue);
      expect(TimerState.critical.isActive, isTrue);
      expect(TimerState.expired.isActive, isTrue);
      expect(TimerState.paused.isActive, isTrue);
      expect(TimerState.inactive.isActive, isFalse);
    });
  });
}
