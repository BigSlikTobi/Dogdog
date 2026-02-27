import 'package:flutter/material.dart';
import '../breed_skeleton_config.dart';

/// Dachshund: absurdly elongated torso, tiny stubby legs, long floppy ears.
/// The extreme torsoAspectRatio (3.2) is the visual signature of the breed.
const dachshundConfig = BreedSkeletonConfig(
  breedKey: 'dachshund',
  heightScale: 0.50,
  torsoAspectRatio: 3.20,
  legLengthRatio: 0.18,
  legThicknessRatio: 0.22,
  headSizeRatio: 0.50,
  snoutLengthRatio: 0.40,
  earHeightRatio: 0.65,
  earsFloppy: true,
  tailLengthRatio: 0.30,
  tailCurledOverBack: false,
  primaryCoatColor: Color(0xFF8B4513),
  secondaryCoatColor: Color(0xFFC87941),
  accentColor: Color(0xFF1A0800),
  animationSpeedMultiplier: 1.20,
);
