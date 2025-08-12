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
import '../widgets/question_error_handler.dart';
import '../widgets/accessible_category_selection.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<TreasureMapController>(
        context,
        listen: false,
      );

      // Set default category if none is selected
      if (controller.selectedCategory == null) {
        controller.selectCategory(QuestionCategory.dogBreeds);
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
            child: Column(
              children: [
                // Category Selection Section
                _buildCategorySelection(isMobile, controller),
                SizedBox(height: ModernSpacing.lg),
                // Error Handler Section
                QuestionErrorBanner(onTap: () => _showErrorDetails(context)),
                SizedBox(height: ModernSpacing.sm),
                // Treasure Map Progress Section
                Container(
                  height: 450, // Fixed height to prevent layout issues
                  margin: EdgeInsets.symmetric(horizontal: ModernSpacing.lg),
                  child: ModernCard(
                    child: Container(
                      padding: EdgeInsets.all(ModernSpacing.lg),
                      child: VerticalProgressLine(
                        currentQuestionCount: controller.currentQuestionCount,
                        completedCheckpoints: controller.completedCheckpoints
                            .toList(),
                        currentCheckpoint: controller.nextCheckpoint,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ModernSpacing.lg),
              ],
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

  Widget _buildCategorySelection(
    bool isMobile,
    TreasureMapController controller,
  ) {
    return AccessibleCategorySelection(
      selectedCategory: controller.selectedCategory,
      onCategorySelected: (category) => controller.selectCategory(category),
      isMobile: isMobile,
      availableCategories: const [
        QuestionCategory.dogTraining,
        QuestionCategory.dogBreeds,
        QuestionCategory.dogBehavior,
        QuestionCategory.dogHealth,
        QuestionCategory.dogHistory,
      ],
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
      if (controller.selectedCategory != null) {
        final locale = Localizations.localeOf(context).languageCode;
        return '${controller.selectedCategory!.getLocalizedName(locale)} ${l10n.treasureMap_adventure}';
      }
      return '${controller.currentPath.getLocalizedName(context)} ${l10n.treasureMap_adventure}';
    } catch (e) {
      // Fallback for test environment
      if (controller.selectedCategory != null) {
        return '${controller.selectedCategory!.displayName} Adventure';
      }
      return '${controller.currentPath.displayName} Adventure';
    }
  }

  Color _getHeaderColor(TreasureMapController controller) {
    if (controller.selectedCategory != null) {
      return _getCategoryColors(controller.selectedCategory!).first;
    }
    return ModernColors.textPrimary;
  }

  String _getActionButtonText(TreasureMapController controller) {
    try {
      final l10n = AppLocalizations.of(context);
      if (controller.selectedCategory == null) {
        return l10n.treasureMap_selectCategoryFirst;
      } else if (controller.isPathCompleted) {
        return l10n.treasureMap_pathCompleted;
      } else if (controller.currentQuestionCount == 0) {
        final locale = Localizations.localeOf(context).languageCode;
        final categoryName = controller.selectedCategory!.getLocalizedName(
          locale,
        );
        return l10n.treasureMap_startCategoryAdventure(categoryName);
      } else {
        final locale = Localizations.localeOf(context).languageCode;
        final categoryName = controller.selectedCategory!.getLocalizedName(
          locale,
        );
        return l10n.treasureMap_continueCategoryAdventure(categoryName);
      }
    } catch (e) {
      // Fallback for test environment
      if (controller.selectedCategory == null) {
        return 'Select Category First';
      } else if (controller.isPathCompleted) {
        return 'Path Completed';
      } else if (controller.currentQuestionCount == 0) {
        final categoryName = controller.selectedCategory!.displayName;
        return 'Start $categoryName Adventure';
      } else {
        final categoryName = controller.selectedCategory!.displayName;
        return 'Continue $categoryName Adventure';
      }
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
    if (controller.selectedCategory == null) {
      // Show category selection prompt
      _showCategorySelectionPrompt();
      return;
    }

    if (controller.isPathCompleted) {
      // Show completion celebration or navigate to results
      _showCompletionDialog();
    } else {
      // Navigate to game screen to start/continue questions
      _navigateToGameScreen();
    }
  }

  void _showCategorySelectionPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: ModernColors.primaryBlue),
            SizedBox(width: ModernSpacing.sm),
            Text(
              _getLocalizedText(
                'treasureMap_selectCategoryDialog_title',
                'Select Category',
              ),
            ),
          ],
        ),
        content: Text(
          _getLocalizedText(
            'treasureMap_selectCategoryDialog_message',
            'Please select a category above to start your adventure.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_getLocalizedText('common_ok', 'OK')),
          ),
        ],
      ),
    );
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

  /// Helper method to get localized text with fallback
  String _getLocalizedText(String key, String fallback) {
    try {
      final l10n = AppLocalizations.of(context);
      switch (key) {
        case 'treasureMap_chooseYourAdventure':
          return l10n.treasureMap_chooseYourAdventure;
        case 'treasureMap_selectCategoryFirst':
          return l10n.treasureMap_selectCategoryFirst;
        case 'treasureMap_selectCategoryDialog_title':
          return l10n.treasureMap_selectCategoryDialog_title;
        case 'treasureMap_selectCategoryDialog_message':
          return l10n.treasureMap_selectCategoryDialog_message;
        default:
          return fallback;
      }
    } catch (e) {
      return fallback;
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

  /// Shows detailed error information in a dialog
  void _showErrorDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: ModernColors.primaryBlue),
            SizedBox(width: ModernSpacing.sm),
            Text('Question Loading Status'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: QuestionErrorHandler(
            onRetrySuccess: () {
              Navigator.of(context).pop();
              // Optionally refresh the screen or show success message
            },
            onRetryFailed: () {
              // Handle retry failure if needed
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
