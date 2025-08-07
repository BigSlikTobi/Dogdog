import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/models/question.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('Question Model', () {
    test('should create question with all properties', () {
      const question = Question(
        id: 'test_1',
        text: 'What is the largest dog breed?',
        answers: ['Chihuahua', 'Great Dane', 'Pug', 'Beagle'],
        correctAnswerIndex: 1,
        funFact: 'Great Danes can weigh up to 200 pounds!',
        difficulty: Difficulty.easy,
        category: 'Breeds',
        hint: 'Think big!',
      );

      expect(question.id, 'test_1');
      expect(question.text, 'What is the largest dog breed?');
      expect(question.answers.length, 4);
      expect(question.correctAnswerIndex, 1);
      expect(question.correctAnswer, 'Great Dane');
      expect(question.funFact, 'Great Danes can weigh up to 200 pounds!');
      expect(question.difficulty, Difficulty.easy);
      expect(question.category, 'Breeds');
      expect(question.hint, 'Think big!');
    });

    test('should return correct points based on difficulty', () {
      const easyQuestion = Question(
        id: 'easy',
        text: 'Test',
        answers: ['A', 'B'],
        correctAnswerIndex: 0,
        funFact: 'Test fact',
        difficulty: Difficulty.easy,
        category: 'Test',
      );

      const hardQuestion = Question(
        id: 'hard',
        text: 'Test',
        answers: ['A', 'B'],
        correctAnswerIndex: 0,
        funFact: 'Test fact',
        difficulty: Difficulty.hard,
        category: 'Test',
      );

      expect(easyQuestion.points, 10);
      expect(hardQuestion.points, 20);
    });

    test('should convert to/from JSON correctly', () {
      const original = Question(
        id: 'json_test',
        text: 'JSON test question',
        answers: ['A', 'B', 'C', 'D'],
        correctAnswerIndex: 2,
        funFact: 'JSON is great!',
        difficulty: Difficulty.medium,
        category: 'Technology',
        hint: 'It\'s structured data',
      );

      final json = original.toJson();
      final restored = Question.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.text, original.text);
      expect(restored.answers, original.answers);
      expect(restored.correctAnswerIndex, original.correctAnswerIndex);
      expect(restored.funFact, original.funFact);
      expect(restored.difficulty, original.difficulty);
      expect(restored.category, original.category);
      expect(restored.hint, original.hint);
    });
  });
}
