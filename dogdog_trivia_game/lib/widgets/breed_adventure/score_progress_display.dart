import 'package:flutter/material.dart';
import '../../design_system/modern_colors.dart';
import '../../design_system/modern_typography.dart';
import '../../design_system/modern_spacing.dart';
import '../../design_system/modern_shadows.dart';
import '../../models/difficulty_phase.dart';

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
          padding: EdgeInsets.only(right: ModernSpacing.xs),
          child: Icon(
            isActive ? Icons.favorite : Icons.favorite_border,
            color: isActive ? ModernColors.error : ModernColors.textLight,
            size: 20,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: ModernSpacing.paddingHorizontalLG,
      padding: ModernSpacing.paddingLG,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernColors.cardBackground,
            ModernColors.cardBackground.withValues(alpha: 0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: ModernSpacing.borderRadiusLarge,
        boxShadow: ModernShadows.medium,
        border: Border.all(
          color: _getPhaseColor().withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Top row: Score and Lives
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score',
                    style: ModernTypography.caption.copyWith(
                      color: ModernColors.textSecondary,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _scoreAnimation,
                    builder: (context, child) {
                      return Text(
                        widget.showAnimations
                            ? '${_scoreAnimation.value}'
                            : '${widget.score}',
                        style: ModernTypography.displayMedium.copyWith(
                          color: _getPhaseColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Lives
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Lives',
                    style: ModernTypography.caption.copyWith(
                      color: ModernColors.textSecondary,
                    ),
                  ),
                  ModernSpacing.verticalSpaceXS,
                  _buildLivesIndicator(),
                ],
              ),
            ],
          ),

          ModernSpacing.verticalSpaceMD,

          // Progress section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress label and phase
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: ModernTypography.caption.copyWith(
                      color: ModernColors.textSecondary,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ModernSpacing.sm,
                      vertical: ModernSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: _getPhaseGradient()),
                      borderRadius: ModernSpacing.borderRadiusSmall,
                    ),
                    child: Text(
                      widget.currentPhase.name,
                      style: ModernTypography.caption.copyWith(
                        color: ModernColors.textOnDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              ModernSpacing.verticalSpaceSM,

              // Progress bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: ModernColors.surfaceLight,
                  borderRadius: BorderRadius.circular(4),
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
                          gradient: LinearGradient(colors: _getPhaseGradient()),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  },
                ),
              ),

              ModernSpacing.verticalSpaceSM,

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.correctAnswers}/${widget.totalQuestions} correct',
                    style: ModernTypography.bodySmall.copyWith(
                      color: ModernColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${widget.accuracy.toStringAsFixed(0)}% accuracy',
                    style: ModernTypography.bodySmall.copyWith(
                      color: ModernColors.textSecondary,
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
      padding: ModernSpacing.paddingMD,
      decoration: BoxDecoration(
        color: _getPhaseColor().withValues(alpha: 0.1),
        borderRadius: ModernSpacing.borderRadiusMedium,
        border: Border.all(
          color: _getPhaseColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Score
          Text(
            '$score',
            style: ModernTypography.headingSmall.copyWith(
              color: _getPhaseColor(),
              fontWeight: FontWeight.bold,
            ),
          ),

          ModernSpacing.horizontalSpaceSM,

          // Separator
          Container(width: 1, height: 20, color: ModernColors.surfaceDark),

          ModernSpacing.horizontalSpaceSM,

          // Progress
          Text(
            '$correctAnswers/$totalQuestions',
            style: ModernTypography.bodyMedium.copyWith(
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
