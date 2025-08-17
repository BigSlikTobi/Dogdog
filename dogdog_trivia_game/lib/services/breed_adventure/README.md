# Breed Adventure Services

This directory contains the services for the Dog Breed Adventure feature. Services encapsulate specific business logic and provide functionalities that can be shared across the application.

## Files

*   **`breed_service.dart`**: The core service for the feature. It is responsible for loading the breed data from `assets/data/breeds.json`, generating challenges, and handling breed name localization.
*   **`breed_adventure_timer.dart`**: Manages the 10-second countdown timer for each challenge.
*   **`breed_adventure_state_manager.dart`**: Handles the saving and loading of the game state for persistence.
*   **`breed_localization_service.dart`**: Provides localization for breed names.
*   **`optimized_image_cache_service.dart`**: An advanced image caching service that helps to improve performance by preloading and caching breed images.
*   **`breed_adventure_memory_manager.dart`**: A service that monitors and manages memory usage to prevent memory-related issues.
*   **`breed_adventure_performance_monitor.dart`**: A service that monitors the performance of the game, such as the frame rate.
*   **`frame_rate_optimizer.dart`**: A service that helps to optimize the frame rate of the game.
*   **`breed_adventure_services.dart`**: A barrel file that exports the services in this directory for easy import.

## Architecture

The services are designed to be self-contained and have a single responsibility. They are typically used by the controllers, which access them through dependency injection. This makes the code modular and easy to test, as services can be mocked or replaced with alternative implementations.
