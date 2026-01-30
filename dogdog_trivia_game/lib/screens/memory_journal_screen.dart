import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/companion_controller.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../models/memory.dart';
import '../models/companion_enums.dart';
import '../services/haptic_service.dart';

/// Memory Journal screen showing the companion's adventure scrapbook
///
/// Displays collected memories, facts learned, and bond milestones
/// in a visually engaging timeline format.
class MemoryJournalScreen extends StatefulWidget {
  const MemoryJournalScreen({super.key});

  @override
  State<MemoryJournalScreen> createState() => _MemoryJournalScreenState();
}

class _MemoryJournalScreenState extends State<MemoryJournalScreen> {
  final HapticService _hapticService = HapticService();
  
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: ModernColors.createLinearGradient(
            ModernColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Consumer<CompanionController>(
            builder: (context, controller, _) {
              final companion = controller.companion;
              final memories = _filterMemories(controller.memories);
              
              return CustomScrollView(
                slivers: [
                  _buildAppBar(companion?.name ?? 'My'),
                  SliverToBoxAdapter(child: _buildStats(controller)),
                  SliverToBoxAdapter(child: _buildFilterChips()),
                  SliverPadding(
                    padding: EdgeInsets.all(ModernSpacing.md),
                    sliver: memories.isEmpty
                        ? SliverToBoxAdapter(child: _buildEmptyState())
                        : _buildMemoryGrid(memories),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(String companionName) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '$companionName\'s Memory Journal',
          style: ModernTypography.headingSmall.copyWith(
            color: ModernColors.textPrimary,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ModernColors.primaryPurple.withOpacity(0.3),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: Text('📔', style: TextStyle(fontSize: 48)),
          ),
        ),
      ),
    );
  }

  Widget _buildStats(CompanionController controller) {
    final memories = controller.memories;
    final factsCount = memories.fold<int>(
      0, 
      (sum, m) => sum + m.factsLearned.length,
    );
    final highlightedCount = memories.where((m) => m.isHighlighted).length;

    return Container(
      margin: EdgeInsets.all(ModernSpacing.md),
      padding: EdgeInsets.all(ModernSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            emoji: '📖',
            value: memories.length.toString(),
            label: 'Adventures',
          ),
          _buildStatItem(
            emoji: '🧠',
            value: factsCount.toString(),
            label: 'Facts Learned',
          ),
          _buildStatItem(
            emoji: '⭐',
            value: highlightedCount.toString(),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String emoji,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: ModernTypography.headingSmall.copyWith(
            color: ModernColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: ModernTypography.caption.copyWith(
            color: ModernColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: ModernSpacing.md),
      child: Row(
        children: [
          _buildChip('all', 'All', '📔'),
          _buildChip('favorites', 'Favorites', '⭐'),
          ...WorldArea.values.map((area) => 
            _buildChip(area.name, area.displayName, area.emoji),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String value, String label, String emoji) {
    final isSelected = _selectedFilter == value;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) {
          _hapticService.buttonTap();
          setState(() => _selectedFilter = value);
        },
        backgroundColor: Colors.white,
        selectedColor: ModernColors.primaryPurple.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected 
              ? ModernColors.primaryPurple 
              : ModernColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected 
                ? ModernColors.primaryPurple 
                : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  List<Memory> _filterMemories(List<Memory> memories) {
    if (_selectedFilter == 'all') return memories;
    if (_selectedFilter == 'favorites') {
      return memories.where((m) => m.isHighlighted).toList();
    }
    
    final area = WorldArea.values.firstWhere(
      (a) => a.name == _selectedFilter,
      orElse: () => WorldArea.home,
    );
    return memories.where((m) => m.worldAreaEnum == area).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ModernSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📭', style: TextStyle(fontSize: 64)),
            ModernSpacing.verticalSpaceLG,
            Text(
              _selectedFilter == 'all' 
                  ? 'No adventures yet!'
                  : 'No memories here yet!',
              style: ModernTypography.headingSmall.copyWith(
                color: ModernColors.textPrimary,
              ),
            ),
            ModernSpacing.verticalSpaceSM,
            Text(
              'Start exploring the Dog World to create memories!',
              style: ModernTypography.bodySmall.copyWith(
                color: ModernColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  SliverGrid _buildMemoryGrid(List<Memory> memories) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildMemoryCard(memories[index]),
        childCount: memories.length,
      ),
    );
  }

  Widget _buildMemoryCard(Memory memory) {
    return GestureDetector(
      onTap: () => _showMemoryDetail(memory),
      onLongPress: () => _toggleFavorite(memory),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: memory.isHighlighted
                  ? ModernColors.primaryYellow.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: memory.isHighlighted ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(ModernSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Area emoji badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getAreaColor(memory.worldAreaEnum).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        memory.worldAreaEnum.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  ModernSpacing.verticalSpaceSM,
                  // Title
                  Text(
                    memory.storyTitle,
                    style: ModernTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Facts count
                  Row(
                    children: [
                      const Text('🧠', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        '${memory.factsLearned.length} facts',
                        style: ModernTypography.caption.copyWith(
                          color: ModernColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Date
                  Text(
                    _formatDate(memory.timestamp),
                    style: ModernTypography.caption.copyWith(
                      color: ModernColors.textLight,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            // Favorite star
            if (memory.isHighlighted)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: ModernColors.primaryYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMemoryDetail(Memory memory) {
    _hapticService.buttonTap();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MemoryDetailSheet(memory: memory),
    );
  }

  void _toggleFavorite(Memory memory) {
    _hapticService.memorySaved();
    Provider.of<CompanionController>(context, listen: false)
        .toggleMemoryHighlight(memory.id);
  }

  Color _getAreaColor(WorldArea area) {
    switch (area) {
      case WorldArea.home:
      case WorldArea.barkPark:
        return ModernColors.primaryGreen;
      case WorldArea.vetClinic:
      case WorldArea.beachCove:
        return ModernColors.primaryBlue;
      case WorldArea.dogShowArena:
        return ModernColors.primaryPurple;
      case WorldArea.adventureTrails:
        return ModernColors.primaryYellow;
      case WorldArea.mysteryIsland:
        return ModernColors.primaryOrange;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    
    return '${date.month}/${date.day}/${date.year}';
  }
}

/// Bottom sheet showing memory details
class _MemoryDetailSheet extends StatelessWidget {
  final Memory memory;

  const _MemoryDetailSheet({required this.memory});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.all(ModernSpacing.lg),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: ModernColors.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        memory.worldAreaEnum.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  SizedBox(width: ModernSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          memory.storyTitle,
                          style: ModernTypography.headingSmall.copyWith(
                            color: ModernColors.textPrimary,
                          ),
                        ),
                        Text(
                          memory.worldAreaEnum.displayName,
                          style: ModernTypography.bodySmall.copyWith(
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ModernSpacing.verticalSpaceLG,
              // Description
              Text(
                memory.description,
                style: ModernTypography.bodyMedium.copyWith(
                  color: ModernColors.textPrimary,
                  height: 1.5,
                ),
              ),
              ModernSpacing.verticalSpaceLG,
              // Stats
              Container(
                padding: EdgeInsets.all(ModernSpacing.md),
                decoration: BoxDecoration(
                  color: ModernColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('✅', '${memory.correctAnswers}', 'Correct'),
                    _buildStat('💕', '+${(memory.bondGained * 100).toStringAsFixed(0)}%', 'Bond'),
                  ],
                ),
              ),
              ModernSpacing.verticalSpaceLG,
              // Facts learned
              if (memory.factsLearned.isNotEmpty) ...[
                Text(
                  '🧠 Facts Learned',
                  style: ModernTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textPrimary,
                  ),
                ),
                ModernSpacing.verticalSpaceSM,
                ...memory.factsLearned.map((fact) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡 ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(
                          fact,
                          style: ModernTypography.bodySmall.copyWith(
                            color: ModernColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: ModernTypography.headingSmall.copyWith(
            color: ModernColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: ModernTypography.caption.copyWith(
            color: ModernColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
