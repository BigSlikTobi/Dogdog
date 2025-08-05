import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dogdog_trivia_game/widgets/audio_settings.dart';
import 'package:dogdog_trivia_game/services/audio_service.dart';

void main() {
  group('AudioSettingsWidget', () {
    late AudioService audioService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      audioService = AudioService();
      await audioService.initialize();
    });

    tearDown(() async {
      await audioService.dispose();
    });

    testWidgets('renders audio settings widget correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AudioSettingsWidget())),
      );

      // Check for main components
      expect(find.text('Audio Settings'), findsOneWidget);
      expect(find.text('Sound Effects'), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);
      expect(find.text('Test Sounds'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('displays correct initial state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AudioSettingsWidget())),
      );

      // Switch should be on (not muted) by default
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);

      // Slider should be at maximum by default
      final sliderWidget = tester.widget<Slider>(find.byType(Slider));
      expect(sliderWidget.value, equals(1.0));

      // Volume percentage should show 100%
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('toggles mute state when switch is tapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AudioSettingsWidget())),
      );

      // Initially not muted
      expect(audioService.isMuted, isFalse);

      // Tap the switch to mute
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Should be muted now
      expect(audioService.isMuted, isTrue);

      // Switch should be off
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });

    testWidgets('hides volume slider when muted', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AudioSettingsWidget())),
      );

      // Initially volume slider should be visible
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);

      // Mute the audio
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Volume slider should be hidden
      expect(find.byType(Slider), findsNothing);
      expect(find.text('Volume'), findsNothing);
    });

    testWidgets('updates volume when slider is moved', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AudioSettingsWidget())),
      );

      // Find the slider
      final sliderFinder = find.byType(Slider);
      expect(sliderFinder, findsOneWidget);

      // Move slider to 50%
      await tester.drag(sliderFinder, const Offset(-100, 0));
      await tester.pumpAndSettle();

      // Volume should be updated (approximately 0.5)
      expect(audioService.volume, lessThan(1.0));
      expect(audioService.volume, greaterThan(0.0));
    });

    testWidgets('displays test sound buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AudioSettingsWidget())),
      );

      // Check for test sound buttons
      expect(find.text('Correct'), findsOneWidget);
      expect(find.text('Incorrect'), findsOneWidget);
      expect(find.text('Power-up'), findsOneWidget);
      expect(find.text('Achievement'), findsOneWidget);

      // Check for corresponding icons
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('disables test buttons when muted', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AudioSettingsWidget())),
      );

      // Mute the audio
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Test buttons should be disabled (we can't easily test this directly,
      // but we can verify they don't crash when tapped)
      await tester.tap(find.text('Correct'));
      await tester.tap(find.text('Incorrect'));
      await tester.tap(find.text('Power-up'));
      await tester.tap(find.text('Achievement'));
      await tester.pumpAndSettle();

      // No exceptions should be thrown
    });

    testWidgets('test sound buttons work when not muted', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AudioSettingsWidget())),
      );

      // Test buttons should work (we can't test actual sound playback,
      // but we can verify they don't crash)
      await tester.tap(find.text('Correct'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Incorrect'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Power-up'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Achievement'));
      await tester.pumpAndSettle();

      // No exceptions should be thrown
    });
  });

  group('AudioSettingsDialog', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final audioService = AudioService();
      await audioService.initialize();
    });

    testWidgets('shows dialog correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AudioSettingsDialog.show(context),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(AudioSettingsWidget), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('closes dialog when close button is tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AudioSettingsDialog.show(context),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.byType(Dialog), findsOneWidget);

      // Tap close button
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('can be dismissed by tapping outside', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AudioSettingsDialog.show(context),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.byType(Dialog), findsOneWidget);

      // Tap outside dialog (on barrier)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.byType(Dialog), findsNothing);
    });
  });

  group('Audio Settings Integration', () {
    testWidgets('settings persist across widget rebuilds', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final audioService = AudioService();
      await audioService.initialize();

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AudioSettingsWidget())),
      );

      // Change settings
      await tester.tap(find.byType(Switch)); // Mute
      await tester.pumpAndSettle();

      // Rebuild widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AudioSettingsWidget())),
      );

      // Settings should persist
      expect(audioService.isMuted, isTrue);
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);

      await audioService.dispose();
    });
  });
}
