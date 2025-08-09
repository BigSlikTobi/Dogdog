import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/treasure_map_controller.dart';
import '../models/enums.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../design_system/modern_shadows.dart';
import '../widgets/modern_card.dart';
import '../widgets/gradient_button.dart';
import '../utils/responsive.dart';
import '../utils/path_localization.dart';
import '../l10n/generated/app_localizations.dart';
import 'treasure_map_screen.dart';

/// Screen for selecting which themed learning path to follow
class PathSelectionScreen extends StatefulWidget {
  const PathSelectionScreen({super.key});

  @override
  State<PathSelectionScreen> createState() => _PathSelectionScreenState();
}

class _PathSelectionScreenState extends State<PathSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: ModernColors.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: EdgeInsets.all(ModernSpacing.lg),
                    child: Column(
                      children: [
                        _buildHeader(isMobile),
                        SizedBox(height: ModernSpacing.xl),
                        Expanded(child: _buildPathGrid(context, isMobile)),
                      ],
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

  Widget _buildHeader(bool isMobile) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Icon(
          Icons.map_outlined,
          size: isMobile ? 48 : 56,
          color: ModernColors.primaryBlue,
        ),
        SizedBox(height: ModernSpacing.md),
        Text(
          l10n.pathSelection_title,
          style: ModernTypography.headingLarge.copyWith(
            color: ModernColors.textPrimary,
            fontSize: isMobile ? 24 : 28,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: ModernSpacing.sm),
        Text(
          l10n.pathSelection_subtitle,
          style: ModernTypography.bodyMedium.copyWith(
            color: ModernColors.textSecondary,
            fontSize: isMobile ? 14 : 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPathGrid(BuildContext context, bool isMobile) {
    if (isMobile) {
      // Use ListView for mobile to avoid height constraints
      return ListView.builder(
        itemCount: PathType.values.length,
        itemBuilder: (context, index) {
          final pathType = PathType.values[index];
          return Container(
            margin: EdgeInsets.only(bottom: ModernSpacing.md),
            child: _buildPathCard(context, pathType, isMobile),
          );
        },
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: ModernSpacing.lg,
        mainAxisSpacing: ModernSpacing.lg,
        childAspectRatio: 2.2, // Fixed ratio for desktop
      ),
      itemCount: PathType.values.length,
      itemBuilder: (context, index) {
        final pathType = PathType.values[index];
        return _buildPathCard(context, pathType, isMobile);
      },
    );
  }

  Widget _buildPathCard(
    BuildContext context,
    PathType pathType,
    bool isMobile,
  ) {
    final treasureMapController = Provider.of<TreasureMapController>(context);
    final isUnlocked = _isPathUnlocked(pathType);
    final isSelected = treasureMapController.currentPath == pathType;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ModernCard(
        padding: EdgeInsets.all(ModernSpacing.sm),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isUnlocked ? () => _selectPath(context, pathType) : null,
            child: Row(
              children: [
                // Icon
                _buildPathIcon(pathType, isMobile),
                SizedBox(width: ModernSpacing.md),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title and status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pathType.getLocalizedName(context),
                              style: ModernTypography.headingSmall.copyWith(
                                color: isUnlocked
                                    ? ModernColors.textPrimary
                                    : ModernColors.textSecondary,
                                fontSize: isMobile ? 16 : 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: ModernColors.primaryGreen.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                ).pathSelection_current,
                                style: ModernTypography.caption.copyWith(
                                  color: ModernColors.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          if (!isUnlocked)
                            Icon(
                              Icons.lock_outline,
                              color: ModernColors.textLight,
                              size: 16,
                            ),
                        ],
                      ),
                      SizedBox(height: ModernSpacing.xs),

                      // Description (single line)
                      Text(
                        pathType.getLocalizedDescription(context),
                        style: ModernTypography.bodySmall.copyWith(
                          color: isUnlocked
                              ? ModernColors.textSecondary
                              : ModernColors.textLight,
                          fontSize: isMobile ? 12 : 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: ModernSpacing.sm),

                // Action button
                SizedBox(
                  width: 80,
                  height: 32,
                  child: GradientButton(
                    text: AppLocalizations.of(context).pathSelection_start,
                    gradientColors: ModernColors.blueGradient,
                    onPressed: isUnlocked
                        ? () => _selectPath(context, pathType)
                        : null,
                    height: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPathIcon(PathType pathType, bool isMobile) {
    IconData iconData;
    List<Color> gradientColors;

    switch (pathType) {
      case PathType.dogBreeds:
        iconData = Icons.pets;
        gradientColors = ModernColors.blueGradient;
        break;
      case PathType.dogTraining:
        iconData = Icons.school;
        gradientColors = ModernColors.greenGradient;
        break;
      case PathType.healthCare:
        iconData = Icons.local_hospital;
        gradientColors = ModernColors.redGradient;
        break;
      case PathType.dogBehavior:
        iconData = Icons.psychology;
        gradientColors = ModernColors.purpleGradient;
        break;
      case PathType.dogHistory:
        iconData = Icons.history_edu;
        gradientColors = ModernColors.yellowGradient;
        break;
    }

    return Container(
      padding: EdgeInsets.all(ModernSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: ModernShadows.card,
      ),
      child: Icon(iconData, color: Colors.white, size: isMobile ? 24 : 28),
    );
  }

  bool _isPathUnlocked(PathType pathType) {
    // For now, all paths are unlocked
    // TODO: Implement actual unlocking logic based on progress
    return true;
  }

  void _selectPath(BuildContext context, PathType pathType) {
    final treasureMapController = Provider.of<TreasureMapController>(
      context,
      listen: false,
    );

    // Initialize the selected path
    treasureMapController.initializePath(pathType);

    // Navigate to the treasure map screen
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const TreasureMapScreen()));
  }
}
