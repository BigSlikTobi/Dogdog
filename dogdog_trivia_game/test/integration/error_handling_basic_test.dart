import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/services/error_service.dart';
import 'package:dogdog_trivia_game/utils/retry_mechanism.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('Error Handling Integration - Basic Tests', () {
    setUp(() {
      ErrorService().clearErrorHistory();
    });

    test('ErrorService can record and retrieve errors', () async {
      final errorService = ErrorService();

      await errorService.recordError(
        ErrorType.network,
        'Test network error',
        severity: ErrorSeverity.medium,
      );

      expect(errorService.errorHistory.length, 1);
      final error = errorService.errorHistory.first;
      expect(error.type, ErrorType.network);
      expect(error.severity, ErrorSeverity.medium);
      expect(error.message, 'Test network error');
    });

    test('RetryMechanism can execute operations with retry', () async {
      int attemptCount = 0;

      final result = await RetryMechanism.execute<String>(() async {
        attemptCount++;
        if (attemptCount < 2) {
          throw Exception('Temporary failure');
        }
        return 'success';
      }, config: const RetryConfig(maxAttempts: 3));

      expect(result.success, true);
      expect(result.data, 'success');
      expect(attemptCount, 2);
    });

    test('NetworkRetry extension works', () async {
      final result = await NetworkRetry.execute<String>(
        () async => 'network success',
      );

      expect(result.success, true);
      expect(result.data, 'network success');
    });

    test('AppError provides user-friendly messages', () {
      final error = AppError(
        type: ErrorType.network,
        severity: ErrorSeverity.medium,
        message: 'Network failed',
      );

      expect(error.userMessage, contains('Connection problem'));
      expect(error.recoverySuggestion, contains('internet connection'));
    });

    test('Circuit breaker opens after failures', () async {
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
  });
}
