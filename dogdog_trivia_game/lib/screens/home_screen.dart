import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../design_system/modern_shadows.dart';
import '../widgets/gradient_button.dart';
import '../widgets/settings_dialog.dart';
import '../utils/responsive.dart';
import '../utils/accessibility.dart';
import '../utils/game_state_animations.dart';
import '../l10n/generated/app_localizations.dart';
import '../controllers/treasure_map_controller.dart';
import '../controllers/companion_controller.dart';
import '../models/enums.dart';
import '../utils/path_localization.dart';
import 'treasure_map_screen.dart';
import 'dog_breeds_adventure_screen.dart';
import 'customization_screen.dart';
import 'mindful_moments_screen.dart';
import 'memory_journal_screen.dart';
import 'parental_dashboard_screen.dart';
import '../widgets/interactive_companion_widget.dart';

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

  late PageController _pathPageController;
  double _currentCarouselPage = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _pathPageController = PageController(viewportFraction: 0.68);
    _pathPageController.addListener(() {
      setState(() => _currentCarouselPage = _pathPageController.page ?? 0.0);
    });
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
    _pathPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect reduced motion preferences for animations
    final animationDuration = ResponsiveUtils.getAccessibleAnimationDuration(
      context,
      const Duration(milliseconds: 1200),
    );
    _mainAnimationController.duration = animationDuration;

    final decorationDuration = ResponsiveUtils.getAccessibleAnimationDuration(
      context,
      const Duration(seconds: 25),
    );
    _decorationAnimationController.duration = decorationDuration;

    return AccessibilityTheme(
      child: Scaffold(
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
                    child: ResponsiveContainer(
                      padding: ResponsiveUtils.getResponsivePadding(context),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ModernSpacing.verticalSpaceMD,
                            // Interactive companion as centerpiece
                            const InteractiveCompanionWidget(),
                            ModernSpacing.verticalSpaceMD,
                            // Quick action buttons
                            _buildQuickActions(),
                            ModernSpacing.verticalSpaceLG,
                            // Section title for adventures
                            _buildSectionTitle(),
                            ModernSpacing.verticalSpaceSM,
                            _buildPathSelectionSection(),
                            ModernSpacing.verticalSpaceXL,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Buttons on top so they're clickable
                _buildSettingsButton(),
                _buildCompanionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds floating decorative elements (stars, circles) with subtle animations
  Widget _buildFloatingDecorations() {
    return IgnorePointer(
      child: AnimatedBuilder(
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
      ),
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

    return Text(
      l10n.homeScreen_welcomeTitle,
      style: ResponsiveUtils.getAccessibleTextStyle(
        context,
        ModernTypography.headingLarge.copyWith(color: ModernColors.textPrimary),
      ),
      textAlign: TextAlign.center,
      semanticsLabel: l10n.homeScreen_welcomeTitle,
    );
  }

  /// Builds a small settings button positioned in the upper right corner
  Widget _buildSettingsButton() {
    final audioService = AudioService();

    return Positioned(
      top: 16,
      right: 16,
      child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () async {
                await audioService.playButtonSound();
                if (mounted) {
                  await SettingsDialog.show(context);
                }
              },
              child: Semantics(
                label: AppLocalizations.of(context).semantics_settings,
                button: true,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.settings,
                    size: 20,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }

  /// Builds a companion menu button positioned in the upper left corner
  Widget _buildCompanionButton() {
    final audioService = AudioService();

    return Consumer<CompanionController>(
      builder: (context, companionCtrl, _) {
        final companion = companionCtrl.companion;
        final hasCompanion = companion != null;

        return Positioned(
          top: 16,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.primaryPurple.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () async {
                  await audioService.playButtonSound();
                  if (mounted) {
                    _showCompanionMenu(context, hasCompanion, companion);
                  }
                },
                child: Semantics(
                  label: AppLocalizations.of(context).semantics_companionMenu,
                  button: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasCompanion ? companion.breed.emoji : '🐾',
                          style: const TextStyle(fontSize: 24),
                        ),
                          if (hasCompanion) ...[
                            const SizedBox(width: 6),
                            Text(
                              companion.name,
                              style: ModernTypography.bodySmall.copyWith(
                                color: ModernColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCompanionMenu(BuildContext context, bool hasCompanion, dynamic companion) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(ModernSpacing.lg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ModernSpacing.verticalSpaceMD,
            // Header
            Row(
              children: [
                Text(
                  hasCompanion ? companion.breed.emoji : '🐾',
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasCompanion ? companion.name : AppLocalizations.of(context).companion_yourCompanion,
                        style: ModernTypography.headingSmall,
                      ),
                      if (hasCompanion)
                        Text(
                          '${companion.stage.displayName} · ${AppLocalizations.of(context).companion_bond((companion.bondLevel * 100).toInt())}',
                          style: ModernTypography.caption.copyWith(
                            color: ModernColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            ModernSpacing.verticalSpaceLG,
            // Menu items
            _buildMenuItem(
              icon: '🎨',
              title: AppLocalizations.of(context).menu_customize_title,
              subtitle: AppLocalizations.of(context).menu_customize_subtitle,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomizationScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: '🧘',
              title: AppLocalizations.of(context).menu_mindful_title,
              subtitle: AppLocalizations.of(context).menu_mindful_subtitle,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MindfulMomentsScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: '📔',
              title: AppLocalizations.of(context).menu_journal_title,
              subtitle: AppLocalizations.of(context).menu_journal_subtitle,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MemoryJournalScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: '👨‍👩‍👧',
              title: AppLocalizations.of(context).menu_parent_title,
              subtitle: AppLocalizations.of(context).menu_parent_subtitle,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ParentalDashboardScreen()),
                );
              },
            ),
            ModernSpacing.verticalSpaceMD,
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: ModernSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ModernColors.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ModernTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: ModernTypography.caption.copyWith(
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: ModernColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Quick action buttons for companion interactions
  Widget _buildQuickActions() {
    return Consumer<CompanionController>(
      builder: (context, controller, chlid) {
        final treats = controller.companion?.treats ?? 0;
        
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildQuickActionButton(
              emoji: '🍖',
              label: AppLocalizations.of(context).action_feed,
              badgeText: '$treats',
              onTap: _handleFeed,
            ),
            _buildQuickActionButton(
              emoji: '🎨',
              label: AppLocalizations.of(context).action_style,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomizationScreen()),
              ),
            ),
            _buildQuickActionButton(
              emoji: '🧘',
              label: AppLocalizations.of(context).action_relax,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MindfulMomentsScreen()),
              ),
            ),
            _buildQuickActionButton(
              emoji: '📔',
              label: AppLocalizations.of(context).action_journal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MemoryJournalScreen()),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleFeed() async {
    final controller = context.read<CompanionController>();
    final success = await controller.feedCompanion();
    
    if (mounted) {
      if (success) {
        AudioService().playButtonSound(); // Reuse bark/crunch
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).feedback_feed_success),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        String msg = AppLocalizations.of(context).feedback_feed_notEnough;
        if ((controller.companion?.hunger ?? 0) >= 1.0) {
          msg = AppLocalizations.of(context).feedback_feed_full;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Widget _buildQuickActionButton({
    required String emoji,
    required String label,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    return GestureDetector(
      onTap: () async {
        await AudioService().playButtonSound();
        onTap();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ModernColors.primaryPurple.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: ModernTypography.caption.copyWith(
                    color: ModernColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (badgeText != null)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ModernColors.primaryPink,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Section title for adventures
  Widget _buildSectionTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                ModernColors.primaryPurple.withValues(alpha: 0.5),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            AppLocalizations.of(context).home_trainingAdventures,
            style: ModernTypography.bodyMedium.copyWith(
              color: ModernColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ModernColors.primaryPurple.withValues(alpha: 0.5),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Path selection section integrated into home screen
  Widget _buildPathSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildPathCarousel(),
        ModernSpacing.verticalSpaceSM,
        _buildCarouselIndicators(),
      ],
    );
  }

  // 3D Carousel implementation
  Widget _buildPathCarousel() {
    final height = 280.0; // Increased height from 230.0 to 280.0
    return SizedBox(
      height: height,
      child: PageView.builder(
        controller: _pathPageController,
        itemCount: PathType.values.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) => _buildCarouselCard(index, height),
      ),
    );
  }

  Widget _buildCarouselCard(int index, double height) {
    final pathType = PathType.values[index];
    final treasureMapController = Provider.of<TreasureMapController>(context);
    final isSelected = treasureMapController.currentPath == pathType;

    final delta = index - _currentCarouselPage;
    // Clamp for transforms
    final clamped = delta.clamp(-1.0, 1.0);
    // 3D values
    final scale = 1 - (clamped.abs() * 0.15); // 0.85 - 1.0
    final rotationY = clamped * 0.35; // radians
    final translationX = clamped * -30.0; // subtle parallax
    final elevation = 8.0 + (1 - clamped.abs()) * 10.0;

    final gradient = _getGradientForPath(pathType);

    return AnimatedBuilder(
      animation: _pathPageController,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..translate(translationX)
            ..rotateY(rotationY)
            ..scale(scale, scale),
          child: Opacity(opacity: (1 - clamped.abs() * 0.4), child: child),
        );
      },
      child: Semantics(
        label: AppLocalizations.of(context).semantics_pathCard(pathType.getLocalizedName(context)),
        selected: isSelected,
        button: true,
        child: GestureDetector(
          onTap: () {
            _navigateToPath(pathType);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: elevation,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  gradient.first.withValues(alpha: 0.95),
                  gradient.last.withValues(alpha: 0.92),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(ModernSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                // inner glass layer
                color: Colors.white.withValues(alpha: 0.75),
                backgroundBlendMode: BlendMode.luminosity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildCarouselIcon(pathType),
                      const Spacer(),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ModernColors.primaryGreen.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Text(
                            AppLocalizations.of(context).pathSelection_current,
                            style: ModernTypography.caption.copyWith(
                              color: ModernColors.primaryGreen,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                  ModernSpacing.verticalSpaceSM,
                  Text(
                    pathType.getLocalizedName(context),
                    style: ModernTypography.headingSmall.copyWith(
                      fontSize: 20,
                      color: ModernColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  ModernSpacing.verticalSpaceXS,
                  Expanded(
                    child: Text(
                      pathType.getLocalizedDescription(context),
                      style: ModernTypography.bodySmall.copyWith(
                        color: ModernColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ModernSpacing.verticalSpaceSM,
                  GameStateAnimations.buildBouncingButton(
                    onPressed: () => _navigateToPath(pathType),
                    child: GradientButton.small(
                      text: AppLocalizations.of(context).action_train,
                      gradientColors: _getGradientForPath(pathType),
                      icon: Icons.school, // Changed icon to school/training
                      onPressed: () {
                        _navigateToPath(pathType);
                      },
                      expandWidth: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselIndicators() {
    final total = PathType.values.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: (i - _currentCarouselPage).abs() < 0.5 ? 22 : 10,
            decoration: BoxDecoration(
              color: (i - _currentCarouselPage).abs() < 0.5
                  ? ModernColors.primaryPurple
                  : ModernColors.primaryPurple.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
      ],
    );
  }

  Widget _buildCarouselIcon(PathType pathType) {
    IconData iconData;
    switch (pathType) {
      case PathType.dogTrivia:
        iconData = Icons.pets;
        break;
      case PathType.puppyQuest:
        iconData = Icons.camera_alt;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(iconData, color: ModernColors.primaryPurple, size: 26),
    );
  }

  /// Navigates to the appropriate screen based on path type with smooth animations
  void _navigateToPath(PathType pathType) async {
    final audioService = AudioService();
    await audioService.playButtonSound();
    if (!mounted) return;
    final navigator = Navigator.of(context);

    if (pathType == PathType.puppyQuest) {
      navigator.push(
        GameStateAnimations.createScaleTransition(
          child: const DogBreedsAdventureScreen(),
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
        ),
      );
    } else {
      final treasureMapController = Provider.of<TreasureMapController>(
        context,
        listen: false,
      );
      treasureMapController.initializePath(pathType);
      navigator.push(
        GameStateAnimations.createSlideTransition(
          child: const TreasureMapScreen(),
          begin: const Offset(1.0, 0.0),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        ),
      );
    }
  }

  // Get gradient colors for the specified path type
  List<Color> _getGradientForPath(PathType pathType) {
    switch (pathType) {
      case PathType.dogTrivia:
        return ModernColors.blueGradient;
      case PathType.puppyQuest:
        return ModernColors.orangeGradient;
    }
  }
}
