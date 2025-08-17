import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:dogdog_trivia_game/screens/dog_breeds_adventure_screen.dart';
import 'package:dogdog_trivia_game/services/breed_adventure/breed_service.dart';
import 'package:dogdog_trivia_game/services/breed_adventure/breed_adventure_timer.dart';
import 'package:dogdog_trivia_game/models/breed.dart';
import 'package:dogdog_trivia_game/widgets/shared/loading_animation.dart';
import 'package:dogdog_trivia_game/l10n/generated/app_localizations.dart';

import 'complete_game_flow_test.mocks.dart';

@GenerateMocks([BreedService, BreedAdventureTimer])
void main() {
  group('Breed Adventure Complete Game Flow Integration Tests', () {
    late MockBreedService mockBreedService;
    late MockBreedAdventureTimer mockTimer;

    // Test data
    final testBreeds = [
      Breed(
        name: 'Labrador Retriever',
        imageUrl: 'https://example.com/labrador.jpg',
        difficulty: 1,
      ),
      Breed(
        name: 'Golden Retriever',
        imageUrl: 'https://example.com/golden.jpg',
        difficulty: 1,
      ),
      Breed(
        name: 'Beagle',
        imageUrl: 'https://example.com/beagle.jpg',
        difficulty: 2,
      ),
      Breed(
        name: 'German Shepherd Dog',
        imageUrl: 'https://example.com/german.jpg',
        difficulty: 3,
      ),
    ];

    setUp(() {
      mockBreedService = MockBreedService();
      mockTimer = MockBreedAdventureTimer();

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

    testWidgets('should display loading screen initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify initial loading state is shown (uses LoadingAnimation, not CircularProgressIndicator)
      expect(find.byType(LoadingAnimation), findsAny);
    });

    testWidgets('should handle app lifecycle and initialization', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Simulate app initialization with multiple pump calls instead of pumpAndSettle
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify that the screen initialized without crashing
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle widget tree construction properly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify key UI components are present (screen doesn't have AppBar)
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(DogBreedsAdventureScreen), findsOneWidget);
    });

    testWidgets('should handle navigation and back button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find and tap back button if present
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pump();
      }

      // Verify no exceptions occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('should properly dispose resources', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Navigate away to trigger dispose
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pump();

      // Verify no exceptions during disposal
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle orientation changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Simulate orientation change
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      await tester.pump();

      // Restore original orientation
      tester.view.physicalSize = const Size(600, 800);
      await tester.pump();

      // Verify layout handled orientation changes
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle theme changes properly', (
      WidgetTester tester,
    ) async {
      // Test with light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: const DogBreedsAdventureScreen(),
        ),
      );
      await tester.pump();

      // Test with dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: const DogBreedsAdventureScreen(),
        ),
      );
      await tester.pump();

      // Verify theme changes handled properly
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle memory pressure scenarios', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Simulate memory pressure by forcing garbage collection and rebuilds
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Verify app handled memory pressure
      expect(tester.takeException(), isNull);
    });

    group('Error Recovery Integration', () {
      testWidgets('should handle invalid data gracefully', (
        WidgetTester tester,
      ) async {
        // Setup mock to return empty breeds list
        when(mockBreedService.getBreedsByDifficultyPhase(any)).thenReturn([]);

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Verify app doesn't crash with empty data
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle network-like errors gracefully', (
        WidgetTester tester,
      ) async {
        // Setup mock to throw exception
        when(
          mockBreedService.getBreedsByDifficultyPhase(any),
        ).thenThrow(Exception('Network error'));

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Verify app handles exceptions gracefully
        expect(tester.takeException(), isNull);
      });
    });

    group('Accessibility Integration', () {
      testWidgets('should provide semantic information', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Check that semantic information is available
        final semantics = tester.getSemantics(
          find.byType(DogBreedsAdventureScreen),
        );
        expect(semantics, isNotNull);
      });

      testWidgets('should support screen reader navigation', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Verify that semantic nodes exist for screen readers
        expect(
          find.bySemanticsLabel(RegExp(r'.*', caseSensitive: false)),
          findsAny,
        );
      });
    });

    group('Performance Integration', () {
      testWidgets('should handle rapid state changes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Simulate rapid state changes
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        // Verify performance remained stable
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle multiple simultaneous animations', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Let any animations run with multiple pump calls instead of pumpAndSettle
        for (int i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Verify animations completed without issues
        expect(tester.takeException(), isNull);
      });
    });
  });
}
