import 'dart:ui';

/// Immutable snapshot of all bone angles and offsets for a single animation frame.
///
/// All angles are in radians. Positive angles are clockwise when viewed from
/// the right side of the dog (screen-right). The [DogAnimationController]
/// produces one of these per animation tick; the [DogSkeletonComponent]
/// reads it to position every [BoneComponent].
class DogBoneTransform {
  const DogBoneTransform({
    required this.torsoAngle,
    required this.headAngle,
    required this.tailAngle,
    required this.frontLeftLegAngle,
    required this.frontRightLegAngle,
    required this.backLeftLegAngle,
    required this.backRightLegAngle,
    required this.frontLeftKneeAngle,
    required this.frontRightKneeAngle,
    required this.backLeftKneeAngle,
    required this.backRightKneeAngle,
    required this.verticalOffset,
    required this.isFacingRight,
  });

  /// Tilt of the whole torso (breathing / gallop bob).
  final double torsoAngle;

  /// Rotation of the head around the neck joint.
  final double headAngle;

  /// Rotation of the tail around its root joint.
  final double tailAngle;

  final double frontLeftLegAngle;
  final double frontRightLegAngle;
  final double backLeftLegAngle;
  final double backRightLegAngle;

  /// Knee bend angles (second segment of each leg).
  final double frontLeftKneeAngle;
  final double frontRightKneeAngle;
  final double backLeftKneeAngle;
  final double backRightKneeAngle;

  /// Vertical displacement in logical pixels (used for jump/bounce).
  final double verticalOffset;

  /// Whether the dog sprite is flipped to face screen-right.
  final bool isFacingRight;

  /// A neutral (all-zero) transform useful as a default / baseline.
  static const DogBoneTransform neutral = DogBoneTransform(
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

  /// Linear interpolation between [a] and [b] by factor [t].
  ///
  /// [t] is clamped to [0, 1]. The boolean [isFacingRight] is taken from [b]
  /// when t ≥ 0.5 and from [a] otherwise, giving a clean midpoint flip.
  static DogBoneTransform lerp(DogBoneTransform a, DogBoneTransform b, double t) {
    final tc = t.clamp(0.0, 1.0);
    return DogBoneTransform(
      torsoAngle: lerpDouble(a.torsoAngle, b.torsoAngle, tc)!,
      headAngle: lerpDouble(a.headAngle, b.headAngle, tc)!,
      tailAngle: lerpDouble(a.tailAngle, b.tailAngle, tc)!,
      frontLeftLegAngle:
          lerpDouble(a.frontLeftLegAngle, b.frontLeftLegAngle, tc)!,
      frontRightLegAngle:
          lerpDouble(a.frontRightLegAngle, b.frontRightLegAngle, tc)!,
      backLeftLegAngle:
          lerpDouble(a.backLeftLegAngle, b.backLeftLegAngle, tc)!,
      backRightLegAngle:
          lerpDouble(a.backRightLegAngle, b.backRightLegAngle, tc)!,
      frontLeftKneeAngle:
          lerpDouble(a.frontLeftKneeAngle, b.frontLeftKneeAngle, tc)!,
      frontRightKneeAngle:
          lerpDouble(a.frontRightKneeAngle, b.frontRightKneeAngle, tc)!,
      backLeftKneeAngle:
          lerpDouble(a.backLeftKneeAngle, b.backLeftKneeAngle, tc)!,
      backRightKneeAngle:
          lerpDouble(a.backRightKneeAngle, b.backRightKneeAngle, tc)!,
      verticalOffset: lerpDouble(a.verticalOffset, b.verticalOffset, tc)!,
      isFacingRight: tc >= 0.5 ? b.isFacingRight : a.isFacingRight,
    );
  }
}
