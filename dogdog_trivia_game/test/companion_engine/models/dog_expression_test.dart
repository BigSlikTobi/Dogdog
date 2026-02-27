import 'package:flutter_test/flutter_test.dart';

import 'package:dogdog_trivia_game/companion_engine/models/dog_animation_state.dart';
import 'package:dogdog_trivia_game/companion_engine/models/dog_expression.dart';

void main() {
  group('DogExpression.fromState maps all 8 animation states', () {
    test('idle → neutral', () {
      expect(DogExpression.fromState(DogAnimationState.idle),
          DogExpression.neutral);
    });

    test('walking → neutral', () {
      expect(DogExpression.fromState(DogAnimationState.walking),
          DogExpression.neutral);
    });

    test('sitting → happy', () {
      expect(DogExpression.fromState(DogAnimationState.sitting),
          DogExpression.happy);
    });

    test('tailWag → happy', () {
      expect(DogExpression.fromState(DogAnimationState.tailWag),
          DogExpression.happy);
    });

    test('headTilt → curious', () {
      expect(DogExpression.fromState(DogAnimationState.headTilt),
          DogExpression.curious);
    });

    test('petting → loving', () {
      expect(DogExpression.fromState(DogAnimationState.petting),
          DogExpression.loving);
    });

    test('zoomies → excited', () {
      expect(DogExpression.fromState(DogAnimationState.zoomies),
          DogExpression.excited);
    });

    test('sleeping → sleepy', () {
      expect(DogExpression.fromState(DogAnimationState.sleeping),
          DogExpression.sleepy);
    });
  });

  group('DogExpression values', () {
    test('has exactly 6 values', () {
      expect(DogExpression.values.length, 6);
    });

    test('contains neutral, happy, excited, curious, loving, sleepy', () {
      final names = DogExpression.values.map((e) => e.name).toSet();
      expect(names, containsAll(
          ['neutral', 'happy', 'excited', 'curious', 'loving', 'sleepy']));
    });

    test('showsTongue is true for happy and loving only', () {
      expect(DogExpression.happy.showsTongue, isTrue);
      expect(DogExpression.loving.showsTongue, isTrue);
      expect(DogExpression.neutral.showsTongue, isFalse);
      expect(DogExpression.excited.showsTongue, isFalse);
      expect(DogExpression.curious.showsTongue, isFalse);
      expect(DogExpression.sleepy.showsTongue, isFalse);
    });

    test('showsBlush is true for happy and loving only', () {
      expect(DogExpression.happy.showsBlush, isTrue);
      expect(DogExpression.loving.showsBlush, isTrue);
      expect(DogExpression.neutral.showsBlush, isFalse);
      expect(DogExpression.excited.showsBlush, isFalse);
    });

    test('eyesOpen is false only for sleepy', () {
      expect(DogExpression.sleepy.eyesOpen, isFalse);
      for (final expr in DogExpression.values) {
        if (expr != DogExpression.sleepy) {
          expect(expr.eyesOpen, isTrue,
              reason: '$expr should have eyes open');
        }
      }
    });

    test('eyeScale is largest for excited', () {
      final excitedScale = DogExpression.excited.eyeScale;
      for (final expr in DogExpression.values) {
        if (expr != DogExpression.excited) {
          expect(excitedScale, greaterThanOrEqualTo(expr.eyeScale));
        }
      }
    });

    test('mouthOpenness increases from neutral → happy → excited', () {
      expect(DogExpression.neutral.mouthOpenness,
          lessThan(DogExpression.happy.mouthOpenness));
      expect(DogExpression.happy.mouthOpenness,
          lessThanOrEqualTo(DogExpression.excited.mouthOpenness));
    });
  });
}
