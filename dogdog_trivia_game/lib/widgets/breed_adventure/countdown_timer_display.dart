import 'package:flutter/material.dart';
import '../../design_system/modern_colors.dart';
import '../../design_system/modern_typography.dart';
import '../../design_system/modern_spacing.dart';
import '../../design_system/modern_shadows.dart';

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
      }

      _previousSeconds = widget.remainingSeconds;
    }

    // Handle time expiration
    if (widget.remainingSeconds <= 0 && oldWidget.remainingSeconds > 0) {
      widget.onTimeExpired?.call();
    }
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

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _warningAnimation]),
      builder: (context, child) {
        double scale = _pulseAnimation.value;
        if (widget.remainingSeconds <= 3) {
          scale *= _warningAnimation.value;
        }

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getTimerColor().withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
                ...ModernShadows.medium,
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular progress indicator
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: ModernColors.surfaceDark.withValues(
                      alpha: 0.3,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(_getTimerColor()),
                    strokeCap: StrokeCap.round,
                  ),
                ),

                // Timer text
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.remainingSeconds}',
                      style: ModernTypography.headingMedium.copyWith(
                        color: _getTimerColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      'sec',
                      style: ModernTypography.caption.copyWith(
                        color: _getTimerColor().withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),

                // Warning indicator for last 3 seconds
                if (widget.remainingSeconds <= 3 && widget.remainingSeconds > 0)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ModernColors.error.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
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
      padding: ModernSpacing.paddingSM,
      decoration: BoxDecoration(
        color: _getTimerColor().withValues(alpha: 0.1),
        borderRadius: ModernSpacing.borderRadiusMedium,
        border: Border.all(
          color: _getTimerColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini progress indicator
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
              backgroundColor: ModernColors.surfaceDark.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(_getTimerColor()),
            ),
          ),

          ModernSpacing.horizontalSpaceSM,

          // Timer text
          Text(
            '${remainingSeconds}s',
            style: ModernTypography.bodyMedium.copyWith(
              color: _getTimerColor(),
              fontWeight: FontWeight.w600,
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
        // Timer text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Time Remaining',
              style: ModernTypography.caption.copyWith(
                color: ModernColors.textSecondary,
              ),
            ),
            Text(
              '${remainingSeconds}s',
              style: ModernTypography.caption.copyWith(
                color: _getTimerColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        ModernSpacing.verticalSpaceXS,

        // Progress bar
        Container(
          height: height,
          decoration: BoxDecoration(
            color: ModernColors.surfaceLight,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: _getTimerColor(),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
