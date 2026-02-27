import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../utils/enum_extensions.dart';
import 'game_screen.dart';
import '../utils/responsive.dart';
import '../utils/animations.dart';
import '../utils/accessibility.dart';
import '../services/audio_service.dart';
import '../l10n/generated/app_localizations.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_spacing.dart';
import '../design_system/modern_typography.dart';

/// Screen for selecting game difficulty level
class DifficultySelectionScreen extends StatelessWidget {
  const DifficultySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: ResponsiveContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ModernSpacing.verticalSpaceLG,
                        _buildHeaderText(context),
                        ModernSpacing.verticalSpaceXL,
                        Expanded(child: _buildDifficultyList(context)),
                      ],
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

  /// Builds the modern app bar
  Widget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: ModernSpacing.screenPaddingInsets.copyWith(bottom: 0),
      child: Row(
        children: [
          GameElementSemantics(
            label: l10n.accessibility_goBack,
            hint: l10n.accessibility_goBack, // Using same label as hint for now or could add specific hint
            onTap: () => Navigator.of(context).pop(),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: ModernColors.textPrimary,
                size: 24,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Expanded(
            child: Text(
              l10n.difficultyScreen_title,
              style: AccessibilityUtils.getAccessibleTextStyle(
                context,
                ModernTypography.headingMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  /// Builds the header text explaining difficulty selection
  Widget _buildHeaderText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: ModernSpacing.paddingHorizontalLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.difficultyScreen_headerTitle,
            style: AccessibilityUtils.getAccessibleTextStyle(
              context,
              ModernTypography.headingLarge,
            ),
          ),
          ModernSpacing.verticalSpaceSM,
          Text(
            l10n.difficultyScreen_headerSubtitle,
            style: AccessibilityUtils.getAccessibleTextStyle(
              context,
              ModernTypography.withSecondaryColor(ModernTypography.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a 2x2 grid of difficulty cards
  Widget _buildDifficultyList(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final difficulties = [
      {
        'difficulty': Difficulty.easy,
        'breedName': 'Chihuahua',
        'imagePath': 'assets/images/chihuahua.png',
        'difficultyKey': 'easy',
        'description': Difficulty.easy.description(context),
        'pointsText': l10n.difficulty_points_per_question(Difficulty.easy.points),
      },
      {
        'difficulty': Difficulty.medium,
        'breedName': 'Cocker Spaniel',
        'imagePath': 'assets/images/cocker.png',
        'difficultyKey': 'medium',
        'description': Difficulty.medium.description(context),
        'pointsText': l10n.difficulty_points_per_question(Difficulty.medium.points),
      },
      {
        'difficulty': Difficulty.hard,
        'breedName': 'German Shepherd',
        'imagePath': 'assets/images/schaeferhund.png',
        'difficultyKey': 'hard',
        'description': Difficulty.hard.description(context),
        'pointsText': l10n.difficulty_points_per_question(Difficulty.hard.points),
      },
      {
        'difficulty': Difficulty.expert,
        'breedName': 'Great Dane',
        'imagePath': 'assets/images/dogge.png',
        'difficultyKey': 'expert',
        'description': Difficulty.expert.description(context),
        'pointsText': l10n.difficulty_points_per_question(Difficulty.expert.points),
      },
    ];

    return Padding(
      padding: ModernSpacing.paddingHorizontalLG,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.75, // Increased height for better content fit
        ),
        itemCount: difficulties.length,
        itemBuilder: (context, index) {
          final difficultyData = difficulties[index];
          return _buildModernDifficultyCard(
            context,
            difficultyData['difficulty'] as Difficulty,
            difficultyData['breedName'] as String,
            difficultyData['imagePath'] as String,
            difficultyData['difficultyKey'] as String,
            difficultyData['description'] as String,
            difficultyData['pointsText'] as String,
          );
        },
      ),
    );
  }

  /// Builds a modern difficulty card using DogBreedCard component
  Widget _buildModernDifficultyCard(
    BuildContext context,
    Difficulty difficulty,
    String breedName,
    String imagePath,
    String difficultyKey,
    String description,
    String pointsText,
  ) {
    final difficultyName = difficulty.displayName(context);
    final l10n = AppLocalizations.of(context);

    return GameElementSemantics(
      label: l10n.difficultyScreen_semantics_play(difficultyName),
      hint: l10n.difficultyScreen_semantics_hint(description, pointsText),
      onTap: () => _onDifficultySelected(context, difficulty),
      child: InkWell(
        onTap: () => _onDifficultySelected(context, difficulty),
        borderRadius: ModernSpacing.borderRadiusLarge,
        child: Container(
          padding: ModernSpacing.cardPaddingInsets,
          decoration: BoxDecoration(
            color: ModernColors.cardBackground,
            borderRadius: ModernSpacing.borderRadiusLarge,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top section: Dog image (centered)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: ModernColors.getColorForDifficulty(
                    difficultyKey,
                  ).withValues(alpha: 0.1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    imagePath,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: ModernColors.getColorForDifficulty(
                            difficultyKey,
                          ).withValues(alpha: 0.2),
                        ),
                        child: Icon(
                          Icons.pets,
                          size: 30,
                          color: ModernColors.getColorForDifficulty(
                            difficultyKey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              ModernSpacing.verticalSpaceSM,

              // Difficulty name (centered)
              Text(
                difficultyName,
                style: AccessibilityUtils.getAccessibleTextStyle(
                  context,
                  ModernTypography.withColor(
                    ModernTypography.bodyMedium,
                    ModernColors.getColorForDifficulty(difficultyKey),
                  ),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              ModernSpacing.verticalSpaceXS,

              // Description
              Expanded(
                child: Text(
                  description,
                  style: AccessibilityUtils.getAccessibleTextStyle(
                    context,
                    ModernTypography.caption,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Points
              Text(
                pointsText,
                style: AccessibilityUtils.getAccessibleTextStyle(
                  context,
                  ModernTypography.withColor(
                    TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                    ModernColors.textSecondary,
                  ),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }



  /// Handles difficulty selection
  void _onDifficultySelected(
    BuildContext context,
    Difficulty difficulty,
  ) async {
    final audioService = AudioService();
    await audioService.playButtonSound();

    // Announce selection to screen reader
    if (context.mounted && AccessibilityUtils.isScreenReaderEnabled(context)) {
      AccessibilityUtils.announceToScreenReader(
        context,
        AppLocalizations.of(context).difficultyScreen_semantics_selected_announcement(
          difficulty.displayName(context),
        ),
      );
    }

    if (context.mounted) {
      Navigator.of(context).push(
        ModernPageRoute(
          child: GameScreen(
            difficulty: difficulty,
            level: 1, // Start at level 1
          ),
          direction: SlideDirection.rightToLeft,
        ),
      );
    }
  }
}
