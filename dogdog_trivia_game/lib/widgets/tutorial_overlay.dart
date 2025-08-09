import 'package:flutter/material.dart';
import '../services/tutorial_service.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';

/// Tutorial overlay widget that displays guided tutorials
class TutorialOverlay extends StatefulWidget {
  final TutorialType tutorialType;
  final VoidCallback onComplete;
  final Widget child;

  const TutorialOverlay({
    super.key,
    required this.tutorialType,
    required this.onComplete,
    required this.child,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStep = 0;
  late TutorialData _tutorialData;
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _initializeTutorial();
  }

  Future<void> _initializeTutorial() async {
    await TutorialService().initialize();

    if (TutorialService().shouldShowTutorialFor(widget.tutorialType)) {
      _tutorialData = TutorialService().getTutorialData(widget.tutorialType);
      _pageController = PageController();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );

      _slideAnimation =
          Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutCubic,
            ),
          );

      setState(() {
        _showTutorial = true;
      });

      _animationController.forward();
      await HapticService().lightFeedback();
    }
  }

  @override
  void dispose() {
    if (_showTutorial) {
      _pageController.dispose();
      _animationController.dispose();
    }
    super.dispose();
  }

  Future<void> _nextStep() async {
    await AudioService().playButtonSound();
    await HapticService().lightFeedback();

    if (_currentStep < _tutorialData.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _completeTutorial();
    }
  }

  Future<void> _previousStep() async {
    await AudioService().playButtonSound();
    await HapticService().lightFeedback();

    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _skipTutorial() async {
    await AudioService().playButtonSound();
    await HapticService().selectionFeedback();
    await _completeTutorial();
  }

  Future<void> _completeTutorial() async {
    await TutorialService().markTutorialShown(widget.tutorialType);
    await _animationController.reverse();

    setState(() {
      _showTutorial = false;
    });

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showTutorial) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildTutorialCard(),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTutorialCard() {
    return Container(
      margin: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildHeader(), _buildContent(), _buildNavigation()],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF6B4EF2),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.school, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _tutorialData.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: _skipTutorial,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SizedBox(
      height: 280,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentStep = index;
          });
        },
        itemCount: _tutorialData.steps.length,
        itemBuilder: (context, index) {
          final step = _tutorialData.steps[index];
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B4EF2).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    step.icon,
                    size: 48,
                    color: const Color(0xFF6B4EF2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  step.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A5568),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Progress indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _tutorialData.steps.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentStep
                      ? const Color(0xFF6B4EF2)
                      : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Navigation buttons
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousStep,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFF6B4EF2)),
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(color: Color(0xFF6B4EF2)),
                    ),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4EF2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    _currentStep == _tutorialData.steps.length - 1
                        ? 'Get Started!'
                        : 'Next',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _skipTutorial,
            child: const Text(
              'Skip Tutorial',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
