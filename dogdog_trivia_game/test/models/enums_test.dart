import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/utils/enum_extensions.dart';
import '../helpers/test_helper.dart';

void main() {
  group('Difficulty', () {
    testWidgets('should have correct display names in German', (tester) async {
      await tester.pumpWidget(
        TestHelper.createTestApp(
          Builder(
            builder: (context) {
              expect(Difficulty.easy.displayName(context), 'Leicht');
              expect(Difficulty.medium.displayName(context), 'Mittel');
              expect(Difficulty.hard.displayName(context), 'Schwer');
              expect(Difficulty.expert.displayName(context), 'Experte');
              return Container();
            },
          ),
          locale: const Locale('de'),
        ),
      );
    });

    test('should have correct point values', () {
      expect(Difficulty.easy.points, 10);
      expect(Difficulty.medium.points, 15);
      expect(Difficulty.hard.points, 20);
      expect(Difficulty.expert.points, 25);
    });

    test('should contain all expected values', () {
      expect(Difficulty.values.length, 4);
      expect(Difficulty.values, contains(Difficulty.easy));
      expect(Difficulty.values, contains(Difficulty.medium));
      expect(Difficulty.values, contains(Difficulty.hard));
      expect(Difficulty.values, contains(Difficulty.expert));
    });
  });

  group('PowerUpType', () {
    testWidgets('should have correct display names in German', (tester) async {
      await tester.pumpWidget(
        TestHelper.createTestApp(
          Builder(
            builder: (context) {
              expect(PowerUpType.fiftyFifty.displayName(context), 'Chew 50/50');
              expect(PowerUpType.hint.displayName(context), 'Hinweis');
              expect(PowerUpType.extraTime.displayName(context), 'Extra Zeit');
              expect(PowerUpType.skip.displayName(context), 'Überspringen');
              expect(
                PowerUpType.secondChance.displayName(context),
                'Zweite Chance',
              );
              return Container();
            },
          ),
          locale: const Locale('de'),
        ),
      );
    });

    testWidgets('should have descriptions in German', (tester) async {
      await tester.pumpWidget(
        TestHelper.createTestApp(
          Builder(
            builder: (context) {
              expect(
                PowerUpType.fiftyFifty.description(context),
                'Entfernt zwei falsche Antworten',
              );
              expect(
                PowerUpType.hint.description(context),
                'Zeigt einen Hinweis zur richtigen Antwort',
              );
              expect(
                PowerUpType.extraTime.description(context),
                'Fügt 10 Sekunden zur aktuellen Frage hinzu',
              );
              expect(
                PowerUpType.skip.description(context),
                'Springt zur nächsten Frage ohne Strafe',
              );
              expect(
                PowerUpType.secondChance.description(context),
                'Stellt ein verlorenes Leben wieder her',
              );
              return Container();
            },
          ),
          locale: const Locale('de'),
        ),
      );
    });

    test('should contain all expected values', () {
      expect(PowerUpType.values.length, 5);
      expect(PowerUpType.values, contains(PowerUpType.fiftyFifty));
      expect(PowerUpType.values, contains(PowerUpType.hint));
      expect(PowerUpType.values, contains(PowerUpType.extraTime));
      expect(PowerUpType.values, contains(PowerUpType.skip));
      expect(PowerUpType.values, contains(PowerUpType.secondChance));
    });
  });

  group('Rank', () {
    testWidgets('should have correct display names in German', (tester) async {
      await tester.pumpWidget(
        TestHelper.createTestApp(
          Builder(
            builder: (context) {
              expect(Rank.chihuahua.displayName(context), 'Chihuahua');
              expect(Rank.pug.displayName(context), 'Mops');
              expect(Rank.cockerSpaniel.displayName(context), 'Cocker Spaniel');
              expect(
                Rank.germanShepherd.displayName(context),
                'Deutscher Schäferhund',
              );
              expect(Rank.greatDane.displayName(context), 'Deutsche Dogge');
              return Container();
            },
          ),
          locale: const Locale('de'),
        ),
      );
    });

    test('should have correct required correct answers', () {
      expect(Rank.chihuahua.requiredCorrectAnswers, 10);
      expect(Rank.pug.requiredCorrectAnswers, 25);
      expect(Rank.cockerSpaniel.requiredCorrectAnswers, 50);
      expect(Rank.germanShepherd.requiredCorrectAnswers, 75);
      expect(Rank.greatDane.requiredCorrectAnswers, 100);
    });

    testWidgets('should have descriptions in German', (tester) async {
      await tester.pumpWidget(
        TestHelper.createTestApp(
          Builder(
            builder: (context) {
              expect(
                Rank.chihuahua.description(context),
                'Kleiner Anfang - Du hast deine ersten 10 Fragen richtig beantwortet!',
              );
              expect(
                Rank.pug.description(context),
                'Guter Fortschritt - 25 richtige Antworten erreicht!',
              );
              expect(
                Rank.cockerSpaniel.description(context),
                'Halbzeit-Held - 50 richtige Antworten gemeistert!',
              );
              expect(
                Rank.germanShepherd.description(context),
                'Treuer Begleiter - 75 richtige Antworten geschafft!',
              );
              expect(
                Rank.greatDane.description(context),
                'Großer Meister - 100 richtige Antworten erreicht!',
              );
              return Container();
            },
          ),
          locale: const Locale('de'),
        ),
      );
    });

    test('should be ordered by difficulty', () {
      final ranks = Rank.values;
      for (int i = 1; i < ranks.length; i++) {
        expect(
          ranks[i].requiredCorrectAnswers,
          greaterThan(ranks[i - 1].requiredCorrectAnswers),
        );
      }
    });

    test('should contain all expected values', () {
      expect(Rank.values.length, 5);
      expect(Rank.values, contains(Rank.chihuahua));
      expect(Rank.values, contains(Rank.pug));
      expect(Rank.values, contains(Rank.cockerSpaniel));
      expect(Rank.values, contains(Rank.germanShepherd));
      expect(Rank.values, contains(Rank.greatDane));
    });
  });

  group('GameResult', () {
    testWidgets('should have correct display names in German', (tester) async {
      await tester.pumpWidget(
        TestHelper.createTestApp(
          Builder(
            builder: (context) {
              expect(GameResult.win.displayName(context), 'Gewonnen');
              expect(GameResult.lose.displayName(context), 'Verloren');
              expect(GameResult.quit.displayName(context), 'Beendet');
              return Container();
            },
          ),
          locale: const Locale('de'),
        ),
      );
    });

    test('should contain all expected values', () {
      expect(GameResult.values.length, 3);
      expect(GameResult.values, contains(GameResult.win));
      expect(GameResult.values, contains(GameResult.lose));
      expect(GameResult.values, contains(GameResult.quit));
    });
  });
}
