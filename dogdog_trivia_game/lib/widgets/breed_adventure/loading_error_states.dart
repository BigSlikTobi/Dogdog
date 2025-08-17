import 'package:flutter/material.dart';
import '../../design_system/modern_colors.dart';
import '../../design_system/modern_typography.dart';
import '../../design_system/modern_spacing.dart';
import '../../design_system/modern_shadows.dart';
import '../../l10n/generated/app_localizations.dart';
import '../shared/loading_animation.dart';

/// Elegant loading state for breed adventure components
class BreedAdventureLoading extends StatelessWidget {
  final String? message;
  final double size;

  const BreedAdventureLoading({super.key, this.message, this.size = 80.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ModernSpacing.paddingXL,
      decoration: BoxDecoration(
        gradient: ModernColors.createLinearGradient([
          ModernColors.cardBackground,
          ModernColors.cardBackground.withValues(alpha: 0.95),
        ]),
        borderRadius: ModernSpacing.borderRadiusLarge,
        boxShadow: ModernShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingAnimation(
            size: size,
            color: ModernColors.primaryPurple,
            message:
                message ?? AppLocalizations.of(context).breedAdventure_loading,
          ),
        ],
      ),
    );
  }
}

/// Elegant error state for breed adventure components
class BreedAdventureError extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const BreedAdventureError({super.key, this.message, this.onRetry, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ModernSpacing.paddingXL,
      decoration: BoxDecoration(
        gradient: ModernColors.createLinearGradient([
          ModernColors.cardBackground,
          ModernColors.cardBackground.withValues(alpha: 0.95),
        ]),
        borderRadius: ModernSpacing.borderRadiusLarge,
        boxShadow: ModernShadows.card,
        border: Border.all(
          color: ModernColors.error.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon
          Container(
            padding: ModernSpacing.paddingLG,
            decoration: BoxDecoration(
              color: ModernColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: ModernColors.error.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon ?? Icons.error_outline,
              size: 48,
              color: ModernColors.error,
            ),
          ),

          ModernSpacing.verticalSpaceLG,

          // Error message
          Text(
            message ?? AppLocalizations.of(context).breedAdventure_error,
            style: ModernTypography.bodyMedium.copyWith(
              color: ModernColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          if (onRetry != null) ...[
            ModernSpacing.verticalSpaceLG,

            // Retry button
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernColors.error,
                foregroundColor: ModernColors.textOnDark,
                padding: ModernSpacing.paddingLG,
                shape: RoundedRectangleBorder(
                  borderRadius: ModernSpacing.borderRadiusMedium,
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 20),
                  ModernSpacing.horizontalSpaceSM,
                  Text(
                    AppLocalizations.of(context).breedAdventure_retry,
                    style: ModernTypography.buttonMedium,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Loading state specifically for breed images
class BreedImageLoading extends StatelessWidget {
  final double? width;
  final double? height;

  const BreedImageLoading({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: ModernColors.createLinearGradient([
          ModernColors.surfaceLight,
          ModernColors.surfaceMedium,
        ]),
        borderRadius: ModernSpacing.borderRadiusLarge,
        border: Border.all(
          color: ModernColors.surfaceDark.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shimmer effect
          const ShimmerLoading(child: SizedBox.expand()),

          // Loading indicator
          Container(
            padding: ModernSpacing.paddingLG,
            decoration: BoxDecoration(
              color: ModernColors.cardBackground.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: ModernShadows.small,
            ),
            child: const DotProgressIndicator(dotCount: 3, dotSize: 8),
          ),
        ],
      ),
    );
  }
}

/// Error state specifically for breed images
class BreedImageError extends StatelessWidget {
  final double? width;
  final double? height;
  final VoidCallback? onRetry;
  final String? errorMessage;

  const BreedImageError({
    super.key,
    this.width,
    this.height,
    this.onRetry,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: ModernColors.createLinearGradient([
          ModernColors.surfaceLight,
          ModernColors.surfaceMedium,
        ]),
        borderRadius: ModernSpacing.borderRadiusLarge,
        border: Border.all(
          color: ModernColors.error.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error icon
          Container(
            padding: ModernSpacing.paddingMD,
            decoration: BoxDecoration(
              color: ModernColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 32,
              color: ModernColors.error,
            ),
          ),

          ModernSpacing.verticalSpaceMD,

          // Error message
          Padding(
            padding: ModernSpacing.paddingHorizontalMD,
            child: Text(
              errorMessage ??
                  AppLocalizations.of(context).breedAdventure_imageFailedToLoad,
              style: ModernTypography.caption.copyWith(
                color: ModernColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),

          if (onRetry != null) ...[
            ModernSpacing.verticalSpaceSM,

            // Retry button
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: ModernColors.error,
                padding: ModernSpacing.paddingSM,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 16),
                  ModernSpacing.horizontalSpaceXS,
                  Text(
                    AppLocalizations.of(context).breedAdventure_retry,
                    style: ModernTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state for when no breed data is available
class BreedAdventureEmpty extends StatelessWidget {
  final String? message;
  final VoidCallback? onRefresh;

  const BreedAdventureEmpty({super.key, this.message, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ModernSpacing.paddingXXL,
      decoration: BoxDecoration(
        gradient: ModernColors.createLinearGradient([
          ModernColors.cardBackground,
          ModernColors.cardBackground.withValues(alpha: 0.95),
        ]),
        borderRadius: ModernSpacing.borderRadiusLarge,
        boxShadow: ModernShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Empty state icon
          Container(
            padding: ModernSpacing.paddingXL,
            decoration: BoxDecoration(
              color: ModernColors.primaryPurple.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: ModernColors.primaryPurple.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.pets_outlined,
              size: 64,
              color: ModernColors.primaryPurple,
            ),
          ),

          ModernSpacing.verticalSpaceXL,

          // Empty message
          Text(
            message ?? 'No breeds available',
            style: ModernTypography.headingMedium.copyWith(
              color: ModernColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          ModernSpacing.verticalSpaceMD,

          Text(
            'Please try refreshing to load breed data.',
            style: ModernTypography.bodyMedium.copyWith(
              color: ModernColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),

          if (onRefresh != null) ...[
            ModernSpacing.verticalSpaceXL,

            // Refresh button
            ElevatedButton(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernColors.primaryPurple,
                foregroundColor: ModernColors.textOnDark,
                padding: ModernSpacing.paddingLG,
                shape: RoundedRectangleBorder(
                  borderRadius: ModernSpacing.borderRadiusMedium,
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 20),
                  ModernSpacing.horizontalSpaceSM,
                  Text('Refresh', style: ModernTypography.buttonMedium),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
