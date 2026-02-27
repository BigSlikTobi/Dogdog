import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../companion_engine/widgets/animated_dog_widget.dart';
import '../controllers/companion_controller.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';

/// Interactive companion widget — centerpiece of the home screen.
///
/// Renders the companion dog as a fully animated Flame skeleton via
/// [AnimatedDogWidget]. Gesture handling (tap / drag / long-press) is
/// delegated to [AnimatedDogWidget]'s built-in [DogInteractionController];
/// this widget is responsible only for the surrounding UI chrome (name,
/// mood text, bond hearts).
class InteractiveCompanionWidget extends StatelessWidget {
  final VoidCallback? onCuddle;
  final VoidCallback? onFeed;

  const InteractiveCompanionWidget({
    super.key,
    this.onCuddle,
    this.onFeed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanionController>(
      builder: (context, controller, _) {
        final companion = controller.companion;

        if (companion == null) {
          return _buildNoCompanion(context);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated dog skeleton via Flame engine
            AnimatedDogWidget(
              breed: companion.breed,
              size: 160,
              moodKey: companion.mood.animationKey,
            ),

            ModernSpacing.verticalSpaceSM,

            // Companion name
            Text(
              companion.name,
              style: ModernTypography.headingMedium.copyWith(
                color: ModernColors.textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            // Mood text
            Text(
              _getMoodText(companion.mood.name),
              style: ModernTypography.bodySmall.copyWith(
                color: ModernColors.textSecondary,
              ),
            ),

            ModernSpacing.verticalSpaceSM,

            // Bond hearts
            _buildBondHearts(companion.bondLevel),

            const SizedBox(height: 4),

            // Interaction hint
            Text(
              'Tap to cuddle! 🤗',
              style: ModernTypography.caption.copyWith(
                color: ModernColors.textLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoCompanion(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: ModernColors.surfaceLight,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🐾', style: TextStyle(fontSize: 60)),
          ),
        ),
        ModernSpacing.verticalSpaceMD,
        Text(
          'No companion yet',
          style: ModernTypography.bodyMedium.copyWith(
            color: ModernColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBondHearts(double bondLevel) {
    final filledHearts = (bondLevel * 5).floor();
    final hasHalfHeart = (bondLevel * 5) - filledHearts >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < filledHearts) {
          return const Text('❤️', style: TextStyle(fontSize: 20));
        } else if (i == filledHearts && hasHalfHeart) {
          return const Text('💗', style: TextStyle(fontSize: 20));
        } else {
          return Text('🤍',
              style: TextStyle(fontSize: 20, color: Colors.grey.shade300));
        }
      }),
    );
  }

  String _getMoodText(String mood) {
    return switch (mood) {
      'happy' => 'Feeling happy! 😊',
      'excited' => 'So excited! 🎉',
      'sleepy' => 'A bit sleepy... 😴',
      'curious' => 'Curious about something! 🧐',
      _ => 'Ready to play!',
    };
  }
}
