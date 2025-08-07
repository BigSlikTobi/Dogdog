import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:dogdog_trivia_game/main.dart';
import 'package:dogdog_trivia_game/services/progress_service.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/services/question_service.dart';
import 'package:dogdog_trivia_game/services/audio_service.dart';

/// Helper class for setting up tests consistently
class TestHelper {
  /// Sets up a clean test environment with mocked SharedPreferences
  static void setUpTestEnvironment() {
    SharedPreferences.setMockInitialValues({});
  }

  /// Creates a fully initialized app widget for testing
  static Future<Widget> createTestApp() async {
    final progressService = ProgressService();
    await progressService.initialize();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameController()),
        ChangeNotifierProvider.value(value: progressService),
        Provider(create: (_) => QuestionService()),
        Provider(create: (_) => AudioService()),
      ],
      child: DogDogTriviaApp(progressService: progressService),
    );
  }

  /// Creates a basic widget wrapper for testing individual widgets
  static Widget wrapWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  /// Cleanup method to call in tearDown
  static void cleanup(ProgressService? progressService) {
    progressService?.dispose();
  }
}
