import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/achievement.dart';
import 'home_screen.dart';
import 'difficulty_selection_screen.dart';
import '../widgets/animated_button.dart';
import '../utils/animations.dart';
import '../services/audio_service.dart';

/// Game over screen widget displaying final score, achievements, and navigation options
class GameOverScreen extends StatefulWidget {
  final int finalScore;
  final int level;
  final int correctAnswers;
  final int totalQuestions;
  final List<Achievement> newlyUnlockedAchievements;

  const GameOverScreen({
    super.key,
    required this.finalScore,
    required this.level,
    required this.correctAnswers,
    required this.totalQuestions,
    this.newlyUnlockedAchievements = const [],
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _achievementAnimationController;
  late AnimationController _scoreAnimationController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _achievementScaleAnimation;
  late Animation<double> _scoreCountAnimation;

  int _displayedScore = 0;
  bool _showAchievements = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Main animation controller for fade in and scale
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Achievement animation controller
    _achievementAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Score animation controller
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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

    // Achievement scale animation
    _achievementScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _achievementAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Score counting animation
    _scoreCountAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scoreAnimationController, curve: Curves.easeOut),
    );

    // Listen to score animation to update displayed score
    _scoreCountAnimation.addListener(() {
      setState(() {
        _displayedScore = (widget.finalScore * _scoreCountAnimation.value)
            .round();
      });
    });
  }

  void _startAnimations() {
    // Start main animation
    _mainAnimationController.forward();

    // Start score animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _scoreAnimationController.forward();
      }
    });

    // Show achievements after main animation
    if (widget.newlyUnlockedAchievements.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _showAchievements = true;
          });
          _achievementAnimationController.forward();

          // Play achievement sound when achievements are shown
          AudioService().playAchievementSound();
        }
      });
    }
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _achievementAnimationController.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Background Gray
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeInAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeInAnimation.value,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Main game over content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Game Over title
                            _buildGameOverTitle(),

                            const SizedBox(height: 40),

                            // Final score display
                            _buildFinalScoreCard(),

                            const SizedBox(height: 30),

                            // Game statistics
                            _buildGameStatistics(),

                            const SizedBox(height: 30),

                            // Achievement notifications
                            if (_showAchievements &&
                                widget.newlyUnlockedAchievements.isNotEmpty)
                              _buildAchievementNotifications(),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    // Navigation buttons
                    _buildNavigationButtons(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the game over title with animation
  Widget _buildGameOverTitle() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            children: [
              // Game over icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pets,
                  size: 50,
                  color: Color(0xFF4A90E2),
                ),
              ),

              const SizedBox(height: 20),

              // Game over text
              Text(
                'Spiel beendet!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: const Color(0xFF1F2937), // Text Dark
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Gut gespielt! Hier sind deine Ergebnisse:',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF6B7280), // Text Light
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the final score card with animation
  Widget _buildFinalScoreCard() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8B5CF6), // Secondary Purple
                  Color(0xFF7C3AED),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Score icon
                const Icon(Icons.emoji_events, color: Colors.white, size: 48),

                const SizedBox(height: 16),

                // Final score
                Text(
                  '$_displayedScore',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Punkte',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),

                const SizedBox(height: 16),

                // Level reached
                Text(
                  'Level ${widget.level} erreicht',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the game statistics section
  Widget _buildGameStatistics() {
    final accuracy = widget.totalQuestions > 0
        ? (widget.correctAnswers / widget.totalQuestions * 100).round()
        : 0;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics header
                Row(
                  children: [
                    const Icon(
                      Icons.analytics,
                      color: Color(0xFF4A90E2),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Spielstatistiken',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontSize: 20,
                            color: const Color(0xFF1F2937),
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Statistics grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Richtige Antworten',
                        '${widget.correctAnswers}/${widget.totalQuestions}',
                        const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        'Genauigkeit',
                        '$accuracy%',
                        const Color(0xFF4A90E2),
                      ),
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

  /// Builds a single statistic item
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds achievement notifications with celebration animations
  Widget _buildAchievementNotifications() {
    return AnimatedBuilder(
      animation: _achievementScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _achievementScaleAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF10B981), // Success Green
                  Color(0xFF059669),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Achievement header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.celebration,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Neuer Rang freigeschaltet!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Achievement list
                ...widget.newlyUnlockedAchievements.map(
                  (achievement) => _buildAchievementItem(achievement),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds a single achievement item
  Widget _buildAchievementItem(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Achievement icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 28),
          ),

          const SizedBox(width: 16),

          // Achievement details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the navigation buttons with animations
  Widget _buildNavigationButtons() {
    return Column(
      children: [
        // Play again button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: SecondaryAnimatedButton(
            onPressed: _handlePlayAgain,
            child: const Text(
              'Nochmal spielen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Return to home button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlineAnimatedButton(
            onPressed: _handleReturnHome,
            borderColor: const Color(0xFF8B5CF6),
            child: const Text(
              'Zurück zum Hauptmenü',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  /// Handles play again button press
  void _handlePlayAgain() {
    // Play button sound
    AudioService().playButtonSound();

    // Clean up game state
    final gameController = context.read<GameController>();
    gameController.resetGame();

    // Navigate to difficulty selection screen with animation
    Navigator.of(context).pushAndRemoveUntil(
      ModernPageRoute(
        child: const DifficultySelectionScreen(),
        direction: SlideDirection.rightToLeft,
      ),
      (route) => false,
    );
  }

  /// Handles return to home button press
  void _handleReturnHome() {
    // Play button sound
    AudioService().playButtonSound();

    // Clean up game state
    final gameController = context.read<GameController>();
    gameController.resetGame();

    // Navigate to home screen with animation
    Navigator.of(context).pushAndRemoveUntil(
      ModernPageRoute(
        child: const HomeScreen(),
        direction: SlideDirection.leftToRight,
      ),
      (route) => false,
    );
  }
}
