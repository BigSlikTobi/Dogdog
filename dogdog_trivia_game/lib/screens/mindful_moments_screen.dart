import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/companion_controller.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../services/haptic_service.dart';

/// Mindful Moments screen with calming activities
/// 
/// Includes:
/// - Breathing Buddy: Guided breathing exercise with companion
/// - Cuddle Time: Gentle interaction mode
/// - Rest Mode: Wind-down before sleep
class MindfulMomentsScreen extends StatefulWidget {
  const MindfulMomentsScreen({super.key});

  @override
  State<MindfulMomentsScreen> createState() => _MindfulMomentsScreenState();
}

class _MindfulMomentsScreenState extends State<MindfulMomentsScreen> {
  String _selectedActivity = 'breathing';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2D3047), // Deep night blue
              Color(0xFF4A4E69), // Soft purple-gray
              Color(0xFF272838), // Dark blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildActivitySelector(),
              Expanded(
                child: _buildActivityContent(),
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
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Mindful Moments',
                      style: ModernTypography.headingMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'with ${companion?.name ?? "Buddy"}',
                      style: ModernTypography.bodySmall.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivitySelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ModernSpacing.lg),
      child: Row(
        children: [
          _buildActivityButton('breathing', '🌬️', 'Breathe'),
          const SizedBox(width: 12),
          _buildActivityButton('cuddle', '🤗', 'Cuddle'),
          const SizedBox(width: 12),
          _buildActivityButton('rest', '😴', 'Rest'),
        ],
      ),
    );
  }

  Widget _buildActivityButton(String id, String emoji, String label) {
    final isSelected = _selectedActivity == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedActivity = id),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: ModernSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(
                label,
                style: ModernTypography.bodySmall.copyWith(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityContent() {
    switch (_selectedActivity) {
      case 'breathing':
        return const _BreathingBuddyActivity();
      case 'cuddle':
        return const _CuddleTimeActivity();
      case 'rest':
        return const _RestModeActivity();
      default:
        return const _BreathingBuddyActivity();
    }
  }
}

/// Breathing Buddy - Guided breathing exercise
class _BreathingBuddyActivity extends StatefulWidget {
  const _BreathingBuddyActivity();

  @override
  State<_BreathingBuddyActivity> createState() => _BreathingBuddyActivityState();
}

class _BreathingBuddyActivityState extends State<_BreathingBuddyActivity>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _scaleAnimation;
  final HapticService _hapticService = HapticService();
  
  bool _isActive = false;
  String _instruction = 'Tap to begin';
  int _breathCount = 0;
  Timer? _instructionTimer;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );

    _breathController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _breathController.reverse();
      } else if (status == AnimationStatus.dismissed && _isActive) {
        _breathController.forward();
        setState(() => _breathCount++);
      }
    });

    _breathController.addListener(() {
      // Update instruction based on animation progress
      if (!_isActive) return;
      
      final progress = _breathController.value;
      String newInstruction;
      
      if (_breathController.status == AnimationStatus.forward) {
        if (progress < 0.5) {
          newInstruction = 'Breathe in...';
        } else {
          newInstruction = 'Hold...';
        }
      } else {
        if (progress > 0.5) {
          newInstruction = 'Hold...';
        } else {
          newInstruction = 'Breathe out...';
        }
      }
      
      if (newInstruction != _instruction) {
        setState(() => _instruction = newInstruction);
        _hapticService.buttonTap();
      }
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    _instructionTimer?.cancel();
    super.dispose();
  }

  void _toggleBreathing() {
    setState(() {
      _isActive = !_isActive;
      if (_isActive) {
        _breathController.forward();
        _instruction = 'Breathe in...';
      } else {
        _breathController.stop();
        _instruction = 'Tap to continue';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanionController>(
      builder: (context, controller, _) {
        final companion = controller.companion;
        return GestureDetector(
          onTap: _toggleBreathing,
          child: Container(
            padding: EdgeInsets.all(ModernSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Breathing circle with companion
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isActive ? _scaleAnimation.value : 1.0,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              ModernColors.primaryPurple.withValues(alpha: 0.3),
                              ModernColors.primaryBlue.withValues(alpha: 0.2),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ModernColors.primaryPurple.withValues(alpha: 0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            companion?.breed.emoji ?? '🐕',
                            style: const TextStyle(fontSize: 80),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                ModernSpacing.verticalSpaceXL,
                // Instruction
                Text(
                  _instruction,
                  style: ModernTypography.headingMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                ModernSpacing.verticalSpaceMD,
                // Breath counter
                if (_breathCount > 0)
                  Text(
                    '$_breathCount breaths',
                    style: ModernTypography.bodyMedium.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                ModernSpacing.verticalSpaceXL,
                // Tip
                Container(
                  padding: EdgeInsets.all(ModernSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        'Breathe with ${companion?.name ?? "your buddy"}',
                        style: ModernTypography.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Cuddle Time - Gentle petting interaction
class _CuddleTimeActivity extends StatefulWidget {
  const _CuddleTimeActivity();

  @override
  State<_CuddleTimeActivity> createState() => _CuddleTimeActivityState();
}

class _CuddleTimeActivityState extends State<_CuddleTimeActivity>
    with SingleTickerProviderStateMixin {
  final HapticService _hapticService = HapticService();
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  
  int _petCount = 0;
  String _reaction = '😊';
  final List<String> _reactions = ['😊', '😍', '🥰', '💖', '✨', '💫'];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _onPet() {
    _hapticService.cuddlePulse();
    _bounceController.forward().then((_) => _bounceController.reverse());
    
    setState(() {
      _petCount++;
      _reaction = _reactions[math.Random().nextInt(_reactions.length)];
    });

    // Give bond for cuddling
    if (_petCount % 10 == 0) {
      Provider.of<CompanionController>(context, listen: false)
          .onCorrectAnswer(); // Small bond boost
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanionController>(
      builder: (context, controller, _) {
        final companion = controller.companion;
        return GestureDetector(
          onTap: _onPet,
          onPanUpdate: (_) => _onPet(),
          child: Container(
            padding: EdgeInsets.all(ModernSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Companion with reaction
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow background
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            ModernColors.primaryPink.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Companion
                    ScaleTransition(
                      scale: _bounceAnimation,
                      child: Text(
                        companion?.breed.emoji ?? '🐕',
                        style: const TextStyle(fontSize: 100),
                      ),
                    ),
                    // Floating reaction
                    Positioned(
                      top: 20,
                      right: 40,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _reaction,
                          key: ValueKey(_petCount),
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  ],
                ),
                ModernSpacing.verticalSpaceXL,
                // Message
                Text(
                  _petCount == 0
                      ? 'Tap or swipe to pet ${companion?.name ?? "your buddy"}'
                      : '${companion?.name ?? "Buddy"} loves this!',
                  style: ModernTypography.headingSmall.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                ModernSpacing.verticalSpaceMD,
                // Pet counter
                if (_petCount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ModernSpacing.lg,
                      vertical: ModernSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: ModernColors.primaryPink.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💕', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          '$_petCount cuddles',
                          style: ModernTypography.bodyMedium.copyWith(
                            color: ModernColors.primaryPink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Rest Mode - Bedtime wind-down
class _RestModeActivity extends StatefulWidget {
  const _RestModeActivity();

  @override
  State<_RestModeActivity> createState() => _RestModeActivityState();
}

class _RestModeActivityState extends State<_RestModeActivity>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  bool _isSleeping = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanionController>(
      builder: (context, controller, _) {
        final companion = controller.companion;
        return GestureDetector(
          onTap: () => setState(() => _isSleeping = !_isSleeping),
          child: Container(
            padding: EdgeInsets.all(ModernSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Floating companion
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -_floatAnimation.value),
                      child: child,
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Stars/moon background
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF1A1A2E).withValues(alpha: 0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: const Stack(
                          children: [
                            Positioned(top: 20, left: 30, child: Text('✨', style: TextStyle(fontSize: 16))),
                            Positioned(top: 40, right: 40, child: Text('⭐', style: TextStyle(fontSize: 12))),
                            Positioned(bottom: 50, left: 50, child: Text('✨', style: TextStyle(fontSize: 14))),
                            Positioned(top: 60, left: 80, child: Text('🌙', style: TextStyle(fontSize: 24))),
                          ],
                        ),
                      ),
                      // Sleeping companion
                      Text(
                        _isSleeping ? '😴' : (companion?.breed.emoji ?? '🐕'),
                        style: const TextStyle(fontSize: 90),
                      ),
                      // Zzz animation
                      if (_isSleeping)
                        Positioned(
                          top: 40,
                          right: 60,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(seconds: 2),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: (math.sin(value * math.pi * 2) + 1) / 2,
                                child: const Text(
                                  'Zzz',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white60,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                ModernSpacing.verticalSpaceXL,
                // Message
                Text(
                  _isSleeping
                      ? '${companion?.name ?? "Buddy"} is sleeping peacefully'
                      : 'Tap to tuck ${companion?.name ?? "your buddy"} in',
                  style: ModernTypography.headingSmall.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                ModernSpacing.verticalSpaceLG,
                // Good night message
                if (_isSleeping)
                  Container(
                    padding: EdgeInsets.all(ModernSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '🌙 Good night!',
                          style: ModernTypography.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sweet dreams await...',
                          style: ModernTypography.bodySmall.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
