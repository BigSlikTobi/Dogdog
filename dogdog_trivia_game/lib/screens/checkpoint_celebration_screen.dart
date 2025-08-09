import 'package:flutter/material.dart';
import 'dart:async';
import '../models/enums.dart';
import '../widgets/animated_button.dart';
import '../widgets/success_animation_widget.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_spacing.dart';
import '../design_system/modern_typography.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/audio_service.dart';

/// Checkpoint celebration screen for milestone achievements
class CheckpointCelebrationScreen extends StatefulWidget {
  final Checkpoint completedCheckpoint;
  final Map<PowerUpType, int> earnedPowerUps;
  final int questionsAnswered;
  final double accuracy;
  final int pointsEarned;
  final bool isPathCompleted;

  const CheckpointCelebrationScreen({
    super.key,
    required this.completedCheckpoint,
    required this.earnedPowerUps,
    required this.questionsAnswered,
    required this.accuracy,
    required this.pointsEarned,
    this.isPathCompleted = false,
  });

  @override
  State<CheckpointCelebrationScreen> createState() =>
      _CheckpointCelebrationScreenState();
}

class _CheckpointCelebrationScreenState
    extends State<CheckpointCelebrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _celebrationController;
  late AnimationController _powerUpAnimationController;
  late AnimationController _statsAnimationController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _powerUpAnimation;
  late Animation<double> _statsAnimation;

  bool _showCelebrationOverlay = true;
  Timer? _autoAdvanceTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _playAchievementSound();
  }

  void _setupAnimations() {
    // Main animation controller for fade in and scale
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Celebration animation for the achievement
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Power-up reveal animation
    _powerUpAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Stats animation controller
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Fade in animation
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Scale animation for main content
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Celebration animation (bounce effect)
    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );

    // Power-up reveal animation
    _powerUpAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _powerUpAnimationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // Stats animation
    _statsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _statsAnimationController, curve: Curves.easeOut),
    );
  }

  void _startAnimations() {
    // Start main animation
    _mainAnimationController.forward();

    // Start celebration animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _celebrationController.forward();
      }
    });

    // Start power-up animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _powerUpAnimationController.forward();
      }
    });

    // Start stats animation
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _statsAnimationController.forward();
      }
    });

    // Hide celebration overlay after animation
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showCelebrationOverlay = false;
        });
      }
    });

    // Auto-advance after showing all content (optional)
    _autoAdvanceTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        _handleContinue();
      }
    });
  }

  void _playAchievementSound() {
    // Play achievement sound effect
    AudioService().playAchievementSound();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _mainAnimationController.dispose();
    _celebrationController.dispose();
    _powerUpAnimationController.dispose();
    _statsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getGradientForCheckpoint(widget.completedCheckpoint),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              AnimatedBuilder(
                animation: _fadeInAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeInAnimation.value,
                    child: Padding(
                      padding: ModernSpacing.paddingLG,
                      child: Column(
                        children: [
                          // Checkpoint achievement header
                          _buildCheckpointHeader(),

                          ModernSpacing.verticalSpaceXL,

                          // Main content area
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  // Dog breed achievement image
                                  _buildAchievementImage(),

                                  ModernSpacing.verticalSpaceLG,

                                  // Performance summary
                                  _buildPerformanceSummary(),

                                  ModernSpacing.verticalSpaceLG,

                                  // Power-up rewards
                                  _buildPowerUpRewards(),

                                  ModernSpacing.verticalSpaceXL,
                                ],
                              ),
                            ),
                          ),

                          // Continue button
                          _buildContinueButton(),

                          ModernSpacing.verticalSpaceLG,
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Celebration overlay
              if (_showCelebrationOverlay) _buildCelebrationOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the checkpoint achievement header
  Widget _buildCheckpointHeader() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            children: [
              Text(
                widget.isPathCompleted
                    ? 'Path Completed!'
                    : 'Checkpoint Reached!',
                style: ModernTypography.headingLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              ModernSpacing.verticalSpaceSM,
              Container(
                padding: ModernSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: ModernSpacing.borderRadiusLarge,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Text(
                  widget.completedCheckpoint.displayName,
                  style: ModernTypography.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the dog breed achievement image with animation
  Widget _buildAchievementImage() {
    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) {
        final scale = 1.0 + (_celebrationAnimation.value * 0.1);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                widget.completedCheckpoint.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.pets,
                      size: 80,
                      color: ModernColors.primaryPurple,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the performance summary card
  Widget _buildPerformanceSummary() {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _statsAnimation.value,
          child: Container(
            width: double.infinity,
            padding: ModernSpacing.paddingLG,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: ModernSpacing.borderRadiusLarge,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  ).checkpointCelebration_performanceSummary,
                  style: ModernTypography.headingSmall.copyWith(
                    color: ModernColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ModernSpacing.verticalSpaceMD,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      AppLocalizations.of(
                        context,
                      ).checkpointCelebration_questions,
                      '${widget.questionsAnswered}',
                      Icons.quiz,
                    ),
                    _buildStatItem(
                      AppLocalizations.of(
                        context,
                      ).checkpointCelebration_accuracy,
                      '${(widget.accuracy * 100).round()}%',
                      Icons.track_changes,
                    ),
                    _buildStatItem(
                      AppLocalizations.of(context).checkpointCelebration_points,
                      '${widget.pointsEarned}',
                      Icons.star,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds a single stat item
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: ModernSpacing.paddingSM,
          decoration: BoxDecoration(
            color: ModernColors.primaryPurple.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: ModernColors.primaryPurple, size: 24),
        ),
        ModernSpacing.verticalSpaceXS,
        Text(
          value,
          style: ModernTypography.headingSmall.copyWith(
            color: ModernColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: ModernTypography.bodySmall.copyWith(
            color: ModernColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Builds the power-up rewards section
  Widget _buildPowerUpRewards() {
    return AnimatedBuilder(
      animation: _powerUpAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _powerUpAnimation.value,
          child: Container(
            width: double.infinity,
            padding: ModernSpacing.paddingLG,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: ModernSpacing.borderRadiusLarge,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      color: ModernColors.primaryYellow,
                      size: 24,
                    ),
                    ModernSpacing.horizontalSpaceSM,
                    Text(
                      'Power-Up Rewards',
                      style: ModernTypography.headingSmall.copyWith(
                        color: ModernColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ModernSpacing.verticalSpaceMD,
                _buildPowerUpGrid(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the power-up rewards grid
  Widget _buildPowerUpGrid() {
    final powerUpsWithRewards = widget.earnedPowerUps.entries
        .where((entry) => entry.value > 0)
        .toList();

    if (powerUpsWithRewards.isEmpty) {
      return Text(
        'No power-ups earned this time',
        style: ModernTypography.bodyMedium.copyWith(
          color: ModernColors.textSecondary,
        ),
      );
    }

    return Wrap(
      spacing: ModernSpacing.sm,
      runSpacing: ModernSpacing.sm,
      alignment: WrapAlignment.center,
      children: powerUpsWithRewards.map((entry) {
        return _buildPowerUpRewardItem(entry.key, entry.value);
      }).toList(),
    );
  }

  /// Builds a single power-up reward item
  Widget _buildPowerUpRewardItem(PowerUpType type, int count) {
    return Container(
      padding: ModernSpacing.paddingSM,
      decoration: BoxDecoration(
        color: _getPowerUpColor(type).withValues(alpha: 0.1),
        borderRadius: ModernSpacing.borderRadiusSmall,
        border: Border.all(
          color: _getPowerUpColor(type).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getPowerUpIcon(type), color: _getPowerUpColor(type), size: 24),
          ModernSpacing.verticalSpaceXS,
          Text(
            '+$count',
            style: ModernTypography.bodyMedium.copyWith(
              color: _getPowerUpColor(type),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _getPowerUpName(type),
            style: ModernTypography.bodySmall.copyWith(
              color: ModernColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the continue button
  Widget _buildContinueButton() {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: PrimaryAnimatedButton(
        onPressed: _handleContinue,
        child: Text(
          widget.isPathCompleted
              ? l10n.checkpointCelebration_completePath
              : l10n.checkpointCelebration_continueJourney,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Builds the celebration overlay
  Widget _buildCelebrationOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _celebrationAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: (_celebrationAnimation.value * 0.8).clamp(0.0, 1.0),
            child: Container(
              color: ModernColors.overlayBackground,
              child: Center(
                child: SuccessAnimationVariants.checkpointAchievement(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.width * 0.6,
                  onAnimationComplete: () {
                    // Animation completed
                  },
                  onDismissComplete: () {
                    // Hide the overlay when animation is dismissed
                    if (mounted) {
                      setState(() {
                        _showCelebrationOverlay = false;
                      });
                    }
                  },
                  semanticLabel: AppLocalizations.of(
                    context,
                  ).accessibility_checkpointCelebration,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Handles the continue action
  void _handleContinue() {
    _autoAdvanceTimer?.cancel();

    if (widget.isPathCompleted) {
      // Navigate back to treasure map or path selection
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      // Continue to next questions or back to treasure map
      Navigator.of(context).pop();
    }
  }

  /// Gets gradient colors for the checkpoint
  List<Color> _getGradientForCheckpoint(Checkpoint checkpoint) {
    switch (checkpoint) {
      case Checkpoint.chihuahua:
        return ModernColors.greenGradient;
      case Checkpoint.cockerSpaniel:
        return ModernColors.yellowGradient;
      case Checkpoint.germanShepherd:
        return ModernColors.redGradient;
      case Checkpoint.greatDane:
        return ModernColors.blueGradient;
      case Checkpoint.deutscheDogge:
        return ModernColors.purpleGradient;
      case Checkpoint.pug:
        return ModernColors.greenGradient;
    }
  }

  /// Gets the color for a power-up type
  Color _getPowerUpColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.fiftyFifty:
        return ModernColors.primaryBlue;
      case PowerUpType.hint:
        return ModernColors.primaryYellow;
      case PowerUpType.extraTime:
        return ModernColors.primaryGreen;
      case PowerUpType.skip:
        return ModernColors.primaryPurple;
      case PowerUpType.secondChance:
        return ModernColors.primaryRed;
    }
  }

  /// Gets the icon for a power-up type
  IconData _getPowerUpIcon(PowerUpType type) {
    switch (type) {
      case PowerUpType.fiftyFifty:
        return Icons.filter_2;
      case PowerUpType.hint:
        return Icons.lightbulb;
      case PowerUpType.extraTime:
        return Icons.access_time;
      case PowerUpType.skip:
        return Icons.skip_next;
      case PowerUpType.secondChance:
        return Icons.refresh;
    }
  }

  /// Gets the display name for a power-up type
  String _getPowerUpName(PowerUpType type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case PowerUpType.fiftyFifty:
        return l10n.powerUp_fiftyFifty_short;
      case PowerUpType.hint:
        return l10n.powerUp_hint_short;
      case PowerUpType.extraTime:
        return l10n.powerUp_extraTime_short;
      case PowerUpType.skip:
        return l10n.powerUp_skip_short;
      case PowerUpType.secondChance:
        return l10n.powerUp_secondChance_short;
    }
  }
}
