import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/models/game_state.dart';
import 'package:dogdog_trivia_game/models/question.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('GameState', () {
    late GameState testGameState;
    late List<Question> testQuestions;

    setUp(() {
      testQuestions = [
        const Question(
          id: 'q1',
          text: 'Question 1',
          answers: ['A', 'B', 'C', 'D'],
          correctAnswerIndex: 0,
          funFact: 'Fact 1',
          difficulty: Difficulty.easy,
          category: 'Test',
        ),
        const Question(
          id: 'q2',
          text: 'Question 2',
          answers: ['A', 'B', 'C', 'D'],
          correctAnswerIndex: 1,
          funFact: 'Fact 2',
          difficulty: Difficulty.medium,
          category: 'Test',
        ),
      ];

      testGameState = GameState(
        currentQuestionIndex: 0,
        score: 100,
        lives: 3,
        streak: 2,
        level: 1,
        questions: testQuestions,
        powerUps: {
          PowerUpType.fiftyFifty: 2,
          PowerUpType.hint: 1,
          PowerUpType.extraTime: 0,
          PowerUpType.skip: 1,
          PowerUpType.secondChance: 0,
        },
        isGameActive: true,
        timeRemaining: 15,
        isTimerActive: true,
        totalQuestionsAnswered: 5,
        correctAnswersInSession: 3,
      );
    });

    test('should create GameState with all fields', () {
      expect(testGameState.currentQuestionIndex, 0);
      expect(testGameState.score, 100);
      expect(testGameState.lives, 3);
      expect(testGameState.streak, 2);
      expect(testGameState.level, 1);
      expect(testGameState.questions.length, 2);
      expect(testGameState.isGameActive, true);
      expect(testGameState.timeRemaining, 15);
      expect(testGameState.isTimerActive, true);
      expect(testGameState.totalQuestionsAnswered, 5);
      expect(testGameState.correctAnswersInSession, 3);
    });

    test('should create initial GameState correctly', () {
      final initialState = GameState.initial();

      expect(initialState.currentQuestionIndex, 0);
      expect(initialState.score, 0);
      expect(initialState.lives, 3);
      expect(initialState.streak, 0);
      expect(initialState.level, 1);
      expect(initialState.questions, isEmpty);
      expect(initialState.powerUps.length, PowerUpType.values.length);
      expect(initialState.isGameActive, false);
      expect(initialState.timeRemaining, 0);
      expect(initialState.isTimerActive, false);
      expect(initialState.totalQuestionsAnswered, 0);
      expect(initialState.correctAnswersInSession, 0);
    });

    group('computed properties', () {
      test('should return current question when available', () {
        expect(testGameState.currentQuestion, equals(testQuestions[0]));
      });

      test('should return null when no current question', () {
        final stateWithoutQuestions = testGameState.copyWith(
          currentQuestionIndex: 5,
        );
        expect(stateWithoutQuestions.currentQuestion, isNull);
      });

      test('should detect game over when no lives remaining', () {
        final gameOverState = testGameState.copyWith(lives: 0);
        expect(gameOverState.isGameOver, true);
        expect(testGameState.isGameOver, false);
      });

      test('should detect if there are more questions', () {
        expect(testGameState.hasMoreQuestions, true);

        final lastQuestionState = testGameState.copyWith(
          currentQuestionIndex: 2,
        );
        expect(lastQuestionState.hasMoreQuestions, false);
      });

      test('should calculate score multiplier based on streak', () {
        expect(testGameState.scoreMultiplier, 1); // Streak < 5

        final highStreakState = testGameState.copyWith(streak: 5);
        expect(highStreakState.scoreMultiplier, 2); // Streak >= 5
      });

      test('should return correct time limit for level', () {
        expect(testGameState.timeLimitForLevel, 0); // Level 1 = no timer

        final level2State = testGameState.copyWith(level: 2);
        expect(level2State.timeLimitForLevel, 20);

        final level3State = testGameState.copyWith(level: 3);
        expect(level3State.timeLimitForLevel, 15);

        final level4State = testGameState.copyWith(level: 4);
        expect(level4State.timeLimitForLevel, 12);

        final level5State = testGameState.copyWith(level: 5);
        expect(level5State.timeLimitForLevel, 10);
      });

      test('should return correct starting lives for level', () {
        expect(testGameState.startingLivesForLevel, 3); // Level < 5

        final level5State = testGameState.copyWith(level: 5);
        expect(level5State.startingLivesForLevel, 2); // Level >= 5
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final json = testGameState.toJson();

        expect(json['currentQuestionIndex'], 0);
        expect(json['score'], 100);
        expect(json['lives'], 3);
        expect(json['streak'], 2);
        expect(json['level'], 1);
        expect(json['questions'], hasLength(2));
        expect(json['powerUps'], isA<Map<String, dynamic>>());
        expect(json['isGameActive'], true);
        expect(json['timeRemaining'], 15);
        expect(json['isTimerActive'], true);
        expect(json['totalQuestionsAnswered'], 5);
        expect(json['correctAnswersInSession'], 3);
      });

      test('should deserialize from JSON correctly', () {
        final json = testGameState.toJson();
        final deserializedState = GameState.fromJson(json);

        expect(
          deserializedState.currentQuestionIndex,
          testGameState.currentQuestionIndex,
        );
        expect(deserializedState.score, testGameState.score);
        expect(deserializedState.lives, testGameState.lives);
        expect(deserializedState.streak, testGameState.streak);
        expect(deserializedState.level, testGameState.level);
        expect(
          deserializedState.questions.length,
          testGameState.questions.length,
        );
        expect(deserializedState.isGameActive, testGameState.isGameActive);
        expect(deserializedState.timeRemaining, testGameState.timeRemaining);
        expect(deserializedState.isTimerActive, testGameState.isTimerActive);
        expect(
          deserializedState.totalQuestionsAnswered,
          testGameState.totalQuestionsAnswered,
        );
        expect(
          deserializedState.correctAnswersInSession,
          testGameState.correctAnswersInSession,
        );
      });

      test('should handle missing optional fields in JSON', () {
        final json = {
          'currentQuestionIndex': 0,
          'score': 100,
          'lives': 3,
          'streak': 2,
          'level': 1,
          'questions': [],
          'powerUps': {},
          'isGameActive': true,
          'timeRemaining': 15,
          // Missing optional fields
        };

        final state = GameState.fromJson(json);
        expect(state.isTimerActive, false);
        expect(state.totalQuestionsAnswered, 0);
        expect(state.correctAnswersInSession, 0);
      });

      test('should serialize and deserialize JSON string correctly', () {
        final jsonString = testGameState.toJsonString();
        final deserializedState = GameState.fromJsonString(jsonString);

        expect(
          deserializedState.currentQuestionIndex,
          testGameState.currentQuestionIndex,
        );
        expect(deserializedState.score, testGameState.score);
        expect(deserializedState.lives, testGameState.lives);
      });
    });

    group('copyWith', () {
      test('should create copy with modified fields', () {
        final modifiedState = testGameState.copyWith(
          score: 200,
          lives: 2,
          level: 2,
        );

        expect(modifiedState.score, 200);
        expect(modifiedState.lives, 2);
        expect(modifiedState.level, 2);
        expect(
          modifiedState.currentQuestionIndex,
          testGameState.currentQuestionIndex,
        ); // Unchanged
        expect(modifiedState.streak, testGameState.streak); // Unchanged
      });

      test('should create identical copy when no parameters provided', () {
        final copiedState = testGameState.copyWith();
        expect(copiedState.score, testGameState.score);
        expect(copiedState.lives, testGameState.lives);
        expect(copiedState.level, testGameState.level);
      });
    });

    group('equality and hashCode', () {
      test('should be equal when key fields match', () {
        final state1 = testGameState;
        final state2 = testGameState.copyWith();

        expect(state1 == state2, true);
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal when fields differ', () {
        final state1 = testGameState;
        final state2 = testGameState.copyWith(score: 999);

        expect(state1 == state2, false);
      });
    });

    test('should have meaningful toString', () {
      final string = testGameState.toString();
      expect(string, contains('level: 1'));
      expect(string, contains('score: 100'));
      expect(string, contains('lives: 3'));
      expect(string, contains('streak: 2'));
      expect(string, contains('active: true'));
    });
  });
}
