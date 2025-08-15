import 'package:flutter/material.dart';
import '../controllers/breed_adventure_controller.dart';
import '../models/enums.dart';
import '../services/audio_service.dart';
import '../services/progress_service.dart';
import '../utils/animations.dart';
import '../widgets/breed_adventure/breed_name_display.dart';
import '../widgets/breed_adventure/dual_image_selection.dart';
import '../widgets/breed_adventure/countdown_timer_display.dart';
import '../widgets/breed_adventure/score_progress_display.dart';
import '../widgets/breed_adventure/loading_error_states.dart';
import '../widgets/animated_button.dart';
import '../widgets/power_up_feedback_widget.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../design_system/modern_shadows.dart';

/// Main screen for the Dog Breeds Adventure game
class DogBreedsAdventureScreen extends StatefulWidget {
  const DogBreedsAdventureScreen({super.key});

  @override
  State<DogBreedsAdventureScreen> createState() =>
      _DogBreedsAdventureScreenState();
}

class _DogBreedsAdventureScreenState extends State<DogBreedsAdventureScreen>
    with TickerProviderStateMixin {
  late BreedAdventureController _controller;
  late AnimationController _screenController;
  late AnimationController _feedbackController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isInitialized = false;
  bool _showFeedback = false;
  bool _isCorrect = false;
  int? _selectedImageIndex;
  PowerUpType? _activePowerUpFeedback;

  @override
  void initState() {
    super.initState();

    _screenController = AnimationController(
      duration: AppAnimations.normalDuration,
      vsync: this,
    );

    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _screenController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _screenController,
            curve: Curves.easeOutCubic,
          ),
        );

    _controller = BreedAdventureController();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      await _controller.initialize();
      await _controller.startGame(context);

      setState(() {
        _isInitialized = true;
      });

      _screenController.forward();
    } catch (e) {
      debugPrint('Failed to initialize game: $e');
      // Handle initialization error
    }
  }

  @override
  void dispose() {
    _screenController.dispose();
    _feedbackController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleImageSelection(int imageIndex) async {
    if (!_controller.isGameActive || _showFeedback) return;

    setState(() {
      _selectedImageIndex = imageIndex;
      _showFeedback = true;
    });

    // Determine if selection is correct
    final challenge = _controller.currentChallenge;
    if (challenge != null) {
      _isCorrect = challenge.isCorrectSelection(imageIndex);
    }

    // Play audio feedback and record progress
    if (_isCorrect) {
      AudioService().playCorrectAnswerSound();
      // Record correct answer with progress service
      final phaseMultiplier =
          _controller.gameState.currentPhase.scoreMultiplier;
      final pointsEarned = (100 * phaseMultiplier); // Base score calculation
      final currentStreak = _controller.gameState.consecutiveCorrect + 1;
      await ProgressService().recordCorrectAnswer(
        pointsEarned: pointsEarned,
        currentStreak: currentStreak,
      );
    } else {
      AudioService().playIncorrectAnswerSound();
      // Record incorrect answer
      await ProgressService().recordIncorrectAnswer();
    }

    // Process the selection in the controller
    await _controller.selectImage(context, imageIndex);

    // Wait for feedback display
    await Future.delayed(
      const Duration(milliseconds: 1100),
    ); // 500ms forward + 600ms pause

    // Reset feedback state when moving to next challenge
    setState(() {
      _showFeedback = false;
      _selectedImageIndex = null;
      _isCorrect = false; // Reset the correct state for next challenge
    });
  }

  Future<void> _handlePowerUpUsage(PowerUpType powerUpType) async {
    final success = await _controller.usePowerUp(context, powerUpType);

    if (success) {
      setState(() {
        _activePowerUpFeedback = powerUpType;
      });

      _feedbackController.forward().then((_) {
        _feedbackController.reset();
        setState(() {
          _activePowerUpFeedback = null;
        });
      });

      // Play power-up sound
      AudioService().playPowerUpSound();
    }
  }

  Widget _buildHeaderPowerUpButton(PowerUpType powerUpType) {
    final count = _controller.powerUpInventory[powerUpType] ?? 0;
    final canUse = _controller.isGameActive && !_showFeedback && count > 0;

    return GestureDetector(
      onTap: canUse ? () => _handlePowerUpUsage(powerUpType) : null,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: canUse
              ? LinearGradient(
                  colors: _getPowerUpGradient(powerUpType),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: canUse ? null : ModernColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canUse
                ? _getPowerUpColor(powerUpType).withValues(alpha: 0.3)
                : ModernColors.surfaceDark,
            width: 1,
          ),
          boxShadow: canUse ? ModernShadows.small : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Power-up icon
            Icon(
              _getPowerUpIcon(powerUpType),
              color: canUse ? ModernColors.textOnDark : ModernColors.textLight,
              size: 20,
            ),

            // Count badge
            if (count > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: canUse
                        ? ModernColors.textOnDark
                        : ModernColors.textLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getPowerUpColor(powerUpType),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: ModernTypography.caption.copyWith(
                        color: canUse
                            ? _getPowerUpColor(powerUpType)
                            : ModernColors.textOnDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
              ),

            // Disabled overlay
            if (!canUse)
              Container(
                decoration: BoxDecoration(
                  color: ModernColors.overlayBackground.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getPowerUpIcon(PowerUpType powerUpType) {
    switch (powerUpType) {
      case PowerUpType.fiftyFifty:
        return Icons.remove_circle_outline_rounded;
      case PowerUpType.hint:
        return Icons.lightbulb_outline_rounded;
      case PowerUpType.extraTime:
        return Icons.access_time_rounded;
      case PowerUpType.skip:
        return Icons.skip_next_rounded;
      case PowerUpType.secondChance:
        return Icons.favorite_rounded;
    }
  }

  Color _getPowerUpColor(PowerUpType powerUpType) {
    switch (powerUpType) {
      case PowerUpType.fiftyFifty:
        return ModernColors.primaryRed;
      case PowerUpType.hint:
        return ModernColors.primaryYellow;
      case PowerUpType.extraTime:
        return ModernColors.primaryBlue;
      case PowerUpType.skip:
        return ModernColors.primaryGreen;
      case PowerUpType.secondChance:
        return ModernColors.primaryPurple;
    }
  }

  List<Color> _getPowerUpGradient(PowerUpType powerUpType) {
    switch (powerUpType) {
      case PowerUpType.fiftyFifty:
        return ModernColors.redGradient;
      case PowerUpType.hint:
        return ModernColors.yellowGradient;
      case PowerUpType.extraTime:
        return ModernColors.blueGradient;
      case PowerUpType.skip:
        return ModernColors.greenGradient;
      case PowerUpType.secondChance:
        return ModernColors.purpleGradient;
    }
  }

  void _handleGameOver() async {
    final stats = _controller.getGameStatistics();

    // Record game completion using controller integration
    await _controller.recordGameCompletion();

    // Navigate to game over screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => _GameOverScreen(statistics: stats),
        ),
      );
    }
  }

  void _handlePauseGame() {
    _controller.pauseGame();
    _showPauseDialog();
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Game Paused', style: ModernTypography.headingMedium),
        content: Text(
          'The game is paused. Tap Resume to continue.',
          style: ModernTypography.bodyMedium,
        ),
        actions: [
          PrimaryAnimatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _controller.resumeGame();
            },
            child: Text('Resume', style: ModernTypography.buttonMedium),
          ),
          SecondaryAnimatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Exit game
            },
            child: Text('Exit Game', style: ModernTypography.buttonMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    final challenge = _controller.currentChallenge;

    if (challenge == null) {
      return const GameInitializingState();
    }

    return Column(
      children: [
        // Top section: Timer, power-ups, and pause button
        Padding(
          padding: ModernSpacing.paddingHorizontalLG,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Timer
              CountdownTimerDisplay(
                remainingSeconds: _controller.timeRemaining,
                totalSeconds: 10,
                isActive: _controller.isTimerRunning,
                onTimeExpired: () {
                  _controller.handleTimeExpired(context);
                  if (_controller.livesRemaining <= 0) {
                    _handleGameOver();
                  }
                },
              ),

              // Power-ups (only extra time and skip)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeaderPowerUpButton(PowerUpType.extraTime),
                  ModernSpacing.horizontalSpaceSM,
                  _buildHeaderPowerUpButton(PowerUpType.skip),
                ],
              ),

              // Pause button
              IconButton(
                onPressed: _handlePauseGame,
                icon: Icon(
                  Icons.pause_rounded,
                  color: ModernColors.textSecondary,
                  size: 28,
                ),
              ),
            ],
          ),
        ),

        ModernSpacing.verticalSpaceLG,

        // Image selection - made more prominent and larger with frame
        Expanded(
          flex: 3,
          child: Container(
            margin: ModernSpacing.paddingHorizontalLG,
            padding: ModernSpacing.paddingLG,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ModernColors.cardBackground,
                  ModernColors.cardBackground.withValues(alpha: 0.95),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: ModernColors.primaryPurple.withValues(alpha: 0.05),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 15),
                ),
              ],
              border: Border.all(
                color: ModernColors.primaryPurple.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Game arena title
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ModernColors.primaryPurple.withValues(alpha: 0.1),
                        ModernColors.primaryBlue.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Choose the Correct Image',
                    style: ModernTypography.bodyMedium.copyWith(
                      color: ModernColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                ModernSpacing.verticalSpaceLG,

                // Images container
                Expanded(
                  child: DualImageSelection(
                    imageUrl1: challenge.correctImageIndex == 0
                        ? challenge.correctImageUrl
                        : challenge.incorrectImageUrl,
                    imageUrl2: challenge.correctImageIndex == 1
                        ? challenge.correctImageUrl
                        : challenge.incorrectImageUrl,
                    onImageSelected: _handleImageSelection,
                    isEnabled: _controller.isGameActive && !_showFeedback,
                    selectedIndex: _selectedImageIndex,
                    isCorrect: _isCorrect,
                    showFeedback: _showFeedback,
                  ),
                ),
              ],
            ),
          ),
        ),

        ModernSpacing.verticalSpaceMD,

        // Compact breed name display - smaller and simpler
        Padding(
          padding: ModernSpacing.paddingHorizontalLG,
          child: CompactBreedNameDisplay(breedName: challenge.correctBreedName),
        ),

        ModernSpacing.verticalSpaceLG,

        // Score and progress
        ScoreProgressDisplay(
          score: _controller.currentScore,
          correctAnswers: _controller.correctAnswers,
          totalQuestions: _controller.gameState.totalQuestions,
          currentPhase: _controller.currentPhase,
          livesRemaining: _controller.livesRemaining,
          accuracy: _controller.accuracy,
        ),

        ModernSpacing.verticalSpaceLG,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.backgroundGradientStart,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ModernColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main game content
              if (_isInitialized)
                AnimatedBuilder(
                  animation: _screenController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ListenableBuilder(
                          listenable: _controller,
                          builder: (context, child) {
                            // Check if game has ended
                            if (!_controller.isGameActive &&
                                _controller.livesRemaining <= 0) {
                              // Schedule game over handling after this build cycle
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _handleGameOver();
                              });
                            }
                            return _buildGameContent();
                          },
                        ),
                      ),
                    );
                  },
                )
              else
                const GameInitializingState(),

              // Power-up feedback overlay
              if (_activePowerUpFeedback != null)
                Positioned.fill(
                  child: Container(
                    color: ModernColors.overlayBackground.withValues(
                      alpha: 0.8,
                    ),
                    child: Center(
                      child: PowerUpFeedbackWidget(
                        powerUpType: _activePowerUpFeedback!,
                        onAnimationComplete: () {
                          setState(() {
                            _activePowerUpFeedback = null;
                          });
                        },
                      ),
                    ),
                  ),
                ),

              // Game over check handled in controller callbacks
            ],
          ),
        ),
      ),
    );
  }
}

/// Game over screen for breed adventure
class _GameOverScreen extends StatelessWidget {
  final GameStatistics statistics;

  const _GameOverScreen({required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.backgroundGradientStart,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ModernColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: ModernSpacing.paddingXL,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game over image
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: ModernSpacing.borderRadiusLarge,
                    boxShadow: ModernShadows.medium,
                  ),
                  child: ClipRRect(
                    borderRadius: ModernSpacing.borderRadiusLarge,
                    child: Image.asset(
                      'assets/images/fail.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                ModernSpacing.verticalSpaceLG,

                // Game over title
                Text(
                  'Game Over',
                  style: ModernTypography.displayLarge.copyWith(
                    color: ModernColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                ModernSpacing.verticalSpaceXL,

                // Statistics card
                Container(
                  padding: ModernSpacing.paddingXL,
                  decoration: BoxDecoration(
                    color: ModernColors.cardBackground,
                    borderRadius: ModernSpacing.borderRadiusLarge,
                    boxShadow: ModernShadows.large,
                  ),
                  child: Column(
                    children: [
                      // Final score
                      Text(
                        'Final Score',
                        style: ModernTypography.headingMedium.copyWith(
                          color: ModernColors.textSecondary,
                        ),
                      ),
                      ModernSpacing.verticalSpaceSM,
                      Text(
                        '${statistics.score}',
                        style: ModernTypography.displayLarge.copyWith(
                          color: ModernColors.primaryPurple,
                        ),
                      ),

                      ModernSpacing.verticalSpaceLG,

                      // Stats grid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(
                            label: 'Correct',
                            value: '${statistics.correctAnswers}',
                            color: ModernColors.success,
                          ),
                          _StatItem(
                            label: 'Accuracy',
                            value: '${statistics.accuracy.toStringAsFixed(0)}%',
                            color: ModernColors.primaryBlue,
                          ),
                          _StatItem(
                            label: 'Phase',
                            value: statistics.currentPhase.name,
                            color: ModernColors.primaryYellow,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                ModernSpacing.verticalSpaceXL,

                // Action buttons
                Column(
                  children: [
                    // Play Again button - enhanced styling
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ModernColors.primaryPurple,
                            ModernColors.primaryBlue,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: ModernSpacing.borderRadiusLarge,
                        boxShadow: ModernShadows.large,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: ModernSpacing.borderRadiusLarge,
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DogBreedsAdventureScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: ModernSpacing.paddingMD,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.replay_rounded,
                                  color: ModernColors.textOnDark,
                                  size: 24,
                                ),
                                ModernSpacing.horizontalSpaceSM,
                                Text(
                                  'Play Again',
                                  style: ModernTypography.buttonLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    ModernSpacing.verticalSpaceMD,

                    // Home button - enhanced styling
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: ModernColors.cardBackground,
                        border: Border.all(
                          color: ModernColors.primaryPurple,
                          width: 2,
                        ),
                        borderRadius: ModernSpacing.borderRadiusLarge,
                        boxShadow: ModernShadows.medium,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: ModernSpacing.borderRadiusLarge,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          },
                          child: Container(
                            padding: ModernSpacing.paddingMD,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.home_rounded,
                                  color: ModernColors.primaryPurple,
                                  size: 24,
                                ),
                                ModernSpacing.horizontalSpaceSM,
                                Text(
                                  'Home',
                                  style: ModernTypography.buttonLarge.copyWith(
                                    color: ModernColors.primaryPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget for displaying individual statistics
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: ModernTypography.headingMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        ModernSpacing.verticalSpaceXS,
        Text(
          label,
          style: ModernTypography.caption.copyWith(
            color: ModernColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
