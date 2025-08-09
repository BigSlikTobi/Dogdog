import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../controllers/game_controller.dart';
import '../models/question.dart';
import '../models/achievement.dart';
import '../services/progress_service.dart';
import 'game_over_screen.dart';
import '../widgets/animated_button.dart';
import '../widgets/success_animation_widget.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_spacing.dart';
import '../utils/animations.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/lives_indicator.dart';

/// Result screen widget for displaying answer feedback and fun facts
class ResultScreen extends StatefulWidget {
  final bool isCorrect;
  final Question question;
  final int pointsEarned;
  final int livesLost;

  const ResultScreen({
    super.key,
    required this.isCorrect,
    required this.question,
    required this.pointsEarned,
    required this.livesLost,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _celebrationController;
  late AnimationController _scoreAnimationController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _scoreCountAnimation;

  int _displayedScore = 0;
  int _targetScore = 0;
  bool _showSuccessOverlay = false;
  bool _showIncorrectOverlay = false;
  Timer? _incorrectOverlayTimer;

  @override
  void initState() {
    super.initState();
    _showSuccessOverlay = widget.isCorrect;
    _showIncorrectOverlay = !widget.isCorrect;
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Main animation controller for fade in and scale
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Celebration animation for correct answers
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Score animation controller
    _scoreAnimationController = AnimationController(
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

    // Scale animation for feedback card
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

    // Score counting animation
    _scoreCountAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scoreAnimationController, curve: Curves.easeOut),
    );

    // Listen to score animation to update displayed score
    _scoreCountAnimation.addListener(() {
      setState(() {
        _displayedScore = (_targetScore * _scoreCountAnimation.value).round();
      });
    });
  }

  void _startAnimations() {
    // Get current and target scores from game controller
    final gameController = context.read<GameController>();
    _displayedScore = gameController.score - widget.pointsEarned;
    _targetScore = gameController.score;

    // Start main animation
    _mainAnimationController.forward();

    // Start celebration animation for correct answers
    if (widget.isCorrect) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          _celebrationController.forward();
        }
      });
    } else {
      // Start auto-dismiss timer for incorrect answers (1 second delay)
      _incorrectOverlayTimer = Timer(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _showIncorrectOverlay = false;
          });
        }
      });
    }

    // Start score animation
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _scoreAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _incorrectOverlayTimer?.cancel();
    _mainAnimationController.dispose();
    _celebrationController.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ModernColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Consumer<GameController>(
            builder: (context, gameController, child) {
              return Stack(
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
                              // Top bar with lives and score
                              _buildTopBar(gameController),

                              ModernSpacing.verticalSpaceXL,

                              // Main feedback area
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ModernSpacing.verticalSpaceLG,

                                      // Feedback message with animation
                                      _buildFeedbackMessage(),

                                      ModernSpacing.verticalSpaceLG,

                                      // Fun fact card
                                      _buildFunFactCard(),

                                      ModernSpacing.verticalSpaceLG,

                                      // Score update display
                                      _buildScoreUpdate(),

                                      ModernSpacing.verticalSpaceLG,
                                    ],
                                  ),
                                ),
                              ),

                              // Next question button
                              _buildNextQuestionButton(gameController),

                              ModernSpacing.verticalSpaceLG,
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Success animation overlay for correct answers
                  if (_showSuccessOverlay) _buildSuccessAnimationOverlay(),

                  // Gentle feedback animation for incorrect answers
                  if (_showIncorrectOverlay) _buildIncorrectFeedbackOverlay(),
                ],
              );
            },
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
          _buildScoreDisplay(),
        ],
      ),
    );
  }

  /// Builds the lives display using heart icons
  Widget _buildLivesDisplay(int lives) {
    return LivesIndicator(
      lives: lives,
      size: 24,
      color: const Color(0xFFEF4444),
    );
  }

  /// Builds the animated score display
  Widget _buildScoreDisplay() {
    return Row(
      children: [
        Text(
          '$_displayedScore',
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
    );
  }

  /// Builds the main feedback message with celebration animation
  Widget _buildFeedbackMessage() {
    return AnimatedBuilder(
      animation: widget.isCorrect ? _celebrationAnimation : _scaleAnimation,
      builder: (context, child) {
        final scale = widget.isCorrect
            ? 1.0 + (_celebrationAnimation.value * 0.1)
            : _scaleAnimation.value;

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            decoration: BoxDecoration(
              color: widget.isCorrect
                  ? const Color(0xFF10B981) // Success Green
                  : const Color(0xFFEF4444), // Error Red
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color:
                      (widget.isCorrect
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444))
                          .withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Feedback icon
                Icon(
                  widget.isCorrect ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 48,
                ),

                const SizedBox(height: 16),

                // Feedback text
                Text(
                  widget.isCorrect
                      ? AppLocalizations.of(context).feedback_correct
                      : AppLocalizations.of(context).feedback_incorrect,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                // Correct answer display (for incorrect answers)
                if (!widget.isCorrect) ...[
                  Text(
                    'The correct answer was:', // This could be localized if needed
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.question.correctAnswer,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the fun fact card with colored background
  Widget _buildFunFactCard() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF8B5CF6), // Secondary Purple
                  const Color(0xFF7C3AED),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Fun fact header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).resultScreen_funFact,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Fun fact text
                Text(
                  widget.question.funFact,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the score update display with animation
  Widget _buildScoreUpdate() {
    if (widget.pointsEarned <= 0) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _scoreCountAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _scoreCountAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981), width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_circle,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '+${widget.pointsEarned} ${AppLocalizations.of(context).gameScreen_score}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the next question button with proper navigation
  Widget _buildNextQuestionButton(GameController gameController) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: SecondaryAnimatedButton(
        onPressed: () => _handleNextQuestion(gameController),
        child: Text(
          AppLocalizations.of(context).resultScreen_nextQuestion,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Handles the next question navigation
  void _handleNextQuestion(GameController gameController) async {
    // Clear feedback state in game controller
    gameController.clearFeedback();

    // Check if game is over
    if (gameController.isGameOver) {
      await _navigateToGameOver(gameController);
      return;
    }

    // Move to next question
    gameController.nextQuestion();

    // Return to game screen
    Navigator.of(context).pop();
  }

  /// Builds the success animation overlay for correct answers
  Widget _buildSuccessAnimationOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _celebrationAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: (_celebrationAnimation.value * 0.9).clamp(0.0, 1.0),
            child: Container(
              color: ModernColors.overlayBackground,
              child: Center(
                child: SuccessAnimationVariants.correctAnswer(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.width * 0.4,
                  onAnimationComplete: () {
                    // Animation completed, but overlay still needs to be dismissed
                  },
                  onDismissComplete: () {
                    // Hide the overlay completely when animation is fully dismissed
                    if (mounted) {
                      setState(() {
                        _showSuccessOverlay = false;
                      });
                    }
                  },
                  semanticLabel: 'Correct answer celebration animation',
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the gentle feedback animation overlay for incorrect answers
  Widget _buildIncorrectFeedbackOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          // Create a gentle shake effect for incorrect answers
          final shakeOffset = _scaleAnimation.value < 0.5
              ? (1.0 - _scaleAnimation.value * 2) * 5.0
              : 0.0;

          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.8 + (_scaleAnimation.value * 0.2),
                      child: Image.asset(
                        'assets/images/fail.png',
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.width * 0.4,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to the original icon if image fails to load
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              color: ModernColors.error.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ModernColors.error.withValues(
                                  alpha: 0.3,
                                ),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: MediaQuery.of(context).size.width * 0.15,
                              color: ModernColors.error.withValues(alpha: 0.7),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Navigates to the game over screen with proper data
  Future<void> _navigateToGameOver(GameController gameController) async {
    // Get progress service to record game completion and check for achievements
    final progressService = context.read<ProgressService>();

    // Record game completion
    await progressService.recordGameCompletion(
      finalScore: gameController.score,
      levelReached: gameController.level,
    );

    // Get game statistics
    final stats = gameController.getGameStatistics();

    // Check for newly unlocked achievements
    final newlyUnlocked = <Achievement>[];
    if (widget.isCorrect) {
      final unlockedAchievements = await progressService.recordCorrectAnswer(
        pointsEarned: widget.pointsEarned,
        currentStreak: gameController.streak,
      );
      newlyUnlocked.addAll(unlockedAchievements);
    } else {
      await progressService.recordIncorrectAnswer();
    }

    // Navigate to game over screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        ModernPageRoute(
          child: ChangeNotifierProvider.value(
            value: gameController,
            child: GameOverScreen(
              finalScore: gameController.score,
              level: gameController.level,
              correctAnswers: stats['correctAnswers'] as int,
              totalQuestions: stats['totalQuestions'] as int,
              newlyUnlockedAchievements: newlyUnlocked,
            ),
          ),
          direction: SlideDirection.rightToLeft,
        ),
      );
    }
  }
}
