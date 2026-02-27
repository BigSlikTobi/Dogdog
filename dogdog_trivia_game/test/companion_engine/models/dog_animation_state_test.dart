import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

import 'package:dogdog_trivia_game/companion_engine/models/dog_animation_state.dart';
import 'package:dogdog_trivia_game/companion_engine/models/dog_bone_transform.dart';

void main() {
  group('DogAnimationState', () {
    group('fromMoodKey maps all 4 mood keys', () {
      test('tail_wag → tailWag', () {
        expect(
          DogAnimationState.fromMoodKey('tail_wag'),
          DogAnimationState.tailWag,
        );
      });

      test('head_tilt → headTilt', () {
        expect(
          DogAnimationState.fromMoodKey('head_tilt'),
          DogAnimationState.headTilt,
        );
      });

      test('yawn → idle (sleepy behaviour)', () {
        expect(
          DogAnimationState.fromMoodKey('yawn'),
          DogAnimationState.idle,
        );
      });

      test('zoomies → walking (excited fast movement)', () {
        expect(
          DogAnimationState.fromMoodKey('zoomies'),
          DogAnimationState.walking,
        );
      });
    });

    test('fromMoodKey returns idle for unknown key', () {
      expect(
        DogAnimationState.fromMoodKey('unknown_mood_key'),
        DogAnimationState.idle,
      );
    });

    test('every value has a non-null string name', () {
      for (final state in DogAnimationState.values) {
        expect(state.name, isNotEmpty);
      }
    });

    test('contains at minimum: idle, walking, sitting, tailWag, headTilt', () {
      final names = DogAnimationState.values.map((s) => s.name).toSet();
      expect(names, containsAll(['idle', 'walking', 'sitting', 'tailWag', 'headTilt']));
    });
  });

  group('DogBoneTransform', () {
    late DogBoneTransform neutral;
    late DogBoneTransform tilted;

    setUp(() {
      neutral = DogBoneTransform(
        torsoAngle: 0.0,
        headAngle: 0.0,
        tailAngle: 0.0,
        frontLeftLegAngle: 0.0,
        frontRightLegAngle: 0.0,
        backLeftLegAngle: 0.0,
        backRightLegAngle: 0.0,
        frontLeftKneeAngle: 0.0,
        frontRightKneeAngle: 0.0,
        backLeftKneeAngle: 0.0,
        backRightKneeAngle: 0.0,
        verticalOffset: 0.0,
        isFacingRight: true,
      );

      tilted = DogBoneTransform(
        torsoAngle: pi / 6,
        headAngle: pi / 4,
        tailAngle: pi / 3,
        frontLeftLegAngle: 0.5,
        frontRightLegAngle: -0.5,
        backLeftLegAngle: -0.5,
        backRightLegAngle: 0.5,
        frontLeftKneeAngle: 0.3,
        frontRightKneeAngle: -0.3,
        backLeftKneeAngle: -0.3,
        backRightKneeAngle: 0.3,
        verticalOffset: 10.0,
        isFacingRight: false,
      );
    });

    test('lerp at t=0 returns first transform values', () {
      final result = DogBoneTransform.lerp(neutral, tilted, 0.0);
      expect(result.torsoAngle, closeTo(0.0, 1e-9));
      expect(result.headAngle, closeTo(0.0, 1e-9));
      expect(result.verticalOffset, closeTo(0.0, 1e-9));
      expect(result.isFacingRight, isTrue);
    });

    test('lerp at t=1 returns second transform values', () {
      final result = DogBoneTransform.lerp(neutral, tilted, 1.0);
      expect(result.torsoAngle, closeTo(pi / 6, 1e-9));
      expect(result.headAngle, closeTo(pi / 4, 1e-9));
      expect(result.tailAngle, closeTo(pi / 3, 1e-9));
      expect(result.verticalOffset, closeTo(10.0, 1e-9));
    });

    test('lerp at t=0.5 interpolates midpoint', () {
      final result = DogBoneTransform.lerp(neutral, tilted, 0.5);
      expect(result.torsoAngle, closeTo(pi / 12, 1e-9));
      expect(result.frontLeftLegAngle, closeTo(0.25, 1e-9));
      expect(result.verticalOffset, closeTo(5.0, 1e-9));
    });

    test('lerp clamps t to [0,1]', () {
      final below = DogBoneTransform.lerp(neutral, tilted, -0.5);
      expect(below.torsoAngle, closeTo(0.0, 1e-9));

      final above = DogBoneTransform.lerp(neutral, tilted, 1.5);
      expect(above.torsoAngle, closeTo(pi / 6, 1e-9));
    });

    test('isFacingRight is taken from "b" when t >= 0.5', () {
      final result05 = DogBoneTransform.lerp(neutral, tilted, 0.5);
      expect(result05.isFacingRight, isFalse); // tilted.isFacingRight

      final result04 = DogBoneTransform.lerp(neutral, tilted, 0.4);
      expect(result04.isFacingRight, isTrue); // neutral.isFacingRight
    });

    test('neutral transform has all angles at zero', () {
      expect(neutral.torsoAngle, 0.0);
      expect(neutral.headAngle, 0.0);
      expect(neutral.tailAngle, 0.0);
      expect(neutral.frontLeftLegAngle, 0.0);
      expect(neutral.frontRightLegAngle, 0.0);
      expect(neutral.backLeftLegAngle, 0.0);
      expect(neutral.backRightLegAngle, 0.0);
    });
  });
}
