import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../design_system/modern_colors.dart';
import '../../design_system/modern_typography.dart';
import '../../design_system/modern_spacing.dart';
import '../../design_system/modern_shadows.dart';
import '../shared/loading_animation.dart';
import 'loading_error_states.dart';
import '../../utils/accessibility.dart';
import '../../utils/accessibility_enhancements.dart' hide AccessibilityTheme;
import '../../l10n/generated/app_localizations.dart';
import '../../services/audio_service.dart';

/// Widget that displays two images side by side for breed selection
class DualImageSelection extends StatefulWidget {
  final String imageUrl1;
  final String imageUrl2;
  final Function(int) onImageSelected;
  final bool isEnabled;
  final int? selectedIndex;
  final bool? isCorrect;
  final bool showFeedback;
  final Duration animationDuration;

  const DualImageSelection({
    super.key,
    required this.imageUrl1,
    required this.imageUrl2,
    required this.onImageSelected,
    this.isEnabled = true,
    this.selectedIndex,
    this.isCorrect,
    this.showFeedback = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<DualImageSelection> createState() => _DualImageSelectionState();
}

class _DualImageSelectionState extends State<DualImageSelection>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _feedbackController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _feedbackAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _feedbackController = AnimationController(
      duration: const Duration(
        milliseconds: 500,
      ), // Shortened for better timing
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeIn));

    _feedbackAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
    );

    _entryController.forward();
  }

  @override
  void didUpdateWidget(DualImageSelection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Start animation when feedback becomes true
    if (widget.showFeedback && !oldWidget.showFeedback) {
      _feedbackController.forward();
    }

    // Reset animations when images change - indicates new challenge
    if (widget.imageUrl1 != oldWidget.imageUrl1 ||
        widget.imageUrl2 != oldWidget.imageUrl2) {
      _entryController.reset();
      _entryController.forward();
      _feedbackController.reset();
    }

    // Reset feedback when showFeedback becomes false
    if (!widget.showFeedback && oldWidget.showFeedback) {
      _feedbackController.reset();
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Color _getImageBorderColor(int index) {
    if (!widget.showFeedback || widget.selectedIndex != index) {
      return ModernColors.surfaceDark;
    }

    return widget.isCorrect == true ? ModernColors.success : ModernColors.error;
  }

  double _getImageBorderWidth(int index) {
    if (!widget.showFeedback || widget.selectedIndex != index) {
      return 2.0;
    }
    return 4.0;
  }

  Widget _buildImageContainer(String imageUrl, int index) {
    final isSelected = widget.selectedIndex == index;
    final showFeedback = widget.showFeedback && isSelected;
    final isHighContrast = AccessibilityUtils.isHighContrastEnabled(context);

    // Create semantic labels for accessibility
    final imageLabel = AppLocalizations.of(
      context,
    ).breedAdventure_imageOption(index + 1);
    final selectionHint = widget.isEnabled
        ? AppLocalizations.of(context).breedAdventure_tapToSelectImage
        : AppLocalizations.of(context).breedAdventure_imageDisabled;

    String? feedbackLabel;
    if (showFeedback) {
      feedbackLabel = widget.isCorrect == true
          ? AppLocalizations.of(context).breedAdventure_correctSelection
          : AppLocalizations.of(context).breedAdventure_incorrectSelection;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _fadeAnimation,
        _feedbackAnimation,
      ]),
      builder: (context, child) {
        double scale = _scaleAnimation.value;
        if (showFeedback) {
          scale *= _feedbackAnimation.value;
        }

        return AccessibilityEnhancements.buildReducedMotionWrapper(
          child: Transform.scale(
            scale: scale,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildAccessibleImageContainer(
                imageUrl,
                index,
                isSelected,
                showFeedback,
                isHighContrast,
                imageLabel,
                selectionHint,
                feedbackLabel,
              ),
            ),
          ),
          reducedMotionChild: _buildAccessibleImageContainer(
            imageUrl,
            index,
            isSelected,
            showFeedback,
            isHighContrast,
            imageLabel,
            selectionHint,
            feedbackLabel,
          ),
        );
      },
    );
  }

  Widget _buildAccessibleImageContainer(
    String imageUrl,
    int index,
    bool isSelected,
    bool showFeedback,
    bool isHighContrast,
    String imageLabel,
    String selectionHint,
    String? feedbackLabel,
  ) {
    return FocusableGameElement(
      semanticLabel: feedbackLabel ?? '$imageLabel. $selectionHint',
      onTap: widget.isEnabled ? () => _handleImageSelection(index) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: ModernSpacing.borderRadiusLarge,
          border: Border.all(
            color: _getAccessibleBorderColor(index, isHighContrast),
            width: _getAccessibleBorderWidth(index, isHighContrast),
          ),
          boxShadow: isHighContrast
              ? null
              : [
                  if (isSelected && showFeedback) ...[
                    // Enhanced feedback glow
                    ...ModernShadows.glow(
                      widget.isCorrect == true
                          ? ModernColors.success
                          : ModernColors.error,
                      opacity: 0.4,
                      blur: 16,
                    ),
                    // Additional depth shadow
                    ...ModernShadows.large,
                  ] else if (widget.isEnabled && !showFeedback) ...[
                    // Interactive hover state
                    ...ModernShadows.cardHover,
                  ] else
                    ...ModernShadows.card,
                ],
        ),
        child: ClipRRect(
          borderRadius: ModernSpacing.borderRadiusLarge,
          child: AspectRatio(
            aspectRatio:
                1.2, // Made images slightly wider for more prominent display
            child: Stack(
              children: [
                // Image with accessibility description
                AccessibilityEnhancements.buildAccessibleImage(
                  image: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => const BreedImageLoading(),
                    errorWidget: (context, url, error) =>
                        const BreedImageError(),
                  ),
                  semanticLabel: imageLabel,
                  description: AppLocalizations.of(
                    context,
                  ).breedAdventure_breedImageDescription,
                ),

                // Enhanced selection overlay with accessibility
                if (isSelected && widget.showFeedback)
                  _buildFeedbackOverlay(isHighContrast),

                // Enhanced disabled overlay with accessibility (only show if not giving feedback)
                if (!widget.isEnabled && !widget.showFeedback)
                  _buildDisabledOverlay(isHighContrast),

                // Enhanced tap indicator with accessibility
                if (widget.isEnabled && !showFeedback)
                  _buildTapIndicator(index, isHighContrast),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackOverlay(bool isHighContrast) {
    return Container(
      decoration: BoxDecoration(
        gradient: isHighContrast
            ? null
            : ModernColors.createLinearGradient([
                (widget.isCorrect == true
                        ? ModernColors.success
                        : ModernColors.error)
                    .withValues(alpha: 0.15),
                (widget.isCorrect == true
                        ? ModernColors.success
                        : ModernColors.error)
                    .withValues(alpha: 0.25),
              ]),
        color: isHighContrast
            ? (widget.isCorrect == true ? Colors.green : Colors.red).withValues(
                alpha: 0.3,
              )
            : null,
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _feedbackController,
          builder: (context, child) {
            final scale = widget.showFeedback
                ? (_feedbackController.value * 0.3 + 0.7)
                : 0.0;

            return Transform.scale(
              scale: scale,
              child: Container(
                width: 72,
                height: 72,
                decoration: isHighContrast
                    ? BoxDecoration(
                        color: widget.isCorrect == true
                            ? Colors.green
                            : Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      )
                    : BoxDecoration(
                        gradient: ModernColors.createLinearGradient(
                          widget.isCorrect == true
                              ? ModernColors.greenGradient
                              : ModernColors.redGradient,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: ModernShadows.large,
                        border: Border.all(
                          color: ModernColors.textOnDark.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                child: Icon(
                  widget.isCorrect == true
                      ? Icons.check_rounded
                      : Icons.close_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDisabledOverlay(bool isHighContrast) {
    return Container(
      decoration: BoxDecoration(
        color: isHighContrast
            ? Colors.grey.withValues(alpha: 0.7)
            : ModernColors.overlayBackground.withValues(alpha: 0.4),
      ),
      child: Center(
        child: Icon(
          Icons.lock_outline,
          color: isHighContrast
              ? Colors.white
              : ModernColors.textOnDark.withValues(alpha: 0.7),
          size: 32,
        ),
      ),
    );
  }

  Widget _buildTapIndicator(int index, bool isHighContrast) {
    return Positioned(
      bottom: ModernSpacing.md,
      right: ModernSpacing.md,
      child: Container(
        padding: ModernSpacing.paddingSM,
        decoration: isHighContrast
            ? BoxDecoration(
                color: Colors.black,
                borderRadius: ModernSpacing.borderRadiusMedium,
                border: Border.all(color: Colors.white, width: 2),
              )
            : BoxDecoration(
                gradient: ModernColors.createLinearGradient(
                  ModernColors.purpleGradient,
                ),
                borderRadius: ModernSpacing.borderRadiusMedium,
                boxShadow: ModernShadows.small,
              ),
        child: Text(
          '${index + 1}',
          style: ModernTypography.label.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Color _getAccessibleBorderColor(int index, bool isHighContrast) {
    if (isHighContrast) {
      if (!widget.showFeedback || widget.selectedIndex != index) {
        return Colors.black;
      }
      return widget.isCorrect == true ? Colors.green : Colors.red;
    }
    return _getImageBorderColor(index);
  }

  double _getAccessibleBorderWidth(int index, bool isHighContrast) {
    if (isHighContrast) {
      return widget.showFeedback && widget.selectedIndex == index ? 4.0 : 3.0;
    }
    return _getImageBorderWidth(index);
  }

  void _handleImageSelection(int index) async {
    // Provide haptic feedback
    AccessibilityEnhancements.provideHapticFeedback(GameHapticType.button);

    // Play audio feedback
    await AudioService().playButtonSound();

    // Announce selection to screen reader
    final imageLabel = AppLocalizations.of(
      context,
    ).breedAdventure_imageOption(index + 1);
    AccessibilityUtils.announceToScreenReader(
      context,
      AppLocalizations.of(context).breedAdventure_imageSelected(imageLabel),
    );

    // Call the original callback
    widget.onImageSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return AccessibilityTheme(
      child: Semantics(
        label: AppLocalizations.of(context).breedAdventure_imageSelectionArea,
        hint: AppLocalizations.of(
          context,
        ).breedAdventure_chooseCorrectImageHint,
        child: Padding(
          padding: ModernSpacing
              .paddingHorizontalMD, // Reduced from LG to MD for bigger images
          child: Row(
            children: [
              // First image with semantic ordering
              Expanded(
                child: Semantics(
                  sortKey: const OrdinalSortKey(1),
                  child: _buildImageContainer(widget.imageUrl1, 0),
                ),
              ),

              ModernSpacing
                  .horizontalSpaceMD, // Reduced from XL to MD for bigger images
              // Second image with semantic ordering
              Expanded(
                child: Semantics(
                  sortKey: const OrdinalSortKey(2),
                  child: _buildImageContainer(widget.imageUrl2, 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A loading state for the dual image selection with elegant animations
class DualImageSelectionLoading extends StatelessWidget {
  const DualImageSelectionLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ModernSpacing.paddingHorizontalLG,
      child: Row(
        children: [
          // First placeholder with enhanced styling
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.2, // Match the updated image aspect ratio
              child: Container(
                decoration: BoxDecoration(
                  gradient: ModernColors.createLinearGradient([
                    ModernColors.surfaceLight,
                    ModernColors.surfaceMedium,
                  ]),
                  borderRadius: ModernSpacing.borderRadiusLarge,
                  border: Border.all(
                    color: ModernColors.surfaceDark.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: ModernShadows.card,
                ),
                child: const ShimmerLoading(child: SizedBox.expand()),
              ),
            ),
          ),

          ModernSpacing.horizontalSpaceMD, // Match the updated spacing
          // Second placeholder with enhanced styling
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.2, // Match the updated image aspect ratio
              child: Container(
                decoration: BoxDecoration(
                  gradient: ModernColors.createLinearGradient([
                    ModernColors.surfaceLight,
                    ModernColors.surfaceMedium,
                  ]),
                  borderRadius: ModernSpacing.borderRadiusLarge,
                  border: Border.all(
                    color: ModernColors.surfaceDark.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: ModernShadows.card,
                ),
                child: const ShimmerLoading(child: SizedBox.expand()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
