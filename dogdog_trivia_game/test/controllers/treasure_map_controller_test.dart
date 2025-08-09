import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/controllers/treasure_map_controller.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('TreasureMapController', () {
    late TreasureMapController controller;

    setUp(() {
      controller = TreasureMapController();
    });

    group('Path Selection', () {
      test('should initialize with default path', () {
        expect(controller.currentPath, equals(PathType.dogBreeds));
        expect(controller.currentQuestionCount, equals(0));
        expect(controller.lastCompletedCheckpoint, isNull);
        expect(controller.completedCheckpoints, isEmpty);
      });

      test('should initialize new path correctly', () {
        controller.initializePath(PathType.dogTraining);

        expect(controller.currentPath, equals(PathType.dogTraining));
        expect(controller.currentQuestionCount, equals(0));
        expect(controller.lastCompletedCheckpoint, isNull);
        expect(controller.completedCheckpoints, isEmpty);
      });

      test('should reset path state when initializing new path', () {
        // Set up some progress
        controller.initializePath(PathType.dogBreeds);
        for (int i = 0; i < 15; i++) {
          controller.incrementQuestionCount();
        }

        // Initialize new path
        controller.initializePath(PathType.dogTraining);

        expect(controller.currentPath, equals(PathType.dogTraining));
        expect(controller.currentQuestionCount, equals(0));
        expect(controller.lastCompletedCheckpoint, isNull);
        expect(controller.completedCheckpoints, isEmpty);
      });
    });

    group('Checkpoint Progression', () {
      test('should return correct next checkpoint initially', () {
        controller.initializePath(PathType.dogBreeds);
        expect(controller.nextCheckpoint, equals(Checkpoint.chihuahua));
      });

      test('should calculate questions to next checkpoint correctly', () {
        controller.initializePath(PathType.dogBreeds);
        expect(controller.questionsToNextCheckpoint, equals(10));

        controller.incrementQuestionCount();
        expect(controller.questionsToNextCheckpoint, equals(9));
      });

      test('should calculate progress to next checkpoint correctly', () {
        controller.initializePath(PathType.dogBreeds);
        expect(controller.progressToNextCheckpoint, equals(0.0));

        // Answer 5 questions (50% to first checkpoint)
        for (int i = 0; i < 5; i++) {
          controller.incrementQuestionCount();
        }
        expect(controller.progressToNextCheckpoint, equals(0.5));

        // Answer 5 more questions (100% to first checkpoint)
        for (int i = 0; i < 5; i++) {
          controller.incrementQuestionCount();
        }
        expect(
          controller.progressToNextCheckpoint,
          equals(0.0),
        ); // Reset for next checkpoint
      });

      test(
        'should complete checkpoint automatically when reaching required questions',
        () {
          controller.initializePath(PathType.dogBreeds);

          // Answer 10 questions to reach Chihuahua checkpoint
          for (int i = 0; i < 10; i++) {
            controller.incrementQuestionCount();
          }

          expect(
            controller.completedCheckpoints.contains(Checkpoint.chihuahua),
            isTrue,
          );
          expect(
            controller.lastCompletedCheckpoint,
            equals(Checkpoint.chihuahua),
          );
          expect(controller.nextCheckpoint, equals(Checkpoint.cockerSpaniel));
        },
      );

      test('should handle multiple checkpoint completions', () {
        controller.initializePath(PathType.dogBreeds);

        // Answer 25 questions to reach multiple checkpoints
        for (int i = 0; i < 25; i++) {
          controller.incrementQuestionCount();
        }

        expect(
          controller.completedCheckpoints.contains(Checkpoint.chihuahua),
          isTrue,
        );
        expect(
          controller.completedCheckpoints.contains(Checkpoint.cockerSpaniel),
          isTrue,
        );
        expect(
          controller.lastCompletedCheckpoint,
          equals(Checkpoint.cockerSpaniel),
        );
        expect(controller.nextCheckpoint, equals(Checkpoint.germanShepherd));
      });

      test('should complete all checkpoints and mark path as completed', () {
        controller.initializePath(PathType.dogBreeds);

        // Answer 50 questions to complete all checkpoints
        for (int i = 0; i < 50; i++) {
          controller.incrementQuestionCount();
        }

        expect(controller.completedCheckpoints.length, equals(5));
        expect(controller.isPathCompleted, isTrue);
        expect(controller.nextCheckpoint, isNull);
        expect(controller.questionsToNextCheckpoint, equals(0));
      });
    });

    group('Checkpoint Fallback', () {
      test('should reset to specific checkpoint correctly', () {
        controller.initializePath(PathType.dogBreeds);

        // Complete multiple checkpoints
        for (int i = 0; i < 35; i++) {
          controller.incrementQuestionCount();
        }

        // Reset to Cocker Spaniel checkpoint
        controller.resetToCheckpoint(Checkpoint.cockerSpaniel);

        expect(controller.currentQuestionCount, equals(20));
        expect(
          controller.lastCompletedCheckpoint,
          equals(Checkpoint.cockerSpaniel),
        );
        expect(
          controller.completedCheckpoints.contains(Checkpoint.chihuahua),
          isTrue,
        );
        expect(
          controller.completedCheckpoints.contains(Checkpoint.cockerSpaniel),
          isTrue,
        );
        expect(
          controller.completedCheckpoints.contains(Checkpoint.germanShepherd),
          isFalse,
        );
      });

      test('should reset entire path correctly', () {
        controller.initializePath(PathType.dogBreeds);

        // Make some progress
        for (int i = 0; i < 25; i++) {
          controller.incrementQuestionCount();
        }

        // Reset path
        controller.resetPath();

        expect(controller.currentQuestionCount, equals(0));
        expect(controller.lastCompletedCheckpoint, isNull);
        expect(controller.completedCheckpoints, isEmpty);
        expect(controller.nextCheckpoint, equals(Checkpoint.chihuahua));
      });
    });

    group('Display Methods', () {
      test('should return correct segment display for initial state', () {
        controller.initializePath(PathType.dogBreeds);
        expect(
          controller.currentSegmentDisplay,
          equals('0/10 questions to Chihuahua'),
        );
      });

      test('should return correct segment display during progress', () {
        controller.initializePath(PathType.dogBreeds);

        // Answer 5 questions
        for (int i = 0; i < 5; i++) {
          controller.incrementQuestionCount();
        }

        expect(
          controller.currentSegmentDisplay,
          equals('5/10 questions to Chihuahua'),
        );
      });

      test(
        'should return correct segment display after checkpoint completion',
        () {
          controller.initializePath(PathType.dogBreeds);

          // Complete first checkpoint and answer 5 more
          for (int i = 0; i < 15; i++) {
            controller.incrementQuestionCount();
          }

          expect(
            controller.currentSegmentDisplay,
            equals('5/10 questions to Cocker Spaniel'),
          );
        },
      );

      test('should return completion message when path is completed', () {
        controller.initializePath(PathType.dogBreeds);

        // Complete all checkpoints
        for (int i = 0; i < 50; i++) {
          controller.incrementQuestionCount();
        }

        expect(controller.currentSegmentDisplay, equals('Path Completed!'));
      });
    });

    group('Manual Checkpoint Completion', () {
      test('should allow manual checkpoint completion', () {
        controller.initializePath(PathType.dogBreeds);

        controller.completeCheckpoint(Checkpoint.chihuahua);

        expect(
          controller.completedCheckpoints.contains(Checkpoint.chihuahua),
          isTrue,
        );
        expect(
          controller.lastCompletedCheckpoint,
          equals(Checkpoint.chihuahua),
        );
      });

      test('should not duplicate checkpoint completion', () {
        controller.initializePath(PathType.dogBreeds);

        controller.completeCheckpoint(Checkpoint.chihuahua);
        controller.completeCheckpoint(Checkpoint.chihuahua);

        expect(controller.completedCheckpoints.length, equals(1));
        expect(
          controller.completedCheckpoints.contains(Checkpoint.chihuahua),
          isTrue,
        );
      });
    });
  });
}
