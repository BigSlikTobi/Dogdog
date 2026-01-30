import 'package:flutter/material.dart';
import '../design_system/modern_colors.dart';
import '../models/companion.dart';
import '../models/companion_enums.dart';

/// Widget displaying the companion dog avatar with mood animations
///
/// Shows the companion's current breed, mood state, and growth stage
/// with animated reactions and emotional expressions.
class CompanionAvatarWidget extends StatefulWidget {
  /// The companion to display
  final Companion companion;

  /// Size of the avatar
  final double size;

  /// Whether to show mood indicator
  final bool showMoodIndicator;

  /// Whether to animate the avatar
  final bool animate;

  /// Callback when avatar is tapped
  final VoidCallback? onTap;

  const CompanionAvatarWidget({
    super.key,
    required this.companion,
    this.size = 80.0,
    this.showMoodIndicator = true,
    this.animate = true,
    this.onTap,
  });

  @override
  State<CompanionAvatarWidget> createState() => _CompanionAvatarWidgetState();
}

class _CompanionAvatarWidgetState extends State<CompanionAvatarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    if (widget.animate) {
      _startMoodAnimation();
    }
  }

  @override
  void didUpdateWidget(CompanionAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.companion.mood != widget.companion.mood) {
      _playMoodTransition();
    }
  }

  void _startMoodAnimation() {
    if (widget.companion.mood == CompanionMood.excited) {
      _animationController.repeat(reverse: true);
    }
  }

  void _playMoodTransition() {
    _animationController.forward().then((_) {
      _animationController.reverse();
      if (widget.companion.mood == CompanionMood.excited) {
        _animationController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.animate ? _bounceAnimation.value : 1.0,
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect based on mood
            Container(
              width: widget.size + 16,
              height: widget.size + 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getMoodColor().withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
            // Main avatar container
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _getStageGradient(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildAvatarContent(),
              ),
            ),
            // Mood indicator
            if (widget.showMoodIndicator)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.companion.mood.emoji,
                    style: TextStyle(fontSize: widget.size * 0.25),
                  ),
                ),
              ),
            // Stage badge
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStageColor(),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: _getStageColor().withOpacity(0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  widget.companion.stage.emoji,
                  style: TextStyle(fontSize: widget.size * 0.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarContent() {
    // Try to load breed image, fallback to emoji placeholder
    return Image.asset(
      widget.companion.breed.imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to breed emoji/icon
        return Container(
          color: _getStageColor().withOpacity(0.2),
          child: Center(
            child: Text(
              '🐕',
              style: TextStyle(fontSize: widget.size * 0.5),
            ),
          ),
        );
      },
    );
  }

  Color _getMoodColor() {
    switch (widget.companion.mood) {
      case CompanionMood.happy:
        return ModernColors.primaryGreen;
      case CompanionMood.curious:
        return ModernColors.primaryBlue;
      case CompanionMood.sleepy:
        return ModernColors.primaryPurple;
      case CompanionMood.excited:
        return ModernColors.primaryYellow;
    }
  }

  Color _getStageColor() {
    switch (widget.companion.stage) {
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

  List<Color> _getStageGradient() {
    switch (widget.companion.stage) {
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
