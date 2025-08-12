import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/widgets/accessible_category_selection.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Simple functional test for AccessibleCategorySelection widget - Task 15
void main() {
  testWidgets('AccessibleCategorySelection basic functionality test', (
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

    // Verify the widget renders
    expect(find.byType(AccessibleCategorySelection), findsOneWidget);

    // Verify category buttons are present
    expect(find.text('Dog Training'), findsOneWidget);
    expect(find.text('Dog Breeds'), findsOneWidget);
    expect(find.text('Dog Behavior'), findsOneWidget);

    // Test category selection
    await tester.tap(find.text('Dog Training'));
    await tester.pump();

    expect(selectedCategory, equals(QuestionCategory.dogTraining));
  });
}
