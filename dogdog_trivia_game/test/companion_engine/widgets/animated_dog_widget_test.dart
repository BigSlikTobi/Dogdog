import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dogdog_trivia_game/companion_engine/widgets/animated_dog_widget.dart';
import 'package:dogdog_trivia_game/models/companion_enums.dart';

void main() {
  group('AnimatedDogWidget', () {
    Widget buildTestWidget({
      required CompanionBreed breed,
      double size = 200,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: AnimatedDogWidget(breed: breed, size: size),
          ),
        ),
      );
    }

    testWidgets('renders without error for goldenRetriever', (tester) async {
      await tester.pumpWidget(buildTestWidget(breed: CompanionBreed.goldenRetriever));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without error for dachshund', (tester) async {
      await tester.pumpWidget(buildTestWidget(breed: CompanionBreed.dachshund));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders for all CompanionBreed values', (tester) async {
      for (final breed in CompanionBreed.values) {
        await tester.pumpWidget(buildTestWidget(breed: breed));
        await tester.pump();
        expect(tester.takeException(), isNull,
            reason: 'AnimatedDogWidget threw for breed: $breed');
      }
    });

    testWidgets('GestureDetector is present in the widget tree', (tester) async {
      await tester.pumpWidget(
          buildTestWidget(breed: CompanionBreed.germanShepherd));
      await tester.pump();
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('custom size is respected by the widget', (tester) async {
      const testSize = 150.0;
      await tester.pumpWidget(buildTestWidget(
          breed: CompanionBreed.goldenRetriever, size: testSize));
      await tester.pump();
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, lessThanOrEqualTo(testSize + 1));
    });

    testWidgets('breed change triggers widget rebuild without crash',
        (tester) async {
      await tester.pumpWidget(
          buildTestWidget(breed: CompanionBreed.goldenRetriever));
      await tester.pump();
      await tester.pumpWidget(
          buildTestWidget(breed: CompanionBreed.dachshund));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('tap gesture invokes interaction (no crash)', (tester) async {
      await tester.pumpWidget(
          buildTestWidget(breed: CompanionBreed.germanShepherd));
      await tester.pump();
      await tester.tap(find.byType(AnimatedDogWidget));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('AnimatedDogWidget has a CustomPaint for skeleton drawing',
        (tester) async {
      await tester.pumpWidget(
          buildTestWidget(breed: CompanionBreed.goldenRetriever));
      await tester.pump();
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('AnimatedDogWidget mood integration', () {
    testWidgets('moodKey parameter sets initial animation state',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: AnimatedDogWidget(
              breed: CompanionBreed.goldenRetriever,
              moodKey: 'tail_wag',
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('moodKey change via widget update does not crash',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnimatedDogWidget(
            breed: CompanionBreed.dachshund,
            moodKey: 'idle',
          ),
        ),
      ));
      await tester.pump();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnimatedDogWidget(
            breed: CompanionBreed.dachshund,
            moodKey: 'tail_wag',
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
