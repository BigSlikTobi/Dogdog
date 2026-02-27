import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dogdog_trivia_game/companion_engine/controllers/dog_animation_controller.dart';
import 'package:dogdog_trivia_game/companion_engine/controllers/dog_interaction_controller.dart';
import 'package:dogdog_trivia_game/companion_engine/models/dog_animation_state.dart';
import 'package:dogdog_trivia_game/companion_engine/models/skeleton_configs/skeleton_config_factory.dart';
import 'package:dogdog_trivia_game/models/companion_enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DogAnimationController animCtrl;
  late DogInteractionController interCtrl;

  setUp(() {
    animCtrl = DogAnimationController(
      skeleton: SkeletonConfigFactory.forBreed(CompanionBreed.goldenRetriever),
      vsync: const TestVSync(),
    );
    interCtrl = DogInteractionController(animationController: animCtrl);
  });

  tearDown(() {
    interCtrl.dispose();
    animCtrl.dispose();
  });

  group('Tap gesture', () {
    test('onTap triggers tailWag or headTilt state', () {
      interCtrl.onTap();
      expect(
        [DogAnimationState.tailWag, DogAnimationState.headTilt]
            .contains(animCtrl.state),
        isTrue,
      );
    });

    test('repeated taps do not throw', () {
      expect(() {
        interCtrl.onTap();
        interCtrl.onTap();
        interCtrl.onTap();
      }, returnsNormally);
    });
  });

  group('Long press gesture', () {
    test('onLongPressStart triggers petting state', () {
      interCtrl.onLongPressStart(const LongPressStartDetails());
      expect(animCtrl.state, DogAnimationState.petting);
    });

    test('onLongPressEnd returns to idle state', () {
      interCtrl.onLongPressStart(const LongPressStartDetails());
      interCtrl.onLongPressEnd(const LongPressEndDetails());
      expect(animCtrl.state, DogAnimationState.idle);
    });
  });

  group('Drag gesture', () {
    test('drag right (positive dx) puts dog in walking state facing right', () {
      interCtrl.onPanUpdate(DragUpdateDetails(
        globalPosition: Offset.zero,
        delta: Offset(10, 0),
      ));
      expect(animCtrl.state, DogAnimationState.walking);
      animCtrl.tick(0.1);
      expect(animCtrl.transform.isFacingRight, isTrue);
    });

    test('drag left (negative dx) puts dog in walking state facing left', () {
      interCtrl.onPanUpdate(DragUpdateDetails(
        globalPosition: Offset.zero,
        delta: Offset(-10, 0),
      ));
      expect(animCtrl.state, DogAnimationState.walking);
      animCtrl.tick(0.1);
      expect(animCtrl.transform.isFacingRight, isFalse);
    });

    test('drag end returns dog to idle', () {
      interCtrl.onPanUpdate(DragUpdateDetails(
        globalPosition: Offset.zero,
        delta: Offset(10, 0),
      ));
      interCtrl.onPanEnd(DragEndDetails());
      expect(animCtrl.state, DogAnimationState.idle);
    });

    test('zero delta drag does not crash', () {
      expect(
        () => interCtrl.onPanUpdate(DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: Offset.zero,
        )),
        returnsNormally,
      );
    });
  });

  group('Mood state routing', () {
    test('applyMoodState maps tail_wag to tailWag', () {
      interCtrl.applyMoodState('tail_wag');
      expect(animCtrl.state, DogAnimationState.tailWag);
    });

    test('applyMoodState maps head_tilt to headTilt', () {
      interCtrl.applyMoodState('head_tilt');
      expect(animCtrl.state, DogAnimationState.headTilt);
    });

    test('applyMoodState maps zoomies to walking', () {
      interCtrl.applyMoodState('zoomies');
      expect(animCtrl.state, DogAnimationState.walking);
    });

    test('applyMoodState maps yawn to idle', () {
      interCtrl.applyMoodState('yawn');
      expect(animCtrl.state, DogAnimationState.idle);
    });
  });

  group('State priority', () {
    test('petting takes priority over walk drag', () {
      interCtrl.onLongPressStart(const LongPressStartDetails());
      interCtrl.onPanUpdate(DragUpdateDetails(
        globalPosition: Offset.zero,
        delta: Offset(10, 0),
      ));
      // Petting should still dominate
      expect(animCtrl.state, DogAnimationState.petting);
    });
  });
}

class TestVSync implements TickerProvider {
  const TestVSync();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
