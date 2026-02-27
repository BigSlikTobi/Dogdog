import 'dog_animation_state.dart';

/// Visual face expression derived from the current [DogAnimationState].
///
/// The [DogBodyPainter] reads this value each frame to choose eye shape,
/// mouth curve, tongue visibility, and blush circles.  Expression is
/// intentionally separate from animation state so that multiple states can
/// share the same face (e.g. both [DogAnimationState.idle] and
/// [DogAnimationState.walking] show a relaxed [neutral] face).
enum DogExpression {
  /// Relaxed, gentle eyes; soft closed-mouth smile.
  neutral(
    eyeScale: 1.0,
    mouthOpenness: 0.0,
    eyesOpen: true,
    showsTongue: false,
    showsBlush: false,
  ),

  /// Wide arched eyes, big open smile, tongue out, cheek blushes.
  happy(
    eyeScale: 1.05,
    mouthOpenness: 0.7,
    eyesOpen: true,
    showsTongue: true,
    showsBlush: true,
  ),

  /// Maximum wide-open circle eyes, open-O mouth, raised brow lines.
  excited(
    eyeScale: 1.25,
    mouthOpenness: 0.9,
    eyesOpen: true,
    showsTongue: false,
    showsBlush: false,
  ),

  /// One eye slightly tilted, small quizzical smile, one raised eyebrow.
  curious(
    eyeScale: 1.0,
    mouthOpenness: 0.2,
    eyesOpen: true,
    showsTongue: false,
    showsBlush: false,
  ),

  /// Squinting happy arcs, wide smile, tongue out, pink blush.
  loving(
    eyeScale: 0.85,
    mouthOpenness: 0.8,
    eyesOpen: true,
    showsTongue: true,
    showsBlush: true,
  ),

  /// Closed arc eyes (˘ shape), neutral mouth, ZZZ indicator.
  sleepy(
    eyeScale: 0.0,
    mouthOpenness: 0.0,
    eyesOpen: false,
    showsTongue: false,
    showsBlush: false,
  );

  const DogExpression({
    required this.eyeScale,
    required this.mouthOpenness,
    required this.eyesOpen,
    required this.showsTongue,
    required this.showsBlush,
  });

  /// Multiplier applied to the base eye diameter.
  final double eyeScale;

  /// 0.0 = closed/smile, 1.0 = wide open mouth.
  final double mouthOpenness;

  /// False only for [sleepy] — draws arc lines instead of filled circles.
  final bool eyesOpen;

  /// Whether to draw a dangling tongue below the lower lip.
  final bool showsTongue;

  /// Whether to draw soft pink blush circles on the cheeks.
  final bool showsBlush;

  /// Derives the correct expression from the current animation state.
  static DogExpression fromState(DogAnimationState state) {
    return switch (state) {
      DogAnimationState.idle => neutral,
      DogAnimationState.walking => neutral,
      DogAnimationState.sitting => happy,
      DogAnimationState.tailWag => happy,
      DogAnimationState.headTilt => curious,
      DogAnimationState.petting => loving,
      DogAnimationState.zoomies => excited,
      DogAnimationState.sleeping => sleepy,
    };
  }
}
