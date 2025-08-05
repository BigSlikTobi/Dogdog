import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/services/error_service.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('ErrorService', () {
    late ErrorService errorService;

    setUp(() {
      errorService = ErrorService();
      errorService.clearErrorHistory();
    });

    test('should record error correctly', () async {
      await errorService.recordError(
        ErrorType.network,
        'Test network error',
        severity: ErrorSeverity.medium,
      );

      expect(errorService.errorHistory.length, 1);
      final error = errorService.errorHistory.first;
      expect(error.type, ErrorType.network);
      expect(error.message, 'Test network error');
      expect(error.severity, ErrorSeverity.medium);
    });

    test('should limit error history size', () async {
      // Add more errors than the maximum
      for (int i = 0; i < 60; i++) {
        await errorService.recordError(ErrorType.unknown, 'Error $i');
      }

      expect(errorService.errorHistory.length, 50); // maxErrorHistory
    });

    test('should provide correct user messages for different error types', () {
      final networkError = AppError(
        type: ErrorType.network,
        severity: ErrorSeverity.medium,
        message: 'Network failed',
      );

      final storageError = AppError(
        type: ErrorType.storage,
        severity: ErrorSeverity.medium,
        message: 'Storage failed',
      );

      final audioError = AppError(
        type: ErrorType.audio,
        severity: ErrorSeverity.low,
        message: 'Audio failed',
      );

      expect(networkError.userMessage, contains('Connection problem'));
      expect(storageError.userMessage, contains('Unable to save'));
      expect(audioError.userMessage, contains('Audio playback issue'));
    });

    test('should provide recovery suggestions', () {
      final networkError = AppError(
        type: ErrorType.network,
        severity: ErrorSeverity.medium,
        message: 'Network failed',
      );

      final gameError = AppError(
        type: ErrorType.gameLogic,
        severity: ErrorSeverity.high,
        message: 'Game failed',
      );

      expect(networkError.recoverySuggestion, contains('internet connection'));
      expect(gameError.recoverySuggestion, contains('Restart'));
    });

    test('should handle network errors specifically', () async {
      final exception = Exception('Connection timeout');

      await errorService.handleNetworkError(exception);

      expect(errorService.errorHistory.length, 1);
      final error = errorService.errorHistory.first;
      expect(error.type, ErrorType.network);
      expect(error.severity, ErrorSeverity.medium);
    });

    test('should handle storage errors specifically', () async {
      final exception = Exception('File not found');

      await errorService.handleStorageError(exception);

      expect(errorService.errorHistory.length, 1);
      final error = errorService.errorHistory.first;
      expect(error.type, ErrorType.storage);
      expect(error.severity, ErrorSeverity.medium);
    });

    test('should handle audio errors with low severity', () async {
      final exception = Exception('Audio device not found');

      await errorService.handleAudioError(exception);

      expect(errorService.errorHistory.length, 1);
      final error = errorService.errorHistory.first;
      expect(error.type, ErrorType.audio);
      expect(error.severity, ErrorSeverity.low);
    });

    test('should handle game logic errors with high severity', () async {
      final exception = Exception('Invalid game state');

      await errorService.handleGameLogicError(exception);

      expect(errorService.errorHistory.length, 1);
      final error = errorService.errorHistory.first;
      expect(error.type, ErrorType.gameLogic);
      expect(error.severity, ErrorSeverity.high);
    });

    test('should clear error history', () async {
      await errorService.recordError(ErrorType.unknown, 'Test error');

      expect(errorService.errorHistory.length, 1);

      errorService.clearErrorHistory();

      expect(errorService.errorHistory.length, 0);
    });

    test('should emit error events through stream', () async {
      AppError? receivedError;

      errorService.errorStream.listen((error) {
        receivedError = error;
      });

      await errorService.recordError(ErrorType.network, 'Stream test error');

      // Wait for stream event
      await Future.delayed(const Duration(milliseconds: 10));

      expect(receivedError, isNotNull);
      expect(receivedError!.type, ErrorType.network);
      expect(receivedError!.message, 'Stream test error');
    });
  });

  group('AppError', () {
    test('should create error with timestamp', () {
      final error = AppError(
        type: ErrorType.network,
        severity: ErrorSeverity.medium,
        message: 'Test error',
      );

      expect(error.timestamp, isA<DateTime>());
      expect(
        error.timestamp.isBefore(
          DateTime.now().add(const Duration(seconds: 1)),
        ),
        true,
      );
    });

    test('should include technical details when provided', () {
      final error = AppError(
        type: ErrorType.storage,
        severity: ErrorSeverity.high,
        message: 'Storage error',
        technicalDetails: 'File system full',
      );

      expect(error.technicalDetails, 'File system full');
    });

    test('should have proper string representation', () {
      final error = AppError(
        type: ErrorType.gameLogic,
        severity: ErrorSeverity.medium,
        message: 'Game error',
      );

      final errorString = error.toString();
      expect(errorString, contains('AppError'));
      expect(errorString, contains('gameLogic'));
      expect(errorString, contains('medium'));
      expect(errorString, contains('Game error'));
    });
  });
}
