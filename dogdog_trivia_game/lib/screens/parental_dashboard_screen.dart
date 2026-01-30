import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/companion_controller.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../models/companion_enums.dart';
import '../services/progress_service.dart';

/// Parental Dashboard for viewing child's learning progress
/// 
/// Provides insights on:
/// - Play time and session frequency
/// - Facts learned by category
/// - Bond progression over time
/// - Areas explored and unlocked
class ParentalDashboardScreen extends StatefulWidget {
  const ParentalDashboardScreen({super.key});

  @override
  State<ParentalDashboardScreen> createState() => _ParentalDashboardScreenState();
}

class _ParentalDashboardScreenState extends State<ParentalDashboardScreen> {
  String _selectedTimeRange = 'week';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: ModernColors.createLinearGradient(
            [const Color(0xFFF5F3FF), const Color(0xFFEDE9F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(child: _buildTimeRangeSelector()),
              SliverToBoxAdapter(child: _buildOverviewCards()),
              SliverToBoxAdapter(child: _buildLearningProgress()),
              SliverToBoxAdapter(child: _buildAreasExplored()),
              SliverToBoxAdapter(child: _buildRecentHighlights()),
              SliverToBoxAdapter(child: SizedBox(height: ModernSpacing.xl)),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Learning Dashboard',
        style: ModernTypography.headingMedium.copyWith(
          color: ModernColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Color(0xFF1F2937)),
          onPressed: _showSettings,
        ),
      ],
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ModernSpacing.md),
      child: Row(
        children: [
          _buildTimeChip('Today', 'today'),
          const SizedBox(width: 8),
          _buildTimeChip('This Week', 'week'),
          const SizedBox(width: 8),
          _buildTimeChip('This Month', 'month'),
          const SizedBox(width: 8),
          _buildTimeChip('All Time', 'all'),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String label, String value) {
    final isSelected = _selectedTimeRange == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedTimeRange = value),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ModernSpacing.md,
          vertical: ModernSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? ModernColors.primaryPurple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? null : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: ModernTypography.bodySmall.copyWith(
            color: isSelected ? Colors.white : ModernColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Consumer2<CompanionController, ProgressService>(
      builder: (context, companionCtrl, progressService, _) {
        final companion = companionCtrl.companion;
        final memories = companionCtrl.memories;
        final totalFacts = memories.fold<int>(
          0,
          (sum, m) => sum + m.factsLearned.length,
        );

        return Container(
          margin: EdgeInsets.all(ModernSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: '🎮',
                  value: memories.length.toString(),
                  label: 'Adventures',
                  color: ModernColors.primaryPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: '🧠',
                  value: totalFacts.toString(),
                  label: 'Facts Learned',
                  color: ModernColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: '💕',
                  value: '${((companion?.bondLevel ?? 0) * 100).toInt()}%',
                  label: 'Bond Level',
                  color: ModernColors.primaryPink,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(ModernSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: ModernTypography.headingMedium.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: ModernTypography.caption.copyWith(
              color: ModernColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLearningProgress() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ModernSpacing.md),
      padding: EdgeInsets.all(ModernSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'Learning Progress',
                style: ModernTypography.headingSmall.copyWith(
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          ModernSpacing.verticalSpaceMD,
          _buildProgressBar('Dog Breeds', 0.75, ModernColors.primaryPurple),
          ModernSpacing.verticalSpaceSM,
          _buildProgressBar('Dog Training', 0.45, ModernColors.primaryBlue),
          ModernSpacing.verticalSpaceSM,
          _buildProgressBar('Dog Health', 0.20, ModernColors.primaryGreen),
          ModernSpacing.verticalSpaceSM,
          _buildProgressBar('Dog Behavior', 0.35, ModernColors.primaryOrange),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String category, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: ModernTypography.bodySmall.copyWith(
                color: ModernColors.textPrimary,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: ModernTypography.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAreasExplored() {
    return Consumer<CompanionController>(
      builder: (context, controller, _) {
        final unlockedAreas = controller.unlockedAreas;
        final totalAreas = WorldArea.values.length;

        return Container(
          margin: EdgeInsets.all(ModernSpacing.md),
          padding: EdgeInsets.all(ModernSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('🗺️', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        'Areas Explored',
                        style: ModernTypography.headingSmall.copyWith(
                          color: ModernColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ModernSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ModernColors.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${unlockedAreas.length}/$totalAreas',
                      style: ModernTypography.bodySmall.copyWith(
                        color: ModernColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              ModernSpacing.verticalSpaceMD,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: WorldArea.values.map((area) {
                  final isUnlocked = unlockedAreas.contains(area);
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ModernSpacing.sm,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? ModernColors.primaryPurple.withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isUnlocked
                            ? ModernColors.primaryPurple.withValues(alpha: 0.3)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isUnlocked ? area.emoji : '🔒',
                          style: TextStyle(
                            fontSize: 16,
                            color: isUnlocked ? null : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          area.displayName,
                          style: ModernTypography.caption.copyWith(
                            color: isUnlocked
                                ? ModernColors.textPrimary
                                : ModernColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentHighlights() {
    return Consumer<CompanionController>(
      builder: (context, controller, _) {
        final highlighted = controller.highlightedMemories.take(3).toList();

        if (highlighted.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: ModernSpacing.md),
          padding: EdgeInsets.all(ModernSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    'Favorite Memories',
                    style: ModernTypography.headingSmall.copyWith(
                      color: ModernColors.textPrimary,
                    ),
                  ),
                ],
              ),
              ModernSpacing.verticalSpaceMD,
              ...highlighted.map((memory) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ModernColors.primaryYellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          memory.worldAreaEnum.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memory.storyTitle,
                            style: ModernTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                              color: ModernColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${memory.factsLearned.length} facts learned',
                            style: ModernTypography.caption.copyWith(
                              color: ModernColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(ModernSpacing.lg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ModernSpacing.verticalSpaceLG,
            Text(
              'Parental Controls',
              style: ModernTypography.headingSmall,
            ),
            ModernSpacing.verticalSpaceMD,
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Play Time Limits'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.notification_important_outlined),
              title: const Text('Progress Notifications'),
              trailing: Switch(value: true, onChanged: (_) {}),
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Export Progress Report'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ModernSpacing.verticalSpaceMD,
          ],
        ),
      ),
    );
  }
}
