import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/breed_skeleton_config.dart';
import '../../models/dog_bone_transform.dart';
import '../../models/dog_expression.dart';

/// Duolingo-style CustomPainter for a procedurally animated companion dog.
///
/// Every shape is drawn twice — first as a thick dark outline, then filled
/// with a radial-gradient colour — giving the clay-toy feel.  The face is
/// fully expression-driven: eyes, mouth, tongue, blush, and eyebrows all
/// change per [DogExpression].
///
/// Coordinate origin is the top-left corner of the supplied [Size].
/// The dog is centred horizontally and sits ~60% down the canvas so there
/// is room for an overhead jump arc.
class DogBodyPainter extends CustomPainter {
  const DogBodyPainter({
    required this.config,
    required this.transform,
    required this.expression,
  });

  final BreedSkeletonConfig config;
  final DogBoneTransform transform;
  final DogExpression expression;

  // ─── CustomPainter ────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final m = _Metrics(size, config);

    canvas.save();

    // Flip canvas horizontally when facing left
    if (!transform.isFacingRight) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    // Centre of the scene
    final cx = size.width / 2;
    final cy = size.height * 0.60 - transform.verticalOffset;

    canvas.translate(cx, cy);
    canvas.rotate(transform.torsoAngle);

    // ── Layer 0: back legs ────────────────────────────────────────────────
    _drawLeg(canvas, m,
        angle: transform.backLeftLegAngle,
        kneeAngle: transform.backLeftKneeAngle,
        offsetX: -m.torsoW * 0.28,
        isBack: true);
    _drawLeg(canvas, m,
        angle: transform.backRightLegAngle,
        kneeAngle: transform.backRightKneeAngle,
        offsetX: m.torsoW * 0.28,
        isBack: true);

    // ── Layer 1: torso ────────────────────────────────────────────────────
    _drawTorso(canvas, m);

    // ── Layer 2: tail ─────────────────────────────────────────────────────
    _drawTail(canvas, m);

    // ── Layer 3: neck + head ──────────────────────────────────────────────
    _drawHead(canvas, m);

    // ── Layer 4: front legs ───────────────────────────────────────────────
    _drawLeg(canvas, m,
        angle: transform.frontLeftLegAngle,
        kneeAngle: transform.frontLeftKneeAngle,
        offsetX: -m.torsoW * 0.25,
        isBack: false);
    _drawLeg(canvas, m,
        angle: transform.frontRightLegAngle,
        kneeAngle: transform.frontRightKneeAngle,
        offsetX: m.torsoW * 0.25,
        isBack: false);

    canvas.restore();
  }

  @override
  bool shouldRepaint(DogBodyPainter old) =>
      old.expression != expression ||
      old.transform != transform ||
      old.config != config;

  // ─── Torso ────────────────────────────────────────────────────────────────

  void _drawTorso(Canvas canvas, _Metrics m) {
    final rect = Rect.fromCenter(
        center: const Offset(0, 0), width: m.torsoW, height: m.torsoH);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(m.torsoH * 0.46));

    // Outline
    canvas.drawRRect(rrect, _outlinePaint(m.outlineW));

    // Filled gradient body
    canvas.drawRRect(rrect, _bodyFillPaint(config.primaryCoatColor, m));

    // Belly patch (secondary colour, lower half)
    final bellyRect = Rect.fromCenter(
      center: Offset(0, m.torsoH * 0.18),
      width: m.torsoW * 0.60,
      height: m.torsoH * 0.55,
    );
    canvas.drawOval(bellyRect,
        Paint()..color = config.secondaryCoatColor);

    // German Shepherd saddle overlay
    if (config.breedKey == 'germanShepherd') {
      _drawShepherdSaddle(canvas, m);
    }
  }

  void _drawShepherdSaddle(Canvas canvas, _Metrics m) {
    // Dark saddle across the top of the torso
    final saddleRect = Rect.fromCenter(
      center: Offset(0, -m.torsoH * 0.05),
      width: m.torsoW * 0.75,
      height: m.torsoH * 0.55,
    );
    canvas.drawOval(
      saddleRect,
      Paint()..color = const Color(0xFF1A1A1A).withValues(alpha: 0.70),
    );
  }

  // ─── Head ─────────────────────────────────────────────────────────────────

  void _drawHead(Canvas canvas, _Metrics m) {
    // Neck joint: front-upper area of the torso
    final neckX = -m.torsoW * 0.36;
    final neckY = -m.torsoH * 0.32;

    canvas.save();
    canvas.translate(neckX, neckY);
    canvas.rotate(transform.headAngle - 0.12);

    final hc = Offset(0, -m.headR * 0.90); // head centre

    // ── Ears (behind head) ──────────────────────────────────────────────
    _drawEars(canvas, m, hc);

    // ── Head circle ──────────────────────────────────────────────────────
    final headCircle = Rect.fromCircle(center: hc, radius: m.headR);
    canvas.drawOval(headCircle, _outlinePaint(m.outlineW));
    canvas.drawOval(headCircle, _bodyFillPaint(config.primaryCoatColor, m));

    // Muzzle patch
    _drawMuzzle(canvas, m, hc);

    // ── Face ──────────────────────────────────────────────────────────────
    _drawFace(canvas, m, hc);

    canvas.restore();
  }

  void _drawMuzzle(Canvas canvas, _Metrics m, Offset hc) {
    final muzzleCenter = Offset(hc.dx - m.headR * 0.52, hc.dy + m.headR * 0.10);
    final muzzleW = m.headR * (config.hasFlatFace ? 0.60 : 0.80);
    final muzzleH = muzzleW * 0.65;

    final muzzleRect = Rect.fromCenter(
        center: muzzleCenter, width: muzzleW, height: muzzleH);

    canvas.drawOval(muzzleRect, _outlinePaint(m.outlineW * 0.7));
    canvas.drawOval(muzzleRect, Paint()..color = config.secondaryCoatColor);

    // Nose
    final noseCenter = Offset(
        muzzleCenter.dx - muzzleW * 0.38, muzzleCenter.dy - muzzleH * 0.15);
    canvas.drawOval(
      Rect.fromCenter(
          center: noseCenter,
          width: m.headR * 0.28,
          height: m.headR * 0.20),
      Paint()..color = config.accentColor,
    );
  }

  void _drawEars(Canvas canvas, _Metrics m, Offset hc) {
    for (final side in [-1.0, 1.0]) {
      _drawSingleEar(canvas, m, hc, side);
    }
  }

  void _drawSingleEar(Canvas canvas, _Metrics m, Offset hc, double side) {
    final earX = hc.dx + side * m.headR * 0.78;
    final earY = hc.dy - m.headR * 0.65;

    canvas.save();
    canvas.translate(earX, earY);

    if (config.earsFloppy) {
      // Droopy teardrop shape — rotated slightly outward
      canvas.rotate(side * 0.20);
      final earPath = Path();
      final ew = m.earW;
      final eh = m.earH;
      earPath.addOval(
          Rect.fromCenter(center: Offset(0, eh * 0.30), width: ew, height: eh));
      canvas.drawPath(earPath, _outlinePaint(m.outlineW * 0.8));
      canvas.drawPath(
          earPath, Paint()..color = config.primaryCoatColor);
      // Inner ear
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(0, eh * 0.35),
            width: ew * 0.55,
            height: eh * 0.60),
        Paint()..color = config.accentColor.withValues(alpha: 0.25),
      );
    } else {
      // Erect triangular ear
      canvas.rotate(side * 0.08);
      final earPath = Path()
        ..moveTo(0, -m.earH)
        ..lineTo(-m.earW * 0.50, 0)
        ..lineTo(m.earW * 0.50, 0)
        ..close();
      canvas.drawPath(earPath, _outlinePaint(m.outlineW * 0.8));
      canvas.drawPath(earPath, Paint()..color = config.primaryCoatColor);
      // Inner ear triangle
      final innerPath = Path()
        ..moveTo(0, -m.earH * 0.75)
        ..lineTo(-m.earW * 0.30, -m.earH * 0.05)
        ..lineTo(m.earW * 0.30, -m.earH * 0.05)
        ..close();
      canvas.drawPath(
          innerPath,
          Paint()..color = config.accentColor.withValues(alpha: 0.30));
    }

    canvas.restore();
  }

  // ─── Face ─────────────────────────────────────────────────────────────────

  void _drawFace(Canvas canvas, _Metrics m, Offset hc) {
    final eyeR = m.headR * 0.22 * expression.eyeScale;
    final leftEyeCenter = Offset(hc.dx - m.headR * 0.28, hc.dy - m.headR * 0.22);
    final rightEyeCenter = Offset(hc.dx + m.headR * 0.08, hc.dy - m.headR * 0.22);

    // Eyebrows
    _drawEyebrows(canvas, m, hc, leftEyeCenter, rightEyeCenter, eyeR);

    if (expression.eyesOpen) {
      _drawOpenEye(canvas, leftEyeCenter, eyeR, tilt: expression == DogExpression.curious ? 0.15 : 0.0);
      _drawOpenEye(canvas, rightEyeCenter, eyeR, tilt: expression == DogExpression.curious ? -0.08 : 0.0);
    } else {
      // Sleepy: closed arc
      _drawClosedEye(canvas, leftEyeCenter, eyeR);
      _drawClosedEye(canvas, rightEyeCenter, eyeR);
    }

    // Mouth
    _drawMouth(canvas, m, hc);

    // Tongue
    if (expression.showsTongue) {
      _drawTongue(canvas, m, hc);
    }

    // Blush
    if (expression.showsBlush) {
      _drawBlush(canvas, m, hc);
    }
  }

  void _drawOpenEye(Canvas canvas, Offset center, double radius, {double tilt = 0.0}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tilt);

    // White sclera
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radius * 2.1, height: radius * 2.0),
      Paint()..color = Colors.white,
    );
    // Outline
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radius * 2.1, height: radius * 2.0),
      _outlinePaint(radius * 0.18),
    );

    // Iris
    final irisColor = const Color(0xFF4A2800); // warm dark brown
    canvas.drawCircle(Offset.zero, radius * 0.75, Paint()..color = irisColor);

    // Pupil
    canvas.drawCircle(Offset(radius * 0.05, radius * 0.05), radius * 0.45,
        Paint()..color = const Color(0xFF0A0A0A));

    // Shine dot
    canvas.drawCircle(Offset(-radius * 0.22, -radius * 0.22), radius * 0.18,
        Paint()..color = Colors.white);

    // Excited: second smaller shine
    if (expression == DogExpression.excited) {
      canvas.drawCircle(Offset(radius * 0.18, -radius * 0.30), radius * 0.10,
          Paint()..color = Colors.white);
    }

    canvas.restore();
  }

  void _drawClosedEye(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = const Color(0xFF2C1A00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.35
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(center.dx - radius, center.dy);
    path.quadraticBezierTo(center.dx, center.dy + radius * 0.8, center.dx + radius, center.dy);
    canvas.drawPath(path, paint);
  }

  void _drawEyebrows(Canvas canvas, _Metrics m, Offset hc,
      Offset leftEye, Offset rightEye, double eyeR) {
    final browPaint = Paint()
      ..color = config.accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = eyeR * 0.30
      ..strokeCap = StrokeCap.round;

    final browY = eyeR * 1.6;
    final browW = eyeR * 1.10;

    // Left brow
    canvas.save();
    canvas.translate(leftEye.dx, leftEye.dy - browY);
    if (expression == DogExpression.curious) canvas.rotate(-0.25);
    if (expression == DogExpression.excited) canvas.rotate(0.15);
    canvas.drawLine(Offset(-browW / 2, 0), Offset(browW / 2, 0), browPaint);
    canvas.restore();

    // Right brow
    canvas.save();
    canvas.translate(rightEye.dx, rightEye.dy - browY);
    if (expression == DogExpression.curious) canvas.rotate(0.10);
    if (expression == DogExpression.excited) canvas.rotate(-0.15);
    canvas.drawLine(Offset(-browW / 2, 0), Offset(browW / 2, 0), browPaint);
    canvas.restore();
  }

  void _drawMouth(Canvas canvas, _Metrics m, Offset hc) {
    final mouthY = hc.dy + m.headR * 0.28;
    final mouthX = hc.dx - m.headR * 0.48;
    final mouthW = m.headR * 0.55;
    final open = expression.mouthOpenness;

    final paint = Paint()
      ..color = const Color(0xFF2C1A00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = m.headR * 0.10
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (open < 0.1) {
      // Gentle smile arc
      path.moveTo(mouthX, mouthY);
      path.quadraticBezierTo(
          mouthX + mouthW * 0.5, mouthY + m.headR * 0.14,
          mouthX + mouthW, mouthY);
    } else {
      // Open mouth: U shape filled with dark pink
      final fillPath = Path()
        ..moveTo(mouthX, mouthY)
        ..quadraticBezierTo(
            mouthX + mouthW * 0.5, mouthY + m.headR * (0.15 + open * 0.40),
            mouthX + mouthW, mouthY)
        ..lineTo(mouthX + mouthW, mouthY)
        ..quadraticBezierTo(
            mouthX + mouthW * 0.5, mouthY + m.headR * (0.05 + open * 0.35),
            mouthX, mouthY)
        ..close();
      canvas.drawPath(
          fillPath,
          Paint()..color = const Color(0xFF8B1A1A).withValues(alpha: 0.85));
      // Outline of open mouth
      path.moveTo(mouthX, mouthY);
      path.quadraticBezierTo(
          mouthX + mouthW * 0.5, mouthY + m.headR * (0.15 + open * 0.40),
          mouthX + mouthW, mouthY);
    }
    canvas.drawPath(path, paint);
  }

  void _drawTongue(Canvas canvas, _Metrics m, Offset hc) {
    final tongueX = hc.dx - m.headR * 0.22;
    final tongueY = hc.dy + m.headR * 0.38;
    final tw = m.headR * 0.32;
    final th = m.headR * 0.30;

    // Tongue body
    canvas.drawOval(
      Rect.fromCenter(center: Offset(tongueX, tongueY), width: tw, height: th),
      Paint()..color = const Color(0xFFE8607A),
    );
    // Tongue crease
    final creasePaint = Paint()
      ..color = const Color(0xFFC04060)
      ..style = PaintingStyle.stroke
      ..strokeWidth = tw * 0.12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(tongueX, tongueY - th * 0.25),
      Offset(tongueX, tongueY + th * 0.30),
      creasePaint,
    );
  }

  void _drawBlush(Canvas canvas, _Metrics m, Offset hc) {
    final blushPaint = Paint()
      ..color = const Color(0xFFFF9999).withValues(alpha: 0.45);
    final br = m.headR * 0.28;
    canvas.drawCircle(Offset(hc.dx - m.headR * 0.70, hc.dy + m.headR * 0.18), br, blushPaint);
    canvas.drawCircle(Offset(hc.dx + m.headR * 0.30, hc.dy + m.headR * 0.18), br, blushPaint);
  }

  // ─── Legs ─────────────────────────────────────────────────────────────────

  void _drawLeg(Canvas canvas, _Metrics m, {
    required double angle,
    required double kneeAngle,
    required double offsetX,
    required bool isBack,
  }) {
    final depth = isBack ? 0.88 : 1.0;
    final legColor = Color.fromRGBO(
      ((config.primaryCoatColor.r * 255.0) * depth).round().clamp(0, 255),
      ((config.primaryCoatColor.g * 255.0) * depth).round().clamp(0, 255),
      ((config.primaryCoatColor.b * 255.0) * depth).round().clamp(0, 255),
      1.0,
    );
    final legOutlineW = m.outlineW * depth;

    final upperLen = m.legLen * 0.52;
    final lowerLen = m.legLen * 0.52;

    canvas.save();
    canvas.translate(offsetX, m.torsoH * 0.40);
    canvas.rotate(angle);

    // Upper leg — thick rounded capsule
    _drawCapsule(canvas, m.legThick * depth, upperLen, legColor, legOutlineW);

    // Lower leg
    canvas.translate(0, upperLen);
    canvas.rotate(kneeAngle);
    _drawCapsule(canvas, m.legThick * depth * 0.88, lowerLen, legColor, legOutlineW);

    // Paw
    canvas.translate(0, lowerLen);
    _drawPaw(canvas, m, depth, legColor, legOutlineW);

    canvas.restore();
  }

  void _drawCapsule(Canvas canvas, double w, double h, Color color, double outlineW) {
    final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(-w / 2, 0, w, h), Radius.circular(w / 2));
    canvas.drawRRect(rect, _outlinePaint(outlineW));
    canvas.drawRRect(rect, Paint()..color = color);
  }

  void _drawPaw(Canvas canvas, _Metrics m, double depth, Color legColor, double outlineW) {
    final pr = m.legThick * depth * 0.75;
    final pawRect = Rect.fromCenter(center: Offset(0, pr * 0.3), width: pr * 2.2, height: pr * 1.6);
    canvas.drawOval(pawRect, _outlinePaint(outlineW));
    canvas.drawOval(pawRect, Paint()..color = config.secondaryCoatColor);

    // Toe lines
    final toePaint = Paint()
      ..color = config.accentColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = outlineW * 0.5
      ..strokeCap = StrokeCap.round;
    for (final dx in [-pr * 0.40, 0.0, pr * 0.40]) {
      canvas.drawLine(
          Offset(dx, pr * 0.0), Offset(dx, pr * 0.9), toePaint);
    }
  }

  // ─── Tail ─────────────────────────────────────────────────────────────────

  void _drawTail(Canvas canvas, _Metrics m) {
    canvas.save();
    canvas.translate(m.torsoW * 0.47, -m.torsoH * 0.05);
    canvas.rotate(transform.tailAngle + (config.tailCurledOverBack ? -pi * 0.55 : pi * 0.12));

    final tailPaint = Paint()
      ..color = config.primaryCoatColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = m.legThick * 1.0
      ..strokeCap = StrokeCap.round;
    final tailOutlinePaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = m.legThick * 1.0 + m.outlineW * 1.4
      ..strokeCap = StrokeCap.round;

    if (config.tailCurledOverBack) {
      final path = Path()
        ..moveTo(0, 0)
        ..cubicTo(m.tailLen * 0.5, -m.tailLen * 0.6, m.tailLen * 0.8, -m.tailLen, 0, -m.tailLen * 1.1);
      canvas.drawPath(path, tailOutlinePaint);
      canvas.drawPath(path, tailPaint);
    } else {
      // Golden Retriever: feathered plume — a slightly thicker curved line
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(m.tailLen * 0.3, -m.tailLen * 0.5, -m.tailLen * 0.1, -m.tailLen);
      canvas.drawPath(path, tailOutlinePaint);
      canvas.drawPath(path, tailPaint);

      // Golden: extra fluffy layer
      if (config.breedKey == 'goldenRetriever') {
        final fluffPaint = Paint()
          ..color = config.primaryCoatColor.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = m.legThick * 1.6
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(path, fluffPaint);
      }
    }

    canvas.restore();
  }

  // ─── Paint helpers ────────────────────────────────────────────────────────

  static Paint _outlinePaint(double width) => Paint()
    ..color = const Color(0xFF1A1A1A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  static Paint _bodyFillPaint(Color base, _Metrics m) {
    // Radial gradient: bright highlight top-left, slightly darker base at bottom
    final highlight = Color.fromRGBO(
      (base.r * 255.0 + 35).clamp(0, 255).round(),
      (base.g * 255.0 + 25).clamp(0, 255).round(),
      (base.b * 255.0 + 10).clamp(0, 255).round(),
      1.0,
    );
    return Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        radius: 0.85,
        colors: [highlight, base],
      ).createShader(
        Rect.fromCenter(
            center: Offset.zero, width: m.torsoW * 1.5, height: m.torsoH * 1.5),
      );
  }
}

// ─── Metrics ──────────────────────────────────────────────────────────────────

/// Pre-computed layout metrics so magic numbers only appear once.
class _Metrics {
  _Metrics(Size size, BreedSkeletonConfig cfg) {
    final ref = size.height * cfg.heightScale;
    torsoH = ref * 0.32;
    torsoW = torsoH * cfg.torsoAspectRatio;
    legLen = ref * cfg.legLengthRatio * 1.1;
    legThick = torsoW * cfg.legThicknessRatio * 0.30;
    headR = torsoH * cfg.headSizeRatio * 0.60;
    earW = headR * 0.50;
    earH = headR * cfg.earHeightRatio * 1.0;
    tailLen = torsoH * cfg.tailLengthRatio * 1.5;
    outlineW = (size.width * 0.018).clamp(2.5, 5.0);
  }

  late final double torsoW;
  late final double torsoH;
  late final double legLen;
  late final double legThick;
  late final double headR;
  late final double earW;
  late final double earH;
  late final double tailLen;
  late final double outlineW;
}
