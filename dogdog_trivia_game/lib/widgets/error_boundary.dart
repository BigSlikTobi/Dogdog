import 'package:flutter/material.dart';
import '../services/error_service.dart';
import '../models/enums.dart';
import '../screens/home_screen.dart';

/// Generic error boundary widget that catches and handles widget tree errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final VoidCallback? onRetry;
  final String? customMessage;
  final ErrorType errorType;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onRetry,
    this.customMessage,
    this.errorType = ErrorType.unknown,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace; // Used for error reporting and debugging

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorUI();
    }

    return _SafeChildWrapper(onError: _handleError, child: widget.child);
  }

  void _handleError(Object error, StackTrace stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });

    // Record error
    ErrorService().recordError(
      widget.errorType,
      error.toString(),
      severity: ErrorSeverity.medium,
      stackTrace: stackTrace,
      originalError: error,
    );
  }

  Widget _buildErrorUI() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.customMessage ??
                  'We encountered an unexpected error. Please try again.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.onRetry != null) ...[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _stackTrace = null;
                      });
                      widget.onRetry!();
                    },
                    child: const Text('Try Again'),
                  ),
                  const SizedBox(width: 12),
                ],
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Error boundary specialized for network operations
class NetworkErrorBoundary extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRetry;

  const NetworkErrorBoundary({super.key, required this.child, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      errorType: ErrorType.network,
      onRetry: onRetry,
      customMessage:
          'Network connection issue. Please check your internet connection.',
      child: child,
    );
  }
}

/// Error boundary specialized for game operations
class GameErrorBoundary extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRetry;

  const GameErrorBoundary({super.key, required this.child, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      errorType: ErrorType.gameLogic,
      onRetry: onRetry,
      customMessage: 'Game error occurred. The game state might be corrupted.',
      child: child,
    );
  }
}

/// Safe async builder that handles async operations with error recovery
class SafeAsyncBuilder<T> extends StatefulWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final VoidCallback? onRetry;

  const SafeAsyncBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    this.onRetry,
  });

  @override
  State<SafeAsyncBuilder<T>> createState() => _SafeAsyncBuilderState<T>();
}

class _SafeAsyncBuilderState<T> extends State<SafeAsyncBuilder<T>> {
  late Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // Record error
          ErrorService().recordError(
            ErrorType.unknown,
            snapshot.error.toString(),
            severity: ErrorSeverity.medium,
            originalError: snapshot.error,
          );

          return widget.errorBuilder?.call(context, snapshot.error!) ??
              _buildDefaultErrorWidget(context, snapshot.error!);
        }

        if (snapshot.hasData && snapshot.data != null) {
          return widget.builder(context, snapshot.data as T);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDefaultErrorWidget(BuildContext context, Object error) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (widget.onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _future = widget.future;
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Safe wrapper for child widgets that catches build errors
class _SafeChildWrapper extends StatefulWidget {
  final Widget child;
  final Function(Object error, StackTrace stackTrace) onError;

  const _SafeChildWrapper({required this.child, required this.onError});

  @override
  State<_SafeChildWrapper> createState() => _SafeChildWrapperState();
}

class _SafeChildWrapperState extends State<_SafeChildWrapper> {
  @override
  Widget build(BuildContext context) {
    try {
      return widget.child;
    } catch (error, stackTrace) {
      widget.onError(error, stackTrace);
      return const SizedBox.shrink();
    }
  }
}

/// Utility class for error boundary operations
class ErrorBoundaryUtils {
  /// Wraps a widget with appropriate error boundary based on context
  static Widget wrapWithErrorBoundary(
    Widget child, {
    ErrorType errorType = ErrorType.unknown,
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    return ErrorBoundary(
      errorType: errorType,
      onRetry: onRetry,
      customMessage: customMessage,
      child: child,
    );
  }

  /// Wraps a list of widgets with error boundaries
  static List<Widget> wrapChildrenWithErrorBoundaries(
    List<Widget> children, {
    ErrorType errorType = ErrorType.unknown,
  }) {
    return children
        .map((child) => wrapWithErrorBoundary(child, errorType: errorType))
        .toList();
  }
}

/// Mixin for widgets that need error handling capabilities
mixin ErrorHandlingMixin<T extends StatefulWidget> on State<T> {
  void handleError(Object error, StackTrace stackTrace, ErrorType type) {
    ErrorService().recordError(
      type,
      error.toString(),
      severity: ErrorSeverity.medium,
      stackTrace: stackTrace,
      originalError: error,
    );
  }

  void showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  Future<void> safeAsyncOperation(
    Future<void> Function() operation, {
    ErrorType errorType = ErrorType.unknown,
    String? errorMessage,
  }) async {
    try {
      await operation();
    } catch (error, stackTrace) {
      handleError(error, stackTrace, errorType);
      if (errorMessage != null) {
        showErrorSnackBar(errorMessage);
      }
    }
  }
}
