import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/l10n/generated/app_localizations.dart';

void main() {
  group('English Locale Tests', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'), // Force English locale
        home: child,
      );
    }

    testWidgets('English localization strings are loaded correctly', (
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

      // Test English home screen strings
      expect(find.text('Welcome to DogDog!'), findsOneWidget);
      expect(
        find.text('Test your knowledge about dogs in this fun quiz!'),
        findsOneWidget,
      );
      expect(find.text('Start Quiz'), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);
    });

    testWidgets('English difficulty strings are loaded correctly', (
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

      // Test English difficulty strings
      expect(find.text('Choose Difficulty'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('Expert'), findsOneWidget);
    });

    testWidgets('English parameter substitution works correctly', (
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
                    Text(l10n.homeScreen_progress_currentRank('Pug')),
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
      expect(find.text('Question 3 of 10'), findsOneWidget);
      expect(find.text('15 points per question'), findsOneWidget);
      expect(find.text('Current Rank: Pug'), findsOneWidget);
      expect(find.text('Next: Cocker Spaniel'), findsOneWidget);
    });

    testWidgets('English rank names display correctly', (
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

      // Test English dog breed names
      expect(find.text('Chihuahua'), findsOneWidget);
      expect(find.text('Pug'), findsOneWidget);
      expect(find.text('Cocker Spaniel'), findsOneWidget);
      expect(find.text('German Shepherd'), findsOneWidget);
      expect(find.text('Great Dane'), findsOneWidget);
    });

    testWidgets('English power-up names display correctly', (
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

      // Test English power-up names
      expect(find.text('Chew 50/50'), findsOneWidget);
      expect(find.text('Hint'), findsOneWidget);
      expect(find.text('Extra Time'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Second Chance'), findsOneWidget);
    });

    testWidgets('English error messages display correctly', (
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

      // Test English error messages
      expect(find.text('Error Recovery'), findsOneWidget);
      expect(find.text('Services restarted successfully'), findsOneWidget);
      expect(find.text('Cache cleared successfully'), findsOneWidget);
      expect(find.text('Settings reset to defaults'), findsOneWidget);
    });

    testWidgets('English feedback messages display correctly', (
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

      // Test English feedback messages
      expect(find.text('Correct!'), findsOneWidget);
      expect(find.text('Incorrect'), findsOneWidget);
      expect(find.text('Time\'s up!'), findsOneWidget);
      expect(find.text('Fun Fact:'), findsOneWidget);
      expect(find.text('Next Question'), findsOneWidget);
    });
  });
}
