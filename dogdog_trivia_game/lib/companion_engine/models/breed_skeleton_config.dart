import 'package:flutter/material.dart';
import 'dog_skeleton.dart';

/// Concrete, immutable implementation of [DogSkeleton].
///
/// Each breed creates one of these via a const factory or a named constructor
/// in its own config file. The fields are plain data — no logic lives here.
class BreedSkeletonConfig implements DogSkeleton {
  const BreedSkeletonConfig({
    required this.breedKey,
    required this.heightScale,
    required this.torsoAspectRatio,
    required this.legLengthRatio,
    required this.legThicknessRatio,
    required this.headSizeRatio,
    required this.snoutLengthRatio,
    required this.earHeightRatio,
    required this.earsFloppy,
    required this.tailLengthRatio,
    required this.tailCurledOverBack,
    required this.primaryCoatColor,
    required this.secondaryCoatColor,
    required this.accentColor,
    this.hasSpots = false,
    this.hasPoodleFuzz = false,
    this.hasFlatFace = false,
    required this.animationSpeedMultiplier,
  });

  @override
  final String breedKey;
  @override
  final double heightScale;
  @override
  final double torsoAspectRatio;
  @override
  final double legLengthRatio;
  @override
  final double legThicknessRatio;
  @override
  final double headSizeRatio;
  @override
  final double snoutLengthRatio;
  @override
  final double earHeightRatio;
  @override
  final bool earsFloppy;
  @override
  final double tailLengthRatio;
  @override
  final bool tailCurledOverBack;
  @override
  final Color primaryCoatColor;
  @override
  final Color secondaryCoatColor;
  @override
  final Color accentColor;
  @override
  final bool hasSpots;
  @override
  final bool hasPoodleFuzz;
  @override
  final bool hasFlatFace;
  @override
  final double animationSpeedMultiplier;
}
