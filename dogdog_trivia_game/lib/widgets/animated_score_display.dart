import 'package:flutter/material.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../design_system/modern_shadows.dart';

/// Enhanced animated score display with bonus point animations
class AnimatedScoreDisplay extends StatefulWidget {
  final int score;
  final int multiplier;
  final int? bonusPoints;
  final bool showBonusAnimation;
  final VoidCallback? onBonusAnimationComplete;

  const AnimatedScoreDisplay({
    super.key,
    required this.score,
    required this.multiplier,
    this.bonusPoints,
    this.showBonusAnimation = false,
    this.onBonusAnimationComplete,
  });

  @override
  State<AnimatedScoreDisplay> createState() => _AnimatedScoreDisplayState();
}

class _AnimatedScoreDisplayState extends State<AnimatedScoreDisplay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bonusController;
  late AnimationController _multiplierController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _bonusSlideAnimation;
  late Animation<double> _bonusFadeAnimation;
  late Animation<double> _multiplierBounceAnimation;

  int _displayedScore = 0;

  @override
  void initState() {
    super.initState();
    _displayedScore = widget.score;

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _bonusController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _multiplierController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
    );

    _bonusSlideAnimation = Tween<double>(
      begin: 0.0,
      end: -30.0,
    ).animate(CurvedAnimation(parent: _bonusController, curve: Curves.easeOut));

    _bonusFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _bonusController,
        curve: const Interval(0.7, 1.0),
      ),
    );

    _multiplierBounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _multiplierController, curve: Curves.bounceOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedScoreDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate score changes
    if (widget.score != oldWidget.score) {
      _animateScoreChange(oldWidget.score, widget.score);
    }

    // Show bonus animation
    if (widget.showBonusAnimation && !oldWidget.showBonusAnimation) {
      _showBonusAnimation();
    }

    // Animate multiplier changes
    if (widget.multiplier != oldWidget.multiplier) {
      _animateMultiplierChange();
    }
  }

  void _animateScoreChange(int oldScore, int newScore) {
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });

    // Animated counting effect
    final duration = const Duration(milliseconds: 500);
    final steps = 30;
    final stepDuration = duration.inMilliseconds ~/ steps;
    final scoreDiff = newScore - oldScore;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: stepDuration * i), () {
        if (mounted) {
          setState(() {
            _displayedScore = oldScore + ((scoreDiff * i) ~/ steps);
          });
        }
      });
    }
  }

  void _showBonusAnimation() {
    _bonusController.forward().then((_) {
      _bonusController.reset();
      widget.onBonusAnimationComplete?.call();
    });
  }

  void _animateMultiplierChange() {
    _multiplierController.forward().then((_) {
      _multiplierController.reverse();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bonusController.dispose();
    _multiplierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main score display
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: ModernSpacing.paddingVerticalXS.add(
                  ModernSpacing.paddingHorizontalSM,
                ),
                decoration: BoxDecoration(
                  color: ModernColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: ModernSpacing.borderRadiusMedium,
                  border: Border.all(
                    color: ModernColors.primaryBlue.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: _pulseAnimation.value > 1.05
                      ? ModernShadows.medium
                      : ModernShadows.small,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Multiplier badge
                    if (widget.multiplier > 1) ...[
                      AnimatedBuilder(
                        animation: _multiplierBounceAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _multiplierBounceAnimation.value,
                            child: Container(
                              padding: ModernSpacing.paddingVerticalXS.add(
                                ModernSpacing.paddingHorizontalXS,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: ModernColors.yellowGradient,
                                ),
                                borderRadius: ModernSpacing.borderRadiusSmall,
                                boxShadow: ModernShadows.small,
                              ),
                              child: Text(
                                '${widget.multiplier}x',
                                style: ModernTypography.caption.copyWith(
                                  color: ModernColors.textOnDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: ModernSpacing.xs),
                    ],

                    // Score text
                    Text(
                      '$_displayedScore',
                      style: ModernTypography.scoreText.copyWith(
                        fontSize: 20,
                        color: ModernColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Bonus points animation
        if (widget.showBonusAnimation && widget.bonusPoints != null)
          AnimatedBuilder(
            animation: _bonusController,
            builder: (context, child) {
              return Positioned(
                top: _bonusSlideAnimation.value,
                right: 0,
                child: Opacity(
                  opacity: _bonusFadeAnimation.value,
                  child: Container(
                    padding: ModernSpacing.paddingXS,
                    decoration: BoxDecoration(
                      color: ModernColors.success,
                      borderRadius: ModernSpacing.borderRadiusSmall,
                      boxShadow: ModernShadows.small,
                    ),
                    child: Text(
                      '+${widget.bonusPoints}',
                      style: ModernTypography.caption.copyWith(
                        color: ModernColors.textOnDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
