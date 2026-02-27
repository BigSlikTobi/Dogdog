import 'dart:ui';
import 'package:flame/components.dart';
import '../../models/breed_skeleton_config.dart';

/// Renders a soft elliptical shadow beneath the dog to create the illusion
/// of ground contact and pseudo-3D depth.
///
/// The shadow's opacity and size scale with the dog's vertical offset so it
/// contracts and fades when the dog jumps.
class ShadowComponent extends PositionComponent {
  ShadowComponent({required this.skeleton});

  final BreedSkeletonConfig skeleton;

  /// Updated each frame by [DogSkeletonComponent] before rendering.
  double verticalOffset = 0.0;

  @override
  void render(Canvas canvas) {
    // Shadow shrinks and fades as the dog lifts off the ground
    final liftFactor = (1.0 - (verticalOffset / 30.0)).clamp(0.3, 1.0);

    final shadowPaint = Paint()
      ..color = Color.fromRGBO(0, 0, 0, 0.18 * liftFactor)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    final baseWidth = size.x * 0.55 * skeleton.torsoAspectRatio * 0.4;
    final shadowWidth = baseWidth * liftFactor;
    final shadowHeight = shadowWidth * 0.3;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y - 4),
        width: shadowWidth,
        height: shadowHeight,
      ),
      shadowPaint,
    );
  }
}
