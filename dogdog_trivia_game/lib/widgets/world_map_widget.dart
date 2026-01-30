import 'package:flutter/material.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../models/companion_enums.dart';
import '../services/haptic_service.dart';

/// Interactive world map for exploring dog learning areas
///
/// Displays unlockable areas based on companion growth stage,
/// with visual fog-of-war and discovery animations.
class WorldMapWidget extends StatefulWidget {
  /// Current growth stage of the companion
  final GrowthStage currentStage;

  /// Callback when an area is selected
  final void Function(WorldArea area)? onAreaSelected;

  /// Currently selected area
  final WorldArea? selectedArea;

  const WorldMapWidget({
    super.key,
    required this.currentStage,
    this.onAreaSelected,
    this.selectedArea,
  });

  @override
  State<WorldMapWidget> createState() => _WorldMapWidgetState();
}

class _WorldMapWidgetState extends State<WorldMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final HapticService _hapticService = HapticService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ModernSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF87CEEB).withOpacity(0.3), // Sky blue
            const Color(0xFF98D982).withOpacity(0.3), // Grass green
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          ModernSpacing.verticalSpaceMD,
          Expanded(
            child: _buildMapGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text('🗺️', style: TextStyle(fontSize: 24)),
        SizedBox(width: ModernSpacing.sm),
        Text(
          'Dog World',
          style: ModernTypography.headingSmall.copyWith(
            color: ModernColors.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ModernSpacing.md,
            vertical: ModernSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _getStageColor(widget.currentStage).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.currentStage.emoji,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 4),
              Text(
                widget.currentStage.displayName,
                style: ModernTypography.caption.copyWith(
                  color: _getStageColor(widget.currentStage),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: WorldArea.values.length,
      itemBuilder: (context, index) {
        final area = WorldArea.values[index];
        return _buildAreaTile(area);
      },
    );
  }

  Widget _buildAreaTile(WorldArea area) {
    final isUnlocked = area.isUnlockedFor(widget.currentStage);
    final isSelected = widget.selectedArea == area;
    
    return GestureDetector(
      onTap: isUnlocked ? () {
        _hapticService.buttonTap();
        widget.onAreaSelected?.call(area);
      } : null,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = isSelected ? _pulseAnimation.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isUnlocked 
                ? Colors.white
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                  ? _getAreaColor(area)
                  : Colors.transparent,
              width: 3,
            ),
            boxShadow: isUnlocked ? [
              BoxShadow(
                color: isSelected
                    ? _getAreaColor(area).withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
                blurRadius: isSelected ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: EdgeInsets.all(ModernSpacing.sm),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      area.emoji,
                      style: TextStyle(
                        fontSize: 32,
                        color: isUnlocked ? null : Colors.grey,
                      ),
                    ),
                    SizedBox(height: ModernSpacing.xs),
                    Text(
                      area.displayName,
                      style: ModernTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isUnlocked
                            ? ModernColors.textPrimary
                            : ModernColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      area.description,
                      style: ModernTypography.caption.copyWith(
                        color: isUnlocked
                            ? ModernColors.textSecondary
                            : ModernColors.textLight,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Lock overlay
              if (!isUnlocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            area.requiredStage.displayName,
                            style: ModernTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Selected indicator
              if (isSelected && isUnlocked)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getAreaColor(area),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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

  Color _getAreaColor(WorldArea area) {
    switch (area) {
      case WorldArea.home:
        return ModernColors.primaryGreen;
      case WorldArea.barkPark:
        return ModernColors.primaryGreen;
      case WorldArea.vetClinic:
        return ModernColors.primaryBlue;
      case WorldArea.dogShowArena:
        return ModernColors.primaryPurple;
      case WorldArea.adventureTrails:
        return ModernColors.primaryYellow;
      case WorldArea.beachCove:
        return ModernColors.primaryBlue;
      case WorldArea.mysteryIsland:
        return ModernColors.primaryOrange;
    }
  }
}
