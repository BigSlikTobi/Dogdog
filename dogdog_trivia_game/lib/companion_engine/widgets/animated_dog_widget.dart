import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../controllers/dog_animation_controller.dart';
import '../controllers/dog_interaction_controller.dart';
import '../flame/dog_game.dart';
import '../models/skeleton_configs/skeleton_config_factory.dart';
import '../../models/companion_enums.dart';

/// A self-contained Flutter widget that renders a procedurally animated
/// companion dog using the Flame game engine.
///
/// Drop this widget anywhere in the widget tree.  It:
///   1. Resolves [breed] → [BreedSkeletonConfig] via [SkeletonConfigFactory]
///   2. Creates a [DogAnimationController] (pure math, breed-agnostic)
///   3. Creates a [DogInteractionController] (gesture state machine)
///   4. Hosts a [DogGame] inside [GameWidget]
///   5. Wraps everything in a [GestureDetector] for tap / drag / long-press
///
/// Example:
/// ```dart
/// AnimatedDogWidget(
///   breed: CompanionBreed.dachshund,
///   size: 200,
///   moodKey: companion.mood.animationKey,
/// )
/// ```
class AnimatedDogWidget extends StatefulWidget {
  const AnimatedDogWidget({
    super.key,
    required this.breed,
    this.size = 200.0,
    this.moodKey,
  });

  /// The companion breed to display.
  final CompanionBreed breed;

  /// Width and height of the game canvas in logical pixels.
  final double size;

  /// Optional mood animation key from [CompanionMood.animationKey].
  /// When provided, sets the initial (and ongoing) animation state.
  final String? moodKey;

  @override
  State<AnimatedDogWidget> createState() => _AnimatedDogWidgetState();
}

class _AnimatedDogWidgetState extends State<AnimatedDogWidget>
    with TickerProviderStateMixin {
  late DogAnimationController _animCtrl;
  late DogInteractionController _interCtrl;
  late DogGame _dogGame;

  @override
  void initState() {
    super.initState();
    _buildControllers();
  }

  void _buildControllers() {
    final skeleton = SkeletonConfigFactory.forBreed(widget.breed);

    _animCtrl = DogAnimationController(
      skeleton: skeleton,
      vsync: this,
    );

    _interCtrl = DogInteractionController(animationController: _animCtrl);

    // Apply initial mood state if provided
    if (widget.moodKey != null) {
      _interCtrl.applyMoodState(widget.moodKey!);
    }

    _dogGame = DogGame(
      skeleton: skeleton,
      animController: _animCtrl,
    );
  }

  @override
  void didUpdateWidget(AnimatedDogWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.breed != widget.breed) {
      // Breed changed: tear down old controllers and rebuild
      _interCtrl.dispose();
      _animCtrl.dispose();
      _buildControllers();
      setState(() {});
      return;
    }

    if (widget.moodKey != null && oldWidget.moodKey != widget.moodKey) {
      _interCtrl.applyMoodState(widget.moodKey!);
    }
  }

  @override
  void dispose() {
    _interCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // ─── Gesture callbacks ────────────────────────────────────────────────────

  void _onTap() => _interCtrl.onTap();

  void _onLongPressStart(LongPressStartDetails details) =>
      _interCtrl.onLongPressStart(details);

  void _onLongPressEnd(LongPressEndDetails details) =>
      _interCtrl.onLongPressEnd(details);

  void _onPanUpdate(DragUpdateDetails details) =>
      _interCtrl.onPanUpdate(details);

  void _onPanEnd(DragEndDetails details) => _interCtrl.onPanEnd(details);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: GestureDetector(
        onTap: _onTap,
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: GameWidget(game: _dogGame),
      ),
    );
  }
}
