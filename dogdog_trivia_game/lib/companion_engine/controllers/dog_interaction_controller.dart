import 'package:flutter/material.dart';
import 'dog_animation_controller.dart';
import '../models/dog_animation_state.dart';

/// Gesture-to-animation state machine.
///
/// Receives raw Flutter gesture events from the [GestureDetector] in
/// [AnimatedDogWidget] and translates them into calls on [DogAnimationController].
///
/// Priority order (highest to lowest):
///   1. petting (long press held down)
///   2. tap impulse (short tap — quickly resolves)
///   3. drag / walking
///   4. mood state from [CompanionController]
class DogInteractionController {
  DogInteractionController({required this.animationController});

  final DogAnimationController animationController;

  bool _isPetting = false;

  // ─── Gesture handlers ────────────────────────────────────────────────────

  void onTap() {
    if (_isPetting) return;
    animationController.triggerTap();
  }

  void onLongPressStart(LongPressStartDetails details) {
    _isPetting = true;
    animationController.triggerHold();
  }

  void onLongPressEnd(LongPressEndDetails details) {
    _isPetting = false;
    animationController.triggerRelease();
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (_isPetting) return; // petting takes priority over walking
    final dx = details.delta.dx;
    animationController.setWalkVelocity(dx);
  }

  void onPanEnd(DragEndDetails details) {
    if (_isPetting) return;
    animationController.triggerRelease();
  }

  /// Routes a [CompanionMood.animationKey] string to the appropriate
  /// animation state, unless a higher-priority gesture is active.
  void applyMoodState(String moodKey) {
    if (_isPetting) return;
    final next = DogAnimationState.fromMoodKey(moodKey);
    animationController.setAnimationState(next);
  }

  void dispose() {
    // Nothing to dispose here; the animationController lifetime is managed
    // by the widget that owns it.
  }
}
