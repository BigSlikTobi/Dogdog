import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dogdog_trivia_game/l10n/generated/app_localizations.dart';
import 'package:dogdog_trivia_game/services/progress_service.dart';

/// Helper class for creating test widgets with proper localization and provider setup
class TestHelper {
  /// Creates a MaterialApp wrapper with proper localization for testing
  static Widget createTestApp(
    Widget child, {
    List<ChangeNotifierProvider>? providers,
  }) {
    Widget app = MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
      home: child,
    );

    if (providers != null && providers.isNotEmpty) {
      app = MultiProvider(providers: providers, child: app);
    }

    return app;
  }

  /// Creates a MaterialApp wrapper with ProgressService provider for testing
  static Widget createTestAppWithProgressService(
    Widget child, {
    ProgressService? progressService,
  }) {
    final service = progressService ?? ProgressService();

    return createTestApp(
      child,
      providers: [
        ChangeNotifierProvider<ProgressService>.value(value: service),
      ],
    );
  }

  /// Creates a basic MaterialApp wrapper for simple widget tests
  static Widget createBasicTestApp(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
      home: Scaffold(body: child),
    );
  }
}
