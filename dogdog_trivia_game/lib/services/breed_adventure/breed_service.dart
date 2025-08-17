import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/error_service.dart';

/// Service for managing breed data, localization, and challenge generation
class BreedService {
  static BreedService? _instance;
  static BreedService get instance => _instance ??= BreedService._();

  BreedService._();

  /// Factory constructor for testing purposes
  @visibleForTesting
  factory BreedService.forTesting() => BreedService._();

  List<Breed> _allBreeds = [];
  bool _isInitialized = false;
  final Random _random = Random();

  /// Breed name translations for supported languages
  static const Map<String, Map<String, String>> _breedTranslations = {
    'German Shepherd Dog': {
      'de': 'Deutscher Schäferhund',
      'es': 'Pastor Alemán',
      'en': 'German Shepherd Dog',
    },
    'Golden Retriever': {
      'de': 'Golden Retriever',
      'es': 'Golden Retriever',
      'en': 'Golden Retriever',
    },
    'Labrador Retriever': {
      'de': 'Labrador Retriever',
      'es': 'Labrador Retriever',
      'en': 'Labrador Retriever',
    },
    'French Bulldog': {
      'de': 'Französische Bulldogge',
      'es': 'Bulldog Francés',
      'en': 'French Bulldog',
    },
    'Bulldog': {
      'de': 'Englische Bulldogge',
      'es': 'Bulldog Inglés',
      'en': 'Bulldog',
    },
    'Poodle': {'de': 'Pudel', 'es': 'Caniche', 'en': 'Poodle'},
    'Beagle': {'de': 'Beagle', 'es': 'Beagle', 'en': 'Beagle'},
    'Rottweiler': {'de': 'Rottweiler', 'es': 'Rottweiler', 'en': 'Rottweiler'},
    'Yorkshire Terrier': {
      'de': 'Yorkshire Terrier',
      'es': 'Yorkshire Terrier',
      'en': 'Yorkshire Terrier',
    },
    'Dachshund (Standard)': {'de': 'Dackel', 'es': 'Teckel', 'en': 'Dachshund'},
    'Siberian Husky': {
      'de': 'Sibirischer Husky',
      'es': 'Husky Siberiano',
      'en': 'Siberian Husky',
    },
    'Shih Tzu': {'de': 'Shih Tzu', 'es': 'Shih Tzu', 'en': 'Shih Tzu'},
    'Boston Terrier': {
      'de': 'Boston Terrier',
      'es': 'Boston Terrier',
      'en': 'Boston Terrier',
    },
    'Pomeranian': {'de': 'Zwergspitz', 'es': 'Pomerania', 'en': 'Pomeranian'},
    'Australian Shepherd': {
      'de': 'Australian Shepherd',
      'es': 'Pastor Australiano',
      'en': 'Australian Shepherd',
    },
    'Border Collie': {
      'de': 'Border Collie',
      'es': 'Border Collie',
      'en': 'Border Collie',
    },
    'Chihuahua': {'de': 'Chihuahua', 'es': 'Chihuahua', 'en': 'Chihuahua'},
    'Boxer': {'de': 'Boxer', 'es': 'Bóxer', 'en': 'Boxer'},
    'Cocker Spaniel (English)': {
      'de': 'English Cocker Spaniel',
      'es': 'Cocker Spaniel Inglés',
      'en': 'English Cocker Spaniel',
    },
    'Dalmatian': {'de': 'Dalmatiner', 'es': 'Dálmata', 'en': 'Dalmatian'},
  };

  /// Initialize the breed service by loading breed data
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/breeds.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      _allBreeds = jsonData
          .map((json) => Breed.fromJson(json as Map<String, dynamic>))
          .where((breed) => breed.difficulty >= 1 && breed.difficulty <= 5)
          .toList();

      _isInitialized = true;
    } catch (e, stack) {
      await ErrorService().recordError(
        ErrorType.network,
        'Failed to initialize BreedService',
        severity: ErrorSeverity.high,
        stackTrace: stack,
        originalError: e,
      );
      throw Exception('Failed to initialize BreedService: $e');
    }
  }

  /// Get all breeds filtered by difficulty phase
  List<Breed> getBreedsByDifficultyPhase(DifficultyPhase phase) {
    _ensureInitialized();

    return _allBreeds
        .where((breed) => phase.containsDifficulty(breed.difficulty))
        .toList();
  }

  /// Get the total number of breeds in a specific difficulty phase
  int getTotalBreedsInPhase(DifficultyPhase phase) {
    return getBreedsByDifficultyPhase(phase).length;
  }

  /// Get localized breed name for the given locale
  String getLocalizedBreedName(String breedName, Locale locale) {
    final languageCode = locale.languageCode;

    // Handle empty or whitespace-only strings
    if (breedName.trim().isEmpty) {
      return breedName;
    }

    // Try to find exact match first
    if (_breedTranslations.containsKey(breedName)) {
      return _breedTranslations[breedName]![languageCode] ??
          _breedTranslations[breedName]!['en'] ??
          breedName;
    }

    // Try to find partial match (for breeds with variations)
    for (final entry in _breedTranslations.entries) {
      if (breedName.toLowerCase().contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(breedName.toLowerCase())) {
        return entry.value[languageCode] ?? entry.value['en'] ?? breedName;
      }
    }

    // Fallback to original name
    return breedName;
  }

  /// Generate a breed challenge with one correct and one incorrect image
  Future<BreedChallenge> generateChallenge(
    DifficultyPhase phase,
    Set<String> usedBreeds,
  ) async {
    _ensureInitialized();

    final availableBreeds = getBreedsByDifficultyPhase(
      phase,
    ).where((breed) => !usedBreeds.contains(breed.name)).toList();

    if (availableBreeds.isEmpty) {
      throw Exception('No available breeds for phase $phase');
    }

    // Select correct breed
    final correctBreed =
        availableBreeds[_random.nextInt(availableBreeds.length)];

    // Select incorrect breed from different difficulty or same phase
    final incorrectBreeds = _allBreeds
        .where(
          (breed) =>
              breed.name != correctBreed.name &&
              !usedBreeds.contains(breed.name),
        )
        .toList();

    if (incorrectBreeds.isEmpty) {
      throw Exception('No available incorrect breeds for challenge');
    }

    final incorrectBreed =
        incorrectBreeds[_random.nextInt(incorrectBreeds.length)];

    // Randomly decide which position (0 or 1) the correct image should be in
    final correctImageIndex = _random.nextInt(2);

    return BreedChallenge(
      correctBreedName: correctBreed.name,
      correctImageUrl: correctBreed.imageUrl,
      incorrectImageUrl: incorrectBreed.imageUrl,
      correctImageIndex: correctImageIndex,
      phase: phase,
    );
  }

  /// Get available breeds for a phase excluding used ones
  List<Breed> getAvailableBreeds(
    DifficultyPhase phase,
    Set<String> usedBreeds,
  ) {
    return getBreedsByDifficultyPhase(
      phase,
    ).where((breed) => !usedBreeds.contains(breed.name)).toList();
  }

  /// Check if there are any available breeds left in the current phase
  bool hasAvailableBreeds(DifficultyPhase phase, Set<String> usedBreeds) {
    return getAvailableBreeds(phase, usedBreeds).isNotEmpty;
  }

  /// Get breed by name (for testing and debugging)
  Breed? getBreedByName(String name) {
    _ensureInitialized();

    try {
      return _allBreeds.firstWhere((breed) => breed.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Get all supported language codes for breed translations
  List<String> getSupportedLanguages() {
    return ['en', 'de', 'es'];
  }

  /// Check if a breed name has translations available
  bool hasTranslation(String breedName) {
    if (breedName.trim().isEmpty) return false;

    return _breedTranslations.containsKey(breedName) ||
        _breedTranslations.keys.any(
          (key) =>
              breedName.toLowerCase().contains(key.toLowerCase()) ||
              key.toLowerCase().contains(breedName.toLowerCase()),
        );
  }

  /// Get statistics about breed distribution across difficulty phases
  Map<DifficultyPhase, int> getBreedDistribution() {
    _ensureInitialized();

    return {
      for (final phase in DifficultyPhase.values)
        phase: getTotalBreedsInPhase(phase),
    };
  }

  /// Reset the service (mainly for testing)
  void reset() {
    _allBreeds.clear();
    _isInitialized = false;
  }

  /// Ensure the service is initialized before use
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception('BreedService not initialized. Call initialize() first.');
    }
  }

  /// Get all breeds (for testing and debugging)
  List<Breed> get allBreeds {
    _ensureInitialized();
    return List.unmodifiable(_allBreeds);
  }

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  // MARK: - Error Handling and Recovery Methods

  /// Get breeds for phase with fallback to other phases if needed
  List<Breed> getBreedsForPhaseWithFallback(DifficultyPhase phase) {
    try {
      _ensureInitialized();

      // Try the requested phase first
      var breeds = getBreedsByDifficultyPhase(phase);

      if (breeds.isNotEmpty) {
        return breeds;
      }

      // Fallback to other phases in order of preference
      final fallbackPhases = _getFallbackPhases(phase);

      for (final fallbackPhase in fallbackPhases) {
        breeds = getBreedsByDifficultyPhase(fallbackPhase);
        if (breeds.isNotEmpty) {
          return breeds;
        }
      }

      // Final fallback - return any available breeds
      return List.from(_allBreeds);
    } catch (e, stack) {
      ErrorService().recordError(
        ErrorType.network,
        'Failed to get breeds for phase with fallback',
        severity: ErrorSeverity.medium,
        stackTrace: stack,
        originalError: e,
      );
      // Return hardcoded fallback breeds
      return _getHardcodedFallbackBreeds();
    }
  }

  /// Generate challenge with error recovery
  Future<BreedChallenge> generateChallengeWithFallback(
    DifficultyPhase phase,
    Set<String> usedBreeds,
  ) async {
    try {
      return await generateChallenge(phase, usedBreeds);
    } catch (e, stack) {
      ErrorService().recordError(
        ErrorType.gameLogic,
        'Failed to generate challenge with fallback (phase: $phase)',
        severity: ErrorSeverity.medium,
        stackTrace: stack,
        originalError: e,
      );
      // Try with empty used breeds set
      try {
        return await generateChallenge(phase, <String>{});
      } catch (e2, stack2) {
        ErrorService().recordError(
          ErrorType.gameLogic,
          'Failed to generate fallback challenge (phase: $phase)',
          severity: ErrorSeverity.high,
          stackTrace: stack2,
          originalError: e2,
        );
        // Final fallback - create basic challenge
        return _createFallbackChallenge(phase);
      }
    }
  }

  /// Validate breed data integrity
  bool validateBreedData() {
    try {
      if (_allBreeds.isEmpty) return false;

      // Check that each difficulty phase has at least 2 breeds
      for (final phase in DifficultyPhase.values) {
        final breeds = getBreedsByDifficultyPhase(phase);
        if (breeds.length < 2) {
          return false;
        }
      }

      // Check that breed translations are available
      if (_breedTranslations.isEmpty) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get fallback phases in order of preference
  List<DifficultyPhase> _getFallbackPhases(DifficultyPhase phase) {
    switch (phase) {
      case DifficultyPhase.beginner:
        return [DifficultyPhase.intermediate, DifficultyPhase.expert];
      case DifficultyPhase.intermediate:
        return [DifficultyPhase.beginner, DifficultyPhase.expert];
      case DifficultyPhase.expert:
        return [DifficultyPhase.intermediate, DifficultyPhase.beginner];
    }
  }

  /// Get hardcoded fallback breeds when all else fails
  List<Breed> _getHardcodedFallbackBreeds() {
    return [
      Breed(
        name: 'German Shepherd',
        imageUrl: 'assets/images/schaeferhund.png',
        difficulty: 1, // Beginner
      ),
      Breed(
        name: 'Golden Retriever',
        imageUrl: 'assets/images/cocker.png',
        difficulty: 1, // Beginner
      ),
      Breed(
        name: 'Bulldog',
        imageUrl: 'assets/images/dogge.png',
        difficulty: 3, // Intermediate
      ),
      Breed(
        name: 'Pug',
        imageUrl: 'assets/images/mops.png',
        difficulty: 5, // Expert
      ),
    ];
  }

  /// Create fallback challenge with local assets
  BreedChallenge _createFallbackChallenge(DifficultyPhase phase) {
    final fallbackBreeds = _getHardcodedFallbackBreeds();

    // Filter by phase if possible, otherwise use any two breeds
    var availableBreeds = fallbackBreeds
        .where((b) => _getDifficultyPhaseFromInt(b.difficulty) == phase)
        .toList();

    if (availableBreeds.length < 2) {
      availableBreeds = fallbackBreeds.take(2).toList();
    }

    if (availableBreeds.length >= 2) {
      final correctBreed = availableBreeds[0];
      final incorrectBreed = availableBreeds[1];

      return BreedChallenge(
        correctBreedName: correctBreed.name,
        correctImageUrl: correctBreed.imageUrl,
        incorrectImageUrl: incorrectBreed.imageUrl,
        correctImageIndex: 0, // Always put correct on left for simplicity
        phase: phase,
      );
    }

    // Absolute fallback
    return BreedChallenge(
      correctBreedName: 'German Shepherd',
      correctImageUrl: 'assets/images/schaeferhund.png',
      incorrectImageUrl: 'assets/images/cocker.png',
      correctImageIndex: 0,
      phase: DifficultyPhase.beginner,
    );
  }

  /// Convert difficulty int to phase (helper method)
  DifficultyPhase _getDifficultyPhaseFromInt(int difficulty) {
    if (difficulty <= 2) return DifficultyPhase.beginner;
    if (difficulty <= 4) return DifficultyPhase.intermediate;
    return DifficultyPhase.expert;
  }

  /// Recovery from corrupted state
  Future<void> recoverFromError() async {
    try {
      // Reset state
      _allBreeds.clear();
      _breedTranslations.clear();
      _isInitialized = false;

      // Attempt re-initialization
      await initialize();
    } catch (e) {
      // If re-initialization fails, set up minimal fallback state
      _allBreeds.addAll(_getHardcodedFallbackBreeds());
      _setupFallbackTranslations();
      _isInitialized = true;
    }
  }

  /// Setup minimal translations for fallback breeds
  void _setupFallbackTranslations() {
    _breedTranslations.addAll({
      'German Shepherd': {
        'en': 'German Shepherd',
        'de': 'Deutscher Schäferhund',
        'es': 'Pastor Alemán',
      },
      'Golden Retriever': {
        'en': 'Golden Retriever',
        'de': 'Golden Retriever',
        'es': 'Retriever Dorado',
      },
      'Bulldog': {'en': 'Bulldog', 'de': 'Bulldogge', 'es': 'Bulldog'},
      'Pug': {'en': 'Pug', 'de': 'Mops', 'es': 'Carlino'},
    });
  }
}
