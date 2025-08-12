import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/widgets/accessible_category_selection.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Test suite for AccessibleCategorySelection widget - Task 15 accessibility enhancements
void main() {
  group('AccessibleCategorySelection Widget Tests', () {
    testWidgets('renders accessible category selection with proper semantics', (
      WidgetTester tester,
    ) async {
      QuestionCategory? selectedCategory;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
          home: Scaffold(
            body: AccessibleCategorySelection(
              selectedCategory: selectedCategory,
              onCategorySelected: (category) {
                selectedCategory = category;
              },
              isMobile: false,
            ),
          ),
        ),
      );

      // Verify main container has proper semantic labels
      expect(find.byType(Semantics), findsWidgets);

      // Verify all category buttons are present
      expect(find.text('Dog Training'), findsOneWidget);
      expect(find.text('Dog Breeds'), findsOneWidget);
      expect(find.text('Dog Behavior'), findsOneWidget);
      expect(find.text('Dog Health'), findsOneWidget);
      expect(find.text('Dog History'), findsOneWidget);

      // Verify accessible button structure
      expect(find.byType(AccessibleCategorySelection), findsOneWidget);
    });

    testWidgets('supports keyboard navigation between categories', (
      WidgetTester tester,
    ) async {
      QuestionCategory? selectedCategory;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: AccessibleCategorySelection(
              selectedCategory: selectedCategory,
              onCategorySelected: (category) {
                selectedCategory = category;
              },
              isMobile: false,
            ),
          ),
        ),
      );

      // Find the focus node and request focus
      final focusNode = tester
          .widget<Focus>(find.byType(Focus).first)
          .focusNode;
      focusNode?.requestFocus();
      await tester.pump();

      // Test arrow key navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      // Test selection with Enter key
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(selectedCategory, isNotNull);
    });

    testWidgets('responds to space bar selection', (WidgetTester tester) async {
      QuestionCategory? selectedCategory;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: AccessibleCategorySelection(
              selectedCategory: selectedCategory,
              onCategorySelected: (category) {
                selectedCategory = category;
              },
              isMobile: false,
            ),
          ),
        ),
      );

      // Find and focus the first category
      final focusNode = tester
          .widget<Focus>(find.byType(Focus).first)
          .focusNode;
      focusNode?.requestFocus();
      await tester.pump();

      // Select with space bar
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(selectedCategory, equals(QuestionCategory.dogTraining));
    });

    testWidgets('handles tap selection correctly', (WidgetTester tester) async {
      QuestionCategory? selectedCategory;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: AccessibleCategorySelection(
              selectedCategory: selectedCategory,
              onCategorySelected: (category) {
                selectedCategory = category;
              },
              isMobile: false,
            ),
          ),
        ),
      );

      // Tap on Dog Breeds category
      await tester.tap(find.text('Dog Breeds'));
      await tester.pump();

      expect(selectedCategory, equals(QuestionCategory.dogBreeds));
    });

    testWidgets('displays selected state correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: AccessibleCategorySelection(
              selectedCategory: QuestionCategory.dogHealth,
              onCategorySelected: (category) {},
              isMobile: false,
            ),
          ),
        ),
      );

      // Verify selected indicator is shown
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('adapts to mobile layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: AccessibleCategorySelection(
              selectedCategory: null,
              onCategorySelected: (category) {},
              isMobile: true,
            ),
          ),
        ),
      );

      // Verify mobile layout renders
      expect(find.byType(AccessibleCategorySelection), findsOneWidget);
    });

    testWidgets('provides proper icons for each category', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: AccessibleCategorySelection(
              selectedCategory: null,
              onCategorySelected: (category) {},
              isMobile: false,
            ),
          ),
        ),
      );

      // Verify category-specific icons are present
      expect(find.byIcon(Icons.school_rounded), findsOneWidget); // Training
      expect(find.byIcon(Icons.pets_rounded), findsOneWidget); // Breeds
      expect(find.byIcon(Icons.psychology_rounded), findsOneWidget); // Behavior
      expect(
        find.byIcon(Icons.health_and_safety_rounded),
        findsOneWidget,
      ); // Health
      expect(find.byIcon(Icons.history_edu_rounded), findsOneWidget); // History
    });

    testWidgets('shows all available categories by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: AccessibleCategorySelection(
              selectedCategory: null,
              onCategorySelected: (category) {},
              isMobile: false,
            ),
          ),
        ),
      );

      // Verify all 5 default categories are shown
      expect(find.text('Dog Training'), findsOneWidget);
      expect(find.text('Dog Breeds'), findsOneWidget);
      expect(find.text('Dog Behavior'), findsOneWidget);
      expect(find.text('Dog Health'), findsOneWidget);
      expect(find.text('Dog History'), findsOneWidget);
    });

    testWidgets('respects custom available categories list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: AccessibleCategorySelection(
              selectedCategory: null,
              onCategorySelected: (category) {},
              isMobile: false,
              availableCategories: const [
                QuestionCategory.dogTraining,
                QuestionCategory.dogBreeds,
              ],
            ),
          ),
        ),
      );

      // Verify only specified categories are shown
      expect(find.text('Dog Training'), findsOneWidget);
      expect(find.text('Dog Breeds'), findsOneWidget);
      expect(find.text('Dog Behavior'), findsNothing);
      expect(find.text('Dog Health'), findsNothing);
      expect(find.text('Dog History'), findsNothing);
    });

    testWidgets('handles empty categories list gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: AccessibleCategorySelection(
              selectedCategory: null,
              onCategorySelected: (category) {},
              isMobile: false,
              availableCategories: const [],
            ),
          ),
        ),
      );

      // Verify widget renders without crashing
      expect(find.byType(AccessibleCategorySelection), findsOneWidget);
    });

    group('Accessibility Features', () {
      testWidgets('provides semantic labels for screen readers', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: Scaffold(
              body: AccessibleCategorySelection(
                selectedCategory: null,
                onCategorySelected: (category) {},
                isMobile: false,
              ),
            ),
          ),
        );

        // Check for semantic labels
        final semantics = tester.getSemantics(find.byType(Semantics).first);
        expect(semantics.label, isNotNull);
      });

      testWidgets('supports focus indicators', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: Scaffold(
              body: AccessibleCategorySelection(
                selectedCategory: null,
                onCategorySelected: (category) {},
                isMobile: false,
              ),
            ),
          ),
        );

        // Verify focus behavior
        expect(find.byType(Focus), findsWidgets);
      });

      testWidgets('handles high contrast mode', (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              accessibleNavigation: true,
              highContrast: true,
            ),
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en')],
              home: Scaffold(
                body: AccessibleCategorySelection(
                  selectedCategory: null,
                  onCategorySelected: (category) {},
                  isMobile: false,
                ),
              ),
            ),
          ),
        );

        // Verify widget renders in high contrast mode
        expect(find.byType(AccessibleCategorySelection), findsOneWidget);
      });
    });

    group('Keyboard Navigation', () {
      testWidgets('navigates with arrow keys in grid pattern', (
        WidgetTester tester,
      ) async {
        QuestionCategory? selectedCategory;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: Scaffold(
              body: AccessibleCategorySelection(
                selectedCategory: selectedCategory,
                onCategorySelected: (category) {
                  selectedCategory = category;
                },
                isMobile: true, // 2-column grid
              ),
            ),
          ),
        );

        // Focus and navigate
        final focusNode = tester
            .widget<Focus>(find.byType(Focus).first)
            .focusNode;
        focusNode?.requestFocus();
        await tester.pump();

        // Test grid navigation patterns
        await tester.sendKeyEvent(
          LogicalKeyboardKey.arrowDown,
        ); // Move down in column
        await tester.pump();

        await tester.sendKeyEvent(
          LogicalKeyboardKey.arrowUp,
        ); // Move up in column
        await tester.pump();
      });

      testWidgets('prevents navigation beyond boundaries', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: Scaffold(
              body: AccessibleCategorySelection(
                selectedCategory: null,
                onCategorySelected: (category) {},
                isMobile: false,
                availableCategories: const [QuestionCategory.dogTraining],
              ),
            ),
          ),
        );

        final focusNode = tester
            .widget<Focus>(find.byType(Focus).first)
            .focusNode;
        focusNode?.requestFocus();
        await tester.pump();

        // Try to navigate beyond single item
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
      });
    });
  });
}
