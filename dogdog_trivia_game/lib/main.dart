import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/error_recovery_screen.dart';
import 'screens/adopt_companion_screen.dart';
import 'services/progress_service.dart';
import 'services/audio_service.dart';
import 'services/error_service.dart';
import 'services/narrative_engine_service.dart';
import 'controllers/treasure_map_controller.dart';
import 'controllers/companion_controller.dart';
import 'widgets/error_boundary.dart';
import 'widgets/app_initializer.dart';
import 'widgets/companion_greeting_widget.dart';
import 'models/enums.dart';
import 'controllers/settings_controller.dart';
import 'l10n/generated/app_localizations.dart';
import 'dart:async';

/// Configure image cache with settings optimized for iPhone profile mode
void _configureImageCacheForIPhone() {
  final imageCache = PaintingBinding.instance.imageCache;

  // More aggressive caching for iPhone profile mode
  imageCache.maximumSize = 200; // Increased from default 100
  imageCache.maximumSizeBytes = 100 * 1024 * 1024; // 100MB cache

  debugPrint(
    'Image cache configured for iPhone: ${imageCache.maximumSize} items, ${imageCache.maximumSizeBytes ~/ (1024 * 1024)}MB',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure global image cache for iPhone optimization
  _configureImageCacheForIPhone();

  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    ErrorService().recordError(
      ErrorType.unknown,
      'Flutter framework error: ${details.exception}',
      severity: ErrorSeverity.high,
      stackTrace: details.stack,
      originalError: details.exception,
    );
  };

  // Handle errors outside of Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    // Check if this is an iOS memory protection error
    if (error.toString().contains('virtual_memory_posix') ||
        error.toString().contains('Unable to flip between RX and RW')) {
      ErrorService().handlePlatformError(
        error,
        stackTrace: stack,
        platform: 'iOS',
      );
    } else {
      ErrorService().recordError(
        ErrorType.unknown,
        'Platform error: $error',
        severity: ErrorSeverity.critical,
        stackTrace: stack,
        originalError: error,
      );
    }
    return true;
  };

  // Initialize services with error handling
  await _initializeApp();
}

Future<void> _initializeApp() async {
  try {
    // Initialize services
    final progressService = ProgressService();
    await progressService.initialize();

    final audioService = AudioService();
    await audioService.initialize();

    final companionController = CompanionController();
    await companionController.initialize();

    final narrativeEngine = NarrativeEngineService();
    await narrativeEngine.initialize();

    final settingsController = SettingsController();
    await settingsController.initialize();

    runApp(DogDogTriviaApp(
      progressService: progressService,
      companionController: companionController,
      narrativeEngine: narrativeEngine,
      settingsController: settingsController,
    ));
  } catch (error, stackTrace) {
    // Critical initialization error
    await ErrorService().recordError(
      ErrorType.unknown,
      'App initialization failed',
      severity: ErrorSeverity.critical,
      stackTrace: stackTrace,
      originalError: error,
    );

    // Run app with minimal functionality
    runApp(const DogDogTriviaAppFallback());
  }
}

class DogDogTriviaApp extends StatelessWidget {
  final ProgressService progressService;
  final CompanionController companionController;
  final NarrativeEngineService narrativeEngine;
  final SettingsController settingsController;

  const DogDogTriviaApp({
    super.key,
    required this.progressService,
    required this.companionController,
    required this.narrativeEngine,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProgressService>.value(value: progressService),
        ChangeNotifierProvider<CompanionController>.value(value: companionController),
        ChangeNotifierProvider<NarrativeEngineService>.value(value: narrativeEngine),
        ChangeNotifierProvider<SettingsController>.value(value: settingsController),
        ChangeNotifierProvider<TreasureMapController>(
          create: (_) => TreasureMapController(),
        ),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, _) {
          return MaterialApp(
            locale: settings.locale,
            title: 'DogDog Trivia',
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('de'), // German
              Locale('en'), // English (fallback)
            ],
        theme: ThemeData(
          // DogDog color scheme as defined in design document
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4A90E2), // Primary Blue
            primary: const Color(0xFF4A90E2),
            secondary: const Color(0xFF8B5CF6), // Secondary Purple
          ),
          useMaterial3: true,
          // Typography settings for child-friendly interface
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            bodyLarge: TextStyle(fontSize: 18, color: Color(0xFF1F2937)),
            bodyMedium: TextStyle(fontSize: 16, color: Color(0xFF1F2937)),
          ),
          // Button theme for large, child-friendly buttons
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        home: ErrorBoundary(
          onRetry: () {
            // Restart the app
            _initializeApp();
          },
          child: const AppInitializer(child: _CompanionAwareHome()),
        ),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

/// Fallback app when main initialization fails
class DogDogTriviaAppFallback extends StatelessWidget {
  const DogDogTriviaAppFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DogDog Trivia - Recovery Mode',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de'), // German
        Locale('en'), // English (fallback)
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A90E2)),
        useMaterial3: true,
      ),
      home: const ErrorRecoveryScreen(initialError: null),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Wrapper that shows adoption screen or home based on companion status
class _CompanionAwareHome extends StatefulWidget {
  const _CompanionAwareHome();

  @override
  State<_CompanionAwareHome> createState() => _CompanionAwareHomeState();
}

class _CompanionAwareHomeState extends State<_CompanionAwareHome> {
  bool _showGreeting = false;

  @override
  void initState() {
    super.initState();
    _checkGreeting();
  }

  void _checkGreeting() {
    final controller = Provider.of<CompanionController>(context, listen: false);
    if (controller.hasCompanion && controller.companion!.missedPlayer) {
      setState(() => _showGreeting = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanionController>(
      builder: (context, controller, _) {
        // Show adoption screen if no companion
        if (!controller.hasCompanion) {
          return AdoptCompanionScreen(
            onAdoptionComplete: () {
              // Refresh to show home
              setState(() {});
            },
          );
        }

        // Show greeting overlay if companion missed player
        if (_showGreeting) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF8F4FF),
                    const Color(0xFFE8E0F0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: CompanionGreetingWidget(
                  companion: controller.companion!,
                  onDismiss: () {
                    controller.recordInteraction();
                    setState(() => _showGreeting = false);
                  },
                ),
              ),
            ),
          );
        }

        // Normal home screen
        return const HomeScreen();
      },
    );
  }
}
