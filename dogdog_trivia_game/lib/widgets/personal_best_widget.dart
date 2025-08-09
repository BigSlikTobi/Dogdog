import 'package:flutter/material.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../design_system/modern_shadows.dart';

/// Widget that displays personal best celebrations and achievement notifications
class PersonalBestWidget extends StatefulWidget {
  final int newScore;
  final int previousBest;
  final VoidCallback? onAnimationComplete;
  final Duration duration;

  const PersonalBestWidget({
    super.key,
    required this.newScore,
    required this.previousBest,
    this.onAnimationComplete,
    this.duration = const Duration(milliseconds: 3000),
  });

  @override
  State<PersonalBestWidget> createState() => _PersonalBestWidgetState();
}

class _PersonalBestWidgetState extends State<PersonalBestWidget>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _celebrationController;
  late AnimationController _sparkleController;
  late AnimationController _exitController;

  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _exitController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.easeInOut),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _exitController, curve: Curves.easeOut));

    _startAnimation();
  }

  void _startAnimation() async {
    // Entry animation
    await _entryController.forward();

    // Celebration effects
    _celebrationController.repeat();
    _sparkleController.repeat();

    // Wait for display duration
    await Future.delayed(const Duration(milliseconds: 2000));

    // Exit animation
    _celebrationController.stop();
    _sparkleController.stop();
    await _exitController.forward();

    widget.onAnimationComplete?.call();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _celebrationController.dispose();
    _sparkleController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  Widget _buildSparkle(double position, double size, Color color) {
    return Positioned(
      left: position * MediaQuery.of(context).size.width,
      top: 20 + (30 * _sparkleAnimation.value),
      child: Transform.rotate(
        angle: _rotationAnimation.value * 6.28,
        child: Icon(
          Icons.star_rounded,
          color: color.withValues(alpha: _sparkleAnimation.value),
          size: size,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _slideAnimation,
        _scaleAnimation,
        _rotationAnimation,
        _sparkleAnimation,
        _fadeOutAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeOutAnimation.value,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Sparkle effects
                  _buildSparkle(0.2, 20, ModernColors.primaryYellow),
                  _buildSparkle(0.8, 16, ModernColors.primaryPurple),
                  _buildSparkle(0.5, 24, ModernColors.primaryGreen),
                  _buildSparkle(0.1, 14, ModernColors.primaryBlue),
                  _buildSparkle(0.9, 18, ModernColors.primaryRed),

                  // Main achievement card
                  Container(
                    margin: ModernSpacing.paddingLG,
                    padding: ModernSpacing.paddingLG,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ModernColors.primaryYellow,
                          ModernColors.primaryGreen,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: ModernSpacing.borderRadiusLarge,
                      boxShadow: [
                        BoxShadow(
                          color: ModernColors.primaryYellow.withValues(
                            alpha: 0.4,
                          ),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                        ...ModernShadows.large,
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Trophy icon with rotation
                        Transform.rotate(
                          angle: _rotationAnimation.value * 0.2,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: ModernColors.textOnDark.withValues(
                                alpha: 0.2,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.emoji_events_rounded,
                              color: ModernColors.textOnDark,
                              size: 48,
                            ),
                          ),
                        ),

                        SizedBox(height: ModernSpacing.md),

                        // Achievement title
                        Text(
                          'PERSONAL BEST!',
                          style: ModernTypography.headingLarge.copyWith(
                            color: ModernColors.textOnDark,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: ModernSpacing.sm),

                        // Score comparison
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Previous',
                                  style: ModernTypography.caption.copyWith(
                                    color: ModernColors.textOnDark.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${widget.previousBest}',
                                  style: ModernTypography.bodyLarge.copyWith(
                                    color: ModernColors.textOnDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: ModernSpacing.md,
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: ModernColors.textOnDark,
                                size: 24,
                              ),
                            ),

                            Column(
                              children: [
                                Text(
                                  'New Best',
                                  style: ModernTypography.caption.copyWith(
                                    color: ModernColors.textOnDark.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${widget.newScore}',
                                  style: ModernTypography.headingMedium
                                      .copyWith(
                                        color: ModernColors.textOnDark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: ModernSpacing.sm),

                        // Improvement amount
                        Container(
                          padding: ModernSpacing.paddingMD,
                          decoration: BoxDecoration(
                            color: ModernColors.textOnDark.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: ModernSpacing.borderRadiusMedium,
                          ),
                          child: Text(
                            '+${widget.newScore - widget.previousBest} points improvement!',
                            style: ModernTypography.bodyMedium.copyWith(
                              color: ModernColors.textOnDark,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
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
