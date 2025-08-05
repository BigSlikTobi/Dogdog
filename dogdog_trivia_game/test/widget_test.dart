// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dogdog_trivia_game/main.dart';
import 'package:dogdog_trivia_game/services/progress_service.dart';

void main() {
  testWidgets('DogDog app loads correctly', (WidgetTester tester) async {
    // Set up mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Create and initialize progress service
    final progressService = ProgressService();
    await progressService.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(DogDogTriviaApp(progressService: progressService));

    // Verify that the app loads
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verify that the dog icon is displayed (from home screen)
    expect(find.byIcon(Icons.pets), findsOneWidget);

    // Clean up
    progressService.dispose();
  });
}
