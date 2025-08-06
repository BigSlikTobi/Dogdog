import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../services/audio_service.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../design_system/modern_shadows.dart';
import '../widgets/gradient_button.dart';
import '../widgets/modern_card.dart';
import '../widgets/audio_settings.dart';
import '../utils/responsive.dart';
import '../utils/enum_extensions.dart';
import '../l10n/generated/app_localizations.dart';
import 'difficulty_selection_screen.dart';
import 'achievements_screen.dart';

/// Home screen with gradient background and decorative elements.
///
/// Features:
/// - Gradient background with floating decorative elements
/// - Centered dog logo image with zoom-in entrance animation
/// - Modern typography hierarchy for welcome text
/// - GradientButton component for start button
/// - Floating decorative elements with subtle animations
/// - Responsive design for different screen sizes
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _decorationAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _decorationAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Main animation controller for overall entrance
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Decoration animation controller for floating elements
    _decorationAnimationController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    );

    // Fade animation for overall entrance
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Slide animation for content
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainAnimationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Decoration floating animation
    _decorationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _decorationAnimationController,
        curve: Curves.linear,
      ),
    );
  }

  void _startAnimations() {
    // Start main entrance animation
    _mainAnimationController.forward();

    // Start continuous decoration animation
    _decorationAnimationController.repeat();
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _decorationAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: ModernColors.createLinearGradient(
            ModernColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildFloatingDecorations(),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: ModernSpacing.responsivePadding(
                      context,
                      mobile: ModernSpacing.screenPaddingInsets,
                      tablet: const EdgeInsets.symmetric(
                        horizontal: 64.0,
                        vertical: 32.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ModernSpacing.verticalSpaceXL,
                        _buildLogo(),
                        ModernSpacing.verticalSpaceLG,
                        _buildWelcomeText(),
                        ModernSpacing.verticalSpaceXL,
                        _buildStartButton(),
                        ModernSpacing.verticalSpaceLG,
                        _buildNavigationButtons(),
                        ModernSpacing.verticalSpaceXL,
                        _buildAchievementProgress(),
                        ModernSpacing.verticalSpaceMD,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds floating decorative elements (stars, circles) with subtle animations
  Widget _buildFloatingDecorations() {
    return AnimatedBuilder(
      animation: _decorationAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Floating star 1
            Positioned(
              top: 100 + (20 * _decorationAnimation.value),
              left: 50,
              child: Transform.rotate(
                angle: _decorationAnimation.value * 2 * 3.14159,
                child: Icon(
                  Icons.star,
                  color: ModernColors.primaryYellow.withValues(alpha: 0.3),
                  size: 24,
                ),
              ),
            ),
            // Floating circle 1
            Positioned(
              top: 200 + (15 * _decorationAnimation.value),
              right: 80,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: ModernColors.primaryBlue.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Floating star 2
            Positioned(
              top: 350 + (25 * _decorationAnimation.value),
              left: MediaQuery.of(context).size.width * 0.8,
              child: Transform.rotate(
                angle: -_decorationAnimation.value * 1.5 * 3.14159,
                child: Icon(
                  Icons.star_outline,
                  color: ModernColors.primaryPurple.withValues(alpha: 0.25),
                  size: 20,
                ),
              ),
            ),
            // Floating circle 2
            Positioned(
              top: 450 + (18 * _decorationAnimation.value),
              left: 30,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: ModernColors.primaryGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Floating star 3
            Positioned(
              bottom: 200 + (22 * _decorationAnimation.value),
              right: 40,
              child: Transform.rotate(
                angle: _decorationAnimation.value * 1.2 * 3.14159,
                child: Icon(
                  Icons.star,
                  color: ModernColors.warning.withValues(alpha: 0.2),
                  size: 18,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds the centered dog logo with smooth zoom-in animation
  Widget _buildLogo() {
    final logoSize = ResponsiveUtils.getResponsiveIconSize(context, 160);

    return AnimatedBuilder(
      animation: _logoScaleAnimation,
      builder: (context, child) {
        return Semantics(
          label: AppLocalizations.of(context).accessibility_appLogo,
          child: Transform.scale(
            scale: _logoScaleAnimation.value,
            child: Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: ModernShadows.large,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to pets icon if image fails to load
                    return Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        gradient: ModernColors.createLinearGradient(
                          ModernColors.purpleGradient,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pets,
                        size: logoSize * 0.5,
                        color: ModernColors.textOnDark,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the welcome text with modern typography hierarchy
  Widget _buildWelcomeText() {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Text(
          l10n.homeScreen_welcomeTitle,
          style: ModernTypography.headingLarge.copyWith(
            color: ModernColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        ModernSpacing.verticalSpaceSM,
        Text(
          l10n.homeScreen_welcomeSubtitle,
          style: ModernTypography.withSecondaryColor(
            ModernTypography.bodyLarge,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the main start button using GradientButton component
  Widget _buildStartButton() {
    final l10n = AppLocalizations.of(context);
    final audioService = AudioService();

    return GradientButton.large(
      text: l10n.homeScreen_startButton,
      onPressed: () async {
        await audioService.playButtonSound();
        if (mounted) {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const DifficultySelectionScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            ),
                          ),
                      child: child,
                    );
                  },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        }
      },
      gradientColors: ModernColors.purpleGradient,
      expandWidth: true,
      icon: Icons.play_arrow,
      semanticLabel: l10n.homeScreen_startButton,
    );
  }

  /// Builds navigation buttons for achievements and settings
  Widget _buildNavigationButtons() {
    final l10n = AppLocalizations.of(context);
    final audioService = AudioService();

    return Row(
      children: [
        Expanded(
          child: GradientButton(
            text: l10n.homeScreen_achievementsButton,
            onPressed: () async {
              await audioService.playButtonSound();
              if (mounted) {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AchievementsScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              }
            },
            gradientColors: ModernColors.yellowGradient,
            icon: Icons.emoji_events,
            semanticLabel: l10n.homeScreen_achievementsButton,
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
          ),
        ),
        ModernSpacing.horizontalSpaceMD,
        GradientButton(
          text: '',
          onPressed: () async {
            await audioService.playButtonSound();
            if (mounted) {
              await AudioSettingsDialog.show(context);
            }
          },
          gradientColors: ModernColors.blueGradient,
          icon: Icons.settings,
          semanticLabel: 'Settings',
          padding: const EdgeInsets.all(16.0),
        ),
      ],
    );
  }

  /// Builds the achievement progress section with modern styling
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

        return ModernCard.gradient(
          gradientColors: ModernColors.purpleGradient,
          child: Padding(
            padding: ModernSpacing.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: ModernColors.textOnDark,
                      size: 28,
                    ),
                    ModernSpacing.horizontalSpaceSM,
                    Expanded(
                      child: Text(
                        l10n.homeScreen_progress_title,
                        style: ModernTypography.headingSmall.copyWith(
                          color: ModernColors.textOnDark,
                        ),
                      ),
                    ),
                    Text(
                      '$unlockedCount/$totalCount',
                      style: ModernTypography.headingSmall.copyWith(
                        color: ModernColors.textOnDark,
                      ),
                    ),
                  ],
                ),
                ModernSpacing.verticalSpaceMD,
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: ModernColors.textOnDark.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressPercentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: ModernColors.textOnDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                ModernSpacing.verticalSpaceSM,
                Text(
                  l10n.homeScreen_progress_currentRank(
                    progress.currentRank.displayName(context),
                  ),
                  style: ModernTypography.bodyMedium.copyWith(
                    color: ModernColors.textOnDark.withValues(alpha: 0.9),
                  ),
                ),
                if (progress.nextRank != null)
                  Text(
                    l10n.homeScreen_progress_nextRank(
                      progress.nextRank!.displayName(context),
                    ),
                    style: ModernTypography.bodyMedium.copyWith(
                      color: ModernColors.textOnDark.withValues(alpha: 0.9),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
