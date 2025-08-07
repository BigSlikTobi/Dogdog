import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/enums.dart';
import '../services/audio_service.dart';
import '../services/progress_service.dart';
import 'result_screen.dart';
import '../utils/responsive.dart';
import '../utils/animations.dart';
import '../utils/accessibility.dart';
import '../utils/enum_extensions.dart';
import '../widgets/loading_animation.dart';
import '../widgets/modern_card.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../design_system/modern_shadows.dart';
import '../l10n/generated/app_localizations.dart';

/// Main game screen widget displaying questions, answers, and game UI elements
class GameScreen extends StatefulWidget {
  final Difficulty difficulty;
  final int level;

  const GameScreen({super.key, required this.difficulty, this.level = 1});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController _gameController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    final progressService = Provider.of<ProgressService>(
      context,
      listen: false,
    );
    _gameController = GameController(progressService: progressService);
    await _gameController.initializeGame(level: widget.level);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _gameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: LoadingAnimation(
            size: 80,
            message: AppLocalizations.of(context).gameScreen_loading,
          ),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _gameController,
      child: AccessibilityTheme(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: ModernColors.backgroundGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Semantics(
                label: AppLocalizations.of(context).accessibility_pauseGame,
                hint: 'Tap to pause the current game',
                child: IconButton(
                  icon: Icon(
                    Icons.pause_rounded,
                    color: ModernColors.textPrimary,
                    size: 24,
                  ),
                  onPressed: () => _showPauseDialog(),
                ),
              ),
              title: Semantics(
                label: 'Current level: ${widget.level}',
                child: Text(
                  AppLocalizations.of(context).gameScreen_level(widget.level),
                  style: ModernTypography.headingSmall.copyWith(fontSize: 18),
                ),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Consumer<GameController>(
                builder: (context, gameController, child) {
                  return ResponsiveContainer(
                    child: Column(
                      children: [
                        // Top bar with lives and score
                        _buildTopBar(gameController),

                        // Timer bar (if applicable)
                        if (gameController.isTimerActive)
                          _buildTimerBar(gameController),

                        // Question area
                        Expanded(
                          child: Column(
                            children: [
                              // Question display
                              _buildQuestionArea(gameController),

                              SizedBox(
                                height: ResponsiveUtils.getResponsiveSpacing(
                                  context,
                                  30,
                                ),
                              ),

                              // Answer choices in responsive grid
                              Expanded(child: _buildAnswerGrid(gameController)),

                              SizedBox(
                                height: ResponsiveUtils.getResponsiveSpacing(
                                  context,
                                  20,
                                ),
                              ),

                              // Power-up buttons
                              _buildPowerUpBar(gameController),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the top bar with lives and score display
  Widget _buildTopBar(GameController gameController) {
    return Container(
      padding: ModernSpacing.paddingHorizontalLG.add(
        ModernSpacing.paddingVerticalMD,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Lives display with heart icons
          _buildLivesDisplay(gameController.lives),

          // Score display
          _buildScoreDisplay(
            gameController.score,
            gameController.scoreMultiplier,
          ),
        ],
      ),
    );
  }

  /// Builds the lives display using heart icons
  Widget _buildLivesDisplay(int lives) {
    return GameElementSemantics(
      label: AccessibilityUtils.createGameElementLabel(
        element: 'Lives remaining',
        value: '$lives out of 3',
        context: 'Hearts represent your remaining chances',
      ),
      child: Container(
        padding: ModernSpacing.paddingVerticalXS.add(
          ModernSpacing.paddingHorizontalSM,
        ),
        decoration: BoxDecoration(
          color: ModernColors.error.withValues(alpha: 0.1),
          borderRadius: ModernSpacing.borderRadiusMedium,
          border: Border.all(
            color: ModernColors.error.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_rounded, color: ModernColors.error, size: 20),
            ModernSpacing.horizontalSpaceXS,
            Row(
              children: List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      index < lives
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: ModernColors.error,
                      size: 18,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the score display in top-right corner
  Widget _buildScoreDisplay(int score, int multiplier) {
    return GameElementSemantics(
      label: AccessibilityUtils.createGameElementLabel(
        element: 'Current score',
        value: '$score points',
        context: multiplier > 1
            ? 'Score multiplier ${multiplier}x active'
            : null,
      ),
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
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (multiplier > 1) ...[
              Container(
                padding: ModernSpacing.paddingVerticalXS.add(
                  ModernSpacing.paddingHorizontalXS,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: ModernColors.yellowGradient),
                  borderRadius: ModernSpacing.borderRadiusSmall,
                  boxShadow: ModernShadows.small,
                ),
                child: Text(
                  '${multiplier}x',
                  style: ModernTypography.caption.copyWith(
                    color: ModernColors.textOnDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ModernSpacing.horizontalSpaceXS,
            ],
            Text(
              '$score',
              style: ModernTypography.scoreText.copyWith(
                fontSize: 20,
                color: ModernColors.primaryBlue,
              ),
            ),
            ModernSpacing.horizontalSpaceXS,
            Text(
              AppLocalizations.of(context).gameScreen_score,
              style: ModernTypography.bodySmall.copyWith(
                color: ModernColors.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the timer bar for timed questions (levels 2-5)
  Widget _buildTimerBar(GameController gameController) {
    final timeRemaining = gameController.timeRemaining;
    final totalTime = gameController.gameState.timeLimitForLevel;
    final progress = totalTime > 0 ? timeRemaining / totalTime : 0.0;

    // Determine color based on remaining time using modern colors
    Color timerColor;
    List<Color> timerGradient;
    String urgencyContext;
    if (progress > 0.5) {
      timerColor = ModernColors.success;
      timerGradient = ModernColors.greenGradient;
      urgencyContext = 'plenty of time remaining';
    } else if (progress > 0.3) {
      timerColor = ModernColors.warning;
      timerGradient = ModernColors.yellowGradient;
      urgencyContext = 'time running low';
    } else {
      timerColor = ModernColors.error;
      timerGradient = ModernColors.redGradient;
      urgencyContext = 'time almost up';
    }

    return GameElementSemantics(
      label: AccessibilityUtils.createGameElementLabel(
        element: 'Timer',
        value: '$timeRemaining seconds remaining',
        context: urgencyContext,
      ),
      child: Container(
        height: 16,
        margin: ModernSpacing.paddingHorizontalLG.add(
          ModernSpacing.paddingVerticalXS,
        ),
        decoration: BoxDecoration(
          color: ModernColors.surfaceLight,
          borderRadius: ModernSpacing.borderRadiusSmall,
          boxShadow: ModernShadows.subtle,
        ),
        child: Stack(
          children: [
            // Animated progress bar with gradient
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width:
                  MediaQuery.of(context).size.width * progress.clamp(0.0, 1.0) -
                  (ModernSpacing.lg * 2),
              height: 16,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: timerGradient),
                borderRadius: ModernSpacing.borderRadiusSmall,
                boxShadow: ModernShadows.colored(timerColor, opacity: 0.4),
              ),
            ),

            // Timer text overlay with modern typography
            if (timeRemaining > 0)
              Positioned.fill(
                child: Center(
                  child: Text(
                    '${timeRemaining}s',
                    style: ModernTypography.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: progress > 0.5
                          ? ModernColors.textPrimary
                          : ModernColors.textOnDark,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the question display area
  Widget _buildQuestionArea(GameController gameController) {
    final question = gameController.currentQuestion;
    if (question == null) {
      return Center(
        child: Text(
          'No question available', // This should not normally happen
          style: ModernTypography.bodyLarge.copyWith(
            color: ModernColors.textSecondary,
          ),
        ),
      );
    }

    return ModernCard(
      margin: ModernSpacing.paddingHorizontalLG,
      padding: ModernSpacing.paddingLG,
      shadows: ModernShadows.medium,
      semanticLabel:
          'Question ${gameController.gameState.currentQuestionIndex + 1} of ${gameController.gameState.questions.length}',
      child: Column(
        children: [
          // Question number indicator
          Container(
            padding: ModernSpacing.paddingVerticalXS.add(
              ModernSpacing.paddingHorizontalSM,
            ),
            decoration: BoxDecoration(
              color: ModernColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: ModernSpacing.borderRadiusXLarge,
            ),
            child: Text(
              AppLocalizations.of(context).gameScreen_questionCounter(
                gameController.gameState.currentQuestionIndex + 1,
                gameController.gameState.questions.length,
              ),
              style: ModernTypography.label.copyWith(
                color: ModernColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          ModernSpacing.verticalSpaceMD,

          // Question text with modern typography
          Text(
            question.text,
            style: ModernTypography.questionText,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the responsive grid layout for four answer choices
  Widget _buildAnswerGrid(GameController gameController) {
    final question = gameController.currentQuestion;
    if (question == null) {
      return const SizedBox.shrink();
    }

    final crossAxisCount = ResponsiveUtils.getAnswerGridColumns(context);
    final spacing = ResponsiveUtils.getResponsiveSpacing(context, 16);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio:
          ResponsiveUtils.isLandscape(context) && crossAxisCount == 4
          ? 2.0
          : 1.2,
      children: List.generate(4, (index) {
        if (index >= question.answers.length) {
          return const SizedBox.shrink();
        }

        return _buildAnswerButton(
          question.answers[index],
          index,
          gameController,
        );
      }),
    );
  }

  /// Builds a single answer button with feedback states
  Widget _buildAnswerButton(
    String answer,
    int index,
    GameController gameController,
  ) {
    final isSelected = gameController.selectedAnswerIndex == index;
    final isCorrectAnswer =
        gameController.currentQuestion?.correctAnswerIndex == index;
    final isShowingFeedback = gameController.isShowingFeedback;
    final isDisabled = gameController.disabledAnswerIndices.contains(index);
    final lastAnswerWasCorrect = gameController.lastAnswerWasCorrect;

    // Determine button state and colors using modern design system
    Color backgroundColor = ModernColors.cardBackground;
    Color borderColor = ModernColors.surfaceDark;
    Color letterBackgroundColor = ModernColors.primaryPurple.withValues(
      alpha: 0.1,
    );
    Color letterTextColor = ModernColors.primaryPurple;
    Color answerTextColor = ModernColors.textPrimary;
    List<BoxShadow> shadows = ModernShadows.small;
    double opacity = 1.0;

    if (isDisabled) {
      // Disabled by 50/50 power-up
      opacity = 0.3;
      backgroundColor = ModernColors.surfaceLight;
      borderColor = ModernColors.surfaceDark;
      letterBackgroundColor = ModernColors.textLight.withValues(alpha: 0.1);
      letterTextColor = ModernColors.textLight;
      answerTextColor = ModernColors.textLight;
      shadows = ModernShadows.none;
    } else if (isShowingFeedback) {
      if (isSelected) {
        // Selected answer feedback
        if (lastAnswerWasCorrect == true) {
          // Correct answer - green
          backgroundColor = ModernColors.success.withValues(alpha: 0.1);
          borderColor = ModernColors.success;
          letterBackgroundColor = ModernColors.success;
          letterTextColor = ModernColors.textOnDark;
          answerTextColor = ModernColors.success;
          shadows = ModernShadows.colored(ModernColors.success);
        } else {
          // Incorrect answer - red
          backgroundColor = ModernColors.error.withValues(alpha: 0.1);
          borderColor = ModernColors.error;
          letterBackgroundColor = ModernColors.error;
          letterTextColor = ModernColors.textOnDark;
          answerTextColor = ModernColors.error;
          shadows = ModernShadows.colored(ModernColors.error);
        }
      } else if (isCorrectAnswer && lastAnswerWasCorrect == false) {
        // Show correct answer when user selected wrong
        backgroundColor = ModernColors.success.withValues(alpha: 0.1);
        borderColor = ModernColors.success;
        letterBackgroundColor = ModernColors.success;
        letterTextColor = ModernColors.textOnDark;
        answerTextColor = ModernColors.success;
        shadows = ModernShadows.colored(ModernColors.success);
      }
    }

    // Create semantic label for the answer button
    final answerLetter = String.fromCharCode(65 + index);
    String semanticLabel = 'Answer $answerLetter: $answer';

    if (isDisabled) {
      semanticLabel += ', disabled';
    } else if (isShowingFeedback) {
      if (isSelected) {
        semanticLabel += lastAnswerWasCorrect == true
            ? ', correct'
            : ', incorrect';
      } else if (isCorrectAnswer && lastAnswerWasCorrect == false) {
        semanticLabel += ', correct answer';
      }
    }

    return GameElementSemantics(
      label: semanticLabel,
      hint: isDisabled
          ? 'This answer has been eliminated'
          : 'Tap to select this answer',
      enabled: gameController.isGameActive && !isShowingFeedback && !isDisabled,
      onTap: (gameController.isGameActive && !isShowingFeedback && !isDisabled)
          ? () => _onAnswerSelected(index, gameController)
          : null,
      child: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 300),
        child: ModernCard.interactive(
          onTap:
              (gameController.isGameActive && !isShowingFeedback && !isDisabled)
              ? () => _onAnswerSelected(index, gameController)
              : null,
          backgroundColor: backgroundColor,
          borderRadius: ModernSpacing.borderRadiusMedium,
          shadows: shadows,
          hasBorder: true,
          borderColor: borderColor,
          borderWidth: 2.0,
          margin: EdgeInsets.zero,
          padding: ModernSpacing.paddingMD,
          semanticLabel: semanticLabel,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Answer letter (A, B, C, D) with feedback icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: letterBackgroundColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow:
                      isShowingFeedback &&
                          (isSelected ||
                              (isCorrectAnswer &&
                                  lastAnswerWasCorrect == false))
                      ? ModernShadows.small
                      : null,
                ),
                child: Center(
                  child: isShowingFeedback && isSelected
                      ? Icon(
                          lastAnswerWasCorrect == true
                              ? Icons.check_rounded
                              : Icons.close_rounded,
                          color: letterTextColor,
                          size: 20,
                        )
                      : isShowingFeedback &&
                            isCorrectAnswer &&
                            lastAnswerWasCorrect == false
                      ? Icon(
                          Icons.check_rounded,
                          color: letterTextColor,
                          size: 20,
                        )
                      : Text(
                          answerLetter,
                          style: ModernTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: letterTextColor,
                          ),
                        ),
                ),
              ),

              ModernSpacing.verticalSpaceSM,

              // Answer text with modern typography
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: ModernTypography.answerText.copyWith(
                    color: answerTextColor,
                    fontSize: 14,
                  ),
                  child: Text(
                    answer,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the power-up bar at the bottom
  Widget _buildPowerUpBar(GameController gameController) {
    return ModernCard(
      margin: ModernSpacing.paddingHorizontalLG,
      padding: ModernSpacing.paddingMD,
      shadows: ModernShadows.small,
      semanticLabel: 'Power-up controls',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPowerUpButton(
            PowerUpType.fiftyFifty,
            Icons.remove_circle_outline_rounded,
            gameController,
          ),
          _buildPowerUpButton(
            PowerUpType.hint,
            Icons.lightbulb_outline_rounded,
            gameController,
          ),
          _buildPowerUpButton(
            PowerUpType.extraTime,
            Icons.access_time_rounded,
            gameController,
          ),
          _buildPowerUpButton(
            PowerUpType.skip,
            Icons.skip_next_rounded,
            gameController,
          ),
          _buildPowerUpButton(
            PowerUpType.secondChance,
            Icons.favorite_border_rounded,
            gameController,
          ),
        ],
      ),
    );
  }

  /// Builds a single power-up button
  Widget _buildPowerUpButton(
    PowerUpType powerUpType,
    IconData icon,
    GameController gameController,
  ) {
    final count = gameController.getPowerUpCount(powerUpType);
    final canUse = gameController.canUsePowerUp(powerUpType) && count > 0;

    return GameElementSemantics(
      label: AccessibilityUtils.createButtonLabel(
        '${powerUpType.displayName(context)} power-up',
        hint: canUse
            ? 'Tap to use this power-up. You have $count remaining.'
            : count > 0
            ? 'Power-up not available in current state'
            : 'No power-ups remaining',
        isEnabled: canUse,
      ),
      onTap: canUse ? () => _usePowerUp(powerUpType, gameController) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: canUse
                  ? ModernColors.primaryPurple.withValues(alpha: 0.1)
                  : ModernColors.surfaceLight,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: canUse
                    ? ModernColors.primaryPurple
                    : ModernColors.surfaceDark,
                width: 2,
              ),
              boxShadow: canUse ? ModernShadows.small : ModernShadows.none,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(26),
                onTap: canUse
                    ? () => _usePowerUp(powerUpType, gameController)
                    : null,
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        icon,
                        color: canUse
                            ? ModernColors.primaryPurple
                            : ModernColors.textLight,
                        size: 26,
                      ),
                    ),
                    // Count badge
                    if (count > 0)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: canUse
                                ? ModernColors.primaryPurple
                                : ModernColors.textLight,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: ModernShadows.small,
                          ),
                          child: Center(
                            child: Text(
                              '$count',
                              style: ModernTypography.caption.copyWith(
                                color: ModernColors.textOnDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles answer selection and navigation to result screen
  void _onAnswerSelected(int answerIndex, GameController gameController) async {
    final currentQuestion = gameController.currentQuestion;
    if (currentQuestion == null) return;

    // Store score before processing answer to calculate points earned
    final scoreBefore = gameController.score;
    final livesBefore = gameController.lives;

    // Process the answer
    final isCorrect = gameController.processAnswer(answerIndex);

    // Calculate points earned and lives lost
    final pointsEarned = gameController.score - scoreBefore;
    final livesLost = livesBefore - gameController.lives;

    // Play sound effect based on answer correctness
    final audioService = AudioService();
    if (isCorrect) {
      await audioService.playCorrectAnswerSound();
    } else {
      await audioService.playIncorrectAnswerSound();
    }

    // Navigate to result screen
    if (mounted) {
      await Navigator.of(context).push(
        ModernPageRoute(
          child: ChangeNotifierProvider.value(
            value: gameController,
            child: ResultScreen(
              isCorrect: isCorrect,
              question: currentQuestion,
              pointsEarned: pointsEarned,
              livesLost: livesLost,
            ),
          ),
          direction: SlideDirection.bottomToTop,
        ),
      );
    }
  }

  /// Handles power-up usage with confirmation dialog
  void _usePowerUp(
    PowerUpType powerUpType,
    GameController gameController,
  ) async {
    // Show confirmation dialog first
    final confirmed = await _showPowerUpConfirmationDialog(powerUpType);
    if (!confirmed) return;

    final audioService = AudioService();

    switch (powerUpType) {
      case PowerUpType.fiftyFifty:
        final removedIndices = gameController.useFiftyFifty();
        if (removedIndices.isNotEmpty) {
          await audioService.playPowerUpSound();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).powerUp_fiftyFifty_description,
                ),
                backgroundColor: const Color(0xFF8B5CF6),
              ),
            );
          }
        }
        break;
      case PowerUpType.hint:
        final hint = gameController.useHint();
        if (hint != null) {
          await audioService.playPowerUpSound();
          if (mounted) {
            _showHintDialog(hint);
          }
        }
        break;
      case PowerUpType.extraTime:
        final success = gameController.useExtraTime();
        if (success) {
          await audioService.playPowerUpSound();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).powerUp_extraTimeAdded,
                ),
                backgroundColor: const Color(0xFF8B5CF6),
              ),
            );
          }
        }
        break;
      case PowerUpType.skip:
        final success = gameController.useSkip();
        if (success) {
          await audioService.playPowerUpSound();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).powerUp_questionSkipped,
                ),
                backgroundColor: const Color(0xFF8B5CF6),
              ),
            );
          }
        }
        break;
      case PowerUpType.secondChance:
        final success = gameController.useSecondChance();
        if (success) {
          await audioService.playPowerUpSound();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).powerUp_lifeRestored,
                ),
                backgroundColor: const Color(0xFF8B5CF6),
              ),
            );
          }
        }
        break;
    }
  }

  /// Shows a power-up confirmation dialog
  Future<bool> _showPowerUpConfirmationDialog(PowerUpType powerUpType) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              powerUpType.displayName(context),
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  powerUpType.description(context),
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF8B5CF6),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Möchtest du dieses Power-Up verwenden?',
                          style: TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Abbrechen',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Verwenden'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Shows a hint dialog
  void _showHintDialog(String hint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Hinweis',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          hint,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Color(0xFF8B5CF6))),
          ),
        ],
      ),
    );
  }

  /// Shows the pause dialog
  void _showPauseDialog() {
    _gameController.pauseGame();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Spiel pausiert',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Das Spiel ist pausiert. Möchtest du weiterspielen oder zum Hauptmenü zurückkehren?',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text(
              'Hauptmenü',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _gameController.resumeGame();
            },
            child: const Text(
              'Weiterspielen',
              style: TextStyle(color: Color(0xFF8B5CF6)),
            ),
          ),
        ],
      ),
    );
  }
}
