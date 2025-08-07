import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';
import 'package:dogdog_trivia_game/controllers/power_up_controller.dart';
import 'package:dogdog_trivia_game/services/question_service.dart';
import 'package:dogdog_trivia_game/models/game_state.dart';
import 'package:dogdog_trivia_game/models/question.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

/// Mock QuestionService for testing
class MockQuestionService implements QuestionService {
  List<Question> _mockQuestions = [];
  bool _shouldThrowError = false;
  bool _isInitialized = false;

  void setMockQuestions(List<Question> questions) {
    _mockQuestions = questions;
  }

  void setShouldThrowError(bool shouldThrow) {
    _shouldThrowError = shouldThrow;
  }

  @override
  Future<void> initialize() async {
    if (_shouldThrowError) {
      throw Exception('Mock initialization error');
    }
    _isInitialized = true;
  }

  @override
  bool get isInitialized => _isInitialized;

  @override
  List<Question> getQuestionsWithAdaptiveDifficulty({
    required int count,
    required int playerLevel,
    required int streakCount,
    required int recentMistakes,
  }) {
    if (_shouldThrowError) {
      throw Exception('Mock question loading error');
    }
    return _mockQuestions.take(count).toList();
  }

  @override
  void reset() {
    _mockQuestions.clear();
    _isInitialized = false;
  }

  @override
  List<Question> getQuestionsByDifficulty(Difficulty difficulty) {
    return _mockQuestions.where((q) => q.difficulty == difficulty).toList();
  }

  @override
  int get totalQuestionCount => _mockQuestions.length;

  @override
  int getQuestionCountByDifficulty(Difficulty difficulty) {
    return _mockQuestions.where((q) => q.difficulty == difficulty).length;
  }
}

void main() {
  group('GameController', () {
    late GameController gameController;
    late MockQuestionService mockQuestionService;

    setUp(() {
      mockQuestionService = MockQuestionService();
      gameController = GameController(questionService: mockQuestionService);
    });

    tearDown(() {
      gameController.dispose();
    });

    group('Initialization', () {
      test('should initialize with default state', () {
        expect(gameController.gameState, equals(GameState.initial()));
        expect(gameController.isGameActive, isFalse);
        expect(gameController.isGameOver, isFalse);
        expect(gameController.score, equals(0));
        expect(gameController.lives, equals(3));
        expect(gameController.streak, equals(0));
        expect(gameController.level, equals(1));
      });

      test('should initialize game with level 1 (3 lives, no timer)', () async {
        // Arrange
        final mockQuestions = [
          Question(
            id: 'test_1',
            text: 'Test question 1',
            answers: ['A', 'B', 'C', 'D'],
            correctAnswerIndex: 0,
            funFact: 'Test fact',
            difficulty: Difficulty.easy,
            category: 'Test',
          ),
        ];
        mockQuestionService.setMockQuestions(mockQuestions);

        // Act
        await gameController.initializeGame(level: 1);

        // Assert
        expect(gameController.isGameActive, isTrue);
        expect(gameController.lives, equals(3));
        expect(gameController.level, equals(1));
        expect(gameController.isTimerActive, isFalse);
        expect(gameController.timeRemaining, equals(0));
        expect(gameController.currentQuestion, isNotNull);
      });

      test(
        'should initialize game with level 2 (3 lives, 20s timer)',
        () async {
          // Arrange
          final mockQuestions = [
            Question(
              id: 'test_1',
              text: 'Test question 1',
              answers: ['A', 'B', 'C', 'D'],
              correctAnswerIndex: 0,
              funFact: 'Test fact',
              difficulty: Difficulty.medium,
              category: 'Test',
            ),
          ];
          mockQuestionService.setMockQuestions(mockQuestions);

          // Act
          await gameController.initializeGame(level: 2);

          // Assert
          expect(gameController.isGameActive, isTrue);
          expect(gameController.lives, equals(3));
          expect(gameController.level, equals(2));
          expect(gameController.isTimerActive, isTrue);
          expect(gameController.timeRemaining, equals(20));
        },
      );

      test(
        'should initialize game with level 5 (2 lives, 10s timer)',
        () async {
          // Arrange
          final mockQuestions = [
            Question(
              id: 'test_1',
              text: 'Test question 1',
              answers: ['A', 'B', 'C', 'D'],
              correctAnswerIndex: 0,
              funFact: 'Test fact',
              difficulty: Difficulty.hard,
              category: 'Test',
            ),
          ];
          mockQuestionService.setMockQuestions(mockQuestions);

          // Act
          await gameController.initializeGame(level: 5);

          // Assert
          expect(gameController.isGameActive, isTrue);
          expect(gameController.lives, equals(2));
          expect(gameController.level, equals(5));
          expect(gameController.isTimerActive, isTrue);
          expect(gameController.timeRemaining, equals(10));
        },
      );

      test('should throw error when no questions available', () async {
        // Arrange
        mockQuestionService.setMockQuestions([]);

        // Act & Assert
        expect(() => gameController.initializeGame(level: 1), throwsException);
      });

      test('should handle question service initialization error', () async {
        // Arrange
        mockQuestionService.setShouldThrowError(true);

        // Act & Assert
        expect(() => gameController.initializeGame(level: 1), throwsException);
      });
    });

    group('Answer Processing', () {
      setUp(() async {
        final mockQuestions = [
          Question(
            id: 'test_1',
            text: 'Test question 1',
            answers: ['Correct', 'Wrong1', 'Wrong2', 'Wrong3'],
            correctAnswerIndex: 0,
            funFact: 'Test fact',
            difficulty: Difficulty.easy,
            category: 'Test',
          ),
          Question(
            id: 'test_2',
            text: 'Test question 2',
            answers: ['Wrong1', 'Correct', 'Wrong2', 'Wrong3'],
            correctAnswerIndex: 1,
            funFact: 'Test fact 2',
            difficulty: Difficulty.medium,
            category: 'Test',
          ),
        ];
        mockQuestionService.setMockQuestions(mockQuestions);
        await gameController.initializeGame(level: 1);
      });

      test('should process correct answer and update score', () {
        // Act
        final result = gameController.processAnswer(0);

        // Assert
        expect(result, isTrue);
        expect(gameController.score, equals(10)); // Easy difficulty = 10 points
        expect(gameController.streak, equals(1));
        expect(gameController.lives, equals(3)); // Lives unchanged
      });

      test('should process incorrect answer and lose life', () {
        // Act
        final result = gameController.processAnswer(1);

        // Assert
        expect(result, isFalse);
        expect(gameController.score, equals(0)); // Score unchanged
        expect(gameController.streak, equals(0)); // Streak reset
        expect(gameController.lives, equals(2)); // Lost one life
      });

      test('should apply score multiplier for streak >= 5', () async {
        // Arrange - Create more questions for streak testing
        final moreQuestions = List.generate(
          10,
          (index) => Question(
            id: 'test_$index',
            text: 'Test question $index',
            answers: ['Correct', 'Wrong1', 'Wrong2', 'Wrong3'],
            correctAnswerIndex: 0,
            funFact: 'Test fact $index',
            difficulty: Difficulty.easy,
            category: 'Test',
          ),
        );
        mockQuestionService.setMockQuestions(moreQuestions);
        await gameController.initializeGame(level: 1);

        // Act - Answer 5 questions correctly to build streak
        for (int i = 0; i < 5; i++) {
          gameController.processAnswer(0);
          if (i < 4) gameController.nextQuestion();
        }

        // Assert
        expect(gameController.streak, equals(5));
        expect(gameController.scoreMultiplier, equals(2));
        expect(
          gameController.score,
          equals(50),
        ); // 5 * 10 (all answers get base points, multiplier applies from streak >= 5)
      });

      test('should end game when all lives are lost', () {
        // Act - Lose all 3 lives
        gameController.processAnswer(1); // Wrong answer, 2 lives left
        gameController.clearFeedback();
        gameController.processAnswer(1); // Wrong answer, 1 life left
        gameController.clearFeedback();
        gameController.processAnswer(1); // Wrong answer, 0 lives left

        // Assert
        expect(gameController.lives, equals(0));
        expect(gameController.isGameOver, isTrue);
        expect(gameController.isGameActive, isFalse);
      });

      test('should not process answer when game is not active', () {
        // Arrange
        gameController.pauseGame();

        // Act
        final result = gameController.processAnswer(0);

        // Assert
        expect(result, isFalse);
        expect(gameController.score, equals(0));
      });

      test('should not process answer when game is over', () {
        // Arrange - End the game
        gameController.processAnswer(1); // Wrong answer, 2 lives left
        gameController.processAnswer(1); // Wrong answer, 1 life left
        gameController.processAnswer(1); // Wrong answer, 0 lives left

        // Act
        final result = gameController.processAnswer(0);

        // Assert
        expect(result, isFalse);
      });
    });

    group('Question Navigation', () {
      setUp(() async {
        final mockQuestions = [
          Question(
            id: 'test_1',
            text: 'Test question 1',
            answers: ['A', 'B', 'C', 'D'],
            correctAnswerIndex: 0,
            funFact: 'Test fact 1',
            difficulty: Difficulty.easy,
            category: 'Test',
          ),
          Question(
            id: 'test_2',
            text: 'Test question 2',
            answers: ['A', 'B', 'C', 'D'],
            correctAnswerIndex: 1,
            funFact: 'Test fact 2',
            difficulty: Difficulty.easy,
            category: 'Test',
          ),
        ];
        mockQuestionService.setMockQuestions(mockQuestions);
        await gameController.initializeGame(level: 1);
      });

      test('should move to next question', () {
        // Arrange
        final firstQuestion = gameController.currentQuestion;

        // Act
        gameController.nextQuestion();

        // Assert
        expect(gameController.currentQuestion, isNot(equals(firstQuestion)));
        expect(gameController.gameState.currentQuestionIndex, equals(1));
      });

      test('should end game when no more questions', () {
        // Act - Move past all questions
        gameController.nextQuestion(); // Move to question 2
        gameController.nextQuestion(); // Try to move past last question

        // Assert
        expect(gameController.isGameActive, isFalse);
      });

      test('should not move to next question when game is not active', () {
        // Arrange
        gameController.pauseGame();
        final currentIndex = gameController.gameState.currentQuestionIndex;

        // Act
        gameController.nextQuestion();

        // Assert
        expect(
          gameController.gameState.currentQuestionIndex,
          equals(currentIndex),
        );
      });
    });

    group('Game State Management', () {
      setUp(() async {
        final mockQuestions = [
          Question(
            id: 'test_1',
            text: 'Test question 1',
            answers: ['A', 'B', 'C', 'D'],
            correctAnswerIndex: 0,
            funFact: 'Test fact',
            difficulty: Difficulty.easy,
            category: 'Test',
          ),
        ];
        mockQuestionService.setMockQuestions(mockQuestions);
        await gameController.initializeGame(level: 2); // Level 2 has timer
      });

      test('should pause and resume game', () {
        // Act - Pause
        gameController.pauseGame();

        // Assert
        expect(gameController.isGameActive, isFalse);

        // Act - Resume
        gameController.resumeGame();

        // Assert
        expect(gameController.isGameActive, isTrue);
      });

      test('should not resume game when game is over', () {
        // Arrange - End the game
        gameController.processAnswer(1); // Wrong answer, 2 lives left
        gameController.clearFeedback();
        gameController.processAnswer(1); // Wrong answer, 1 life left
        gameController.clearFeedback();
        gameController.processAnswer(1); // Wrong answer, 0 lives left

        // Act
        gameController.resumeGame();

        // Assert
        expect(gameController.isGameActive, isFalse);
      });

      test('should restart game with same level', () async {
        // Arrange
        gameController.processAnswer(0); // Correct answer

        // Act
        await gameController.restartGame();

        // Assert
        expect(gameController.score, equals(0));
        expect(gameController.lives, equals(3));
        expect(gameController.streak, equals(0));
        expect(gameController.level, equals(2)); // Same level
        expect(gameController.isGameActive, isTrue);
      });

      test('should reset game to initial state', () {
        // Arrange
        gameController.processAnswer(0); // Make some changes

        // Act
        gameController.resetGame();

        // Assert
        expect(gameController.gameState, equals(GameState.initial()));
        expect(gameController.isGameActive, isFalse);
      });
    });

    group('Timer Functionality', () {
      test('should have timer for levels 2-5', () async {
        // Test level 2
        final mockQuestions = [
          Question(
            id: 'test_1',
            text: 'Test question 1',
            answers: ['A', 'B', 'C', 'D'],
            correctAnswerIndex: 0,
            funFact: 'Test fact',
            difficulty: Difficulty.medium,
            category: 'Test',
          ),
        ];
        mockQuestionService.setMockQuestions(mockQuestions);

        await gameController.initializeGame(level: 2);
        expect(gameController.isTimerActive, isTrue);
        expect(gameController.timeRemaining, equals(20));

        await gameController.initializeGame(level: 3);
        expect(gameController.timeRemaining, equals(15));

        await gameController.initializeGame(level: 4);
        expect(gameController.timeRemaining, equals(12));

        await gameController.initializeGame(level: 5);
        expect(gameController.timeRemaining, equals(10));
      });

      test('should not have timer for level 1', () async {
        final mockQuestions = [
          Question(
            id: 'test_1',
            text: 'Test question 1',
            answers: ['A', 'B', 'C', 'D'],
            correctAnswerIndex: 0,
            funFact: 'Test fact',
            difficulty: Difficulty.easy,
            category: 'Test',
          ),
        ];
        mockQuestionService.setMockQuestions(mockQuestions);

        await gameController.initializeGame(level: 1);
        expect(gameController.isTimerActive, isFalse);
        expect(gameController.timeRemaining, equals(0));
      });
    });

    group('Game Statistics', () {
      setUp(() async {
        final mockQuestions = [
          Question(
            id: 'test_1',
            text: 'Test question 1',
            answers: ['Correct', 'Wrong1', 'Wrong2', 'Wrong3'],
            correctAnswerIndex: 0,
            funFact: 'Test fact',
            difficulty: Difficulty.easy,
            category: 'Test',
          ),
        ];
        mockQuestionService.setMockQuestions(mockQuestions);
        await gameController.initializeGame(level: 1);
      });

      test('should provide accurate game statistics', () {
        // Arrange
        gameController.processAnswer(0); // Correct answer

        // Act
        final stats = gameController.getGameStatistics();

        // Assert
        expect(stats['score'], equals(10));
        expect(stats['level'], equals(1));
        expect(stats['lives'], equals(3));
        expect(stats['streak'], equals(1));
        expect(stats['totalQuestions'], equals(1));
        expect(stats['correctAnswers'], equals(1));
        expect(stats['accuracy'], equals(100));
        expect(stats['isGameOver'], isFalse);
        expect(stats['isGameActive'], isTrue);
      });

      test('should calculate accuracy correctly', () {
        // Arrange
        gameController.processAnswer(0); // Correct
        gameController.clearFeedback();
        gameController.processAnswer(1); // Incorrect

        // Act
        final stats = gameController.getGameStatistics();

        // Assert
        expect(stats['totalQuestions'], equals(2));
        expect(stats['correctAnswers'], equals(1));
        expect(stats['accuracy'], equals(50));
      });
    });

    group('Load More Questions', () {
      test('should load additional questions', () async {
        // Arrange
        final initialQuestions = [
          Question(
            id: 'test_1',
            text: 'Test question 1',
            answers: ['A', 'B', 'C', 'D'],
            correctAnswerIndex: 0,
            funFact: 'Test fact',
            difficulty: Difficulty.easy,
            category: 'Test',
          ),
        ];

        final additionalQuestions = [
          Question(
            id: 'test_2',
            text: 'Test question 2',
            answers: ['A', 'B', 'C', 'D'],
            correctAnswerIndex: 1,
            funFact: 'Test fact 2',
            difficulty: Difficulty.easy,
            category: 'Test',
          ),
        ];

        mockQuestionService.setMockQuestions(initialQuestions);
        await gameController.initializeGame(level: 1);

        final initialCount = gameController.gameState.questions.length;

        // Act
        mockQuestionService.setMockQuestions(additionalQuestions);
        await gameController.loadMoreQuestions(count: 1);

        // Assert
        expect(
          gameController.gameState.questions.length,
          equals(initialCount + 1),
        );
      });

      test('should handle error when loading more questions', () async {
        // Arrange
        final mockQuestions = [
          Question(
            id: 'test_1',
            text: 'Test question 1',
            answers: ['A', 'B', 'C', 'D'],
            correctAnswerIndex: 0,
            funFact: 'Test fact',
            difficulty: Difficulty.easy,
            category: 'Test',
          ),
        ];
        mockQuestionService.setMockQuestions(mockQuestions);
        await gameController.initializeGame(level: 1);

        mockQuestionService.setShouldThrowError(true);

        // Act & Assert - Should not throw, just handle gracefully
        await gameController.loadMoreQuestions();
        expect(gameController.gameState.questions.length, equals(1));
      });
    });

    group('Power-up Functionality', () {
      setUp(() async {
        final mockQuestions = [
          Question(
            id: 'test_1',
            text: 'Test question 1',
            answers: ['Correct', 'Wrong1', 'Wrong2', 'Wrong3'],
            correctAnswerIndex: 0,
            funFact: 'Test fact',
            difficulty: Difficulty.easy,
            category: 'Test',
            hint: 'This is a hint',
          ),
        ];
        mockQuestionService.setMockQuestions(mockQuestions);
        await gameController.initializeGame(level: 2); // Level 2 has timer
      });

      test('should provide access to power-up controller', () {
        expect(gameController.powerUpController, isA<PowerUpController>());
        expect(gameController.powerUps, isA<Map<PowerUpType, int>>());
      });

      test('should add power-ups to inventory', () {
        // Act
        gameController.addPowerUp(PowerUpType.fiftyFifty, 3);
        gameController.addPowerUps({
          PowerUpType.hint: 2,
          PowerUpType.extraTime: 1,
        });

        // Assert
        expect(
          gameController.getPowerUpCount(PowerUpType.fiftyFifty),
          equals(3),
        );
        expect(gameController.getPowerUpCount(PowerUpType.hint), equals(2));
        expect(
          gameController.getPowerUpCount(PowerUpType.extraTime),
          equals(1),
        );
      });

      test('should check if power-up can be used', () {
        // Arrange
        gameController.addPowerUp(PowerUpType.skip, 1);

        // Assert
        expect(gameController.canUsePowerUp(PowerUpType.skip), isTrue);
        expect(gameController.canUsePowerUp(PowerUpType.secondChance), isFalse);
      });

      group('50/50 Power-up', () {
        test('should use 50/50 power-up and return disabled indices', () {
          // Arrange
          gameController.addPowerUp(PowerUpType.fiftyFifty, 1);

          // Act
          final disabledIndices = gameController.useFiftyFifty();

          // Assert
          expect(disabledIndices.length, equals(2));
          expect(
            disabledIndices.contains(0),
            isFalse,
          ); // Should not disable correct answer
          expect(
            gameController.getPowerUpCount(PowerUpType.fiftyFifty),
            equals(0),
          );
        });

        test('should not use 50/50 when not available', () {
          // Act
          final disabledIndices = gameController.useFiftyFifty();

          // Assert
          expect(disabledIndices, isEmpty);
        });

        test('should not use 50/50 when game is not active', () {
          // Arrange
          gameController.addPowerUp(PowerUpType.fiftyFifty, 1);
          gameController.pauseGame();

          // Act
          final disabledIndices = gameController.useFiftyFifty();

          // Assert
          expect(disabledIndices, isEmpty);
          expect(
            gameController.getPowerUpCount(PowerUpType.fiftyFifty),
            equals(1),
          );
        });
      });

      group('Hint Power-up', () {
        test('should use hint power-up and return hint text', () {
          // Arrange
          gameController.addPowerUp(PowerUpType.hint, 1);

          // Act
          final hint = gameController.useHint();

          // Assert
          expect(hint, equals('This is a hint'));
          expect(gameController.getPowerUpCount(PowerUpType.hint), equals(0));
        });

        test('should not use hint when not available', () {
          // Act
          final hint = gameController.useHint();

          // Assert
          expect(hint, isNull);
        });

        test('should not use hint when game is not active', () {
          // Arrange
          gameController.addPowerUp(PowerUpType.hint, 1);
          gameController.pauseGame();

          // Act
          final hint = gameController.useHint();

          // Assert
          expect(hint, isNull);
          expect(gameController.getPowerUpCount(PowerUpType.hint), equals(1));
        });
      });

      group('Extra Time Power-up', () {
        test('should use extra time power-up and add time', () {
          // Arrange
          gameController.addPowerUp(PowerUpType.extraTime, 1);
          final initialTime = gameController.timeRemaining;

          // Act
          final result = gameController.useExtraTime();

          // Assert
          expect(result, isTrue);
          expect(gameController.timeRemaining, equals(initialTime + 10));
          expect(
            gameController.getPowerUpCount(PowerUpType.extraTime),
            equals(0),
          );
        });

        test('should not use extra time when not available', () {
          // Act
          final result = gameController.useExtraTime();

          // Assert
          expect(result, isFalse);
        });

        test('should not use extra time when timer is not active', () async {
          // Arrange
          final mockQuestions = [
            Question(
              id: 'test_1',
              text: 'Test question 1',
              answers: ['A', 'B', 'C', 'D'],
              correctAnswerIndex: 0,
              funFact: 'Test fact',
              difficulty: Difficulty.easy,
              category: 'Test',
            ),
          ];
          mockQuestionService.setMockQuestions(mockQuestions);
          await gameController.initializeGame(level: 1); // Level 1 has no timer

          gameController.addPowerUp(PowerUpType.extraTime, 1);

          // Act
          final result = gameController.useExtraTime();

          // Assert
          expect(result, isFalse);
          expect(
            gameController.getPowerUpCount(PowerUpType.extraTime),
            equals(1),
          );
        });

        test('should not use extra time when game is not active', () {
          // Arrange
          gameController.addPowerUp(PowerUpType.extraTime, 1);
          gameController.pauseGame();

          // Act
          final result = gameController.useExtraTime();

          // Assert
          expect(result, isFalse);
          expect(
            gameController.getPowerUpCount(PowerUpType.extraTime),
            equals(1),
          );
        });
      });

      group('Skip Power-up', () {
        test('should use skip power-up and move to next question', () async {
          // Arrange
          final mockQuestions = [
            Question(
              id: 'test_1',
              text: 'Test question 1',
              answers: ['A', 'B', 'C', 'D'],
              correctAnswerIndex: 0,
              funFact: 'Test fact 1',
              difficulty: Difficulty.easy,
              category: 'Test',
            ),
            Question(
              id: 'test_2',
              text: 'Test question 2',
              answers: ['A', 'B', 'C', 'D'],
              correctAnswerIndex: 1,
              funFact: 'Test fact 2',
              difficulty: Difficulty.easy,
              category: 'Test',
            ),
          ];
          mockQuestionService.setMockQuestions(mockQuestions);
          await gameController.initializeGame(level: 1);

          gameController.addPowerUp(PowerUpType.skip, 1);
          final initialQuestionIndex =
              gameController.gameState.currentQuestionIndex;

          // Act
          final result = gameController.useSkip();

          // Assert
          expect(result, isTrue);
          expect(
            gameController.gameState.currentQuestionIndex,
            equals(initialQuestionIndex + 1),
          );
          expect(gameController.getPowerUpCount(PowerUpType.skip), equals(0));
        });

        test('should not use skip when not available', () {
          // Act
          final result = gameController.useSkip();

          // Assert
          expect(result, isFalse);
        });

        test('should not use skip when game is not active', () {
          // Arrange
          gameController.addPowerUp(PowerUpType.skip, 1);
          gameController.pauseGame();

          // Act
          final result = gameController.useSkip();

          // Assert
          expect(result, isFalse);
          expect(gameController.getPowerUpCount(PowerUpType.skip), equals(1));
        });
      });

      group('Second Chance Power-up', () {
        test('should use second chance power-up and restore life', () {
          // Arrange
          gameController.addPowerUp(PowerUpType.secondChance, 1);
          gameController.processAnswer(1); // Wrong answer, lose a life
          final livesAfterWrongAnswer = gameController.lives;

          // Act
          final result = gameController.useSecondChance();

          // Assert
          expect(result, isTrue);
          expect(gameController.lives, equals(livesAfterWrongAnswer + 1));
          expect(
            gameController.getPowerUpCount(PowerUpType.secondChance),
            equals(0),
          );
        });

        test('should not use second chance when not available', () {
          // Arrange
          gameController.processAnswer(1); // Wrong answer, lose a life
          final livesAfterWrongAnswer = gameController.lives;

          // Act
          final result = gameController.useSecondChance();

          // Assert
          expect(result, isFalse);
          expect(gameController.lives, equals(livesAfterWrongAnswer));
        });

        test('should not use second chance when already at max lives', () {
          // Arrange
          gameController.addPowerUp(PowerUpType.secondChance, 1);
          // Lives should be at 3 (max)

          // Act
          final result = gameController.useSecondChance();

          // Assert
          expect(result, isFalse);
          expect(
            gameController.getPowerUpCount(PowerUpType.secondChance),
            equals(1),
          );
        });

        test('should not use second chance when game is not active', () {
          // Arrange
          gameController.addPowerUp(PowerUpType.secondChance, 1);
          gameController.processAnswer(1); // Wrong answer, lose a life
          gameController.pauseGame();

          // Act
          final result = gameController.useSecondChance();

          // Assert
          expect(result, isFalse);
          expect(
            gameController.getPowerUpCount(PowerUpType.secondChance),
            equals(1),
          );
        });
      });

      test('should include power-ups in game statistics', () {
        // Arrange
        gameController.addPowerUp(PowerUpType.fiftyFifty, 2);
        gameController.addPowerUp(PowerUpType.hint, 1);

        // Act
        final stats = gameController.getGameStatistics();

        // Assert
        expect(stats['powerUps'], isA<Map<PowerUpType, int>>());
        final powerUps = stats['powerUps'] as Map<PowerUpType, int>;
        expect(powerUps[PowerUpType.fiftyFifty], equals(2));
        expect(powerUps[PowerUpType.hint], equals(1));
      });
    });
  });
}
