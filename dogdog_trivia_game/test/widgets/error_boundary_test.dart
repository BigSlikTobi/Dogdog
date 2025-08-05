import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/widgets/error_boundary.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('ErrorBoundary Widget Tests', () {
    testWidgets('should display child when no error occurs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ErrorBoundary(child: const Text('Test Child'))),
      );

      expect(find.text('Test Child'), findsOneWidget);
      expect(find.text('Oops! Something went wrong'), findsNothing);
    });

    testWidgets('should show error UI when error occurs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            child: Builder(
              builder: (context) {
                throw Exception('Test error');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Oops! Something went wrong'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Go to Home'), findsOneWidget);
    });

    testWidgets('should show custom message when provided', (tester) async {
      const customMessage = 'Custom error message for testing';

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            customMessage: customMessage,
            child: Builder(
              builder: (context) {
                throw Exception('Test error');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(customMessage), findsOneWidget);
    });

    testWidgets('should call onRetry when Try Again is tapped', (tester) async {
      bool retryWasCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            onRetry: () {
              retryWasCalled = true;
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

      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(retryWasCalled, true);
    });
  });

  group('NetworkErrorBoundary Widget Tests', () {
    testWidgets('should show network-specific error message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NetworkErrorBoundary(
            child: Builder(
              builder: (context) {
                throw Exception('Network error');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Network connection issue'), findsOneWidget);
    });
  });

  group('GameErrorBoundary Widget Tests', () {
    testWidgets('should show game-specific error message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameErrorBoundary(
            child: Builder(
              builder: (context) {
                throw Exception('Game error');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Game error occurred'), findsOneWidget);
    });
  });

  group('SafeAsyncBuilder Widget Tests', () {
    testWidgets('should show loading widget while future is pending', (
      tester,
    ) async {
      final completer = Completer<String>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeAsyncBuilder<String>(
              future: completer.future,
              builder: (context, data) => Text(data),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete('Test Data');
      await tester.pumpAndSettle();

      expect(find.text('Test Data'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show error widget when future fails', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeAsyncBuilder<String>(
              future: Future.error('Test error'),
              builder: (context, data) => Text(data),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Please try again'), findsOneWidget);
    });

    testWidgets('should use custom loading widget', (tester) async {
      final completer = Completer<String>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeAsyncBuilder<String>(
              future: completer.future,
              builder: (context, data) => Text(data),
              loadingBuilder: (context) => const Text('Custom Loading'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Loading'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should use custom error widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeAsyncBuilder<String>(
              future: Future.error('Test error'),
              builder: (context, data) => Text(data),
              errorBuilder: (context, error) =>
                  const Text('Custom Error Widget'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Custom Error Widget'), findsOneWidget);
    });

    testWidgets('should retry on button tap', (tester) async {
      int retryCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SafeAsyncBuilder<String>(
                  future: Future.error('Test error'),
                  builder: (context, data) => Text(data),
                  onRetry: () {
                    retryCount++;
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(retryCount, 1);
    });
  });

  group('ErrorBoundaryUtils Tests', () {
    testWidgets('should wrap widget with error boundary', (tester) async {
      final wrappedWidget = ErrorBoundaryUtils.wrapWithErrorBoundary(
        const Text('Test Widget'),
        errorType: ErrorType.network,
      );

      expect(wrappedWidget, isA<ErrorBoundary>());
    });

    test('should wrap list of children with error boundaries', () {
      final children = [
        const Text('Child 1'),
        const Text('Child 2'),
        const Text('Child 3'),
      ];

      final wrappedChildren =
          ErrorBoundaryUtils.wrapChildrenWithErrorBoundaries(
            children,
            errorType: ErrorType.gameLogic,
          );

      expect(wrappedChildren.length, 3);
      expect(wrappedChildren.every((child) => child is ErrorBoundary), true);
    });
  });
}
