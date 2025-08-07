# Localization Testing Guide

This document explains how to properly test localized content in the DogDog Trivia Game.

## Problem Statement

Previously, tests were failing because they expected German translations (e.g., "Leicht", "Mittel", "Schwer") but the test environment was providing English translations (e.g., "Easy", "Medium", "Hard"). This occurred because tests didn't have proper localization setup, defaulting to system locale instead of a controlled test locale.

## Solution

We have implemented a comprehensive solution that includes:

1. **Explicit locale setting in test widgets**
2. **Standardized test helper for consistent localization setup**
3. **Updated test expectations to match actual translations**
4. **Clear documentation of the localization architecture**

## How Localization Works in the App

### 1. Model Structure
- **Achievement Model**: The `Achievement.fromRank()` factory constructor sets empty strings for `name` and `description` fields with the comment "Will be populated via localization"
- **Rank Extensions**: Localized display names and descriptions are provided via extension methods on the `Rank` enum (e.g., `rank.displayName(context)`, `rank.description(context)`)

### 2. Localization Files
- German translations: `lib/l10n/app_de.arb`
- English translations: `lib/l10n/app_en.arb`
- Spanish translations: `lib/l10n/app_es.arb`

### 3. Usage Pattern
In the actual app, achievements display localized content using:
```dart
// Display name via rank extension
Text(achievement.rank.displayName(context))

// Description via rank extension  
Text(achievement.rank.description(context))
```

NOT via the achievement's own name/description fields:
```dart
// WRONG - these are empty by design
Text(achievement.name)
Text(achievement.description)
```

## Testing Best Practices

### 1. Use the Localization Test Helper

```dart
import '../helpers/localization_test_helper.dart';

testWidgets('should display German text', (tester) async {
  await tester.pumpWidget(
    LocalizationTestHelper.createGermanTestWidget(
      child: Builder(
        builder: (context) {
          expect(Difficulty.easy.displayName(context), 'Leicht');
          return Container();
        },
      ),
    ),
  );
});
```

### 2. Test the Correct Pattern

When testing achievements, test the localization via the rank extensions, not the model fields:

```dart
// CORRECT - Test localization via rank extension
expect(achievement.rank.displayName(context), 'Mops');
expect(achievement.rank.description(context), 'Guter Fortschritt - 25 richtige Antworten erreicht!');

// WRONG - These fields are empty by design
expect(achievement.name, 'Mops'); // This will fail
expect(achievement.description, 'Guter Fortschritt...'); // This will fail
```

### 3. Verify Actual Translation Content

Always check the actual translation files to ensure test expectations match:

```bash
# Check German translations
grep -n "difficulty_easy" lib/l10n/app_de.arb
grep -n "rank_pug" lib/l10n/app_de.arb
```

### 4. Test Multiple Locales

Test critical functionality in multiple locales to ensure consistency:

```dart
testWidgets('should work in German', (tester) async {
  await tester.pumpWidget(LocalizationTestHelper.createGermanTestWidget(child: widget));
  // Test German expectations
});

testWidgets('should work in English', (tester) async {
  await tester.pumpWidget(LocalizationTestHelper.createEnglishTestWidget(child: widget));
  // Test English expectations
});
```

## Fixed Issues

### 1. Enum Tests (`test/models/enums_test.dart`)
- **Problem**: Tests expected German translations but got English
- **Solution**: Added `locale: const Locale('de')` to force German locale
- **Fix**: Updated test expectations to match actual German translations in ARB files

### 2. Achievement Tests (`test/models/achievement_test.dart`)  
- **Problem**: Tests expected achievement.name/description to contain localized text
- **Solution**: Updated tests to reflect the actual architecture where localization happens via rank extensions
- **Fix**: Test that `achievement.name` and `achievement.description` are empty (by design) and that localized text is available via `achievement.rank.displayName(context)`

### 3. Translation Mismatches
Fixed several cases where test expectations didn't match actual translations:
- `'Chew 50/50'` → `'Kau 50/50'`
- `'Zeigt einen Hinweis zur richtigen Antwort'` → `'Zeigt einen Hinweis für die richtige Antwort'`
- `'Treuer Begleiter - 75 richtige Antworten geschafft!'` → `'Treuer Begleiter - 75 richtige Antworten erreicht!'`
- `'Großer Meister'` → `'Großmeister'`

## Test Verification

All model tests now pass:
```bash
cd dogdog_trivia_game
flutter test test/models/
# ✓ All tests passed!
```

## Future Guidelines

1. **Always use LocalizationTestHelper** for tests that involve localized content
2. **Verify translations in ARB files** before writing test expectations
3. **Follow the established pattern** of using extension methods for localized display
4. **Test the architecture, not implementation details** - test how localization is actually used in the app
5. **Document any changes** to localization patterns in this guide

This approach ensures consistent, reliable localization testing that accurately reflects how the app actually works.
