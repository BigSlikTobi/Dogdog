import 'package:flutter/material.dart';
import '../design_system/modern_colors.dart';
import '../models/companion_enums.dart';

/// Widget displaying the bond meter (replaces traditional score)
/// 
/// Shows the emotional connection between player and companion,
/// with visual growth stage indicators and animated progression.
class BondMeterWidget extends StatelessWidget {
  /// Current bond level (0.0 to 1.0)
  final double bondLevel;

  /// Whether to show the growth stage label
  final bool showStageLabel;

  /// Height of the meter
  final double height;

  /// Whether to animate changes
  final bool animate;

  /// Callback when meter is tapped
  final VoidCallback? onTap;

  const BondMeterWidget({
    super.key,
    required this.bondLevel,
    this.showStageLabel = true,
    this.height = 12.0,
    this.animate = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final stage = GrowthStage.fromBondLevel(bondLevel);
    final stageProgress = _calculateStageProgress(bondLevel, stage);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showStageLabel) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      stage.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stage.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${(bondLevel * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getStageColor(stage),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Container(
            height: height,
            decoration: BoxDecoration(
              color: ModernColors.surfaceMedium,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: Stack(
              children: [
                // Stage markers
                ..._buildStageMarkers(height),
                // Progress fill
                AnimatedContainer(
                  duration: animate ? const Duration(milliseconds: 500) : Duration.zero,
                  curve: Curves.easeOutCubic,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: bondLevel.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getGradientColors(stage),
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(height / 2),
                        boxShadow: [
                          BoxShadow(
                            color: _getStageColor(stage).withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Sparkle at current level
                if (animate)
                  Positioned(
                    left: (bondLevel.clamp(0.0, 1.0) * MediaQuery.of(context).size.width * 0.8) - 4,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.8),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStageMarkers(double barHeight) {
    return [
      for (final stage in GrowthStage.values)
        if (stage != GrowthStage.puppy) // No marker at start
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: stage.minBond,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 2,
                  height: barHeight,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
    ];
  }

  double _calculateStageProgress(double bond, GrowthStage stage) {
    final range = stage.maxBond - stage.minBond;
    if (range == 0) return 1.0;
    return ((bond - stage.minBond) / range).clamp(0.0, 1.0);
  }

  Color _getStageColor(GrowthStage stage) {
    switch (stage) {
      case GrowthStage.puppy:
        return ModernColors.primaryGreen;
      case GrowthStage.adolescent:
        return ModernColors.primaryBlue;
      case GrowthStage.adult:
        return ModernColors.primaryPurple;
      case GrowthStage.elder:
        return ModernColors.primaryOrange;
    }
  }

  List<Color> _getGradientColors(GrowthStage stage) {
    switch (stage) {
      case GrowthStage.puppy:
        return ModernColors.greenGradient;
      case GrowthStage.adolescent:
        return ModernColors.blueGradient;
      case GrowthStage.adult:
        return ModernColors.purpleGradient;
      case GrowthStage.elder:
        return ModernColors.orangeGradient;
    }
  }
}
