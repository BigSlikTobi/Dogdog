import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../design_system/modern_colors.dart';
import '../../design_system/modern_typography.dart';
import '../../design_system/modern_spacing.dart';
import '../../design_system/modern_shadows.dart';
import '../shared/loading_animation.dart';
import 'loading_error_states.dart';
import '../../services/image_service.dart';
import '../../utils/accessibility.dart';
import '../../utils/accessibility_enhancements.dart' hide AccessibilityTheme;
import '../../l10n/generated/app_localizations.dart';
import '../../services/audio_service.dart';

/// A widget that displays two images side-by-side for the user to select from.
///
/// This widget is a core component of the Dog Breed Adventure game. It is responsible for:
/// - Displaying two images from URLs.
/// - Handling user taps on the images.
/// - Showing feedback on whether the selection was correct or incorrect.
/// - Providing accessibility features, such as semantic labels and focus management.
class DualImageSelection extends StatefulWidget {
  /// The URL of the first image.
  final String imageUrl1;

  /// The URL of the second image.
  final String imageUrl2;

  /// A callback function that is called when an image is selected.
  final Function(int) onImageSelected;

  /// Whether the widget is enabled for user interaction.
  final bool isEnabled;

  /// The index of the currently selected image.
  final int? selectedIndex;

  /// Whether the selected answer is correct.
  final bool? isCorrect;

  /// Whether to show feedback on the selection.
  final bool showFeedback;

  /// The duration of the entry animation.
  final Duration animationDuration;

  /// Creates a new instance of [DualImageSelection].
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

/// The state for the [DualImageSelection] widget.
class _DualImageSelectionState extends State<DualImageSelection>
    with TickerProviderStateMixin {
  /// The animation controller for the entry animation.
  late AnimationController _entryController;

  /// The animation controller for the feedback animation.
  late AnimationController _feedbackController;

  /// The scale animation for the entry animation.
  late Animation<double> _scaleAnimation;

  /// The fade animation for the entry animation.
  late Animation<double> _fadeAnimation;

  /// The feedback animation for when an answer is selected.
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

  /// Gets the border color for an image based on the selection state.
  Color _getImageBorderColor(int index) {
    if (!widget.showFeedback || widget.selectedIndex != index) {
      return ModernColors.surfaceDark;
    }

    return widget.isCorrect == true ? ModernColors.success : ModernColors.error;
  }

  /// Gets the border width for an image based on the selection state.
  double _getImageBorderWidth(int index) {
    if (!widget.showFeedback || widget.selectedIndex != index) {
      return 2.0;
    }
    return 4.0;
  }

  /// Builds the container for a single image.
  Widget _buildImageContainer(String imageUrl, int index) {
    final isSelected = widget.selectedIndex == index;
    final showFeedback = widget.showFeedback && isSelected;
    final isHighContrast = AccessibilityUtils.isHighContrastEnabled(context);

    // Create semantic labels for accessibility.
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

  /// Builds an accessible image container with focus management and semantics.
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
                // Image with accessibility description and reliable caching
                AccessibilityEnhancements.buildAccessibleImage(
                  image: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,

                    // Enhanced caching for iPhone profile mode
                    memCacheWidth: 400,
                    memCacheHeight: 400,

                    // More persistent caching settings
                    httpHeaders: const {
                      'User-Agent': 'DogDog-TriviGame/1.0',
                      'Accept': 'image/*',
                      'Cache-Control': 'max-age=86400', // 24 hours
                    },

                    placeholder: (context, url) => const BreedImageLoading(),

                    errorWidget: (context, url, error) {
                      debugPrint('Network image failed for $url: $error');

                      // Try to extract breed name and use local fallback
                      final breedName = _extractBreedNameFromUrl(url);
                      if (breedName != null) {
                        return ImageService.getDogBreedImage(
                          breedName: breedName,
                          fit: BoxFit.cover,
                          placeholder: const BreedImageLoading(),
                          errorWidget: const BreedImageError(),
                        );
                      }

                      return const BreedImageError();
                    },

                    fadeInDuration: const Duration(milliseconds: 300),
                    fadeOutDuration: const Duration(milliseconds: 100),
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

  /// Builds the feedback overlay that is shown when an answer is selected.
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

  /// Builds the overlay that is shown when the widget is disabled.
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

  /// Builds the tap indicator that is shown on the images.
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

  /// Gets the accessible border color for an image.
  Color _getAccessibleBorderColor(int index, bool isHighContrast) {
    if (isHighContrast) {
      if (!widget.showFeedback || widget.selectedIndex != index) {
        return Colors.black;
      }
      return widget.isCorrect == true ? Colors.green : Colors.red;
    }
    return _getImageBorderColor(index);
  }

  /// Gets the accessible border width for an image.
  double _getAccessibleBorderWidth(int index, bool isHighContrast) {
    if (isHighContrast) {
      return widget.showFeedback && widget.selectedIndex == index ? 4.0 : 3.0;
    }
    return _getImageBorderWidth(index);
  }

  /// Handles the selection of an image, including haptic and audio feedback.
  void _handleImageSelection(int index) async {
    // Provide haptic feedback for the interaction.
    AccessibilityEnhancements.provideHapticFeedback(GameHapticType.button);

    // Get the localized strings before any async operations.
    final imageLabel = AppLocalizations.of(
      context,
    ).breedAdventure_imageOption(index + 1);
    final selectionAnnouncement = AppLocalizations.of(
      context,
    ).breedAdventure_imageSelected(imageLabel);

    // Play audio feedback
    await AudioService().playButtonSound();

    // Check if widget is still mounted after async operation
    if (!mounted) return;

    // Announce selection to screen reader
    AccessibilityUtils.announceToScreenReader(context, selectionAnnouncement);

    // Call the original callback
    widget.onImageSelected(index);
  }

  /// Extracts the breed name from a Supabase URL for fallback purposes.
  String? _extractBreedNameFromUrl(String url) {
    try {
      // Extract the breed name from Supabase URLs like:
      // https://...../labrador-retriever_1_1024x1024_20250809T120349Z.png
      final uri = Uri.parse(url);
      final filename = uri.pathSegments.last;

      // Remove the file extension and timestamp.
      final nameWithoutExtension = filename.split('.').first;
      final parts = nameWithoutExtension.split('_');

      if (parts.isNotEmpty) {
        final breedPart = parts.first;

        // Convert hyphenated breed names to proper format
        return breedPart
            .split('-')
            .map(
              (word) => word.isNotEmpty
                  ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                  : word,
            )
            .join(' ');
      }
    } catch (e) {
      debugPrint('Could not extract breed name from URL: $url');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool stackVertically = screenWidth < 360;

    return AccessibilityTheme(
      child: Semantics(
        label: AppLocalizations.of(context).breedAdventure_imageSelectionArea,
        hint: AppLocalizations.of(
          context,
        ).breedAdventure_chooseCorrectImageHint,
        child: Padding(
          padding: ModernSpacing
              .paddingHorizontalMD, // Reduced from LG to MD for bigger images
          child: stackVertically
              ? Column(
                  children: [
                    Semantics(
                      sortKey: const OrdinalSortKey(1),
                      child: _buildImageContainer(widget.imageUrl1, 0),
                    ),
                    SizedBox(height: ModernSpacing.md),
                    Semantics(
                      sortKey: const OrdinalSortKey(2),
                      child: _buildImageContainer(widget.imageUrl2, 1),
                    ),
                  ],
                )
              : Row(
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
/// A loading state for the [DualImageSelection] widget with elegant animations.
class DualImageSelectionLoading extends StatelessWidget {
  /// Creates a new instance of [DualImageSelectionLoading].
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
