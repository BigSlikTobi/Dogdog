import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/utils/retry_mechanism.dart';
import 'package:dogdog_trivia_game/services/error_service.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('RetryMechanism', () {
    setUp(() {
      ErrorService().clearErrorHistory();
    });

    test('should succeed on first attempt', () async {
      final result = await RetryMechanism.execute<String>(
        () async => 'success',
        config: const RetryConfig(maxAttempts: 3),
      );

      expect(result.success, true);
      expect(result.data, 'success');
      expect(result.attempts, 1);
    });

    test('should retry on failure and eventually succeed', () async {
      int attemptCount = 0;

      final result = await RetryMechanism.execute<String>(() async {
        attemptCount++;
        if (attemptCount < 3) {
          throw Exception('Temporary failure');
        }
        return 'success';
      }, config: const RetryConfig(maxAttempts: 3));

      expect(result.success, true);
      expect(result.data, 'success');
      expect(result.attempts, 3);
    });

    test('should fail after max attempts', () async {
      final result = await RetryMechanism.execute<String>(() async {
        throw Exception('Persistent failure');
      }, config: const RetryConfig(maxAttempts: 2));

      expect(result.success, false);
      expect(result.data, null);
      expect(result.attempts, 2);
      expect(result.error, isA<Exception>());
    });

    test('should call retry callback', () async {
      final retryAttempts = <int>[];
      final retryErrors = <Object>[];

      await RetryMechanism.execute<String>(
        () async {
          throw Exception('Test error');
        },
        config: const RetryConfig(maxAttempts: 3),
        onRetry: (attempt, error) {
          retryAttempts.add(attempt);
          retryErrors.add(error);
        },
      );

      expect(retryAttempts, [1, 2]);
      expect(retryErrors.length, 2);
    });

    test('should record errors in ErrorService', () async {
      await RetryMechanism.execute<String>(
        () async {
          throw Exception('Test error for recording');
        },
        config: const RetryConfig(maxAttempts: 2),
        errorType: ErrorType.network,
      );

      final errorHistory = ErrorService().errorHistory;
      expect(errorHistory.length, 2); // One for each attempt
      expect(errorHistory.every((e) => e.type == ErrorType.network), true);
    });
  });

  group('RetryConfig', () {
    test('should have correct default values', () {
      const config = RetryConfig();

      expect(config.maxAttempts, 3);
      expect(config.initialDelay, const Duration(milliseconds: 500));
      expect(config.maxDelay, const Duration(seconds: 10));
      expect(config.backoffMultiplier, 2.0);
    });

    test('should accept custom values', () {
      const config = RetryConfig(
        maxAttempts: 5,
        initialDelay: Duration(milliseconds: 1000),
        maxDelay: Duration(seconds: 30),
        backoffMultiplier: 1.5,
      );

      expect(config.maxAttempts, 5);
      expect(config.initialDelay, const Duration(milliseconds: 1000));
      expect(config.maxDelay, const Duration(seconds: 30));
      expect(config.backoffMultiplier, 1.5);
    });
  });

  group('Predefined Retry Configurations', () {
    test('should have network configuration', () {
      expect(RetryConfigs.network.maxAttempts, 3);
      expect(
        RetryConfigs.network.initialDelay,
        const Duration(milliseconds: 1000),
      );
    });

    test('should have storage configuration', () {
      expect(RetryConfigs.storage.maxAttempts, 2);
      expect(
        RetryConfigs.storage.initialDelay,
        const Duration(milliseconds: 500),
      );
    });

    test('should have audio configuration', () {
      expect(RetryConfigs.audio.maxAttempts, 2);
      expect(
        RetryConfigs.audio.initialDelay,
        const Duration(milliseconds: 200),
      );
    });

    test('should have game logic configuration', () {
      expect(RetryConfigs.gameLogic.maxAttempts, 1);
      expect(
        RetryConfigs.gameLogic.initialDelay,
        const Duration(milliseconds: 100),
      );
    });
  });

  group('CircuitBreaker', () {
    test('should start in closed state', () {
      final circuitBreaker = CircuitBreaker(name: 'test');
      expect(circuitBreaker.state, CircuitBreakerState.closed);
    });

    test('should open after failure threshold', () async {
      final circuitBreaker = CircuitBreaker(name: 'test', failureThreshold: 2);

      // First failure
      try {
        await circuitBreaker.execute(() async => throw Exception('Failure 1'));
      } catch (_) {}

      expect(circuitBreaker.state, CircuitBreakerState.closed);

      // Second failure - should open circuit
      try {
        await circuitBreaker.execute(() async => throw Exception('Failure 2'));
      } catch (_) {}

      expect(circuitBreaker.state, CircuitBreakerState.open);
    });

    test('should throw CircuitBreakerOpenException when open', () async {
      final circuitBreaker = CircuitBreaker(name: 'test', failureThreshold: 1);

      // Cause failure to open circuit
      try {
        await circuitBreaker.execute(() async => throw Exception('Failure'));
      } catch (_) {}

      expect(circuitBreaker.state, CircuitBreakerState.open);

      // Should now throw CircuitBreakerOpenException
      expect(
        () async => await circuitBreaker.execute(() async => 'success'),
        throwsA(isA<CircuitBreakerOpenException>()),
      );
    });

    test('should reset on success', () async {
      final circuitBreaker = CircuitBreaker(name: 'test', failureThreshold: 1);

      // Cause failure
      try {
        await circuitBreaker.execute(() async => throw Exception('Failure'));
      } catch (_) {}

      expect(circuitBreaker.state, CircuitBreakerState.open);

      // Reset manually
      circuitBreaker.reset();
      expect(circuitBreaker.state, CircuitBreakerState.closed);

      // Should work again
      final result = await circuitBreaker.execute(() async => 'success');
      expect(result, 'success');
    });
  });

  group('Extension Methods', () {
    test('NetworkRetry should use network configuration', () async {
      final result = await NetworkRetry.execute<String>(
        () async => 'network success',
      );

      expect(result.success, true);
      expect(result.data, 'network success');
    });

    test('StorageRetry should use storage configuration', () async {
      final result = await StorageRetry.execute<String>(
        () async => 'storage success',
      );

      expect(result.success, true);
      expect(result.data, 'storage success');
    });

    test('AudioRetry should use audio configuration', () async {
      final result = await AudioRetry.execute<String>(
        () async => 'audio success',
      );

      expect(result.success, true);
      expect(result.data, 'audio success');
    });

    test('GameLogicRetry should use game logic configuration', () async {
      final result = await GameLogicRetry.execute<String>(
        () async => 'game logic success',
      );

      expect(result.success, true);
      expect(result.data, 'game logic success');
    });
  });
}
