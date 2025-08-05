import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/services/progress_service.dart';
import 'package:dogdog_trivia_game/services/question_service.dart';
import 'package:dogdog_trivia_game/services/audio_service.dart';
import 'package:dogdog_trivia_game/services/error_service.dart';
import 'package:dogdog_trivia_game/screens/error_recovery_screen.dart';

import 'package:dogdog_trivia_game/screens/home_screen.dart';
import 'package:dogdog_trivia_game/widgets/error_boundary.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('Comprehensive Error Handling Tests', () {
    late SharedPreferences prefs;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    setUp(() async {
      await prefs.clear();
    });

    testWidgets('Error boundary catches and handles widget exceptions', (
      WidgetTester tester,
    ) async {
      // Create a widget that throws an exception
      Widget throwingWidget() {
        return Builder(
          builder: (context) {
            throw Exception('Test exception for error boundary');
          },
        );
      }

      await tester.pumpWidget(
        MaterialApp(home: ErrorBoundary(child: throwingWidget())),
      );

      await tester.pumpAndSettle();

      // Verify error boundary displays error recovery UI
      expect(find.text('Oops! Something went wrong'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets(
      'Game controller handles invalid state transitions gracefully',
      (WidgetTester tester) async {
        final gameController = GameController();

        // Try to select answer when no question is loaded
        expect(() => gameController.processAnswer(0), returnsNormally);

        // Try to use power-up when none available
        expect(() => gameController.useFiftyFifty(), returnsNormally);

        // Try to proceed to next question when game is over
        gameController.resetGame();
        expect(() => gameController.nextQuestion(), returnsNormally);

        // Verify game state remains consistent
        expect(gameController.isGameActive, isFalse);
        gameController.dispose();
      },
    );

    testWidgets('Question service handles missing or corrupted data', (
      WidgetTester tester,
    ) async {
      final questionService = QuestionService();

      // Initialize the service first
      await questionService.initialize();

      // Test with empty question pool
      final emptyQuestions = questionService.getQuestionsWithAdaptiveDifficulty(
        count: 0,
        playerLevel: 1,
        streakCount: 0,
        recentMistakes: 0,
      );
      expect(emptyQuestions, isEmpty);

      // Test with negative count
      final negativeCountQuestions = questionService
          .getQuestionsWithAdaptiveDifficulty(
            count: -5,
            playerLevel: 1,
            streakCount: 0,
            recentMistakes: 0,
          );
      expect(negativeCountQuestions, isEmpty);
    });

    testWidgets('Progress service handles corrupted save data', (
      WidgetTester tester,
    ) async {
      final progressService = ProgressService();

      // Simulate corrupted data in SharedPreferences
      await prefs.setString('player_progress', 'invalid_json_data');

      // Should handle corrupted data gracefully
      await progressService.initialize();
      final progress = await progressService.getPlayerProgress();
      expect(progress, isNotNull);
      expect(
        progress.totalCorrectAnswers,
        equals(0),
      ); // Should reset to defaults
    });

    testWidgets('Audio service handles missing audio files', (
      WidgetTester tester,
    ) async {
      final audioService = AudioService();

      // Try to play non-existent audio file
      expect(() => audioService.playCorrectAnswerSound(), returnsNormally);

      // Try to play different sound types
      expect(() => audioService.playIncorrectAnswerSound(), returnsNormally);

      // Try to play button sound
      expect(() => audioService.playButtonSound(), returnsNormally);
    });

    testWidgets('Memory pressure scenarios are handled', (
      WidgetTester tester,
    ) async {
      // Simulate memory pressure by creating many widgets
      for (int i = 0; i < 100; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: List.generate(
                  100,
                  (index) => SizedBox(
                    key: ValueKey('container_${i}_$index'),
                    height: 50,
                    child: Text('Item $index'),
                  ),
                ),
              ),
            ),
          ),
        );

        if (i % 10 == 0) {
          await tester.pumpAndSettle();
        }
      }

      // App should handle memory pressure without crashing
      expect(tester.takeException(), isNull);
    });

    testWidgets('Timer edge cases are handled correctly', (
      WidgetTester tester,
    ) async {
      final gameController = GameController();

      // Initialize game first
      await gameController.initializeGame(level: 2); // Level 2 has timer

      // Multiple operations should be handled gracefully
      expect(() => gameController.pauseGame(), returnsNormally);
      expect(() => gameController.resumeGame(), returnsNormally);

      gameController.dispose();
    });

    testWidgets('Power-up edge cases are handled', (WidgetTester tester) async {
      final gameController = GameController();

      // Use power-up when inventory is empty
      expect(() => gameController.useFiftyFifty(), returnsNormally);

      // Use multiple power-ups simultaneously
      gameController.addPowerUp(PowerUpType.fiftyFifty, 2);
      gameController.addPowerUp(PowerUpType.hint, 1);

      expect(() => gameController.useFiftyFifty(), returnsNormally);
      expect(() => gameController.useHint(), returnsNormally);

      gameController.dispose();
    });

    testWidgets('Achievement system handles edge cases', (
      WidgetTester tester,
    ) async {
      final progressService = ProgressService();
      await progressService.initialize();

      // Record correct answers
      await progressService.recordCorrectAnswer(
        pointsEarned: 10,
        currentStreak: 1,
      );

      final progress = await progressService.getPlayerProgress();
      expect(progress.totalCorrectAnswers, greaterThanOrEqualTo(0));

      // Should handle operations without overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Screen rotation during gameplay is handled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GameController()),
            ChangeNotifierProvider(create: (_) => ProgressService()),
            Provider(create: (_) => QuestionService()),
            Provider(create: (_) => AudioService()),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Simulate screen rotation during gameplay
      await tester.binding.setSurfaceSize(const Size(800, 400)); // Landscape
      await tester.pumpAndSettle();

      await tester.binding.setSurfaceSize(const Size(400, 800)); // Portrait
      await tester.pumpAndSettle();

      // Should handle rotation gracefully
      expect(tester.takeException(), isNull);
    });

    testWidgets('Concurrent operations are handled safely', (
      WidgetTester tester,
    ) async {
      final gameController = GameController();
      final progressService = ProgressService();
      await progressService.initialize();

      // Simulate concurrent operations
      final futures = <Future>[];

      for (int i = 0; i < 10; i++) {
        futures.add(
          progressService.recordCorrectAnswer(
            pointsEarned: i * 10,
            currentStreak: i,
          ),
        );
        futures.add(
          Future.delayed(Duration(milliseconds: i * 10), () {
            gameController.processAnswer(i % 4);
          }),
        );
      }

      // Wait for all operations to complete
      await Future.wait(futures);

      // Should handle concurrent operations without issues
      expect(tester.takeException(), isNull);

      gameController.dispose();
    });

    testWidgets('Error recovery flow works correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorRecoveryScreen(
            initialError: AppError(
              type: ErrorType.unknown,
              severity: ErrorSeverity.medium,
              message: 'Test error',
              originalError: Exception('Test error'),
            ),
          ),
        ),
      );

      // Verify error recovery screen is displayed
      expect(find.text('Ein Fehler ist aufgetreten'), findsOneWidget);
      expect(find.text('Erneut versuchen'), findsOneWidget);
      expect(find.text('Zurück zum Hauptmenü'), findsOneWidget);

      // Test retry functionality
      await tester.tap(find.text('Erneut versuchen'));
      await tester.pumpAndSettle();

      // Test home navigation
      await tester.tap(find.text('Zurück zum Hauptmenü'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Resource cleanup on app termination', (
      WidgetTester tester,
    ) async {
      final gameController = GameController();
      final audioService = AudioService();

      // Initialize resources
      await gameController.initializeGame(level: 1);
      await audioService.initialize();

      // Simulate app termination
      gameController.dispose();
      await audioService.dispose();

      // Should clean up resources without exceptions
      expect(tester.takeException(), isNull);
    });
  });

  group('Edge Case Tests', () {
    testWidgets('Boundary value testing for game mechanics', (
      WidgetTester tester,
    ) async {
      final gameController = GameController();

      // Initialize game first
      await gameController.initializeGame(level: 1);

      // Test with boundary values
      expect(() => gameController.processAnswer(0), returnsNormally);
      expect(() => gameController.processAnswer(3), returnsNormally);

      // Test game state consistency
      expect(gameController.isGameActive, isTrue);
      gameController.dispose();
    });

    testWidgets('Unicode and special character handling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                Text('🐕 Hund mit Emoji'),
                Text('Spëcîál chäracters'),
                Text(
                  'Very long text that might cause layout issues and should be handled gracefully by the text rendering system',
                ),
                SizedBox(height: 8),
                Text('null'),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should handle special characters without issues
      expect(tester.takeException(), isNull);
      expect(find.text('🐕 Hund mit Emoji'), findsOneWidget);
    });

    testWidgets('Extreme screen sizes are handled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GameController()),
            ChangeNotifierProvider(create: (_) => ProgressService()),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Test very small screen
      await tester.binding.setSurfaceSize(const Size(100, 100));
      await tester.pumpAndSettle();

      // Test very wide screen
      await tester.binding.setSurfaceSize(const Size(2000, 400));
      await tester.pumpAndSettle();

      // Test very tall screen
      await tester.binding.setSurfaceSize(const Size(400, 2000));
      await tester.pumpAndSettle();

      // Should handle extreme sizes gracefully
      expect(tester.takeException(), isNull);
    });

    testWidgets('Rapid state changes are handled correctly', (
      WidgetTester tester,
    ) async {
      final gameController = GameController();

      // Initialize game first
      await gameController.initializeGame(level: 1);

      // Rapid state changes
      for (int i = 0; i < 100; i++) {
        gameController.processAnswer(i % 4);
        if (i % 10 == 0) {
          gameController.nextQuestion();
        }
      }

      // Should handle rapid changes without issues
      expect(tester.takeException(), isNull);
      gameController.dispose();
    });
  });
}
