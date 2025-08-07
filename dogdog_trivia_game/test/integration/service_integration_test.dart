import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dogdog_trivia_game/services/progress_service.dart';
import 'package:dogdog_trivia_game/services/question_service.dart';
import 'package:dogdog_trivia_game/controllers/game_controller.dart';

void main() {
  group('Service Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Services should work together', () async {
      // Initialize services
      final progressService = ProgressService();
      await progressService.initialize();

      final questionService = QuestionService();
      await questionService.initialize();

      final gameController = GameController(
        questionService: questionService,
        progressService: progressService,
      );

      // Basic integration test
      expect(progressService.currentProgress.totalCorrectAnswers, 0);
      expect(questionService.isInitialized, isTrue);
      expect(gameController.isGameActive, isFalse);

      // Cleanup
      progressService.dispose();
      gameController.dispose();
    });
  });
}
