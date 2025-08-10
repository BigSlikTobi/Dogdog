import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/utils/path_localization.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/l10n/generated/app_localizations.dart';

void main() {
  group('Path Localization Integration', () {
    Widget createTestWidget({required Locale locale, required Widget child}) {
      return MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );
    }

    group('PathType.breedAdventure localization', () {
      testWidgets('should return German localized name and description', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            locale: const Locale('de'),
            child: Builder(
              builder: (context) {
                final name = PathType.breedAdventure.getLocalizedName(context);
                final description = PathType.breedAdventure
                    .getLocalizedDescription(context);

                expect(name, equals('Rassen-Abenteuer'));
                expect(
                  description,
                  equals(
                    'Identifiziere Hunderassen anhand von Fotos in dieser aufregenden visuellen Herausforderung',
                  ),
                );

                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return Spanish localized name and description', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            locale: const Locale('es'),
            child: Builder(
              builder: (context) {
                final name = PathType.breedAdventure.getLocalizedName(context);
                final description = PathType.breedAdventure
                    .getLocalizedDescription(context);

                expect(name, equals('Aventura de Razas'));
                expect(
                  description,
                  equals(
                    'Identifica razas de perros a partir de fotos en este emocionante desafío visual',
                  ),
                );

                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return English localized name and description', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            locale: const Locale('en'),
            child: Builder(
              builder: (context) {
                final name = PathType.breedAdventure.getLocalizedName(context);
                final description = PathType.breedAdventure
                    .getLocalizedDescription(context);

                expect(name, equals('Breed Adventure'));
                expect(
                  description,
                  equals(
                    'Identify dog breeds from photos in this exciting visual challenge',
                  ),
                );

                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should fallback to English for unsupported locale', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            locale: const Locale('fr'), // Unsupported locale
            child: Builder(
              builder: (context) {
                final name = PathType.breedAdventure.getLocalizedName(context);
                final description = PathType.breedAdventure
                    .getLocalizedDescription(context);

                // Should fallback to English
                expect(name, equals('Breed Adventure'));
                expect(
                  description,
                  equals(
                    'Identify dog breeds from photos in this exciting visual challenge',
                  ),
                );

                return Container();
              },
            ),
          ),
        );
      });
    });

    group('All PathType localization consistency', () {
      final testLocales = [
        const Locale('en'),
        const Locale('de'),
        const Locale('es'),
      ];

      for (final locale in testLocales) {
        testWidgets(
          'should have localized strings for all PathTypes in ${locale.languageCode}',
          (WidgetTester tester) async {
            await tester.pumpWidget(
              createTestWidget(
                locale: locale,
                child: Builder(
                  builder: (context) {
                    for (final pathType in PathType.values) {
                      final name = pathType.getLocalizedName(context);
                      final description = pathType.getLocalizedDescription(
                        context,
                      );

                      // All paths should have non-empty localized strings
                      expect(
                        name.trim(),
                        isNotEmpty,
                        reason:
                            'Name for $pathType in ${locale.languageCode} should not be empty',
                      );
                      expect(
                        description.trim(),
                        isNotEmpty,
                        reason:
                            'Description for $pathType in ${locale.languageCode} should not be empty',
                      );

                      expect(
                        name,
                        isNot(contains('TODO')),
                        reason:
                            '$pathType name should not contain TODO in ${locale.languageCode}',
                      );
                      expect(
                        description,
                        isNot(contains('TODO')),
                        reason:
                            '$pathType description should not contain TODO in ${locale.languageCode}',
                      );
                    }

                    return Container();
                  },
                ),
              ),
            );
          },
        );
      }
    });

    group('Localization delegate integration', () {
      testWidgets(
        'should properly initialize AppLocalizations for all supported locales',
        (WidgetTester tester) async {
          final supportedLocales = AppLocalizations.supportedLocales;

          for (final locale in supportedLocales) {
            await tester.pumpWidget(
              createTestWidget(
                locale: locale,
                child: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context);

                    // Should be able to access localization instance
                    expect(l10n, isNotNull);

                    // Should have expected locale
                    expect(l10n.localeName, equals(locale.languageCode));

                    // Should have breed adventure localization keys
                    expect(l10n.pathType_breedAdventure_name, isNotEmpty);
                    expect(
                      l10n.pathType_breedAdventure_description,
                      isNotEmpty,
                    );

                    return Container();
                  },
                ),
              ),
            );
          }
        },
      );
    });

    group('Breed Adventure specific localization', () {
      testWidgets(
        'should have all required breed adventure UI strings in German',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            createTestWidget(
              locale: const Locale('de'),
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);

                  // Test key breed adventure UI strings
                  expect(
                    l10n.breedAdventure_title,
                    equals('Hunderassen-Abenteuer'),
                  );
                  expect(
                    l10n.breedAdventure_whichImageShows,
                    equals('Welches Bild zeigt einen'),
                  );
                  expect(l10n.breedAdventure_powerUps, equals('Power-Ups'));
                  expect(l10n.breedAdventure_lives, equals('Leben'));
                  expect(
                    l10n.breedAdventure_timeRemaining,
                    equals('Verbleibende Zeit'),
                  );
                  expect(l10n.breedAdventure_sec, equals('Sek'));
                  expect(l10n.breedAdventure_skip, equals('Überspringen'));
                  expect(
                    l10n.breedAdventure_playAgain,
                    equals('Nochmal Spielen'),
                  );
                  expect(l10n.breedAdventure_home, equals('Start'));

                  return Container();
                },
              ),
            ),
          );
        },
      );

      testWidgets(
        'should have all required breed adventure UI strings in Spanish',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            createTestWidget(
              locale: const Locale('es'),
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);

                  // Test key breed adventure UI strings
                  expect(
                    l10n.breedAdventure_title,
                    equals('Aventura de Razas Caninas'),
                  );
                  expect(
                    l10n.breedAdventure_whichImageShows,
                    equals('¿Qué imagen muestra un'),
                  );
                  expect(l10n.breedAdventure_powerUps, equals('Power-ups'));
                  expect(l10n.breedAdventure_lives, equals('Vidas'));
                  expect(
                    l10n.breedAdventure_timeRemaining,
                    equals('Tiempo Restante'),
                  );
                  expect(l10n.breedAdventure_sec, equals('seg'));
                  expect(l10n.breedAdventure_skip, equals('Saltar'));
                  expect(
                    l10n.breedAdventure_playAgain,
                    equals('Jugar de Nuevo'),
                  );
                  expect(l10n.breedAdventure_home, equals('Inicio'));

                  return Container();
                },
              ),
            ),
          );
        },
      );

      testWidgets(
        'should have all required breed adventure UI strings in English',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            createTestWidget(
              locale: const Locale('en'),
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);

                  // Test key breed adventure UI strings
                  expect(
                    l10n.breedAdventure_title,
                    equals('Dog Breeds Adventure'),
                  );
                  expect(
                    l10n.breedAdventure_whichImageShows,
                    equals('Which image shows a'),
                  );
                  expect(l10n.breedAdventure_powerUps, equals('Power-ups'));
                  expect(l10n.breedAdventure_lives, equals('Lives'));
                  expect(
                    l10n.breedAdventure_timeRemaining,
                    equals('Time Remaining'),
                  );
                  expect(l10n.breedAdventure_sec, equals('sec'));
                  expect(l10n.breedAdventure_skip, equals('Skip'));
                  expect(l10n.breedAdventure_playAgain, equals('Play Again'));
                  expect(l10n.breedAdventure_home, equals('Home'));

                  return Container();
                },
              ),
            ),
          );
        },
      );
    });

    group('Difficulty phase localization', () {
      testWidgets('should have localized difficulty phase names', (
        WidgetTester tester,
      ) async {
        final testCases = [
          {
            'locale': const Locale('en'),
            'beginner': 'Beginner',
            'intermediate': 'Intermediate',
            'expert': 'Expert',
          },
          {
            'locale': const Locale('de'),
            'beginner': 'Anfänger',
            'intermediate': 'Fortgeschritten',
            'expert': 'Experte',
          },
          {
            'locale': const Locale('es'),
            'beginner': 'Principiante',
            'intermediate': 'Intermedio',
            'expert': 'Experto',
          },
        ];

        for (final testCase in testCases) {
          await tester.pumpWidget(
            createTestWidget(
              locale: testCase['locale'] as Locale,
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);

                  expect(
                    l10n.difficultyPhase_beginner,
                    equals(testCase['beginner']),
                  );
                  expect(
                    l10n.difficultyPhase_intermediate,
                    equals(testCase['intermediate']),
                  );
                  expect(
                    l10n.difficultyPhase_expert,
                    equals(testCase['expert']),
                  );

                  return Container();
                },
              ),
            ),
          );
        }
      });
    });
  });
}
