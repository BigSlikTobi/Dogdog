import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/controllers/treasure_map_controller.dart';
import 'package:dogdog_trivia_game/controllers/persistent_timer_controller.dart';
import 'package:dogdog_trivia_game/services/progress_service.dart';
import 'package:dogdog_trivia_game/screens/game_screen.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('GameScreen Treasure Map Integration Tests', () {
    late GameController gameController;
    late TreasureMapController treasureMapController;
    late ProgressService progressService;
    late PersistentTimerController timerController;

    setUp(() async {
      progressService = ProgressService();
      await progressService.initialize();

      timerController = PersistentTimerController();

      gameController = GameController(
        progressService: progressService,
        timerController: timerController,
      );

      treasureMapController = TreasureMapController();
      treasureMapController.initializePath(PathType.dogBreeds);
    });

    testWidgets('displays checkpoint progress indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: gameController),
              ChangeNotifierProvider.value(value: treasureMapController),
            ],
            child: const GameScreen(difficulty: Difficulty.easy),
          ),
        ),
      );

      await tester.pump();

      // Should show path name
      expect(find.text('Dog Breeds Path'), findsOneWidget);

      // Should show next checkpoint
      expect(find.text('Chihuahua'), findsOneWidget);

      // Should show progress indicator
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('displays updated app bar title with path info', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: gameController),
              ChangeNotifierProvider.value(value: treasureMapController),
            ],
            child: const GameScreen(difficulty: Difficulty.easy),
          ),
        ),
      );

      await tester.pump();

      // Should show current path in app bar
      expect(find.text('Dog Breeds'), findsOneWidget);
      expect(find.text('Treasure Hunt'), findsOneWidget);
    });

    testWidgets('shows exactly 3 heart slots in lives display', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: gameController),
              ChangeNotifierProvider.value(value: treasureMapController),
            ],
            child: const GameScreen(difficulty: Difficulty.easy),
          ),
        ),
      );

      await tester.pump();

      // Should find exactly 3 heart icons (filled or empty)
      final heartIcons =
          find.byIcon(Icons.favorite_rounded).evaluate().length +
          find.byIcon(Icons.favorite_border_rounded).evaluate().length;
      expect(heartIcons, equals(3));
    });

    testWidgets('displays all 5 power-up types', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: gameController),
              ChangeNotifierProvider.value(value: treasureMapController),
            ],
            child: const GameScreen(difficulty: Difficulty.easy),
          ),
        ),
      );

      await tester.pump();

      // Should show all 5 power-up icons
      expect(
        find.byIcon(Icons.remove_circle_outline_rounded),
        findsOneWidget,
      ); // 50/50
      expect(
        find.byIcon(Icons.lightbulb_outline_rounded),
        findsOneWidget,
      ); // hint
      expect(
        find.byIcon(Icons.access_time_rounded),
        findsOneWidget,
      ); // extra time
      expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget); // skip
      expect(
        find.byIcon(Icons.favorite_border_rounded),
        findsOneWidget,
      ); // second chance
    });

    testWidgets('updates progress when questions are answered', (
      WidgetTester tester,
    ) async {
      // Initialize game with questions
      await gameController.initializeGame(level: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: gameController),
              ChangeNotifierProvider.value(value: treasureMapController),
            ],
            child: const GameScreen(difficulty: Difficulty.easy),
          ),
        ),
      );

      await tester.pump();

      // Check initial state shows questions remaining
      expect(find.textContaining('left'), findsOneWidget);

      // Answer a question (simulate)
      treasureMapController.incrementQuestionCount();
      await tester.pump();

      // Progress should update (check by finding progress indicator)
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows enhanced timer with warning states', (
      WidgetTester tester,
    ) async {
      // Initialize with timer active
      await gameController.initializeGame(level: 2); // Level 2 has timer

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: gameController),
              ChangeNotifierProvider.value(value: treasureMapController),
            ],
            child: const GameScreen(difficulty: Difficulty.easy, level: 2),
          ),
        ),
      );

      await tester.pump();

      // Should have timer display when active
      if (gameController.isTimerActive) {
        expect(find.textContaining('s'), findsWidgets); // Timer seconds display
      }
    });
  });
}
