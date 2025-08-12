import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';

/// A carousel widget for category selection that matches the home screen style
class CategoryCarousel extends StatefulWidget {
  final QuestionCategory? selectedCategory;
  final Function(QuestionCategory) onCategorySelected;
  final Function(QuestionCategory)?
  onFocusedCategoryChanged; // New callback for focus changes
  final List<QuestionCategory> availableCategories;
  final bool isMobile;
  final VoidCallback? onStartGame; // Add callback for starting the game

  const CategoryCarousel({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.availableCategories,
    this.onFocusedCategoryChanged,
    this.isMobile = false,
    this.onStartGame,
  });

  @override
  State<CategoryCarousel> createState() => _CategoryCarouselState();
}

class _CategoryCarouselState extends State<CategoryCarousel> {
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();

    // Find the index of the selected category, or default to 0
    final selectedIndex = widget.selectedCategory != null
        ? widget.availableCategories.indexOf(widget.selectedCategory!)
        : 0;

    _pageController = PageController(
      viewportFraction: widget.isMobile ? 0.75 : 0.68,
      initialPage: selectedIndex >= 0 ? selectedIndex : 0,
    );

    _currentPage = selectedIndex >= 0 ? selectedIndex.toDouble() : 0.0;

    // Notify parent about initial focused category
    if (widget.onFocusedCategoryChanged != null &&
        widget.availableCategories.isNotEmpty) {
      final initialFocusedIndex = selectedIndex >= 0 ? selectedIndex : 0;
      final initialFocusedCategory =
          widget.availableCategories[initialFocusedIndex];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onFocusedCategoryChanged!(initialFocusedCategory);
      });
    }

    _pageController.addListener(() {
      final newPage = _pageController.page ?? 0.0;
      setState(() => _currentPage = newPage);

      // Notify parent about the focused category change
      if (widget.onFocusedCategoryChanged != null &&
          widget.availableCategories.isNotEmpty) {
        final focusedIndex = newPage.round().clamp(
          0,
          widget.availableCategories.length - 1,
        );
        final focusedCategory = widget.availableCategories[focusedIndex];
        widget.onFocusedCategoryChanged!(focusedCategory);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.availableCategories.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildCategoryCarousel(),
        SizedBox(height: ModernSpacing.md),
        _buildCarouselIndicators(),
      ],
    );
  }

  Widget _buildCategoryCarousel() {
    final height = widget.isMobile
        ? 180.0
        : 220.0; // Reduced height to prevent overflow

    return SizedBox(
      height: height,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.availableCategories.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) => _buildCarouselCard(index, height),
      ),
    );
  }

  Widget _buildCarouselCard(int index, double height) {
    final category = widget.availableCategories[index];
    final isSelected = widget.selectedCategory == category;

    final delta = index - _currentPage;
    final clamped = delta.clamp(-1.0, 1.0);

    // 3D transform values
    final scale = 1 - (clamped.abs() * 0.15);
    final rotationY = clamped * 0.35;
    final translationX = clamped * -30.0;
    final elevation = 8.0 + (1 - clamped.abs()) * 10.0;

    final gradient = _getCategoryColors(category);

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..translate(translationX)
            ..rotateY(rotationY)
            ..scale(scale, scale),
          child: Opacity(opacity: (1 - clamped.abs() * 0.4), child: child),
        );
      },
      child: Semantics(
        label:
            '${category.getLocalizedName(Localizations.localeOf(context).languageCode)} category card',
        selected: isSelected,
        button: true,
        child: GestureDetector(
          onTap: () {
            // Select the category and start the game directly
            widget.onCategorySelected(category);
            if (widget.onStartGame != null) {
              widget.onStartGame!();
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: elevation,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  gradient.first.withValues(alpha: 0.95),
                  gradient.last.withValues(alpha: 0.92),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(ModernSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withValues(alpha: 0.75),
                backgroundBlendMode: BlendMode.luminosity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_buildCategoryIcon(category, gradient)],
                  ),
                  SizedBox(height: ModernSpacing.md),
                  Text(
                    category.getLocalizedName(
                      Localizations.localeOf(context).languageCode,
                    ),
                    style: ModernTypography.headingSmall.copyWith(
                      fontSize: widget.isMobile ? 16 : 18,
                      color: ModernColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ModernSpacing.sm),
                  Text(
                    _getCategoryDescription(category),
                    style: ModernTypography.bodySmall.copyWith(
                      color: ModernColors.textSecondary,
                      height: 1.3,
                      fontSize: widget.isMobile ? 12 : 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(QuestionCategory category, List<Color> gradient) {
    final iconData = _getCategoryIcon(category);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        iconData,
        color: gradient.first,
        size: widget.isMobile ? 24 : 28,
      ),
    );
  }

  Widget _buildCarouselIndicators() {
    final total = widget.availableCategories.length;

    if (total <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: (i - _currentPage).abs() < 0.5 ? 22 : 10,
            decoration: BoxDecoration(
              color: (i - _currentPage).abs() < 0.5
                  ? ModernColors.primaryPurple
                  : ModernColors.primaryPurple.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(ModernSpacing.lg),
      child: Column(
        children: [
          Icon(
            Icons.category_outlined,
            size: 48,
            color: ModernColors.textSecondary,
          ),
          SizedBox(height: ModernSpacing.md),
          Text(
            'No categories available',
            style: ModernTypography.bodyMedium.copyWith(
              color: ModernColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Color> _getCategoryColors(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.dogTraining:
        return ModernColors.greenGradient;
      case QuestionCategory.dogBreeds:
        return ModernColors.blueGradient;
      case QuestionCategory.dogBehavior:
        return ModernColors.purpleGradient;
      case QuestionCategory.dogHealth:
        return ModernColors.redGradient;
      case QuestionCategory.dogHistory:
        return ModernColors.orangeGradient;
    }
  }

  IconData _getCategoryIcon(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.dogTraining:
        return Icons.school;
      case QuestionCategory.dogBreeds:
        return Icons.pets;
      case QuestionCategory.dogBehavior:
        return Icons.psychology;
      case QuestionCategory.dogHealth:
        return Icons.health_and_safety;
      case QuestionCategory.dogHistory:
        return Icons.history_edu;
    }
  }

  String _getCategoryDescription(QuestionCategory category) {
    final locale = Localizations.localeOf(context).languageCode;

    switch (category) {
      case QuestionCategory.dogTraining:
        switch (locale) {
          case 'de':
            return 'Lerne über Hundetraining und Befehle';
          case 'es':
            return 'Aprende sobre entrenamiento y comandos';
          default:
            return 'Learn about dog training and commands';
        }
      case QuestionCategory.dogBreeds:
        switch (locale) {
          case 'de':
            return 'Entdecke verschiedene Hunderassen';
          case 'es':
            return 'Descubre diferentes razas de perros';
          default:
            return 'Discover different dog breeds';
        }
      case QuestionCategory.dogBehavior:
        switch (locale) {
          case 'de':
            return 'Verstehe Hundeverhalten';
          case 'es':
            return 'Entiende el comportamiento canino';
          default:
            return 'Understand dog behavior';
        }
      case QuestionCategory.dogHealth:
        switch (locale) {
          case 'de':
            return 'Erfahre über Hundegesundheit';
          case 'es':
            return 'Aprende sobre salud canina';
          default:
            return 'Learn about dog health';
        }
      case QuestionCategory.dogHistory:
        switch (locale) {
          case 'de':
            return 'Entdecke die Geschichte der Hunde';
          case 'es':
            return 'Descubre la historia canina';
          default:
            return 'Discover dog history';
        }
    }
  }
}
