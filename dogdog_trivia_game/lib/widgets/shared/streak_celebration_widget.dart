import 'package:flutter/material.dart';
import '../../design_system/modern_colors.dart';
import '../../design_system/modern_typography.dart';
import '../../design_system/modern_spacing.dart';
import '../../design_system/modern_shadows.dart';

/// Widget that displays streak celebration animations with multiplier feedback
class StreakCelebrationWidget extends StatefulWidget {
  final int streakCount;
  final int multiplier;
  final VoidCallback? onAnimationComplete;
  final Duration duration;

  const StreakCelebrationWidget({
    super.key,
    required this.streakCount,
    required this.multiplier,
    this.onAnimationComplete,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<StreakCelebrationWidget> createState() =>
      _StreakCelebrationWidgetState();
}

class _StreakCelebrationWidgetState extends State<StreakCelebrationWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _scaleController.forward();
    _pulseController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 1000));

    await _fadeController.forward();
    widget.onAnimationComplete?.call();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _fadeAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: ModernSpacing.paddingLG,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: ModernColors.yellowGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: ModernSpacing.borderRadiusLarge,
                  boxShadow: ModernShadows.large,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          color: ModernColors.textOnDark,
                          size: 32,
                        ),
                        SizedBox(width: ModernSpacing.sm),
                        Text(
                          'STREAK!',
                          style: ModernTypography.headingMedium.copyWith(
                            color: ModernColors.textOnDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ModernSpacing.xs),
                    Text(
                      '${widget.streakCount} in a row',
                      style: ModernTypography.bodyMedium.copyWith(
                        color: ModernColors.textOnDark,
                      ),
                    ),
                    if (widget.multiplier > 1) ...[
                      SizedBox(height: ModernSpacing.xs),
                      Container(
                        padding: ModernSpacing.paddingMD,
                        decoration: BoxDecoration(
                          color: ModernColors.textOnDark.withValues(alpha: 0.2),
                          borderRadius: ModernSpacing.borderRadiusMedium,
                        ),
                        child: Text(
                          '${widget.multiplier}x MULTIPLIER',
                          style: ModernTypography.bodySmall.copyWith(
                            color: ModernColors.textOnDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
