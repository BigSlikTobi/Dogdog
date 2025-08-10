import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/services/breed_localization_service.dart';

void main() {
  group('BreedLocalizationService', () {
    group('getLocalizedBreedName', () {
      test('should return German breed names for German locale', () {
        const locale = Locale('de');

        expect(
          BreedLocalizationService.getLocalizedBreedName(
            'German Shepherd Dog',
            locale,
          ),
          equals('Deutscher Schäferhund'),
        );

        expect(
          BreedLocalizationService.getLocalizedBreedName('Great Dane', locale),
          equals('Deutsche Dogge'),
        );

        expect(
          BreedLocalizationService.getLocalizedBreedName('Pomeranian', locale),
          equals('Zwergspitz'),
        );

        expect(
          BreedLocalizationService.getLocalizedBreedName(
            'Doberman Pinscher',
            locale,
          ),
          equals('Dobermann'),
        );
      });

      test('should return Spanish breed names for Spanish locale', () {
        const locale = Locale('es');

        expect(
          BreedLocalizationService.getLocalizedBreedName(
            'German Shepherd Dog',
            locale,
          ),
          equals('Pastor Alemán'),
        );

        expect(
          BreedLocalizationService.getLocalizedBreedName('Great Dane', locale),
          equals('Gran Danés'),
        );

        expect(
          BreedLocalizationService.getLocalizedBreedName('Pomeranian', locale),
          equals('Pomerania'),
        );

        expect(
          BreedLocalizationService.getLocalizedBreedName(
            'French Bulldog',
            locale,
          ),
          equals('Bulldog Francés'),
        );
      });

      test('should return English breed names for English locale', () {
        const locale = Locale('en');

        expect(
          BreedLocalizationService.getLocalizedBreedName(
            'German Shepherd Dog',
            locale,
          ),
          equals('German Shepherd Dog'),
        );

        expect(
          BreedLocalizationService.getLocalizedBreedName(
            'Golden Retriever',
            locale,
          ),
          equals('Golden Retriever'),
        );

        expect(
          BreedLocalizationService.getLocalizedBreedName(
            'French Bulldog',
            locale,
          ),
          equals('French Bulldog'),
        );
      });

      test('should fallback to English when translation not available', () {
        const locale = Locale('de');

        expect(
          BreedLocalizationService.getLocalizedBreedName(
            'Unknown Breed',
            locale,
          ),
          equals('Unknown Breed'),
        );
      });

      test('should fallback to original name when no English translation', () {
        const locale = Locale('fr'); // Unsupported language

        expect(
          BreedLocalizationService.getLocalizedBreedName(
            'German Shepherd Dog',
            locale,
          ),
          equals('German Shepherd Dog'), // Falls back to English
        );

        expect(
          BreedLocalizationService.getLocalizedBreedName(
            'Unknown Breed',
            locale,
          ),
          equals('Unknown Breed'), // Returns original when no translations
        );
      });
    });

    group('getAllLocalizedBreedNames', () {
      test('should return all breed names in German', () {
        const locale = Locale('de');
        final breedNames = BreedLocalizationService.getAllLocalizedBreedNames(
          locale,
        );

        expect(breedNames, isNotEmpty);
        expect(breedNames, contains('Deutscher Schäferhund'));
        expect(breedNames, contains('Deutsche Dogge'));
        expect(breedNames, contains('Zwergspitz'));
        expect(breedNames, contains('Golden Retriever')); // Same in German
      });

      test('should return all breed names in Spanish', () {
        const locale = Locale('es');
        final breedNames = BreedLocalizationService.getAllLocalizedBreedNames(
          locale,
        );

        expect(breedNames, isNotEmpty);
        expect(breedNames, contains('Pastor Alemán'));
        expect(breedNames, contains('Gran Danés'));
        expect(breedNames, contains('Pomerania'));
        expect(breedNames, contains('Golden Retriever')); // Same in Spanish
      });

      test('should return all breed names in English', () {
        const locale = Locale('en');
        final breedNames = BreedLocalizationService.getAllLocalizedBreedNames(
          locale,
        );

        expect(breedNames, isNotEmpty);
        expect(breedNames, contains('German Shepherd Dog'));
        expect(breedNames, contains('Great Dane'));
        expect(breedNames, contains('Pomeranian'));
        expect(breedNames, contains('Golden Retriever'));
      });
    });

    group('hasTranslation', () {
      test('should return true for breeds with German translations', () {
        const locale = Locale('de');

        expect(
          BreedLocalizationService.hasTranslation(
            'German Shepherd Dog',
            locale,
          ),
          isTrue,
        );
        expect(
          BreedLocalizationService.hasTranslation('Great Dane', locale),
          isTrue,
        );
        expect(
          BreedLocalizationService.hasTranslation('Golden Retriever', locale),
          isTrue,
        );
      });

      test('should return true for breeds with Spanish translations', () {
        const locale = Locale('es');

        expect(
          BreedLocalizationService.hasTranslation(
            'German Shepherd Dog',
            locale,
          ),
          isTrue,
        );
        expect(
          BreedLocalizationService.hasTranslation('French Bulldog', locale),
          isTrue,
        );
        expect(
          BreedLocalizationService.hasTranslation('Poodle', locale),
          isTrue,
        );
      });

      test('should return false for breeds without translations', () {
        const locale = Locale('de');

        expect(
          BreedLocalizationService.hasTranslation('Unknown Breed', locale),
          isFalse,
        );
      });

      test('should return false for unsupported languages', () {
        const locale = Locale('fr');

        expect(
          BreedLocalizationService.hasTranslation(
            'German Shepherd Dog',
            locale,
          ),
          isFalse,
        );
      });
    });

    group('getSupportedLanguages', () {
      test('should return all supported language codes', () {
        final languages = BreedLocalizationService.getSupportedLanguages();

        expect(languages, hasLength(3));
        expect(languages, contains('en'));
        expect(languages, contains('de'));
        expect(languages, contains('es'));
      });
    });

    group('getTranslatedBreedCount', () {
      test('should return the total number of translated breeds', () {
        final count = BreedLocalizationService.getTranslatedBreedCount();

        expect(count, greaterThan(0));
        expect(count, isA<int>());
      });
    });

    group('getTranslationStats', () {
      test('should return translation statistics for German', () {
        const locale = Locale('de');
        final stats = BreedLocalizationService.getTranslationStats(locale);

        expect(stats['locale'], equals('de'));
        expect(stats['translatedCount'], isA<int>());
        expect(stats['totalCount'], isA<int>());
        expect(stats['coverage'], isA<double>());
        expect(
          stats['translatedCount'],
          lessThanOrEqualTo(stats['totalCount']),
        );
        expect(stats['coverage'], greaterThanOrEqualTo(0.0));
        expect(stats['coverage'], lessThanOrEqualTo(100.0));
      });

      test('should return translation statistics for Spanish', () {
        const locale = Locale('es');
        final stats = BreedLocalizationService.getTranslationStats(locale);

        expect(stats['locale'], equals('es'));
        expect(stats['translatedCount'], isA<int>());
        expect(stats['totalCount'], isA<int>());
        expect(stats['coverage'], isA<double>());
        expect(
          stats['translatedCount'],
          lessThanOrEqualTo(stats['totalCount']),
        );
        expect(stats['coverage'], greaterThanOrEqualTo(0.0));
        expect(stats['coverage'], lessThanOrEqualTo(100.0));
      });

      test('should return translation statistics for English', () {
        const locale = Locale('en');
        final stats = BreedLocalizationService.getTranslationStats(locale);

        expect(stats['locale'], equals('en'));
        expect(
          stats['translatedCount'],
          equals(stats['totalCount']),
        ); // English should be 100%
        expect(stats['coverage'], equals(100.0));
      });

      test('should return zero coverage for unsupported language', () {
        const locale = Locale('fr');
        final stats = BreedLocalizationService.getTranslationStats(locale);

        expect(stats['locale'], equals('fr'));
        expect(stats['translatedCount'], equals(0));
        expect(stats['coverage'], equals(0.0));
      });
    });

    group('getFallbackBreedName', () {
      test('should return English name for translated breeds', () {
        expect(
          BreedLocalizationService.getFallbackBreedName('German Shepherd Dog'),
          equals('German Shepherd Dog'),
        );

        expect(
          BreedLocalizationService.getFallbackBreedName('Great Dane'),
          equals('Great Dane'),
        );

        expect(
          BreedLocalizationService.getFallbackBreedName('French Bulldog'),
          equals('French Bulldog'),
        );
      });

      test('should return original name for untranslated breeds', () {
        expect(
          BreedLocalizationService.getFallbackBreedName('Unknown Breed'),
          equals('Unknown Breed'),
        );
      });
    });

    group('normalizeBreedName', () {
      test('should normalize breed names to title case', () {
        expect(
          BreedLocalizationService.normalizeBreedName('german shepherd dog'),
          equals('German Shepherd Dog'),
        );

        expect(
          BreedLocalizationService.normalizeBreedName('GREAT DANE'),
          equals('Great Dane'),
        );

        expect(
          BreedLocalizationService.normalizeBreedName('french bulldog'),
          equals('French Bulldog'),
        );

        expect(
          BreedLocalizationService.normalizeBreedName('Golden retriever'),
          equals('Golden Retriever'),
        );
      });

      test('should handle empty strings', () {
        expect(BreedLocalizationService.normalizeBreedName(''), equals(''));
      });

      test('should handle single words', () {
        expect(
          BreedLocalizationService.normalizeBreedName('poodle'),
          equals('Poodle'),
        );

        expect(
          BreedLocalizationService.normalizeBreedName('BEAGLE'),
          equals('Beagle'),
        );
      });

      test('should handle multiple spaces', () {
        expect(
          BreedLocalizationService.normalizeBreedName('german  shepherd  dog'),
          equals('German  Shepherd  Dog'),
        );
      });
    });

    group('Edge Cases', () {
      test('should handle empty breed names', () {
        const locale = Locale('de');

        expect(
          BreedLocalizationService.getLocalizedBreedName('', locale),
          equals(''),
        );

        expect(BreedLocalizationService.hasTranslation('', locale), isFalse);
      });

      test('should handle whitespace-only breed names', () {
        const locale = Locale('de');

        expect(
          BreedLocalizationService.getLocalizedBreedName('   ', locale),
          equals('   '),
        );

        expect(BreedLocalizationService.hasTranslation('   ', locale), isFalse);
      });

      test('should handle case variations in breed names', () {
        const locale = Locale('de');

        // Test case insensitive matching
        expect(
          BreedLocalizationService.getLocalizedBreedName(
            'german shepherd dog',
            locale,
          ),
          equals('german shepherd dog'), // Returns original when no exact match
        );
      });
    });

    group('Integration with Supported Languages', () {
      test('should have consistent language support across methods', () {
        final supportedLanguages =
            BreedLocalizationService.getSupportedLanguages();

        for (final languageCode in supportedLanguages) {
          final locale = Locale(languageCode);

          // Should be able to get translation stats for all supported languages
          final stats = BreedLocalizationService.getTranslationStats(locale);
          expect(stats['locale'], equals(languageCode));

          // Should be able to get all localized breed names
          final breedNames = BreedLocalizationService.getAllLocalizedBreedNames(
            locale,
          );
          expect(breedNames, isNotEmpty);

          // Should have at least some translations (English should have 100%)
          expect(stats['coverage'], greaterThan(0.0));
        }
      });
    });
  });
}
