import 'dart:math';

/// Represents a single bone in the dog skeleton.
///
/// Each bone has local transforms (relative to its parent) and computed
/// world transforms (absolute position after forward kinematics).
/// This is the fundamental unit of the skeleton system — the animation
/// engine manipulates bone transforms, and the renderer reads them.
class Bone {
  /// Unique name identifying this bone (e.g., 'spine_base', 'paw_front_left').
  final String name;

  /// Name of the parent bone, or null for the root bone.
  final String? parentName;

  /// The rest (default) length of this bone segment.
  final double length;

  // --- Local transforms (relative to parent) ---

  /// X offset from parent's tip in parent's local space.
  double localX;

  /// Y offset from parent's tip in parent's local space.
  double localY;

  /// Rotation in radians relative to parent.
  double localRotation;

  /// Scale factor (uniform).
  double localScale;

  // --- Computed world transforms (set by forward kinematics) ---

  /// Absolute X position in world space.
  double worldX = 0.0;

  /// Absolute Y position in world space.
  double worldY = 0.0;

  /// Absolute rotation in world space.
  double worldRotation = 0.0;

  /// Absolute scale in world space.
  double worldScale = 1.0;

  Bone({
    required this.name,
    this.parentName,
    this.length = 0.0,
    this.localX = 0.0,
    this.localY = 0.0,
    this.localRotation = 0.0,
    this.localScale = 1.0,
  });

  /// Returns the world-space position of this bone's tip (end point),
  /// computed from worldX/worldY plus length along worldRotation.
  double get tipX => worldX + cos(worldRotation) * length * worldScale;
  double get tipY => worldY + sin(worldRotation) * length * worldScale;

  /// Reset local transforms to zero (neutral pose).
  void resetLocal() {
    localX = 0.0;
    localY = 0.0;
    localRotation = 0.0;
    localScale = 1.0;
  }

  /// Create a deep copy of this bone.
  Bone copy() {
    return Bone(
      name: name,
      parentName: parentName,
      length: length,
      localX: localX,
      localY: localY,
      localRotation: localRotation,
      localScale: localScale,
    )
      ..worldX = worldX
      ..worldY = worldY
      ..worldRotation = worldRotation
      ..worldScale = worldScale;
  }

  @override
  String toString() =>
      'Bone($name, local:($localX,$localY,${localRotation.toStringAsFixed(2)}rad), '
      'world:($worldX,$worldY,${worldRotation.toStringAsFixed(2)}rad))';
}
