import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/l10n/generated/app_localizations.dart';

void main() {
  group('German Locale Tests', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'), // Force German locale
        home: child,
      );
    }

    testWidgets('German localization strings are loaded correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.homeScreen_welcomeTitle),
                    Text(l10n.homeScreen_welcomeSubtitle),
                    Text(l10n.homeScreen_startButton),
                    Text(l10n.homeScreen_achievementsButton),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test German home screen strings
      expect(find.text('Willkommen bei DogDog!'), findsOneWidget);
      expect(
        find.text('Teste dein Wissen über Hunde in diesem lustigen Quiz!'),
        findsOneWidget,
      );
      expect(find.text('Quiz starten'), findsOneWidget);
      expect(find.text('Erfolge'), findsOneWidget);
    });

    testWidgets('German difficulty strings are loaded correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.difficultyScreen_title),
                    Text(l10n.difficulty_easy),
                    Text(l10n.difficulty_medium),
                    Text(l10n.difficulty_hard),
                    Text(l10n.difficulty_expert),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test German difficulty strings
      expect(find.text('Schwierigkeit wählen'), findsOneWidget);
      expect(find.text('Leicht'), findsOneWidget);
      expect(find.text('Mittel'), findsOneWidget);
      expect(find.text('Schwer'), findsOneWidget);
      expect(find.text('Experte'), findsOneWidget);
    });

    testWidgets('German parameter substitution works correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.gameScreen_level(5)),
                    Text(l10n.gameScreen_questionCounter(3, 10)),
                    Text(l10n.difficulty_points_per_question(15)),
                    Text(l10n.homeScreen_progress_currentRank('Mops')),
                    Text(l10n.homeScreen_progress_nextRank('Cocker Spaniel')),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test parameter substitution
      expect(find.text('Level 5'), findsOneWidget);
      expect(find.text('Frage 3 von 10'), findsOneWidget);
      expect(find.text('15 Punkte pro Frage'), findsOneWidget);
      expect(find.text('Aktueller Rang: Mops'), findsOneWidget);
      expect(find.text('Nächster: Cocker Spaniel'), findsOneWidget);
    });

    testWidgets('German rank names display correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.rank_chihuahua),
                    Text(l10n.rank_pug),
                    Text(l10n.rank_cockerSpaniel),
                    Text(l10n.rank_germanShepherd),
                    Text(l10n.rank_greatDane),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test German dog breed names
      expect(find.text('Chihuahua'), findsOneWidget);
      expect(find.text('Mops'), findsOneWidget);
      expect(find.text('Cocker Spaniel'), findsOneWidget);
      expect(find.text('Deutscher Schäferhund'), findsOneWidget);
      expect(find.text('Deutsche Dogge'), findsOneWidget);
    });

    testWidgets('German power-up names display correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.powerUp_fiftyFifty),
                    Text(l10n.powerUp_hint),
                    Text(l10n.powerUp_extraTime),
                    Text(l10n.powerUp_skip),
                    Text(l10n.powerUp_secondChance),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test German power-up names
      expect(find.text('Kau 50/50'), findsOneWidget);
      expect(find.text('Hinweis'), findsOneWidget);
      expect(find.text('Extra Zeit'), findsOneWidget);
      expect(find.text('Überspringen'), findsOneWidget);
      expect(find.text('Zweite Chance'), findsOneWidget);
    });

    testWidgets('German error messages display correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.errorScreen_title),
                    Text(l10n.errorScreen_servicesRestarted),
                    Text(l10n.errorScreen_cacheCleared),
                    Text(l10n.errorScreen_settingsReset),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test German error messages
      expect(find.text('Fehlerwiederherstellung'), findsOneWidget);
      expect(find.text('Dienste erfolgreich neu gestartet'), findsOneWidget);
      expect(find.text('Cache erfolgreich geleert'), findsOneWidget);
      expect(
        find.text('Einstellungen auf Standard zurückgesetzt'),
        findsOneWidget,
      );
    });

    testWidgets('German feedback messages display correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.feedback_correct),
                    Text(l10n.feedback_incorrect),
                    Text(l10n.feedback_timeUp),
                    Text(l10n.resultScreen_funFact),
                    Text(l10n.resultScreen_nextQuestion),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test German feedback messages
      expect(find.text('Richtig!'), findsOneWidget);
      expect(find.text('Falsch'), findsOneWidget);
      expect(find.text('Zeit ist um!'), findsOneWidget);
      expect(find.text('Wissenswertes:'), findsOneWidget);
      expect(find.text('Nächste Frage'), findsOneWidget);
    });
  });
}
