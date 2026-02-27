import 'dart:ui';
import 'package:flame/game.dart';
import '../controllers/dog_animation_controller.dart';
import '../models/breed_skeleton_config.dart';
import 'components/shadow_component.dart';
import 'components/dog_skeleton_component.dart';

/// Minimal [FlameGame] that hosts the animated dog skeleton.
///
/// This class is intentionally thin: it owns the game loop and adds the two
/// components that make up the dog scene. All animation logic lives in
/// [DogAnimationController]; all rendering logic lives in
/// [DogSkeletonComponent].
class DogGame extends FlameGame {
  DogGame({
    required this.skeleton,
    required this.animController,
  });

  final BreedSkeletonConfig skeleton;
  final DogAnimationController animController;

  late final ShadowComponent _shadow;
  late final DogSkeletonComponent _dogSkeleton;

  @override
  Color backgroundColor() => const Color(0x00000000); // transparent

  @override
  Future<void> onLoad() async {
    // Disable the default Flame debug overlay
    debugMode = false;

    _shadow = ShadowComponent(skeleton: skeleton)
      ..size = size
      ..position = Vector2.zero();

    _dogSkeleton = DogSkeletonComponent(
      skeleton: skeleton,
      controller: animController,
    )
      ..size = size
      ..position = Vector2.zero();

    await add(_shadow);
    await add(_dogSkeleton);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Keep shadow in sync with the latest vertical offset
    _shadow.verticalOffset = animController.transform.verticalOffset;
  }
}
