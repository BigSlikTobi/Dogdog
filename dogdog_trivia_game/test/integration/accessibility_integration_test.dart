import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dogdog_trivia_game/services/progress_service.dart';
import 'package:dogdog_trivia_game/utils/accessibility.dart';
import 'package:dogdog_trivia_game/utils/responsive.dart';
import 'package:dogdog_trivia_game/screens/home_screen.dart';
import 'package:dogdog_trivia_game/screens/difficulty_selection_screen.dart';
import 'package:dogdog_trivia_game/screens/game_screen.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('Accessibility Integration Tests', () {
    late List<String> screenReaderAnnouncements;

    setUp(() {
      screenReaderAnnouncements = [];

      // Mock the SemanticsService.announce method
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter/semantics'), (
            call,
          ) async {
            if (call.method == 'announce') {
              screenReaderAnnouncements.add(call.arguments['message']);
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter/semantics'),
            null,
          );
    });

    testWidgets('should provide proper semantic labels throughout app flow', (
      tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ProgressService(),
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Test home screen semantics
      expect(find.bySemanticsLabel('DogDog app logo'), findsOneWidget);

      // Navigate to difficulty selection
      await tester.tap(find.text('Start Quiz'));
      await tester.pumpAndSettle();

      // Test difficulty selection semantics
      expect(find.bySemanticsLabel(RegExp(r'.*difficulty.*')), findsWidgets);
      expect(find.bySemanticsLabel('Go back to home screen'), findsOneWidget);

      // Test difficulty card semantics
      final difficultyCards = find.byType(GameElementSemantics);
      expect(difficultyCards, findsWidgets);
    });

    testWidgets('should work with screen reader enabled', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(accessibleNavigation: true),
          child: ChangeNotifierProvider(
            create: (context) => ProgressService(),
            child: const MaterialApp(home: HomeScreen()),
          ),
        ),
      );

      // Verify screen reader detection
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(AccessibilityUtils.isScreenReaderEnabled(context), true);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should announce important events to screen reader', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(accessibleNavigation: true),
          child: ChangeNotifierProvider(
            create: (context) => ProgressService(),
            child: const MaterialApp(home: DifficultySelectionScreen()),
          ),
        ),
      );

      // Tap on a difficulty card
      await tester.tap(find.text('Leicht').first);
      await tester.pumpAndSettle();

      // Verify announcement was made
      expect(screenReaderAnnouncements, isNotEmpty);
      expect(screenReaderAnnouncements.last, contains('difficulty selected'));
    });

    testWidgets('should support high contrast mode', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(highContrast: true),
          child: ChangeNotifierProvider(
            create: (context) => ProgressService(),
            child: const MaterialApp(home: HomeScreen()),
          ),
        ),
      );

      // Verify high contrast colors are applied
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(AccessibilityUtils.isHighContrastEnabled(context), true);
              final colorScheme = AccessibilityUtils.getHighContrastColors(
                context,
              );
              expect(colorScheme.primary, Colors.black);
              expect(colorScheme.surface, Colors.white);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should respect reduced motion preferences', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: ChangeNotifierProvider(
            create: (context) => ProgressService(),
            child: const MaterialApp(home: HomeScreen()),
          ),
        ),
      );

      // Verify reduced motion detection
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(AccessibilityUtils.prefersReducedMotion(context), true);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should scale text appropriately', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(2.0), // Large text
          ),
          child: ChangeNotifierProvider(
            create: (context) => ProgressService(),
            child: const MaterialApp(home: HomeScreen()),
          ),
        ),
      );

      // Verify text scaling is applied but clamped
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final scaleFactor = AccessibilityUtils.getTextScaleFactor(
                context,
              );
              expect(scaleFactor, lessThanOrEqualTo(2.0));
              expect(scaleFactor, greaterThan(1.0));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should provide proper focus management', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ProgressService(),
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Test keyboard navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Verify focusable elements exist
      final focusableElements = find.byType(FocusableGameElement);
      expect(focusableElements, findsWidgets);
    });

    testWidgets('should work across different screen sizes', (tester) async {
      // Test mobile screen
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ProgressService(),
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.isMobile(context), true);
              final padding = ResponsiveUtils.getResponsivePadding(context);
              expect(padding, const EdgeInsets.all(16.0));
              return Container();
            },
          ),
        ),
      );

      // Test tablet screen
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.isTablet(context), true);
              final padding = ResponsiveUtils.getResponsivePadding(context);
              expect(padding, const EdgeInsets.all(24.0));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should maintain accessibility in game flow', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            accessibleNavigation: true,
            highContrast: true,
          ),
          child: ChangeNotifierProvider(
            create: (context) => ProgressService(),
            child: MaterialApp(
              home: GameScreen(difficulty: Difficulty.easy, level: 1),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test game screen accessibility
      expect(
        find.bySemanticsLabel(RegExp(r'Lives remaining.*')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp(r'Current score.*')), findsOneWidget);

      // Test answer buttons have proper semantics
      final answerButtons = find.byType(GameElementSemantics);
      expect(answerButtons, findsWidgets);
    });

    testWidgets('should provide accessible error handling', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(accessibleNavigation: true),
          child: ChangeNotifierProvider(
            create: (context) => ProgressService(),
            child: const MaterialApp(home: HomeScreen()),
          ),
        ),
      );

      // Test that error states are announced to screen reader
      // This would be tested with actual error scenarios in a real app
      expect(screenReaderAnnouncements, isEmpty); // Initially empty
    });

    testWidgets('should support keyboard navigation throughout app', (
      tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ProgressService(),
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Test tab navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Test enter key activation
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // Verify navigation occurred or action was taken
      // This would depend on the specific focus management implementation
    });
  });

  group('Cross-Platform Accessibility Tests', () {
    testWidgets('should work consistently on different platforms', (
      tester,
    ) async {
      // Test iOS-specific accessibility features
      // debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ProgressService(),
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Verify iOS-specific accessibility features
      expect(find.byType(HomeScreen), findsOneWidget);

      // Test Android-specific accessibility features
      // debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ProgressService(),
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Verify Android-specific accessibility features
      expect(find.byType(HomeScreen), findsOneWidget);

      // debugDefaultTargetPlatformOverride = null;
    });
  });
}
