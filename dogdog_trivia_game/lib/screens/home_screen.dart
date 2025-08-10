import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../design_system/modern_shadows.dart';
import '../widgets/gradient_button.dart';
import '../widgets/audio_settings.dart';
import '../utils/responsive.dart';
import '../utils/animations.dart';
import '../utils/accessibility.dart';
import '../l10n/generated/app_localizations.dart';
import '../controllers/treasure_map_controller.dart';
import '../models/enums.dart';
import '../utils/path_localization.dart';
import 'treasure_map_screen.dart';

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
                _buildSettingsButton(),
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
                            ModernSpacing.verticalSpaceXL,
                            _buildLogo(),
                            ModernSpacing.verticalSpaceLG,
                            _buildWelcomeText(),
                            ModernSpacing.verticalSpaceXL,
                            _buildPathSelectionSection(),
                            ModernSpacing.verticalSpaceXL,
                          ],
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
                await AudioSettingsDialog.show(context);
              }
            },
            child: Semantics(
              label: 'Settings',
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
        label: '${pathType.getLocalizedName(context)} path card',
        selected: isSelected,
        button: true,
        child: GestureDetector(
          onTap: () {
            treasureMapController.initializePath(pathType);
            Navigator.of(context).push(
              ModernPageRoute(
                child: const TreasureMapScreen(),
                direction: SlideDirection.rightToLeft,
              ),
            );
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
                  GradientButton.small(
                    text: AppLocalizations.of(context).pathSelection_start,
                    gradientColors: _getGradientForPath(pathType),
                    icon: Icons.play_arrow,
                    onPressed: () {
                      treasureMapController.initializePath(pathType);
                      Navigator.of(context).push(
                        ModernPageRoute(
                          child: const TreasureMapScreen(),
                          direction: SlideDirection.rightToLeft,
                        ),
                      );
                    },
                    expandWidth: true,
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
      case PathType.dogBreeds:
        iconData = Icons.pets;
        break;
      case PathType.dogTraining:
        iconData = Icons.school;
        break;
      case PathType.healthCare:
        iconData = Icons.local_hospital;
        break;
      case PathType.dogBehavior:
        iconData = Icons.psychology;
        break;
      case PathType.dogHistory:
        iconData = Icons.history_edu;
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

  // Get gradient colors for the specified path type
  List<Color> _getGradientForPath(PathType pathType) {
    switch (pathType) {
      case PathType.dogBreeds:
        return ModernColors.blueGradient;
      case PathType.dogTraining:
        return ModernColors.greenGradient;
      case PathType.healthCare:
        return ModernColors.redGradient;
      case PathType.dogBehavior:
        return ModernColors.purpleGradient;
      case PathType.dogHistory:
        return ModernColors.yellowGradient;
    }
  }
}
