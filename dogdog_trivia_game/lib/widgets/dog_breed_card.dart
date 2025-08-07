import 'package:flutter/material.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_spacing.dart';
import '../design_system/modern_shadows.dart';
import '../design_system/modern_typography.dart';
import '../services/image_service.dart';
import '../utils/accessibility.dart';
import '../utils/responsive.dart';

/// A card widget featuring dog breed images with modern styling.
///
/// This widget provides a consistent card design for displaying dog breeds with support for:
/// - Dog breed images with modern styling
/// - Interactive states and press animations
/// - Proper image loading and error handling
/// - Difficulty-based gradient backgrounds
class DogBreedCard extends StatefulWidget {
  /// The dog breed name
  final String breedName;

  /// The difficulty level associated with this breed
  final String difficulty;

  /// Path to the dog breed image asset
  final String imagePath;

  /// Title text to display on the card
  final String? title;

  /// Subtitle text to display on the card
  final String? subtitle;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Width of the card
  final double? width;

  /// Height of the card
  final double? height;

  /// Custom padding for the card content
  final EdgeInsetsGeometry? padding;

  /// Custom margin around the card
  final EdgeInsetsGeometry? margin;

  /// Border radius for the card
  final BorderRadius? borderRadius;

  /// Whether the card is selected
  final bool isSelected;

  /// Whether the card is enabled
  final bool isEnabled;

  /// Semantic label for accessibility
  final String? semanticLabel;

  /// Whether to show the breed name overlay
  final bool showBreedName;

  /// Custom text style for the breed name
  final TextStyle? breedNameStyle;

  /// Custom text style for the title
  final TextStyle? titleStyle;

  /// Custom text style for the subtitle
  final TextStyle? subtitleStyle;

  /// Creates a dog breed card widget
  const DogBreedCard({
    super.key,
    required this.breedName,
    required this.difficulty,
    required this.imagePath,
    this.title,
    this.subtitle,
    this.onTap,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.isSelected = false,
    this.isEnabled = true,
    this.semanticLabel,
    this.showBreedName = true,
    this.breedNameStyle,
    this.titleStyle,
    this.subtitleStyle,
  });

  /// Creates a difficulty selection card
  const DogBreedCard.difficulty({
    super.key,
    required this.breedName,
    required this.difficulty,
    required this.imagePath,
    required this.onTap,
    this.width,
    this.height,
    this.isSelected = false,
    this.isEnabled = true,
    this.semanticLabel,
  }) : title = null,
       subtitle = null,
       padding = null,
       margin = null,
       borderRadius = null,
       showBreedName = true,
       breedNameStyle = null,
       titleStyle = null,
       subtitleStyle = null;

  /// Creates an achievement card with dog breed
  const DogBreedCard.achievement({
    super.key,
    required this.breedName,
    required this.difficulty,
    required this.imagePath,
    required this.title,
    this.subtitle,
    this.onTap,
    this.width,
    this.height,
    this.isSelected = false,
    this.isEnabled = true,
    this.semanticLabel,
  }) : padding = null,
       margin = null,
       borderRadius = null,
       showBreedName = false,
       breedNameStyle = null,
       titleStyle = null,
       subtitleStyle = null;

  @override
  State<DogBreedCard> createState() => _DogBreedCardState();
}

class _DogBreedCardState extends State<DogBreedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isEnabled && widget.onTap != null) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isEnabled && widget.onTap != null) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.isEnabled && widget.onTap != null) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use responsive and accessible spacing
    final effectivePadding =
        widget.padding ??
        EdgeInsets.all(
          ResponsiveUtils.getResponsiveSpacing(context, ModernSpacing.md),
        );
    final effectiveMargin =
        widget.margin ??
        EdgeInsets.all(
          ResponsiveUtils.getAccessibleGridSpacing(
            context,
            ModernSpacing.cardMargin,
          ),
        );
    final effectiveBorderRadius =
        widget.borderRadius ?? ModernSpacing.borderRadiusLarge;
    final gradientColors = ModernColors.getGradientForDifficulty(
      widget.difficulty,
    );
    final isInteractive = widget.isEnabled && widget.onTap != null;

    // Respect reduced motion preferences
    final animationDuration = ResponsiveUtils.getAccessibleAnimationDuration(
      context,
      const Duration(milliseconds: 200),
    );
    _animationController.duration = animationDuration;

    // Calculate shadows based on state and accessibility preferences
    List<BoxShadow> effectiveShadows;
    if (!widget.isEnabled ||
        AccessibilityUtils.isHighContrastEnabled(context)) {
      effectiveShadows = ModernShadows.none;
    } else if (widget.isSelected) {
      effectiveShadows = ModernShadows.colored(
        ModernColors.getColorForDifficulty(widget.difficulty),
        opacity: 0.4,
      );
    } else if (_isPressed) {
      effectiveShadows = ModernShadows.buttonPressed;
    } else {
      effectiveShadows = ModernShadows.card;
    }

    Widget cardContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Dog breed image
        Expanded(flex: 3, child: _buildImage()),

        if (widget.showBreedName ||
            widget.title != null ||
            widget.subtitle != null)
          Expanded(flex: 1, child: _buildTextContent()),
      ],
    );

    Widget card = AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _elevationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            margin: effectiveMargin,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: effectiveBorderRadius,
              boxShadow: effectiveShadows.map((shadow) {
                return BoxShadow(
                  color: shadow.color,
                  offset: shadow.offset,
                  blurRadius: shadow.blurRadius * _elevationAnimation.value,
                  spreadRadius: shadow.spreadRadius,
                );
              }).toList(),
              border: widget.isSelected
                  ? Border.all(
                      color: ModernColors.getColorForDifficulty(
                        widget.difficulty,
                      ),
                      width: 3.0,
                    )
                  : null,
            ),
            child: ClipRRect(
              borderRadius: effectiveBorderRadius,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isInteractive ? widget.onTap : null,
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  borderRadius: effectiveBorderRadius,
                  child: Padding(padding: effectivePadding, child: cardContent),
                ),
              ),
            ),
          ),
        );
      },
    );

    // Add semantic label
    final semanticLabel =
        widget.semanticLabel ??
        '${widget.breedName} difficulty card for ${widget.difficulty} level';

    return Semantics(
      label: semanticLabel,
      button: isInteractive,
      enabled: widget.isEnabled,
      selected: widget.isSelected,
      child: Opacity(opacity: widget.isEnabled ? 1.0 : 0.6, child: card),
    );
  }

  Widget _buildImage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      child: ImageService.getDogBreedImage(
        breedName: widget.breedName,
        fit: BoxFit.contain,
        errorWidget: _buildFallbackIcon(),
        semanticLabel: '${widget.breedName} dog breed image',
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Icon(
      Icons.pets,
      size: 80,
      color: ModernColors.textOnDark.withValues(alpha: 0.8),
    );
  }

  Widget _buildTextContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showBreedName)
              Text(
                widget.breedName,
                style:
                    widget.breedNameStyle ??
                    ModernTypography.withOnDarkColor(
                      ModernTypography.bodyMedium,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

            if (widget.title != null) ...[
              if (widget.showBreedName) const SizedBox(height: 4),
              Text(
                widget.title!,
                style:
                    widget.titleStyle ??
                    ModernTypography.withOnDarkColor(
                      ModernTypography.headingSmall,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (widget.subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                widget.subtitle!,
                style:
                    widget.subtitleStyle ??
                    ModernTypography.withOnDarkColor(
                      ModernTypography.bodySmall,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Extension methods for creating common dog breed card variants
extension DogBreedCardVariants on DogBreedCard {
  /// Creates a card for Chihuahua (Easy difficulty)
  static DogBreedCard chihuahua({
    Key? key,
    VoidCallback? onTap,
    double? width,
    double? height,
    bool isSelected = false,
    bool isEnabled = true,
    String? semanticLabel,
  }) {
    return DogBreedCard.difficulty(
      key: key,
      breedName: 'Chihuahua',
      difficulty: 'easy',
      imagePath: 'assets/images/chihuahua.png',
      onTap: onTap,
      width: width,
      height: height,
      isSelected: isSelected,
      isEnabled: isEnabled,
      semanticLabel: semanticLabel,
    );
  }

  /// Creates a card for Cocker Spaniel (Medium difficulty)
  static DogBreedCard cocker({
    Key? key,
    VoidCallback? onTap,
    double? width,
    double? height,
    bool isSelected = false,
    bool isEnabled = true,
    String? semanticLabel,
  }) {
    return DogBreedCard.difficulty(
      key: key,
      breedName: 'Cocker Spaniel',
      difficulty: 'medium',
      imagePath: 'assets/images/cocker.png',
      onTap: onTap,
      width: width,
      height: height,
      isSelected: isSelected,
      isEnabled: isEnabled,
      semanticLabel: semanticLabel,
    );
  }

  /// Creates a card for German Shepherd (Hard difficulty)
  static DogBreedCard germanShepherd({
    Key? key,
    VoidCallback? onTap,
    double? width,
    double? height,
    bool isSelected = false,
    bool isEnabled = true,
    String? semanticLabel,
  }) {
    return DogBreedCard.difficulty(
      key: key,
      breedName: 'German Shepherd',
      difficulty: 'hard',
      imagePath: 'assets/images/schaeferhund.png',
      onTap: onTap,
      width: width,
      height: height,
      isSelected: isSelected,
      isEnabled: isEnabled,
      semanticLabel: semanticLabel,
    );
  }

  /// Creates a card for Great Dane (Expert difficulty)
  static DogBreedCard greatDane({
    Key? key,
    VoidCallback? onTap,
    double? width,
    double? height,
    bool isSelected = false,
    bool isEnabled = true,
    String? semanticLabel,
  }) {
    return DogBreedCard.difficulty(
      key: key,
      breedName: 'Great Dane',
      difficulty: 'expert',
      imagePath: 'assets/images/dogge.png',
      onTap: onTap,
      width: width,
      height: height,
      isSelected: isSelected,
      isEnabled: isEnabled,
      semanticLabel: semanticLabel,
    );
  }

  /// Creates a card for a custom breed and difficulty
  static DogBreedCard custom({
    Key? key,
    required String breedName,
    required String difficulty,
    required String imagePath,
    VoidCallback? onTap,
    double? width,
    double? height,
    bool isSelected = false,
    bool isEnabled = true,
    String? semanticLabel,
  }) {
    return DogBreedCard.difficulty(
      key: key,
      breedName: breedName,
      difficulty: difficulty,
      imagePath: imagePath,
      onTap: onTap,
      width: width,
      height: height,
      isSelected: isSelected,
      isEnabled: isEnabled,
      semanticLabel: semanticLabel,
    );
  }
}
