import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/companion_controller.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../models/customization.dart';
import '../services/haptic_service.dart';

/// Screen for customizing companion with accessories and home decorations
class CustomizationScreen extends StatefulWidget {
  const CustomizationScreen({super.key});

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final HapticService _hapticService = HapticService();

  List<Accessory> _accessories = [];
  List<HomeDecoration> _decorations = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadItems();
  }

  void _loadItems() {
    // In a real app, these would be loaded from storage
    // For now, unlock items based on bond level
    final controller = Provider.of<CompanionController>(context, listen: false);
    final bondPercent = ((controller.companion?.bondLevel ?? 0) * 100).toInt();

    _accessories = DefaultAccessories.all.map((a) {
      return Accessory(
        id: a.id,
        name: a.name,
        emoji: a.emoji,
        type: a.type,
        bondRequired: a.bondRequired,
        isUnlocked: bondPercent >= a.bondRequired,
        isEquipped: false,
      );
    }).toList();

    _decorations = DefaultDecorations.all.map((d) {
      return HomeDecoration(
        id: d.id,
        name: d.name,
        emoji: d.emoji,
        category: d.category,
        bondRequired: d.bondRequired,
        isUnlocked: bondPercent >= d.bondRequired,
        isPlaced: false,
      );
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAccessoriesTab(),
                    _buildDecorationsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<CompanionController>(
      builder: (context, controller, _) {
        final companion = controller.companion;
        return Container(
          padding: EdgeInsets.all(ModernSpacing.md),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${companion?.name ?? "Buddy"}\'s Style',
                      style: ModernTypography.headingMedium.copyWith(
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Unlock more with bond level',
                      style: ModernTypography.caption.copyWith(
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ModernSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: ModernColors.primaryPurple,
          borderRadius: BorderRadius.circular(25),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: ModernColors.textSecondary,
        labelStyle: ModernTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: '👕 Accessories'),
          Tab(text: '🏠 Home Decor'),
        ],
      ),
    );
  }

  Widget _buildAccessoriesTab() {
    final groupedAccessories = <AccessoryType, List<Accessory>>{};
    for (final accessory in _accessories) {
      groupedAccessories.putIfAbsent(accessory.type, () => []).add(accessory);
    }

    return ListView.builder(
      padding: EdgeInsets.all(ModernSpacing.md),
      itemCount: groupedAccessories.length,
      itemBuilder: (context, index) {
        final type = groupedAccessories.keys.elementAt(index);
        final items = groupedAccessories[type]!;
        return _buildAccessorySection(type, items);
      },
    );
  }

  Widget _buildAccessorySection(AccessoryType type, List<Accessory> items) {
    final typeNames = {
      AccessoryType.hat: '🎩 Hats',
      AccessoryType.collar: '📿 Collars',
      AccessoryType.bandana: '🧣 Bandanas',
      AccessoryType.glasses: '🕶️ Eyewear',
      AccessoryType.bow: '🎀 Bows & Ties',
      AccessoryType.toy: '🎾 Toys',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: ModernSpacing.sm),
          child: Text(
            typeNames[type] ?? type.name,
            style: ModernTypography.headingSmall.copyWith(
              color: ModernColors.textPrimary,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildAccessoryItem(items[index]),
        ),
        ModernSpacing.verticalSpaceMD,
      ],
    );
  }

  Widget _buildAccessoryItem(Accessory accessory) {
    return GestureDetector(
      onTap: () => _onAccessoryTap(accessory),
      child: Container(
        decoration: BoxDecoration(
          color: accessory.isEquipped
              ? ModernColors.primaryPurple.withValues(alpha: 0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: accessory.isEquipped
              ? Border.all(color: ModernColors.primaryPurple, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  accessory.isUnlocked ? accessory.emoji : '🔒',
                  style: TextStyle(
                    fontSize: 32,
                    color: accessory.isUnlocked ? null : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  accessory.name,
                  style: ModernTypography.caption.copyWith(
                    color: accessory.isUnlocked
                        ? ModernColors.textPrimary
                        : ModernColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (!accessory.isUnlocked)
              Positioned(
                bottom: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: ModernColors.primaryPurple.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${accessory.bondRequired}%',
                    style: ModernTypography.caption.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            if (accessory.isEquipped)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  Icons.check_circle,
                  color: ModernColors.primaryGreen,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onAccessoryTap(Accessory accessory) {
    if (!accessory.isUnlocked) {
      _hapticService.wrongAnswer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reach ${accessory.bondRequired}% bond to unlock!'),
          backgroundColor: ModernColors.primaryPurple,
        ),
      );
      return;
    }

    _hapticService.buttonTap();

    setState(() {
      final index = _accessories.indexWhere((a) => a.id == accessory.id);
      if (index != -1) {
        // Unequip others of same type
        for (int i = 0; i < _accessories.length; i++) {
          if (_accessories[i].type == accessory.type && _accessories[i].isEquipped) {
            _accessories[i] = _accessories[i].unequip();
          }
        }
        // Toggle this one
        _accessories[index] = accessory.isEquipped
            ? accessory.unequip()
            : accessory.equip();
      }
    });
  }

  Widget _buildDecorationsTab() {
    final groupedDecorations = <DecorationCategory, List<HomeDecoration>>{};
    for (final decoration in _decorations) {
      groupedDecorations.putIfAbsent(decoration.category, () => []).add(decoration);
    }

    return ListView.builder(
      padding: EdgeInsets.all(ModernSpacing.md),
      itemCount: groupedDecorations.length,
      itemBuilder: (context, index) {
        final category = groupedDecorations.keys.elementAt(index);
        final items = groupedDecorations[category]!;
        return _buildDecorationSection(category, items);
      },
    );
  }

  Widget _buildDecorationSection(DecorationCategory category, List<HomeDecoration> items) {
    final categoryNames = {
      DecorationCategory.furniture: '🛋️ Furniture',
      DecorationCategory.wallArt: '🖼️ Wall Art',
      DecorationCategory.plants: '🌱 Plants',
      DecorationCategory.rugs: '🟫 Rugs',
      DecorationCategory.lighting: '💡 Lighting',
      DecorationCategory.outdoor: '🌳 Outdoor',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: ModernSpacing.sm),
          child: Text(
            categoryNames[category] ?? category.name,
            style: ModernTypography.headingSmall.copyWith(
              color: ModernColors.textPrimary,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildDecorationItem(items[index]),
        ),
        ModernSpacing.verticalSpaceMD,
      ],
    );
  }

  Widget _buildDecorationItem(HomeDecoration decoration) {
    return GestureDetector(
      onTap: () => _onDecorationTap(decoration),
      child: Container(
        decoration: BoxDecoration(
          color: decoration.isPlaced
              ? ModernColors.primaryGreen.withValues(alpha: 0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: decoration.isPlaced
              ? Border.all(color: ModernColors.primaryGreen, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  decoration.isUnlocked ? decoration.emoji : '🔒',
                  style: TextStyle(
                    fontSize: 36,
                    color: decoration.isUnlocked ? null : Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  decoration.name,
                  style: ModernTypography.bodySmall.copyWith(
                    color: decoration.isUnlocked
                        ? ModernColors.textPrimary
                        : ModernColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (!decoration.isUnlocked)
              Positioned(
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ModernColors.primaryPurple.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${decoration.bondRequired}% bond',
                    style: ModernTypography.caption.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            if (decoration.isPlaced)
              const Positioned(
                top: 6,
                right: 6,
                child: Icon(
                  Icons.home,
                  color: ModernColors.primaryGreen,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onDecorationTap(HomeDecoration decoration) {
    if (!decoration.isUnlocked) {
      _hapticService.wrongAnswer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reach ${decoration.bondRequired}% bond to unlock!'),
          backgroundColor: ModernColors.primaryPurple,
        ),
      );
      return;
    }

    _hapticService.buttonTap();

    setState(() {
      final index = _decorations.indexWhere((d) => d.id == decoration.id);
      if (index != -1) {
        _decorations[index] = _decorations[index].togglePlacement();
      }
    });
  }
}
