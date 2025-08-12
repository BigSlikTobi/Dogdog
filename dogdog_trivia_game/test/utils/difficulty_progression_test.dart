import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/utils/difficulty_progression.dart';

void main() {
  group('DifficultyProgression Tests', () {
    test('should generate appropriate progression for short journey', () {
      final progression = DifficultyProgression.getProgressionForQuestionCount(
        5,
      );

      expect(progression.length, equals(5));
      expect(progression.first, equals('easy'));
      expect(progression.where((d) => d == 'easy').length, greaterThan(0));
    });

    test('should generate appropriate progression for medium journey', () {
      final progression = DifficultyProgression.getProgressionForQuestionCount(
        15,
      );

      expect(progression.length, equals(15));
      expect(progression.first, equals('easy'));
      expect(progression.contains('easy+'), isTrue);
      expect(progression.contains('medium'), isTrue);
    });

    test('should generate appropriate progression for long journey', () {
      final progression = DifficultyProgression.getProgressionForQuestionCount(
        25,
      );

      expect(progression.length, equals(25));
      expect(progression.first, equals('easy'));
      expect(progression.contains('easy+'), isTrue);
      expect(progression.contains('medium'), isTrue);
      expect(progression.contains('hard'), isTrue);
    });

    test('should get difficulty for specific question index', () {
      final difficulty = DifficultyProgression.getDifficultyForQuestionIndex(
        0,
        20,
      );
      expect(difficulty, equals('easy'));

      final lastDifficulty =
          DifficultyProgression.getDifficultyForQuestionIndex(19, 20);
      expect(lastDifficulty, equals('hard'));
    });

    test('should return difficulty distribution', () {
      final distribution = DifficultyProgression.getDifficultyDistribution(20);

      expect(
        distribution.keys,
        containsAll(['easy', 'easy+', 'medium', 'hard']),
      );
      expect(distribution.values.reduce((a, b) => a + b), equals(20));
    });

    test('should validate progression correctly', () {
      expect(
        DifficultyProgression.isValidProgression([
          'easy',
          'easy+',
          'medium',
          'hard',
        ]),
        isTrue,
      );
      expect(
        DifficultyProgression.isValidProgression([
          'easy',
          'easy',
          'easy+',
          'medium',
        ]),
        isTrue,
      );
      expect(
        DifficultyProgression.isValidProgression(['medium', 'easy']),
        isFalse,
      ); // starts with medium
      expect(
        DifficultyProgression.isValidProgression(['easy', 'hard', 'easy']),
        isFalse,
      ); // regresses too much
      expect(DifficultyProgression.isValidProgression([]), isFalse); // empty
    });

    test('should get next difficulty level', () {
      expect(DifficultyProgression.getNextDifficulty('easy'), equals('easy+'));
      expect(
        DifficultyProgression.getNextDifficulty('easy+'),
        equals('medium'),
      );
      expect(DifficultyProgression.getNextDifficulty('medium'), equals('hard'));
      expect(DifficultyProgression.getNextDifficulty('hard'), equals('hard'));
    });

    test('should get previous difficulty level', () {
      expect(
        DifficultyProgression.getPreviousDifficulty('hard'),
        equals('medium'),
      );
      expect(
        DifficultyProgression.getPreviousDifficulty('medium'),
        equals('easy+'),
      );
      expect(
        DifficultyProgression.getPreviousDifficulty('easy+'),
        equals('easy'),
      );
      expect(
        DifficultyProgression.getPreviousDifficulty('easy'),
        equals('easy'),
      );
    });

    test('should map to legacy difficulty format', () {
      expect(
        DifficultyProgression.mapToLegacyDifficulty('easy'),
        equals('easy'),
      );
      expect(
        DifficultyProgression.mapToLegacyDifficulty('easy+'),
        equals('easy'),
      );
      expect(
        DifficultyProgression.mapToLegacyDifficulty('medium'),
        equals('medium'),
      );
      expect(
        DifficultyProgression.mapToLegacyDifficulty('hard'),
        equals('hard'),
      );
      expect(
        DifficultyProgression.mapToLegacyDifficulty('unknown'),
        equals('easy'),
      );
    });

    test('should return correct difficulty weights', () {
      expect(DifficultyProgression.getDifficultyWeight('easy'), equals(1.0));
      expect(DifficultyProgression.getDifficultyWeight('easy+'), equals(1.2));
      expect(DifficultyProgression.getDifficultyWeight('medium'), equals(1.5));
      expect(DifficultyProgression.getDifficultyWeight('hard'), equals(2.0));
    });

    test('should identify advanced difficulties', () {
      expect(DifficultyProgression.isAdvancedDifficulty('easy'), isFalse);
      expect(DifficultyProgression.isAdvancedDifficulty('easy+'), isFalse);
      expect(DifficultyProgression.isAdvancedDifficulty('medium'), isTrue);
      expect(DifficultyProgression.isAdvancedDifficulty('hard'), isTrue);
    });

    test('should return localized difficulty descriptions', () {
      expect(
        DifficultyProgression.getDifficultyDescription('easy', 'en'),
        contains('Perfect for beginners'),
      );
      expect(
        DifficultyProgression.getDifficultyDescription('easy', 'de'),
        contains('Perfekt für Anfänger'),
      );
      expect(
        DifficultyProgression.getDifficultyDescription('easy', 'es'),
        contains('Perfecto para principiantes'),
      );

      expect(
        DifficultyProgression.getDifficultyDescription('easy+', 'en'),
        contains('Slightly more challenging'),
      );
      expect(
        DifficultyProgression.getDifficultyDescription('medium', 'en'),
        contains('For dog lovers'),
      );
      expect(
        DifficultyProgression.getDifficultyDescription('hard', 'en'),
        contains('For dog experts'),
      );
    });
  });
}
