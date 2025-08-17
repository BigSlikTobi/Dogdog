import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../controllers/persistent_timer_controller.dart';
import '../controllers/treasure_map_controller.dart';
import '../controllers/feedback_controller.dart';
import '../models/enums.dart';
import '../services/audio_service.dart';
import '../services/progress_service.dart';
import 'result_screen.dart';
import 'checkpoint_celebration_screen.dart';
import '../utils/responsive.dart';
import '../utils/animations.dart';
import '../utils/accessibility.dart';
import '../utils/enum_extensions.dart';
import '../widgets/shared/loading_animation.dart';
import '../widgets/modern_card.dart';
import '../widgets/lives_indicator.dart';
import '../widgets/shared/streak_celebration_widget.dart';
import '../widgets/animated_score_display.dart';
import '../widgets/milestone_progress_widget.dart';
import '../widgets/power_up_feedback_widget.dart';
import '../widgets/personal_best_widget.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../design_system/modern_shadows.dart';
import '../l10n/generated/app_localizations.dart';

/// Main game screen widget displaying questions, answers, and game UI elements
class GameScreen extends StatefulWidget {
  final Difficulty difficulty;
  final int level;
  final QuestionCategory? category;

  const GameScreen({
    super.key,
    required this.difficulty,
    this.level = 1,
    this.category,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController _gameController;
  late FeedbackController _feedbackController;
  bool _isLoading = true;
  bool _shouldDisposeController = false;

  @override
  void initState() {
    super.initState();
    _feedbackController = FeedbackController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeGame());
  }

  Future<void> _initializeGame() async {
    try {
      _gameController = Provider.of<GameController>(context, listen: false);
      _shouldDisposeController = false;

      // If category is provided, use category-based initialization
      if (widget.category != null) {
        await _gameController.initializeGameWithCategory(
          category: widget.category!,
          level: widget.level,
        );
      } else {
        await _gameController.initializeGame(level: widget.level);
      }
    } on Exception {
      if (!mounted) return;
      final progressService = Provider.of<ProgressService>(
        context,
        listen: false,
      );
      final timerController = PersistentTimerController();
      _gameController = GameController(
        progressService: progressService,
        timerController: timerController,
      );
      _shouldDisposeController = true;

      // If category is provided, use category-based initialization
      if (widget.category != null) {
        await _gameController.initializeGameWithCategory(
          category: widget.category!,
          level: widget.level,
        );
      } else {
        await _gameController.initializeGame(level: widget.level);
      }
    }
    _gameController.setCheckpointReachedCallback(_handleCheckpointReached);
    if (mounted) setState(() => _isLoading = false);
  }

  void _handleCheckpointReached(
    Checkpoint checkpoint,
    Map<PowerUpType, int> earnedPowerUps,
    int questionsAnswered,
    double accuracy,
    int pointsEarned,
    bool isPathCompleted,
  ) {
    Navigator.of(context).push(
      ModernPageRoute(
        child: CheckpointCelebrationScreen(
          completedCheckpoint: checkpoint,
          earnedPowerUps: earnedPowerUps,
          questionsAnswered: questionsAnswered,
          accuracy: accuracy,
          pointsEarned: pointsEarned,
          isPathCompleted: isPathCompleted,
        ),
        direction: SlideDirection.bottomToTop,
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    if (_shouldDisposeController) {
      try {
        _gameController.dispose();
      } catch (_) {}
    }
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
                  onPressed: _showPauseDialog,
                ),
              ),
              title: Consumer<TreasureMapController>(
                builder: (context, tmc, _) => _buildAppBarTitle(tmc),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: ChangeNotifierProvider.value(
                value: _feedbackController,
                child:
                    Consumer3<
                      GameController,
                      TreasureMapController,
                      FeedbackController
                    >(
                      builder:
                          (
                            context,
                            gameController,
                            treasureMapController,
                            feedbackController,
                            _,
                          ) {
                            return ResponsiveContainer(
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      _buildTopBar(gameController),
                                      if (gameController.isTimerActive)
                                        _buildTimerBar(gameController),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            _buildQuestionArea(gameController),
                                            SizedBox(
                                              height:
                                                  ResponsiveUtils.getResponsiveSpacing(
                                                    context,
                                                    12,
                                                  ),
                                            ),
                                            Expanded(
                                              child: _buildAnswerGrid(
                                                gameController,
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                                  ResponsiveUtils.getResponsiveSpacing(
                                                    context,
                                                    8,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (feedbackController.showStreakCelebration)
                                    StreakCelebrationWidget(
                                      streakCount:
                                          feedbackController.currentStreak,
                                      multiplier:
                                          feedbackController.currentMultiplier,
                                      onAnimationComplete: feedbackController
                                          .hideStreakCelebration,
                                    ),
                                  if (feedbackController.showMilestoneProgress)
                                    Positioned(
                                      top: 100,
                                      left: 0,
                                      right: 0,
                                      child: Consumer<TreasureMapController>(
                                        builder: (context, tmc, _) =>
                                            MilestoneProgressWidget(
                                              progress: feedbackController
                                                  .milestoneProgress,
                                              questionsRemaining:
                                                  feedbackController
                                                      .questionsToMilestone,
                                              nextCheckpoint:
                                                  tmc.nextCheckpoint ??
                                                  Checkpoint.chihuahua,
                                              onAnimationComplete:
                                                  feedbackController
                                                      .hideMilestoneProgress,
                                            ),
                                      ),
                                    ),
                                  if (feedbackController.showPowerUpFeedback &&
                                      feedbackController.powerUpType != null)
                                    Positioned(
                                      top: 200,
                                      left: 20,
                                      right: 20,
                                      child: PowerUpFeedbackWidget(
                                        powerUpType:
                                            feedbackController.powerUpType!,
                                        onAnimationComplete: feedbackController
                                            .hidePowerUpFeedback,
                                      ),
                                    ),
                                  if (feedbackController.showPersonalBest)
                                    PersonalBestWidget(
                                      newScore: feedbackController.newBestScore,
                                      previousBest:
                                          feedbackController.previousBestScore,
                                      onAnimationComplete:
                                          feedbackController.hidePersonalBest,
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
      ),
    );
  }

  // HEADER ------------------------------------------------------------------
  Widget _buildTopBar(GameController gameController) {
    return Container(
      padding: ModernSpacing.paddingHorizontalLG.add(
        ModernSpacing.paddingVerticalSM,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCompactPowerUpButton(
                    PowerUpType.fiftyFifty,
                    Icons.remove_circle_outline_rounded,
                    gameController,
                  ),
                  _buildCompactPowerUpButton(
                    PowerUpType.hint,
                    Icons.lightbulb_outline_rounded,
                    gameController,
                  ),
                  _buildCompactPowerUpButton(
                    PowerUpType.extraTime,
                    Icons.access_time_rounded,
                    gameController,
                  ),
                  _buildCompactPowerUpButton(
                    PowerUpType.skip,
                    Icons.skip_next_rounded,
                    gameController,
                  ),
                  _buildCompactPowerUpButton(
                    PowerUpType.secondChance,
                    Icons.favorite_border_rounded,
                    gameController,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: ModernSpacing.md),
          Consumer<FeedbackController>(
            builder: (context, fc, _) => AnimatedScoreDisplay(
              score: gameController.score,
              multiplier: gameController.scoreMultiplier,
              bonusPoints: fc.scoreGained,
              showBonusAnimation: fc.isScoreAnimating,
              onBonusAnimationComplete: fc.completeScoreAnimation,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPowerUpButton(
    PowerUpType type,
    IconData icon,
    GameController controller,
  ) {
    final count = controller.getPowerUpCount(type);
    final canUse = controller.canUsePowerUp(type) && count > 0;
    final semantic = AccessibilityUtils.createButtonLabel(
      '${type.displayName(context)} power-up',
      hint: canUse
          ? 'Tap to use. $count left.'
          : (count > 0 ? 'Unavailable now' : 'None left'),
      isEnabled: canUse,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GameElementSemantics(
        label: semantic,
        enabled: canUse,
        onTap: canUse ? () => _usePowerUp(type, controller) : null,
        child: GestureDetector(
          onTap: canUse ? () => _usePowerUp(type, controller) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: canUse
                  ? ModernColors.primaryPurple.withValues(alpha: 0.12)
                  : ModernColors.surfaceLight,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: canUse
                    ? ModernColors.primaryPurple
                    : ModernColors.surfaceDark,
                width: 1.5,
              ),
              boxShadow: canUse ? ModernShadows.small : ModernShadows.none,
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    size: 22,
                    color: canUse
                        ? ModernColors.primaryPurple
                        : ModernColors.textLight,
                  ),
                ),
                if (count > 0)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: canUse
                            ? ModernColors.primaryPurple
                            : ModernColors.textLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: ModernTypography.caption.copyWith(
                          color: ModernColors.textOnDark,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // TIMER -------------------------------------------------------------------
  Widget _buildTimerBar(GameController gameController) {
    final timeRemaining = gameController.timeRemaining;
    final totalTime = gameController.gameState.timeLimitForLevel;
    final progress = totalTime > 0 ? timeRemaining / totalTime : 0.0;
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width:
                  (MediaQuery.of(context).size.width - (ModernSpacing.lg * 2)) *
                  progress.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: timerGradient),
                borderRadius: ModernSpacing.borderRadiusSmall,
                boxShadow: ModernShadows.colored(timerColor, opacity: 0.4),
              ),
            ),
            if (timeRemaining > 0)
              Center(
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
          ],
        ),
      ),
    );
  }

  // APP BAR TITLE -----------------------------------------------------------
  Widget _buildAppBarTitle(TreasureMapController treasureMapController) {
    final currentPath = treasureMapController.currentPath;
    return Semantics(
      label: 'Current path: ${currentPath.displayName}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentPath.displayName,
                style: ModernTypography.headingSmall.copyWith(fontSize: 18),
              ),
              SizedBox(width: 8),
              Consumer<GameController>(
                builder: (context, gameController, _) => LivesIndicator(
                  lives: gameController.lives,
                  size: 16,
                  color: ModernColors.error,
                ),
              ),
            ],
          ),
          Text(
            'Treasure Hunt',
            style: ModernTypography.caption.copyWith(
              color: ModernColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // QUESTION ----------------------------------------------------------------
  Widget _buildQuestionArea(GameController gameController) {
    final question = gameController.currentQuestion;
    if (question == null) {
      return Center(
        child: Text(
          'No question available',
          style: ModernTypography.bodyLarge.copyWith(
            color: ModernColors.textSecondary,
          ),
        ),
      );
    }
    final maxHeight = MediaQuery.of(context).size.height * 0.26;
    return ModernCard(
      margin: ModernSpacing.paddingHorizontalLG,
      padding: EdgeInsets.symmetric(
        horizontal: ModernSpacing.md,
        vertical: ModernSpacing.md,
      ),
      shadows: ModernShadows.medium,
      semanticLabel:
          'Question ${gameController.gameState.currentQuestionIndex + 1} of ${gameController.gameState.questions.length}',
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 140,
          maxHeight: maxHeight.clamp(140, 240),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: ModernColors.primaryBlue.withValues(alpha: 0.12),
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
            SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  question.text,
                  style: ModernTypography.questionText.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ANSWERS -----------------------------------------------------------------
  Widget _buildAnswerGrid(GameController gameController) {
    final question = gameController.currentQuestion;
    if (question == null) return const SizedBox.shrink();
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
      children: List.generate(4, (i) {
        if (i >= question.answers.length) return const SizedBox.shrink();
        return _buildAnswerButton(question.answers[i], i, gameController);
      }),
    );
  }

  Widget _buildAnswerButton(String answer, int index, GameController gc) {
    final isSelected = gc.selectedAnswerIndex == index;
    final isCorrect = gc.currentQuestion?.correctAnswerIndex == index;
    final isFeedback = gc.isShowingFeedback;
    final isDisabled = gc.disabledAnswerIndices.contains(index);
    final lastCorrect = gc.lastAnswerWasCorrect;

    Color backgroundColor = ModernColors.cardBackground;
    Color borderColor = ModernColors.surfaceDark;
    Color letterBg = ModernColors.primaryPurple.withValues(alpha: 0.1);
    Color letterColor = ModernColors.primaryPurple;
    Color answerColor = ModernColors.textPrimary;
    List<BoxShadow> shadows = ModernShadows.small;
    double opacity = 1.0;

    if (isDisabled) {
      opacity = 0.3;
      backgroundColor = ModernColors.surfaceLight;
      borderColor = ModernColors.surfaceDark;
      letterBg = ModernColors.textLight.withValues(alpha: 0.1);
      letterColor = ModernColors.textLight;
      answerColor = ModernColors.textLight;
      shadows = ModernShadows.none;
    } else if (isFeedback) {
      if (isSelected) {
        if (lastCorrect == true) {
          backgroundColor = ModernColors.success.withValues(alpha: 0.1);
          borderColor = ModernColors.success;
          letterBg = ModernColors.success;
          letterColor = ModernColors.textOnDark;
          answerColor = ModernColors.success;
          shadows = ModernShadows.colored(ModernColors.success);
        } else {
          backgroundColor = ModernColors.error.withValues(alpha: 0.1);
          borderColor = ModernColors.error;
          letterBg = ModernColors.error;
          letterColor = ModernColors.textOnDark;
          answerColor = ModernColors.error;
          shadows = ModernShadows.colored(ModernColors.error);
        }
      } else if (isCorrect && lastCorrect == false) {
        backgroundColor = ModernColors.success.withValues(alpha: 0.1);
        borderColor = ModernColors.success;
        letterBg = ModernColors.success;
        letterColor = ModernColors.textOnDark;
        answerColor = ModernColors.success;
        shadows = ModernShadows.colored(ModernColors.success);
      }
    }

    final letter = String.fromCharCode(65 + index);
    String semantic = 'Answer $letter: $answer';
    if (isDisabled) {
      semantic += ', disabled';
    } else if (isFeedback) {
      if (isSelected) {
        semantic += lastCorrect == true ? ', correct' : ', incorrect';
      } else if (isCorrect && lastCorrect == false)
        // ignore: curly_braces_in_flow_control_structures
        semantic += ', correct answer';
    }

    return GameElementSemantics(
      label: semantic,
      hint: isDisabled
          ? 'This answer has been eliminated'
          : 'Tap to select this answer',
      enabled: gc.isGameActive && !isFeedback && !isDisabled,
      onTap: (gc.isGameActive && !isFeedback && !isDisabled)
          ? () => _onAnswerSelected(index, gc)
          : null,
      child: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 300),
        child: ModernCard.interactive(
          onTap: (gc.isGameActive && !isFeedback && !isDisabled)
              ? () => _onAnswerSelected(index, gc)
              : null,
          backgroundColor: backgroundColor,
          borderRadius: ModernSpacing.borderRadiusMedium,
          shadows: shadows,
          hasBorder: true,
          borderColor: borderColor,
          borderWidth: 2,
          margin: EdgeInsets.zero,
          padding: ModernSpacing.paddingMD,
          semanticLabel: semantic,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: letterBg,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow:
                      isFeedback &&
                          (isSelected || (isCorrect && lastCorrect == false))
                      ? ModernShadows.small
                      : null,
                ),
                child: Center(
                  child: isFeedback && isSelected
                      ? Icon(
                          lastCorrect == true
                              ? Icons.check_rounded
                              : Icons.close_rounded,
                          color: letterColor,
                          size: 20,
                        )
                      : (isFeedback && isCorrect && lastCorrect == false)
                      ? Icon(Icons.check_rounded, color: letterColor, size: 20)
                      : Text(
                          letter,
                          style: ModernTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: letterColor,
                          ),
                        ),
                ),
              ),
              ModernSpacing.verticalSpaceSM,
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: ModernTypography.answerText.copyWith(
                    color: answerColor,
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

  // ANSWER HANDLING ---------------------------------------------------------
  void _onAnswerSelected(int index, GameController gc) async {
    final q = gc.currentQuestion;
    if (q == null) return;
    final scoreBefore = gc.score;
    final livesBefore = gc.lives;
    final correct = gc.processAnswer(index);
    final pointsEarned = gc.score - scoreBefore;
    final livesLost = livesBefore - gc.lives;

    if (correct && pointsEarned > 0) {
      _feedbackController.triggerScoreAnimation(
        pointsEarned,
        gc.scoreMultiplier,
        gc.streak,
      );
      final previousScore = gc.score - pointsEarned;
      if (gc.score > previousScore + 100) {
        _feedbackController.triggerPersonalBest(gc.score, previousScore);
      }
      if (gc.streak % 5 == 0 && gc.streak > 0) {
        final progress = (gc.streak % 10) / 10.0;
        final remaining = 10 - (gc.streak % 10);
        _feedbackController.triggerMilestoneProgress(progress, remaining);
      }
    }

    final audio = AudioService();
    if (correct) {
      await audio.playCorrectAnswerSound();
    } else {
      await audio.playIncorrectAnswerSound();
    }

    if (!mounted) return;
    await Navigator.of(context).push(
      ModernPageRoute(
        child: ChangeNotifierProvider.value(
          value: gc,
          child: ResultScreen(
            isCorrect: correct,
            question: q,
            pointsEarned: pointsEarned,
            livesLost: livesLost,
          ),
        ),
        direction: SlideDirection.bottomToTop,
      ),
    );
  }

  // POWER-UPS ---------------------------------------------------------------
  void _usePowerUp(PowerUpType type, GameController gc) async {
    final confirmed = await _showPowerUpConfirmationDialog(type);
    if (!confirmed) return;
    final audio = AudioService();

    switch (type) {
      case PowerUpType.fiftyFifty:
        final removed = gc.useFiftyFifty();
        if (removed.isNotEmpty) {
          await audio.playPowerUpSound();
          _feedbackController.triggerPowerUpAnimation(type);
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
        final hint = gc.useHint();
        if (hint != null) {
          await audio.playPowerUpSound();
          _feedbackController.triggerPowerUpAnimation(type);
          if (mounted) _showHintDialog(hint);
        }
        break;
      case PowerUpType.extraTime:
        final before = gc.timeRemaining;
        final success = gc.useExtraTime();
        if (success) {
          final after = gc.timeRemaining;
          await audio.playPowerUpSound();
          _feedbackController.triggerPowerUpAnimation(
            type,
            beforeValue: before,
            afterValue: after,
          );
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
        final success = gc.useSkip();
        if (success) {
          await audio.playPowerUpSound();
          _feedbackController.triggerPowerUpAnimation(type);
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
        final success = gc.useSecondChance();
        if (success) {
          await audio.playPowerUpSound();
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

  Future<bool> _showPowerUpConfirmationDialog(PowerUpType type) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              type.displayName(context),
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
                  type.description(context),
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
                    children: const [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF8B5CF6),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
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
              Navigator.of(context).pop();
              Navigator.of(context).pop();
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
