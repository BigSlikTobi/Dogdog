import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/design_system/modern_colors.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/utils/enum_extensions.dart';
import 'package:dogdog_trivia_game/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('Design System Integration Tests', () {
    Widget createTestWidget({required Widget child}) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
        home: Scaffold(body: SingleChildScrollView(child: child)),
      );
    }

    group('ModernColors Integration', () {
      testWidgets('should work with difficulty selection cards', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            child: Builder(
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: ModernColors.createLinearGradient(
                          ModernColors.getGradientForDifficulty('easy'),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            Difficulty.easy.displayName(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: ModernColors.getColorForDifficulty('easy'),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: ModernColors.createLinearGradient(
                          ModernColors.getGradientForDifficulty('medium'),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            Difficulty.medium.displayName(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: ModernColors.getColorForDifficulty(
                                'medium',
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Easy'), findsOneWidget);
        expect(find.text('Medium'), findsOneWidget);
        expect(
          find.byType(Container),
          findsNWidgets(4),
        ); // 2 main containers + 2 circles
      });

      testWidgets('should create proper theme integration', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              primaryColor: ModernColors.primaryPurple,
              colorScheme: ColorScheme.fromSeed(
                seedColor: ModernColors.primaryPurple,
                brightness: Brightness.light,
              ),
            ),
            home: Scaffold(
              backgroundColor: ModernColors.backgroundGradientStart,
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    color: ModernColors.cardBackground,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Test Card'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ModernColors.primaryPurple,
                      foregroundColor: ModernColors.textOnDark,
                    ),
                    child: const Text('Test Button'),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Test Card'), findsOneWidget);
        expect(find.text('Test Button'), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('should handle status colors correctly', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ModernColors.success.withValues(alpha: 0.1),
                    border: Border.all(color: ModernColors.success),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: ModernColors.success),
                      const SizedBox(width: 8),
                      Text(
                        'Success!',
                        style: TextStyle(color: ModernColors.success),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ModernColors.error.withValues(alpha: 0.1),
                    border: Border.all(color: ModernColors.error),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error, color: ModernColors.error),
                      const SizedBox(width: 8),
                      Text(
                        'Error occurred',
                        style: TextStyle(color: ModernColors.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Success!'), findsOneWidget);
        expect(find.text('Error occurred'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);
      });
    });

    group('Performance Integration', () {
      testWidgets('should efficiently handle multiple gradient creations', (
        tester,
      ) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          createTestWidget(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                final difficulty =
                    Difficulty.values[index % Difficulty.values.length];
                final colors = ModernColors.getGradientForDifficulty(
                  difficulty.name,
                );

                return Container(
                  height: 20,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    gradient: ModernColors.createLinearGradient(colors),
                  ),
                );
              }),
            ),
          ),
        );

        await tester.pumpAndSettle();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        expect(find.byType(Container), findsNWidgets(5));
      });

      testWidgets('should reuse color instances efficiently', (tester) async {
        final colors1 = <Color>[];
        final colors2 = <Color>[];

        for (final difficulty in ['easy', 'medium', 'hard', 'expert']) {
          colors1.add(ModernColors.getColorForDifficulty(difficulty));
          colors2.add(ModernColors.getColorForDifficulty(difficulty));
        }

        for (int i = 0; i < colors1.length; i++) {
          expect(identical(colors1[i], colors2[i]), isTrue);
        }

        await tester.pumpWidget(
          createTestWidget(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: colors1
                  .map(
                    (color) => Container(width: 50, height: 50, color: color),
                  )
                  .toList(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(Container), findsNWidgets(4));
      });
    });

    group('Error Handling Integration', () {
      testWidgets('should gracefully handle invalid difficulty names', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: ModernColors.createLinearGradient(
                      ModernColors.getGradientForDifficulty('invalid'),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Invalid Difficulty',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  color: ModernColors.getColorForDifficulty('nonexistent'),
                ),
              ],
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Invalid Difficulty'), findsOneWidget);
        expect(find.byType(Container), findsNWidgets(2));
      });
    });

    group('Accessibility Integration', () {
      testWidgets('should maintain proper contrast ratios', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: ModernColors.textPrimary,
                  child: Text(
                    'Light text on dark background',
                    style: TextStyle(color: ModernColors.textOnDark),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: ModernColors.cardBackground,
                  child: Text(
                    'Dark text on light background',
                    style: TextStyle(color: ModernColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Light text on dark background'), findsOneWidget);
        expect(find.text('Dark text on light background'), findsOneWidget);

        expect(ModernColors.textPrimary.computeLuminance(), lessThan(0.5));
        expect(ModernColors.textOnDark.computeLuminance(), greaterThan(0.5));
      });
    });
  });
}
