import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../controllers/breed_adventure/breed_adventure_controller.dart';
import '../models/enums.dart';
import '../models/shared/game_statistics.dart';
import '../services/audio_service.dart';
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

/// The main screen for the Dog Breeds Adventure game.
///
/// This screen is responsible for:
/// - Initializing the [BreedAdventureController].
/// - Building the UI for the game, including the timer, power-ups, image selection, and score display.
/// - Handling user interactions, such as tapping on an image or using a power-up.
/// - Managing animations for screen transitions and feedback.
class DogBreedsAdventureScreen extends StatefulWidget {
  /// Creates a new instance of [DogBreedsAdventureScreen].
  const DogBreedsAdventureScreen({super.key});

  @override
  State<DogBreedsAdventureScreen> createState() =>
      _DogBreedsAdventureScreenState();
}

/// The state for the [DogBreedsAdventureScreen].
class _DogBreedsAdventureScreenState extends State<DogBreedsAdventureScreen>
    with TickerProviderStateMixin {
  /// The controller for the breed adventure game.
  late BreedAdventureController _controller;

  /// The animation controller for the screen transitions.
  late AnimationController _screenController;

  /// The animation controller for the power-up feedback.
  late AnimationController _feedbackController;

  /// The fade animation for the screen content.
  late Animation<double> _fadeAnimation;

  /// The slide animation for the screen content.
  late Animation<Offset> _slideAnimation;

  /// Whether the game has been initialized.
  bool _isInitialized = false;

  /// The type of power-up feedback currently being displayed.
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

  /// Initializes the game by setting up the controller and starting the game.
  Future<void> _initializeGame() async {
    try {
      await _controller.initialize();
      if (mounted) {
        await _controller.startGame();

        setState(() {
          _isInitialized = true;
        });

        _screenController.forward();
      }
    } catch (e) {
      debugPrint('Failed to initialize game: $e');
    }
  }

  @override
  void dispose() {
    _screenController.dispose();
    _feedbackController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Handles the user's selection of an image.
  void _handleImageSelection(int imageIndex) {
    if (_controller.isGameActive &&
        _controller.feedbackState == AnswerFeedback.none) {
      _controller.selectImage(imageIndex);
    }
  }

  /// Handles the user's usage of a power-up.
  Future<void> _handlePowerUpUsage(PowerUpType powerUpType) async {
    final success = await _controller.usePowerUp(powerUpType);

    if (!mounted) return;

    if (success) {
      setState(() {
        _activePowerUpFeedback = powerUpType;
      });

      _feedbackController.forward().then((_) {
        if (!mounted) return;
        _feedbackController.reset();
        setState(() {
          _activePowerUpFeedback = null;
        });
      });

      // Play a sound to give feedback to the user.
      AudioService().playPowerUpSound();
    }
  }

  /// Builds a power-up button for the header.
  Widget _buildHeaderPowerUpButton(PowerUpType powerUpType) {
    final count = _controller.powerUpInventory[powerUpType] ?? 0;
    final canUse =
        _controller.isGameActive &&
        _controller.feedbackState == AnswerFeedback.none &&
        count > 0;

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

  /// Handles the end of the game by navigating to the game over screen.
  void _handleGameOver() async {
    final stats = _controller.getGameStatistics();

    // Record the completion of the game using the controller integration.
    await _controller.recordGameCompletion();

    // Navigate to the game over screen.
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => _GameOverScreen(statistics: stats),
        ),
      );
    }
  }

  /// Handles pausing the game.
  void _handlePauseGame() {
    _controller.pauseGame();
    _showPauseDialog();
  }

  void _showPauseDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.breedAdventure_gamePaused,
          style: ModernTypography.headingMedium,
        ),
        content: Text(
          l10n.breedAdventure_pauseMessage,
          style: ModernTypography.bodyMedium,
        ),
        actions: [
          PrimaryAnimatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _controller.resumeGame();
            },
            child: Text(
              l10n.breedAdventure_resume,
              style: ModernTypography.buttonMedium,
            ),
          ),
          SecondaryAnimatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Exit game
            },
            child: Text(
              l10n.breedAdventure_exitGame,
              style: ModernTypography.buttonMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main content of the game screen.
  Widget _buildGameContent() {
    final challenge = _controller.currentChallenge;

    if (challenge == null) {
      return Center(
        child: BreedAdventureLoading(
          message: AppLocalizations.of(context).breedAdventure_gameInitializing,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool needsScroll = constraints.maxHeight < 720;
        final double imageHeight = constraints.maxHeight * 0.42;
        final double clampedImageHeight = imageHeight
            .clamp(260.0, 420.0)
            .toDouble();

        Widget buildImageArena() {
          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: needsScroll ? ModernSpacing.md : ModernSpacing.lg,
            ),
            padding: const EdgeInsets.all(ModernSpacing.md),
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
              // Column used to keep title and gallery vertically aligned
              children: [
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
                    AppLocalizations.of(
                      context,
                    ).breedAdventure_chooseCorrectImage,
                    style: ModernTypography.bodyMedium.copyWith(
                      color: ModernColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  height: needsScroll ? ModernSpacing.md : ModernSpacing.lg,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    child: DualImageSelection(
                      key: ValueKey(_controller.currentChallenge),
                      imageUrl1: challenge.correctImageIndex == 0
                          ? challenge.correctImageUrl
                          : challenge.incorrectImageUrl,
                      imageUrl2: challenge.correctImageIndex == 1
                          ? challenge.correctImageUrl
                          : challenge.incorrectImageUrl,
                      onImageSelected: _handleImageSelection,
                      isEnabled:
                          _controller.feedbackState == AnswerFeedback.none,
                      selectedIndex: _controller.feedbackIndex,
                      isCorrect:
                          _controller.feedbackState == AnswerFeedback.correct,
                      showFeedback:
                          _controller.feedbackState != AnswerFeedback.none,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        Widget buildContent({required bool useFlexible}) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: needsScroll ? ModernSpacing.md : ModernSpacing.lg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CountdownTimerDisplay(
                      remainingSeconds: _controller.timeRemaining,
                      totalSeconds: 10,
                      isActive: _controller.isTimerRunning,
                      onTimeExpired: () async {
                        await _controller.handleTimeExpired();
                        if (!mounted) return;
                        if (_controller.livesRemaining <= 0) {
                          _handleGameOver();
                        }
                      },
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeaderPowerUpButton(PowerUpType.extraTime),
                        ModernSpacing.horizontalSpaceSM,
                        _buildHeaderPowerUpButton(PowerUpType.skip),
                      ],
                    ),
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
              SizedBox(
                height: needsScroll ? ModernSpacing.md : ModernSpacing.lg,
              ),
              if (useFlexible)
                Expanded(child: buildImageArena())
              else
                SizedBox(height: clampedImageHeight, child: buildImageArena()),
              SizedBox(height: ModernSpacing.sm),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: needsScroll ? ModernSpacing.md : ModernSpacing.lg,
                ),
                child: CompactBreedNameDisplay(
                  breedName: challenge.correctBreedName,
                ),
              ),
              SizedBox(
                height: needsScroll ? ModernSpacing.md : ModernSpacing.lg,
              ),
              ScoreProgressDisplay(
                score: _controller.currentScore,
                correctAnswers: _controller.correctAnswers,
                totalQuestions: _controller.gameState.totalQuestions,
                currentPhase: _controller.currentPhase,
                livesRemaining: _controller.livesRemaining,
                accuracy: _controller.accuracy,
              ),
              SizedBox(
                height: needsScroll ? ModernSpacing.md : ModernSpacing.lg,
              ),
            ],
          );
        }

        if (!needsScroll) {
          return buildContent(useFlexible: true);
        }

        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: ModernSpacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: buildContent(useFlexible: false),
          ),
        );
      },
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
              // Main game content.
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
                            // Check if the game has ended.
                            if (!_controller.isGameActive &&
                                _controller.livesRemaining <= 0) {
                              // Schedule the game over handling after this build cycle.
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
                Center(
                  child: BreedAdventureLoading(
                    message: AppLocalizations.of(
                      context,
                    ).breedAdventure_gameInitializing,
                  ),
                ),

              // Power-up feedback overlay.
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

              // The game over check is handled in the controller callbacks.
            ],
          ),
        ),
      ),
    );
  }
}

/// A screen that displays the game over statistics for the breed adventure game.
class _GameOverScreen extends StatelessWidget {
  /// The statistics for the completed game.
  final GameStatistics statistics;

  /// Creates a new instance of [_GameOverScreen].
  const _GameOverScreen({required this.statistics});

  String _getLocalizedPhaseName(BuildContext context, String? phaseName) {
    final l10n = AppLocalizations.of(context);
    if (phaseName == null) return l10n.breed_adventure_unknown;

    switch (phaseName.toLowerCase()) {
      case 'beginner':
        return l10n.difficultyPhase_beginner;
      case 'intermediate':
        return l10n.difficultyPhase_intermediate;
      case 'expert':
        return l10n.difficultyPhase_expert;
      default:
        return phaseName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                  l10n.gameOverScreen_title,
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
                      // High score and final score row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Final score
                          Column(
                            children: [
                              Text(
                                l10n.breedAdventure_finalScore,
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
                            ],
                          ),
                          // High score
                          Column(
                            children: [
                              Text(
                                l10n.achievementsScreen_totalScore,
                                style: ModernTypography.headingMedium.copyWith(
                                  color: ModernColors.textSecondary,
                                ),
                              ),
                              ModernSpacing.verticalSpaceSM,
                              Text(
                                '${statistics.highScore}',
                                style: ModernTypography.displayLarge.copyWith(
                                  color: ModernColors.primaryPurple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // New high score badge
                      if (statistics.isNewHighScore)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: ModernColors.primaryYellow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              l10n.breedAdventure_newHighScore,
                              style: ModernTypography.bodyMedium.copyWith(
                                color: ModernColors.textOnDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      ModernSpacing.verticalSpaceLG,

                      // Stats grid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(
                            label: l10n.breedAdventure_correct,
                            value: '${statistics.correctAnswers}',
                            color: ModernColors.success,
                          ),
                          _StatItem(
                            label: l10n.breedAdventure_accuracy,
                            value: '${statistics.accuracy.toStringAsFixed(0)}%',
                            color: ModernColors.primaryBlue,
                          ),
                          _StatItem(
                            label: l10n.breedAdventure_phase,
                            value: _getLocalizedPhaseName(
                              context,
                              statistics.additionalStats['currentPhase'] as String?,
                            ),
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
                                  l10n.breedAdventure_playAgain,
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
                                  l10n.breedAdventure_home,
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

/// A widget for displaying an individual statistic on the game over screen.
class _StatItem extends StatelessWidget {
  /// The label for the statistic.
  final String label;

  /// The value of the statistic.
  final String value;

  /// The color of the value text.
  final Color color;

  /// Creates a new instance of [_StatItem].
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
