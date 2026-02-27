import 'dart:ui';
import 'package:flame/components.dart';

/// The primitive unit of the skeleton: a single bone segment drawn as a
/// rounded rectangle (capsule shape).
///
/// Bones are hierarchically composed inside [DogSkeletonComponent].  Each
/// bone's rotation pivot is at its own origin; the parent positions the bone
/// by translating its canvas before handing off to this component.
///
/// The [depthScale] parameter lets back-leg bones appear slightly smaller
/// (0.92×) to simulate 3-D layering without a real 3-D engine.
class BoneComponent extends PositionComponent {
  BoneComponent({
    required this.length,
    required this.thickness,
    required this.color,
    this.depthScale = 1.0,
  });

  final double length;
  final double thickness;
  final Color color;

  /// < 1.0 makes back bones appear further away.
  final double depthScale;

  /// Current rotation in radians, set by [DogSkeletonComponent] each frame.
  @override
  double angle = 0.0;

  @override
  void render(Canvas canvas) {
    final scaledThickness = thickness * depthScale;
    final scaledLength = length * depthScale;

    final paint = Paint()
      ..color = Color.fromRGBO(
        ((color.r * 255.0) * depthScale).round().clamp(0, 255),
        ((color.g * 255.0) * depthScale).round().clamp(0, 255),
        ((color.b * 255.0) * depthScale).round().clamp(0, 255),
        color.a,
      )
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.rotate(angle);

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        -scaledThickness / 2,
        0,
        scaledThickness,
        scaledLength,
      ),
      Radius.circular(scaledThickness / 2),
    );
    canvas.drawRRect(rect, paint);
    canvas.restore();
  }
}
