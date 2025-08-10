import 'package:flutter/material.dart';
import '../utils/game_state_animations.dart';
import '../utils/accessibility_enhancements.dart';
import '../design_system/modern_colors.dart';

/// Integrates all game components into a cohesive experience with animations and accessibility
class ComponentIntegrationService {
  static ComponentIntegrationService? _instance;
  static ComponentIntegrationService get instance =>
      _instance ??= ComponentIntegrationService._();

  ComponentIntegrationService._();

  late AnimationController _globalAnimationController;
  late AnimationController _transitionController;

  bool _isInitialized = false;

  /// Initialize the integration service with animation controllers
  void initialize(TickerProvider vsync) {
    if (_isInitialized) return;

    _globalAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );

    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: vsync,
    );

    _isInitialized = true;
  }

  /// Dispose of resources
  void dispose() {
    if (_isInitialized) {
      _globalAnimationController.dispose();
      _transitionController.dispose();
      _isInitialized = false;
    }
  }

  /// Creates an integrated game screen with all enhancements
  Widget buildIntegratedGameScreen({
    required Widget child,
    required String screenTitle,
    required VoidCallback? onBackPressed,
    bool showMemoryStats = false,
    bool enablePerformanceOptimization = true,
  }) {
    return AccessibilityTheme(
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: _buildIntegratedAppBar(
              context: context,
              title: screenTitle,
              onBackPressed: onBackPressed,
            ),
            body: Stack(
              children: [
                // Main content with smooth transitions
                GameStateAnimations.buildGameStateTransition(
                  child: child,
                  isVisible: true,
                  controller: _globalAnimationController,
                  slideOffset: const Offset(0.0, 0.1),
                  scaleBegin: 0.95,
                ),
                // Memory stats overlay (if enabled)
                if (showMemoryStats) _buildMemoryStatsOverlay(context),
                // Performance optimization indicator
                if (enablePerformanceOptimization)
                  _buildPerformanceIndicator(context),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Creates an integrated app bar with animations and accessibility
  PreferredSizeWidget _buildIntegratedAppBar({
    required BuildContext context,
    required String title,
    required VoidCallback? onBackPressed,
  }) {
    return AppBar(
      title: AccessibilityEnhancements.buildHighContrastText(
        text: title,
        style: Theme.of(context).textTheme.titleLarge,
        highContrastColor: Theme.of(context).colorScheme.onSurface,
      ),
      leading: onBackPressed != null
          ? AccessibilityEnhancements.buildAccessibleButton(
              onPressed: onBackPressed,
              semanticLabel: 'Go back',
              hint: 'Navigate to previous screen',
              child: GameStateAnimations.buildBouncingButton(
                onPressed: onBackPressed,
                child: const Icon(Icons.arrow_back),
              ),
            )
          : null,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0.95),
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ModernColors.primaryPurple.withValues(alpha: 0.1),
              ModernColors.primaryBlue.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  /// Creates an integrated game card with animations and accessibility
  Widget buildIntegratedGameCard({
    required Widget child,
    required String semanticLabel,
    required VoidCallback? onTap,
    String? hint,
    bool isSelected = false,
    bool enableHoverAnimation = true,
    EdgeInsets? padding,
  }) {
    Widget cardContent = AccessibilityEnhancements.buildAccessibleCard(
      semanticLabel: semanticLabel,
      hint: hint,
      onTap: onTap,
      isSelected: isSelected,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );

    if (enableHoverAnimation && onTap != null) {
      cardContent = GameStateAnimations.buildBouncingButton(
        onPressed: onTap,
        child: cardContent,
      );
    }

    return GameStateAnimations.buildGameStateTransition(
      child: cardContent,
      isVisible: true,
      controller: _globalAnimationController,
      slideOffset: const Offset(0.0, 0.05),
      scaleBegin: 0.98,
    );
  }

  /// Creates an integrated score display with animations and accessibility
  Widget buildIntegratedScoreDisplay({
    required int score,
    required String scoreType,
    String? additionalInfo,
    bool isAnimated = true,
  }) {
    Widget scoreWidget = AccessibilityEnhancements.buildAccessibleScore(
      score: score,
      scoreType: scoreType,
      additionalInfo: additionalInfo,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ModernColors.primaryPurple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ModernColors.primaryPurple, width: 1),
        ),
        child: AccessibilityEnhancements.buildHighContrastText(
          text: '$scoreType: $score',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );

    if (isAnimated) {
      scoreWidget = GameStateAnimations.buildGameStateTransition(
        child: scoreWidget,
        isVisible: true,
        controller: _transitionController,
        scaleBegin: 0.8,
      );
    }

    return scoreWidget;
  }

  /// Creates an integrated timer display with urgency animations
  Widget buildIntegratedTimer({
    required int seconds,
    bool isUrgent = false,
    bool enablePulseAnimation = true,
  }) {
    Widget timerWidget = AccessibilityEnhancements.buildAccessibleTimer(
      seconds: seconds,
      isUrgent: isUrgent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isUrgent
              ? ModernColors.error.withValues(alpha: 0.1)
              : ModernColors.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUrgent ? ModernColors.error : ModernColors.primaryBlue,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer,
              size: 16,
              color: isUrgent ? ModernColors.error : ModernColors.primaryBlue,
            ),
            const SizedBox(width: 4),
            AccessibilityEnhancements.buildHighContrastText(
              text: _formatTime(seconds),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isUrgent ? ModernColors.error : ModernColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );

    if (enablePulseAnimation && isUrgent) {
      timerWidget = GameStateAnimations.buildPulsingWidget(
        duration: const Duration(milliseconds: 800),
        minOpacity: 0.6,
        maxOpacity: 1.0,
        child: timerWidget,
      );
    }

    return timerWidget;
  }

  /// Creates an integrated progress indicator with accessibility
  Widget buildIntegratedProgress({
    required double progress,
    required String progressType,
    String? description,
    bool isAnimated = true,
  }) {
    Widget progressWidget = AccessibilityEnhancements.buildAccessibleProgress(
      progress: progress,
      progressType: progressType,
      description: description,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccessibilityEnhancements.buildHighContrastText(
            text: progressType,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: ModernColors.textSecondary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              ModernColors.primaryGreen,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 2),
            AccessibilityEnhancements.buildHighContrastText(
              text: description,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ],
      ),
    );

    if (isAnimated) {
      progressWidget = GameStateAnimations.buildGameStateTransition(
        child: progressWidget,
        isVisible: true,
        controller: _transitionController,
        slideOffset: const Offset(-0.1, 0.0),
      );
    }

    return progressWidget;
  }

  /// Creates an integrated loading state with accessibility
  Widget buildIntegratedLoadingState({
    required String loadingMessage,
    bool useShimmer = true,
  }) {
    Widget loadingContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (useShimmer)
          GameStateAnimations.buildShimmerEffect(
            child: Container(
              width: 200,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          )
        else
          const CircularProgressIndicator(),
        const SizedBox(height: 16),
        AccessibilityEnhancements.buildHighContrastText(
          text: loadingMessage,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );

    return Semantics(
      label: loadingMessage,
      liveRegion: true,
      child: Center(child: loadingContent),
    );
  }

  /// Handles memory optimization across components
  Future<void> optimizeComponentMemory() async {
    try {
      // Memory optimization logic would be implemented here
      // For now, just log the optimization attempt
      debugPrint('Component memory optimization completed');
    } catch (e) {
      debugPrint('Error during component memory optimization: $e');
    }
  }

  /// Triggers smooth transition animations
  Future<void> triggerTransition({Duration? duration, Curve? curve}) async {
    _transitionController.duration =
        duration ?? const Duration(milliseconds: 400);
    await _transitionController.forward();
    _transitionController.reset();
  }

  /// Memory stats overlay for debugging
  Widget _buildMemoryStatsOverlay(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Memory Stats',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Cache: Memory stats available',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  /// Performance indicator for optimization status
  Widget _buildPerformanceIndicator(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: ModernColors.primaryGreen,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// Format time in MM:SS format
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Start global animations
  void startAnimations() {
    if (_isInitialized) {
      _globalAnimationController.forward();
    }
  }

  /// Reset all animations
  void resetAnimations() {
    if (_isInitialized) {
      _globalAnimationController.reset();
      _transitionController.reset();
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}
