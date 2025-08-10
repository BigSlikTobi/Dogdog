import 'package:flutter/material.dart';

/// Service for localizing dog breed names across different languages
class BreedLocalizationService {
  static const Map<String, Map<String, String>> _breedTranslations = {
    // Popular breeds with translations
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
    'Bulldog': {'de': 'Bulldogge', 'es': 'Bulldog', 'en': 'Bulldog'},
    'Poodle': {'de': 'Pudel', 'es': 'Caniche', 'en': 'Poodle'},
    'Beagle': {'de': 'Beagle', 'es': 'Beagle', 'en': 'Beagle'},
    'Rottweiler': {'de': 'Rottweiler', 'es': 'Rottweiler', 'en': 'Rottweiler'},
    'Yorkshire Terrier': {
      'de': 'Yorkshire Terrier',
      'es': 'Yorkshire Terrier',
      'en': 'Yorkshire Terrier',
    },
    'Dachshund': {'de': 'Dackel', 'es': 'Teckel', 'en': 'Dachshund'},
    'Siberian Husky': {
      'de': 'Sibirischer Husky',
      'es': 'Husky Siberiano',
      'en': 'Siberian Husky',
    },
    'Great Dane': {
      'de': 'Deutsche Dogge',
      'es': 'Gran Danés',
      'en': 'Great Dane',
    },
    'Chihuahua': {'de': 'Chihuahua', 'es': 'Chihuahua', 'en': 'Chihuahua'},
    'Boxer': {'de': 'Boxer', 'es': 'Boxer', 'en': 'Boxer'},
    'Border Collie': {
      'de': 'Border Collie',
      'es': 'Border Collie',
      'en': 'Border Collie',
    },
    'Australian Shepherd': {
      'de': 'Australian Shepherd',
      'es': 'Pastor Australiano',
      'en': 'Australian Shepherd',
    },
    'Cocker Spaniel': {
      'de': 'Cocker Spaniel',
      'es': 'Cocker Spaniel',
      'en': 'Cocker Spaniel',
    },
    'Shih Tzu': {'de': 'Shih Tzu', 'es': 'Shih Tzu', 'en': 'Shih Tzu'},
    'Boston Terrier': {
      'de': 'Boston Terrier',
      'es': 'Boston Terrier',
      'en': 'Boston Terrier',
    },
    'Pomeranian': {'de': 'Zwergspitz', 'es': 'Pomerania', 'en': 'Pomeranian'},
    'Australian Cattle Dog': {
      'de': 'Australian Cattle Dog',
      'es': 'Perro Ganadero Australiano',
      'en': 'Australian Cattle Dog',
    },
    'Mastiff': {'de': 'Mastiff', 'es': 'Mastín', 'en': 'Mastiff'},
    'Doberman Pinscher': {
      'de': 'Dobermann',
      'es': 'Doberman',
      'en': 'Doberman Pinscher',
    },
    'Bernese Mountain Dog': {
      'de': 'Berner Sennenhund',
      'es': 'Boyero de Berna',
      'en': 'Bernese Mountain Dog',
    },
    'Pembroke Welsh Corgi': {
      'de': 'Pembroke Welsh Corgi',
      'es': 'Corgi Galés de Pembroke',
      'en': 'Pembroke Welsh Corgi',
    },
    'Weimaraner': {'de': 'Weimaraner', 'es': 'Weimaraner', 'en': 'Weimaraner'},
    'Basset Hound': {
      'de': 'Basset Hound',
      'es': 'Basset Hound',
      'en': 'Basset Hound',
    },
    'Saint Bernard': {
      'de': 'Bernhardiner',
      'es': 'San Bernardo',
      'en': 'Saint Bernard',
    },
    'Newfoundland': {
      'de': 'Neufundländer',
      'es': 'Terranova',
      'en': 'Newfoundland',
    },
    'Bloodhound': {'de': 'Bloodhound', 'es': 'Sabueso', 'en': 'Bloodhound'},
    'Bull Terrier': {
      'de': 'Bull Terrier',
      'es': 'Bull Terrier',
      'en': 'Bull Terrier',
    },
    'Akita': {'de': 'Akita', 'es': 'Akita', 'en': 'Akita'},
    'Alaskan Malamute': {
      'de': 'Alaskan Malamute',
      'es': 'Malamute de Alaska',
      'en': 'Alaskan Malamute',
    },
    'Rhodesian Ridgeback': {
      'de': 'Rhodesian Ridgeback',
      'es': 'Rhodesian Ridgeback',
      'en': 'Rhodesian Ridgeback',
    },
    'Vizsla': {'de': 'Vizsla', 'es': 'Vizsla', 'en': 'Vizsla'},
    'Whippet': {'de': 'Whippet', 'es': 'Whippet', 'en': 'Whippet'},
    'Greyhound': {'de': 'Windhund', 'es': 'Galgo', 'en': 'Greyhound'},
    'Afghan Hound': {
      'de': 'Afghanischer Windhund',
      'es': 'Lebrel Afgano',
      'en': 'Afghan Hound',
    },
    'Irish Setter': {
      'de': 'Irish Setter',
      'es': 'Setter Irlandés',
      'en': 'Irish Setter',
    },
    'English Springer Spaniel': {
      'de': 'English Springer Spaniel',
      'es': 'Springer Spaniel Inglés',
      'en': 'English Springer Spaniel',
    },
    'Brittany': {'de': 'Bretone', 'es': 'Bretón', 'en': 'Brittany'},
    'Pointer': {'de': 'Pointer', 'es': 'Pointer', 'en': 'Pointer'},
    'Chesapeake Bay Retriever': {
      'de': 'Chesapeake Bay Retriever',
      'es': 'Retriever de la Bahía de Chesapeake',
      'en': 'Chesapeake Bay Retriever',
    },
    'Cane Corso': {'de': 'Cane Corso', 'es': 'Cane Corso', 'en': 'Cane Corso'},
    'Great Pyrenees': {
      'de': 'Pyrenäenberghund',
      'es': 'Pirineo',
      'en': 'Great Pyrenees',
    },
    'Anatolian Shepherd Dog': {
      'de': 'Anatolischer Hirtenhund',
      'es': 'Pastor de Anatolia',
      'en': 'Anatolian Shepherd Dog',
    },
    'Portuguese Water Dog': {
      'de': 'Portugiesischer Wasserhund',
      'es': 'Perro de Agua Portugués',
      'en': 'Portuguese Water Dog',
    },
    'Standard Schnauzer': {
      'de': 'Mittelschnauzer',
      'es': 'Schnauzer Estándar',
      'en': 'Standard Schnauzer',
    },
    'Giant Schnauzer': {
      'de': 'Riesenschnauzer',
      'es': 'Schnauzer Gigante',
      'en': 'Giant Schnauzer',
    },
    'Miniature Schnauzer': {
      'de': 'Zwergschnauzer',
      'es': 'Schnauzer Miniatura',
      'en': 'Miniature Schnauzer',
    },
  };

  /// Get the localized breed name for the given locale
  /// Falls back to English if translation is not available
  static String getLocalizedBreedName(String breedName, Locale locale) {
    final languageCode = locale.languageCode;

    // Check if we have translations for this breed
    final breedTranslations = _breedTranslations[breedName];
    if (breedTranslations == null) {
      return breedName; // Return original name if no translations available
    }

    // Return localized name or fall back to English
    return breedTranslations[languageCode] ??
        breedTranslations['en'] ??
        breedName;
  }

  /// Get all available breed names in the specified locale
  static List<String> getAllLocalizedBreedNames(Locale locale) {
    final languageCode = locale.languageCode;

    return _breedTranslations.keys.map((breedName) {
      final breedTranslations = _breedTranslations[breedName]!;
      return breedTranslations[languageCode] ??
          breedTranslations['en'] ??
          breedName;
    }).toList();
  }

  /// Check if a breed has translations available
  static bool hasTranslation(String breedName, Locale locale) {
    final breedTranslations = _breedTranslations[breedName];
    if (breedTranslations == null) return false;

    return breedTranslations.containsKey(locale.languageCode);
  }

  /// Get all supported language codes for breed translations
  static List<String> getSupportedLanguages() {
    return ['en', 'de', 'es'];
  }

  /// Get the number of breeds that have translations
  static int getTranslatedBreedCount() {
    return _breedTranslations.length;
  }

  /// Get breed translation statistics for a locale
  static Map<String, dynamic> getTranslationStats(Locale locale) {
    final languageCode = locale.languageCode;
    int translatedCount = 0;
    int totalCount = _breedTranslations.length;

    for (final breedTranslations in _breedTranslations.values) {
      if (breedTranslations.containsKey(languageCode)) {
        translatedCount++;
      }
    }

    return {
      'locale': languageCode,
      'translatedCount': translatedCount,
      'totalCount': totalCount,
      'coverage': totalCount > 0 ? (translatedCount / totalCount) * 100 : 0.0,
    };
  }

  /// Add or update breed translations (for future extensibility)
  static void addBreedTranslation(
    String breedName,
    Map<String, String> translations,
  ) {
    // This would be used for dynamic breed translation updates
    // For now, we use static translations defined above
  }

  /// Get fallback breed name (English) for any breed
  static String getFallbackBreedName(String breedName) {
    final breedTranslations = _breedTranslations[breedName];
    return breedTranslations?['en'] ?? breedName;
  }

  /// Normalize breed name for lookup (handles case variations)
  static String normalizeBreedName(String breedName) {
    // Convert to title case for consistent lookup
    return breedName
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
