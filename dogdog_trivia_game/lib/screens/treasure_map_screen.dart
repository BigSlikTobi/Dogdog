import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/treasure_map_controller.dart';
import '../models/enums.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../widgets/modern_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/vertical_progress_line.dart';
import '../utils/responsive.dart';
import '../utils/path_localization.dart';
import '../l10n/generated/app_localizations.dart';
import 'game_screen.dart';
import 'dog_breeds_adventure_screen.dart';

/// Screen displaying the treasure map with checkpoint progress visualization
class TreasureMapScreen extends StatefulWidget {
  const TreasureMapScreen({super.key});

  @override
  State<TreasureMapScreen> createState() => _TreasureMapScreenState();
}

class _TreasureMapScreenState extends State<TreasureMapScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ModernColors.primaryBlue.withValues(alpha: 0.1),
              ModernColors.primaryPurple.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(isMobile),
                Expanded(child: _buildTreasureMapView(isMobile)),
                _buildActionSection(isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Consumer<TreasureMapController>(
      builder: (context, controller, child) {
        return Container(
          padding: EdgeInsets.all(ModernSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: ModernColors.primaryBlue,
                      size: isMobile ? 24 : 28,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${controller.currentPath.getLocalizedName(context)} ${AppLocalizations.of(context).treasureMap_adventure}',
                      style: ModernTypography.headingLarge.copyWith(
                        color: ModernColors.textPrimary,
                        fontSize: isMobile ? 22 : 26,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: isMobile ? 40 : 44,
                  ), // Balance the back button
                ],
              ),
              SizedBox(height: ModernSpacing.sm),
              Text(
                _getLocalizedSegmentDisplay(controller),
                style: ModernTypography.bodyMedium.copyWith(
                  color: ModernColors.textSecondary,
                  fontSize: isMobile ? 14 : 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTreasureMapView(bool isMobile) {
    return Consumer<TreasureMapController>(
      builder: (context, controller, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: ModernSpacing.lg),
          child: ModernCard(
            child: Container(
              padding: EdgeInsets.all(ModernSpacing.lg),
              child: VerticalProgressLine(
                currentQuestionCount: controller.currentQuestionCount,
                completedCheckpoints: controller.completedCheckpoints.toList(),
                currentCheckpoint: controller.nextCheckpoint,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionSection(bool isMobile) {
    return Consumer<TreasureMapController>(
      builder: (context, controller, child) {
        return Container(
          padding: EdgeInsets.all(ModernSpacing.lg),
          child: SizedBox(
            width: double.infinity,
            child: GradientButton(
              onPressed: () => _handleActionButtonPressed(controller),
              text: _getActionButtonText(controller),
              gradientColors: ModernColors.blueGradient,
              icon: _getActionButtonIcon(controller),
            ),
          ),
        );
      },
    );
  }

  String _getActionButtonText(TreasureMapController controller) {
    final l10n = AppLocalizations.of(context);
    if (controller.isPathCompleted) {
      return l10n.treasureMap_pathCompleted;
    } else if (controller.currentQuestionCount == 0) {
      return l10n.treasureMap_startAdventure;
    } else {
      return l10n.treasureMap_continueAdventure;
    }
  }

  IconData _getActionButtonIcon(TreasureMapController controller) {
    if (controller.isPathCompleted) {
      return Icons.celebration;
    } else if (controller.currentQuestionCount == 0) {
      return Icons.play_arrow;
    } else {
      return Icons.arrow_forward;
    }
  }

  void _handleActionButtonPressed(TreasureMapController controller) {
    if (controller.isPathCompleted) {
      // Show completion celebration or navigate to results
      _showCompletionDialog();
    } else {
      // Navigate to game screen to start/continue questions
      _navigateToGameScreen();
    }
  }

  void _showCompletionDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: ModernColors.success),
            SizedBox(width: ModernSpacing.sm),
            Text(l10n.treasureMap_congratulations),
          ],
        ),
        content: Text(l10n.treasureMap_completionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.treasureMap_continueExploring),
          ),
        ],
      ),
    );
  }

  void _navigateToGameScreen() {
    final controller = Provider.of<TreasureMapController>(
      context,
      listen: false,
    );

    if (controller.currentPath == PathType.breedAdventure) {
      // Navigate to breed adventure screen
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DogBreedsAdventureScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      // Navigate to regular game screen for other paths
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => GameScreen(
            difficulty:
                Difficulty.medium, // Default difficulty for treasure map mode
            level: 1,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  /// Get localized segment display text
  String _getLocalizedSegmentDisplay(TreasureMapController controller) {
    final l10n = AppLocalizations.of(context);
    final next = controller.nextCheckpoint;

    if (next == null) {
      return l10n.treasureMap_pathCompletedStatus;
    }

    final previousQuestions =
        controller.lastCompletedCheckpoint?.questionsRequired ?? 0;
    final questionsInSegment =
        controller.currentQuestionCount - previousQuestions;
    final questionsNeeded = next.questionsRequired - previousQuestions;

    return l10n.treasureMap_questionsTo(
      questionsInSegment,
      questionsNeeded,
      next.displayName,
    );
  }
}
