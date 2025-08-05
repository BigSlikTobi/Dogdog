import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/enums.dart';

/// Service for centralized error tracking and management
class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  final List<AppError> _errorHistory = [];
  final StreamController<AppError> _errorController =
      StreamController<AppError>.broadcast();

  static const int maxErrorHistory = 50;

  /// Stream of error events
  Stream<AppError> get errorStream => _errorController.stream;

  /// List of recorded errors
  List<AppError> get errorHistory => List.unmodifiable(_errorHistory);

  /// Records an error with the specified type and severity
  Future<void> recordError(
    ErrorType type,
    String message, {
    ErrorSeverity severity = ErrorSeverity.medium,
    StackTrace? stackTrace,
    Object? originalError,
    String? technicalDetails,
  }) async {
    final error = AppError(
      type: type,
      severity: severity,
      message: message,
      stackTrace: stackTrace,
      originalError: originalError,
      technicalDetails: technicalDetails,
    );

    _errorHistory.add(error);

    // Limit history size
    if (_errorHistory.length > maxErrorHistory) {
      _errorHistory.removeAt(0);
    }

    // Emit error event
    _errorController.add(error);

    // Log to console in debug mode
    if (kDebugMode) {
      debugPrint('Error recorded: ${error.toString()}');
    }
  }

  /// Handles network-specific errors
  Future<void> handleNetworkError(
    Object error, {
    StackTrace? stackTrace,
  }) async {
    await recordError(
      ErrorType.network,
      error.toString(),
      severity: ErrorSeverity.medium,
      stackTrace: stackTrace,
      originalError: error,
    );
  }

  /// Handles storage-specific errors
  Future<void> handleStorageError(
    Object error, {
    StackTrace? stackTrace,
  }) async {
    await recordError(
      ErrorType.storage,
      error.toString(),
      severity: ErrorSeverity.medium,
      stackTrace: stackTrace,
      originalError: error,
    );
  }

  /// Handles audio-specific errors
  Future<void> handleAudioError(Object error, {StackTrace? stackTrace}) async {
    await recordError(
      ErrorType.audio,
      error.toString(),
      severity: ErrorSeverity.low,
      stackTrace: stackTrace,
      originalError: error,
    );
  }

  /// Handles game logic errors
  Future<void> handleGameLogicError(
    Object error, {
    StackTrace? stackTrace,
  }) async {
    await recordError(
      ErrorType.gameLogic,
      error.toString(),
      severity: ErrorSeverity.high,
      stackTrace: stackTrace,
      originalError: error,
    );
  }

  /// Handles UI/rendering errors
  Future<void> handleUIError(
    Object error, {
    StackTrace? stackTrace,
    String? widgetContext,
  }) async {
    String message = error.toString();
    if (widgetContext != null) {
      message = '$widgetContext: $message';
    }

    await recordError(
      ErrorType.ui,
      message,
      severity: ErrorSeverity.medium,
      stackTrace: stackTrace,
      originalError: error,
      technicalDetails:
          'UI rendering error - check widget layout and constraints',
    );
  }

  /// Handles platform-specific runtime errors (iOS/Android crashes)
  Future<void> handlePlatformError(
    Object error, {
    StackTrace? stackTrace,
    String? platform,
  }) async {
    String message = error.toString();
    if (platform != null) {
      message = '$platform runtime error: $message';
    }

    await recordError(
      ErrorType.unknown,
      message,
      severity: ErrorSeverity.high,
      stackTrace: stackTrace,
      originalError: error,
      technicalDetails:
          'Platform-specific runtime error - may require app restart',
    );
  }

  /// Clears the error history
  void clearErrorHistory() {
    _errorHistory.clear();
  }

  /// Disposes of the error service
  void dispose() {
    _errorController.close();
  }
}

/// Represents an application error with context and metadata
class AppError {
  final ErrorType type;
  final ErrorSeverity severity;
  final String message;
  final DateTime timestamp;
  final StackTrace? stackTrace;
  final Object? originalError;
  final String? technicalDetails;

  AppError({
    required this.type,
    required this.severity,
    required this.message,
    this.stackTrace,
    this.originalError,
    this.technicalDetails,
  }) : timestamp = DateTime.now();

  /// User-friendly error message
  String get userMessage {
    switch (type) {
      case ErrorType.network:
        return 'Connection problem. Please check your internet connection and try again.';
      case ErrorType.storage:
        return 'Unable to save your progress. Please ensure you have enough storage space.';
      case ErrorType.audio:
        return 'Audio playback issue. The game will continue without sound.';
      case ErrorType.gameLogic:
        return 'Something went wrong with the game. We\'re working to fix this.';
      case ErrorType.ui:
        return 'Display issue detected. Please try rotating your device or restarting the app.';
      case ErrorType.unknown:
        // Check if it's a UI error based on message content for backwards compatibility
        if (message.contains('RenderFlex') ||
            message.contains('overflow') ||
            message.contains('layout')) {
          return 'Display issue detected. Please try rotating your device or restarting the app.';
        }
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Recovery suggestion for the user
  String get recoverySuggestion {
    switch (type) {
      case ErrorType.network:
        return 'Check your internet connection and retry the operation.';
      case ErrorType.storage:
        return 'Free up some storage space or restart the app.';
      case ErrorType.audio:
        return 'Check your device\'s audio settings or restart the app.';
      case ErrorType.gameLogic:
        return 'Restart the current game or return to the main menu.';
      case ErrorType.ui:
        return 'Try rotating your device, adjusting text size settings, or restarting the app.';
      case ErrorType.unknown:
        // Check if it's a UI error based on message content for backwards compatibility
        if (message.contains('RenderFlex') ||
            message.contains('overflow') ||
            message.contains('layout')) {
          return 'Try rotating your device, adjusting text size settings, or restarting the app.';
        }
        return 'Try restarting the app or contact support if the problem persists.';
    }
  }

  @override
  String toString() {
    return 'AppError(type: $type, severity: $severity, message: $message, timestamp: $timestamp)';
  }
}
