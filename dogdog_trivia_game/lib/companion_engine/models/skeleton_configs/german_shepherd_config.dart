import 'package:flutter/material.dart';
import '../breed_skeleton_config.dart';

/// German Shepherd: tall athletic reference dog (heightScale ≈ 1.0),
/// erect ears, tan-and-black saddle pattern.
const germanShepherdConfig = BreedSkeletonConfig(
  breedKey: 'germanShepherd',
  heightScale: 1.00,
  torsoAspectRatio: 1.40,
  legLengthRatio: 0.48,
  legThicknessRatio: 0.18,
  headSizeRatio: 0.44,
  snoutLengthRatio: 0.48,
  earHeightRatio: 0.75,
  earsFloppy: false,
  tailLengthRatio: 0.48,
  tailCurledOverBack: false,
  primaryCoatColor: Color(0xFF8B6914),
  secondaryCoatColor: Color(0xFF1A1A1A),
  accentColor: Color(0xFF3E2200),
  animationSpeedMultiplier: 1.00,
);
