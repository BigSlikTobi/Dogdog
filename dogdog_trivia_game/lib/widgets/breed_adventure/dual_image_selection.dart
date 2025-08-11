import 'package:flutter/material.dart';
import '../../design_system/modern_colors.dart';
import '../../design_system/modern_typography.dart';
import '../../design_system/modern_spacing.dart';
import '../../design_system/modern_shadows.dart';
import '../../widgets/loading_animation.dart';

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

        return Transform.scale(
          scale: scale,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: widget.isEnabled
                  ? () => widget.onImageSelected(index)
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: ModernSpacing.borderRadiusLarge,
                  border: Border.all(
                    color: _getImageBorderColor(index),
                    width: _getImageBorderWidth(index),
                  ),
                  boxShadow: [
                    if (isSelected && showFeedback) ...[
                      BoxShadow(
                        color: widget.isCorrect == true
                            ? ModernColors.success.withValues(alpha: 0.3)
                            : ModernColors.error.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ] else
                      ...ModernShadows.medium,
                  ],
                ),
                child: ClipRRect(
                  borderRadius: ModernSpacing.borderRadiusLarge,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Stack(
                      children: [
                        // Image
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: ModernColors.surfaceLight,
                              child: const Center(
                                child: ShimmerLoading(
                                  child: SizedBox(width: 60, height: 60),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: ModernColors.surfaceLight,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 40,
                                    color: ModernColors.textLight,
                                  ),
                                  ModernSpacing.verticalSpaceSM,
                                  Text(
                                    'Image failed to load',
                                    style: ModernTypography.caption,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // Selection overlay - controlled directly by showFeedback state
                        if (isSelected && widget.showFeedback)
                          Container(
                            decoration: BoxDecoration(
                              color: widget.isCorrect == true
                                  ? ModernColors.success.withValues(alpha: 0.2)
                                  : ModernColors.error.withValues(alpha: 0.2),
                            ),
                            child: Center(
                              child: AnimatedBuilder(
                                animation: _feedbackController,
                                builder: (context, child) {
                                  // Use animation for the icon scale/appearance
                                  final scale = widget.showFeedback
                                      ? (_feedbackController.value * 0.3 + 0.7)
                                      : 0.0;

                                  return Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: widget.isCorrect == true
                                            ? ModernColors.success
                                            : ModernColors.error,
                                        shape: BoxShape.circle,
                                        boxShadow: ModernShadows.large,
                                      ),
                                      child: Icon(
                                        widget.isCorrect == true
                                            ? Icons.check_rounded
                                            : Icons.close_rounded,
                                        color: ModernColors.textOnDark,
                                        size: 32,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                        // Disabled overlay
                        if (!widget.isEnabled)
                          Container(
                            decoration: BoxDecoration(
                              color: ModernColors.overlayBackground.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),

                        // Tap indicator
                        if (widget.isEnabled && !showFeedback)
                          Positioned(
                            bottom: ModernSpacing.sm,
                            right: ModernSpacing.sm,
                            child: Container(
                              padding: ModernSpacing.paddingXS,
                              decoration: BoxDecoration(
                                color: ModernColors.overlayBackground,
                                borderRadius: ModernSpacing.borderRadiusSmall,
                              ),
                              child: Text(
                                '${index + 1}',
                                style: ModernTypography.caption.copyWith(
                                  color: ModernColors.textOnDark,
                                  fontWeight: FontWeight.bold,
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // First image
        Expanded(child: _buildImageContainer(widget.imageUrl1, 0)),

        ModernSpacing.horizontalSpaceLG,

        // Second image
        Expanded(child: _buildImageContainer(widget.imageUrl2, 1)),
      ],
    );
  }
}

/// A loading state for the dual image selection
class DualImageSelectionLoading extends StatelessWidget {
  const DualImageSelectionLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // First placeholder
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: ModernColors.surfaceLight,
                borderRadius: ModernSpacing.borderRadiusLarge,
                border: Border.all(color: ModernColors.surfaceDark, width: 2.0),
              ),
              child: const ShimmerLoading(child: SizedBox.expand()),
            ),
          ),
        ),

        ModernSpacing.horizontalSpaceLG,

        // Second placeholder
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: ModernColors.surfaceLight,
                borderRadius: ModernSpacing.borderRadiusLarge,
                border: Border.all(color: ModernColors.surfaceDark, width: 2.0),
              ),
              child: const ShimmerLoading(child: SizedBox.expand()),
            ),
          ),
        ),
      ],
    );
  }
}
