import 'dart:async';
import 'dart:math';
import '../models/enums.dart';
import '../services/error_service.dart';

/// Configuration for retry behavior
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final List<Type> retryableExceptions;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 10),
    this.backoffMultiplier = 2.0,
    this.retryableExceptions = const [],
  });
}

/// Predefined retry configurations for different operation types
class RetryConfigs {
  static const network = RetryConfig(
    maxAttempts: 3,
    initialDelay: Duration(milliseconds: 1000),
    maxDelay: Duration(seconds: 30),
    backoffMultiplier: 2.0,
  );

  static const storage = RetryConfig(
    maxAttempts: 2,
    initialDelay: Duration(milliseconds: 500),
    maxDelay: Duration(seconds: 5),
    backoffMultiplier: 1.5,
  );

  static const audio = RetryConfig(
    maxAttempts: 2,
    initialDelay: Duration(milliseconds: 200),
    maxDelay: Duration(seconds: 2),
    backoffMultiplier: 1.5,
  );

  static const gameLogic = RetryConfig(
    maxAttempts: 1,
    initialDelay: Duration(milliseconds: 100),
    maxDelay: Duration(seconds: 1),
    backoffMultiplier: 1.0,
  );
}

/// Result of a retry operation
class RetryResult<T> {
  final bool success;
  final T? data;
  final Object? error;
  final int attempts;

  RetryResult({
    required this.success,
    this.data,
    this.error,
    required this.attempts,
  });
}

/// Main retry mechanism class
class RetryMechanism {
  /// Executes an operation with retry logic
  static Future<RetryResult<T>> execute<T>(
    Future<T> Function() operation, {
    RetryConfig config = const RetryConfig(),
    ErrorType? errorType,
    Function(int attempt, Object error)? onRetry,
  }) async {
    Object? lastError;
    int attempt = 0;

    while (attempt < config.maxAttempts) {
      try {
        final result = await operation();
        return RetryResult<T>(
          success: true,
          data: result,
          attempts: attempt + 1,
        );
      } catch (error) {
        lastError = error;
        attempt++;

        // Record error if error type is specified
        if (errorType != null) {
          ErrorService().recordError(
            errorType,
            'Retry attempt $attempt failed: ${error.toString()}',
            severity: attempt == config.maxAttempts
                ? ErrorSeverity.high
                : ErrorSeverity.low,
            originalError: error,
          );
        }

        // Call retry callback if provided
        if (onRetry != null && attempt < config.maxAttempts) {
          onRetry(attempt, error);
        }

        // Don't delay after the last attempt
        if (attempt >= config.maxAttempts) {
          break;
        }

        // Calculate delay with exponential backoff
        final delay = _calculateDelay(config, attempt);
        await Future.delayed(delay);
      }
    }

    return RetryResult<T>(success: false, error: lastError, attempts: attempt);
  }

  /// Calculates the delay for the next retry attempt
  static Duration _calculateDelay(RetryConfig config, int attempt) {
    final delayMs =
        config.initialDelay.inMilliseconds *
        pow(config.backoffMultiplier, attempt - 1);

    final cappedDelayMs = min(delayMs.toInt(), config.maxDelay.inMilliseconds);

    // Add jitter to prevent thundering herd
    final jitter = Random().nextInt(100);

    return Duration(milliseconds: cappedDelayMs + jitter);
  }
}

/// Circuit breaker states
enum CircuitBreakerState { closed, open, halfOpen }

/// Exception thrown when circuit breaker is open
class CircuitBreakerOpenException implements Exception {
  final String message;

  CircuitBreakerOpenException(this.message);

  @override
  String toString() => 'CircuitBreakerOpenException: $message';
}

/// Circuit breaker implementation to prevent cascading failures
class CircuitBreaker {
  final String name;
  final int failureThreshold;
  final Duration timeout;
  final Duration halfOpenRetryDelay;

  CircuitBreakerState _state = CircuitBreakerState.closed;
  int _failureCount = 0;
  DateTime? _nextRetryTime;

  CircuitBreaker({
    required this.name,
    this.failureThreshold = 5,
    this.timeout = const Duration(minutes: 1),
    this.halfOpenRetryDelay = const Duration(seconds: 30),
  });

  CircuitBreakerState get state => _state;

  /// Executes an operation through the circuit breaker
  Future<T> execute<T>(Future<T> Function() operation) async {
    if (_state == CircuitBreakerState.open) {
      if (_shouldAttemptReset()) {
        _state = CircuitBreakerState.halfOpen;
      } else {
        throw CircuitBreakerOpenException('Circuit breaker is open for $name');
      }
    }

    try {
      final result = await operation();
      _onSuccess();
      return result;
    } catch (error) {
      _onFailure();
      rethrow;
    }
  }

  /// Handles successful operations
  void _onSuccess() {
    _failureCount = 0;
    _state = CircuitBreakerState.closed;
    _nextRetryTime = null;
  }

  /// Handles failed operations
  void _onFailure() {
    _failureCount++;

    if (_failureCount >= failureThreshold) {
      _state = CircuitBreakerState.open;
      _nextRetryTime = DateTime.now().add(halfOpenRetryDelay);
    }
  }

  /// Checks if we should attempt to reset the circuit breaker
  bool _shouldAttemptReset() {
    final nextRetryTime = _nextRetryTime;
    return nextRetryTime != null && DateTime.now().isAfter(nextRetryTime);
  }

  /// Resets the circuit breaker manually
  void reset() {
    _state = CircuitBreakerState.closed;
    _failureCount = 0;
    _nextRetryTime = null;
  }
}

/// Extension methods for easy retry integration
extension NetworkRetry on Object {
  static Future<RetryResult<T>> execute<T>(
    Future<T> Function() operation, {
    Function(int attempt, Object error)? onRetry,
  }) => RetryMechanism.execute<T>(
    operation,
    config: RetryConfigs.network,
    errorType: ErrorType.network,
    onRetry: onRetry,
  );
}

extension StorageRetry on Object {
  static Future<RetryResult<T>> execute<T>(
    Future<T> Function() operation, {
    Function(int attempt, Object error)? onRetry,
  }) => RetryMechanism.execute<T>(
    operation,
    config: RetryConfigs.storage,
    errorType: ErrorType.storage,
    onRetry: onRetry,
  );
}

extension AudioRetry on Object {
  static Future<RetryResult<T>> execute<T>(
    Future<T> Function() operation, {
    Function(int attempt, Object error)? onRetry,
  }) => RetryMechanism.execute<T>(
    operation,
    config: RetryConfigs.audio,
    errorType: ErrorType.audio,
    onRetry: onRetry,
  );
}

extension GameLogicRetry on Object {
  static Future<RetryResult<T>> execute<T>(
    Future<T> Function() operation, {
    Function(int attempt, Object error)? onRetry,
  }) => RetryMechanism.execute<T>(
    operation,
    config: RetryConfigs.gameLogic,
    errorType: ErrorType.gameLogic,
    onRetry: onRetry,
  );
}
