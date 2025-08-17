import 'package:flutter/material.dart';
import '../../design_system/modern_colors.dart';
import '../../design_system/modern_typography.dart';
import '../../design_system/modern_spacing.dart';
import '../../design_system/modern_shadows.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/breed_adventure/breed_localization_service.dart';
import '../../services/breed_adventure/frame_rate_optimizer.dart';
import '../../utils/accessibility.dart';
import '../../utils/accessibility_enhancements.dart' hide AccessibilityTheme;

/// Widget that displays the breed name with localized text and performance optimization
class BreedNameDisplay extends StatefulWidget {
  final String breedName;
  final bool isVisible;
  final Duration animationDuration;

  const BreedNameDisplay({
    super.key,
    required this.breedName,
    this.isVisible = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<BreedNameDisplay> createState() => _BreedNameDisplayState();
}

class _BreedNameDisplayState extends State<BreedNameDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final FrameRateOptimizer _frameRateOptimizer = FrameRateOptimizer.instance;

  @override
  void initState() {
    super.initState();

    // Use optimized animation controller
    _animationController = _frameRateOptimizer.createOptimizedController(
      duration: widget.animationDuration,
      vsync: this,
      isEssential: true, // Breed name display is essential
      debugLabel: 'BreedNameDisplay',
    );

    final optimizedCurve = _frameRateOptimizer.getOptimizedCurve(
      Curves.easeInOut,
      isEssential: true,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: optimizedCurve),
    );

    if (widget.isVisible) {
      _animationController.forwardOptimized(isEssential: true);
    }
  }

  @override
  void didUpdateWidget(BreedNameDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forwardOptimized(isEssential: true);
      } else {
        _animationController.reverseOptimized(isEssential: true);
      }
    }

    // Animate when breed name changes
    if (widget.breedName != oldWidget.breedName) {
      _animationController.reset();
      _animationController.forwardOptimized(isEssential: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizedBreedName = BreedLocalizationService.getLocalizedBreedName(
      context,
      widget.breedName,
    );

    final questionText = AppLocalizations.of(
      context,
    ).breedAdventure_whichImageShows;

    // Create comprehensive semantic label for screen readers
    final semanticLabel = AccessibilityUtils.createGameElementLabel(
      element: AppLocalizations.of(context).breedAdventure_breedChallenge,
      value: localizedBreedName,
      context: questionText,
    );

    // Optimize rebuilds with RepaintBoundary
    return _frameRateOptimizer.optimizeRebuilds(
      child: AccessibilityTheme(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return AccessibilityEnhancements.buildReducedMotionWrapper(
              child: _frameRateOptimizer.createOptimizedTransition(
                child: _buildAccessibleContainer(
                  context,
                  localizedBreedName,
                  questionText,
                  semanticLabel,
                ),
                animation: _fadeAnimation,
                type: AnimationType.fade,
                isEssential: true,
              ),
              reducedMotionChild: _buildAccessibleContainer(
                context,
                localizedBreedName,
                questionText,
                semanticLabel,
              ),
            );
          },
        ),
      ),
      shouldRebuild: _animationController.isAnimating,
      debugLabel: 'BreedNameDisplay',
    );
  }

  Widget _buildAccessibleContainer(
    BuildContext context,
    String localizedBreedName,
    String questionText,
    String semanticLabel,
  ) {
    final isHighContrast = AccessibilityUtils.isHighContrastEnabled(context);
    final colorScheme = AccessibilityUtils.getHighContrastColors(context);

    return Semantics(
      label: semanticLabel,
      hint: AppLocalizations.of(context).breedAdventure_selectCorrectImageHint,
      readOnly: true,
      child: Container(
        width: double.infinity,
        margin: ModernSpacing.paddingHorizontalLG,
        padding: ModernSpacing.paddingLG,
        decoration: isHighContrast
            ? AccessibilityUtils.getAccessibleCardDecoration(context)
            : BoxDecoration(
                gradient: ModernColors.createLinearGradient(
                  [
                    ModernColors.cardBackground,
                    ModernColors.cardBackground.withValues(alpha: 0.98),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: ModernSpacing.borderRadiusLarge,
                boxShadow: ModernShadows.card,
                border: Border.all(
                  color: ModernColors.primaryPurple.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Question prompt with accessibility enhancements
            Semantics(
              label: questionText,
              readOnly: true,
              child: AccessibilityEnhancements.buildHighContrastText(
                text: questionText,
                style: AccessibilityUtils.getAccessibleTextStyle(
                  context,
                  ModernTypography.bodyMedium.copyWith(
                    color: isHighContrast
                        ? colorScheme.onSurface
                        : ModernColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),

            ModernSpacing.verticalSpaceMD,

            // Breed name with enhanced accessibility
            Semantics(
              label: AccessibilityUtils.createGameElementLabel(
                element: AppLocalizations.of(
                  context,
                ).breedAdventure_targetBreed,
                value: localizedBreedName,
              ),
              readOnly: true,
              child: Container(
                padding: ModernSpacing.paddingMD,
                decoration: isHighContrast
                    ? BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: ModernSpacing.borderRadiusMedium,
                        border: Border.all(
                          color: colorScheme.onPrimary,
                          width: 2,
                        ),
                      )
                    : BoxDecoration(
                        gradient: ModernColors.createLinearGradient(
                          ModernColors.purpleGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: ModernSpacing.borderRadiusMedium,
                        boxShadow: ModernShadows.glow(
                          ModernColors.primaryPurple,
                          opacity: 0.2,
                          blur: 12,
                        ),
                      ),
                child: AccessibilityEnhancements.buildHighContrastText(
                  text: localizedBreedName,
                  style: AccessibilityUtils.getAccessibleTextStyle(
                    context,
                    ModernTypography.headingLarge.copyWith(
                      color: isHighContrast
                          ? colorScheme.onPrimary
                          : ModernColors.textOnDark,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      shadows: isHighContrast
                          ? null
                          : [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                    ),
                  ),
                ),
              ),
            ),

            ModernSpacing.verticalSpaceSM,

            // Enhanced question mark indicator with accessibility
            Semantics(
              label: AppLocalizations.of(
                context,
              ).breedAdventure_questionIndicator,
              readOnly: true,
              child: Container(
                width: 48,
                height: 48,
                decoration: isHighContrast
                    ? AccessibilityUtils.getAccessibleCircularDecoration(
                        context,
                      )
                    : BoxDecoration(
                        color: ModernColors.primaryPurple.withValues(
                          alpha: 0.1,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ModernColors.primaryPurple.withValues(
                            alpha: 0.3,
                          ),
                          width: 2,
                        ),
                      ),
                child: Center(
                  child: AccessibilityEnhancements.buildHighContrastText(
                    text: '?',
                    style: AccessibilityUtils.getAccessibleTextStyle(
                      context,
                      ModernTypography.headingLarge.copyWith(
                        color: isHighContrast
                            ? colorScheme.onSurface
                            : ModernColors.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A simplified version for smaller spaces
class CompactBreedNameDisplay extends StatelessWidget {
  final String breedName;
  final Color? textColor;
  final TextStyle? textStyle;

  const CompactBreedNameDisplay({
    super.key,
    required this.breedName,
    this.textColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final localizedBreedName = BreedLocalizationService.getLocalizedBreedName(
      context,
      breedName,
    );
    final isHighContrast = AccessibilityUtils.isHighContrastEnabled(context);
    final colorScheme = AccessibilityUtils.getHighContrastColors(context);

    return AccessibilityTheme(
      child: Semantics(
        label: AccessibilityUtils.createGameElementLabel(
          element: AppLocalizations.of(context).breedAdventure_breedName,
          value: localizedBreedName,
        ),
        readOnly: true,
        child: Container(
          width: double.infinity,
          padding: ModernSpacing.paddingLG,
          decoration: isHighContrast
              ? AccessibilityUtils.getAccessibleCardDecoration(context)
              : BoxDecoration(
                  gradient: ModernColors.createLinearGradient(
                    [
                      ModernColors.cardBackground,
                      ModernColors.cardBackground.withValues(alpha: 0.98),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: ModernSpacing.borderRadiusLarge,
                  border: Border.all(
                    color: ModernColors.primaryPurple.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: ModernShadows.card,
                ),
          child: Center(
            // Center the text content
            child: AccessibilityEnhancements.buildHighContrastText(
              text: localizedBreedName,
              style: AccessibilityUtils.getAccessibleTextStyle(
                context,
                textStyle ??
                    ModernTypography.headingMedium.copyWith(
                      color: isHighContrast
                          ? colorScheme.onSurface
                          : (textColor ?? ModernColors.primaryPurple),
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
