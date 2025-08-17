# Dog Breed Adventure: Debugging and Troubleshooting Guide

## 1. Introduction

This guide provides instructions for debugging and troubleshooting common issues in the Dog Breed Adventure feature. It covers a range of potential problems, from data loading errors to performance bottlenecks.

## 2. General Debugging Tools

Before diving into specific issues, it's important to be familiar with the general-purpose debugging tools available for Flutter development.

### 2.1. Flutter DevTools

Flutter DevTools is a suite of performance and debugging tools for Dart and Flutter. It is an essential tool for diagnosing issues in the Dog Breed Adventure feature. You can use it to:

*   **Inspect the widget tree**: Understand the layout of the UI and identify any layout issues.
*   **Monitor performance**: Analyze the frame rate, CPU usage, and memory allocation.
*   **Debug memory leaks**: Identify objects that are not being garbage collected correctly.
*   **Debug network requests**: Inspect the network traffic and identify any failed requests.

You can launch DevTools from your IDE or by running `flutter devtools` in your terminal.

### 2.2. Logging

The Dog Breed Adventure feature includes extensive logging to help you understand what's happening under the hood. You can view the logs in your IDE's console or by using the `flutter logs` command.

The `BreedAdventureController` and other services log important events, such as:

*   Game state changes
*   Challenge generation
*   Image loading events
*   Errors and exceptions

Look for log messages prefixed with `[BreedAdventure]` to filter for logs related to this feature.

## 3. Troubleshooting Common Issues

This section provides guidance on how to troubleshoot specific issues that you might encounter.

### 3.1. Data Loading Issues

**Symptom**: The game fails to start, and you see an error in the logs related to loading `assets/data/breeds.json`.

**Causes**:

*   The `breeds.json` file is missing or corrupted.
*   The path to the file is incorrect in `pubspec.yaml`.
*   The JSON format is invalid.

**Troubleshooting Steps**:

1.  **Verify the file path**: Make sure that `assets/data/breeds.json` is listed in the `assets` section of `pubspec.yaml`.
2.  **Check the file content**: Ensure that the `breeds.json` file exists at the specified path and that its content is valid JSON. You can use an online JSON validator to check the syntax.
3.  **Check the logs**: Look for error messages in the logs that provide more details about the failure. The `BreedService` will log an error if it fails to initialize.

### 3.2. Image Loading Issues

**Symptom**: Breed images are not displayed, or you see placeholder images instead.

**Causes**:

*   The device has no network connectivity.
*   The image URLs in `breeds.json` are incorrect or the images are no longer available at those URLs.
*   The `ImageCacheService` is not functioning correctly.

**Troubleshooting Steps**:

1.  **Check network connectivity**: Ensure that the device or emulator has a working internet connection.
2.  **Verify image URLs**: Check a few image URLs from `breeds.json` in your browser to make sure they are valid.
3.  **Inspect network requests**: Use Flutter DevTools' network inspector to see if the image requests are being made and if they are succeeding.
4.  **Check the image cache**: The `ImageCacheService` logs information about cache hits and misses. Check the logs to see if the images are being cached correctly.
5.  **Review error handling**: The `BreedAdventureController` has logic to handle image loading errors. Check the `handleImageLoadError` method to see how these errors are being managed.

### 3.3. Game Logic Bugs

**Symptom**: The game is not behaving as expected. For example, the score is not updating correctly, the difficulty phase is not progressing, or power-ups are not working.

**Causes**:

*   A bug in the `BreedAdventureController`.
*   A problem with the `BreedAdventureGameState`.
*   An issue with one of the services.

**Troubleshooting Steps**:

1.  **Use the debugger**: Set breakpoints in the relevant methods of the `BreedAdventureController` to step through the code and inspect the state.
2.  **Inspect the game state**: Use the debugger to inspect the `_gameState` variable in the `BreedAdventureController`. Check if the values of the properties are what you expect.
3.  **Review the controller logic**: Carefully review the logic in the `BreedAdventureController` to see if you can spot any errors. Pay close attention to the methods that handle user input and update the game state.
4.  **Check the service logic**: If the issue seems to be related to a specific service (e.g., the `BreedService` is not generating challenges correctly), set breakpoints in that service to debug its logic.

### 3.4. Performance Problems

**Symptom**: The game is running slowly, the animations are jerky (jank), or the app is using a lot of memory.

**Causes**:

*   Rebuilding widgets unnecessarily.
*   Performing expensive operations on the main thread.
*   Memory leaks.
*   Large images that are not being optimized.

**Troubleshooting Steps**:

1.  **Use the Performance view in DevTools**: This tool helps you identify performance issues by showing you the frame rate, CPU usage, and a flame chart of the activity in your app.
2.  **Check for unnecessary rebuilds**: Use the "Track Widget Builds" feature in DevTools to see which widgets are being rebuilt. If a widget is being rebuilt unnecessarily, you may need to refactor your code to prevent it.
3.  **Analyze memory usage**: Use the Memory view in DevTools to see how much memory your app is using and to identify any potential memory leaks.
4.  **Optimize images**: Ensure that the breed images are appropriately sized and compressed. The `OptimizedImageCacheService` helps with this, but the source images should also be optimized.

### 3.5. Localization Issues

**Symptom**: Breed names are not being translated into the selected language.

**Causes**:

*   The translations are missing from the `_breedTranslations` map in `BreedService`.
*   The `getLocalizedBreedName` method in `BreedService` has a bug.
*   The device's locale is not being detected correctly.

**Troubleshooting Steps**:

1.  **Check the translations map**: Verify that the `_breedTranslations` map in `BreedService` contains the correct translations for the breed in question.
2.  **Debug the `getLocalizedBreedName` method**: Set a breakpoint in this method to see what locale is being passed in and what translation is being returned.
3.  **Verify the device locale**: Check the device's language settings to ensure that the locale is set to one of the supported languages (English, German, or Spanish).

## 4. Error Handling and Recovery

The Dog Breed Adventure feature has a robust error handling and recovery system. The `ErrorService` is used to record errors, and the `BreedAdventureController` has several methods for handling and recovering from errors.

When an error occurs, it is recorded by the `ErrorService` with a severity level. The controller then attempts to recover from the error. For example, if an image fails to load, the controller will try to load it again. If the `breeds.json` file cannot be loaded, the `BreedService` will use a hardcoded set of fallback breeds.

When debugging, it is helpful to look at the errors that have been recorded by the `ErrorService`. You can do this by inspecting the `ErrorService` instance in the debugger.
