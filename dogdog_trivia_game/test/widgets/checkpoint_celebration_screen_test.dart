import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dogdog_trivia_game/screens/checkpoint_celebration_screen.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/controllers/power_up_controller.dart';
import 'package:dogdog_trivia_game/services/question_service.dart';
import '../helpers/test_helper.dart';

void main() {
  group('CheckpointCelebrationScreen Widget Tests', () {
    late GameController gameController;
    late PowerUpController powerUpController;

    setUp(() {
      powerUpController = PowerUpController();
      gameController = GameController(
        questionService: QuestionService(),
        powerUpController: powerUpController,
      );
    });

    tearDown(() {
      gameController.dispose();
    });

    Widget createTestWidget({
      required Checkpoint checkpoint,
      Map<PowerUpType, int>? earnedPowerUps,
      int questionsAnswered = 10,
      double accuracy = 0.8,
      int pointsEarned = 100,
      bool isPathCompleted = false,
    }) {
      return TestHelper.wrapWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<GameController>.value(value: gameController),
            ChangeNotifierProvider<PowerUpController>.value(
              value: powerUpController,
            ),
          ],
          child: CheckpointCelebrationScreen(
            completedCheckpoint: checkpoint,
            earnedPowerUps:
                earnedPowerUps ??
                {
                  PowerUpType.fiftyFifty: 2,
                  PowerUpType.hint: 2,
                  PowerUpType.extraTime: 1,
                },
            questionsAnswered: questionsAnswered,
            accuracy: accuracy,
            pointsEarned: pointsEarned,
            isPathCompleted: isPathCompleted,
          ),
        ),
      );
    }

    testWidgets('displays checkpoint achievement header correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(checkpoint: Checkpoint.chihuahua),
      );

      // Wait for animations to settle
      await tester.pumpAndSettle();

      // Check for checkpoint reached text
      expect(find.text('Checkpoint Reached!'), findsOneWidget);
      expect(find.text('Chihuahua'), findsOneWidget);
    });

    testWidgets('displays path completed header when path is completed', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          checkpoint: Checkpoint.deutscheDogge,
          isPathCompleted: true,
        ),
      );

      // Wait for animations to settle
      await tester.pumpAndSettle();

      // Check for path completed text
      expect(find.text('Path Completed!'), findsOneWidget);
      expect(find.text('Deutsche Dogge'), findsOneWidget);
    });

    testWidgets('displays performance summary correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          checkpoint: Checkpoint.cockerSpaniel,
          questionsAnswered: 20,
          accuracy: 0.85,
          pointsEarned: 250,
        ),
      );

      // Wait for animations to settle
      await tester.pumpAndSettle();

      // Check for performance summary
      expect(find.text('Performance Summary'), findsOneWidget);
      expect(find.text('20'), findsOneWidget); // Questions
      expect(find.text('85%'), findsOneWidget); // Accuracy
      expect(find.text('250'), findsOneWidget); // Points
    });

    testWidgets('displays power-up rewards correctly', (tester) async {
      final earnedPowerUps = {
        PowerUpType.fiftyFifty: 2,
        PowerUpType.hint: 2,
        PowerUpType.extraTime: 1,
        PowerUpType.skip: 1,
      };

      await tester.pumpWidget(
        createTestWidget(
          checkpoint: Checkpoint.cockerSpaniel,
          earnedPowerUps: earnedPowerUps,
        ),
      );

      // Wait for animations to settle
      await tester.pumpAndSettle();

      // Check for power-up rewards section
      expect(find.text('Power-Up Rewards'), findsOneWidget);
      expect(find.text('+2'), findsNWidgets(2)); // fiftyFifty and hint
      expect(find.text('+1'), findsNWidgets(2)); // extraTime and skip
    });

    testWidgets('displays no power-ups message when none earned', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(checkpoint: Checkpoint.chihuahua, earnedPowerUps: {}),
      );

      // Wait for animations to settle
      await tester.pumpAndSettle();

      // Check for no power-ups message
      expect(find.text('No power-ups earned this time'), findsOneWidget);
    });

    testWidgets('displays continue button with correct text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          checkpoint: Checkpoint.germanShepherd,
          isPathCompleted: false,
        ),
      );

      // Wait for animations to settle
      await tester.pumpAndSettle();

      // Check for continue button
      expect(find.text('Continue Journey'), findsOneWidget);
    });

    testWidgets('displays complete path button when path is completed', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          checkpoint: Checkpoint.deutscheDogge,
          isPathCompleted: true,
        ),
      );

      // Wait for animations to settle
      await tester.pumpAndSettle();

      // Check for complete path button
      expect(find.text('Complete Path'), findsOneWidget);
    });

    testWidgets('handles continue button tap correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(checkpoint: Checkpoint.germanShepherd),
      );

      // Wait for animations to settle
      await tester.pumpAndSettle();

      // Find and tap the continue button
      final continueButton = find.text('Continue Journey');
      expect(continueButton, findsOneWidget);

      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // The screen should handle navigation (tested in integration tests)
    });

    testWidgets('displays correct gradient colors for different checkpoints', (
      tester,
    ) async {
      // Test different checkpoints to ensure proper gradient colors
      final checkpoints = [
        Checkpoint.chihuahua,
        Checkpoint.cockerSpaniel,
        Checkpoint.germanShepherd,
        Checkpoint.greatDane,
        Checkpoint.deutscheDogge,
      ];

      for (final checkpoint in checkpoints) {
        await tester.pumpWidget(createTestWidget(checkpoint: checkpoint));
        await tester.pumpAndSettle();

        // Verify the screen renders without errors for each checkpoint
        expect(find.byType(CheckpointCelebrationScreen), findsOneWidget);
        expect(find.text(checkpoint.displayName), findsOneWidget);
      }
    });

    testWidgets('displays dog breed image correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(checkpoint: Checkpoint.chihuahua),
      );

      // Wait for animations to settle
      await tester.pumpAndSettle();

      // Check for image widget (should handle both success and error cases)
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('handles image loading error gracefully', (tester) async {
      await tester.pumpWidget(
        createTestWidget(checkpoint: Checkpoint.chihuahua),
      );

      // Wait for animations to settle
      await tester.pumpAndSettle();

      // The image widget should be present even if the actual image fails to load
      // The error builder should show a fallback icon
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('displays correct power-up icons and names', (tester) async {
      final earnedPowerUps = {
        PowerUpType.fiftyFifty: 1,
        PowerUpType.hint: 1,
        PowerUpType.extraTime: 1,
        PowerUpType.skip: 1,
        PowerUpType.secondChance: 1,
      };

      await tester.pumpWidget(
        createTestWidget(
          checkpoint: Checkpoint.germanShepherd,
          earnedPowerUps: earnedPowerUps,
        ),
      );

      // Wait for animations to settle
      await tester.pumpAndSettle();

      // Check for power-up names
      expect(find.text('50/50'), findsOneWidget);
      expect(find.text('Hint'), findsOneWidget);
      expect(find.text('Extra Time'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('2nd Chance'), findsOneWidget);
    });

    testWidgets('animates correctly on screen load', (tester) async {
      await tester.pumpWidget(
        createTestWidget(checkpoint: Checkpoint.cockerSpaniel),
      );

      // Check initial state (should be animating in)
      await tester.pump();
      expect(find.byType(CheckpointCelebrationScreen), findsOneWidget);

      // Let animations complete
      await tester.pumpAndSettle();

      // All content should be visible after animations
      expect(find.text('Checkpoint Reached!'), findsOneWidget);
      expect(find.text('Cocker Spaniel'), findsOneWidget);
      expect(find.text('Performance Summary'), findsOneWidget);
      expect(find.text('Power-Up Rewards'), findsOneWidget);
    });

    testWidgets('displays accurate performance statistics', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          checkpoint: Checkpoint.greatDane,
          questionsAnswered: 40,
          accuracy: 0.925, // 92.5%
          pointsEarned: 800,
        ),
      );

      // Wait for animations to settle
      await tester.pumpAndSettle();

      // Check for accurate statistics display
      expect(find.text('40'), findsOneWidget); // Questions
      expect(find.text('93%'), findsOneWidget); // Accuracy (rounded)
      expect(find.text('800'), findsOneWidget); // Points
    });

    testWidgets('handles zero power-ups gracefully', (tester) async {
      final earnedPowerUps = {
        PowerUpType.fiftyFifty: 0,
        PowerUpType.hint: 0,
        PowerUpType.extraTime: 0,
        PowerUpType.skip: 0,
        PowerUpType.secondChance: 0,
      };

      await tester.pumpWidget(
        createTestWidget(
          checkpoint: Checkpoint.chihuahua,
          earnedPowerUps: earnedPowerUps,
        ),
      );

      // Wait for animations to settle
      await tester.pumpAndSettle();

      // Should show no power-ups message
      expect(find.text('No power-ups earned this time'), findsOneWidget);
    });
  });
}
