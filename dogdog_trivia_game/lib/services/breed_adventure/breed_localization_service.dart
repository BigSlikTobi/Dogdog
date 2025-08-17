import 'package:flutter/material.dart';

/// Service for handling breed name localization and fallback logic
class BreedLocalizationService {
  static const Map<String, Map<String, String>> _breedTranslations = {
    // Popular breeds with full translations
    'German Shepherd Dog': {
      'en': 'German Shepherd Dog',
      'de': 'Deutscher Schäferhund',
      'es': 'Pastor Alemán',
    },
    'Golden Retriever': {
      'en': 'Golden Retriever',
      'de': 'Golden Retriever',
      'es': 'Golden Retriever',
    },
    'Labrador Retriever': {
      'en': 'Labrador Retriever',
      'de': 'Labrador Retriever',
      'es': 'Labrador Retriever',
    },
    'French Bulldog': {
      'en': 'French Bulldog',
      'de': 'Französische Bulldogge',
      'es': 'Bulldog Francés',
    },
    'Bulldog': {'en': 'Bulldog', 'de': 'Bulldogge', 'es': 'Bulldog'},
    'Poodle': {'en': 'Poodle', 'de': 'Pudel', 'es': 'Caniche'},
    'Beagle': {'en': 'Beagle', 'de': 'Beagle', 'es': 'Beagle'},
    'Rottweiler': {'en': 'Rottweiler', 'de': 'Rottweiler', 'es': 'Rottweiler'},
    'Yorkshire Terrier': {
      'en': 'Yorkshire Terrier',
      'de': 'Yorkshire Terrier',
      'es': 'Yorkshire Terrier',
    },
    'Dachshund': {'en': 'Dachshund', 'de': 'Dackel', 'es': 'Teckel'},
    'Siberian Husky': {
      'en': 'Siberian Husky',
      'de': 'Sibirischer Husky',
      'es': 'Husky Siberiano',
    },
    'Great Dane': {
      'en': 'Great Dane',
      'de': 'Deutsche Dogge',
      'es': 'Gran Danés',
    },
    'Chihuahua': {'en': 'Chihuahua', 'de': 'Chihuahua', 'es': 'Chihuahua'},
    'Boxer': {'en': 'Boxer', 'de': 'Boxer', 'es': 'Bóxer'},
    'Border Collie': {
      'en': 'Border Collie',
      'de': 'Border Collie',
      'es': 'Border Collie',
    },
    'Australian Shepherd': {
      'en': 'Australian Shepherd',
      'de': 'Australian Shepherd',
      'es': 'Pastor Australiano',
    },
    'Cocker Spaniel': {
      'en': 'Cocker Spaniel',
      'de': 'Cocker Spaniel',
      'es': 'Cocker Spaniel',
    },
    'Pug': {'en': 'Pug', 'de': 'Mops', 'es': 'Pug'},
    'Boston Terrier': {
      'en': 'Boston Terrier',
      'de': 'Boston Terrier',
      'es': 'Boston Terrier',
    },
    'Shih Tzu': {'en': 'Shih Tzu', 'de': 'Shih Tzu', 'es': 'Shih Tzu'},
    'Doberman Pinscher': {
      'en': 'Doberman Pinscher',
      'de': 'Dobermann',
      'es': 'Doberman',
    },
    'Mastiff': {'en': 'Mastiff', 'de': 'Mastiff', 'es': 'Mastín'},
    'Saint Bernard': {
      'en': 'Saint Bernard',
      'de': 'Bernhardiner',
      'es': 'San Bernardo',
    },
    'Newfoundland': {
      'en': 'Newfoundland',
      'de': 'Neufundländer',
      'es': 'Terranova',
    },
    'Bernese Mountain Dog': {
      'en': 'Bernese Mountain Dog',
      'de': 'Berner Sennenhund',
      'es': 'Boyero de Berna',
    },
    'Akita': {'en': 'Akita', 'de': 'Akita', 'es': 'Akita'},
    'Shiba Inu': {'en': 'Shiba Inu', 'de': 'Shiba Inu', 'es': 'Shiba Inu'},
    'Weimaraner': {'en': 'Weimaraner', 'de': 'Weimaraner', 'es': 'Weimaraner'},
    'Dalmatian': {'en': 'Dalmatian', 'de': 'Dalmatiner', 'es': 'Dálmata'},
    'Jack Russell Terrier': {
      'en': 'Jack Russell Terrier',
      'de': 'Jack Russell Terrier',
      'es': 'Jack Russell Terrier',
    },
    'Cavalier King Charles Spaniel': {
      'en': 'Cavalier King Charles Spaniel',
      'de': 'Cavalier King Charles Spaniel',
      'es': 'Cavalier King Charles Spaniel',
    },
    'Bichon Frise': {
      'en': 'Bichon Frise',
      'de': 'Bichon Frisé',
      'es': 'Bichón Frisé',
    },
    'Maltese': {'en': 'Maltese', 'de': 'Malteser', 'es': 'Maltés'},
    'Papillon': {'en': 'Papillon', 'de': 'Papillon', 'es': 'Papillón'},
    'Pomeranian': {'en': 'Pomeranian', 'de': 'Zwergspitz', 'es': 'Pomerania'},
    'Afghan Hound': {
      'en': 'Afghan Hound',
      'de': 'Afghanischer Windhund',
      'es': 'Lebrel Afgano',
    },
    'Greyhound': {'en': 'Greyhound', 'de': 'Greyhound', 'es': 'Galgo'},
    'Whippet': {'en': 'Whippet', 'de': 'Whippet', 'es': 'Whippet'},
    'Basenji': {'en': 'Basenji', 'de': 'Basenji', 'es': 'Basenji'},
    'Bloodhound': {'en': 'Bloodhound', 'de': 'Bloodhound', 'es': 'Sabueso'},
    'Basset Hound': {
      'en': 'Basset Hound',
      'de': 'Basset Hound',
      'es': 'Basset Hound',
    },
    'Irish Setter': {
      'en': 'Irish Setter',
      'de': 'Irish Setter',
      'es': 'Setter Irlandés',
    },
    'English Setter': {
      'en': 'English Setter',
      'de': 'English Setter',
      'es': 'Setter Inglés',
    },
    'Pointer': {'en': 'Pointer', 'de': 'Pointer', 'es': 'Pointer'},
    'Vizsla': {'en': 'Vizsla', 'de': 'Vizsla', 'es': 'Vizsla'},
    'Brittany': {'en': 'Brittany', 'de': 'Bretone', 'es': 'Bretón'},
    'Springer Spaniel': {
      'en': 'Springer Spaniel',
      'de': 'Springer Spaniel',
      'es': 'Springer Spaniel',
    },
    'Welsh Corgi': {
      'en': 'Welsh Corgi',
      'de': 'Welsh Corgi',
      'es': 'Corgi Galés',
    },
    'Australian Cattle Dog': {
      'en': 'Australian Cattle Dog',
      'de': 'Australian Cattle Dog',
      'es': 'Boyero Australiano',
    },
    'Belgian Malinois': {
      'en': 'Belgian Malinois',
      'de': 'Belgischer Schäferhund',
      'es': 'Pastor Belga Malinois',
    },
    'Collie': {'en': 'Collie', 'de': 'Collie', 'es': 'Collie'},
    'Old English Sheepdog': {
      'en': 'Old English Sheepdog',
      'de': 'Bobtail',
      'es': 'Pastor Inglés Antiguo',
    },
    'Samoyed': {'en': 'Samoyed', 'de': 'Samojede', 'es': 'Samoyedo'},
    'Alaskan Malamute': {
      'en': 'Alaskan Malamute',
      'de': 'Alaskan Malamute',
      'es': 'Malamute de Alaska',
    },
    'Chow Chow': {'en': 'Chow Chow', 'de': 'Chow Chow', 'es': 'Chow Chow'},
    'Shar Pei': {'en': 'Shar Pei', 'de': 'Shar Pei', 'es': 'Shar Pei'},
    'Lhasa Apso': {'en': 'Lhasa Apso', 'de': 'Lhasa Apso', 'es': 'Lhasa Apso'},
    'Tibetan Terrier': {
      'en': 'Tibetan Terrier',
      'de': 'Tibet Terrier',
      'es': 'Terrier Tibetano',
    },
    'Bull Terrier': {
      'en': 'Bull Terrier',
      'de': 'Bull Terrier',
      'es': 'Bull Terrier',
    },
    'Staffordshire Terrier': {
      'en': 'Staffordshire Terrier',
      'de': 'Staffordshire Terrier',
      'es': 'Staffordshire Terrier',
    },
    'Scottish Terrier': {
      'en': 'Scottish Terrier',
      'de': 'Scottish Terrier',
      'es': 'Terrier Escocés',
    },
    'West Highland Terrier': {
      'en': 'West Highland Terrier',
      'de': 'West Highland White Terrier',
      'es': 'West Highland White Terrier',
    },
    'Cairn Terrier': {
      'en': 'Cairn Terrier',
      'de': 'Cairn Terrier',
      'es': 'Cairn Terrier',
    },
    'Fox Terrier': {
      'en': 'Fox Terrier',
      'de': 'Fox Terrier',
      'es': 'Fox Terrier',
    },
    'Airedale Terrier': {
      'en': 'Airedale Terrier',
      'de': 'Airedale Terrier',
      'es': 'Airedale Terrier',
    },
    'Wire Fox Terrier': {
      'en': 'Wire Fox Terrier',
      'de': 'Drahthaar Fox Terrier',
      'es': 'Fox Terrier de Pelo Duro',
    },
    'Smooth Fox Terrier': {
      'en': 'Smooth Fox Terrier',
      'de': 'Glatthaar Fox Terrier',
      'es': 'Fox Terrier de Pelo Liso',
    },
    'Miniature Schnauzer': {
      'en': 'Miniature Schnauzer',
      'de': 'Zwergschnauzer',
      'es': 'Schnauzer Miniatura',
    },
    'Standard Schnauzer': {
      'en': 'Standard Schnauzer',
      'de': 'Mittelschnauzer',
      'es': 'Schnauzer Estándar',
    },
    'Giant Schnauzer': {
      'en': 'Giant Schnauzer',
      'de': 'Riesenschnauzer',
      'es': 'Schnauzer Gigante',
    },
    'Portuguese Water Dog': {
      'en': 'Portuguese Water Dog',
      'de': 'Portugiesischer Wasserhund',
      'es': 'Perro de Agua Portugués',
    },
    'Spanish Water Dog': {
      'en': 'Spanish Water Dog',
      'de': 'Spanischer Wasserhund',
      'es': 'Perro de Agua Español',
    },
    'Irish Water Spaniel': {
      'en': 'Irish Water Spaniel',
      'de': 'Irish Water Spaniel',
      'es': 'Spaniel de Agua Irlandés',
    },
    'Chesapeake Bay Retriever': {
      'en': 'Chesapeake Bay Retriever',
      'de': 'Chesapeake Bay Retriever',
      'es': 'Retriever de la Bahía de Chesapeake',
    },
    'Flat-Coated Retriever': {
      'en': 'Flat-Coated Retriever',
      'de': 'Flat Coated Retriever',
      'es': 'Retriever de Pelo Liso',
    },
    'Nova Scotia Duck Tolling Retriever': {
      'en': 'Nova Scotia Duck Tolling Retriever',
      'de': 'Nova Scotia Duck Tolling Retriever',
      'es': 'Retriever de Nueva Escocia',
    },
    'Curly-Coated Retriever': {
      'en': 'Curly-Coated Retriever',
      'de': 'Curly Coated Retriever',
      'es': 'Retriever de Pelo Rizado',
    },
  };

  /// Gets the localized breed name for the current locale
  /// Falls back to English if translation is not available
  static String getLocalizedBreedName(BuildContext context, String breedName) {
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;

    // Check if we have translations for this breed
    if (_breedTranslations.containsKey(breedName)) {
      final translations = _breedTranslations[breedName]!;

      // Return localized version if available, otherwise fall back to English
      return translations[languageCode] ?? translations['en'] ?? breedName;
    }

    // If no translations available, return original name
    return breedName;
  }

  /// Gets all available breed names in the specified language
  static List<String> getAllBreedNames(String languageCode) {
    return _breedTranslations.values
        .map(
          (translations) => translations[languageCode] ?? translations['en']!,
        )
        .toList();
  }

  /// Checks if a breed has translations available
  static bool hasTranslations(String breedName) {
    return _breedTranslations.containsKey(breedName);
  }

  /// Gets all supported language codes for breed translations
  static List<String> getSupportedLanguages() {
    return ['en', 'de', 'es'];
  }

  /// Gets the breed name in English (useful for API calls)
  static String getEnglishBreedName(String localizedName) {
    // Find the breed by checking all translations
    for (final entry in _breedTranslations.entries) {
      final englishName = entry.key;
      final translations = entry.value;

      if (translations.values.contains(localizedName)) {
        return englishName;
      }
    }

    // If not found in translations, assume it's already in English
    return localizedName;
  }

  /// Gets translation statistics for debugging
  static Map<String, int> getTranslationStats() {
    final stats = <String, int>{};

    for (final languageCode in getSupportedLanguages()) {
      stats[languageCode] = _breedTranslations.values
          .where((translations) => translations.containsKey(languageCode))
          .length;
    }

    return stats;
  }

  /// Validates that all breeds have required translations
  static List<String> validateTranslations() {
    final missingTranslations = <String>[];

    for (final entry in _breedTranslations.entries) {
      final breedName = entry.key;
      final translations = entry.value;

      for (final languageCode in getSupportedLanguages()) {
        if (!translations.containsKey(languageCode)) {
          missingTranslations.add(
            '$breedName missing $languageCode translation',
          );
        }
      }
    }

    return missingTranslations;
  }

  /// Gets fallback logic explanation for debugging
  static String getFallbackExplanation(BuildContext context, String breedName) {
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;

    if (!_breedTranslations.containsKey(breedName)) {
      return 'No translations available for "$breedName", using original name';
    }

    final translations = _breedTranslations[breedName]!;

    if (translations.containsKey(languageCode)) {
      return 'Using $languageCode translation: "${translations[languageCode]}"';
    } else if (translations.containsKey('en')) {
      return 'Falling back to English: "${translations['en']}" (no $languageCode translation)';
    } else {
      return 'Using original name: "$breedName" (no translations available)';
    }
  }
}
