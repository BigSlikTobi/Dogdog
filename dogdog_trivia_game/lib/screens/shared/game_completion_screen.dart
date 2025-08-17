import 'package:flutter/material.dart';
import '../../models/achievement.dart';
import '../../models/shared/game_statistics.dart';
import '../../widgets/animated_button.dart';

import '../../services/audio_service.dart';

/// A reusable game completion screen that can be used across different game modes
///
/// This screen provides:
/// - Animated score display with counting effect
/// - Game statistics presentation
/// - Achievement notifications with celebrations
/// - Customizable navigation actions
/// - Consistent visual design across game modes
class GameCompletionScreen extends StatefulWidget {
  /// Game statistics to display
  final GameStatistics statistics;

  /// Newly unlocked achievements to celebrate
  final List<Achievement> newlyUnlockedAchievements;

  /// Title to display at the top of the screen
  final String title;

  /// Subtitle text below the title
  final String subtitle;

  /// Primary action button configuration
  final GameCompletionAction primaryAction;

  /// Secondary action button configuration
  final GameCompletionAction secondaryAction;

  /// Optional custom statistics widgets to display
  final List<Widget> customStatistics;

  /// Background color for the screen
  final Color? backgroundColor;

  /// Whether to show the default statistics section
  final bool showDefaultStatistics;

  const GameCompletionScreen({
    super.key,
    required this.statistics,
    required this.title,
    required this.subtitle,
    required this.primaryAction,
    required this.secondaryAction,
    this.newlyUnlockedAchievements = const [],
    this.customStatistics = const [],
    this.backgroundColor,
    this.showDefaultStatistics = true,
  });

  @override
  State<GameCompletionScreen> createState() => _GameCompletionScreenState();
}

class _GameCompletionScreenState extends State<GameCompletionScreen>
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
        _displayedScore = (widget.statistics.score * _scoreCountAnimation.value)
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
      backgroundColor: widget.backgroundColor ?? const Color(0xFFF8FAFC),
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

                    // Main game completion content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Game completion title
                            _buildTitle(),

                            const SizedBox(height: 40),

                            // Final score display
                            _buildScoreCard(),

                            const SizedBox(height: 30),

                            // Game statistics
                            if (widget.showDefaultStatistics)
                              _buildDefaultStatistics(),

                            // Custom statistics
                            if (widget.customStatistics.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              ...widget.customStatistics,
                            ],

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

  /// Builds the completion title with animation
  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            children: [
              // Completion icon
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

              // Title text
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                widget.subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the score card with animation
  Widget _buildScoreCard() {
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
                colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
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
                Text(
                  AppLocalizations.of(context)!.points,
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),

                const SizedBox(height: 16),

                // Additional score info
                if (widget.statistics.isNewHighScore)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Neuer Rekord!',
                    child: Text(
                      AppLocalizations.of(context)!.newRecord,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the default game statistics section
  Widget _buildDefaultStatistics() {
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
                      AppLocalizations.of(context)!.statisticsTitle,
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
                        '${widget.statistics.correctAnswers}/${widget.statistics.totalQuestions}',
                        const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        'Genauigkeit',
                        '${(widget.statistics.accuracy * 100).round()}%',
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
                colors: [Color(0xFF10B981), Color(0xFF059669)],
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
        // Primary action button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: SecondaryAnimatedButton(
            onPressed: () {
              AudioService().playButtonSound();
              widget.primaryAction.onPressed();
            },
            child: Text(
              widget.primaryAction.label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary action button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlineAnimatedButton(
            onPressed: () {
              AudioService().playButtonSound();
              widget.secondaryAction.onPressed();
            },
            borderColor: const Color(0xFF8B5CF6),
            child: Text(
              widget.secondaryAction.label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

/// Configuration for action buttons in the game completion screen
class GameCompletionAction {
  /// Label text for the button
  final String label;

  /// Callback when the button is pressed
  final VoidCallback onPressed;

  /// Optional icon for the button
  final IconData? icon;

  const GameCompletionAction({
    required this.label,
    required this.onPressed,
    this.icon,
  });
}

/// Extension methods for creating common game completion screen variants
extension GameCompletionScreenVariants on GameCompletionScreen {
  /// Creates a game completion screen for regular trivia games
  static GameCompletionScreen trivia({
    Key? key,
    required GameStatistics statistics,
    required VoidCallback onPlayAgain,
    required VoidCallback onReturnHome,
    List<Achievement> newlyUnlockedAchievements = const [],
    List<Widget> customStatistics = const [],
  }) {
    return GameCompletionScreen(
      key: key,
      statistics: statistics,
      title: 'Spiel beendet!',
      subtitle: 'Gut gespielt! Hier sind deine Ergebnisse:',
      primaryAction: GameCompletionAction(
        label: 'Nochmal spielen',
        onPressed: onPlayAgain,
        icon: Icons.refresh,
      ),
      secondaryAction: GameCompletionAction(
        label: 'Zurück zum Hauptmenü',
        onPressed: onReturnHome,
        icon: Icons.home,
      ),
      newlyUnlockedAchievements: newlyUnlockedAchievements,
      customStatistics: customStatistics,
    );
  }

  /// Creates a game completion screen for breed adventure games
  static GameCompletionScreen breedAdventure({
    Key? key,
    required GameStatistics statistics,
    required VoidCallback onPlayAgain,
    required VoidCallback onReturnHome,
    List<Achievement> newlyUnlockedAchievements = const [],
    List<Widget> customStatistics = const [],
  }) {
    return GameCompletionScreen(
      key: key,
      statistics: statistics,
      title: 'Abenteuer beendet!',
      subtitle: 'Fantastisch! Du hast das Hunderassen-Abenteuer gemeistert:',
      primaryAction: GameCompletionAction(
        label: 'Neues Abenteuer',
        onPressed: onPlayAgain,
        icon: Icons.explore,
      ),
      secondaryAction: GameCompletionAction(
        label: 'Zurück zur Karte',
        onPressed: onReturnHome,
        icon: Icons.map,
      ),
      newlyUnlockedAchievements: newlyUnlockedAchievements,
      customStatistics: customStatistics,
    );
  }

  /// Creates a game completion screen for checkpoint celebrations
  static GameCompletionScreen checkpoint({
    Key? key,
    required GameStatistics statistics,
    required VoidCallback onContinue,
    required VoidCallback onReturnHome,
    List<Achievement> newlyUnlockedAchievements = const [],
    List<Widget> customStatistics = const [],
  }) {
    return GameCompletionScreen(
      key: key,
      statistics: statistics,
      title: 'Checkpoint erreicht!',
      subtitle: 'Großartig! Du hast einen wichtigen Meilenstein erreicht:',
      primaryAction: GameCompletionAction(
        label: 'Weiter spielen',
        onPressed: onContinue,
        icon: Icons.play_arrow,
      ),
      secondaryAction: GameCompletionAction(
        label: 'Pause machen',
        onPressed: onReturnHome,
        icon: Icons.pause,
      ),
      newlyUnlockedAchievements: newlyUnlockedAchievements,
      customStatistics: customStatistics,
      backgroundColor: const Color(0xFFF0F9FF), // Light blue background
    );
  }
}
