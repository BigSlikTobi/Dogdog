import 'package:flutter/material.dart';
import '../../design_system/modern_colors.dart';
import '../../design_system/modern_typography.dart';
import '../../design_system/modern_spacing.dart';
import '../../design_system/modern_shadows.dart';
import '../../models/breed_adventure/difficulty_phase.dart';

/// Widget that displays score and progress with animations
class ScoreProgressDisplay extends StatefulWidget {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final DifficultyPhase currentPhase;
  final int livesRemaining;
  final double accuracy;
  final bool showAnimations;

  const ScoreProgressDisplay({
    super.key,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.currentPhase,
    this.livesRemaining = 3,
    this.accuracy = 0.0,
    this.showAnimations = true,
  });

  @override
  State<ScoreProgressDisplay> createState() => _ScoreProgressDisplayState();
}

class _ScoreProgressDisplayState extends State<ScoreProgressDisplay>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late AnimationController _progressController;
  late Animation<int> _scoreAnimation;
  late Animation<double> _progressAnimation;

  int _previousScore = 0;
  int _previousCorrectAnswers = 0;

  @override
  void initState() {
    super.initState();

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scoreAnimation = IntTween(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
    );

    _progressAnimation =
        Tween<double>(
          begin: 0.0,
          end: widget.totalQuestions > 0
              ? widget.correctAnswers / widget.totalQuestions
              : 0.0,
        ).animate(
          CurvedAnimation(
            parent: _progressController,
            curve: Curves.easeOutCubic,
          ),
        );

    _previousScore = widget.score;
    _previousCorrectAnswers = widget.correctAnswers;

    if (widget.showAnimations) {
      _scoreController.forward();
      _progressController.forward();
    }
  }

  @override
  void didUpdateWidget(ScoreProgressDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate score changes
    if (widget.score != _previousScore && widget.showAnimations) {
      _scoreAnimation = IntTween(begin: _previousScore, end: widget.score)
          .animate(
            CurvedAnimation(
              parent: _scoreController,
              curve: Curves.easeOutCubic,
            ),
          );

      _scoreController.reset();
      _scoreController.forward();
      _previousScore = widget.score;
    }

    // Animate progress changes
    if (widget.correctAnswers != _previousCorrectAnswers &&
        widget.showAnimations) {
      final newProgress = widget.totalQuestions > 0
          ? widget.correctAnswers / widget.totalQuestions
          : 0.0;

      _progressAnimation =
          Tween<double>(
            begin: _progressAnimation.value,
            end: newProgress,
          ).animate(
            CurvedAnimation(
              parent: _progressController,
              curve: Curves.easeOutCubic,
            ),
          );

      _progressController.reset();
      _progressController.forward();
      _previousCorrectAnswers = widget.correctAnswers;
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Color _getPhaseColor() {
    switch (widget.currentPhase) {
      case DifficultyPhase.beginner:
        return ModernColors.primaryGreen;
      case DifficultyPhase.intermediate:
        return ModernColors.primaryYellow;
      case DifficultyPhase.expert:
        return ModernColors.primaryRed;
    }
  }

  List<Color> _getPhaseGradient() {
    switch (widget.currentPhase) {
      case DifficultyPhase.beginner:
        return ModernColors.greenGradient;
      case DifficultyPhase.intermediate:
        return ModernColors.yellowGradient;
      case DifficultyPhase.expert:
        return ModernColors.redGradient;
    }
  }

  Widget _buildLivesIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isActive = index < widget.livesRemaining;
        return Padding(
          padding: EdgeInsets.only(right: ModernSpacing.sm),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isActive
                  ? ModernColors.error.withValues(alpha: 0.1)
                  : ModernColors.textLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? ModernColors.error.withValues(alpha: 0.3)
                    : ModernColors.textLight.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              isActive ? Icons.favorite : Icons.favorite_border,
              color: isActive ? ModernColors.error : ModernColors.textLight,
              size: 18,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: ModernSpacing.paddingHorizontalLG,
      padding: ModernSpacing.paddingXL,
      decoration: BoxDecoration(
        gradient: ModernColors.createLinearGradient(
          [
            ModernColors.cardBackground,
            ModernColors.cardBackground.withValues(alpha: 0.98),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: ModernSpacing.borderRadiusLarge,
        boxShadow: ModernShadows.card,
        border: Border.all(
          color: _getPhaseColor().withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Enhanced top row: Score and Lives
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Enhanced Score section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score',
                      style: ModernTypography.label.copyWith(
                        color: ModernColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    ModernSpacing.verticalSpaceXS,
                    AnimatedBuilder(
                      animation: _scoreAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: ModernSpacing.paddingSM,
                          decoration: BoxDecoration(
                            gradient: ModernColors.createLinearGradient(
                              _getPhaseGradient(),
                            ),
                            borderRadius: ModernSpacing.borderRadiusMedium,
                            boxShadow: ModernShadows.glow(
                              _getPhaseColor(),
                              opacity: 0.2,
                              blur: 8,
                            ),
                          ),
                          child: Text(
                            widget.showAnimations
                                ? '${_scoreAnimation.value}'
                                : '${widget.score}',
                            style: ModernTypography.displayMedium.copyWith(
                              color: ModernColors.textOnDark,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              ModernSpacing.horizontalSpaceLG,

              // Enhanced Lives section
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Lives',
                    style: ModernTypography.label.copyWith(
                      color: ModernColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  ModernSpacing.verticalSpaceSM,
                  _buildLivesIndicator(),
                ],
              ),
            ],
          ),

          ModernSpacing.verticalSpaceXL,

          // Enhanced Progress section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced progress label and phase
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: ModernTypography.label.copyWith(
                      color: ModernColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: ModernSpacing.paddingMD,
                    decoration: BoxDecoration(
                      gradient: ModernColors.createLinearGradient(
                        _getPhaseGradient(),
                      ),
                      borderRadius: ModernSpacing.borderRadiusMedium,
                      boxShadow: ModernShadows.small,
                    ),
                    child: Text(
                      widget.currentPhase.name.toUpperCase(),
                      style: ModernTypography.caption.copyWith(
                        color: ModernColors.textOnDark,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),

              ModernSpacing.verticalSpaceMD,

              // Enhanced progress bar
              Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: ModernColors.createLinearGradient([
                    ModernColors.surfaceLight,
                    ModernColors.surfaceMedium,
                  ]),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    final progress = widget.showAnimations
                        ? _progressAnimation.value
                        : (widget.totalQuestions > 0
                              ? widget.correctAnswers / widget.totalQuestions
                              : 0.0);

                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: ModernColors.createLinearGradient(
                            _getPhaseGradient(),
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: _getPhaseColor().withValues(alpha: 0.4),
                              offset: const Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              ModernSpacing.verticalSpaceMD,

              // Enhanced stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: ModernSpacing.paddingSM,
                    decoration: BoxDecoration(
                      color: ModernColors.surfaceLight,
                      borderRadius: ModernSpacing.borderRadiusSmall,
                    ),
                    child: Text(
                      '${widget.correctAnswers}/${widget.totalQuestions} correct',
                      style: ModernTypography.bodySmall.copyWith(
                        color: ModernColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: ModernSpacing.paddingSM,
                    decoration: BoxDecoration(
                      color: _getPhaseColor().withValues(alpha: 0.1),
                      borderRadius: ModernSpacing.borderRadiusSmall,
                    ),
                    child: Text(
                      '${widget.accuracy.toStringAsFixed(0)}% accuracy',
                      style: ModernTypography.bodySmall.copyWith(
                        color: _getPhaseColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A compact version for smaller spaces
class CompactScoreDisplay extends StatelessWidget {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final DifficultyPhase currentPhase;

  const CompactScoreDisplay({
    super.key,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.currentPhase,
  });

  Color _getPhaseColor() {
    switch (currentPhase) {
      case DifficultyPhase.beginner:
        return ModernColors.primaryGreen;
      case DifficultyPhase.intermediate:
        return ModernColors.primaryYellow;
      case DifficultyPhase.expert:
        return ModernColors.primaryRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ModernSpacing.paddingLG,
      decoration: BoxDecoration(
        gradient: ModernColors.createLinearGradient([
          _getPhaseColor().withValues(alpha: 0.1),
          _getPhaseColor().withValues(alpha: 0.05),
        ]),
        borderRadius: ModernSpacing.borderRadiusMedium,
        border: Border.all(
          color: _getPhaseColor().withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: ModernShadows.small,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Enhanced Score
          Container(
            padding: ModernSpacing.paddingSM,
            decoration: BoxDecoration(
              gradient: ModernColors.createLinearGradient([
                _getPhaseColor(),
                _getPhaseColor().withValues(alpha: 0.8),
              ]),
              borderRadius: ModernSpacing.borderRadiusSmall,
            ),
            child: Text(
              '$score',
              style: ModernTypography.headingSmall.copyWith(
                color: ModernColors.textOnDark,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),

          ModernSpacing.horizontalSpaceMD,

          // Enhanced Separator
          Container(
            width: 2,
            height: 24,
            decoration: BoxDecoration(
              gradient: ModernColors.createLinearGradient(
                [
                  ModernColors.surfaceDark.withValues(alpha: 0.3),
                  ModernColors.surfaceDark.withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          ModernSpacing.horizontalSpaceMD,

          // Enhanced Progress
          Text(
            '$correctAnswers/$totalQuestions',
            style: ModernTypography.bodyMedium.copyWith(
              color: ModernColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
