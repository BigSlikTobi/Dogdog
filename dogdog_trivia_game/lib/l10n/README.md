# DogDog Trivia Game - Localization Guide

## Overview

The DogDog Trivia Game supports multiple languages using Flutter's official internationalization (i18n) framework. The app currently supports German, English, and Spanish, with English as the fallback language for unsupported locales.

## Supported Languages

- **German (de)** - Primary language with culturally appropriate dog breed names
- **English (en)** - Fallback language for unsupported locales  
- **Spanish (es)** - Full translation with appropriate terminology

## File Structure

```
lib/l10n/
├── app_en.arb          # English translations (fallback)
├── app_de.arb          # German translations
├── app_es.arb          # Spanish translations
├── generated/          # Auto-generated localization classes
│   ├── app_localizations.dart
│   ├── app_localizations_en.dart
│   ├── app_localizations_de.dart
│   └── app_localizations_es.dart
├── header.txt          # Header template for generated files
└── README.md           # This documentation
```

## Adding a New Language

### Step 1: Create ARB File

Create a new ARB file following the naming convention `app_[locale].arb`:

```bash
# Example for French
touch lib/l10n/app_fr.arb
```

### Step 2: Copy Base Structure

Copy the structure from `app_en.arb` and translate all strings:

```json
{
  "@@locale": "fr",
  "@@last_modified": "2025-02-08T12:00:00.000Z",
  
  "homeScreen_welcomeTitle": "Bienvenue à DogDog!",
  "@homeScreen_welcomeTitle": {
    "description": "Titre principal de bienvenue sur l'écran d'accueil"
  },
  
  // ... continue with all translations
}
```

### Step 3: Update Configuration

Add the new locale to the supported locales list in `main.dart`:

```dart
supportedLocales: const [
  Locale('de'), // German
  Locale('en'), // English (fallback)
  Locale('es'), // Spanish
  Locale('fr'), // French - NEW
],
```

### Step 4: Generate Localization Files

Run the code generation command:

```bash
flutter gen-l10n
```

### Step 5: Test the New Language

Create comprehensive tests for the new language in `test/localization/`:

```dart
// test/localization/french_locale_test.dart
testWidgets('French localization strings are loaded correctly', (WidgetTester tester) async {
  // Test implementation
});
```

## Naming Conventions

### String Keys

Use hierarchical naming with underscores:

```
{screen}_{component}_{variant?}
```

Examples:
- `homeScreen_welcomeTitle`
- `gameScreen_correctAnswer_celebration`
- `errors_network_retry`
- `common_button_cancel`

### ARB File Organization

Group strings by feature/screen:

1. **App-level strings**: `appTitle`, `appDescription`
2. **Screen-specific strings**: `homeScreen_*`, `gameScreen_*`
3. **Common strings**: `common_*` (buttons, labels)
4. **Error messages**: `errorScreen_*`
5. **Accessibility**: `accessibility_*`

### Comments and Descriptions

Always include descriptive comments for translators:

```json
{
  "gameScreen_questionCounter": "Frage {current} von {total}",
  "@gameScreen_questionCounter": {
    "description": "Shows current question number out of total",
    "placeholders": {
      "current": {
        "type": "int",
        "example": "5"
      },
      "total": {
        "type": "int", 
        "example": "10"
      }
    }
  }
}
```

## Translation Guidelines

### Age-Appropriate Language

- Use simple vocabulary suitable for ages 8-12
- Avoid complex grammatical structures
- Use encouraging, positive language
- Keep sentences short and clear

### Cultural Considerations

#### Dog Breed Names

Use culturally appropriate breed names:

| English | German | Spanish |
|---------|--------|---------|
| German Shepherd | Deutscher Schäferhund | Pastor Alemán |
| Great Dane | Deutsche Dogge | Gran Danés |
| Pug | Mops | Pug |

#### Tone and Style

- **German**: Formal but friendly ("Sie" vs "du" - use "du" for children)
- **English**: Casual and encouraging
- **Spanish**: Warm and enthusiastic with appropriate formality

### Parameter Placeholders

Use typed placeholders for dynamic content:

```json
{
  "gameScreen_level": "Level {level}",
  "@gameScreen_level": {
    "placeholders": {
      "level": {
        "type": "int",
        "example": "1"
      }
    }
  }
}
```

## Usage in Code

### Basic Usage

```dart
import '../l10n/generated/app_localizations.dart';

// In widget build method
Text(AppLocalizations.of(context)!.homeScreen_welcomeTitle)
```

### With Parameters

```dart
Text(AppLocalizations.of(context)!.gameScreen_questionCounter(3, 10))
// Renders: "Question 3 of 10" (English)
// Renders: "Frage 3 von 10" (German)
// Renders: "Pregunta 3 de 10" (Spanish)
```

### Safe Access Pattern

```dart
final l10n = AppLocalizations.of(context)!;
return Column(
  children: [
    Text(l10n.homeScreen_welcomeTitle),
    Text(l10n.homeScreen_welcomeSubtitle),
  ],
);
```

## Testing Localization

### Unit Tests

Test each language separately:

```dart
testWidgets('German strings display correctly', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('de'),
      home: MyWidget(),
    ),
  );
  
  expect(find.text('Willkommen bei DogDog!'), findsOneWidget);
});
```

### Parameter Testing

Verify placeholder substitution:

```dart
testWidgets('Parameter substitution works', (WidgetTester tester) async {
  // Test with different parameter values
  final l10n = AppLocalizations.of(context)!;
  expect(l10n.gameScreen_level(5), equals('Level 5'));
});
```

## Maintenance

### Adding New Strings

1. Add to `app_en.arb` first (base language)
2. Add translations to all other ARB files
3. Run `flutter gen-l10n` to regenerate classes
4. Update tests to include new strings
5. Test on all supported locales

### Updating Existing Strings

1. Update in all ARB files simultaneously
2. Update `@@last_modified` timestamp
3. Regenerate localization files
4. Update tests if string content changed
5. Test thoroughly on all locales

### Quality Assurance

- Use native speakers for translation review
- Test with actual device locale changes
- Verify text fits in UI layouts for all languages
- Check accessibility with screen readers
- Validate cultural appropriateness

## Troubleshooting

### Common Issues

1. **Missing translations**: Check all ARB files have the same keys
2. **Generation errors**: Verify JSON syntax in ARB files
3. **Runtime errors**: Ensure locale is properly configured in MaterialApp
4. **Layout issues**: Test with longer German/Spanish text

### Debug Commands

```bash
# Regenerate localization files
flutter gen-l10n

# Check for missing translations
flutter analyze

# Run localization tests
flutter test test/localization/

# Test specific locale
flutter run --locale de
```

## Performance Considerations

- Localization files are compiled at build time
- No runtime performance impact
- Generated classes use const constructors
- String interpolation is optimized by Flutter

## Future Enhancements

- Add more languages based on user demand
- Implement RTL language support if needed
- Add context-aware translations
- Consider pluralization rules for complex languages

## Resources

- [Flutter Internationalization Guide](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB File Format Specification](https://github.com/google/app-resource-bundle)
- [Intl Package Documentation](https://pub.dev/packages/intl)