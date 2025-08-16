import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../design_system/modern_colors.dart';
import '../../design_system/modern_typography.dart';
import '../../design_system/modern_spacing.dart';
import '../../design_system/modern_shadows.dart';

/// Widget that displays breed hints when the hint power-up is used
class BreedHintDisplay extends StatefulWidget {
  final String? hint;
  final bool isVisible;
  final VoidCallback? onDismiss;
  final Duration animationDuration;

  const BreedHintDisplay({
    super.key,
    this.hint,
    this.isVisible = false,
    this.onDismiss,
    this.animationDuration = const Duration(milliseconds: 400),
  });

  @override
  State<BreedHintDisplay> createState() => _BreedHintDisplayState();
}

class _BreedHintDisplayState extends State<BreedHintDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    if (widget.isVisible && widget.hint != null) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(BreedHintDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible && widget.hint != null) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hint == null || !widget.isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: ModernSpacing.paddingHorizontalLG,
                padding: ModernSpacing.paddingLG,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: ModernColors.yellowGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: ModernSpacing.borderRadiusLarge,
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.primaryYellow.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                    ...ModernShadows.large,
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hint header
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ModernColors.textOnDark.withValues(
                              alpha: 0.2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lightbulb_rounded,
                            color: ModernColors.textOnDark,
                            size: 24,
                          ),
                        ),

                        ModernSpacing.horizontalSpaceMD,

                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.breedAdventure_hintTitle,
                            style: ModernTypography.headingSmall.copyWith(
                              color: ModernColors.textOnDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        if (widget.onDismiss != null)
                          GestureDetector(
                            onTap: widget.onDismiss,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: ModernColors.textOnDark.withValues(
                                  alpha: 0.2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: ModernColors.textOnDark,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),

                    ModernSpacing.verticalSpaceMD,

                    // Hint text
                    Text(
                      widget.hint!,
                      style: ModernTypography.bodyMedium.copyWith(
                        color: ModernColors.textOnDark,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.left,
                    ),

                    ModernSpacing.verticalSpaceSM,

                    // Hint indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: ModernSpacing.xs / 2,
                          ),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: ModernColors.textOnDark.withValues(
                              alpha: 0.6,
                            ),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A compact version of the hint display for smaller spaces
class CompactBreedHintDisplay extends StatelessWidget {
  final String? hint;
  final bool isVisible;
  final VoidCallback? onTap;

  const CompactBreedHintDisplay({
    super.key,
    this.hint,
    this.isVisible = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (hint == null || !isVisible) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: ModernSpacing.paddingMD,
        margin: ModernSpacing.paddingHorizontalMD,
        decoration: BoxDecoration(
          color: ModernColors.primaryYellow.withValues(alpha: 0.1),
          borderRadius: ModernSpacing.borderRadiusMedium,
          border: Border.all(
            color: ModernColors.primaryYellow.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              color: ModernColors.primaryYellow,
              size: 20,
            ),

            ModernSpacing.horizontalSpaceSM,

            Expanded(
              child: Text(
                hint!,
                style: ModernTypography.bodySmall.copyWith(
                  color: ModernColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A floating hint bubble that appears temporarily
class FloatingHintBubble extends StatefulWidget {
  final String hint;
  final Duration displayDuration;
  final VoidCallback? onComplete;

  const FloatingHintBubble({
    super.key,
    required this.hint,
    this.displayDuration = const Duration(seconds: 3),
    this.onComplete,
  });

  @override
  State<FloatingHintBubble> createState() => _FloatingHintBubbleState();
}

class _FloatingHintBubbleState extends State<FloatingHintBubble>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _exitController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;
  late Animation<Offset> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _exitController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeIn));

    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _exitController, curve: Curves.easeOut));

    _floatAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: const Offset(0, -0.1),
        ).animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeInOut),
        );

    _startAnimation();
  }

  void _startAnimation() async {
    await _entryController.forward();
    await Future.delayed(widget.displayDuration);
    await _exitController.forward();
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _exitController]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeInAnimation,
          child: FadeTransition(
            opacity: _fadeOutAnimation,
            child: SlideTransition(
              position: _floatAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  padding: ModernSpacing.paddingLG,
                  margin: ModernSpacing.paddingHorizontalLG,
                  decoration: BoxDecoration(
                    color: ModernColors.primaryYellow,
                    borderRadius: ModernSpacing.borderRadiusLarge,
                    boxShadow: ModernShadows.large,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb_rounded,
                        color: ModernColors.textOnDark,
                        size: 24,
                      ),

                      ModernSpacing.horizontalSpaceMD,

                      Flexible(
                        child: Text(
                          widget.hint,
                          style: ModernTypography.bodyMedium.copyWith(
                            color: ModernColors.textOnDark,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
