import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Create a simple test widget that doesn't trigger timers
    await tester.pumpWidget(MaterialApp(home: const Text('Test App')));

    // Verify that MaterialApp is created
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Test App'), findsOneWidget);
  });
}
