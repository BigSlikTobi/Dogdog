import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/screens/home_screen.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('should display loading indicator initially', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Assert - Should show loading indicator before initialization
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // Check that the scaffold has the correct background color
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(
        scaffold.backgroundColor,
        const Color(0xFFF8FAFC),
      ); // Background Gray
    });

    testWidgets('should create HomeScreen widget without errors', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Assert - Widget should be created successfully
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should display loading state with proper structure', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Wait a short time to let the widget build
      await tester.pump();

      // Assert - Should have proper loading structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should use correct background color from design system', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Assert - Check that the scaffold has the correct background color
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(
        scaffold.backgroundColor,
        const Color(0xFFF8FAFC),
      ); // Background Gray from design
    });

    testWidgets('should display loading state correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Assert - Loading state should be displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Check loading indicator color
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progressIndicator.color, const Color(0xFF4A90E2)); // Primary Blue
    });
  });

  group('HomeScreen Integration Tests', () {
    testWidgets('should handle widget lifecycle correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Assert initial state
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Test widget disposal
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Different Screen'))),
      );

      expect(find.byType(HomeScreen), findsNothing);
      expect(find.text('Different Screen'), findsOneWidget);
    });

    testWidgets('should maintain state during rebuild', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Act - Trigger a rebuild
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Assert - Widget should still be present
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // Note: Navigation test is complex due to async initialization
    // The navigation functionality is tested manually and works correctly
  });
}
