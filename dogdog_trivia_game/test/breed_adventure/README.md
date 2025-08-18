# Breed Adventure Tests

This directory contains all the tests for the Dog Breed Adventure feature. The tests are organized into subdirectories based on the type of test.

## Test Structure

*   **`integration/`**: Contains integration tests that test the complete flow of the Dog Breed Adventure game.
*   **`unit/`**: Contains unit tests for the individual components of the feature, such as controllers, services, and models.

### Unit Tests

The unit tests are further organized by the type of component they are testing:

*   **`controllers/`**: Unit tests for the `BreedAdventureController` and `BreedAdventurePowerUpController`. These tests verify the game logic, state management, and power-up functionality.
*   **`models/`**: Unit tests for the data models, such as `BreedAdventureGameState`. These tests ensure that the models are created correctly and that their methods work as expected.
*   **`services/`**: Unit tests for the services, such as `BreedService` and `BreedAdventureTimer`. These tests verify that the services provide the correct functionality and handle errors gracefully.
*   **`widgets/`**: Widget tests for the UI components. These tests ensure that the widgets render correctly and respond to user interaction as expected.

## Running the Tests

You can run all the tests for the Dog Breed Adventure feature with the following command:

```bash
flutter test test/breed_adventure/
```

You can also run specific tests by providing the path to the test file:

```bash
flutter test test/breed_adventure/unit/controllers/breed_adventure_controller_test.dart
```

## Test Coverage

The goal is to have high test coverage for the Dog Breed Adventure feature. All new code should be accompanied by corresponding tests. You can generate a test coverage report by running the following command:

```bash
flutter test --coverage
```
