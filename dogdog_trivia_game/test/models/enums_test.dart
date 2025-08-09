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

  group('PathType Enum', () {
    test('should have all path types defined', () {
      expect(PathType.values.length, 5);
      expect(PathType.values, contains(PathType.dogBreeds));
      expect(PathType.values, contains(PathType.dogTraining));
      expect(PathType.values, contains(PathType.healthCare));
      expect(PathType.values, contains(PathType.dogBehavior));
      expect(PathType.values, contains(PathType.dogHistory));
    });

    test('should return correct display names', () {
      expect(PathType.dogBreeds.displayName, 'Dog Breeds');
      expect(PathType.dogTraining.displayName, 'Dog Training');
      expect(PathType.healthCare.displayName, 'Health & Care');
      expect(PathType.dogBehavior.displayName, 'Dog Behavior');
      expect(PathType.dogHistory.displayName, 'Dog History');
    });

    test('should return correct descriptions', () {
      expect(
        PathType.dogBreeds.description,
        'Learn about different dog breeds, their characteristics, and origins',
      );
      expect(
        PathType.dogTraining.description,
        'Master dog training techniques, commands, and behavioral guidance',
      );
      expect(
        PathType.healthCare.description,
        'Understand dog health, nutrition, and medical care',
      );
      expect(
        PathType.dogBehavior.description,
        'Explore dog psychology, instincts, and behavioral patterns',
      );
      expect(
        PathType.dogHistory.description,
        'Discover the history of dogs, genetics, and evolution',
      );
    });
  });

  group('Checkpoint Enum', () {
    test('should have all checkpoints defined', () {
      expect(Checkpoint.values.length, 5);
      expect(Checkpoint.values, contains(Checkpoint.chihuahua));
      expect(Checkpoint.values, contains(Checkpoint.cockerSpaniel));
      expect(Checkpoint.values, contains(Checkpoint.germanShepherd));
      expect(Checkpoint.values, contains(Checkpoint.greatDane));
      expect(Checkpoint.values, contains(Checkpoint.deutscheDogge));
    });

    test('should return correct questions required for each checkpoint', () {
      expect(Checkpoint.chihuahua.questionsRequired, 10);
      expect(Checkpoint.cockerSpaniel.questionsRequired, 20);
      expect(Checkpoint.germanShepherd.questionsRequired, 30);
      expect(Checkpoint.greatDane.questionsRequired, 40);
      expect(Checkpoint.deutscheDogge.questionsRequired, 50);
    });

    test('should return correct display names', () {
      expect(Checkpoint.chihuahua.displayName, 'Chihuahua');
      expect(Checkpoint.cockerSpaniel.displayName, 'Cocker Spaniel');
      expect(Checkpoint.germanShepherd.displayName, 'German Shepherd');
      expect(Checkpoint.greatDane.displayName, 'Great Dane');
      expect(Checkpoint.deutscheDogge.displayName, 'Deutsche Dogge');
    });

    test('should return correct image paths', () {
      expect(Checkpoint.chihuahua.imagePath, 'assets/images/chihuahua.png');
      expect(Checkpoint.cockerSpaniel.imagePath, 'assets/images/cocker.png');
      expect(
        Checkpoint.germanShepherd.imagePath,
        'assets/images/schaeferhund.png',
      );
      expect(Checkpoint.greatDane.imagePath, 'assets/images/dogge.png');
      expect(Checkpoint.deutscheDogge.imagePath, 'assets/images/dogge.png');
    });

    test(
      'should have checkpoints in ascending order of questions required',
      () {
        final checkpoints = Checkpoint.values;
        for (int i = 1; i < checkpoints.length; i++) {
          expect(
            checkpoints[i].questionsRequired,
            greaterThan(checkpoints[i - 1].questionsRequired),
          );
        }
      },
    );
  });
}
