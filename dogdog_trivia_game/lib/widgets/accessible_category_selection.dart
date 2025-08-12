import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/enums.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../utils/accessibility_enhancements.dart';
import '../utils/accessibility.dart';
import '../l10n/generated/app_localizations.dart';

/// Enhanced accessible category selection widget for Task 15
class AccessibleCategorySelection extends StatefulWidget {
  final QuestionCategory? selectedCategory;
  final Function(QuestionCategory) onCategorySelected;
  final bool isMobile;
  final List<QuestionCategory> availableCategories;

  const AccessibleCategorySelection({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.isMobile = false,
    this.availableCategories = const [
      QuestionCategory.dogTraining,
      QuestionCategory.dogBreeds,
      QuestionCategory.dogBehavior,
      QuestionCategory.dogHealth,
      QuestionCategory.dogHistory,
    ],
  });

  @override
  State<AccessibleCategorySelection> createState() =>
      _AccessibleCategorySelectionState();
}

class _AccessibleCategorySelectionState
    extends State<AccessibleCategorySelection> {
  late FocusNode _focusNode;
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Set initial focus to selected category if available
    if (widget.selectedCategory != null) {
      _focusedIndex = widget.availableCategories.indexOf(
        widget.selectedCategory!,
      );
      if (_focusedIndex == -1) _focusedIndex = 0;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AccessibilityEnhancements.buildHighContrastContainer(
      backgroundColor: Colors.white,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: ModernSpacing.lg),
        child: Semantics(
          label: l10n.categorySelection_title,
          hint: l10n.categorySelection_hint,
          child: Card(
            elevation: AccessibilityUtils.isHighContrastEnabled(context)
                ? 0
                : 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: AccessibilityUtils.isHighContrastEnabled(context)
                  ? BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                      width: 2,
                    )
                  : BorderSide.none,
            ),
            child: Container(
              padding: EdgeInsets.all(ModernSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context),
                  SizedBox(height: ModernSpacing.md),
                  _buildCategoryGrid(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.categorySelection_title,
            style: AccessibilityUtils.getAccessibleTextStyle(
              context,
              ModernTypography.headingMedium.copyWith(
                color: ModernColors.textPrimary,
                fontSize: widget.isMobile ? 18 : 20,
              ),
            ),
          ),
          SizedBox(height: ModernSpacing.xs),
          Text(
            l10n.categorySelection_description,
            style: AccessibilityUtils.getAccessibleTextStyle(
              context,
              ModernTypography.bodyMedium.copyWith(
                color: ModernColors.textSecondary,
                fontSize: widget.isMobile ? 14 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return AccessibilityEnhancements.buildAccessibleGrid(
      gridDescription:
          'Category selection grid with ${widget.availableCategories.length} options',
      crossAxisCount: widget.isMobile ? 2 : 3,
      children: widget.availableCategories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        return _buildAccessibleCategoryButton(context, category, index);
      }).toList(),
    );
  }

  Widget _buildAccessibleCategoryButton(
    BuildContext context,
    QuestionCategory category,
    int index,
  ) {
    final l10n = AppLocalizations.of(context);
    final isSelected = widget.selectedCategory == category;
    final isFocused = _focusedIndex == index;
    final locale = Localizations.localeOf(context).languageCode;
    final categoryColors = _getCategoryColors(category);

    // Enhanced semantic description
    final semanticLabel = '${category.getLocalizedName(locale)} category';
    final semanticHint = isSelected
        ? l10n.categorySelection_selectedHint(category.getLocalizedName(locale))
        : l10n.categorySelection_selectHint(category.getLocalizedName(locale));

    return Padding(
      padding: EdgeInsets.all(ModernSpacing.xs),
      child: AccessibilityEnhancements.buildAccessibleButton(
        semanticLabel: semanticLabel,
        hint: semanticHint,
        enabled: true,
        selected: isSelected,
        onPressed: () => _handleCategorySelection(category, index),
        child: Focus(
          focusNode: index == 0 ? _focusNode : null,
          onKeyEvent: (node, event) => _handleKeyEvent(event, index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              vertical: ModernSpacing.md,
              horizontal: ModernSpacing.sm,
            ),
            decoration: _buildAccessibleButtonDecoration(
              context,
              categoryColors,
              isSelected,
              isFocused,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCategoryIcon(
                  context,
                  category,
                  isSelected,
                  categoryColors,
                ),
                SizedBox(height: ModernSpacing.sm),
                _buildCategoryLabel(context, category, isSelected),
                if (isSelected) ...[
                  SizedBox(height: ModernSpacing.xs),
                  _buildSelectedIndicator(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildAccessibleButtonDecoration(
    BuildContext context,
    List<Color> categoryColors,
    bool isSelected,
    bool isFocused,
  ) {
    final isHighContrast = AccessibilityUtils.isHighContrastEnabled(context);

    if (isHighContrast) {
      return BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused
              ? Theme.of(context).colorScheme.secondary
              : (isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.outline),
          width: isFocused ? 3 : 2,
        ),
      );
    }

    return BoxDecoration(
      gradient: isSelected
          ? LinearGradient(
              colors: categoryColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      color: isSelected ? null : ModernColors.surfaceLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isFocused
            ? ModernColors.primaryBlue
            : (isSelected ? categoryColors.first : ModernColors.surfaceDark),
        width: isFocused ? 3 : (isSelected ? 2 : 1),
      ),
      boxShadow: isSelected || isFocused
          ? [
              BoxShadow(
                color:
                    (isFocused
                            ? ModernColors.primaryBlue
                            : categoryColors.first)
                        .withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  Widget _buildCategoryIcon(
    BuildContext context,
    QuestionCategory category,
    bool isSelected,
    List<Color> categoryColors,
  ) {
    final isHighContrast = AccessibilityUtils.isHighContrastEnabled(context);
    final iconColor = isHighContrast
        ? (isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface)
        : (isSelected ? Colors.white : categoryColors.first);

    return Semantics(
      image: true,
      label:
          'Icon for ${category.getLocalizedName(Localizations.localeOf(context).languageCode)}',
      child: Icon(
        _getCategoryIcon(category),
        color: iconColor,
        size: widget.isMobile ? 32 : 36,
      ),
    );
  }

  Widget _buildCategoryLabel(
    BuildContext context,
    QuestionCategory category,
    bool isSelected,
  ) {
    final locale = Localizations.localeOf(context).languageCode;
    final isHighContrast = AccessibilityUtils.isHighContrastEnabled(context);

    final textColor = isHighContrast
        ? (isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface)
        : (isSelected ? Colors.white : ModernColors.textPrimary);

    return Text(
      category.getLocalizedName(locale),
      style: AccessibilityUtils.getAccessibleTextStyle(
        context,
        ModernTypography.bodyMedium.copyWith(
          color: textColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: widget.isMobile ? 14 : 16,
        ),
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSelectedIndicator(BuildContext context) {
    final isHighContrast = AccessibilityUtils.isHighContrastEnabled(context);

    return Semantics(
      label: 'Selected',
      child: Icon(
        Icons.check_circle,
        color: isHighContrast
            ? Theme.of(context).colorScheme.onPrimary
            : Colors.white,
        size: 20,
      ),
    );
  }

  KeyEventResult _handleKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          _moveFocus(-1);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowRight:
          _moveFocus(1);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowUp:
          _moveFocus(widget.isMobile ? -2 : -3);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowDown:
          _moveFocus(widget.isMobile ? 2 : 3);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.space:
          _handleCategorySelection(
            widget.availableCategories[_focusedIndex],
            _focusedIndex,
          );
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _moveFocus(int delta) {
    setState(() {
      _focusedIndex = (_focusedIndex + delta).clamp(
        0,
        widget.availableCategories.length - 1,
      );
    });

    // Announce focus change to screen reader
    final category = widget.availableCategories[_focusedIndex];
    final locale = Localizations.localeOf(context).languageCode;
    AccessibilityUtils.announceToScreenReader(
      context,
      'Focused on ${category.getLocalizedName(locale)} category',
    );
  }

  void _handleCategorySelection(QuestionCategory category, int index) {
    // Provide haptic feedback
    HapticFeedback.selectionClick();

    // Update focus
    setState(() {
      _focusedIndex = index;
    });

    // Announce selection to screen reader
    final locale = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context);
    AccessibilityUtils.announceToScreenReader(
      context,
      l10n.categorySelection_announceSelection(
        category.getLocalizedName(locale),
      ),
    );

    // Call the callback
    widget.onCategorySelected(category);
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
        return Icons.school_rounded;
      case QuestionCategory.dogBreeds:
        return Icons.pets_rounded;
      case QuestionCategory.dogBehavior:
        return Icons.psychology_rounded;
      case QuestionCategory.dogHealth:
        return Icons.health_and_safety_rounded;
      case QuestionCategory.dogHistory:
        return Icons.history_edu_rounded;
    }
  }
}
