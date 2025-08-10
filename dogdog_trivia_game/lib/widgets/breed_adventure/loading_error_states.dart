import 'package:flutter/material.dart';
import '../../design_system/modern_colors.dart';
import '../../design_system/modern_typography.dart';
import '../../design_system/modern_spacing.dart';

import '../../widgets/loading_animation.dart';
import '../../widgets/animated_button.dart';

/// Widget for loading states during image loading scenarios
class BreedAdventureLoadingState extends StatelessWidget {
  final String? message;
  final bool showProgress;
  final double? progress;

  const BreedAdventureLoadingState({
    super.key,
    this.message,
    this.showProgress = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ModernSpacing.paddingXL,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Loading animation
          LoadingAnimation(
            size: 80,
            color: ModernColors.primaryPurple,
            message: message ?? 'Loading breed challenge...',
          ),

          if (showProgress && progress != null) ...[
            ModernSpacing.verticalSpaceLG,

            // Progress bar
            Container(
              width: 200,
              height: 6,
              decoration: BoxDecoration(
                color: ModernColors.surfaceLight,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress!.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: ModernColors.primaryPurple,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

            ModernSpacing.verticalSpaceSM,

            Text(
              '${(progress! * 100).toInt()}%',
              style: ModernTypography.bodySmall.copyWith(
                color: ModernColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget for error states with retry options
class BreedAdventureErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onSkip;
  final IconData? icon;
  final bool showRetryButton;
  final bool showSkipButton;

  const BreedAdventureErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.onSkip,
    this.icon,
    this.showRetryButton = true,
    this.showSkipButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ModernSpacing.paddingXL,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ModernColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.error_outline_rounded,
              size: 40,
              color: ModernColors.error,
            ),
          ),

          ModernSpacing.verticalSpaceLG,

          // Error title
          Text(
            title,
            style: ModernTypography.headingMedium.copyWith(
              color: ModernColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          ModernSpacing.verticalSpaceMD,

          // Error message
          Text(
            message,
            style: ModernTypography.bodyMedium.copyWith(
              color: ModernColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          ModernSpacing.verticalSpaceXL,

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showRetryButton && onRetry != null) ...[
                PrimaryAnimatedButton(
                  onPressed: onRetry,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: ModernColors.textOnDark,
                      ),
                      ModernSpacing.horizontalSpaceSM,
                      Text('Retry', style: ModernTypography.buttonMedium),
                    ],
                  ),
                ),
              ],

              if (showRetryButton && showSkipButton && onSkip != null)
                ModernSpacing.horizontalSpaceLG,

              if (showSkipButton && onSkip != null) ...[
                SecondaryAnimatedButton(
                  onPressed: onSkip,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.skip_next_rounded,
                        size: 18,
                        color: ModernColors.textOnDark,
                      ),
                      ModernSpacing.horizontalSpaceSM,
                      Text('Skip', style: ModernTypography.buttonMedium),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget for network connectivity issues
class NetworkErrorState extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onOfflineMode;

  const NetworkErrorState({super.key, this.onRetry, this.onOfflineMode});

  @override
  Widget build(BuildContext context) {
    return BreedAdventureErrorState(
      title: 'Connection Problem',
      message:
          'Unable to load images. Please check your internet connection and try again.',
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
      onSkip: onOfflineMode,
      showSkipButton: onOfflineMode != null,
    );
  }
}

/// Widget for image loading failures
class ImageLoadErrorState extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onSkip;

  const ImageLoadErrorState({super.key, this.onRetry, this.onSkip});

  @override
  Widget build(BuildContext context) {
    return BreedAdventureErrorState(
      title: 'Image Load Failed',
      message:
          'The breed images could not be loaded. This might be a temporary issue.',
      icon: Icons.image_not_supported_rounded,
      onRetry: onRetry,
      onSkip: onSkip,
      showSkipButton: true,
    );
  }
}

/// Widget for empty breed pool
class EmptyBreedPoolState extends StatelessWidget {
  final String phaseName;
  final VoidCallback? onNextPhase;
  final VoidCallback? onRestart;

  const EmptyBreedPoolState({
    super.key,
    required this.phaseName,
    this.onNextPhase,
    this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ModernSpacing.paddingXL,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ModernColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 40,
              color: ModernColors.success,
            ),
          ),

          ModernSpacing.verticalSpaceLG,

          // Completion message
          Text(
            'Phase Complete!',
            style: ModernTypography.headingMedium.copyWith(
              color: ModernColors.success,
            ),
            textAlign: TextAlign.center,
          ),

          ModernSpacing.verticalSpaceMD,

          Text(
            'You\'ve completed all breeds in the $phaseName phase. Great job!',
            style: ModernTypography.bodyMedium.copyWith(
              color: ModernColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          ModernSpacing.verticalSpaceXL,

          // Action buttons
          Column(
            children: [
              if (onNextPhase != null) ...[
                PrimaryAnimatedButton(
                  onPressed: onNextPhase,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: ModernColors.textOnDark,
                      ),
                      ModernSpacing.horizontalSpaceSM,
                      Text('Next Phase', style: ModernTypography.buttonMedium),
                    ],
                  ),
                ),

                ModernSpacing.verticalSpaceMD,
              ],

              if (onRestart != null) ...[
                OutlineAnimatedButton(
                  onPressed: onRestart,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.restart_alt_rounded,
                        size: 18,
                        color: ModernColors.primaryPurple,
                      ),
                      ModernSpacing.horizontalSpaceSM,
                      Text(
                        'Restart Game',
                        style: ModernTypography.buttonMedium.copyWith(
                          color: ModernColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget for game initialization
class GameInitializingState extends StatelessWidget {
  const GameInitializingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const BreedAdventureLoadingState(
      message: 'Preparing your breed adventure...',
    );
  }
}

/// Widget for image preloading
class ImagePreloadingState extends StatelessWidget {
  final double progress;

  const ImagePreloadingState({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return BreedAdventureLoadingState(
      message: 'Loading breed images...',
      showProgress: true,
      progress: progress,
    );
  }
}

/// Widget for general loading with custom message
class CustomLoadingState extends StatelessWidget {
  final String message;
  final Widget? customIcon;

  const CustomLoadingState({super.key, required this.message, this.customIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ModernSpacing.paddingXL,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          customIcon ??
              LoadingAnimation(size: 60, color: ModernColors.primaryPurple),

          ModernSpacing.verticalSpaceLG,

          Text(
            message,
            style: ModernTypography.bodyMedium.copyWith(
              color: ModernColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Comprehensive error recovery widget for Task 11
class BreedAdventureErrorRecovery extends StatelessWidget {
  final String errorType;
  final String errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onSkip;
  final VoidCallback? onRestart;
  final VoidCallback? onGoHome;
  final bool isInRecoveryMode;
  final int consecutiveFailures;

  const BreedAdventureErrorRecovery({
    super.key,
    required this.errorType,
    required this.errorMessage,
    this.onRetry,
    this.onSkip,
    this.onRestart,
    this.onGoHome,
    this.isInRecoveryMode = false,
    this.consecutiveFailures = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ModernSpacing.paddingXL,
      decoration: BoxDecoration(
        color: ModernColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon and title
          _buildErrorHeader(context),

          ModernSpacing.verticalSpaceLG,

          // Error message
          _buildErrorMessage(context),

          if (isInRecoveryMode) ...[
            ModernSpacing.verticalSpaceMD,
            _buildRecoveryModeInfo(context),
          ],

          ModernSpacing.verticalSpaceXL,

          // Action buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildErrorHeader(BuildContext context) {
    IconData iconData;
    Color iconColor;
    String title;

    switch (errorType.toLowerCase()) {
      case 'network':
        iconData = Icons.wifi_off;
        iconColor = ModernColors.warning;
        title = 'Connection Problem';
        break;
      case 'image':
        iconData = Icons.image_not_supported;
        iconColor = ModernColors.error;
        title = 'Image Load Failed';
        break;
      case 'data':
        iconData = Icons.error_outline;
        iconColor = ModernColors.error;
        title = 'Data Error';
        break;
      default:
        iconData = Icons.warning;
        iconColor = ModernColors.warning;
        title = 'Something Went Wrong';
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, size: 48, color: iconColor),
        ),

        ModernSpacing.verticalSpaceMD,

        Text(
          title,
          style: ModernTypography.headingMedium.copyWith(
            color: ModernColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Text(
      errorMessage,
      style: ModernTypography.bodyMedium.copyWith(
        color: ModernColors.textSecondary,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRecoveryModeInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ModernColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ModernColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.healing, color: ModernColors.warning, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              consecutiveFailures > 0
                  ? 'Recovery mode active after $consecutiveFailures failures. Using fallback content.'
                  : 'Recovery mode active. Using offline content where possible.',
              style: ModernTypography.bodySmall.copyWith(
                color: ModernColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final buttons = <Widget>[];

    // Primary action (Retry)
    if (onRetry != null) {
      buttons.add(
        Expanded(
          child: AnimatedButton(
            onPressed: onRetry!,
            backgroundColor: ModernColors.primaryBlue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, color: ModernColors.textOnDark, size: 16),
                const SizedBox(width: 8),
                Text(
                  isInRecoveryMode ? 'Try Again' : 'Retry',
                  style: ModernTypography.buttonMedium.copyWith(
                    color: ModernColors.textOnDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Skip current challenge
    if (onSkip != null && buttons.isNotEmpty) {
      buttons.add(const SizedBox(width: 12));
    }

    if (onSkip != null) {
      buttons.add(
        Expanded(
          child: AnimatedButton(
            onPressed: onSkip!,
            backgroundColor: ModernColors.surfaceMedium,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.skip_next,
                  color: ModernColors.textPrimary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Skip',
                  style: ModernTypography.buttonMedium.copyWith(
                    color: ModernColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Secondary actions row
    final secondaryButtons = <Widget>[];

    if (onRestart != null) {
      secondaryButtons.add(
        Expanded(
          child: AnimatedButton(
            onPressed: onRestart!,
            backgroundColor: ModernColors.surfaceMedium,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restart_alt,
                  color: ModernColors.textPrimary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Restart Game',
                  style: ModernTypography.buttonMedium.copyWith(
                    color: ModernColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (onGoHome != null) {
      if (secondaryButtons.isNotEmpty) {
        secondaryButtons.add(const SizedBox(width: 12));
      }
      secondaryButtons.add(
        Expanded(
          child: AnimatedButton(
            onPressed: onGoHome!,
            backgroundColor: ModernColors.surfaceMedium,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home, color: ModernColors.textPrimary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Go Home',
                  style: ModernTypography.buttonMedium.copyWith(
                    color: ModernColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        if (buttons.isNotEmpty) Row(children: buttons),

        if (secondaryButtons.isNotEmpty) ...[
          ModernSpacing.verticalSpaceMD,
          Row(children: secondaryButtons),
        ],
      ],
    );
  }
}

/// Network error recovery widget
class NetworkErrorRecovery extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onOfflineMode;

  const NetworkErrorRecovery({super.key, this.onRetry, this.onOfflineMode});

  @override
  Widget build(BuildContext context) {
    return BreedAdventureErrorRecovery(
      errorType: 'network',
      errorMessage:
          'Unable to load images. Please check your internet connection and try again.',
      onRetry: onRetry,
      onSkip: onOfflineMode,
    );
  }
}

/// Image loading error recovery widget
class ImageLoadErrorRecovery extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onSkip;
  final int failedImageCount;

  const ImageLoadErrorRecovery({
    super.key,
    this.onRetry,
    this.onSkip,
    this.failedImageCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BreedAdventureErrorRecovery(
      errorType: 'image',
      errorMessage: failedImageCount > 0
          ? 'Failed to load $failedImageCount images. This might be a temporary issue.'
          : 'The breed images could not be loaded. This might be a temporary issue.',
      onRetry: onRetry,
      onSkip: onSkip,
    );
  }
}

/// Data corruption error recovery widget
class DataErrorRecovery extends StatelessWidget {
  final VoidCallback? onRestart;
  final VoidCallback? onGoHome;

  const DataErrorRecovery({super.key, this.onRestart, this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return BreedAdventureErrorRecovery(
      errorType: 'data',
      errorMessage:
          'Game data appears to be corrupted. Please restart the game or return to the home screen.',
      onRestart: onRestart,
      onGoHome: onGoHome,
    );
  }
}

/// Recovery mode indicator widget
class RecoveryModeIndicator extends StatelessWidget {
  final bool isVisible;
  final VoidCallback? onTap;

  const RecoveryModeIndicator({super.key, required this.isVisible, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ModernColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ModernColors.warning.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.healing, color: ModernColors.warning, size: 16),
            const SizedBox(width: 4),
            Text(
              'Recovery Mode',
              style: ModernTypography.caption.copyWith(
                color: ModernColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
