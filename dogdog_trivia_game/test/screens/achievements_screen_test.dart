import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dogdog_trivia_game/screens/achievements_screen.dart';
import 'package:dogdog_trivia_game/services/progress_service.dart';
import 'package:dogdog_trivia_game/l10n/generated/app_localizations.dart';
import 'package:dogdog_trivia_game/widgets/modern_card.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('AchievementsScreen Widget Tests', () {
    late ProgressService mockProgressService;

    setUp(() {
      mockProgressService = ProgressService();
    });

    testWidgets('should display loading indicator initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
          home: ChangeNotifierProvider<ProgressService>.value(
            value: mockProgressService,
            child: const AchievementsScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display achievements after loading', (tester) async {
      await mockProgressService.initialize();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
          home: ChangeNotifierProvider<ProgressService>.value(
            value: mockProgressService,
            child: const AchievementsScreen(),
          ),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      expect(find.text('Achievements & Progress'), findsOneWidget);
      expect(find.text('Your Statistics'), findsOneWidget);
      expect(find.text('Current Rank'), findsOneWidget);
      expect(find.text('All Achievements'), findsOneWidget);
    });

    testWidgets('should display correct statistics', (tester) async {
      await mockProgressService.initialize();

      // Add some progress
      await mockProgressService.recordCorrectAnswer(
        pointsEarned: 10,
        currentStreak: 1,
      );
      await mockProgressService.recordIncorrectAnswer();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
          home: ChangeNotifierProvider<ProgressService>.value(
            value: mockProgressService,
            child: const AchievementsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('1'), findsWidgets); // Correct answers
      expect(find.text('50.0%'), findsOneWidget); // Accuracy
    });

    testWidgets('should display achievement cards', (tester) async {
      await mockProgressService.initialize();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
          home: ChangeNotifierProvider<ProgressService>.value(
            value: mockProgressService,
            child: const AchievementsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display achievement cards (checking for specific rank names)
      expect(find.textContaining('Chihuahua'), findsOneWidget);
      expect(find.textContaining('Pug'), findsOneWidget);
    });

    testWidgets('should show achievement details on tap', (tester) async {
      await mockProgressService.initialize();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
          home: ChangeNotifierProvider<ProgressService>.value(
            value: mockProgressService,
            child: const AchievementsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on first achievement card (now using ModernCard.interactive)
      await tester.tap(find.byType(ModernCard).first);
      await tester.pumpAndSettle();

      // Should show dialog
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('should handle back button press', (tester) async {
      await mockProgressService.initialize();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
          home: ChangeNotifierProvider<ProgressService>.value(
            value: mockProgressService,
            child: const AchievementsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap back button
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();
    });

    testWidgets('should display next rank progress when available', (
      tester,
    ) async {
      await mockProgressService.initialize();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
          home: ChangeNotifierProvider<ProgressService>.value(
            value: mockProgressService,
            child: const AchievementsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Next Rank'), findsOneWidget);
    });

    testWidgets('should show all ranks achieved when at max rank', (
      tester,
    ) async {
      await mockProgressService.initialize();

      // Add enough progress to reach max rank
      for (int i = 0; i < 1000; i++) {
        await mockProgressService.recordCorrectAnswer(
          pointsEarned: 10,
          currentStreak: 1,
        );
      }

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
          home: ChangeNotifierProvider<ProgressService>.value(
            value: mockProgressService,
            child: const AchievementsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('All Ranks Achieved!'), findsOneWidget);
    });

    testWidgets('should use ModernCard components for layout', (tester) async {
      await mockProgressService.initialize();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
          home: ChangeNotifierProvider<ProgressService>.value(
            value: mockProgressService,
            child: const AchievementsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should use ModernCard components for the main sections
      expect(find.byType(ModernCard), findsWidgets);
    });

    testWidgets('should display dog breed images for achievements', (
      tester,
    ) async {
      await mockProgressService.initialize();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
          home: ChangeNotifierProvider<ProgressService>.value(
            value: mockProgressService,
            child: const AchievementsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display dog breed images instead of icons
      expect(find.byType(Image), findsWidgets);

      // Should have ClipOval widgets for circular dog images
      expect(find.byType(ClipOval), findsWidgets);
    });

    testWidgets('should apply grayscale filter to locked achievements', (
      tester,
    ) async {
      await mockProgressService.initialize();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
          home: ChangeNotifierProvider<ProgressService>.value(
            value: mockProgressService,
            child: const AchievementsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have ColorFiltered widgets for locked achievements
      expect(find.byType(ColorFiltered), findsWidgets);
    });

    testWidgets('should show progress bars for locked achievements', (
      tester,
    ) async {
      await mockProgressService.initialize();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
          home: ChangeNotifierProvider<ProgressService>.value(
            value: mockProgressService,
            child: const AchievementsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display progress indicators for locked achievements
      expect(find.byType(FractionallySizedBox), findsWidgets);
    });

    testWidgets('should handle image loading errors gracefully', (
      tester,
    ) async {
      await mockProgressService.initialize();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('de'), Locale('es')],
          home: ChangeNotifierProvider<ProgressService>.value(
            value: mockProgressService,
            child: const AchievementsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have fallback icons (pets icon) for error cases
      expect(find.byIcon(Icons.pets), findsWidgets);
    });
  });
}
