import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('Difficulty Enum', () {
    test('should return correct points for each difficulty', () {
      expect(Difficulty.easy.points, 10);
      expect(Difficulty.medium.points, 15);
      expect(Difficulty.hard.points, 20);
      expect(Difficulty.expert.points, 25);
    });
  });

  group('Rank Enum', () {
    test('should return correct required answers for each rank', () {
      expect(Rank.chihuahua.requiredCorrectAnswers, 10);
      expect(Rank.pug.requiredCorrectAnswers, 25);
      expect(Rank.cockerSpaniel.requiredCorrectAnswers, 50);
      expect(Rank.germanShepherd.requiredCorrectAnswers, 75);
      expect(Rank.greatDane.requiredCorrectAnswers, 100);
    });
  });

  group('PowerUpType Enum', () {
    test('should have all power-up types defined', () {
      expect(PowerUpType.values.length, 5);
      expect(PowerUpType.values, contains(PowerUpType.fiftyFifty));
      expect(PowerUpType.values, contains(PowerUpType.hint));
      expect(PowerUpType.values, contains(PowerUpType.extraTime));
      expect(PowerUpType.values, contains(PowerUpType.skip));
      expect(PowerUpType.values, contains(PowerUpType.secondChance));
    });
  });
}
