import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/dog_skeleton.dart';
import '../models/dog_animation_state.dart';
import '../models/dog_bone_transform.dart';

/// Pure-math animation controller for a companion dog skeleton.
///
/// All sinusoidal walk/idle/sit calculations live here. The controller has
/// **zero knowledge of any specific breed** — it receives breed proportions
/// through [DogSkeleton] and uses [skeleton.animationSpeedMultiplier] to
/// scale timing. The [DogSkeletonComponent] reads [transform] each frame and
/// positions bones accordingly.
///
/// Usage:
/// ```dart
/// final ctrl = DogAnimationController(skeleton: config, vsync: this);
/// // In the Flame onUpdate callback:
/// ctrl.tick(dt);                 // advances internal time by dt seconds
/// final bones = ctrl.transform;  // read the latest snapshot
/// ```
class DogAnimationController extends ChangeNotifier {
  DogAnimationController({
    required this.skeleton,
    required TickerProvider vsync,
  }) {
    _ticker = vsync.createTicker(_onTick);
    _ticker.start();
  }

  final DogSkeleton skeleton;

  DogAnimationState _state = DogAnimationState.idle;
  DogBoneTransform _transform = DogBoneTransform.neutral;
  double _elapsedTime = 0.0;
  double _walkVelocity = 0.0;

  DogAnimationState get state => _state;
  DogBoneTransform get transform => _transform;

  // ─── Public API ────────────────────────────────────────────────────────────

  void setAnimationState(DogAnimationState next) {
    if (_state == next) return;
    _state = next;
    notifyListeners();
  }

  /// Drives the walking direction. Positive = right, negative = left.
  void setWalkVelocity(double dx) {
    _walkVelocity = dx;
    if (dx > 0) {
      setAnimationState(DogAnimationState.walking);
    } else if (dx < 0) {
      setAnimationState(DogAnimationState.walking);
    }
    // dx == 0: caller decides whether to keep walking or go idle
  }

  void triggerTap() {
    setAnimationState(DogAnimationState.tailWag);
  }

  void triggerHold() {
    setAnimationState(DogAnimationState.petting);
  }

  void triggerRelease() {
    setAnimationState(DogAnimationState.idle);
    _walkVelocity = 0.0;
  }

  /// Advances the animation clock by [dt] seconds and recomputes [transform].
  ///
  /// This is called automatically by the internal Ticker (via [_onTick]) and
  /// can also be called directly in tests to advance to a specific time.
  void tick(double dt) {
    _elapsedTime += dt;
    _transform = _computeTransform(_elapsedTime);
  }

  // ─── Private: Ticker callback ───────────────────────────────────────────

  late final Ticker _ticker;

  void _onTick(Duration elapsed) {
    final seconds = elapsed.inMicroseconds / 1000000.0;
    _transform = _computeTransform(seconds);
    notifyListeners();
  }

  // ─── Private: Math ───────────────────────────────────────────────────────

  DogBoneTransform _computeTransform(double t) {
    return switch (_state) {
      DogAnimationState.idle => _computeIdle(t),
      DogAnimationState.walking => _computeWalk(t),
      DogAnimationState.sitting => _computeSit(t),
      DogAnimationState.tailWag => _computeTailWag(t),
      DogAnimationState.headTilt => _computeHeadTilt(t),
      DogAnimationState.petting => _computePetting(t),
      DogAnimationState.zoomies => _computeZoomies(t),
      DogAnimationState.sleeping => _computeSleeping(t),
    };
  }

  double get _spd => skeleton.animationSpeedMultiplier;

  // ── Idle: gentle breathing bob ─────────────────────────────────────────

  DogBoneTransform _computeIdle(double t) {
    final breathFreq = 1.2 * _spd;
    final breathAmp = 1.5; // pixels
    final tailFreq = 1.5 * _spd;
    final tailAmp = 0.30; // radians

    return DogBoneTransform(
      torsoAngle: 0.0,
      headAngle: 0.0,
      tailAngle: sin(2 * pi * tailFreq * t) * tailAmp,
      frontLeftLegAngle: 0.0,
      frontRightLegAngle: 0.0,
      backLeftLegAngle: 0.0,
      backRightLegAngle: 0.0,
      frontLeftKneeAngle: 0.0,
      frontRightKneeAngle: 0.0,
      backLeftKneeAngle: 0.0,
      backRightKneeAngle: 0.0,
      verticalOffset: (1 + sin(2 * pi * breathFreq * t)) * breathAmp,
      isFacingRight: _walkVelocity >= 0,
    );
  }

  // ── Walk: diagonal gait — FR+BL vs FL+BR ──────────────────────────────

  DogBoneTransform _computeWalk(double t) {
    final freq = 2.0 * _spd; // cycles per second
    final legAmp = 0.45; // radians peak swing
    final kneeAmp = 0.25;
    final torsoAmp = 0.04;
    final bounceAmp = 2.0; // pixels

    final phase = 2 * pi * freq * t;

    // Diagonal gait: frontLeft and backRight swing together (+phase);
    //                frontRight and backLeft swing together (−phase).
    final swing = sin(phase);

    final frontLeft = swing * legAmp;
    final frontRight = -swing * legAmp;
    final backLeft = -swing * legAmp;
    final backRight = swing * legAmp;

    // Knees bend when the leg is swinging forward (positive phase)
    final frontLeftKnee = max(0.0, sin(phase + pi / 4) * kneeAmp);
    final frontRightKnee = max(0.0, sin(phase + pi + pi / 4) * kneeAmp);
    final backLeftKnee = max(0.0, sin(phase + pi + pi / 4) * kneeAmp);
    final backRightKnee = max(0.0, sin(phase + pi / 4) * kneeAmp);

    return DogBoneTransform(
      torsoAngle: sin(phase * 2) * torsoAmp,
      headAngle: sin(phase * 2) * 0.05,
      tailAngle: sin(phase) * 0.5,
      frontLeftLegAngle: frontLeft,
      frontRightLegAngle: frontRight,
      backLeftLegAngle: backLeft,
      backRightLegAngle: backRight,
      frontLeftKneeAngle: frontLeftKnee,
      frontRightKneeAngle: frontRightKnee,
      backLeftKneeAngle: backLeftKnee,
      backRightKneeAngle: backRightKnee,
      verticalOffset: (1 + sin(phase * 2)) * bounceAmp,
      isFacingRight: _walkVelocity >= 0,
    );
  }

  // ── Sit: static pose with minor breathing ─────────────────────────────

  DogBoneTransform _computeSit(double t) {
    final breathAmp = 0.8;
    final breathFreq = 1.0 * _spd;

    return DogBoneTransform(
      torsoAngle: 0.08, // slight forward lean
      headAngle: -0.05, // slight look-up
      tailAngle: sin(2 * pi * breathFreq * t) * 0.40,
      frontLeftLegAngle: 0.0,
      frontRightLegAngle: 0.0,
      backLeftLegAngle: 1.20, // folded under body
      backRightLegAngle: 1.20,
      frontLeftKneeAngle: 0.0,
      frontRightKneeAngle: 0.0,
      backLeftKneeAngle: 0.80,
      backRightKneeAngle: 0.80,
      verticalOffset: (1 + sin(2 * pi * breathFreq * t)) * breathAmp,
      isFacingRight: _walkVelocity >= 0,
    );
  }

  // ── Tail wag: fast lateral tail with body shimmy ──────────────────────

  DogBoneTransform _computeTailWag(double t) {
    final wagFreq = 4.0 * _spd;
    final wagAmp = 0.90;

    return DogBoneTransform(
      torsoAngle: sin(2 * pi * wagFreq / 2 * t) * 0.06,
      headAngle: 0.0,
      tailAngle: sin(2 * pi * wagFreq * t) * wagAmp,
      frontLeftLegAngle: 0.0,
      frontRightLegAngle: 0.0,
      backLeftLegAngle: 0.0,
      backRightLegAngle: 0.0,
      frontLeftKneeAngle: 0.0,
      frontRightKneeAngle: 0.0,
      backLeftKneeAngle: 0.0,
      backRightKneeAngle: 0.0,
      verticalOffset: (1 + sin(2 * pi * wagFreq / 2 * t)) * 1.5,
      isFacingRight: true,
    );
  }

  // ── Head tilt: single rotation of the head ────────────────────────────

  DogBoneTransform _computeHeadTilt(double t) {
    final tiltAmp = 0.35; // radians
    final tiltFreq = 0.5 * _spd;

    return DogBoneTransform(
      torsoAngle: 0.0,
      headAngle: sin(2 * pi * tiltFreq * t) * tiltAmp,
      tailAngle: sin(2 * pi * 1.5 * _spd * t) * 0.30,
      frontLeftLegAngle: 0.0,
      frontRightLegAngle: 0.0,
      backLeftLegAngle: 0.0,
      backRightLegAngle: 0.0,
      frontLeftKneeAngle: 0.0,
      frontRightKneeAngle: 0.0,
      backLeftKneeAngle: 0.0,
      backRightKneeAngle: 0.0,
      verticalOffset: 1.5,
      isFacingRight: true,
    );
  }

  // ── Petting: lean into hand, tail at max wag ──────────────────────────

  DogBoneTransform _computePetting(double t) {
    final wagAmp = 1.10;
    final wagFreq = 5.0 * _spd;
    final leanAngle = -0.15; // lean left toward hand

    return DogBoneTransform(
      torsoAngle: leanAngle,
      headAngle: -0.10,
      tailAngle: sin(2 * pi * wagFreq * t) * wagAmp,
      frontLeftLegAngle: 0.0,
      frontRightLegAngle: 0.0,
      backLeftLegAngle: 0.0,
      backRightLegAngle: 0.0,
      frontLeftKneeAngle: 0.0,
      frontRightKneeAngle: 0.0,
      backLeftKneeAngle: 0.0,
      backRightKneeAngle: 0.0,
      verticalOffset: 2.0,
      isFacingRight: true,
    );
  }

  // ── Zoomies: fast chaotic gait ────────────────────────────────────────

  DogBoneTransform _computeZoomies(double t) {
    final freq = 4.0 * _spd;
    final legAmp = 0.60;
    final phase = 2 * pi * freq * t;
    final swing = sin(phase);

    return DogBoneTransform(
      torsoAngle: sin(phase * 2) * 0.10,
      headAngle: sin(phase * 2) * 0.08,
      tailAngle: sin(phase * 3) * 0.80,
      frontLeftLegAngle: swing * legAmp,
      frontRightLegAngle: -swing * legAmp,
      backLeftLegAngle: -swing * legAmp,
      backRightLegAngle: swing * legAmp,
      frontLeftKneeAngle: max(0.0, sin(phase + pi / 4) * 0.40),
      frontRightKneeAngle: max(0.0, sin(phase + pi + pi / 4) * 0.40),
      backLeftKneeAngle: max(0.0, sin(phase + pi + pi / 4) * 0.40),
      backRightKneeAngle: max(0.0, sin(phase + pi / 4) * 0.40),
      verticalOffset: (1 + sin(phase * 2)) * 4.0,
      isFacingRight: _walkVelocity >= 0,
    );
  }

  // ── Sleeping: minimal movement ────────────────────────────────────────

  DogBoneTransform _computeSleeping(double t) {
    final breathFreq = 0.4 * _spd;
    final breathAmp = 1.0;

    return DogBoneTransform(
      torsoAngle: 0.12,
      headAngle: 0.20, // droop forward
      tailAngle: sin(2 * pi * breathFreq * t) * 0.10,
      frontLeftLegAngle: 0.0,
      frontRightLegAngle: 0.0,
      backLeftLegAngle: 0.60,
      backRightLegAngle: 0.60,
      frontLeftKneeAngle: 0.0,
      frontRightKneeAngle: 0.0,
      backLeftKneeAngle: 0.40,
      backRightKneeAngle: 0.40,
      verticalOffset: (1 + sin(2 * pi * breathFreq * t)) * breathAmp,
      isFacingRight: true,
    );
  }

  @override
  void dispose() {
    _ticker.stop();
    _ticker.dispose();
    super.dispose();
  }
}
