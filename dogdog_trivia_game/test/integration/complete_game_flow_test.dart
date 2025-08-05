import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dogdog_trivia_game/main.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/services/progress_service.dart';
import 'package:dogdog_trivia_game/services/question_service.dart';
import 'package:dogdog_trivia_game/services/audio_service.dart';
import 'package:dogdog_trivia_game/screens/game_screen.dart';
import 'package:dogdog_trivia_game/screens/result_screen.dart';
import 'package:dogdog_trivia_game/screens/game_over_screen.dart';
import 'package:dogdog_trivia_game/screens/achievements_screen.dart';
import 'package:dogdog_trivia_game/widgets/error_boundary.dart';

void main() {
  group('Complete Game Flow Integration Tests', () {
    late SharedPreferences prefs;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    setUp(() async {
      await prefs.clear();
    });

    testWidgets('Complete game flow from home to game over', (
      WidgetTester tester,
    ) async {
      // Build the app
      final progressService = ProgressService();
      await progressService.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GameController()),
            ChangeNotifierProvider.value(value: progressService),
            Provider(create: (_) => QuestionService()),
            Provider(create: (_) => AudioService()),
          ],
          child: DogDogTriviaApp(progressService: progressService),
        ),
      );

      // Verify home screen is displayed
      expect(find.text('DogDog Trivia'), findsOneWidget);
      expect(find.text('Quiz starten'), findsOneWidget);

      // Tap start quiz button
      await tester.tap(find.text('Quiz starten'));
      await tester.pumpAndSettle();

      // Verify difficulty selection screen
      expect(find.text('Schwierigkeit wählen'), findsOneWidget);
      expect(find.text('Leicht'), findsOneWidget);
      expect(find.text('Mittel'), findsOneWidget);
      expect(find.text('Schwer'), findsOneWidget);
      expect(find.text('Experte'), findsOneWidget);

      // Select easy difficulty
      await tester.tap(find.text('Diese Kategorie wählen').first);
      await tester.pumpAndSettle();

      // Verify game screen is displayed
      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.text('❤️❤️❤️'), findsOneWidget); // Lives display
      expect(find.text('Score: 0'), findsOneWidget);

      // Simulate answering questions
      // Note: We'll interact with the UI directly rather than accessing the controller

      // Answer first question correctly
      final answerButtons = find.byType(ElevatedButton);
      expect(answerButtons, findsNWidgets(4)); // Four answer choices

      await tester.tap(answerButtons.first);
      await tester.pumpAndSettle();

      // Verify result screen
      expect(find.byType(ResultScreen), findsOneWidget);
      expect(find.text('Richtig!'), findsOneWidget);

      // Continue to next question
      await tester.tap(find.text('Nächste Frage'));
      await tester.pumpAndSettle();

      // Simulate losing all lives by answering incorrectly
      for (int i = 0; i < 3; i++) {
        // Answer incorrectly (assuming first answer is wrong)
        await tester.tap(answerButtons.first);
        await tester.pumpAndSettle();

        if (i < 2) {
          // Continue to next question
          await tester.tap(find.text('Nächste Frage'));
          await tester.pumpAndSettle();
        }
      }

      // Verify game over screen
      expect(find.byType(GameOverScreen), findsOneWidget);
      expect(find.text('Spiel beendet!'), findsOneWidget);

      // Return to home
      await tester.tap(find.text('Zurück zum Hauptmenü'));
      await tester.pumpAndSettle();

      // Verify back at home screen
      expect(find.text('DogDog Trivia'), findsOneWidget);
    });

    testWidgets('Achievement unlock flow', (WidgetTester tester) async {
      final progressService = ProgressService();
      await progressService.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GameController()),
            ChangeNotifierProvider.value(value: progressService),
            Provider(create: (_) => QuestionService()),
            Provider(create: (_) => AudioService()),
          ],
          child: DogDogTriviaApp(progressService: progressService),
        ),
      );

      // Navigate to achievements screen
      await tester.tap(find.text('Quiz starten'));
      await tester.pumpAndSettle();

      // Verify achievements can be accessed
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      await tester.tap(find.byIcon(Icons.emoji_events));
      await tester.pumpAndSettle();

      // Verify achievements screen
      expect(find.byType(AchievementsScreen), findsOneWidget);
      expect(find.text('Erfolge'), findsOneWidget);

      // Verify rank progression display
      expect(find.text('Chihuahua'), findsOneWidget);
      expect(find.text('Pug'), findsOneWidget);
      expect(find.text('Cocker Spaniel'), findsOneWidget);
      expect(find.text('German Shepherd'), findsOneWidget);
      expect(find.text('Great Dane'), findsOneWidget);
    });

    testWidgets('Power-up usage flow', (WidgetTester tester) async {
      final progressService = ProgressService();
      await progressService.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GameController()),
            ChangeNotifierProvider.value(value: progressService),
            Provider(create: (_) => QuestionService()),
            Provider(create: (_) => AudioService()),
          ],
          child: DogDogTriviaApp(progressService: progressService),
        ),
      );

      // Navigate to game
      await tester.tap(find.text('Quiz starten'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Diese Kategorie wählen').first);
      await tester.pumpAndSettle();

      // Verify power-up buttons are present
      expect(find.text('50/50'), findsOneWidget);
      expect(find.text('Hint'), findsOneWidget);
      expect(find.text('Extra Time'), findsOneWidget);

      // Test 50/50 power-up
      await tester.tap(find.text('50/50'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Power-Up verwenden?'), findsOneWidget);
      await tester.tap(find.text('Ja'));
      await tester.pumpAndSettle();

      // Verify two answer choices are disabled
      final disabledButtons = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.onPressed == null,
      );
      expect(disabledButtons, findsNWidgets(2));
    });

    testWidgets('Data persistence across app restarts', (
      WidgetTester tester,
    ) async {
      // First app session - play and earn progress
      final progressService = ProgressService();
      await progressService.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GameController()),
            ChangeNotifierProvider.value(value: progressService),
            Provider(create: (_) => QuestionService()),
            Provider(create: (_) => AudioService()),
          ],
          child: DogDogTriviaApp(progressService: progressService),
        ),
      );

      // Simulate earning some progress
      await progressService.recordCorrectAnswer(
        pointsEarned: 50,
        currentStreak: 5,
      );

      // Restart app (new widget tree)
      final newProgressService = ProgressService();
      await newProgressService.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GameController()),
            ChangeNotifierProvider.value(value: newProgressService),
            Provider(create: (_) => QuestionService()),
            Provider(create: (_) => AudioService()),
          ],
          child: DogDogTriviaApp(progressService: newProgressService),
        ),
      );

      // Verify progress is maintained
      final progress = await newProgressService.getPlayerProgress();
      expect(progress.totalCorrectAnswers, equals(5));
    });

    testWidgets('Error handling and recovery', (WidgetTester tester) async {
      final progressService = ProgressService();
      await progressService.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GameController()),
            ChangeNotifierProvider.value(value: progressService),
            Provider(create: (_) => QuestionService()),
            Provider(create: (_) => AudioService()),
          ],
          child: DogDogTriviaApp(progressService: progressService),
        ),
      );

      // Test navigation with invalid state
      await tester.tap(find.text('Start Quiz'));
      await tester.pumpAndSettle();

      // Verify error boundary handles gracefully
      expect(find.byType(ErrorBoundary), findsOneWidget);

      // Test recovery from error state
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      // Verify app recovers to home screen
      expect(find.text('Welcome to DogDog!'), findsOneWidget);
    });
  });
}
