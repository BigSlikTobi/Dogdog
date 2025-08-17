# Breed Adventure Models

This directory contains the data models for the Dog Breed Adventure feature. Models are immutable data structures that represent the state and entities of the feature.

## Files

*   **`breed_adventure_game_state.dart`**: This is the central model that encapsulates the entire state of a Dog Breed Adventure game session. It includes properties for the score, current phase, used breeds, and more.
*   **`breed_challenge.dart`**: This model represents a single challenge in the game. It contains the correct breed, an incorrect breed, and the index of the correct image.
*   **`difficulty_phase.dart`**: This enum defines the different difficulty levels of the game: `beginner`, `intermediate`, and `expert`.

## Architecture

The models are designed to be immutable. This means that once an instance of a model is created, it cannot be changed. To update the state, you create a new instance of the model with the updated values. This approach, combined with the Provider pattern, ensures a predictable and unidirectional data flow.
