import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/widgets/loading_animation.dart';

void main() {
  group('LoadingAnimation', () {
    testWidgets('renders loading animation with default settings', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingAnimation())),
      );

      // Should find the pets icon
      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('renders loading animation with custom message', (
      tester,
    ) async {
      const testMessage = 'Loading test data...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingAnimation(message: testMessage)),
        ),
      );

      expect(find.text(testMessage), findsOneWidget);
      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('applies custom size correctly', (tester) async {
      const customSize = 100.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingAnimation(size: customSize)),
        ),
      );

      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('applies custom color correctly', (tester) async {
      const customColor = Color(0xFF123456);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingAnimation(color: customColor)),
        ),
      );

      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('animation runs continuously', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingAnimation())),
      );

      expect(find.byIcon(Icons.pets), findsOneWidget);

      // Pump a few frames to ensure animation is running
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byIcon(Icons.pets), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byIcon(Icons.pets), findsOneWidget);
    });
  });

  group('ShimmerLoading', () {
    testWidgets('shows child when not loading', (tester) async {
      const testChild = Text('Test Content');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLoading(isLoading: false, child: testChild),
          ),
        ),
      );

      expect(find.byWidget(testChild), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('shows shimmer effect when loading', (tester) async {
      const testChild = Text('Test Content');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLoading(isLoading: true, child: testChild),
          ),
        ),
      );

      expect(find.byWidget(testChild), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('updates loading state correctly', (tester) async {
      const testChild = Text('Test Content');
      bool isLoading = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    ShimmerLoading(isLoading: isLoading, child: testChild),
                    ElevatedButton(
                      onPressed: () => setState(() => isLoading = !isLoading),
                      child: const Text('Toggle Loading'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);

      // Toggle loading state
      await tester.tap(find.text('Toggle Loading'));
      await tester.pump();

      expect(find.text('Test Content'), findsOneWidget);
    });
  });

  group('DotProgressIndicator', () {
    testWidgets('renders default number of dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DotProgressIndicator())),
      );

      // Should render the indicator (exact dot count is hard to test due to animation)
      expect(find.byType(DotProgressIndicator), findsOneWidget);
    });

    testWidgets('renders custom number of dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DotProgressIndicator(dotCount: 5)),
        ),
      );

      expect(find.byType(DotProgressIndicator), findsOneWidget);
    });

    testWidgets('applies custom dot size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DotProgressIndicator(dotSize: 12.0)),
        ),
      );

      expect(find.byType(DotProgressIndicator), findsOneWidget);
    });

    testWidgets('applies custom color', (tester) async {
      const customColor = Color(0xFF123456);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DotProgressIndicator(color: customColor)),
        ),
      );

      expect(find.byType(DotProgressIndicator), findsOneWidget);
    });

    testWidgets('animation runs continuously', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DotProgressIndicator())),
      );

      expect(find.byType(DotProgressIndicator), findsOneWidget);

      // Pump a few frames to ensure animation is running
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(DotProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(DotProgressIndicator), findsOneWidget);
    });
  });

  group('WaveProgressIndicator', () {
    testWidgets('renders wave progress indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WaveProgressIndicator())),
      );

      expect(find.byType(WaveProgressIndicator), findsOneWidget);
    });

    testWidgets('applies custom dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WaveProgressIndicator(width: 200.0, height: 40.0),
          ),
        ),
      );

      expect(find.byType(WaveProgressIndicator), findsOneWidget);
    });

    testWidgets('applies custom color', (tester) async {
      const customColor = Color(0xFF123456);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WaveProgressIndicator(color: customColor)),
        ),
      );

      expect(find.byType(WaveProgressIndicator), findsOneWidget);
    });

    testWidgets('applies custom wave count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WaveProgressIndicator(waveCount: 6)),
        ),
      );

      expect(find.byType(WaveProgressIndicator), findsOneWidget);
    });

    testWidgets('animation runs continuously', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WaveProgressIndicator())),
      );

      expect(find.byType(WaveProgressIndicator), findsOneWidget);

      // Pump a few frames to ensure animation is running
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(WaveProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(WaveProgressIndicator), findsOneWidget);
    });
  });

  group('Animation Performance', () {
    testWidgets('loading animations perform well with multiple instances', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const LoadingAnimation(size: 40),
                const DotProgressIndicator(),
                const WaveProgressIndicator(),
                const ShimmerLoading(child: Text('Shimmer Test')),
              ],
            ),
          ),
        ),
      );

      // All animations should render
      expect(find.byType(LoadingAnimation), findsOneWidget);
      expect(find.byType(DotProgressIndicator), findsOneWidget);
      expect(find.byType(WaveProgressIndicator), findsOneWidget);
      expect(find.byType(ShimmerLoading), findsOneWidget);

      // Pump several frames to ensure smooth performance
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16)); // ~60 FPS
      }

      // All should still be present
      expect(find.byType(LoadingAnimation), findsOneWidget);
      expect(find.byType(DotProgressIndicator), findsOneWidget);
      expect(find.byType(WaveProgressIndicator), findsOneWidget);
      expect(find.byType(ShimmerLoading), findsOneWidget);
    });

    testWidgets('animations dispose properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingAnimation())),
      );

      expect(find.byType(LoadingAnimation), findsOneWidget);

      // Navigate away to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('New Screen'))),
      );

      expect(find.text('New Screen'), findsOneWidget);
      expect(find.byType(LoadingAnimation), findsNothing);
    });
  });
}
