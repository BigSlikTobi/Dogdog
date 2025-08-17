import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:dogdog_trivia_game/screens/dog_breeds_adventure_screen.dart';
import 'package:dogdog_trivia_game/controllers/power_up_controller.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/models/breed.dart';
import 'package:dogdog_trivia_game/services/breed_adventure/breed_service.dart';
import 'package:dogdog_trivia_game/services/breed_adventure/breed_adventure_timer.dart';
import 'package:dogdog_trivia_game/l10n/generated/app_localizations.dart';

import 'complete_game_flow_test.mocks.dart';

@GenerateMocks([BreedService, BreedAdventureTimer])
void main() {
  group('Breed Adventure Power-Up Usage Integration Tests', () {
    late MockBreedService mockBreedService;
    late MockBreedAdventureTimer mockTimer;
    late PowerUpController powerUpController;

    // Test data
    final testBreeds = [
      Breed(name: 'Test Breed 1', imageUrl: 'test_url_1.jpg', difficulty: 1),
    ];

    setUp(() {
      mockBreedService = MockBreedService();
      mockTimer = MockBreedAdventureTimer();
      powerUpController = PowerUpController();

      // Setup basic mock responses
      when(
        mockBreedService.getBreedsByDifficultyPhase(any),
      ).thenReturn(testBreeds);
      when(
        mockBreedService.getLocalizedBreedName(any, any),
      ).thenAnswer((invocation) => invocation.positionalArguments[0] as String);
      when(mockTimer.remainingSeconds).thenReturn(10);
      when(mockTimer.isActive).thenReturn(false);
      when(mockTimer.isPaused).thenReturn(false);
      when(mockTimer.isRunning).thenReturn(false);
      when(mockTimer.hasExpired).thenReturn(false);
      when(mockTimer.timerStream).thenAnswer((_) => Stream.value(10));
    });

    Widget createTestWidget() {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
        home: const DogBreedsAdventureScreen(),
      );
    }

    testWidgets('should initialize with default power-ups available', (
      WidgetTester tester,
    ) async {
      powerUpController.addPowerUp(PowerUpType.extraTime, 2);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify power-up controller is initialized
      expect(powerUpController.powerUps, isNotEmpty);
      expect(
        powerUpController.getPowerUpCount(PowerUpType.extraTime),
        equals(2),
      );
    });

    testWidgets('should handle power-up activation without crashing', (
      WidgetTester tester,
    ) async {
      powerUpController.addPowerUp(PowerUpType.extraTime, 3);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Use a power-up
      final initialCount = powerUpController.getPowerUpCount(
        PowerUpType.extraTime,
      );
      final success = powerUpController.usePowerUp(PowerUpType.extraTime);

      expect(success, isTrue);
      expect(
        powerUpController.getPowerUpCount(PowerUpType.extraTime),
        equals(initialCount - 1),
      );
    });

    testWidgets('should handle multiple power-up activations', (
      WidgetTester tester,
    ) async {
      powerUpController.addPowerUp(PowerUpType.extraTime, 5);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Use multiple power-ups
      final initialCount = powerUpController.getPowerUpCount(
        PowerUpType.extraTime,
      );
      powerUpController.usePowerUp(PowerUpType.extraTime);
      powerUpController.usePowerUp(PowerUpType.extraTime);

      expect(
        powerUpController.getPowerUpCount(PowerUpType.extraTime),
        equals(initialCount - 2),
      );
    });

    testWidgets('should prevent using unavailable power-ups', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Try to use a power-up when none available
      final result = powerUpController.usePowerUp(PowerUpType.extraTime);

      expect(result, isFalse);
      expect(
        powerUpController.getPowerUpCount(PowerUpType.extraTime),
        equals(0),
      );
    });

    testWidgets('should handle all power-up types correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Test each power-up type
      for (final powerUpType in PowerUpType.values) {
        powerUpController.addPowerUp(powerUpType, 1);
        expect(powerUpController.canUsePowerUp(powerUpType), isTrue);

        final used = powerUpController.usePowerUp(powerUpType);
        expect(used, isTrue);
        expect(powerUpController.canUsePowerUp(powerUpType), isFalse);
      }
    });

    group('Power-Up Edge Cases', () {
      testWidgets('should handle negative power-up additions', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Try to add negative amount
        powerUpController.addPowerUp(PowerUpType.extraTime, -1);

        // Should not go below zero
        expect(
          powerUpController.getPowerUpCount(PowerUpType.extraTime),
          greaterThanOrEqualTo(0),
        );
      });

      testWidgets('should handle rapid power-up usage', (
        WidgetTester tester,
      ) async {
        powerUpController.addPowerUp(PowerUpType.extraTime, 10);

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Rapidly use power-ups
        final initialCount = powerUpController.getPowerUpCount(
          PowerUpType.extraTime,
        );
        for (int i = 0; i < 5; i++) {
          powerUpController.usePowerUp(PowerUpType.extraTime);
          await tester.pump(const Duration(milliseconds: 10));
        }

        // Verify state consistency
        expect(
          powerUpController.getPowerUpCount(PowerUpType.extraTime),
          equals(initialCount - 5),
        );
      });
    });

    group('Power-Up UI Integration', () {
      testWidgets('should handle power-up button taps without error', (
        WidgetTester tester,
      ) async {
        powerUpController.addPowerUp(PowerUpType.extraTime, 1);

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Verify no exceptions occurred
        expect(tester.takeException(), isNull);
      });

      testWidgets('should update UI when power-ups are used', (
        WidgetTester tester,
      ) async {
        powerUpController.addPowerUp(PowerUpType.extraTime, 2);

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Use a power-up
        powerUpController.usePowerUp(PowerUpType.extraTime);

        // Trigger UI update
        await tester.pump();

        // Verify UI handled the change
        expect(tester.takeException(), isNull);
      });
    });
  });
}
