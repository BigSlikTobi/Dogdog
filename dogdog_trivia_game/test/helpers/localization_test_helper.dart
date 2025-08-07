import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dogdog_trivia_game/l10n/generated/app_localizations.dart';

/// Helper class for creating consistent localization setup in tests
class LocalizationTestHelper {
  /// Creates a test widget with German locale (for testing German translations)
  static Widget createGermanTestWidget({required Widget child}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
      locale: const Locale('de'), // Force German locale for tests
      home: child,
    );
  }

  /// Creates a test widget with English locale (for testing English translations)
  static Widget createEnglishTestWidget({required Widget child}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
      locale: const Locale('en'), // Force English locale for tests
      home: child,
    );
  }

  /// Creates a test widget with Spanish locale (for testing Spanish translations)
  static Widget createSpanishTestWidget({required Widget child}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
      locale: const Locale('es'), // Force Spanish locale for tests
      home: child,
    );
  }

  /// Creates a test widget with custom locale
  static Widget createTestWidgetWithLocale({
    required Widget child,
    required Locale locale,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
      locale: locale,
      home: child,
    );
  }
}
