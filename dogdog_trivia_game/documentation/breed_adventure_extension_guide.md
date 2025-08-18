# Dog Breed Adventure: Extension Guide

## 1. Introduction

This guide provides instructions on how to extend the Dog Breed Adventure feature. The feature has been designed with extensibility in mind, making it easy to add new content and functionality.

## 2. Architectural Principles

The extensibility of the Dog Breed Adventure feature is based on the following architectural principles:

*   **Separation of Concerns**: The code is divided into logical layers (models, views, controllers, services), which makes it easy to modify one part of the system without affecting the others.
*   **Dependency Injection**: The `BreedAdventureController` receives its dependencies (the services) through its constructor. This makes it easy to replace a service with a different implementation or to add a new service.
*   **Configuration over Code**: Much of the game's content, such as the list of breeds, is defined in a configuration file (`assets/data/breeds.json`). This makes it easy to add new content without modifying the code.

## 3. Extending the Feature

This section provides step-by-step instructions for common extension scenarios.

### 3.1. Adding New Breeds

To add a new breed to the game, you need to follow these steps:

1.  **Add the breed to the JSON file**: Open `assets/data/breeds.json` and add a new entry for the breed. The entry should have the following format:
    ```json
    {
      "name": "New Breed Name",
      "imageUrl": "url_to_image",
      "difficulty": 3
    }
    ```
    *   `name`: The name of the breed.
    *   `imageUrl`: A URL to a high-quality image of the breed.
    *   `difficulty`: A number between 1 and 5 that represents the difficulty of identifying the breed.

2.  **Add translations (optional)**: If the breed name needs to be translated, add it to the `_breedTranslations` map in `lib/services/breed_adventure/breed_service.dart`.
    ```dart
    static const Map<String, Map<String, String>> _breedTranslations = {
      // ... existing translations
      'New Breed Name': {
        'de': 'Neuer Rassenname',
        'es': 'Nuevo Nombre de Raza',
        'en': 'New Breed Name',
      },
    };
    ```

3.  **Verify**: Run the game and check if the new breed appears in the appropriate difficulty phase.

### 3.2. Modifying Difficulty Phases

The difficulty phases are defined in the `DifficultyPhase` enum in `lib/models/breed_adventure/difficulty_phase.dart`.

To modify the difficulty ranges, you can edit the `containsDifficulty` method in the `DifficultyPhase` enum:
```dart
extension DifficultyPhaseExtension on DifficultyPhase {
  bool containsDifficulty(int difficulty) {
    switch (this) {
      case DifficultyPhase.beginner:
        return difficulty >= 1 && difficulty <= 2; // Adjust the range here
      case DifficultyPhase.intermediate:
        return difficulty >= 3 && difficulty <= 4; // Adjust the range here
      case DifficultyPhase.expert:
        return difficulty == 5; // Adjust the range here
    }
  }
  // ...
}
```

To add a new difficulty phase, you would need to:
1.  Add a new value to the `DifficultyPhase` enum.
2.  Update the `containsDifficulty` method to include the new phase.
3.  Update the `nextPhase` property to handle the transition to and from the new phase.
4.  Update the `scoreMultiplier` property to define a score multiplier for the new phase.

### 3.3. Adding New Power-Ups

Adding a new power-up is a more involved process. Here's a high-level overview of the steps:

1.  **Define the power-up type**: Add a new value to the `PowerUpType` enum in `lib/models/enums.dart`.

2.  **Implement the power-up logic**: Create a new method in `lib/controllers/breed_adventure/breed_adventure_power_up_controller.dart` to apply the power-up's effect.

3.  **Update the `usePowerUp` method**: In `lib/controllers/breed_adventure/breed_adventure_controller.dart`, update the `usePowerUp` method to call the new logic when the power-up is used.

4.  **Add a UI element**: Add a new button or other UI element to the `PowerUpButtonRow` widget (or another appropriate widget) to allow the user to activate the power-up.

5.  **Add to initial inventory (optional)**: If the power-up should be available at the start of the game, add it to the initial power-ups map in `BreedAdventureGameState.initial()`.

### 3.4. Integrating New Services

To integrate a new service with the `BreedAdventureController`, you need to:

1.  **Create the service**: Create a new Dart class for your service. It's a good practice to create a base class or interface that the service implements.

2.  **Add the service to the controller**:
    *   Add a new field for the service in `BreedAdventureController`.
    *   Add the service to the controller's constructor, using dependency injection. You can provide a default instance if needed.
    ```dart
    class BreedAdventureController extends ChangeNotifier {
      final MyNewService _myNewService;

      BreedAdventureController({
        // ... other services
        MyNewService? myNewService,
      }) : _myNewService = myNewService ?? MyNewService(),
           // ...
    }
    ```

3.  **Use the service**: Call the methods of your new service from the `BreedAdventureController` as needed.

## 4. Best Practices

When extending the Dog Breed Adventure feature, please follow these best practices:

*   **Maintain separation of concerns**: Keep the responsibilities of the different layers separate. Don't put business logic in the UI or UI code in the services.
*   **Write tests**: If you add new functionality, please also add corresponding tests to ensure that it works correctly and doesn't break existing functionality.
*   **Follow existing patterns**: Try to follow the existing architectural patterns and coding style to maintain consistency.
*   **Update documentation**: If you make significant changes, please update the relevant documentation to reflect your changes.
