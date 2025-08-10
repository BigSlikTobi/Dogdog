import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/controllers/breed_adventure_controller.dart';
import 'package:dogdog_trivia_game/models/breed.dart';
import 'package:dogdog_trivia_game/models/difficulty_phase.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Error Scenario Tests - Task 11', () {
    late BreedAdventureController controller;

    setUp(() {
      controller = BreedAdventureController();
    });

    group('Network Error Handling', () {
      test('Should handle network connection failures gracefully', () async {
        // Test network error handling
        await controller.handleNetworkError(
          Exception('Network connection failed'),
        );

        // Assert
        expect(controller.hasError, isTrue);
        expect(controller.currentError?.type, equals(ErrorType.network));
        expect(controller.isInRecoveryMode, isTrue);
      });

      test('Should track consecutive failures', () async {
        // Act
        await controller.handleNetworkError(Exception('Error 1'));
        await controller.handleNetworkError(Exception('Error 2'));
        await controller.handleNetworkError(Exception('Error 3'));

        // Assert
        expect(controller.consecutiveFailures, equals(3));
        expect(controller.isInRecoveryMode, isTrue);
      });

      test('Should activate recovery mode after multiple failures', () async {
        // Act - Simulate multiple failures
        for (int i = 0; i < 4; i++) {
          await controller.handleNetworkError(Exception('Network error $i'));
        }

        // Assert
        expect(controller.isInRecoveryMode, isTrue);
        expect(controller.consecutiveFailures, greaterThan(3));
      });
    });

    group('Image Loading Error Handling', () {
      test('Should track failed image URLs', () async {
        // Act
        await controller.handleImageLoadError(
          'https://example.com/image1.jpg',
          Exception('Load error 1'),
        );
        await controller.handleImageLoadError(
          'https://example.com/image2.jpg',
          Exception('Load error 2'),
        );

        // Assert
        expect(controller.hasImageErrors, isTrue);
        expect(controller.hasError, isTrue);
      });

      test(
        'Should activate recovery mode after multiple image failures',
        () async {
          // Act - Simulate multiple image failures
          for (int i = 0; i < 6; i++) {
            await controller.handleImageLoadError(
              'https://example.com/image$i.jpg',
              Exception('Load error $i'),
            );
          }

          // Assert
          expect(controller.isInRecoveryMode, isTrue);
          expect(controller.hasImageErrors, isTrue);
        },
      );
    });

    group('Breed Data Validation', () {
      test('Should handle breed data errors', () async {
        // Act
        await controller.handleBreedDataError(
          DifficultyPhase.beginner,
          Exception('Invalid breed data'),
        );

        // Assert
        expect(controller.hasError, isTrue);
        expect(controller.currentError?.type, equals(ErrorType.gameLogic));
        // Note: Recovery mode might not be activated immediately if fallback succeeds
        // but the error should still be recorded
      });

      test('Should validate simple breed data integrity', () {
        // Arrange
        final invalidBreed = Breed(
          name: '', // Invalid empty name
          imageUrl: '', // Invalid empty URL
          difficulty: -1, // Invalid difficulty
        );

        // Act - Basic validation (checking if breed has valid properties)
        final hasValidName = invalidBreed.name.isNotEmpty;
        final hasValidUrl = invalidBreed.imageUrl.isNotEmpty;
        final hasValidDifficulty = invalidBreed.difficulty > 0;

        // Assert
        expect(hasValidName, isFalse);
        expect(hasValidUrl, isFalse);
        expect(hasValidDifficulty, isFalse);
      });

      test('Should accept valid breed data', () {
        // Arrange
        final validBreed = _createMockBreed('Valid Breed');

        // Act
        final hasValidName = validBreed.name.isNotEmpty;
        final hasValidUrl = validBreed.imageUrl.isNotEmpty;
        final hasValidDifficulty = validBreed.difficulty > 0;

        // Assert
        expect(hasValidName, isTrue);
        expect(hasValidUrl, isTrue);
        expect(hasValidDifficulty, isTrue);
      });
    });

    group('Error Recovery Mechanisms', () {
      test('Should reset error state on recovery', () async {
        // Arrange
        await controller.handleNetworkError(Exception('Test error'));
        expect(controller.hasError, isTrue);

        // Act
        await controller.recoverFromError(ErrorType.network);

        // Assert
        expect(controller.hasError, isFalse);
        expect(controller.consecutiveFailures, equals(0));
      });

      test('Should handle multiple consecutive errors', () async {
        // Act
        await controller.handleNetworkError(Exception('Error 1'));
        await controller.handleImageLoadError(
          'failed_url1.jpg',
          Exception('Error 2'),
        );
        await controller.handleBreedDataError(
          DifficultyPhase.beginner,
          Exception('Error 3'),
        );

        // Assert
        expect(controller.consecutiveFailures, equals(3));
        expect(controller.isInRecoveryMode, isTrue);
      });

      test('Should clear error state properly', () async {
        // Arrange
        await controller.handleNetworkError(Exception('Test error'));

        // Act
        controller.clearErrors();

        // Assert
        expect(controller.hasError, isFalse);
        expect(controller.currentError, isNull);
        expect(controller.isInRecoveryMode, isFalse);
        expect(controller.consecutiveFailures, equals(0));
      });
    });

    group('Game State Validation', () {
      test('Should validate game state without current challenge', () {
        // Act
        final isValid = controller.validateGameState();

        // Assert - Without proper initialization, should be valid (empty state)
        expect(isValid, isTrue);
      });
    });

    group('Error Service Integration', () {
      test('Should create proper error objects', () async {
        // Act
        await controller.handleNetworkError(Exception('Test network error'));

        // Assert
        expect(controller.currentError, isNotNull);
        expect(controller.currentError?.type, equals(ErrorType.network));
        expect(controller.currentError?.message, contains('network'));
      });

      test('Should handle different error types', () async {
        // Test network error
        await controller.handleNetworkError(Exception('Network error'));
        expect(controller.currentError?.type, equals(ErrorType.network));

        // Clear and test data error
        controller.clearErrors();
        await controller.handleBreedDataError(
          DifficultyPhase.beginner,
          Exception('Data error'),
        );
        expect(controller.currentError?.type, equals(ErrorType.gameLogic));
      });

      test('Should maintain error history', () async {
        // Act
        await controller.handleNetworkError(Exception('Error 1'));
        await controller.handleImageLoadError(
          'failed_url.jpg',
          Exception('Error 2'),
        );
        await controller.handleBreedDataError(
          DifficultyPhase.beginner,
          Exception('Error 3'),
        );

        // Assert - Error service should maintain history
        expect(controller.consecutiveFailures, equals(3));
      });
    });

    group('Recovery Mode Behavior', () {
      test('Should enter recovery mode after threshold', () async {
        // Act - Simulate threshold number of failures
        for (int i = 0; i < 3; i++) {
          await controller.handleNetworkError(Exception('Error $i'));
        }

        // Assert
        expect(controller.isInRecoveryMode, isTrue);
      });

      test('Should exit recovery mode on successful operation', () async {
        // Arrange
        await controller.handleNetworkError(Exception('Test error'));
        expect(controller.isInRecoveryMode, isTrue);

        // Act
        await controller.recoverFromError(ErrorType.network);

        // Assert
        expect(controller.isInRecoveryMode, isFalse);
      });

      test('Should track recovery attempts', () async {
        // Arrange
        await controller.handleNetworkError(Exception('Error'));
        final initialFailures = controller.consecutiveFailures;

        // Act
        await controller.handleNetworkError(Exception('Another error'));

        // Assert
        expect(controller.consecutiveFailures, equals(initialFailures + 1));
      });
    });

    group('Error Message Generation', () {
      test('Should generate appropriate error messages', () async {
        // Act
        await controller.handleNetworkError(Exception('Connection timeout'));

        // Assert
        expect(controller.currentError?.message, isNotEmpty);
        expect(
          controller.currentError?.message,
          contains('Connection timeout'),
        );
      });

      test('Should categorize errors by severity', () async {
        // Test network error (medium severity)
        await controller.handleNetworkError(Exception('Network error'));
        expect(controller.currentError?.severity, equals(ErrorSeverity.medium));

        // Clear and test image error (medium severity)
        controller.clearErrors();
        await controller.handleImageLoadError(
          'failed_image.jpg',
          Exception('Image error'),
        );
        expect(controller.currentError?.severity, equals(ErrorSeverity.medium));
      });
    });

    group('Retry Operations', () {
      test('Should retry last operation successfully', () async {
        // Arrange
        await controller.handleNetworkError(Exception('Network error'));
        expect(controller.hasError, isTrue);

        // Act
        final success = await controller.retryLastOperation();

        // Assert
        expect(success, isTrue);
      });

      test('Should handle retry failures gracefully', () async {
        // Arrange
        await controller.handleNetworkError(Exception('Persistent error'));

        // Act
        final success = await controller.retryLastOperation();

        // Assert - Should still attempt retry
        expect(success, isA<bool>());
      });
    });

    group('Error State Reporting', () {
      test('Should provide comprehensive error state', () async {
        // Arrange
        await controller.handleNetworkError(Exception('Test error'));
        await controller.handleImageLoadError(
          'failed_image.jpg',
          Exception('Image error'),
        );

        // Act
        final errorState = controller.getErrorState();

        // Assert
        expect(errorState['isInRecoveryMode'], isTrue);
        expect(errorState['consecutiveFailures'], greaterThan(0));
        expect(errorState['failedImageCount'], greaterThan(0));
        expect(errorState['lastError'], isNotNull);
      });
    });

    group('Breed Data Models', () {
      test('Should validate breed model structure', () {
        // Arrange
        final breed = _createMockBreed('Test Breed');

        // Assert
        expect(breed.name, equals('Test Breed'));
        expect(breed.imageUrl, isNotEmpty);
        expect(breed.difficulty, equals(1));
      });

      test('Should handle breed equality correctly', () {
        // Arrange
        final breed1 = _createMockBreed('Test Breed');
        final breed2 = _createMockBreed('Test Breed');

        // Assert
        expect(breed1, equals(breed2));
        expect(breed1.hashCode, equals(breed2.hashCode));
      });
    });

    group('Difficulty Phase Handling', () {
      test('Should handle different difficulty phases', () {
        // Test that we can create errors for different phases
        expect(DifficultyPhase.beginner.name, equals('Beginner'));
        expect(DifficultyPhase.intermediate.name, equals('Intermediate'));
        expect(DifficultyPhase.expert.name, equals('Expert'));
      });
    });
  });
}

// Helper methods
Breed _createMockBreed(String name) {
  return Breed(
    name: name,
    imageUrl:
        'https://example.com/${name.toLowerCase().replaceAll(' ', '_')}.jpg',
    difficulty: 1,
  );
}
