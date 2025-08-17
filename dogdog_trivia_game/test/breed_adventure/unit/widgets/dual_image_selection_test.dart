import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/widgets/breed_adventure/dual_image_selection.dart';

void main() {
  group('DualImageSelection Tests', () {
    test('should create widget with required properties', () {
      final widget = DualImageSelection(
        imageUrl1: 'assets/images/test1.png',
        imageUrl2: 'assets/images/test2.png',
        onImageSelected: (index) {},
      );

      expect(widget.imageUrl1, equals('assets/images/test1.png'));
      expect(widget.imageUrl2, equals('assets/images/test2.png'));
      expect(widget.isEnabled, isTrue);
      expect(widget.selectedIndex, isNull);
      expect(widget.isCorrect, isNull);
      expect(widget.showFeedback, isFalse);
      expect(
        widget.animationDuration,
        equals(const Duration(milliseconds: 300)),
      );
    });

    test('should create widget with disabled state', () {
      final widget = DualImageSelection(
        imageUrl1: 'assets/images/test1.png',
        imageUrl2: 'assets/images/test2.png',
        onImageSelected: (index) {},
        isEnabled: false,
      );

      expect(widget.isEnabled, isFalse);
    });

    test('should create widget with selection state', () {
      final widget = DualImageSelection(
        imageUrl1: 'assets/images/test1.png',
        imageUrl2: 'assets/images/test2.png',
        onImageSelected: (index) {},
        selectedIndex: 0,
        isCorrect: true,
      );

      expect(widget.selectedIndex, equals(0));
      expect(widget.isCorrect, isTrue);
    });

    test('should create widget with feedback display', () {
      final widget = DualImageSelection(
        imageUrl1: 'assets/images/test1.png',
        imageUrl2: 'assets/images/test2.png',
        onImageSelected: (index) {},
        showFeedback: true,
      );

      expect(widget.showFeedback, isTrue);
    });

    test('should create widget with custom animation duration', () {
      const customDuration = Duration(milliseconds: 500);
      final widget = DualImageSelection(
        imageUrl1: 'assets/images/test1.png',
        imageUrl2: 'assets/images/test2.png',
        onImageSelected: (index) {},
        animationDuration: customDuration,
      );

      expect(widget.animationDuration, equals(customDuration));
    });

    test('should validate all property combinations', () {
      const url1 = 'test1.png';
      const url2 = 'test2.png';
      const duration = Duration(milliseconds: 250);

      final widget = DualImageSelection(
        imageUrl1: url1,
        imageUrl2: url2,
        onImageSelected: (index) {},
        isEnabled: false,
        selectedIndex: 1,
        isCorrect: false,
        showFeedback: true,
        animationDuration: duration,
      );

      expect(widget.imageUrl1, equals(url1));
      expect(widget.imageUrl2, equals(url2));
      expect(widget.isEnabled, isFalse);
      expect(widget.selectedIndex, equals(1));
      expect(widget.isCorrect, isFalse);
      expect(widget.showFeedback, isTrue);
      expect(widget.animationDuration, equals(duration));
    });
  });
}
