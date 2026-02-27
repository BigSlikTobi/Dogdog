/// All possible animation states for a companion dog.
///
/// The [DogAnimationController] transitions between these states based on
/// gestures and the companion's current mood. The Flame renderer reads the
/// current state each frame but never drives the state itself.
enum DogAnimationState {
  /// Standing still with a gentle breathing bob.
  idle,

  /// Moving left or right; the walking gait cycle is active.
  walking,

  /// Sitting down: hind legs folded, forelegs extended.
  sitting,

  /// Tail oscillating at high frequency (happy mood).
  tailWag,

  /// Head tilted sideways (curious mood).
  headTilt,

  /// Leaning into the user's hand; tail at maximum wag rate (petting).
  petting,

  /// High-speed erratic running (excited/zoomies mood).
  zoomies,

  /// Crouching with eyes half-closed (sleepy mood).
  sleeping;

  /// Maps a [CompanionMood.animationKey] string to a [DogAnimationState].
  ///
  /// Unknown keys fall back to [idle] so the renderer is always in a valid
  /// state even if new mood keys are added without updating this class.
  static DogAnimationState fromMoodKey(String moodKey) {
    return switch (moodKey) {
      'tail_wag' => tailWag,
      'head_tilt' => headTilt,
      'yawn' => idle,
      'zoomies' => walking,
      _ => idle,
    };
  }
}
