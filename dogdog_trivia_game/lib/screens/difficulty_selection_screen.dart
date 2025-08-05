import 'package:flutter/material.dart';
import '../models/enums.dart';
import 'game_screen.dart';
import '../utils/responsive.dart';
import '../utils/accessibility.dart';
import '../services/audio_service.dart';
import '../l10n/generated/app_localizations.dart';

/// Screen for selecting game difficulty level
class DifficultySelectionScreen extends StatelessWidget {
  const DifficultySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AccessibilityTheme(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // Background Gray
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GameElementSemantics(
            label: AppLocalizations.of(context).accessibility_goBack,
            hint: 'Tap to return to the main menu',
            onTap: () => Navigator.of(context).pop(),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          title: Text(
            AppLocalizations.of(context).difficultyScreen_title,
            style: AccessibilityUtils.getAccessibleTextStyle(
              context,
              const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ResponsiveContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 20),
                ),
                _buildHeaderText(context),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 30),
                ),
                Expanded(child: _buildDifficultyGrid(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header text explaining difficulty selection
  Widget _buildHeaderText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.difficultyScreen_headerTitle,
          style: AccessibilityUtils.getAccessibleTextStyle(
            context,
            const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.difficultyScreen_headerSubtitle,
          style: AccessibilityUtils.getAccessibleTextStyle(
            context,
            const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
        ),
      ],
    );
  }

  /// Builds the 2x2 grid of difficulty cards
  Widget _buildDifficultyGrid(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final crossAxisCount =
        ResponsiveUtils.isLandscape(context) &&
            !ResponsiveUtils.isMobile(context)
        ? 4
        : 2;
    final spacing = ResponsiveUtils.getResponsiveSpacing(context, 16);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: ResponsiveUtils.isLandscape(context) ? 1.0 : 0.75,
      children: [
        _buildDifficultyCard(
          context,
          Difficulty.easy,
          Icons.pets,
          const Color(0xFF10B981), // Success Green
          l10n.difficulty_easy_description,
          l10n.difficulty_points_per_question(Difficulty.easy.points),
        ),
        _buildDifficultyCard(
          context,
          Difficulty.medium,
          Icons.favorite,
          const Color(0xFFF59E0B), // Warning Yellow
          l10n.difficulty_medium_description,
          l10n.difficulty_points_per_question(Difficulty.medium.points),
        ),
        _buildDifficultyCard(
          context,
          Difficulty.hard,
          Icons.star,
          const Color(0xFFEF4444), // Error Red
          l10n.difficulty_hard_description,
          l10n.difficulty_points_per_question(Difficulty.hard.points),
        ),
        _buildDifficultyCard(
          context,
          Difficulty.expert,
          Icons.emoji_events,
          const Color(0xFF8B5CF6), // Secondary Purple
          l10n.difficulty_expert_description,
          l10n.difficulty_points_per_question(Difficulty.expert.points),
        ),
      ],
    );
  }

  /// Builds a single difficulty card
  Widget _buildDifficultyCard(
    BuildContext context,
    Difficulty difficulty,
    IconData icon,
    Color color,
    String description,
    String pointsText,
  ) {
    return GameElementSemantics(
      label: AccessibilityUtils.createButtonLabel(
        '${_getLocalizedDifficultyName(context, difficulty)} difficulty',
        hint: '$description. $pointsText. Tap to select this difficulty.',
      ),
      onTap: () => _onDifficultySelected(context, difficulty),
      child: Container(
        decoration: AccessibilityUtils.getAccessibleCardDecoration(context)
            .copyWith(
              border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
            ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _onDifficultySelected(context, difficulty),
            child: Padding(
              padding: ResponsiveUtils.getResponsivePadding(
                context,
              ).copyWith(top: 12, bottom: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with colored background
                  Container(
                    width: ResponsiveUtils.getResponsiveIconSize(context, 60),
                    height: ResponsiveUtils.getResponsiveIconSize(context, 60),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      icon,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 32),
                      color: color,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 12),
                  ),

                  // Difficulty name
                  Text(
                    _getLocalizedDifficultyName(context, difficulty),
                    style: AccessibilityUtils.getAccessibleTextStyle(
                      context,
                      TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 6),
                  ),

                  // Description
                  Text(
                    description,
                    style: AccessibilityUtils.getAccessibleTextStyle(
                      context,
                      const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 6),
                  ),

                  // Points text
                  Text(
                    pointsText,
                    style: AccessibilityUtils.getAccessibleTextStyle(
                      context,
                      const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 12),
                  ),

                  // Selection button
                  Container(
                    width: double.infinity,
                    height: 32,
                    decoration:
                        AccessibilityUtils.getAccessibleButtonDecoration(
                          context,
                          backgroundColor: color,
                        ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(
                          context,
                        ).difficultyScreen_selectButton,
                        style: AccessibilityUtils.getAccessibleTextStyle(
                          context,
                          const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
      ),
    );
  }

  /// Gets the localized name for a difficulty level
  String _getLocalizedDifficultyName(
    BuildContext context,
    Difficulty difficulty,
  ) {
    final l10n = AppLocalizations.of(context);
    switch (difficulty) {
      case Difficulty.easy:
        return l10n.difficulty_easy;
      case Difficulty.medium:
        return l10n.difficulty_medium;
      case Difficulty.hard:
        return l10n.difficulty_hard;
      case Difficulty.expert:
        return l10n.difficulty_expert;
    }
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
        '${_getLocalizedDifficultyName(context, difficulty)} difficulty selected. Starting game.',
      );
    }

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GameScreen(
            difficulty: difficulty,
            level: 1, // Start at level 1
          ),
        ),
      );
    }
  }
}
