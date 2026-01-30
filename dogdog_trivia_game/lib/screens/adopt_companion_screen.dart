import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/companion_controller.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../models/companion_enums.dart';
import '../services/haptic_service.dart';
import '../widgets/gradient_button.dart';

/// Adoption onboarding screen for new players
/// 
/// Allows players to choose and name their companion dog,
/// creating an emotional connection from the start.
class AdoptCompanionScreen extends StatefulWidget {
  /// Callback when adoption is complete
  final VoidCallback? onAdoptionComplete;

  const AdoptCompanionScreen({
    super.key,
    this.onAdoptionComplete,
  });

  @override
  State<AdoptCompanionScreen> createState() => _AdoptCompanionScreenState();
}

class _AdoptCompanionScreenState extends State<AdoptCompanionScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  
  CompanionBreed? _selectedBreed;
  int _currentStep = 0; // 0: intro, 1: choose breed, 2: name, 3: welcome
  
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;

  final HapticService _hapticService = HapticService();

  // Available breeds for new players (puppy stage)
  List<CompanionBreed> get _availableBreeds => 
      CompanionBreed.availableAt(GrowthStage.puppy);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _fadeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _nextStep() {
    _hapticService.buttonTap();
    _fadeController.reset();
    setState(() {
      _currentStep++;
    });
    _fadeController.forward();
    if (_currentStep == 3) {
      _bounceController.forward();
    }
  }

  Future<void> _completeAdoption() async {
    if (_selectedBreed == null || _nameController.text.trim().isEmpty) return;

    final controller = Provider.of<CompanionController>(context, listen: false);
    
    await controller.adoptCompanion(
      name: _nameController.text.trim(),
      breed: _selectedBreed!,
    );

    _hapticService.welcomeBack();
    
    if (mounted) {
      widget.onAdoptionComplete?.call();
    }
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildCurrentStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildIntroStep();
      case 1:
        return _buildBreedSelectionStep();
      case 2:
        return _buildNamingStep();
      case 3:
        return _buildWelcomeStep();
      default:
        return _buildIntroStep();
    }
  }

  Widget _buildIntroStep() {
    return Padding(
      padding: EdgeInsets.all(ModernSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🐕',
            style: TextStyle(fontSize: 80),
          ),
          ModernSpacing.verticalSpaceXL,
          Text(
            'Welcome to DogDog!',
            style: ModernTypography.headingLarge.copyWith(
              color: ModernColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          ModernSpacing.verticalSpaceMD,
          Text(
            'Your journey begins with a new best friend.\nLet\'s find you a companion!',
            style: ModernTypography.bodyMedium.copyWith(
              color: ModernColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          ModernSpacing.verticalSpaceXL,
          ModernSpacing.verticalSpaceXL,
          GradientButton(
            text: 'Find My Companion',
            gradientColors: ModernColors.purpleGradient,
            icon: Icons.pets,
            onPressed: _nextStep,
          ),
        ],
      ),
    );
  }

  Widget _buildBreedSelectionStep() {
    return Padding(
      padding: EdgeInsets.all(ModernSpacing.lg),
      child: Column(
        children: [
          ModernSpacing.verticalSpaceLG,
          Text(
            'Choose Your Puppy',
            style: ModernTypography.headingMedium.copyWith(
              color: ModernColors.textPrimary,
            ),
          ),
          ModernSpacing.verticalSpaceSM,
          Text(
            'Each puppy is special. Who will be your companion?',
            style: ModernTypography.bodySmall.copyWith(
              color: ModernColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          ModernSpacing.verticalSpaceLG,
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _availableBreeds.length,
              itemBuilder: (context, index) {
                final breed = _availableBreeds[index];
                final isSelected = _selectedBreed == breed;
                
                return GestureDetector(
                  onTap: () {
                    _hapticService.buttonTap();
                    setState(() => _selectedBreed = breed);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected 
                            ? ModernColors.primaryPurple 
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? ModernColors.primaryPurple.withOpacity(0.3)
                              : Colors.black.withOpacity(0.08),
                          blurRadius: isSelected ? 16 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: ModernColors.surfaceLight,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              breed.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Text('🐕', style: TextStyle(fontSize: 40)),
                              ),
                            ),
                          ),
                        ),
                        ModernSpacing.verticalSpaceSM,
                        Text(
                          breed.displayName,
                          style: ModernTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: ModernColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isSelected) ...[
                          ModernSpacing.verticalSpaceXS,
                          Icon(
                            Icons.favorite,
                            color: ModernColors.primaryPurple,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ModernSpacing.verticalSpaceMD,
          GradientButton(
            text: 'This One!',
            gradientColors: ModernColors.purpleGradient,
            icon: Icons.arrow_forward,
            onPressed: _selectedBreed != null ? _nextStep : null,
          ),
          ModernSpacing.verticalSpaceMD,
        ],
      ),
    );
  }

  Widget _buildNamingStep() {
    return Padding(
      padding: EdgeInsets.all(ModernSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: ModernColors.surfaceLight,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ModernColors.primaryPurple.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                _selectedBreed!.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Text('🐕', style: TextStyle(fontSize: 60)),
                ),
              ),
            ),
          ),
          ModernSpacing.verticalSpaceXL,
          Text(
            'What\'s their name?',
            style: ModernTypography.headingMedium.copyWith(
              color: ModernColors.textPrimary,
            ),
          ),
          ModernSpacing.verticalSpaceSM,
          Text(
            'Give your ${_selectedBreed!.displayName} a special name',
            style: ModernTypography.bodySmall.copyWith(
              color: ModernColors.textSecondary,
            ),
          ),
          ModernSpacing.verticalSpaceLG,
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              textAlign: TextAlign.center,
              style: ModernTypography.headingSmall.copyWith(
                color: ModernColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Enter name...',
                hintStyle: ModernTypography.bodyMedium.copyWith(
                  color: ModernColors.textLight,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(ModernSpacing.lg),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {
                if (_nameController.text.trim().isNotEmpty) {
                  _nextStep();
                }
              },
            ),
          ),
          ModernSpacing.verticalSpaceXL,
          GradientButton(
            text: 'That\'s Perfect!',
            gradientColors: ModernColors.greenGradient,
            icon: Icons.check,
            onPressed: _nameController.text.trim().isNotEmpty ? _nextStep : null,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep() {
    final name = _nameController.text.trim();
    
    return Padding(
      padding: EdgeInsets.all(ModernSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _bounceAnimation,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: ModernColors.surfaceLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ModernColors.primaryGreen.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  _selectedBreed!.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text('🐕', style: TextStyle(fontSize: 80)),
                  ),
                ),
              ),
            ),
          ),
          ModernSpacing.verticalSpaceXL,
          const Text(
            '🎉',
            style: TextStyle(fontSize: 48),
          ),
          ModernSpacing.verticalSpaceMD,
          Text(
            'Welcome, $name!',
            style: ModernTypography.headingLarge.copyWith(
              color: ModernColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          ModernSpacing.verticalSpaceSM,
          Text(
            'You and $name are going to have\namazing adventures together!',
            style: ModernTypography.bodyMedium.copyWith(
              color: ModernColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          ModernSpacing.verticalSpaceXL,
          ModernSpacing.verticalSpaceLG,
          GradientButton(
            text: 'Start Our Journey!',
            gradientColors: ModernColors.greenGradient,
            icon: Icons.explore,
            onPressed: _completeAdoption,
          ),
        ],
      ),
    );
  }
}
