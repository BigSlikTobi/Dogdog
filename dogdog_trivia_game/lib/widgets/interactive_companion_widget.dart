import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/companion_controller.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../services/haptic_service.dart';

/// Interactive companion widget with Duolingo-style bounce animations
/// This is the centerpiece of the home screen
class InteractiveCompanionWidget extends StatefulWidget {
  final VoidCallback? onCuddle;
  final VoidCallback? onFeed;
  
  const InteractiveCompanionWidget({
    super.key,
    this.onCuddle,
    this.onFeed,
  });

  @override
  State<InteractiveCompanionWidget> createState() => _InteractiveCompanionWidgetState();
}

class _InteractiveCompanionWidgetState extends State<InteractiveCompanionWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _heartController;
  late AnimationController _wiggleController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _heartAnimation;
  late Animation<double> _wiggleAnimation;
  
  final HapticService _hapticService = HapticService();
  final List<_HeartParticle> _hearts = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Duolingo-style bounce animation
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.elasticOut,
      ),
    );

    // Heart float-up animation
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _heartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heartController,
        curve: Curves.easeOut,
      ),
    );

    // Continuous happy wiggle
    _wiggleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _wiggleAnimation = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(
        parent: _wiggleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _heartController.dispose();
    _wiggleController.dispose();
    super.dispose();
  }

  void _onTap() {
    // Trigger bounce
    _bounceController.forward(from: 0.0);
    
    // Create heart particles
    _createHearts();
    
    // Haptic feedback
    _hapticService.cuddlePulse();
    
    // Trigger callback
    widget.onCuddle?.call();
    
    // Add bond via controller
    final controller = context.read<CompanionController>();
    controller.addBondFromInteraction(0.005); // Small bond gain
  }

  void _createHearts() {
    setState(() {
      _hearts.clear();
      for (int i = 0; i < 5; i++) {
        _hearts.add(_HeartParticle(
          offsetX: (_random.nextDouble() - 0.5) * 100,
          delay: _random.nextDouble() * 0.3,
        ));
      }
    });
    _heartController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanionController>(
      builder: (context, controller, _) {
        final companion = controller.companion;
        
        if (companion == null) {
          return _buildNoCompanion();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Interactive companion with hearts
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Floating hearts
                  ...List.generate(_hearts.length, (i) {
                    final heart = _hearts[i];
                    return AnimatedBuilder(
                      animation: _heartAnimation,
                      builder: (context, child) {
                        final progress = (_heartAnimation.value - heart.delay).clamp(0.0, 1.0);
                        if (progress <= 0) return const SizedBox.shrink();
                        
                        return Positioned(
                          bottom: 80 + (progress * 120),
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Transform.translate(
                              offset: Offset(heart.offsetX * progress, 0),
                              child: Opacity(
                                opacity: (1 - progress).clamp(0.0, 1.0),
                                child: Text(
                                  '❤️',
                                  style: TextStyle(fontSize: 24 + (progress * 8)),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  
                  // Main companion avatar
                  GestureDetector(
                    onTap: _onTap,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_bounceController, _wiggleController]),
                      builder: (context, child) {
                        final bounceScale = 1.0 + 
                            (0.15 * (1 - _bounceController.value).clamp(0, 1) * 
                            sin(_bounceController.value * pi * 3));
                        
                        return Transform.rotate(
                          angle: _wiggleAnimation.value,
                          child: Transform.scale(
                            scale: bounceScale,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ModernColors.primaryPurple.withValues(alpha: 0.15),
                              ModernColors.primaryBlue.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: ModernColors.primaryPurple.withValues(alpha: 0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            companion.breed.emoji,
                            style: const TextStyle(fontSize: 80),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
            
            // Tap hint
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

  Widget _buildNoCompanion() {
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
          return Text('🤍', style: TextStyle(fontSize: 20, color: Colors.grey.shade300));
        }
      }),
    );
  }

  String _getMoodText(String mood) {
    switch (mood) {
      case 'happy': return 'Feeling happy! 😊';
      case 'excited': return 'So excited! 🎉';
      case 'sleepy': return 'A bit sleepy... 😴';
      case 'curious': return 'Curious about something! 🧐';
      default: return 'Ready to play!';
    }
  }
}

class _HeartParticle {
  final double offsetX;
  final double delay;
  
  _HeartParticle({required this.offsetX, required this.delay});
}
