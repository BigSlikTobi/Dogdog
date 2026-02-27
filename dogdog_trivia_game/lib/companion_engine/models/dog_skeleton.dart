import 'package:flutter/material.dart';

/// Abstract contract that every breed skeleton must satisfy.
///
/// The Controller (DogAnimationController) and Renderer (DogSkeletonComponent)
/// depend only on this interface — they contain zero breed-specific constants.
/// Each breed provides its proportions as pure data; the animation math is
/// identical for all breeds.
abstract class DogSkeleton {
  /// Unique key matching the CompanionBreed enum name (e.g. 'corgi').
  String get breedKey;

  /// Overall height scale relative to a reference dog (1.0 = German Shepherd).
  /// Range: [0.4, 1.1]
  double get heightScale;

  /// Width / height ratio of the torso ellipse.
  /// Range: (0, 3.0]
  double get torsoAspectRatio;

  /// Leg length as a fraction of torso height.
  /// Range: [0.15, 0.65] — Corgi ≈ 0.20, Poodle ≈ 0.55
  double get legLengthRatio;

  /// Leg cylinder thickness as a fraction of torso width.
  /// Range: (0, 1.0]
  double get legThicknessRatio;

  /// Head circle diameter as a fraction of torso height.
  /// Range: (0, 1.0]
  double get headSizeRatio;

  /// Snout protrusion length as a fraction of head diameter.
  /// Range: [0, 1.0] — Bulldog ≈ 0.05, Collie ≈ 0.55
  double get snoutLengthRatio;

  /// Ear height as a fraction of head diameter.
  /// Range: [0, 1.0] — Corgi ≈ 0.85, Bulldog ≈ 0.25
  double get earHeightRatio;

  /// Whether the ears droop (true) or stand erect (false).
  bool get earsFloppy;

  /// Tail length as a fraction of torso height.
  /// Range: [0, 1.0] — Bulldog stub ≈ 0.10, Husky plume ≈ 0.55
  double get tailLengthRatio;

  /// Whether the tail curls up over the back (Husky, Shiba Inu style).
  bool get tailCurledOverBack;

  /// Primary coat colour used for the main body.
  Color get primaryCoatColor;

  /// Secondary coat colour used for markings, belly, and paws.
  Color get secondaryCoatColor;

  /// Accent colour for nose, eyes, and inner ears.
  Color get accentColor;

  /// Whether the breed has random spots (Dalmatian).
  bool get hasSpots;

  /// Whether the breed has fluffy poodle-style fuzz around joints.
  bool get hasPoodleFuzz;

  /// Whether the breed has a brachycephalic (flat) face.
  bool get hasFlatFace;

  /// Multiplier applied to all animation frequencies.
  /// Range: [0.5, 2.0] — Corgi ≈ 1.25, Bulldog ≈ 0.70
  double get animationSpeedMultiplier;
}
