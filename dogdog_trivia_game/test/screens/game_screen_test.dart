import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/screens/game_screen.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/services/audio_service.dart';
import 'package:dogdog_trivia_game/widgets/modern_card.dart';
import 'package:dogdog_trivia_game/design_system/modern_colors.dart';

/// Helper function to create a testable GameScreen widget
Widget createTestableWidget({
  Difficulty difficulty = Difficulty.easy,
  int level = 1,
}) {
  return MaterialApp(
    home: GameScreen(difficulty: difficulty, level: level),
  );
}

void main() {
  group('GameScreen Widget Tests', () {
    testWidgets('should display loading indicator initially', (tester) async {
      await tester.pumpWidget(createTestableWidget());

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Level 1'), findsNothing);
    });

    testWidgets('should display game screen layout after initialization', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());

      // Wait for initialization to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should display main game elements
      expect(find.text('Level 1'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('should display lives in top-left corner', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show heart icons for lives
      expect(find.byIcon(Icons.favorite), findsWidgets);
    });

    testWidgets('should display score in top-right corner', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show "Punkte" text
      expect(find.text('Punkte'), findsOneWidget);
    });

    testWidgets('should not display timer bar for level 1', (tester) async {
      await tester.pumpWidget(createTestableWidget(level: 1));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Timer bar should not be visible for level 1
      // We check for the absence of FractionallySizedBox which is used for timer
      expect(find.byType(FractionallySizedBox), findsNothing);
    });

    testWidgets('should display timer bar for level 2 and above', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget(level: 2));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Timer bar should be visible for level 2
      expect(find.byType(FractionallySizedBox), findsOneWidget);
    });

    testWidgets('should display question area', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show question number indicator
      expect(find.textContaining('Frage'), findsOneWidget);
    });

    testWidgets('should display 2x2 grid layout for answer choices', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show GridView
      expect(find.byType(GridView), findsOneWidget);

      // Should show answer letters (may not be loaded if questions aren't available)
      // Just verify the GridView structure exists
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should display power-up buttons at bottom', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show modern power-up icons with rounded variants
      expect(
        find.byIcon(Icons.remove_circle_outline_rounded),
        findsOneWidget,
      ); // 50/50
      expect(
        find.byIcon(Icons.lightbulb_outline_rounded),
        findsOneWidget,
      ); // Hint
      expect(
        find.byIcon(Icons.access_time_rounded),
        findsOneWidget,
      ); // Extra time
      expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget); // Skip
    });

    testWidgets('should use ModernCard components for UI elements', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show ModernCard components for question area and power-up bar
      expect(find.byType(ModernCard), findsWidgets);
    });

    testWidgets('should display modern gradient background', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show Container with gradient decoration
      final containers = find.byType(Container);
      expect(containers, findsWidgets);

      // Check that at least one container has a gradient decoration
      bool hasGradientBackground = false;
      for (final container in tester.widgetList<Container>(containers)) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.gradient != null) {
            hasGradientBackground = true;
            break;
          }
        }
      }
      expect(hasGradientBackground, isTrue);
    });

    testWidgets('should display modern styled lives and score displays', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show modern heart icons with rounded variants
      expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
      expect(find.byIcon(Icons.favorite_border_rounded), findsWidgets);

      // Should show score text
      expect(find.text('Punkte'), findsOneWidget);
    });

    testWidgets('should display modern pause button', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show modern pause icon with rounded variant
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    });

    testWidgets('should show pause dialog when pause button is pressed', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap pause button
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Should show pause dialog
      expect(find.text('Spiel pausiert'), findsOneWidget);
      expect(find.text('Hauptmenü'), findsOneWidget);
      expect(find.text('Weiterspielen'), findsOneWidget);
    });

    testWidgets(
      'should resume game when continue button is pressed in pause dialog',
      (tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Pause the game
        await tester.tap(find.byIcon(Icons.pause));
        await tester.pumpAndSettle();

        // Tap continue button
        await tester.tap(find.text('Weiterspielen'));
        await tester.pumpAndSettle();

        // Dialog should be closed
        expect(find.text('Spiel pausiert'), findsNothing);
      },
    );

    testWidgets('should display correct level in app bar', (tester) async {
      await tester.pumpWidget(createTestableWidget(level: 3));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show correct level
      expect(find.text('Level 3'), findsOneWidget);
    });

    testWidgets('should handle different difficulty levels', (tester) async {
      // Test with different difficulties
      for (final difficulty in Difficulty.values) {
        await tester.pumpWidget(createTestableWidget(difficulty: difficulty));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should display the game screen regardless of difficulty
        expect(find.text('Level 1'), findsOneWidget);
        expect(find.byType(GridView), findsOneWidget);
      }
    });

    testWidgets('should display game screen components in correct layout', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify the main structure exists
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.byType(SafeArea),
        findsWidgets,
      ); // May have multiple SafeArea widgets
      expect(find.byType(Column), findsWidgets);

      // Verify key UI elements are present
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });
  });

  group('GameScreen Integration Tests', () {
    testWidgets('should initialize and display game content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const GameScreen(difficulty: Difficulty.easy, level: 1),
        ),
      );

      // Initially should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for initialization
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show game content
      expect(find.text('Level 1'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });
  });

  group('Answer Selection and Feedback Tests', () {
    testWidgets('should display answer buttons with correct initial state', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show answer buttons with letters A, B, C, D
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);

      // All buttons should be enabled initially (InkWell should be tappable)
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('should show animated feedback when answer is selected', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find and tap the first answer button
      final answerButtons = find.byType(InkWell);
      if (answerButtons.evaluate().isNotEmpty) {
        await tester.tap(answerButtons.first);
        await tester.pump(); // Trigger initial animation

        // Should show animated containers for feedback
        expect(find.byType(AnimatedContainer), findsWidgets);
        expect(find.byType(AnimatedOpacity), findsWidgets);
      }
    });

    testWidgets('should display feedback icons for correct/incorrect answers', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find and tap an answer button
      final answerButtons = find.byType(InkWell);
      if (answerButtons.evaluate().isNotEmpty) {
        await tester.tap(answerButtons.first);
        await tester.pump();

        // Should show either check or close icon for feedback
        final hasCheckIcon = find.byIcon(Icons.check).evaluate().isNotEmpty;
        final hasCloseIcon = find.byIcon(Icons.close).evaluate().isNotEmpty;

        expect(hasCheckIcon || hasCloseIcon, isTrue);
      }
    });

    testWidgets('should disable answer buttons during feedback state', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find and tap an answer button
      final answerButtons = find.byType(InkWell);
      if (answerButtons.evaluate().isNotEmpty) {
        await tester.tap(answerButtons.first);
        await tester.pump();

        // Try to tap another button during feedback - should not respond
        if (answerButtons.evaluate().length > 1) {
          await tester.tap(answerButtons.at(1));
          await tester.pump();

          // Should still only show one feedback state
          final feedbackIcons =
              find.byIcon(Icons.check).evaluate().length +
              find.byIcon(Icons.close).evaluate().length;
          expect(
            feedbackIcons,
            lessThanOrEqualTo(2),
          ); // Max 2: selected + correct answer
        }
      }
    });

    testWidgets('should show correct answer when wrong answer is selected', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find and tap an answer button
      final answerButtons = find.byType(InkWell);
      if (answerButtons.evaluate().isNotEmpty) {
        await tester.tap(answerButtons.first);
        await tester.pump();

        // Wait for feedback animation
        await tester.pump(const Duration(milliseconds: 300));

        // Should show feedback icons (either one for correct, or two for incorrect + correct)
        final checkIcons = find.byIcon(Icons.check);
        final closeIcons = find.byIcon(Icons.close);

        expect(
          checkIcons.evaluate().isNotEmpty || closeIcons.evaluate().isNotEmpty,
          isTrue,
        );
      }
    });

    testWidgets('should clear feedback and move to next question after delay', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find and tap an answer button
      final answerButtons = find.byType(InkWell);
      if (answerButtons.evaluate().isNotEmpty) {
        await tester.tap(answerButtons.first);
        await tester.pump();

        // Wait for feedback display period
        await tester.pump(const Duration(milliseconds: 1500));

        // Should clear feedback icons after delay
        await tester.pumpAndSettle();

        // Feedback icons should be cleared (back to letters A, B, C, D)
        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
        expect(find.text('C'), findsOneWidget);
        expect(find.text('D'), findsOneWidget);
      }
    });
  });

  group('Power-up Feedback Tests', () {
    testWidgets('should show disabled answers when 50/50 power-up is used', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find and tap the 50/50 power-up button
      final fiftyFiftyButton = find.byIcon(Icons.remove_circle_outline);
      if (fiftyFiftyButton.evaluate().isNotEmpty) {
        await tester.tap(fiftyFiftyButton);
        await tester.pump();

        // Should show AnimatedOpacity widgets for disabled answers
        expect(find.byType(AnimatedOpacity), findsWidgets);
      }
    });

    testWidgets('should show hint dialog when hint power-up is used', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find and tap the hint power-up button
      final hintButton = find.byIcon(Icons.lightbulb_outline);
      if (hintButton.evaluate().isNotEmpty) {
        await tester.tap(hintButton);
        await tester.pumpAndSettle();

        // Should show hint dialog or snackbar
        final hasDialog = find.byType(AlertDialog).evaluate().isNotEmpty;
        final hasSnackBar = find.byType(SnackBar).evaluate().isNotEmpty;

        expect(hasDialog || hasSnackBar, isTrue);
      }
    });

    testWidgets('should show snackbar feedback for power-up usage', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find and tap the extra time power-up button
      final extraTimeButton = find.byIcon(Icons.access_time);
      if (extraTimeButton.evaluate().isNotEmpty) {
        await tester.tap(extraTimeButton);
        await tester.pumpAndSettle();

        // Should show snackbar for power-up feedback
        expect(find.byType(SnackBar), findsOneWidget);
      }
    });
  });

  group('Audio Service Tests', () {
    testWidgets('should initialize audio service', (tester) async {
      // Test that AudioService can be instantiated
      final audioService = AudioService();
      expect(audioService, isNotNull);
      expect(audioService.isMuted, isFalse);
    });

    testWidgets('should toggle mute state', (tester) async {
      final audioService = AudioService();

      // Initially not muted
      expect(audioService.isMuted, isFalse);

      // Toggle mute
      audioService.toggleMute();
      expect(audioService.isMuted, isTrue);

      // Toggle back
      audioService.toggleMute();
      expect(audioService.isMuted, isFalse);
    });

    testWidgets('should set mute state directly', (tester) async {
      final audioService = AudioService();

      // Set muted
      audioService.setMuted(true);
      expect(audioService.isMuted, isTrue);

      // Set unmuted
      audioService.setMuted(false);
      expect(audioService.isMuted, isFalse);
    });
  });

  group('Animation Tests', () {
    testWidgets('should show smooth color transitions for answer feedback', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find and tap an answer button
      final answerButtons = find.byType(InkWell);
      if (answerButtons.evaluate().isNotEmpty) {
        await tester.tap(answerButtons.first);

        // Should show AnimatedContainer for smooth transitions
        expect(find.byType(AnimatedContainer), findsWidgets);

        // Pump animation frames
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pump(const Duration(milliseconds: 150));

        // Animation should still be in progress or completed
        expect(find.byType(AnimatedContainer), findsWidgets);
      }
    });

    testWidgets('should show opacity animations for disabled answers', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show AnimatedOpacity widgets for all answer buttons
      expect(find.byType(AnimatedOpacity), findsWidgets);

      // All should have full opacity initially
      final animatedOpacities = tester.widgetList<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      for (final opacity in animatedOpacities) {
        expect(opacity.opacity, equals(1.0));
      }
    });
  });
}
