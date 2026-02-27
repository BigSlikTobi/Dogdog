import 'dart:ui';
import 'package:flame/components.dart';
import '../../controllers/dog_animation_controller.dart';
import '../../models/breed_skeleton_config.dart';
import '../../models/dog_expression.dart';
import 'dog_body_painter.dart';

/// Top-level Flame component that renders the companion dog each frame.
///
/// All drawing is delegated to [DogBodyPainter], the Duolingo-style
/// CustomPainter.  This component's sole responsibilities are:
///   1. Advance the animation clock via [DogAnimationController.tick].
///   2. Derive the correct [DogExpression] from the current animation state.
///   3. Hand the painter a [Canvas] + [Size] and let it do the rest.
///
/// Layer order (managed by the painter):
///   shadow → back legs → torso → tail → head → front legs
class DogSkeletonComponent extends PositionComponent {
  DogSkeletonComponent({
    required this.skeleton,
    required this.controller,
  });

  final BreedSkeletonConfig skeleton;
  final DogAnimationController controller;

  @override
  void update(double dt) {
    controller.tick(dt);
  }

  @override
  void render(Canvas canvas) {
    if (size == Vector2.zero()) return;

    final painter = DogBodyPainter(
      config: skeleton,
      transform: controller.transform,
      expression: DogExpression.fromState(controller.state),
    );

    painter.paint(canvas, Size(size.x, size.y));
  }
}
