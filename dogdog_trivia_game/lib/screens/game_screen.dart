import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/enums.dart';
import '../services/audio_service.dart';
import '../services/progress_service.dart';
import 'result_screen.dart';
import '../utils/responsive.dart';
import '../utils/accessibility.dart';
import '../widgets/loading_animation.dart';
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
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC), // Background Gray
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Semantics(
              label: AppLocalizations.of(context).accessibility_pauseGame,
              hint: 'Tap to pause the current game',
              child: IconButton(
                icon: const Icon(Icons.pause, color: Color(0xFF1F2937)),
                onPressed: () => _showPauseDialog(),
              ),
            ),
            title: Semantics(
              label: 'Current level: ${widget.level}',
              child: Text(
                AppLocalizations.of(context).gameScreen_level(widget.level),
                style: AccessibilityUtils.getAccessibleTextStyle(
                  context,
                  const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
    );
  }

  /// Builds the top bar with lives and score display
  Widget _buildTopBar(GameController gameController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: Row(
        children: [
          const Icon(
            Icons.favorite,
            color: Color(0xFFEF4444), // Error Red
            size: 20,
          ),
          const SizedBox(width: 8),
          Row(
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  index < lives ? Icons.favorite : Icons.favorite_border,
                  color: const Color(0xFFEF4444), // Error Red
                  size: 24,
                ),
              );
            }),
          ),
        ],
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
      child: Row(
        children: [
          if (multiplier > 1) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B), // Warning Yellow
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${multiplier}x',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937), // Text Dark
            ),
          ),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context).gameScreen_score,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280), // Text Light
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the timer bar for timed questions (levels 2-5)
  Widget _buildTimerBar(GameController gameController) {
    final timeRemaining = gameController.timeRemaining;
    final totalTime = gameController.gameState.timeLimitForLevel;
    final progress = totalTime > 0 ? timeRemaining / totalTime : 0.0;

    // Determine color based on remaining time
    Color timerColor;
    String urgencyContext;
    if (progress > 0.5) {
      timerColor = const Color(0xFF10B981); // Success Green
      urgencyContext = 'plenty of time remaining';
    } else if (progress > 0.3) {
      timerColor = const Color(0xFFF59E0B); // Warning Yellow
      urgencyContext = 'time running low';
    } else {
      timerColor = const Color(0xFFEF4444); // Error Red
      urgencyContext = 'time almost up';
    }

    return GameElementSemantics(
      label: AccessibilityUtils.createGameElementLabel(
        element: 'Timer',
        value: '$timeRemaining seconds remaining',
        context: urgencyContext,
      ),
      child: Container(
        height: 12,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated progress bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width:
                  MediaQuery.of(context).size.width * progress.clamp(0.0, 1.0) -
                  40,
              height: 12,
              decoration: BoxDecoration(
                color: timerColor,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: timerColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),

            // Timer text overlay
            if (timeRemaining > 0)
              Positioned.fill(
                child: Center(
                  child: Text(
                    '${timeRemaining}s',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: progress > 0.5
                          ? const Color(0xFF1F2937)
                          : Colors.white,
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
          style: const TextStyle(fontSize: 18, color: Color(0xFF6B7280)),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Question number indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              AppLocalizations.of(context).gameScreen_questionCounter(
                gameController.gameState.currentQuestionIndex + 1,
                gameController.gameState.questions.length,
              ),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A90E2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Question text
          Text(
            question.text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
              height: 1.4,
            ),
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

    // Determine button state and colors
    Color backgroundColor = Colors.white;
    Color borderColor = const Color(0xFFE5E7EB);
    Color letterBackgroundColor = const Color(
      0xFF8B5CF6,
    ).withValues(alpha: 0.1);
    Color letterTextColor = const Color(0xFF8B5CF6);
    Color answerTextColor = const Color(0xFF1F2937);
    double opacity = 1.0;

    if (isDisabled) {
      // Disabled by 50/50 power-up
      opacity = 0.3;
      backgroundColor = const Color(0xFFF3F4F6);
      borderColor = const Color(0xFFE5E7EB);
      letterBackgroundColor = const Color(0xFF9CA3AF).withValues(alpha: 0.1);
      letterTextColor = const Color(0xFF9CA3AF);
      answerTextColor = const Color(0xFF9CA3AF);
    } else if (isShowingFeedback) {
      if (isSelected) {
        // Selected answer feedback
        if (lastAnswerWasCorrect == true) {
          // Correct answer - green
          backgroundColor = const Color(0xFF10B981).withValues(alpha: 0.1);
          borderColor = const Color(0xFF10B981);
          letterBackgroundColor = const Color(0xFF10B981);
          letterTextColor = Colors.white;
          answerTextColor = const Color(0xFF10B981);
        } else {
          // Incorrect answer - red
          backgroundColor = const Color(0xFFEF4444).withValues(alpha: 0.1);
          borderColor = const Color(0xFFEF4444);
          letterBackgroundColor = const Color(0xFFEF4444);
          letterTextColor = Colors.white;
          answerTextColor = const Color(0xFFEF4444);
        }
      } else if (isCorrectAnswer && lastAnswerWasCorrect == false) {
        // Show correct answer when user selected wrong
        backgroundColor = const Color(0xFF10B981).withValues(alpha: 0.1);
        borderColor = const Color(0xFF10B981);
        letterBackgroundColor = const Color(0xFF10B981);
        letterTextColor = Colors.white;
        answerTextColor = const Color(0xFF10B981);
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: AccessibilityUtils.getAccessibleButtonDecoration(
            context,
            backgroundColor: backgroundColor,
          ).copyWith(border: Border.all(color: borderColor, width: 2)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap:
                  (gameController.isGameActive &&
                      !isShowingFeedback &&
                      !isDisabled)
                  ? () => _onAnswerSelected(index, gameController)
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Answer letter (A, B, C, D) with feedback icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: letterBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: isShowingFeedback && isSelected
                            ? Icon(
                                lastAnswerWasCorrect == true
                                    ? Icons.check
                                    : Icons.close,
                                color: letterTextColor,
                                size: 18,
                              )
                            : isShowingFeedback &&
                                  isCorrectAnswer &&
                                  lastAnswerWasCorrect == false
                            ? Icon(
                                Icons.check,
                                color: letterTextColor,
                                size: 18,
                              )
                            : Text(
                                answerLetter,
                                style:
                                    AccessibilityUtils.getAccessibleTextStyle(
                                      context,
                                      TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: letterTextColor,
                                      ),
                                    ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Answer text
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: AccessibilityUtils.getAccessibleTextStyle(
                          context,
                          TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: answerTextColor,
                            height: 1.3,
                          ),
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
          ),
        ),
      ),
    );
  }

  /// Builds the power-up bar at the bottom
  Widget _buildPowerUpBar(GameController gameController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPowerUpButton(
            PowerUpType.fiftyFifty,
            Icons.remove_circle_outline,
            gameController,
          ),
          _buildPowerUpButton(
            PowerUpType.hint,
            Icons.lightbulb_outline,
            gameController,
          ),
          _buildPowerUpButton(
            PowerUpType.extraTime,
            Icons.access_time,
            gameController,
          ),
          _buildPowerUpButton(
            PowerUpType.skip,
            Icons.skip_next,
            gameController,
          ),
          _buildPowerUpButton(
            PowerUpType.secondChance,
            Icons.favorite_border,
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
        '${powerUpType.displayName} power-up',
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
          Container(
            width: 48,
            height: 48,
            decoration:
                AccessibilityUtils.getAccessibleButtonDecoration(
                  context,
                  backgroundColor: canUse
                      ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
                      : const Color(0xFFF3F4F6),
                ).copyWith(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: canUse
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFFE5E7EB),
                    width: 2,
                  ),
                ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: canUse
                    ? () => _usePowerUp(powerUpType, gameController)
                    : null,
                child: Icon(
                  icon,
                  color: canUse
                      ? const Color(0xFF8B5CF6)
                      : const Color(0xFF9CA3AF),
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: AccessibilityUtils.getAccessibleTextStyle(
              context,
              TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: canUse
                    ? const Color(0xFF1F2937)
                    : const Color(0xFF9CA3AF),
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
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: gameController,
            child: ResultScreen(
              isCorrect: isCorrect,
              question: currentQuestion,
              pointsEarned: pointsEarned,
              livesLost: livesLost,
            ),
          ),
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
              powerUpType.displayName,
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
                  powerUpType.description,
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
