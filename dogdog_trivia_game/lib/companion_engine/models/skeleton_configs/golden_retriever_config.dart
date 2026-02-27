import 'package:flutter/material.dart';
import '../breed_skeleton_config.dart';

/// Golden Retriever: friendly proportions, medium-long legs, floppy ears.
const goldenRetrieverConfig = BreedSkeletonConfig(
  breedKey: 'goldenRetriever',
  heightScale: 0.85,
  torsoAspectRatio: 1.40,
  legLengthRatio: 0.44,
  legThicknessRatio: 0.19,
  headSizeRatio: 0.48,
  snoutLengthRatio: 0.42,
  earHeightRatio: 0.48,
  earsFloppy: true,
  tailLengthRatio: 0.45,
  tailCurledOverBack: false,
  primaryCoatColor: Color(0xFFDAA520),
  secondaryCoatColor: Color(0xFFF5E0A0),
  accentColor: Color(0xFF3E2200),
  animationSpeedMultiplier: 1.00,
);
