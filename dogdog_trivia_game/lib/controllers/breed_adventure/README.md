# Breed Adventure Controllers

This directory contains the controllers for the Dog Breed Adventure feature. Controllers are responsible for managing the state and business logic of the feature.

## Files

*   **`breed_adventure_controller.dart`**: The main controller for the Dog Breed Adventure game. It manages the game state, handles user input, and coordinates the various services.
*   **`breed_adventure_power_up_controller.dart`**: This controller manages the logic for the power-ups used in the Dog Breed Adventure game.
*   **`breed_adventure_controllers.dart`**: A barrel file that exports the controllers in this directory for easy import into other files.

## Architecture

The controllers follow the Provider pattern for state management. The `BreedAdventureController` is a `ChangeNotifier`, which means that it can notify its listeners (the UI) when its state changes. This allows the UI to rebuild and reflect the new state.
