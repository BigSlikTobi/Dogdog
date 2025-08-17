import 'package:flutter/material.dart';
import '../../design_system/modern_colors.dart';
import '../../design_system/modern_typography.dart';
import '../../design_system/modern_spacing.dart';
import '../../design_system/modern_shadows.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/accessibility.dart';
import '../../utils/accessibility_enhancements.dart' hide AccessibilityTheme;
import '../../services/audio_service.dart';
import 'package:flutter/semantics.dart';

/// Widget that displays a countdown timer with circular progress indicator and color changes
class CountdownTimerDisplay extends StatefulWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isActive;
  final VoidCallback? onTimeExpired;
  final Color? primaryColor;
  final Color? warningColor;
  final Color? dangerColor;

  const CountdownTimerDisplay({
    super.key,
    required this.remainingSeconds,
    this.totalSeconds = 10,
    this.isActive = false,
    this.onTimeExpired,
    this.primaryColor,
    this.warningColor,
    this.dangerColor,
  });

  @override
  State<CountdownTimerDisplay> createState() => _CountdownTimerDisplayState();
}

class _CountdownTimerDisplayState extends State<CountdownTimerDisplay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _warningController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _warningAnimation;

  int _previousSeconds = 0;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _warningController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _warningAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _warningController, curve: Curves.elasticOut),
    );

    _previousSeconds = widget.remainingSeconds;
  }

  @override
  void didUpdateWidget(CountdownTimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger pulse animation when seconds change
    if (widget.remainingSeconds != _previousSeconds) {
      _pulseController.forward().then((_) {
        _pulseController.reverse();
      });

      // Trigger warning animation for last 3 seconds
      if (widget.remainingSeconds <= 3 && widget.remainingSeconds > 0) {
        _warningController.forward().then((_) {
          _warningController.reverse();
        });

        // Provide audio cue for accessibility
        _playTimerWarningAudio();

        // Provide haptic feedback
        AccessibilityEnhancements.provideHapticFeedback(
          GameHapticType.incorrect,
        );
      }

      // Announce time updates to screen reader for critical moments
      if (mounted &&
          (widget.remainingSeconds <= 5 || widget.remainingSeconds % 10 == 0)) {
        _announceTimeUpdate();
      }

      _previousSeconds = widget.remainingSeconds;
    }

    // Handle time expiration
    if (widget.remainingSeconds <= 0 && oldWidget.remainingSeconds > 0) {
      widget.onTimeExpired?.call();
      _announceTimeExpired();
    }
  }

  void _playTimerWarningAudio() async {
    try {
      await AudioService().playTimerWarningSound();
    } catch (e) {
      // Silently fail if audio service is not available
    }
  }

  void _announceTimeUpdate() {
    if (!mounted) return;

    final timeLabel = AccessibilityEnhancements.getGameElementDescription(
      elementType: AppLocalizations.of(context).breedAdventure_timer,
      state: widget.remainingSeconds <= 3
          ? AppLocalizations.of(context).breedAdventure_timeRunningOut
          : null,
      value: AppLocalizations.of(
        context,
      ).breedAdventure_secondsRemaining(widget.remainingSeconds),
    );

    AccessibilityUtils.announceToScreenReader(
      context,
      timeLabel,
      assertiveness: widget.remainingSeconds <= 3
          ? Assertiveness.assertive
          : Assertiveness.polite,
    );
  }

  void _announceTimeExpired() {
    if (!mounted) return;

    AccessibilityUtils.announceToScreenReader(
      context,
      AppLocalizations.of(context).breedAdventure_timeExpired,
      assertiveness: Assertiveness.assertive,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _warningController.dispose();
    super.dispose();
  }

  Color _getTimerColor() {
    final progress = widget.remainingSeconds / widget.totalSeconds;

    if (progress <= 0.2) {
      return widget.dangerColor ?? ModernColors.error;
    } else if (progress <= 0.5) {
      return widget.warningColor ?? ModernColors.warning;
    } else {
      return widget.primaryColor ?? ModernColors.primaryBlue;
    }
  }

  Color _getBackgroundColor() {
    return _getTimerColor().withValues(alpha: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalSeconds > 0
        ? (widget.remainingSeconds / widget.totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    final isHighContrast = AccessibilityUtils.isHighContrastEnabled(context);
    final colorScheme = AccessibilityUtils.getHighContrastColors(context);

    // Create comprehensive semantic label
    final timerLabel = AccessibilityEnhancements.buildAccessibleTimer(
      child: Container(), // Placeholder, we'll use the label
      seconds: widget.remainingSeconds,
      isUrgent: widget.remainingSeconds <= 3,
    );

    return AccessibilityTheme(
      child: AccessibilityEnhancements.buildReducedMotionWrapper(
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _warningAnimation]),
          builder: (context, child) {
            double scale = _pulseAnimation.value;
            if (widget.remainingSeconds <= 3) {
              scale *= _warningAnimation.value;
            }

            return Transform.scale(
              scale: scale,
              child: _buildAccessibleTimer(
                context,
                progress,
                isHighContrast,
                colorScheme,
              ),
            );
          },
        ),
        reducedMotionChild: _buildAccessibleTimer(
          context,
          progress,
          isHighContrast,
          colorScheme,
        ),
      ),
    );
  }

  Widget _buildAccessibleTimer(
    BuildContext context,
    double progress,
    bool isHighContrast,
    ColorScheme colorScheme,
  ) {
    final timerColor = isHighContrast ? colorScheme.primary : _getTimerColor();
    final backgroundColor = isHighContrast
        ? colorScheme.surface
        : _getBackgroundColor();

    return Semantics(
      label: AccessibilityUtils.createGameElementLabel(
        element: AppLocalizations.of(context).breedAdventure_countdownTimer,
        value: AppLocalizations.of(
          context,
        ).breedAdventure_secondsRemaining(widget.remainingSeconds),
        context: widget.remainingSeconds <= 3
            ? AppLocalizations.of(context).breedAdventure_timeRunningOut
            : null,
      ),
      value: widget.remainingSeconds.toString(),
      liveRegion: true,
      child: Container(
        width: 88,
        height: 88,
        decoration: isHighContrast
            ? AccessibilityUtils.getAccessibleCircularDecoration(context)
            : BoxDecoration(
                gradient: ModernColors.createRadialGradient(
                  [backgroundColor, backgroundColor.withValues(alpha: 0.8)],
                  center: Alignment.center,
                  radius: 0.8,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  // Enhanced glow effect
                  ...ModernShadows.glow(
                    timerColor,
                    opacity: widget.remainingSeconds <= 3 ? 0.6 : 0.3,
                    blur: widget.remainingSeconds <= 3 ? 16 : 12,
                  ),
                  // Depth shadow
                  ...ModernShadows.large,
                ],
                border: Border.all(
                  color: timerColor.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Enhanced circular progress indicator with accessibility
            Semantics(
              label: AppLocalizations.of(context).breedAdventure_timerProgress,
              value: '${(progress * 100).round()}%',
              child: SizedBox(
                width: 76,
                height: 76,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: isHighContrast
                      ? colorScheme.onSurface.withValues(alpha: 0.3)
                      : ModernColors.surfaceDark.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
            ),

            // Enhanced timer text with accessibility
            Semantics(
              label: AppLocalizations.of(context).breedAdventure_timeDisplay,
              readOnly: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AccessibilityEnhancements.buildHighContrastText(
                    text: '${widget.remainingSeconds}',
                    style: AccessibilityUtils.getAccessibleTextStyle(
                      context,
                      ModernTypography.displayMedium.copyWith(
                        color: timerColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        letterSpacing: -1,
                        shadows: isHighContrast
                            ? null
                            : [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                      ),
                    ),
                  ),
                  AccessibilityEnhancements.buildHighContrastText(
                    text: AppLocalizations.of(context).breedAdventure_seconds,
                    style: AccessibilityUtils.getAccessibleTextStyle(
                      context,
                      ModernTypography.caption.copyWith(
                        color: timerColor.withValues(alpha: 0.8),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Enhanced warning indicator with accessibility
            if (widget.remainingSeconds <= 3 && widget.remainingSeconds > 0)
              Semantics(
                label: AppLocalizations.of(
                  context,
                ).breedAdventure_urgentWarning,
                liveRegion: true,
                child: Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isHighContrast
                            ? Colors.red
                            : ModernColors.error.withValues(
                                alpha: 0.4 + (_warningAnimation.value * 0.4),
                              ),
                        width: isHighContrast ? 4 : 3,
                      ),
                    ),
                  ),
                ),
              ),

            // Critical state overlay with accessibility
            if (widget.remainingSeconds <= 1 && widget.remainingSeconds > 0)
              Semantics(
                label: AppLocalizations.of(context).breedAdventure_criticalTime,
                liveRegion: true,
                child: Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isHighContrast
                          ? null
                          : ModernColors.createRadialGradient([
                              ModernColors.error.withValues(alpha: 0.1),
                              ModernColors.error.withValues(alpha: 0.05),
                            ]),
                      color: isHighContrast
                          ? Colors.red.withValues(alpha: 0.2)
                          : null,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A compact version of the timer for smaller spaces
class CompactCountdownTimer extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isActive;

  const CompactCountdownTimer({
    super.key,
    required this.remainingSeconds,
    this.totalSeconds = 10,
    this.isActive = false,
  });

  Color _getTimerColor() {
    final progress = remainingSeconds / totalSeconds;

    if (progress <= 0.2) {
      return ModernColors.error;
    } else if (progress <= 0.5) {
      return ModernColors.warning;
    } else {
      return ModernColors.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0
        ? (remainingSeconds / totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: ModernSpacing.paddingMD,
      decoration: BoxDecoration(
        gradient: ModernColors.createLinearGradient([
          _getTimerColor().withValues(alpha: 0.1),
          _getTimerColor().withValues(alpha: 0.05),
        ]),
        borderRadius: ModernSpacing.borderRadiusMedium,
        border: Border.all(
          color: _getTimerColor().withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: ModernShadows.small,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Enhanced mini progress indicator
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              backgroundColor: ModernColors.surfaceDark.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(_getTimerColor()),
              strokeCap: StrokeCap.round,
            ),
          ),

          ModernSpacing.horizontalSpaceMD,

          // Enhanced timer text
          Text(
            '$remainingSeconds${AppLocalizations.of(context).breedAdventure_secondsShort}',
            style: ModernTypography.bodyMedium.copyWith(
              color: _getTimerColor(),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// A linear progress version of the timer
class LinearCountdownTimer extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isActive;
  final double height;

  const LinearCountdownTimer({
    super.key,
    required this.remainingSeconds,
    this.totalSeconds = 10,
    this.isActive = false,
    this.height = 8.0,
  });

  Color _getTimerColor() {
    final progress = remainingSeconds / totalSeconds;

    if (progress <= 0.2) {
      return ModernColors.error;
    } else if (progress <= 0.5) {
      return ModernColors.warning;
    } else {
      return ModernColors.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0
        ? (remainingSeconds / totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced timer text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).breedAdventure_timeRemaining,
              style: ModernTypography.caption.copyWith(
                color: ModernColors.textSecondary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ModernSpacing.sm,
                vertical: ModernSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _getTimerColor().withValues(alpha: 0.1),
                borderRadius: ModernSpacing.borderRadiusSmall,
              ),
              child: Text(
                '$remainingSeconds${AppLocalizations.of(context).breedAdventure_secondsShort}',
                style: ModernTypography.caption.copyWith(
                  color: _getTimerColor(),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),

        ModernSpacing.verticalSpaceSM,

        // Enhanced progress bar
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: ModernColors.createLinearGradient([
              ModernColors.surfaceLight,
              ModernColors.surfaceMedium,
            ]),
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: MediaQuery.of(context).size.width * progress,
            decoration: BoxDecoration(
              gradient: ModernColors.createLinearGradient([
                _getTimerColor(),
                _getTimerColor().withValues(alpha: 0.8),
              ]),
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: [
                BoxShadow(
                  color: _getTimerColor().withValues(alpha: 0.3),
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
