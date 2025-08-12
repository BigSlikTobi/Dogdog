import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/models/models.dart';

void main() {
  group('LocalizedQuestion Tests', () {
    late LocalizedQuestion testQuestion;

    setUp(() {
      testQuestion = LocalizedQuestion(
        id: 'DT_easy_001',
        category: 'Dog Training',
        difficulty: 'easy',
        text: {
          'de':
              'Welcher Befehl wird verwendet, um einem Hund beizubringen zu sitzen?',
          'en': 'Which command is used to teach a dog to sit?',
          'es': '¿Qué comando se usa para enseñar a un perro a sentarse?',
        },
        answers: {
          'de': ['Sitz', 'Platz', 'Bleib', 'Komm'],
          'en': ['Sit', 'Down', 'Stay', 'Come'],
          'es': ['Siéntate', 'Abajo', 'Quieto', 'Ven'],
        },
        correctAnswerIndex: 0,
        hint: {
          'de': 'Es ist der grundlegendste Befehl',
          'en': 'It is the most basic command',
          'es': 'Es el comando más básico',
        },
        funFact: {
          'de': 'Sitz ist meist der erste Befehl, den Hunde lernen',
          'en': 'Sit is usually the first command dogs learn',
          'es':
              'Sentarse es generalmente el primer comando que aprenden los perros',
        },
        ageRange: '8-12',
        tags: ['training', 'basic-commands'],
      );
    });

    test('should create LocalizedQuestion with all properties', () {
      expect(testQuestion.id, equals('DT_easy_001'));
      expect(testQuestion.category, equals('Dog Training'));
      expect(testQuestion.difficulty, equals('easy'));
      expect(testQuestion.correctAnswerIndex, equals(0));
      expect(testQuestion.ageRange, equals('8-12'));
      expect(testQuestion.tags, contains('training'));
    });

    test('should return correct text for different locales', () {
      expect(testQuestion.getText('de'), contains('Welcher Befehl'));
      expect(testQuestion.getText('en'), contains('Which command'));
      expect(testQuestion.getText('es'), contains('Qué comando'));
    });

    test('should fallback to German when locale not available', () {
      expect(testQuestion.getText('fr'), contains('Welcher Befehl'));
    });

    test('should return correct answers for different locales', () {
      expect(testQuestion.getAnswers('de'), contains('Sitz'));
      expect(testQuestion.getAnswers('en'), contains('Sit'));
      expect(testQuestion.getAnswers('es'), contains('Siéntate'));
    });

    test('should return correct answer text for locale', () {
      expect(testQuestion.getCorrectAnswer('de'), equals('Sitz'));
      expect(testQuestion.getCorrectAnswer('en'), equals('Sit'));
      expect(testQuestion.getCorrectAnswer('es'), equals('Siéntate'));
    });

    test('should return correct points based on difficulty', () {
      expect(testQuestion.points, equals(10)); // easy = 10 points

      final easyPlusQuestion = testQuestion.copyWith(difficulty: 'easy+');
      expect(easyPlusQuestion.points, equals(12)); // easy+ = 12 points

      final mediumQuestion = testQuestion.copyWith(difficulty: 'medium');
      expect(mediumQuestion.points, equals(15)); // medium = 15 points

      final hardQuestion = testQuestion.copyWith(difficulty: 'hard');
      expect(hardQuestion.points, equals(20)); // hard = 20 points
    });

    test('should convert to legacy Question format', () {
      final legacyQuestion = testQuestion.toLegacyQuestion('en');

      expect(legacyQuestion.id, equals('DT_easy_001'));
      expect(legacyQuestion.text, contains('Which command'));
      expect(legacyQuestion.answers, contains('Sit'));
      expect(legacyQuestion.correctAnswerIndex, equals(0));
      expect(legacyQuestion.category, equals('Dog Training'));
      expect(legacyQuestion.difficulty, equals(Difficulty.easy));
    });

    test('should serialize to and from JSON', () {
      final json = testQuestion.toJson();
      final recreated = LocalizedQuestion.fromJson(json);

      expect(recreated.id, equals(testQuestion.id));
      expect(recreated.category, equals(testQuestion.category));
      expect(recreated.difficulty, equals(testQuestion.difficulty));
      expect(recreated.getText('en'), equals(testQuestion.getText('en')));
      expect(recreated.getAnswers('en'), equals(testQuestion.getAnswers('en')));
    });

    test('should create copy with modified properties', () {
      final modified = testQuestion.copyWith(
        difficulty: 'medium',
        ageRange: '10-14',
      );

      expect(modified.difficulty, equals('medium'));
      expect(modified.ageRange, equals('10-14'));
      expect(modified.id, equals(testQuestion.id)); // unchanged
      expect(modified.category, equals(testQuestion.category)); // unchanged
    });
  });

  group('QuestionCategory Tests', () {
    test('should return correct localized names', () {
      expect(
        QuestionCategory.dogTraining.getLocalizedName('de'),
        equals('Hundetraining'),
      );
      expect(
        QuestionCategory.dogTraining.getLocalizedName('en'),
        equals('Dog Training'),
      );
      expect(
        QuestionCategory.dogTraining.getLocalizedName('es'),
        equals('Entrenamiento Canino'),
      );

      expect(
        QuestionCategory.dogBreeds.getLocalizedName('de'),
        equals('Hunderassen'),
      );
      expect(
        QuestionCategory.dogBreeds.getLocalizedName('en'),
        equals('Dog Breeds'),
      );
      expect(
        QuestionCategory.dogBreeds.getLocalizedName('es'),
        equals('Razas de Perros'),
      );

      expect(
        QuestionCategory.dogBehavior.getLocalizedName('de'),
        equals('Hundeverhalten'),
      );
      expect(
        QuestionCategory.dogBehavior.getLocalizedName('en'),
        equals('Dog Behavior'),
      );
      expect(
        QuestionCategory.dogBehavior.getLocalizedName('es'),
        equals('Comportamiento Canino'),
      );
    });

    test('should parse from string values', () {
      expect(
        QuestionCategory.fromString('Dog Training'),
        equals(QuestionCategory.dogTraining),
      );
      expect(
        QuestionCategory.fromString('Hundetraining'),
        equals(QuestionCategory.dogTraining),
      );
      expect(
        QuestionCategory.fromString('entrenamiento canino'),
        equals(QuestionCategory.dogTraining),
      );

      expect(
        QuestionCategory.fromString('Dog Breeds'),
        equals(QuestionCategory.dogBreeds),
      );
      expect(
        QuestionCategory.fromString('Hunderassen'),
        equals(QuestionCategory.dogBreeds),
      );

      expect(
        QuestionCategory.fromString('Dog Behavior'),
        equals(QuestionCategory.dogBehavior),
      );
      expect(
        QuestionCategory.fromString('Hundeverhalten'),
        equals(QuestionCategory.dogBehavior),
      );

      // Default fallback
      expect(
        QuestionCategory.fromString('Unknown'),
        equals(QuestionCategory.dogBreeds),
      );
    });
  });
}
