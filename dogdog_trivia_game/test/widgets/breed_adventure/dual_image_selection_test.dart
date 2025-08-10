import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/widgets/breed_adventure/dual_image_selection.dart';

void main() {
  group('DualImageSelection Widget Tests', () {
    const imageUrl1 = 'https://example.com/image1.jpg';
    const imageUrl2 = 'https://example.com/image2.jpg';

    testWidgets('should display two images side by side', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DualImageSelection(
              imageUrl1: imageUrl1,
              imageUrl2: imageUrl2,
              onImageSelected: (index) {},
            ),
          ),
        ),
      );

      // Should find two image containers
      expect(find.byType(GestureDetector), findsNWidgets(2));
      expect(find.byType(AspectRatio), findsNWidgets(2));
    });

    testWidgets('should call onImageSelected when image is tapped', (
      WidgetTester tester,
    ) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DualImageSelection(
              imageUrl1: imageUrl1,
              imageUrl2: imageUrl2,
              onImageSelected: (index) {
                selectedIndex = index;
              },
            ),
          ),
        ),
      );

      // Tap the first image
      await tester.tap(find.byType(GestureDetector).first);
      expect(selectedIndex, equals(0));

      // Tap the second image
      await tester.tap(find.byType(GestureDetector).last);
      expect(selectedIndex, equals(1));
    });

    testWidgets('should not respond to taps when disabled', (
      WidgetTester tester,
    ) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DualImageSelection(
              imageUrl1: imageUrl1,
              imageUrl2: imageUrl2,
              onImageSelected: (index) {
                selectedIndex = index;
              },
              isEnabled: false,
            ),
          ),
        ),
      );

      // Tap the first image
      await tester.tap(find.byType(GestureDetector).first);
      expect(selectedIndex, isNull);
    });

    testWidgets('should show feedback when showFeedback is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DualImageSelection(
              imageUrl1: imageUrl1,
              imageUrl2: imageUrl2,
              onImageSelected: (index) {},
              selectedIndex: 0,
              isCorrect: true,
              showFeedback: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show check icon for correct answer
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('should show error feedback for incorrect answer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DualImageSelection(
              imageUrl1: imageUrl1,
              imageUrl2: imageUrl2,
              onImageSelected: (index) {},
              selectedIndex: 1,
              isCorrect: false,
              showFeedback: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show close icon for incorrect answer
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('should show tap indicators when enabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DualImageSelection(
              imageUrl1: imageUrl1,
              imageUrl2: imageUrl2,
              onImageSelected: (index) {},
              isEnabled: true,
            ),
          ),
        ),
      );

      // Should show tap indicators (1 and 2)
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('should animate entry correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DualImageSelection(
              imageUrl1: imageUrl1,
              imageUrl2: imageUrl2,
              onImageSelected: (index) {},
            ),
          ),
        ),
      );

      // Should find transform widgets for animation
      expect(find.byType(Transform), findsAtLeastNWidgets(2));
      expect(find.byType(FadeTransition), findsAtLeastNWidgets(2));
    });
  });

  group('DualImageSelectionLoading Widget Tests', () {
    testWidgets('should display loading placeholders', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DualImageSelectionLoading())),
      );

      // Should find two placeholder containers
      expect(find.byType(AspectRatio), findsNWidgets(2));
      expect(find.byType(Container), findsAtLeastNWidgets(2));
    });

    testWidgets('should show shimmer loading effect', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DualImageSelectionLoading())),
      );

      // Should find shimmer loading widgets
      expect(find.byType(SizedBox), findsAtLeastNWidgets(2));
    });
  });
}
