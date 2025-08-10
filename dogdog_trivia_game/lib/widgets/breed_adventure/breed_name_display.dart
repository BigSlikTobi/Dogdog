import 'package:flutter/material.dart';
import '../../design_system/modern_colors.dart';
import '../../design_system/modern_typography.dart';
import '../../design_system/modern_spacing.dart';
import '../../design_system/modern_shadows.dart';

/// Widget that displays the breed name with localized text and modern typography
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
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(BreedNameDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }

    // Animate when breed name changes
    if (widget.breedName != oldWidget.breedName) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              margin: ModernSpacing.paddingHorizontalLG,
              padding: ModernSpacing.paddingLG,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ModernColors.cardBackground,
                    ModernColors.cardBackground.withValues(alpha: 0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: ModernSpacing.borderRadiusLarge,
                boxShadow: ModernShadows.medium,
                border: Border.all(
                  color: ModernColors.primaryPurple.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Question prompt
                  Text(
                    'Which image shows a',
                    style: ModernTypography.bodyMedium.copyWith(
                      color: ModernColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  ModernSpacing.verticalSpaceSM,

                  // Breed name
                  Text(
                    widget.breedName,
                    style: ModernTypography.headingLarge.copyWith(
                      color: ModernColors.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  ModernSpacing.verticalSpaceXS,

                  // Question mark indicator
                  Text(
                    '?',
                    style: ModernTypography.displayMedium.copyWith(
                      color: ModernColors.primaryPurple.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    return Container(
      padding: ModernSpacing.paddingMD,
      decoration: BoxDecoration(
        color: ModernColors.surfaceLight,
        borderRadius: ModernSpacing.borderRadiusMedium,
        border: Border.all(
          color: ModernColors.primaryPurple.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        breedName,
        style:
            textStyle ??
            ModernTypography.headingSmall.copyWith(
              color: textColor ?? ModernColors.primaryPurple,
              fontWeight: FontWeight.w600,
            ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
