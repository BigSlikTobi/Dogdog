import 'package:flutter/material.dart';
import '../services/question_service.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../widgets/modern_card.dart';
import '../widgets/gradient_button.dart';
import '../models/enums.dart';
import '../l10n/generated/app_localizations.dart';

/// Widget that displays question service errors and provides recovery options
/// Enhanced for Task 10: Comprehensive error recovery and user guidance
class QuestionErrorHandler extends StatefulWidget {
  final VoidCallback? onRetrySuccess;
  final VoidCallback? onRetryFailed;
  final QuestionCategory? currentCategory;
  final VoidCallback? onSwitchCategory;
  final VoidCallback? onUseBackupMode;
  final VoidCallback? onGoHome;
  final bool showDetailedGuidance;

  const QuestionErrorHandler({
    super.key,
    this.onRetrySuccess,
    this.onRetryFailed,
    this.currentCategory,
    this.onSwitchCategory,
    this.onUseBackupMode,
    this.onGoHome,
    this.showDetailedGuidance = false,
  });

  @override
  State<QuestionErrorHandler> createState() => _QuestionErrorHandlerState();
}

class _QuestionErrorHandlerState extends State<QuestionErrorHandler> {
  bool _isRetrying = false;
  String? _retryMessage;
  final bool _showDetailedError = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final questionService = QuestionService();
    final errorInfo = questionService.getErrorInfo();

    if (!errorInfo['hasErrors'] && !widget.showDetailedGuidance) {
      return const SizedBox.shrink();
    }

    return ModernCard(
      child: Container(
        padding: EdgeInsets.all(ModernSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildErrorHeader(errorInfo, l10n),
            SizedBox(height: ModernSpacing.sm),
            _buildErrorMessage(errorInfo, l10n),
            if (_showDetailedError) ...[
              SizedBox(height: ModernSpacing.md),
              _buildDetailedErrorInfo(errorInfo, l10n),
            ],
            SizedBox(height: ModernSpacing.lg),
            _buildRecoveryActions(errorInfo, l10n),
            if (_retryMessage != null) ...[
              SizedBox(height: ModernSpacing.sm),
              _buildRetryMessage(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorHeader(
    Map<String, dynamic> errorInfo,
    AppLocalizations? l10n,
  ) {
    return Row(
      children: [
        Icon(
          Icons.warning_amber_rounded,
          color: _getSeverityColor(errorInfo['severity']),
          size: 24,
        ),
        SizedBox(width: ModernSpacing.sm),
        Expanded(
          child: Text(
            'Question Loading Notice',
            style: ModernTypography.headingSmall.copyWith(
              color: ModernColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(
    Map<String, dynamic> errorInfo,
    AppLocalizations? l10n,
  ) {
    return Text(
      errorInfo['message'],
      style: ModernTypography.bodyMedium.copyWith(
        color: ModernColors.textSecondary,
      ),
    );
  }

  Widget _buildDetailedErrorInfo(
    Map<String, dynamic> errorInfo,
    AppLocalizations? l10n,
  ) {
    return Container(
      padding: EdgeInsets.all(ModernSpacing.sm),
      decoration: BoxDecoration(
        color: ModernColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ModernColors.surfaceDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Technical Details:',
            style: ModernTypography.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: ModernColors.textPrimary,
            ),
          ),
          SizedBox(height: ModernSpacing.xs),
          Text(
            errorInfo.toString(),
            style: ModernTypography.bodySmall.copyWith(
              color: ModernColors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryActions(
    Map<String, dynamic> errorInfo,
    AppLocalizations? l10n,
  ) {
    return Column(
      children: [
        if (errorInfo['canRetry']) ...[
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              onPressed: _isRetrying ? null : _handleRetry,
              text: _isRetrying ? 'Retrying...' : 'Retry Loading',
              gradientColors: ModernColors.blueGradient,
              icon: _isRetrying ? null : Icons.refresh,
            ),
          ),
          SizedBox(height: ModernSpacing.sm),
          TextButton(
            onPressed: _handleDismiss,
            child: Text(
              'Continue',
              style: ModernTypography.bodyMedium.copyWith(
                color: ModernColors.primaryBlue,
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              onPressed: _handleDismiss,
              text: 'Continue with Available Content',
              gradientColors: ModernColors.greenGradient,
              icon: Icons.check,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRetryMessage() {
    final isSuccess = _retryMessage!.contains('Success');
    return Container(
      padding: EdgeInsets.all(ModernSpacing.sm),
      decoration: BoxDecoration(
        color: (isSuccess ? ModernColors.success : ModernColors.error)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isSuccess ? ModernColors.success : ModernColors.error)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        _retryMessage!,
        style: ModernTypography.bodySmall.copyWith(
          color: isSuccess ? ModernColors.success : ModernColors.error,
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return ModernColors.error;
      case 'high':
        return ModernColors.warning;
      case 'medium':
        return ModernColors.primaryYellow;
      case 'low':
        return ModernColors.info;
      default:
        return ModernColors.textSecondary;
    }
  }

  Future<void> _handleRetry() async {
    setState(() {
      _isRetrying = true;
      _retryMessage = null;
    });

    try {
      final questionService = QuestionService();
      final success = await questionService.attemptRecovery();

      setState(() {
        _isRetrying = false;
        _retryMessage = success
            ? 'Success! Questions loaded successfully.'
            : 'Retry failed. Continuing with available content.';
      });

      if (success) {
        widget.onRetrySuccess?.call();
        // Auto-dismiss after successful retry
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _handleDismiss();
          }
        });
      } else {
        widget.onRetryFailed?.call();
      }
    } catch (e) {
      setState(() {
        _isRetrying = false;
        _retryMessage = 'Retry failed: ${e.toString()}';
      });
      widget.onRetryFailed?.call();
    }
  }

  void _handleDismiss() {
    // You could implement a callback here to notify parent widget
    // For now, we'll just hide the error handler
    setState(() {
      _retryMessage = null;
    });
  }
}

/// Simplified error banner for minimal error display
class QuestionErrorBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const QuestionErrorBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final questionService = QuestionService();
    final errorInfo = questionService.getErrorInfo();

    if (!errorInfo['hasErrors']) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: ModernSpacing.lg),
        padding: EdgeInsets.all(ModernSpacing.sm),
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
            Icon(Icons.info_outline, color: ModernColors.warning, size: 20),
            SizedBox(width: ModernSpacing.sm),
            Expanded(
              child: Text(
                'Some questions may be limited. Tap for details.',
                style: ModernTypography.bodySmall.copyWith(
                  color: ModernColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: ModernColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
