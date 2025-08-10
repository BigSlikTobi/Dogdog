import 'package:flutter/material.dart';
import '../../design_system/modern_colors.dart';
import '../../design_system/modern_typography.dart';
import '../../design_system/modern_spacing.dart';
import '../../design_system/modern_shadows.dart';
import '../../models/enums.dart';

/// Widget that displays power-up buttons with icons, counts, and disabled states
class PowerUpButtonRow extends StatefulWidget {
  final Map<PowerUpType, int> powerUps;
  final Function(PowerUpType) onPowerUpPressed;
  final bool isEnabled;
  final Set<PowerUpType> disabledPowerUps;

  const PowerUpButtonRow({
    super.key,
    required this.powerUps,
    required this.onPowerUpPressed,
    this.isEnabled = true,
    this.disabledPowerUps = const {},
  });

  @override
  State<PowerUpButtonRow> createState() => _PowerUpButtonRowState();
}

class _PowerUpButtonRowState extends State<PowerUpButtonRow>
    with TickerProviderStateMixin {
  late Map<PowerUpType, AnimationController> _animationControllers;
  late Map<PowerUpType, Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();

    _animationControllers = {};
    _scaleAnimations = {};

    for (final powerUpType in PowerUpType.values) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      );

      _animationControllers[powerUpType] = controller;
      _scaleAnimations[powerUpType] = Tween<double>(
        begin: 1.0,
        end: 0.95,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPowerUpPressed(PowerUpType powerUpType) {
    if (!_canUsePowerUp(powerUpType)) return;

    final controller = _animationControllers[powerUpType]!;
    controller.forward().then((_) {
      controller.reverse();
    });

    widget.onPowerUpPressed(powerUpType);
  }

  bool _canUsePowerUp(PowerUpType powerUpType) {
    if (!widget.isEnabled) return false;
    if (widget.disabledPowerUps.contains(powerUpType)) return false;
    return (widget.powerUps[powerUpType] ?? 0) > 0;
  }

  IconData _getPowerUpIcon(PowerUpType powerUpType) {
    switch (powerUpType) {
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

  Color _getPowerUpColor(PowerUpType powerUpType) {
    switch (powerUpType) {
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

  List<Color> _getPowerUpGradient(PowerUpType powerUpType) {
    switch (powerUpType) {
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

  Widget _buildPowerUpButton(PowerUpType powerUpType) {
    final count = widget.powerUps[powerUpType] ?? 0;
    final canUse = _canUsePowerUp(powerUpType);
    final animation = _scaleAnimations[powerUpType]!;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: GestureDetector(
            onTap: () => _onPowerUpPressed(powerUpType),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: canUse
                    ? LinearGradient(
                        colors: _getPowerUpGradient(powerUpType),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: canUse ? null : ModernColors.surfaceLight,
                borderRadius: ModernSpacing.borderRadiusMedium,
                border: Border.all(
                  color: canUse
                      ? _getPowerUpColor(powerUpType).withValues(alpha: 0.3)
                      : ModernColors.surfaceDark,
                  width: 1,
                ),
                boxShadow: canUse ? ModernShadows.small : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Power-up icon
                  Icon(
                    _getPowerUpIcon(powerUpType),
                    color: canUse
                        ? ModernColors.textOnDark
                        : ModernColors.textLight,
                    size: 24,
                  ),

                  // Count badge
                  if (count > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: canUse
                              ? ModernColors.textOnDark
                              : ModernColors.textLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getPowerUpColor(powerUpType),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: ModernTypography.caption.copyWith(
                              color: canUse
                                  ? _getPowerUpColor(powerUpType)
                                  : ModernColors.textOnDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Disabled overlay
                  if (!canUse)
                    Container(
                      decoration: BoxDecoration(
                        color: ModernColors.overlayBackground.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: ModernSpacing.borderRadiusMedium,
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

  @override
  Widget build(BuildContext context) {
    // Filter power-ups that are relevant for breed adventure
    final relevantPowerUps = [
      PowerUpType.hint,
      PowerUpType.extraTime,
      PowerUpType.skip,
      PowerUpType.secondChance,
    ];

    return Container(
      padding: ModernSpacing.paddingMD,
      margin: ModernSpacing.paddingHorizontalLG,
      decoration: BoxDecoration(
        color: ModernColors.cardBackground,
        borderRadius: ModernSpacing.borderRadiusLarge,
        boxShadow: ModernShadows.small,
        border: Border.all(
          color: ModernColors.surfaceDark.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Power-ups label
          Text(
            'Power-ups',
            style: ModernTypography.caption.copyWith(
              color: ModernColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),

          ModernSpacing.verticalSpaceSM,

          // Power-up buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: relevantPowerUps
                .map((powerUpType) => _buildPowerUpButton(powerUpType))
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// A compact version of power-up buttons for smaller spaces
class CompactPowerUpButtons extends StatelessWidget {
  final Map<PowerUpType, int> powerUps;
  final Function(PowerUpType) onPowerUpPressed;
  final bool isEnabled;

  const CompactPowerUpButtons({
    super.key,
    required this.powerUps,
    required this.onPowerUpPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final relevantPowerUps = [
      PowerUpType.hint,
      PowerUpType.extraTime,
      PowerUpType.skip,
      PowerUpType.secondChance,
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: relevantPowerUps.map((powerUpType) {
        final count = powerUps[powerUpType] ?? 0;
        final canUse = isEnabled && count > 0;

        return Padding(
          padding: EdgeInsets.only(right: ModernSpacing.xs),
          child: GestureDetector(
            onTap: canUse ? () => onPowerUpPressed(powerUpType) : null,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: canUse
                    ? _getPowerUpColor(powerUpType).withValues(alpha: 0.1)
                    : ModernColors.surfaceLight,
                borderRadius: ModernSpacing.borderRadiusSmall,
                border: Border.all(
                  color: canUse
                      ? _getPowerUpColor(powerUpType).withValues(alpha: 0.3)
                      : ModernColors.surfaceDark,
                  width: 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    _getPowerUpIcon(powerUpType),
                    color: canUse
                        ? _getPowerUpColor(powerUpType)
                        : ModernColors.textLight,
                    size: 18,
                  ),
                  if (count > 0)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: _getPowerUpColor(powerUpType),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: ModernTypography.caption.copyWith(
                              color: ModernColors.textOnDark,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getPowerUpIcon(PowerUpType powerUpType) {
    switch (powerUpType) {
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

  Color _getPowerUpColor(PowerUpType powerUpType) {
    switch (powerUpType) {
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
}
