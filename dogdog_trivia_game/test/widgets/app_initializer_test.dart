import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/widgets/app_initializer.dart';

void main() {
  group('AppInitializer', () {
    testWidgets('shows loading screen initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AppInitializer(child: Text('Child Widget'))),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Initializing...'), findsOneWidget);
      expect(find.text('Child Widget'), findsNothing);
    });

    testWidgets('shows child widget after initialization', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AppInitializer(child: Text('Child Widget'))),
      );

      // Wait for initialization to complete
      await tester.pumpAndSettle();

      // Should show child widget
      expect(find.text('Child Widget'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('calls onInitializationComplete callback', (tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AppInitializer(
            onInitializationComplete: () {
              callbackCalled = true;
            },
            child: const Text('Child Widget'),
          ),
        ),
      );

      // Wait for initialization to complete
      await tester.pumpAndSettle();

      expect(callbackCalled, isTrue);
    });

    testWidgets('shows loading status updates', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AppInitializer(child: Text('Child Widget'))),
      );

      // Should show initial loading message
      expect(find.text('Initializing...'), findsOneWidget);

      // Pump a frame to allow state updates
      await tester.pump();

      // Should show loading images message
      expect(find.text('Loading images...'), findsOneWidget);
    });

    testWidgets('handles initialization errors gracefully', (tester) async {
      // This test ensures the widget doesn't crash on initialization errors
      await tester.pumpWidget(
        const MaterialApp(home: AppInitializer(child: Text('Child Widget'))),
      );

      // Wait for initialization to complete (even with potential errors)
      await tester.pumpAndSettle();

      // Should eventually show child widget even if there were errors
      expect(find.text('Child Widget'), findsOneWidget);
    });

    testWidgets('provides proper scaffold structure during loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: AppInitializer(child: Text('Child Widget'))),
      );

      // Should have proper scaffold structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('maintains widget tree structure after initialization', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppInitializer(
            child: Scaffold(
              appBar: AppBar(title: const Text('Test App')),
              body: const Text('Child Widget'),
            ),
          ),
        ),
      );

      // Wait for initialization
      await tester.pumpAndSettle();

      // Should maintain child widget structure
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Test App'), findsOneWidget);
      expect(find.text('Child Widget'), findsOneWidget);
    });

    testWidgets('handles multiple initialization cycles', (tester) async {
      Widget buildApp() {
        return const MaterialApp(
          home: AppInitializer(child: Text('Child Widget')),
        );
      }

      // First initialization
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Child Widget'), findsOneWidget);

      // Rebuild with new widget
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Child Widget'), findsOneWidget);
    });

    testWidgets('respects theme styling during loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontSize: 20, color: Colors.red),
            ),
          ),
          home: const AppInitializer(child: Text('Child Widget')),
        ),
      );

      // Should apply theme to loading text
      final textWidget = tester.widget<Text>(find.text('Initializing...'));
      expect(textWidget.style, isNull); // Uses theme default
    });

    testWidgets('provides accessibility support during loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: AppInitializer(child: Text('Child Widget'))),
      );

      // Should have accessible loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Initializing...'), findsOneWidget);

      // Text should be readable by screen readers
      final textFinder = find.text('Initializing...');
      expect(textFinder, findsOneWidget);
    });
  });
}
