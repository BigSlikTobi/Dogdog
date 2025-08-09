import 'package:flutter/material.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../design_system/modern_shadows.dart';
import '../models/enums.dart';

/// Widget that displays animated milestone progress when approaching checkpoints
class MilestoneProgressWidget extends StatefulWidget {
  final double progress;
  final int questionsRemaining;
  final Checkpoint nextCheckpoint;
  final bool showUrgency;
  final VoidCallback? onAnimationComplete;

  const MilestoneProgressWidget({
    super.key,
    required this.progress,
    required this.questionsRemaining,
    required this.nextCheckpoint,
    this.showUrgency = false,
    this.onAnimationComplete,
  });

  @override
  State<MilestoneProgressWidget> createState() =>
      _MilestoneProgressWidgetState();
}

class _MilestoneProgressWidgetState extends State<MilestoneProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation =
        Tween<double>(begin: _currentProgress, end: widget.progress).animate(
          CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _progressController.forward();

    if (widget.showUrgency) {
      _pulseController.repeat(reverse: true);
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MilestoneProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.progress != oldWidget.progress) {
      _progressAnimation =
          Tween<double>(begin: _currentProgress, end: widget.progress).animate(
            CurvedAnimation(
              parent: _progressController,
              curve: Curves.easeInOut,
            ),
          );

      _progressController.reset();
      _progressController.forward();
    }

    if (widget.showUrgency && !oldWidget.showUrgency) {
      _pulseController.repeat(reverse: true);
      _glowController.repeat(reverse: true);
    } else if (!widget.showUrgency && oldWidget.showUrgency) {
      _pulseController.stop();
      _glowController.stop();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Color _getProgressColor() {
    if (widget.progress >= 0.8) {
      return ModernColors.success;
    } else if (widget.progress >= 0.6) {
      return ModernColors.warning;
    } else {
      return ModernColors.primaryPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _progressAnimation,
        _pulseAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        _currentProgress = _progressAnimation.value;
        final progressColor = _getProgressColor();

        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            margin: ModernSpacing.paddingHorizontalLG.add(
              ModernSpacing.paddingVerticalXS,
            ),
            padding: ModernSpacing.paddingMD,
            decoration: BoxDecoration(
              color: ModernColors.cardBackground,
              borderRadius: ModernSpacing.borderRadiusMedium,
              border: Border.all(
                color: progressColor.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: widget.showUrgency
                  ? [
                      BoxShadow(
                        color: progressColor.withValues(
                          alpha: 0.4 * _glowAnimation.value,
                        ),
                        blurRadius: 8 + (4 * _glowAnimation.value),
                        spreadRadius: 2 * _glowAnimation.value,
                      ),
                    ]
                  : ModernShadows.small,
            ),
            child: Column(
              children: [
                // Header with checkpoint info
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: progressColor,
                        shape: BoxShape.circle,
                        boxShadow: ModernShadows.small,
                      ),
                      child: Icon(
                        Icons.flag_rounded,
                        color: ModernColors.textOnDark,
                        size: 14,
                      ),
                    ),
                    SizedBox(width: ModernSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next: ${widget.nextCheckpoint.displayName}',
                            style: ModernTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: progressColor,
                            ),
                          ),
                          Text(
                            '${widget.questionsRemaining} questions remaining',
                            style: ModernTypography.caption.copyWith(
                              color: ModernColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${(_currentProgress * 100).round()}%',
                      style: ModernTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: ModernSpacing.sm),

                // Animated progress bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: ModernColors.surfaceLight,
                    borderRadius: ModernSpacing.borderRadiusSmall,
                  ),
                  child: Stack(
                    children: [
                      // Background progress
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: ModernColors.surfaceLight,
                          borderRadius: ModernSpacing.borderRadiusSmall,
                        ),
                      ),

                      // Animated progress fill
                      ClipRRect(
                        borderRadius: ModernSpacing.borderRadiusSmall,
                        child: Container(
                          width:
                              MediaQuery.of(context).size.width *
                              _currentProgress,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                progressColor,
                                progressColor.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: ModernSpacing.borderRadiusSmall,
                            boxShadow: widget.showUrgency
                                ? [
                                    BoxShadow(
                                      color: progressColor.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Urgency message
                if (widget.showUrgency) ...[
                  SizedBox(height: ModernSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.whatshot_rounded,
                        color: ModernColors.warning,
                        size: 16,
                      ),
                      SizedBox(width: ModernSpacing.xs),
                      Text(
                        'Almost there!',
                        style: ModernTypography.caption.copyWith(
                          color: ModernColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
