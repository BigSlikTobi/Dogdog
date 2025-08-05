import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('Difficulty', () {
    test('should have correct display names in German', () {
      expect(Difficulty.easy.displayName, 'Leicht');
      expect(Difficulty.medium.displayName, 'Mittel');
      expect(Difficulty.hard.displayName, 'Schwer');
      expect(Difficulty.expert.displayName, 'Experte');
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
    test('should have correct display names in German', () {
      expect(PowerUpType.fiftyFifty.displayName, 'Chew 50/50');
      expect(PowerUpType.hint.displayName, 'Hinweis');
      expect(PowerUpType.extraTime.displayName, 'Extra Zeit');
      expect(PowerUpType.skip.displayName, 'Überspringen');
      expect(PowerUpType.secondChance.displayName, 'Zweite Chance');
    });

    test('should have descriptions in German', () {
      expect(
        PowerUpType.fiftyFifty.description,
        'Entfernt zwei falsche Antworten',
      );
      expect(
        PowerUpType.hint.description,
        'Zeigt einen Hinweis zur richtigen Antwort',
      );
      expect(
        PowerUpType.extraTime.description,
        'Fügt 10 Sekunden zur aktuellen Frage hinzu',
      );
      expect(
        PowerUpType.skip.description,
        'Springt zur nächsten Frage ohne Strafe',
      );
      expect(
        PowerUpType.secondChance.description,
        'Stellt ein verlorenes Leben wieder her',
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
    test('should have correct display names in German', () {
      expect(Rank.chihuahua.displayName, 'Chihuahua');
      expect(Rank.pug.displayName, 'Mops');
      expect(Rank.cockerSpaniel.displayName, 'Cocker Spaniel');
      expect(Rank.germanShepherd.displayName, 'Deutscher Schäferhund');
      expect(Rank.greatDane.displayName, 'Deutsche Dogge');
    });

    test('should have correct required correct answers', () {
      expect(Rank.chihuahua.requiredCorrectAnswers, 10);
      expect(Rank.pug.requiredCorrectAnswers, 25);
      expect(Rank.cockerSpaniel.requiredCorrectAnswers, 50);
      expect(Rank.germanShepherd.requiredCorrectAnswers, 75);
      expect(Rank.greatDane.requiredCorrectAnswers, 100);
    });

    test('should have descriptions in German', () {
      expect(
        Rank.chihuahua.description,
        'Kleiner Anfang - Du hast deine ersten 10 Fragen richtig beantwortet!',
      );
      expect(
        Rank.pug.description,
        'Guter Fortschritt - 25 richtige Antworten erreicht!',
      );
      expect(
        Rank.cockerSpaniel.description,
        'Halbzeit-Held - 50 richtige Antworten gemeistert!',
      );
      expect(
        Rank.germanShepherd.description,
        'Treuer Begleiter - 75 richtige Antworten geschafft!',
      );
      expect(
        Rank.greatDane.description,
        'Großer Meister - 100 richtige Antworten erreicht!',
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
    test('should have correct display names in German', () {
      expect(GameResult.win.displayName, 'Gewonnen');
      expect(GameResult.lose.displayName, 'Verloren');
      expect(GameResult.quit.displayName, 'Beendet');
    });

    test('should contain all expected values', () {
      expect(GameResult.values.length, 3);
      expect(GameResult.values, contains(GameResult.win));
      expect(GameResult.values, contains(GameResult.lose));
      expect(GameResult.values, contains(GameResult.quit));
    });
  });
}
