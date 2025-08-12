import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/treasure_map_controller.dart';
import '../models/enums.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../widgets/modern_card.dart';
import '../widgets/vertical_progress_line.dart';
import '../widgets/category_carousel.dart';
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
    _initializeController();
  }

  void _initializeController() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = Provider.of<TreasureMapController>(
        context,
        listen: false,
      );

      // Initialize the controller to load available categories
      await controller.initialize();

      // Set default category if none is selected and categories are available
      if (controller.selectedCategory == null &&
          controller.availableCategories.isNotEmpty) {
        controller.selectCategory(controller.availableCategories.first);
      }
    });
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
                _buildTreasureMapView(isMobile),
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
                      _getHeaderTitle(controller),
                      style: ModernTypography.headingLarge.copyWith(
                        color: _getHeaderColor(controller),
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
        return Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: ModernSpacing.md),
            child: Column(
              children: [
                // Category Selection Section
                _buildCategorySelection(isMobile, controller),
                SizedBox(height: ModernSpacing.xl),
                // Treasure Map Progress Section
                SizedBox(
                  height: isMobile
                      ? 500
                      : 600, // Fixed height to show all checkpoints
                  child: ModernCard(
                    child: Container(
                      padding: EdgeInsets.all(ModernSpacing.lg),
                      child: VerticalProgressLine(
                        currentQuestionCount: controller.currentQuestionCount,
                        completedCheckpoints: controller.completedCheckpoints
                            .toList(),
                        currentCheckpoint: controller.nextCheckpoint,
                        category:
                            controller.focusedCategory ??
                            controller.selectedCategory, // Use focused category
                      ),
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

  Widget _buildCategorySelection(
    bool isMobile,
    TreasureMapController controller,
  ) {
    return CategoryCarousel(
      selectedCategory: controller.selectedCategory,
      onCategorySelected: (category) => controller.selectCategory(category),
      onFocusedCategoryChanged: (category) => controller.setFocusedCategory(
        category,
      ), // Add focused category callback
      isMobile: isMobile,
      availableCategories: controller.availableCategories,
      onStartGame: () => _navigateToGameScreen(), // Add navigation callback
    );
  }

  List<Color> _getCategoryColors(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.dogTraining:
        return ModernColors.greenGradient; // Green for training
      case QuestionCategory.dogBreeds:
        return ModernColors.blueGradient; // Blue for breeds
      case QuestionCategory.dogBehavior:
        return ModernColors.purpleGradient; // Purple for behavior
      case QuestionCategory.dogHealth:
        return ModernColors.redGradient; // Red for health
      case QuestionCategory.dogHistory:
        return ModernColors.orangeGradient; // Orange for history
    }
  }

  String _getHeaderTitle(TreasureMapController controller) {
    try {
      final l10n = AppLocalizations.of(context);
      // Use focused category for header display, fallback to selected category
      final displayCategory =
          controller.focusedCategory ?? controller.selectedCategory;
      if (displayCategory != null) {
        final locale = Localizations.localeOf(context).languageCode;
        return '${displayCategory.getLocalizedName(locale)} ${l10n.treasureMap_adventure}';
      }
      return '${controller.currentPath.getLocalizedName(context)} ${l10n.treasureMap_adventure}';
    } catch (e) {
      // Fallback for test environment
      final displayCategory =
          controller.focusedCategory ?? controller.selectedCategory;
      if (displayCategory != null) {
        return '${displayCategory.displayName} Adventure';
      }
      return '${controller.currentPath.displayName} Adventure';
    }
  }

  Color _getHeaderColor(TreasureMapController controller) {
    // Use focused category for header color, fallback to selected category
    final displayCategory =
        controller.focusedCategory ?? controller.selectedCategory;
    if (displayCategory != null) {
      return _getCategoryColors(displayCategory).first;
    }
    return ModernColors.textPrimary;
  }

  void _navigateToGameScreen() {
    final controller = Provider.of<TreasureMapController>(
      context,
      listen: false,
    );

    if (controller.currentPath == PathType.puppyQuest) {
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
      // Navigate to regular game screen with category context
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => GameScreen(
            difficulty:
                Difficulty.medium, // Default difficulty for treasure map mode
            level: 1,
            category: controller.selectedCategory, // Pass selected category
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
    try {
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
    } catch (e) {
      // Fallback for test environment
      final next = controller.nextCheckpoint;

      if (next == null) {
        return 'Path Completed!';
      }

      final previousQuestions =
          controller.lastCompletedCheckpoint?.questionsRequired ?? 0;
      final questionsInSegment =
          controller.currentQuestionCount - previousQuestions;
      final questionsNeeded = next.questionsRequired - previousQuestions;

      return '$questionsInSegment/$questionsNeeded questions to ${next.displayName}';
    }
  }
}
