import 'package:flutter/material.dart';
import '../../design_system/modern_colors.dart';
import '../../design_system/modern_typography.dart';
import '../../design_system/modern_spacing.dart';
import '../../services/breed_adventure/breed_adventure_services.dart';

/// Developer widget for monitoring breed adventure performance metrics
class PerformanceMonitorWidget extends StatefulWidget {
  final bool enabled;
  final bool showDetailed;

  const PerformanceMonitorWidget({
    super.key,
    this.enabled = false, // Only enable in debug mode
    this.showDetailed = false,
  });

  @override
  State<PerformanceMonitorWidget> createState() =>
      _PerformanceMonitorWidgetState();
}

class _PerformanceMonitorWidgetState extends State<PerformanceMonitorWidget> {
  late BreedAdventurePerformanceMonitor _performanceMonitor;
  late BreedAdventureMemoryManager _memoryManager;
  late OptimizedImageCacheService _imageCache;
  late FrameRateOptimizer _frameRateOptimizer;

  @override
  void initState() {
    super.initState();
    _performanceMonitor = BreedAdventurePerformanceMonitor.instance;
    _memoryManager = BreedAdventureMemoryManager.instance;
    _imageCache = OptimizedImageCacheService.instance;
    _frameRateOptimizer = FrameRateOptimizer.instance;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 50,
      right: 10,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        padding: ModernSpacing.paddingMD,
        decoration: BoxDecoration(
          color: ModernColors.cardBackground.withValues(alpha: 0.9),
          borderRadius: ModernSpacing.borderRadiusMedium,
          border: Border.all(color: ModernColors.textLight),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPerformanceHeader(),
            ModernSpacing.verticalSpaceSM,
            _buildFPSIndicator(),
            ModernSpacing.verticalSpaceSM,
            _buildMemoryIndicator(),
            ModernSpacing.verticalSpaceSM,
            _buildImageCacheIndicator(),
            if (widget.showDetailed) ...[
              ModernSpacing.verticalSpaceSM,
              _buildDetailedStats(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceHeader() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.speed, size: 16, color: ModernColors.textSecondary),
        ModernSpacing.horizontalSpaceXS,
        Text(
          'Performance',
          style: ModernTypography.label.copyWith(
            color: ModernColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFPSIndicator() {
    final stats = _performanceMonitor.getPerformanceStats();
    final fps = stats.currentFPS;
    final isGood = fps >= 55.0;
    final isMedium = fps >= 45.0;

    Color color = isGood
        ? ModernColors.success
        : isMedium
        ? ModernColors.warning
        : ModernColors.error;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        ModernSpacing.horizontalSpaceXS,
        Text(
          'FPS: ${fps.toStringAsFixed(1)}',
          style: ModernTypography.caption.copyWith(color: color),
        ),
        ModernSpacing.horizontalSpaceSM,
        Text(
          'Avg: ${stats.averageFPS.toStringAsFixed(1)}',
          style: ModernTypography.caption.copyWith(
            color: ModernColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryIndicator() {
    final stats = _memoryManager.getMemoryStats();
    final memoryMB = stats.currentUsageMB;
    final isHigh = stats.pressureLevel.index >= 2; // High or critical

    Color color = isHigh ? ModernColors.warning : ModernColors.success;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.memory, size: 12, color: color),
        ModernSpacing.horizontalSpaceXS,
        Text(
          'Memory: ${memoryMB}MB',
          style: ModernTypography.caption.copyWith(color: color),
        ),
        ModernSpacing.horizontalSpaceSM,
        Text(
          stats.pressureLevel.name.toUpperCase(),
          style: ModernTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildImageCacheIndicator() {
    final stats = _imageCache.getPerformanceStats();
    final hitRate = stats.hitRate * 100;
    final isGood = hitRate >= 80.0;

    Color color = isGood ? ModernColors.success : ModernColors.warning;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.image, size: 12, color: color),
        ModernSpacing.horizontalSpaceXS,
        Text(
          'Cache: ${stats.cacheSize}/${stats.maxCacheSize}',
          style: ModernTypography.caption.copyWith(color: color),
        ),
        ModernSpacing.horizontalSpaceSM,
        Text(
          '${hitRate.toStringAsFixed(0)}%',
          style: ModernTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedStats() {
    final performanceStats = _performanceMonitor.getPerformanceStats();
    final memoryStats = _memoryManager.getMemoryStats();
    final imageCacheStats = _imageCache.getPerformanceStats();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatRow(
          'Dropped Frames',
          '${performanceStats.droppedFrameCount}',
        ),
        _buildStatRow('Image Loads', '${imageCacheStats.totalImagesLoaded}'),
        _buildStatRow('Failed Images', '${imageCacheStats.failedUrls}'),
        _buildStatRow(
          'Avg Load Time',
          '${imageCacheStats.averageLoadTimeMs.toStringAsFixed(0)}ms',
        ),
        _buildStatRow(
          'Animation Quality',
          _frameRateOptimizer.currentQuality.name.toUpperCase(),
        ),
        _buildStatRow('Game States', '${memoryStats.gameStatesCount}'),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: ModernTypography.caption.copyWith(
              color: ModernColors.textLight,
            ),
          ),
          Text(
            value,
            style: ModernTypography.caption.copyWith(
              color: ModernColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Performance overlay that can be toggled for debugging
class PerformanceOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const PerformanceOverlay({
    super.key,
    required this.child,
    this.enabled = false,
  });

  @override
  State<PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<PerformanceOverlay> {
  bool _showDetailed = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.enabled)
          GestureDetector(
            onTap: () {
              setState(() {
                _showDetailed = !_showDetailed;
              });
            },
            child: PerformanceMonitorWidget(
              enabled: widget.enabled,
              showDetailed: _showDetailed,
            ),
          ),
      ],
    );
  }
}

/// Widget for displaying performance recommendations
class PerformanceRecommendations extends StatelessWidget {
  const PerformanceRecommendations({super.key});

  @override
  Widget build(BuildContext context) {
    final performanceMonitor = BreedAdventurePerformanceMonitor.instance;
    final recommendations = performanceMonitor.getPerformanceRecommendations();

    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: ModernSpacing.paddingMD,
      padding: ModernSpacing.paddingMD,
      decoration: BoxDecoration(
        color: ModernColors.surfaceLight,
        borderRadius: ModernSpacing.borderRadiusMedium,
        border: Border.all(color: ModernColors.textLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: ModernColors.warning,
              ),
              ModernSpacing.horizontalSpaceXS,
              Text(
                'Performance Tips',
                style: ModernTypography.label.copyWith(
                  color: ModernColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ModernSpacing.verticalSpaceSM,
          ...recommendations.map(
            (recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: ModernTypography.caption),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: ModernTypography.caption.copyWith(
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
