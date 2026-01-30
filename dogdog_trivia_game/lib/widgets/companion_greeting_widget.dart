import 'package:flutter/material.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../models/companion.dart';
import '../models/companion_enums.dart';
import '../services/haptic_service.dart';
import 'bond_meter_widget.dart';
import 'companion_avatar_widget.dart';

/// Widget showing companion greeting when player returns
/// 
/// Displays the companion's mood, bond progress, and a personalized
/// welcome message based on how long they've been away.
class CompanionGreetingWidget extends StatefulWidget {
  /// The companion to greet with
  final Companion companion;

  /// Optional callback when greeting is dismissed
  final VoidCallback? onDismiss;

  /// Whether this is a compact inline view
  final bool compact;

  const CompanionGreetingWidget({
    super.key,
    required this.companion,
    this.onDismiss,
    this.compact = false,
  });

  @override
  State<CompanionGreetingWidget> createState() => _CompanionGreetingWidgetState();
}

class _CompanionGreetingWidgetState extends State<CompanionGreetingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final HapticService _hapticService = HapticService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    
    if (widget.companion.missedPlayer) {
      _hapticService.welcomeBack();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _greetingMessage {
    final name = widget.companion.name;
    final mood = widget.companion.mood;
    
    if (widget.companion.missedPlayer) {
      return '$name missed you! 💕';
    }
    
    switch (mood) {
      case CompanionMood.happy:
        return '$name is happy to see you!';
      case CompanionMood.curious:
        return '$name is curious about today\'s adventure!';
      case CompanionMood.sleepy:
        return '$name is a bit sleepy... 😴';
      case CompanionMood.excited:
        return '$name can\'t wait to play!';
    }
  }

  String get _timeSinceMessage {
    if (!widget.companion.missedPlayer) return '';
    return 'It\'s been ${widget.companion.timeSinceLastVisit}!';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactView();
    }
    return _buildFullView();
  }

  Widget _buildCompactView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(ModernSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CompanionAvatarWidget(
              companion: widget.companion,
              size: 56,
              showMoodIndicator: true,
            ),
            SizedBox(width: ModernSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.companion.name,
                    style: ModernTypography.headingSmall.copyWith(
                      color: ModernColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  BondMeterWidget(
                    bondLevel: widget.companion.bondLevel,
                    showStageLabel: false,
                    height: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullView() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.all(ModernSpacing.lg),
          padding: EdgeInsets.all(ModernSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _getMoodGlowColor().withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CompanionAvatarWidget(
                companion: widget.companion,
                size: 100,
                animate: true,
              ),
              ModernSpacing.verticalSpaceMD,
              Text(
                _greetingMessage,
                style: ModernTypography.headingSmall.copyWith(
                  color: ModernColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (_timeSinceMessage.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _timeSinceMessage,
                  style: ModernTypography.bodySmall.copyWith(
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
              ModernSpacing.verticalSpaceLG,
              BondMeterWidget(
                bondLevel: widget.companion.bondLevel,
                showStageLabel: true,
                height: 12,
              ),
              ModernSpacing.verticalSpaceMD,
              Text(
                '${widget.companion.stage.emoji} ${widget.companion.stage.displayName}',
                style: ModernTypography.bodyMedium.copyWith(
                  color: ModernColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.onDismiss != null) ...[
                ModernSpacing.verticalSpaceLG,
                GestureDetector(
                  onTap: () {
                    _hapticService.buttonTap();
                    widget.onDismiss?.call();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ModernSpacing.xl,
                      vertical: ModernSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: ModernColors.greenGradient,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: ModernColors.primaryGreen.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Let\'s Play! 🎮',
                      style: ModernTypography.buttonMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getMoodGlowColor() {
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
}
