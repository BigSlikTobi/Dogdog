import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/utils/accessibility.dart';

void main() {
  group('AccessibilityUtils', () {
    testWidgets('should detect high contrast mode correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(highContrast: true),
            child: Builder(
              builder: (context) {
                expect(AccessibilityUtils.isHighContrastEnabled(context), true);
                return Container();
              },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(highContrast: false),
            child: Builder(
              builder: (context) {
                expect(
                  AccessibilityUtils.isHighContrastEnabled(context),
                  false,
                );
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should detect screen reader correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(accessibleNavigation: true),
            child: Builder(
              builder: (context) {
                expect(AccessibilityUtils.isScreenReaderEnabled(context), true);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should detect reduced motion preference', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                expect(AccessibilityUtils.prefersReducedMotion(context), true);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should respect text scaling with limits', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(3.0), // Very large scale
            ),
            child: Builder(
              builder: (context) {
                final scaleFactor = AccessibilityUtils.getTextScaleFactor(
                  context,
                );
                expect(
                  scaleFactor,
                  lessThanOrEqualTo(2.0),
                ); // Should be clamped
                expect(scaleFactor, greaterThanOrEqualTo(0.8));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should create proper button labels', (tester) async {
      final label = AccessibilityUtils.createButtonLabel(
        'Start Quiz',
        hint: 'Tap to begin the game',
        isEnabled: true,
      );
      expect(label, 'Start Quiz, Tap to begin the game');

      final disabledLabel = AccessibilityUtils.createButtonLabel(
        'Start Quiz',
        isEnabled: false,
      );
      expect(disabledLabel, 'Start Quiz, disabled');
    });

    testWidgets('should create proper game element labels', (tester) async {
      final label = AccessibilityUtils.createGameElementLabel(
        element: 'Score',
        value: '150',
        context: 'Current game score',
      );
      expect(label, 'Score: 150, Current game score');
    });

    testWidgets('should create proper progress labels', (tester) async {
      final label = AccessibilityUtils.createProgressLabel(
        type: 'Achievement Progress',
        current: 3,
        total: 5,
        additionalInfo: 'Chihuahua rank unlocked',
      );
      expect(label, 'Achievement Progress: 3 of 5, Chihuahua rank unlocked');
    });

    testWidgets('should provide high contrast colors when enabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(highContrast: true),
            child: Builder(
              builder: (context) {
                final colorScheme = AccessibilityUtils.getHighContrastColors(
                  context,
                );
                expect(colorScheme.primary, Colors.black);
                expect(colorScheme.onPrimary, Colors.white);
                expect(colorScheme.surface, Colors.white);
                expect(colorScheme.onSurface, Colors.black);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should provide accessible text styles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              highContrast: true,
              textScaler: TextScaler.linear(1.5),
            ),
            child: Builder(
              builder: (context) {
                final baseStyle = const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                );
                final accessibleStyle =
                    AccessibilityUtils.getAccessibleTextStyle(
                      context,
                      baseStyle,
                    );

                expect(accessibleStyle.fontSize, greaterThan(16)); // Scaled up
                expect(
                  accessibleStyle.fontWeight,
                  FontWeight.bold,
                ); // Bold for high contrast
                expect(
                  accessibleStyle.color,
                  Colors.black,
                ); // High contrast color
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should provide accessible card decoration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(highContrast: true),
            child: Builder(
              builder: (context) {
                final decoration =
                    AccessibilityUtils.getAccessibleCardDecoration(context);
                expect(
                  decoration.border,
                  isNotNull,
                ); // Should have border in high contrast
                expect(
                  decoration.boxShadow,
                  isNull,
                ); // No shadow in high contrast
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('AccessibilityTheme should apply high contrast theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(highContrast: true),
            child: AccessibilityTheme(
              child: Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  expect(theme.colorScheme.primary, Colors.black);
                  expect(theme.colorScheme.surface, Colors.white);
                  return Container();
                },
              ),
            ),
          ),
        ),
      );
    });

    testWidgets('GameElementSemantics should provide proper semantics', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameElementSemantics(
            label: 'Answer A',
            hint: 'Tap to select this answer',
            value: 'Golden Retriever',
            enabled: true,
            onTap: () {},
            child: SizedBox(
              key: const Key('answer-button'),
              width: 100,
              height: 50,
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(
        find.byKey(const Key('answer-button')),
      );
      expect(semantics.label, 'Answer A');
      expect(semantics.hint, 'Tap to select this answer');
      expect(semantics.value, 'Golden Retriever');
      expect(semantics.hasFlag(SemanticsFlag.hasEnabledState), true);
      expect(semantics.hasFlag(SemanticsFlag.isEnabled), true);
    });

    testWidgets('FocusableGameElement should handle keyboard navigation', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: FocusableGameElement(
            semanticLabel: 'Test Button',
            onTap: () => tapped = true,
            child: Container(
              key: const Key('focusable-element'),
              width: 100,
              height: 50,
              color: Colors.blue,
            ),
          ),
        ),
      );

      // Test tap functionality
      await tester.tap(find.byKey(const Key('focusable-element')));
      expect(tapped, true);

      // Test focus
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // The element should be focusable
      final focusableElement = tester.widget<FocusableGameElement>(
        find.byType(FocusableGameElement),
      );
      expect(focusableElement.semanticLabel, 'Test Button');
    });

    testWidgets('should announce to screen reader when enabled', (
      tester,
    ) async {
      final List<String> announcements = [];

      // Mock the SemanticsService.announce method
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter/semantics'),
        (call) async {
          if (call.method == 'announce') {
            announcements.add(call.arguments['message']);
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(accessibleNavigation: true),
            child: Builder(
              builder: (context) {
                AccessibilityUtils.announceToScreenReader(
                  context,
                  'Game started',
                );
                return Container();
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(announcements, contains('Game started'));
    });

    testWidgets('should create managed focus node with proper disposal', (
      tester,
    ) async {
      final focusNode = AccessibilityUtils.createManagedFocusNode();
      expect(focusNode.debugLabel, 'ManagedFocusNode');

      // Test that it can be disposed without errors
      focusNode.dispose();
    });
  });
}
