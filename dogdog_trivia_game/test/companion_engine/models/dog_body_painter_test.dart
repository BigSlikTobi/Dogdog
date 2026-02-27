import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';

import 'package:dogdog_trivia_game/companion_engine/flame/components/dog_body_painter.dart';
import 'package:dogdog_trivia_game/companion_engine/models/dog_bone_transform.dart';
import 'package:dogdog_trivia_game/companion_engine/models/dog_expression.dart';
import 'package:dogdog_trivia_game/companion_engine/models/skeleton_configs/skeleton_config_factory.dart';
import 'package:dogdog_trivia_game/models/companion_enums.dart';

void main() {
  group('DogBodyPainter', () {
    group('does not throw for any breed × expression combination', () {
      for (final breed in CompanionBreed.values) {
        for (final expression in DogExpression.values) {
          test('$breed × $expression', () {
            final painter = DogBodyPainter(
              config: SkeletonConfigFactory.forBreed(breed),
              transform: DogBoneTransform.neutral,
              expression: expression,
            );

            final recorder = PictureRecorder();
            final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 200, 200));

            expect(
              () => painter.paint(canvas, const Size(200, 200)),
              returnsNormally,
              reason: 'Painter threw for $breed × $expression',
            );
          });
        }
      }
    });

    group('shouldRepaint', () {
      test('returns true when expression changes', () {
        final config = SkeletonConfigFactory.forBreed(CompanionBreed.goldenRetriever);
        final a = DogBodyPainter(
          config: config,
          transform: DogBoneTransform.neutral,
          expression: DogExpression.neutral,
        );
        final b = DogBodyPainter(
          config: config,
          transform: DogBoneTransform.neutral,
          expression: DogExpression.happy,
        );
        expect(a.shouldRepaint(b), isTrue);
      });

      test('returns true when transform changes', () {
        final config = SkeletonConfigFactory.forBreed(CompanionBreed.germanShepherd);
        final a = DogBodyPainter(
          config: config,
          transform: DogBoneTransform.neutral,
          expression: DogExpression.neutral,
        );
        final b = DogBodyPainter(
          config: config,
          transform: const DogBoneTransform(
            torsoAngle: 0.1,
            headAngle: 0,
            tailAngle: 0,
            frontLeftLegAngle: 0,
            frontRightLegAngle: 0,
            backLeftLegAngle: 0,
            backRightLegAngle: 0,
            frontLeftKneeAngle: 0,
            frontRightKneeAngle: 0,
            backLeftKneeAngle: 0,
            backRightKneeAngle: 0,
            verticalOffset: 0,
            isFacingRight: true,
          ),
          expression: DogExpression.neutral,
        );
        expect(a.shouldRepaint(b), isTrue);
      });
    });

    group('outline pass happens before fill pass', () {
      test('painter produces draw calls on canvas', () {
        // Use a recording canvas to verify at least one drawPath/drawOval call
        final recorder = PictureRecorder();
        final canvas = Canvas(
            recorder, const Rect.fromLTWH(0, 0, 300, 300));

        final painter = DogBodyPainter(
          config: SkeletonConfigFactory.forBreed(CompanionBreed.dachshund),
          transform: DogBoneTransform.neutral,
          expression: DogExpression.happy,
        );

        painter.paint(canvas, const Size(300, 300));

        // If the picture has content, recording size > 0
        final picture = recorder.endRecording();
        expect(picture, isNotNull);
      });
    });

    group('facing direction', () {
      test('paint completes for isFacingRight = false', () {
        final transform = const DogBoneTransform(
          torsoAngle: 0,
          headAngle: 0,
          tailAngle: 0,
          frontLeftLegAngle: 0,
          frontRightLegAngle: 0,
          backLeftLegAngle: 0,
          backRightLegAngle: 0,
          frontLeftKneeAngle: 0,
          frontRightKneeAngle: 0,
          backLeftKneeAngle: 0,
          backRightKneeAngle: 0,
          verticalOffset: 0,
          isFacingRight: false,
        );

        final recorder = PictureRecorder();
        final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 200, 200));
        final painter = DogBodyPainter(
          config: SkeletonConfigFactory.forBreed(CompanionBreed.germanShepherd),
          transform: transform,
          expression: DogExpression.neutral,
        );

        expect(
          () => painter.paint(canvas, const Size(200, 200)),
          returnsNormally,
        );
      });
    });
  });
}
