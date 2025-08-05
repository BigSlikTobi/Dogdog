import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/l10n/generated/app_localizations.dart';

void main() {
  group('Spanish Locale Tests', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'), // Force Spanish locale
        home: child,
      );
    }

    testWidgets('Spanish localization strings are loaded correctly', (
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

      // Test Spanish home screen strings
      expect(find.text('¡Bienvenido a DogDog!'), findsOneWidget);
      expect(
        find.text(
          '¡Pon a prueba tu conocimiento sobre perros en este divertido quiz!',
        ),
        findsOneWidget,
      );
      expect(find.text('Comenzar Quiz'), findsOneWidget);
      expect(find.text('Logros'), findsOneWidget);
    });

    testWidgets('Spanish difficulty strings are loaded correctly', (
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

      // Test Spanish difficulty strings
      expect(find.text('Elegir Dificultad'), findsOneWidget);
      expect(find.text('Fácil'), findsOneWidget);
      expect(find.text('Medio'), findsOneWidget);
      expect(find.text('Difícil'), findsOneWidget);
      expect(find.text('Experto'), findsOneWidget);
    });

    testWidgets('Spanish parameter substitution works correctly', (
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
      expect(find.text('Nivel 5'), findsOneWidget);
      expect(find.text('Pregunta 3 de 10'), findsOneWidget);
      expect(find.text('15 puntos por pregunta'), findsOneWidget);
      expect(find.text('Rango Actual: Pug'), findsOneWidget);
      expect(find.text('Siguiente: Cocker Spaniel'), findsOneWidget);
    });

    testWidgets('Spanish rank names display correctly', (
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

      // Test Spanish dog breed names
      expect(find.text('Chihuahua'), findsOneWidget);
      expect(find.text('Pug'), findsOneWidget);
      expect(find.text('Cocker Spaniel'), findsOneWidget);
      expect(find.text('Pastor Alemán'), findsOneWidget);
      expect(find.text('Gran Danés'), findsOneWidget);
    });

    testWidgets('Spanish power-up names display correctly', (
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

      // Test Spanish power-up names
      expect(find.text('Masticar 50/50'), findsOneWidget);
      expect(find.text('Pista'), findsOneWidget);
      expect(find.text('Tiempo Extra'), findsOneWidget);
      expect(find.text('Saltar'), findsOneWidget);
      expect(find.text('Segunda Oportunidad'), findsOneWidget);
    });

    testWidgets('Spanish error messages display correctly', (
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

      // Test Spanish error messages
      expect(find.text('Recuperación de Errores'), findsOneWidget);
      expect(find.text('Servicios reiniciados exitosamente'), findsOneWidget);
      expect(find.text('Caché limpiado exitosamente'), findsOneWidget);
      expect(
        find.text('Configuraciones restablecidas a valores predeterminados'),
        findsOneWidget,
      );
    });

    testWidgets('Spanish feedback messages display correctly', (
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

      // Test Spanish feedback messages
      expect(find.text('¡Correcto!'), findsOneWidget);
      expect(find.text('Incorrecto'), findsOneWidget);
      expect(find.text('¡Se acabó el tiempo!'), findsOneWidget);
      expect(find.text('Dato Curioso:'), findsOneWidget);
      expect(find.text('Siguiente Pregunta'), findsOneWidget);
    });
  });
}
