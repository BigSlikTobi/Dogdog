import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/services/error_service.dart';
import 'package:dogdog_trivia_game/services/progress_service.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/widgets/error_boundary.dart';
import 'package:dogdog_trivia_game/screens/error_recovery_screen.dart';
import 'package:dogdog_trivia_game/utils/retry_mechanism.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('Error Handling Integration Tests', () {
    late ErrorService errorService;
    late ProgressService progressService;

    setUp(() async {
      errorService = ErrorService();
      errorService.clearErrorHistory();

      progressService = ProgressService();
    });

    testWidgets('ErrorBoundary catches and displays errors', (tester) async {
      bool errorCaught = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            onRetry: () {
              errorCaught = true;
            },
            child: Builder(
              builder: (context) {
                throw Exception('Test error');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show error UI
      expect(find.text('Oops! Something went wrong'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Go to Home'), findsOneWidget);

      // Test retry functionality
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(errorCaught, true);
    });

    testWidgets('SafeAsyncBuilder handles async errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeAsyncBuilder<String>(
              future: Future.delayed(
                const Duration(milliseconds: 100),
                () => throw Exception('Async error'),
              ),
              builder: (context, data) => Text(data),
              onRetry: () {},
            ),
          ),
        ),
      );

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Should show error UI after failure
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('ErrorRecoveryScreen displays error details', (tester) async {
      final testError = AppError(
        type: ErrorType.network,
        severity: ErrorSeverity.high,
        message: 'Test network error',
      );

      await tester.pumpWidget(
        MaterialApp(home: ErrorRecoveryScreen(initialError: testError)),
      );

      await tester.pumpAndSettle();

      expect(find.text('System Recovery'), findsOneWidget);
      expect(find.text('Current Error'), findsOneWidget);
      expect(find.text('Recovery Actions'), findsOneWidget);
      expect(find.text('Restart Services'), findsOneWidget);
      expect(find.text('Clear Cache'), findsOneWidget);
      expect(find.text('Reset to Defaults'), findsOneWidget);
    });

    testWidgets('Error history is displayed correctly', (tester) async {
      // Add some test errors
      await errorService.recordError(
        ErrorType.network,
        'Network error 1',
        severity: ErrorSeverity.medium,
      );

      await errorService.recordError(
        ErrorType.storage,
        'Storage error 1',
        severity: ErrorSeverity.high,
      );

      await tester.pumpWidget(MaterialApp(home: const ErrorRecoveryScreen()));

      await tester.pumpAndSettle();

      // Show error history
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Network error 1'), findsOneWidget);
      expect(find.text('Storage error 1'), findsOneWidget);
    });

    test('Service initialization with error handling', () async {
      // Test progress service initialization with error handling
      bool initializationCompleted = false;

      try {
        await progressService.initialize();
        initializationCompleted = true;
      } catch (e) {
        // Should not throw - errors should be handled gracefully
        fail('Service initialization should not throw');
      }

      expect(initializationCompleted, true);
    });

    test('Retry mechanism works with different error types', () async {
      int networkAttempts = 0;
      int storageAttempts = 0;
      int audioAttempts = 0;

      // Test network retry
      final networkResult = await NetworkRetry.execute<String>(() async {
        networkAttempts++;
        throw Exception('Network failure');
      });

      expect(networkResult.success, false);
      expect(networkAttempts, 3); // Network config max attempts

      // Test storage retry
      final storageResult = await StorageRetry.execute<String>(() async {
        storageAttempts++;
        throw Exception('Storage failure');
      });

      expect(storageResult.success, false);
      expect(storageAttempts, 2); // Storage config max attempts

      // Test audio retry
      final audioResult = await AudioRetry.execute<String>(() async {
        audioAttempts++;
        throw Exception('Audio failure');
      });

      expect(audioResult.success, false);
      expect(audioAttempts, 2); // Audio config max attempts
    });

    test('Error service records and categorizes errors correctly', () async {
      // Test different error types
      await errorService.handleNetworkError(Exception('Network timeout'));
      await errorService.handleStorageError(Exception('File not found'));
      await errorService.handleAudioError(Exception('Audio device error'));
      await errorService.handleGameLogicError(Exception('Invalid state'));

      final history = errorService.errorHistory;
      expect(history.length, 4);

      final networkError = history.firstWhere(
        (e) => e.type == ErrorType.network,
      );
      final storageError = history.firstWhere(
        (e) => e.type == ErrorType.storage,
      );
      final audioError = history.firstWhere((e) => e.type == ErrorType.audio);
      final gameError = history.firstWhere(
        (e) => e.type == ErrorType.gameLogic,
      );

      expect(networkError.severity, ErrorSeverity.medium);
      expect(storageError.severity, ErrorSeverity.medium);
      expect(audioError.severity, ErrorSeverity.low);
      expect(gameError.severity, ErrorSeverity.high);
    });

    test('Circuit breaker prevents cascading failures', () async {
      final circuitBreaker = CircuitBreaker(
        name: 'test-service',
        failureThreshold: 2,
      );

      // Cause failures to open circuit
      try {
        await circuitBreaker.execute(
          () async => throw Exception('Service down'),
        );
      } catch (_) {}

      try {
        await circuitBreaker.execute(
          () async => throw Exception('Service down'),
        );
      } catch (_) {}

      expect(circuitBreaker.state, CircuitBreakerState.open);

      // Should now fail fast
      expect(
        () async => await circuitBreaker.execute(() async => 'success'),
        throwsA(isA<CircuitBreakerOpenException>()),
      );
    });

    test('Error service provides appropriate user messages', () {
      final errors = [
        AppError(
          type: ErrorType.network,
          severity: ErrorSeverity.medium,
          message: 'Network',
        ),
        AppError(
          type: ErrorType.storage,
          severity: ErrorSeverity.medium,
          message: 'Storage',
        ),
        AppError(
          type: ErrorType.audio,
          severity: ErrorSeverity.low,
          message: 'Audio',
        ),
        AppError(
          type: ErrorType.gameLogic,
          severity: ErrorSeverity.high,
          message: 'Game',
        ),
        AppError(
          type: ErrorType.unknown,
          severity: ErrorSeverity.medium,
          message: 'Unknown',
        ),
      ];

      for (final error in errors) {
        expect(error.userMessage, isNotEmpty);
        expect(error.recoverySuggestion, isNotEmpty);

        // User messages should be friendly and non-technical
        expect(error.userMessage.toLowerCase(), isNot(contains('exception')));
        expect(error.userMessage.toLowerCase(), isNot(contains('stack')));
        expect(error.userMessage.toLowerCase(), isNot(contains('null')));
      }
    });

    test('Error boundaries work with game controller', () async {
      final gameController = GameController();

      // Simulate error in game controller
      bool errorHandled = false;

      errorService.errorStream.listen((error) {
        if (error.type == ErrorType.gameLogic) {
          errorHandled = true;
        }
      });

      // This should trigger error handling
      try {
        // Simulate an invalid game operation
        gameController.processAnswer(-1); // Invalid answer index
      } catch (_) {
        // Expected to handle gracefully
      }

      // Wait for async error handling
      await Future.delayed(const Duration(milliseconds: 100));

      expect(errorHandled, true);
    });

    testWidgets('App continues functioning after recoverable errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  // Simulate a recoverable error
                  errorService.recordError(
                    ErrorType.audio,
                    'Audio playback failed',
                    severity: ErrorSeverity.low,
                  );

                  return const Center(child: Text('App is working'));
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // App should continue working despite the error
      expect(find.text('App is working'), findsOneWidget);

      // Error should be recorded
      expect(errorService.errorHistory.length, 1);
      expect(errorService.errorHistory.first.type, ErrorType.audio);
    });
  });
}
