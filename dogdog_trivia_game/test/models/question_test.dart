import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/models/question.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('Question', () {
    late Question testQuestion;

    setUp(() {
      testQuestion = const Question(
        id: 'test_1',
        text: 'What is the largest dog breed?',
        answers: ['Chihuahua', 'Great Dane', 'Pug', 'Beagle'],
        correctAnswerIndex: 1,
        funFact: 'Great Danes can weigh up to 200 pounds!',
        difficulty: Difficulty.easy,
        category: 'Breeds',
        hint: 'Think big!',
      );
    });

    test('should create a Question with all required fields', () {
      expect(testQuestion.id, 'test_1');
      expect(testQuestion.text, 'What is the largest dog breed?');
      expect(testQuestion.answers.length, 4);
      expect(testQuestion.correctAnswerIndex, 1);
      expect(testQuestion.funFact, 'Great Danes can weigh up to 200 pounds!');
      expect(testQuestion.difficulty, Difficulty.easy);
      expect(testQuestion.category, 'Breeds');
      expect(testQuestion.hint, 'Think big!');
    });

    test('should return correct answer text', () {
      expect(testQuestion.correctAnswer, 'Great Dane');
    });

    test('should return points based on difficulty', () {
      expect(testQuestion.points, 10); // Easy difficulty = 10 points

      final hardQuestion = testQuestion.copyWith(difficulty: Difficulty.hard);
      expect(hardQuestion.points, 20); // Hard difficulty = 20 points
    });

    test('should create Question without hint', () {
      final questionWithoutHint = const Question(
        id: 'test_no_hint',
        text: 'Test question',
        answers: ['A', 'B', 'C', 'D'],
        correctAnswerIndex: 0,
        funFact: 'Test fact',
        difficulty: Difficulty.easy,
        category: 'Test',
        // hint is null by default
      );
      expect(questionWithoutHint.hint, isNull);
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final json = testQuestion.toJson();

        expect(json['id'], 'test_1');
        expect(json['text'], 'What is the largest dog breed?');
        expect(json['answers'], ['Chihuahua', 'Great Dane', 'Pug', 'Beagle']);
        expect(json['correctAnswerIndex'], 1);
        expect(json['funFact'], 'Great Danes can weigh up to 200 pounds!');
        expect(json['difficulty'], 'easy');
        expect(json['category'], 'Breeds');
        expect(json['hint'], 'Think big!');
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'test_2',
          'text': 'Which breed is known for herding?',
          'answers': ['Poodle', 'German Shepherd', 'Bulldog', 'Dachshund'],
          'correctAnswerIndex': 1,
          'funFact': 'German Shepherds are excellent working dogs.',
          'difficulty': 'medium',
          'category': 'Behavior',
          'hint': 'They work with sheep.',
        };

        final question = Question.fromJson(json);

        expect(question.id, 'test_2');
        expect(question.text, 'Which breed is known for herding?');
        expect(question.answers, [
          'Poodle',
          'German Shepherd',
          'Bulldog',
          'Dachshund',
        ]);
        expect(question.correctAnswerIndex, 1);
        expect(
          question.funFact,
          'German Shepherds are excellent working dogs.',
        );
        expect(question.difficulty, Difficulty.medium);
        expect(question.category, 'Behavior');
        expect(question.hint, 'They work with sheep.');
      });

      test('should handle JSON without hint', () {
        final json = {
          'id': 'test_3',
          'text': 'Test question',
          'answers': ['A', 'B', 'C', 'D'],
          'correctAnswerIndex': 0,
          'funFact': 'Test fact',
          'difficulty': 'easy',
          'category': 'Test',
          'hint': null,
        };

        final question = Question.fromJson(json);
        expect(question.hint, isNull);
      });

      test('should handle invalid difficulty gracefully', () {
        final json = {
          'id': 'test_4',
          'text': 'Test question',
          'answers': ['A', 'B', 'C', 'D'],
          'correctAnswerIndex': 0,
          'funFact': 'Test fact',
          'difficulty': 'invalid_difficulty',
          'category': 'Test',
        };

        final question = Question.fromJson(json);
        expect(question.difficulty, Difficulty.easy); // Should default to easy
      });

      test('should serialize and deserialize JSON string correctly', () {
        final jsonString = testQuestion.toJsonString();
        final deserializedQuestion = Question.fromJsonString(jsonString);

        expect(deserializedQuestion, equals(testQuestion));
      });
    });

    group('copyWith', () {
      test('should create copy with modified fields', () {
        final modifiedQuestion = testQuestion.copyWith(
          text: 'Modified question',
          difficulty: Difficulty.hard,
        );

        expect(modifiedQuestion.text, 'Modified question');
        expect(modifiedQuestion.difficulty, Difficulty.hard);
        expect(modifiedQuestion.id, testQuestion.id); // Unchanged
        expect(modifiedQuestion.answers, testQuestion.answers); // Unchanged
      });

      test('should create identical copy when no parameters provided', () {
        final copiedQuestion = testQuestion.copyWith();
        expect(copiedQuestion, equals(testQuestion));
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all fields match', () {
        final question1 = testQuestion;
        final question2 = testQuestion.copyWith();

        expect(question1, equals(question2));
        expect(question1.hashCode, equals(question2.hashCode));
      });

      test('should not be equal when fields differ', () {
        final question1 = testQuestion;
        final question2 = testQuestion.copyWith(text: 'Different text');

        expect(question1, isNot(equals(question2)));
      });

      test('should handle answers list comparison correctly', () {
        final question1 = testQuestion;
        final question2 = testQuestion.copyWith(
          answers: ['Chihuahua', 'Great Dane', 'Pug', 'Beagle'], // Same content
        );

        expect(question1, equals(question2));
      });
    });

    test('should have meaningful toString', () {
      final string = testQuestion.toString();
      expect(string, contains('test_1'));
      expect(string, contains('easy'));
      expect(string, contains('Breeds'));
    });
  });
}
