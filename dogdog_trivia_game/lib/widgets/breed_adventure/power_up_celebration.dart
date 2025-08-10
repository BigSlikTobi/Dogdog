import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../design_system/modern_colors.dart';
import '../../design_system/modern_typography.dart';
import '../../design_system/modern_spacing.dart';
import '../../design_system/modern_shadows.dart';
import '../../models/enums.dart';

/// Widget that displays celebration animations when power-ups are earned or used
class PowerUpCelebration extends StatefulWidget {
  final PowerUpType powerUpType;
  final String message;
  final bool isEarned; // true for earned, false for used
  final VoidCallback? onComplete;
  final Duration duration;

  const PowerUpCelebration({
    super.key,
    required this.powerUpType,
    required this.message,
    this.isEarned = false,
    this.onComplete,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<PowerUpCelebration> createState() => _PowerUpCelebrationState();
}

class _PowerUpCelebrationState extends State<PowerUpCelebration>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 10,
      ),
    ]).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: widget.isEarned ? 2.0 : 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    _mainController.forward();
    if (widget.isEarned) {
      _particleController.forward();
    }

    await _mainController.forward();
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  IconData _getPowerUpIcon() {
    switch (widget.powerUpType) {
      case PowerUpType.fiftyFifty:
        return Icons.remove_circle_outline_rounded;
      case PowerUpType.hint:
        return Icons.lightbulb_rounded;
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

  Widget _buildParticleEffect() {
    if (!widget.isEarned) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final angle = (index * 45.0) * (3.14159 / 180.0);
            final distance = 60.0 * _particleAnimation.value;
            final x = distance * math.cos(angle);
            final y = distance * math.sin(angle);

            return Positioned(
              left: 150 + x,
              top: 150 + y,
              child: Transform.scale(
                scale: 1.0 - _particleAnimation.value,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getPowerUpColor().withValues(
                      alpha: 1.0 - _particleAnimation.value,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _particleController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Particle effect
            _buildParticleEffect(),

            // Main celebration
            FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value * 3.14159,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getPowerUpGradient(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getPowerUpColor().withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                        ...ModernShadows.large,
                      ],
                    ),
                    child: Icon(
                      _getPowerUpIcon(),
                      color: ModernColors.textOnDark,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),

            // Message
            Positioned(
              bottom: 50,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: ModernSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: ModernColors.overlayBackground,
                    borderRadius: ModernSpacing.borderRadiusMedium,
                  ),
                  child: Text(
                    widget.message,
                    style: ModernTypography.bodyLarge.copyWith(
                      color: ModernColors.textOnDark,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A compact celebration for power-up rewards
class PowerUpRewardNotification extends StatefulWidget {
  final PowerUpType powerUpType;
  final VoidCallback? onTap;
  final Duration displayDuration;

  const PowerUpRewardNotification({
    super.key,
    required this.powerUpType,
    this.onTap,
    this.displayDuration = const Duration(seconds: 2),
  });

  @override
  State<PowerUpRewardNotification> createState() => _PowerUpRewardNotificationState();
}

class _PowerUpRewardNotificationState extends State<PowerUpRewardNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    // Auto-dismiss after display duration
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getPowerUpIcon() {
    switch (widget.powerUpType) {
      case PowerUpType.fiftyFifty:
        return Icons.remove_circle_outline_rounded;
      case PowerUpType.hint:
        return Icons.lightbulb_rounded;
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

  String _getPowerUpName() {
    switch (widget.powerUpType) {
      case PowerUpType.fiftyFifty:
        return '50/50';
      case PowerUpType.hint:
        return 'Hint';
      case PowerUpType.extraTime:
        return 'Extra Time';
      case PowerUpType.skip:
        return 'Skip';
      case PowerUpType.secondChance:
        return 'Second Chance';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                margin: ModernSpacing.paddingMD,
                padding: ModernSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: _getPowerUpColor().withValues(alpha: 0.1),
                  borderRadius: ModernSpacing.borderRadiusMedium,
                  border: Border.all(
                    color: _getPowerUpColor().withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: ModernShadows.small,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getPowerUpColor(),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getPowerUpIcon(),
                        color: ModernColors.textOnDark,
                        size: 18,
                      ),
                    ),

                    ModernSpacing.horizontalSpaceSM,

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Power-up Earned!',
                          style: ModernTypography.caption.copyWith(
                            color: ModernColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _getPowerUpName(),
                          style: ModernTypography.bodyMedium.copyWith(
                            color: _getPowerUpColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
