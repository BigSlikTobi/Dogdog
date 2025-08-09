import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/services/audio_service.dart';
import 'package:dogdog_trivia_game/services/haptic_service.dart';
import 'package:dogdog_trivia_game/services/tutorial_service.dart';
import 'package:dogdog_trivia_game/services/accessibility_service.dart';
import 'package:dogdog_trivia_game/services/animation_service.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import '../helpers/test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Polish and UX Enhancement Services Tests', () {
    setUp(() {
      TestHelper.setUpTestEnvironment();
    });

    group('AudioService Enhanced Features', () {
      test('should have checkpoint completion sound effect', () async {
        final audioService = AudioService();
        await audioService.initialize();

        // Should not throw when playing checkpoint sound
        expect(
          () => audioService.playCheckpointCompleteSound(),
          returnsNormally,
        );
      });

      test('should have power-up specific sound effects', () async {
        final audioService = AudioService();
        await audioService.initialize();

        // Should handle all power-up types
        for (final powerUpType in PowerUpType.values) {
          expect(
            () => audioService.playPowerUpSpecificSound(powerUpType),
            returnsNormally,
          );
        }
      });

      test('should have milestone and streak bonus sounds', () async {
        final audioService = AudioService();
        await audioService.initialize();

        expect(() => audioService.playMilestoneSound(), returnsNormally);
        expect(() => audioService.playStreakBonusSound(), returnsNormally);
        expect(() => audioService.playPathCompleteSound(), returnsNormally);
      });
    });

    group('HapticService Features', () {
      test('should initialize correctly', () async {
        final hapticService = HapticService();
        await hapticService.initialize();

        expect(hapticService.isEnabled, isA<bool>());
      });

      test('should provide different feedback intensities', () async {
        final hapticService = HapticService();
        await hapticService.initialize();

        // Should not throw for different feedback types
        expect(() => hapticService.lightFeedback(), returnsNormally);
        expect(() => hapticService.mediumFeedback(), returnsNormally);
        expect(() => hapticService.heavyFeedback(), returnsNormally);
        expect(() => hapticService.selectionFeedback(), returnsNormally);
      });

      test('should provide specific feedback for power-ups', () async {
        final hapticService = HapticService();
        await hapticService.initialize();

        for (final powerUpType in PowerUpType.values) {
          expect(
            () => hapticService.powerUpFeedback(powerUpType),
            returnsNormally,
          );
        }
      });

      test('should provide special celebration feedback', () async {
        final hapticService = HapticService();
        await hapticService.initialize();

        expect(
          () => hapticService.checkpointCompleteFeedback(),
          returnsNormally,
        );
        expect(() => hapticService.pathCompleteFeedback(), returnsNormally);
        expect(() => hapticService.streakBonusFeedback(), returnsNormally);
        expect(() => hapticService.milestoneFeedback(), returnsNormally);
      });
    });

    group('TutorialService Features', () {
      test('should initialize correctly', () async {
        final tutorialService = TutorialService();
        await tutorialService.initialize();

        // Should start with tutorials not shown
        expect(tutorialService.isTreasureMapTutorialShown, false);
        expect(tutorialService.isCheckpointTutorialShown, false);
        expect(tutorialService.isPowerUpTutorialShown, false);
        expect(tutorialService.isPathSelectionTutorialShown, false);
      });

      test('should track tutorial completion', () async {
        final tutorialService = TutorialService();
        await tutorialService.initialize();

        // Mark treasure map tutorial as shown
        await tutorialService.markTreasureMapTutorialShown();
        expect(tutorialService.isTreasureMapTutorialShown, true);

        // Check if tutorial should be shown
        expect(
          tutorialService.shouldShowTutorialFor(TutorialType.treasureMap),
          false,
        );
        expect(
          tutorialService.shouldShowTutorialFor(TutorialType.checkpoint),
          true,
        );
      });

      test('should provide tutorial data for all types', () async {
        final tutorialService = TutorialService();
        await tutorialService.initialize();

        for (final tutorialType in TutorialType.values) {
          final tutorialData = tutorialService.getTutorialData(tutorialType);
          expect(tutorialData.title, isNotEmpty);
          expect(tutorialData.steps, isNotEmpty);

          for (final step in tutorialData.steps) {
            expect(step.title, isNotEmpty);
            expect(step.description, isNotEmpty);
          }
        }
      });

      test('should reset all tutorials', () async {
        final tutorialService = TutorialService();
        await tutorialService.initialize();

        // Mark some tutorials as shown
        await tutorialService.markTreasureMapTutorialShown();
        await tutorialService.markCheckpointTutorialShown();

        // Reset all tutorials
        await tutorialService.resetAllTutorials();

        // All should be reset
        expect(tutorialService.isTreasureMapTutorialShown, false);
        expect(tutorialService.isCheckpointTutorialShown, false);
        expect(tutorialService.isPowerUpTutorialShown, false);
        expect(tutorialService.isPathSelectionTutorialShown, false);
      });
    });

    group('AccessibilityService Features', () {
      test('should initialize with default settings', () async {
        final accessibilityService = AccessibilityService();
        await accessibilityService.initialize();

        expect(accessibilityService.isHighContrastEnabled, isA<bool>());
        expect(accessibilityService.isLargeTextEnabled, isA<bool>());
        expect(accessibilityService.isReducedMotionEnabled, isA<bool>());
        expect(accessibilityService.textScaleFactor, isA<double>());
      });

      test('should toggle accessibility settings', () async {
        final accessibilityService = AccessibilityService();
        await accessibilityService.initialize();

        final initialHighContrast = accessibilityService.isHighContrastEnabled;
        await accessibilityService.toggleHighContrast();
        expect(
          accessibilityService.isHighContrastEnabled,
          !initialHighContrast,
        );

        final initialLargeText = accessibilityService.isLargeTextEnabled;
        await accessibilityService.toggleLargeText();
        expect(accessibilityService.isLargeTextEnabled, !initialLargeText);
      });

      test('should provide semantic labels for game elements', () async {
        final accessibilityService = AccessibilityService();
        await accessibilityService.initialize();

        // Test checkpoint semantic label
        final checkpointLabel = accessibilityService.getCheckpointSemanticLabel(
          Checkpoint.chihuahua,
          5,
          10,
        );
        expect(checkpointLabel, contains('Checkpoint'));
        expect(checkpointLabel, contains('5 of 10'));

        // Test power-up semantic label
        final powerUpLabel = accessibilityService.getPowerUpSemanticLabel(
          PowerUpType.fiftyFifty,
          3,
        );
        expect(powerUpLabel, contains('power-up'));
        expect(powerUpLabel, contains('3 available'));

        // Test timer semantic label
        final timerLabel = accessibilityService.getTimerSemanticLabel(
          45,
          false,
        );
        expect(timerLabel, contains('45 seconds'));

        // Test lives semantic label
        final livesLabel = accessibilityService.getLivesSemanticLabel(2, 3);
        expect(livesLabel, contains('2 out of 3'));
      });
    });

    group('AnimationService Features', () {
      test('should provide standard animation durations', () {
        expect(
          AnimationService.shortDuration,
          const Duration(milliseconds: 200),
        );
        expect(
          AnimationService.mediumDuration,
          const Duration(milliseconds: 400),
        );
        expect(
          AnimationService.longDuration,
          const Duration(milliseconds: 600),
        );
      });

      test('should respect accessibility settings for animation duration', () {
        final animationService = AnimationService();

        final normalDuration = animationService.getDuration(
          const Duration(milliseconds: 400),
        );
        expect(normalDuration, isA<Duration>());

        final shouldDisable = animationService.shouldDisableAnimations();
        expect(shouldDisable, isA<bool>());
      });

      test('should provide page transition types', () {
        expect(PageTransitionType.values, hasLength(4));
        expect(PageTransitionType.values, contains(PageTransitionType.fade));
        expect(PageTransitionType.values, contains(PageTransitionType.slide));
        expect(PageTransitionType.values, contains(PageTransitionType.scale));
        expect(
          PageTransitionType.values,
          contains(PageTransitionType.rotation),
        );
      });
    });
  });
}
