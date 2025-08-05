import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import 'difficulty_selection_screen.dart';
import 'achievements_screen.dart';
import '../services/audio_service.dart';
import '../utils/animations.dart';
import '../utils/responsive.dart';
import '../utils/accessibility.dart';
import '../utils/enum_extensions.dart';
import '../widgets/animated_button.dart';
import '../widgets/audio_settings.dart';
import '../l10n/generated/app_localizations.dart';

/// Home screen widget displaying the DogDog logo, welcome message, and game features
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _logoAnimationController;
  late List<AnimationController> _cardAnimationControllers;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Main animation controller for overall entrance
    _mainAnimationController = AnimationController(
      duration: AppAnimations.extraSlowDuration,
      vsync: this,
    );

    // Logo animation controller for continuous subtle animation
    _logoAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Card animation controllers for staggered entrance
    _cardAnimationControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: AppAnimations.slowDuration,
        vsync: this,
      ),
    );

    // Fade animation for overall entrance
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Slide animation for content
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Logo rotation animation (continuous)
    _logoRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoAnimationController, curve: Curves.linear),
    );
  }

  void _startAnimations() {
    // Start main entrance animation
    _mainAnimationController.forward();

    // Start continuous logo animation
    _logoAnimationController.repeat();

    // Start staggered card animations
    for (int i = 0; i < _cardAnimationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 600 + (i * 200)), () {
        if (mounted) {
          _cardAnimationControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _logoAnimationController.dispose();
    for (final controller in _cardAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccessibilityTheme(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // Background Gray
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: ResponsiveContainer(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              40,
                            ),
                          ),
                          _buildLogo(),
                          SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              30,
                            ),
                          ),
                          _buildWelcomeText(),
                          SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              40,
                            ),
                          ),
                          _buildStartButton(),
                          SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              20,
                            ),
                          ),
                          _buildNavigationButtons(),
                          SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              40,
                            ),
                          ),
                          _buildInfoCards(),
                          SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              30,
                            ),
                          ),
                          _buildAchievementProgress(),
                          SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Builds the DogDog logo with animations
  Widget _buildLogo() {
    final logoSize = ResponsiveUtils.getResponsiveIconSize(context, 120);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 60);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoScaleAnimation,
        _logoRotationAnimation,
      ]),
      builder: (context, child) {
        return Semantics(
          label: AppLocalizations.of(context).accessibility_appLogo,
          child: Transform.scale(
            scale: _logoScaleAnimation.value,
            child: Transform.rotate(
              angle: AccessibilityUtils.prefersReducedMotion(context)
                  ? 0
                  : _logoRotationAnimation.value * 0.1, // Subtle rotation
              child: Container(
                width: logoSize,
                height: logoSize,
                decoration:
                    AccessibilityUtils.getAccessibleCircularDecoration(
                      context,
                    ).copyWith(
                      color: const Color(0xFF4A90E2), // Primary Blue
                    ),
                child: Icon(Icons.pets, size: iconSize, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the welcome text
  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context).homeScreen_welcomeTitle,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: const Color(0xFF1F2937), // Text Dark
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          AppLocalizations.of(context).homeScreen_welcomeSubtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF6B7280), // Text Light
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the main start button with animation
  Widget _buildStartButton() {
    final audioService = AudioService();

    return SizedBox(
      width: double.infinity,
      child: PrimaryAnimatedButton(
        onPressed: () async {
          await audioService.playButtonSound();
          if (mounted) {
            Navigator.of(context).push(
              SlidePageRoute(
                child: const DifficultySelectionScreen(),
                direction: SlideDirection.rightToLeft,
              ),
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow, size: 24),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).homeScreen_startButton,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds navigation buttons for achievements and other features
  Widget _buildNavigationButtons() {
    final audioService = AudioService();

    return Row(
      children: [
        Expanded(
          child: OutlineAnimatedButton(
            onPressed: () async {
              await audioService.playButtonSound();
              if (mounted) {
                Navigator.of(
                  context,
                ).push(FadePageRoute(child: const AchievementsScreen()));
              }
            },
            borderColor: const Color(0xFF8B5CF6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).homeScreen_achievementsButton,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8B5CF6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlineAnimatedButton(
          onPressed: () async {
            await audioService.playButtonSound();
            if (mounted) {
              await AudioSettingsDialog.show(context);
            }
          },
          borderColor: const Color(0xFF4A90E2),
          child: Icon(Icons.settings, size: 20, color: const Color(0xFF4A90E2)),
        ),
      ],
    );
  }

  /// Builds informational cards about the game with staggered animations
  Widget _buildInfoCards() {
    final l10n = AppLocalizations.of(context);

    final cardData = [
      {
        'icon': Icons.quiz,
        'title': l10n.homeScreen_infoCard_funQuestions_title,
        'description': l10n.homeScreen_infoCard_funQuestions_description,
        'color': const Color(0xFF10B981), // Green
      },
      {
        'icon': Icons.school,
        'title': l10n.homeScreen_infoCard_educational_title,
        'description': l10n.homeScreen_infoCard_educational_description,
        'color': const Color(0xFFF59E0B), // Yellow
      },
      {
        'icon': Icons.trending_up,
        'title': l10n.homeScreen_infoCard_progress_title,
        'description': l10n.homeScreen_infoCard_progress_description,
        'color': const Color(0xFF8B5CF6), // Purple
      },
    ];

    return Column(
      children: List.generate(cardData.length, (index) {
        return Column(
          children: [
            if (index > 0) const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _cardAnimationControllers[index],
              builder: (context, child) {
                return AppAnimations.fadeAndScale(
                  animation: _cardAnimationControllers[index],
                  child: _buildInfoCard(
                    icon: cardData[index]['icon'] as IconData,
                    title: cardData[index]['title'] as String,
                    description: cardData[index]['description'] as String,
                    color: cardData[index]['color'] as Color,
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }

  /// Builds a single info card
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
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
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the achievement progress section
  Widget _buildAchievementProgress() {
    return Consumer<ProgressService>(
      builder: (context, progressService, child) {
        final l10n = AppLocalizations.of(context);
        final progress = progressService.currentProgress;
        final unlockedCount = progress.unlockedAchievements.length;
        final totalCount = progress.achievements.length;
        final progressPercentage = totalCount > 0
            ? unlockedCount / totalCount
            : 0.0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.homeScreen_progress_title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '$unlockedCount/$totalCount',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progressPercentage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.homeScreen_progress_currentRank(
                  progress.currentRank.displayName(context),
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              if (progress.nextRank != null)
                Text(
                  l10n.homeScreen_progress_nextRank(
                    progress.nextRank!.displayName(context),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
