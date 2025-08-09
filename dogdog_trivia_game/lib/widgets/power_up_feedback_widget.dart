import 'package:flutter/material.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../design_system/modern_shadows.dart';
import '../models/enums.dart';
import '../utils/enum_extensions.dart';

/// Widget that displays satisfying power-up usage feedback with before/after state transitions
class PowerUpFeedbackWidget extends StatefulWidget {
  final PowerUpType powerUpType;
  final VoidCallback? onAnimationComplete;
  final Duration duration;

  const PowerUpFeedbackWidget({
    super.key,
    required this.powerUpType,
    this.onAnimationComplete,
    this.duration = const Duration(milliseconds: 2500),
  });

  @override
  State<PowerUpFeedbackWidget> createState() => _PowerUpFeedbackWidgetState();
}

class _PowerUpFeedbackWidgetState extends State<PowerUpFeedbackWidget>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _pulseController;
  late AnimationController _exitController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _exitController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeIn));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
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

    // Pulse effect
    _pulseController.repeat(reverse: true);

    // Wait for display duration
    await Future.delayed(const Duration(milliseconds: 1500));

    // Exit animation
    _pulseController.stop();
    await _exitController.forward();

    widget.onAnimationComplete?.call();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  IconData _getPowerUpIcon() {
    switch (widget.powerUpType) {
      case PowerUpType.fiftyFifty:
        return Icons.remove_circle_outline_rounded;
      case PowerUpType.hint:
        return Icons.lightbulb_outline_rounded;
      case PowerUpType.extraTime:
        return Icons.access_time_rounded;
      case PowerUpType.skip:
        return Icons.skip_next_rounded;
      case PowerUpType.secondChance:
        return Icons.favorite_rounded;
    }
  }

  Color _getPowerUpColor() {
    switch (widget.powerUpType) {
      case PowerUpType.fiftyFifty:
        return ModernColors.primaryRed;
      case PowerUpType.hint:
        return ModernColors.primaryYellow;
      case PowerUpType.extraTime:
        return ModernColors.primaryBlue;
      case PowerUpType.skip:
        return ModernColors.primaryGreen;
      case PowerUpType.secondChance:
        return ModernColors.primaryPurple;
    }
  }

  List<Color> _getPowerUpGradient() {
    switch (widget.powerUpType) {
      case PowerUpType.fiftyFifty:
        return ModernColors.redGradient;
      case PowerUpType.hint:
        return ModernColors.yellowGradient;
      case PowerUpType.extraTime:
        return ModernColors.blueGradient;
      case PowerUpType.skip:
        return ModernColors.greenGradient;
      case PowerUpType.secondChance:
        return ModernColors.purpleGradient;
    }
  }

  String _getPowerUpMessage() {
    switch (widget.powerUpType) {
      case PowerUpType.fiftyFifty:
        return 'Two wrong answers eliminated!';
      case PowerUpType.hint:
        return 'Helpful hint revealed!';
      case PowerUpType.extraTime:
        return 'Extra time added!';
      case PowerUpType.skip:
        return 'Question skipped successfully!';
      case PowerUpType.secondChance:
        return 'Life restored!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _fadeInAnimation,
        _pulseAnimation,
        _fadeOutAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeInAnimation.value * _fadeOutAnimation.value,
            child: Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                margin: ModernSpacing.paddingLG,
                padding: ModernSpacing.paddingLG,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getPowerUpGradient(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: ModernSpacing.borderRadiusLarge,
                  boxShadow: [
                    BoxShadow(
                      color: _getPowerUpColor().withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    ...ModernShadows.large,
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Power-up icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: ModernColors.textOnDark.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getPowerUpIcon(),
                        color: ModernColors.textOnDark,
                        size: 32,
                      ),
                    ),

                    SizedBox(height: ModernSpacing.md),

                    // Power-up name
                    Text(
                      widget.powerUpType.displayName(context),
                      style: ModernTypography.headingMedium.copyWith(
                        color: ModernColors.textOnDark,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: ModernSpacing.xs),

                    // Power-up effect message
                    Text(
                      _getPowerUpMessage(),
                      style: ModernTypography.bodyMedium.copyWith(
                        color: ModernColors.textOnDark,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: ModernSpacing.sm),

                    // Visual effect indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: ModernSpacing.xs / 2,
                          ),
                          width: 8,
                          height: 8,
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
