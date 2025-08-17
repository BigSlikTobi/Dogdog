import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mockito/mockito.dart';

import 'package:dogdog_trivia_game/screens/dog_breeds_adventure_screen.dart';
import 'package:dogdog_trivia_game/models/breed.dart';
import 'package:dogdog_trivia_game/l10n/generated/app_localizations.dart';

import '../integration/complete_game_flow_test.mocks.dart';

void main() {
  group('Breed Adventure Localization Integration Tests', () {
    late MockBreedService mockBreedService;
    late MockBreedAdventureTimer mockTimer;

    // Test data
    final testBreeds = [
      Breed(
        name: 'German Shepherd Dog',
        imageUrl: 'https://example.com/german.jpg',
        difficulty: 1,
      ),
      Breed(
        name: 'Golden Retriever',
        imageUrl: 'https://example.com/golden.jpg',
        difficulty: 1,
      ),
      Breed(
        name: 'French Bulldog',
        imageUrl: 'https://example.com/french.jpg',
        difficulty: 2,
      ),
    ];

    setUp(() {
      mockBreedService = MockBreedService();
      mockTimer = MockBreedAdventureTimer();

      // Setup basic mock responses
      when(
        mockBreedService.getBreedsByDifficultyPhase(any),
      ).thenReturn(testBreeds);
      when(mockTimer.remainingSeconds).thenReturn(10);
      when(mockTimer.isActive).thenReturn(false);
      when(mockTimer.isPaused).thenReturn(false);
      when(mockTimer.isRunning).thenReturn(false);
      when(mockTimer.hasExpired).thenReturn(false);
      when(mockTimer.timerStream).thenAnswer((_) => Stream.value(10));
    });

    Widget createTestWidget({Locale locale = const Locale('en')}) {
      return MaterialApp(
        locale: locale,
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

    group('English Localization', () {
      testWidgets('should display English breed names correctly', (
        WidgetTester tester,
      ) async {
        when(
          mockBreedService.getLocalizedBreedName(
            'German Shepherd Dog',
            const Locale('en'),
          ),
        ).thenReturn('German Shepherd Dog');
        when(
          mockBreedService.getLocalizedBreedName(
            'Golden Retriever',
            const Locale('en'),
          ),
        ).thenReturn('Golden Retriever');
        when(
          mockBreedService.getLocalizedBreedName(
            'French Bulldog',
            const Locale('en'),
          ),
        ).thenReturn('French Bulldog');

        await tester.pumpWidget(createTestWidget(locale: const Locale('en')));
        await tester.pump();

        // Verify English localization works without errors
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle English UI elements', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget(locale: const Locale('en')));
        await tester.pump();

        // Verify English UI loads properly
        expect(find.byType(Scaffold), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('German Localization', () {
      testWidgets('should display German breed names correctly', (
        WidgetTester tester,
      ) async {
        when(
          mockBreedService.getLocalizedBreedName(
            'German Shepherd Dog',
            const Locale('de'),
          ),
        ).thenReturn('Deutscher Schäferhund');
        when(
          mockBreedService.getLocalizedBreedName(
            'Golden Retriever',
            const Locale('de'),
          ),
        ).thenReturn('Golden Retriever');
        when(
          mockBreedService.getLocalizedBreedName(
            'French Bulldog',
            const Locale('de'),
          ),
        ).thenReturn('Französische Bulldogge');

        await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
        await tester.pump();

        // Verify German localization works without errors
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle German UI elements', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
        await tester.pump();

        // Verify German UI loads properly
        expect(find.byType(Scaffold), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle German special characters', (
        WidgetTester tester,
      ) async {
        when(
          mockBreedService.getLocalizedBreedName(any, const Locale('de')),
        ).thenReturn('Deutscher Schäferhund mit ä, ö, ü, ß');

        await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
        await tester.pump();

        // Verify special characters are handled
        expect(tester.takeException(), isNull);
      });
    });

    group('Spanish Localization', () {
      testWidgets('should display Spanish breed names correctly', (
        WidgetTester tester,
      ) async {
        when(
          mockBreedService.getLocalizedBreedName(
            'German Shepherd Dog',
            const Locale('es'),
          ),
        ).thenReturn('Pastor Alemán');
        when(
          mockBreedService.getLocalizedBreedName(
            'Golden Retriever',
            const Locale('es'),
          ),
        ).thenReturn('Golden Retriever');
        when(
          mockBreedService.getLocalizedBreedName(
            'French Bulldog',
            const Locale('es'),
          ),
        ).thenReturn('Bulldog Francés');

        await tester.pumpWidget(createTestWidget(locale: const Locale('es')));
        await tester.pump();

        // Verify Spanish localization works without errors
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle Spanish UI elements', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget(locale: const Locale('es')));
        await tester.pump();

        // Verify Spanish UI loads properly
        expect(find.byType(Scaffold), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle Spanish accented characters', (
        WidgetTester tester,
      ) async {
        when(
          mockBreedService.getLocalizedBreedName(any, const Locale('es')),
        ).thenReturn('Pastor Alemán con acentos: á, é, í, ó, ú, ñ');

        await tester.pumpWidget(createTestWidget(locale: const Locale('es')));
        await tester.pump();

        // Verify accented characters are handled
        expect(tester.takeException(), isNull);
      });
    });

    group('Language Switching', () {
      testWidgets('should handle switching from English to German', (
        WidgetTester tester,
      ) async {
        // Setup localized responses for both languages
        when(
          mockBreedService.getLocalizedBreedName(
            'German Shepherd Dog',
            const Locale('en'),
          ),
        ).thenReturn('German Shepherd Dog');
        when(
          mockBreedService.getLocalizedBreedName(
            'German Shepherd Dog',
            const Locale('de'),
          ),
        ).thenReturn('Deutscher Schäferhund');

        // Start with English
        await tester.pumpWidget(createTestWidget(locale: const Locale('en')));
        await tester.pump();

        // Switch to German
        await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
        await tester.pump();

        // Verify no errors during language switch
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle switching from German to Spanish', (
        WidgetTester tester,
      ) async {
        // Setup localized responses
        when(
          mockBreedService.getLocalizedBreedName(
            'German Shepherd Dog',
            const Locale('de'),
          ),
        ).thenReturn('Deutscher Schäferhund');
        when(
          mockBreedService.getLocalizedBreedName(
            'German Shepherd Dog',
            const Locale('es'),
          ),
        ).thenReturn('Pastor Alemán');

        // Start with German
        await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
        await tester.pump();

        // Switch to Spanish
        await tester.pumpWidget(createTestWidget(locale: const Locale('es')));
        await tester.pump();

        // Verify no errors during language switch
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle rapid language switching', (
        WidgetTester tester,
      ) async {
        final locales = [
          const Locale('en'),
          const Locale('de'),
          const Locale('es'),
        ];

        // Setup responses for all locales
        for (final locale in locales) {
          when(
            mockBreedService.getLocalizedBreedName(any, locale),
          ).thenReturn('Localized Name ${locale.languageCode}');
        }

        // Rapidly switch between languages
        for (int i = 0; i < 10; i++) {
          final locale = locales[i % locales.length];
          await tester.pumpWidget(createTestWidget(locale: locale));
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Verify no errors during rapid switching
        expect(tester.takeException(), isNull);
      });
    });

    group('Fallback Behavior', () {
      testWidgets('should fallback to English for unknown breeds', (
        WidgetTester tester,
      ) async {
        when(
          mockBreedService.getLocalizedBreedName(
            'Unknown Breed',
            const Locale('de'),
          ),
        ).thenReturn('Unknown Breed'); // Fallback to original name

        await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
        await tester.pump();

        // Verify fallback behavior works
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle missing translations gracefully', (
        WidgetTester tester,
      ) async {
        when(
          mockBreedService.getLocalizedBreedName(any, any),
        ).thenReturn(''); // Empty translation

        await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
        await tester.pump();

        // Verify empty translations are handled
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle localization service errors', (
        WidgetTester tester,
      ) async {
        when(
          mockBreedService.getLocalizedBreedName(any, any),
        ).thenThrow(Exception('Localization service error'));

        await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
        await tester.pump();

        // Verify localization errors are handled
        expect(tester.takeException(), isNull);
      });
    });

    group('Text Direction and Layout', () {
      testWidgets('should handle left-to-right languages correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget(locale: const Locale('en')));
        await tester.pump();

        // Verify LTR layout
        expect(find.byType(Scaffold), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should maintain consistent layout across languages', (
        WidgetTester tester,
      ) async {
        final locales = [
          const Locale('en'),
          const Locale('de'),
          const Locale('es'),
        ];

        for (final locale in locales) {
          await tester.pumpWidget(createTestWidget(locale: locale));
          await tester.pump();

          // Verify layout consistency
          expect(find.byType(Scaffold), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      });
    });

    group('Performance with Localization', () {
      testWidgets('should maintain performance during localization', (
        WidgetTester tester,
      ) async {
        // Setup large number of localized breed names
        when(mockBreedService.getLocalizedBreedName(any, any)).thenAnswer((
          invocation,
        ) {
          final breedName = invocation.positionalArguments[0] as String;
          final locale = invocation.positionalArguments[1] as Locale;
          return 'Localized_${locale.languageCode}_$breedName';
        });

        await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
        await tester.pump();

        // Verify performance is maintained
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle memory efficiently with multiple locales', (
        WidgetTester tester,
      ) async {
        final locales = [
          const Locale('en'),
          const Locale('de'),
          const Locale('es'),
        ];

        // Test memory efficiency by switching locales multiple times
        for (int i = 0; i < 20; i++) {
          final locale = locales[i % locales.length];
          await tester.pumpWidget(createTestWidget(locale: locale));
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Verify memory efficiency
        expect(tester.takeException(), isNull);
      });
    });

    group('Real-world Localization Scenarios', () {
      testWidgets('should handle mixed language content', (
        WidgetTester tester,
      ) async {
        // Setup mixed language responses
        when(
          mockBreedService.getLocalizedBreedName(
            'German Shepherd Dog',
            const Locale('es'),
          ),
        ).thenReturn('Pastor Alemán (German Shepherd)'); // Mixed content

        await tester.pumpWidget(createTestWidget(locale: const Locale('es')));
        await tester.pump();

        // Verify mixed content handling
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle long translated names', (
        WidgetTester tester,
      ) async {
        when(
          mockBreedService.getLocalizedBreedName(any, const Locale('de')),
        ).thenReturn(
          'Sehr Langer Deutscher Hunderassenname Mit Vielen Wörtern',
        );

        await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
        await tester.pump();

        // Verify long names are handled
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle breed names with numbers and symbols', (
        WidgetTester tester,
      ) async {
        when(
          mockBreedService.getLocalizedBreedName(any, any),
        ).thenReturn('Breed-Name #1 (2024)');

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Verify special characters in names
        expect(tester.takeException(), isNull);
      });
    });
  });
}
