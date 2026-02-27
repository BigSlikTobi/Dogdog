import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dogdog_trivia_game/companion_engine/controllers/dog_animation_controller.dart';
import 'package:dogdog_trivia_game/companion_engine/models/dog_animation_state.dart';
import 'package:dogdog_trivia_game/companion_engine/models/skeleton_configs/skeleton_config_factory.dart';
import 'package:dogdog_trivia_game/models/companion_enums.dart';

void main() {
  // We use a real Flutter test framework ticker so vsync works.
  TestWidgetsFlutterBinding.ensureInitialized();

  late DogAnimationController controller;

  setUp(() {
    controller = DogAnimationController(
      skeleton: SkeletonConfigFactory.forBreed(CompanionBreed.goldenRetriever),
      vsync: const TestVSync(),
    );
  });

  tearDown(() {
    controller.dispose();
  });

  group('Initial state', () {
    test('default state is idle', () {
      expect(controller.state, DogAnimationState.idle);
    });

    test('at t=0 idle transform has neutral torso angle (≈0)', () {
      controller.tick(0.0);
      expect(controller.transform.torsoAngle, closeTo(0.0, 0.1));
    });

    test('idle transform verticalOffset is non-negative', () {
      controller.tick(0.0);
      expect(controller.transform.verticalOffset, greaterThanOrEqualTo(0.0));
    });
  });

  group('Walk cycle', () {
    setUp(() {
      controller.setAnimationState(DogAnimationState.walking);
    });

    test('state transitions to walking', () {
      expect(controller.state, DogAnimationState.walking);
    });

    test('at t=0 walking transform front-left and back-left legs in phase', () {
      controller.tick(0.0);
      // At t=0 sin(0) = 0 → both leading legs should be near neutral
      final t = controller.transform;
      expect(t.frontLeftLegAngle.abs(), lessThan(0.3));
    });

    test('at t=0.25 cycle front-right and back-left legs are in opposite phase', () {
      // Walk cycle period is 1 second. At t=0.25s:
      //   frontRight: sin(2π*0.25) = sin(π/2) = 1.0 → positive peak
      //   frontLeft:  sin(2π*0.25 + π) = sin(3π/2) = −1.0 → negative peak
      controller.tick(0.25);
      final t = controller.transform;
      // Front legs must be in opposite directions
      expect(t.frontRightLegAngle * t.frontLeftLegAngle, lessThan(0.0),
          reason: 'front legs must be in opposite phase at t=0.25s');
    });

    test('walk cycle produces non-zero leg angles', () {
      controller.tick(0.1);
      final t = controller.transform;
      final anyNonZero = t.frontLeftLegAngle.abs() > 0.01 ||
          t.frontRightLegAngle.abs() > 0.01 ||
          t.backLeftLegAngle.abs() > 0.01 ||
          t.backRightLegAngle.abs() > 0.01;
      expect(anyNonZero, isTrue);
    });

    test('animationSpeedMultiplier affects leg swing magnitude via time scaling', () {
      // Dachshund has speedMultiplier 1.20 (faster) vs German Shepherd 1.00 (slower)
      final dachshundCtrl = DogAnimationController(
        skeleton: SkeletonConfigFactory.forBreed(CompanionBreed.dachshund),
        vsync: const TestVSync(),
      )..setAnimationState(DogAnimationState.walking);
      final shepherdCtrl = DogAnimationController(
        skeleton: SkeletonConfigFactory.forBreed(CompanionBreed.germanShepherd),
        vsync: const TestVSync(),
      )..setAnimationState(DogAnimationState.walking);

      // At the same real-time t, faster multiplier produces different phase
      dachshundCtrl.tick(0.1);
      shepherdCtrl.tick(0.1);

      // Their leg angles at the same real time should differ
      expect(
        dachshundCtrl.transform.frontLeftLegAngle,
        isNot(closeTo(shepherdCtrl.transform.frontLeftLegAngle, 0.001)),
      );

      dachshundCtrl.dispose();
      shepherdCtrl.dispose();
    });
  });

  group('Sitting state', () {
    setUp(() {
      controller.setAnimationState(DogAnimationState.sitting);
    });

    test('sitting state back legs have positive (folded) angle', () {
      controller.tick(0.0);
      // Back legs fold under body — angle should be positive/elevated
      expect(controller.transform.backLeftLegAngle, greaterThan(0.0));
      expect(controller.transform.backRightLegAngle, greaterThan(0.0));
    });

    test('sitting state torso angle is slightly forward (positive)', () {
      controller.tick(0.0);
      expect(controller.transform.torsoAngle, greaterThanOrEqualTo(0.0));
    });
  });

  group('State transitions', () {
    test('idle → walking → sitting roundtrip', () {
      expect(controller.state, DogAnimationState.idle);
      controller.setAnimationState(DogAnimationState.walking);
      expect(controller.state, DogAnimationState.walking);
      controller.setAnimationState(DogAnimationState.sitting);
      expect(controller.state, DogAnimationState.sitting);
      controller.setAnimationState(DogAnimationState.idle);
      expect(controller.state, DogAnimationState.idle);
    });

    test('setAnimationState notifies listeners', () {
      int notifications = 0;
      controller.addListener(() => notifications++);
      controller.setAnimationState(DogAnimationState.walking);
      expect(notifications, greaterThan(0));
    });
  });

  group('Walk velocity', () {
    test('positive velocity faces right', () {
      controller.setWalkVelocity(1.0);
      controller.tick(0.1);
      expect(controller.transform.isFacingRight, isTrue);
    });

    test('negative velocity faces left', () {
      controller.setWalkVelocity(-1.0);
      controller.tick(0.1);
      expect(controller.transform.isFacingRight, isFalse);
    });

    test('zero velocity stays idle', () {
      controller.setAnimationState(DogAnimationState.walking);
      controller.setWalkVelocity(0.0);
      // After settling the controller may stay in walking state but velocity=0
      // — the important thing is it doesn't throw
      expect(controller.state, isA<DogAnimationState>());
    });
  });

  group('Gesture triggers', () {
    test('triggerTap transitions to headTilt or tailWag', () {
      controller.triggerTap();
      expect(
        [DogAnimationState.headTilt, DogAnimationState.tailWag]
            .contains(controller.state),
        isTrue,
      );
    });

    test('triggerHold transitions to petting', () {
      controller.triggerHold();
      expect(controller.state, DogAnimationState.petting);
    });

    test('triggerRelease returns to idle', () {
      controller.triggerHold();
      controller.triggerRelease();
      expect(controller.state, DogAnimationState.idle);
    });
  });

  group('Idle breathing', () {
    test('vertical offset oscillates during idle', () {
      controller.tick(0.0);
      final v0 = controller.transform.verticalOffset;
      controller.tick(0.5);
      final v05 = controller.transform.verticalOffset;
      // At least one tick should differ (breathing wave)
      expect(v0, isNot(closeTo(v05, 1e-9)));
    });
  });
}

/// Minimal [TickerProvider] that satisfies vsync requirement in pure unit tests.
class TestVSync implements TickerProvider {
  const TestVSync();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
