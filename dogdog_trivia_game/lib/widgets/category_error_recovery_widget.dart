import 'package:flutter/material.dart';
import '../services/category_error_recovery_service.dart';
import '../design_system/modern_colors.dart';
import '../design_system/modern_typography.dart';
import '../design_system/modern_spacing.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/enums.dart';
import '../widgets/gradient_button.dart';
import '../widgets/modern_card.dart';

/// Comprehensive error recovery widget for category-specific issues
/// Implements Task 10: Add comprehensive error recovery and user guidance
class CategoryErrorRecoveryWidget extends StatefulWidget {
  final QuestionCategory category;
  final VoidCallback? onCategorySwitched;
  final VoidCallback? onBackupModeActivated;
  final VoidCallback? onGoHome;
  final VoidCallback? onContinueWithLimited;
  final String locale;

  const CategoryErrorRecoveryWidget({
    super.key,
    required this.category,
    this.onCategorySwitched,
    this.onBackupModeActivated,
    this.onGoHome,
    this.onContinueWithLimited,
    this.locale = 'en',
  });

  @override
  State<CategoryErrorRecoveryWidget> createState() =>
      _CategoryErrorRecoveryWidgetState();
}

class _CategoryErrorRecoveryWidgetState
    extends State<CategoryErrorRecoveryWidget> {
  final CategoryErrorRecoveryService _recoveryService =
      CategoryErrorRecoveryService();
  CategoryErrorAnalysis? _currentAnalysis;
  bool _isAnalyzing = true;
  bool _isRecovering = false;
  String? _recoveryMessage;

  @override
  void initState() {
    super.initState();
    _analyzeCategory();
  }

  Future<void> _analyzeCategory() async {
    setState(() {
      _isAnalyzing = true;
      _recoveryMessage = null;
    });

    try {
      final analysis = await _recoveryService.analyzeCategoryError(
        category: widget.category,
        locale: widget.locale,
      );

      setState(() {
        _currentAnalysis = analysis;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _currentAnalysis = CategoryErrorAnalysis(
          category: widget.category,
          errorType: CategoryErrorType.criticalFailure,
          availableQuestions: 0,
          canContinue: false,
          recommendedAction: RecoveryAction.goHome,
          userMessage: 'Failed to analyze category: ${e.toString()}',
        );
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isAnalyzing) {
      return _buildAnalyzingWidget(l10n);
    }

    if (_currentAnalysis == null) {
      return _buildErrorWidget(l10n);
    }

    // If no errors found, don't show anything
    if (_currentAnalysis!.errorType == CategoryErrorType.none) {
      return const SizedBox.shrink();
    }

    return ModernCard(
      child: Container(
        padding: EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildErrorHeader(l10n),
            SizedBox(height: ModernSpacing.md),
            _buildErrorMessage(l10n),
            if (_recoveryMessage != null) ...[
              SizedBox(height: ModernSpacing.sm),
              _buildRecoveryMessage(),
            ],
            SizedBox(height: ModernSpacing.lg),
            _buildRecoveryActions(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzingWidget(AppLocalizations l10n) {
    return ModernCard(
      child: Container(
        padding: EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: ModernSpacing.md),
            Text(
              'Analyzing category availability...',
              style: ModernTypography.bodyMedium.copyWith(
                color: ModernColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(AppLocalizations l10n) {
    return ModernCard(
      child: Container(
        padding: EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: ModernColors.error, size: 48),
            SizedBox(height: ModernSpacing.md),
            Text(
              l10n.errorCriticalTitle,
              style: ModernTypography.headingMedium.copyWith(
                color: ModernColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ModernSpacing.sm),
            Text(
              l10n.errorCriticalMessage,
              style: ModernTypography.bodyMedium.copyWith(
                color: ModernColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorHeader(AppLocalizations l10n) {
    IconData icon;
    Color iconColor;
    String title;

    switch (_currentAnalysis!.errorType) {
      case CategoryErrorType.criticalFailure:
        icon = Icons.error_outline;
        iconColor = ModernColors.error;
        title = l10n.errorCriticalTitle;
        break;
      case CategoryErrorType.noQuestions:
        icon = Icons.help_outline;
        iconColor = ModernColors.warning;
        title = l10n.errorNoQuestionsTitle;
        break;
      case CategoryErrorType.localizationError:
        icon = Icons.translate;
        iconColor = ModernColors.warning;
        title = l10n.errorLocalizationTitle;
        break;
      default:
        icon = Icons.warning_amber_outlined;
        iconColor = ModernColors.warning;
        title = l10n.errorLoadingTitle;
        break;
    }

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ModernSpacing.sm),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 32),
        ),
        SizedBox(width: ModernSpacing.md),
        Expanded(
          child: Text(
            title,
            style: ModernTypography.headingMedium.copyWith(
              color: iconColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(AppLocalizations l10n) {
    return Text(
      _currentAnalysis!.userMessage,
      style: ModernTypography.bodyMedium.copyWith(
        color: ModernColors.textSecondary,
        height: 1.4,
      ),
    );
  }

  Widget _buildRecoveryMessage() {
    final isSuccess = _recoveryMessage!.toLowerCase().contains('success');
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
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? ModernColors.success : ModernColors.error,
            size: 20,
          ),
          SizedBox(width: ModernSpacing.sm),
          Expanded(
            child: Text(
              _recoveryMessage!,
              style: ModernTypography.bodySmall.copyWith(
                color: isSuccess ? ModernColors.success : ModernColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryActions(AppLocalizations l10n) {
    return Column(
      children: [
        // Primary action
        _buildPrimaryAction(l10n),

        // Alternative actions
        if (_currentAnalysis!.alternativeActions.isNotEmpty) ...[
          SizedBox(height: ModernSpacing.sm),
          ..._currentAnalysis!.alternativeActions.map(
            (action) => Padding(
              padding: EdgeInsets.only(bottom: ModernSpacing.xs),
              child: _buildSecondaryAction(l10n, action),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrimaryAction(AppLocalizations l10n) {
    final action = _currentAnalysis!.recommendedAction;
    return SizedBox(
      width: double.infinity,
      child: _buildActionButton(l10n, action, isPrimary: true),
    );
  }

  Widget _buildSecondaryAction(AppLocalizations l10n, RecoveryAction action) {
    return SizedBox(
      width: double.infinity,
      child: _buildActionButton(l10n, action, isPrimary: false),
    );
  }

  Widget _buildActionButton(
    AppLocalizations l10n,
    RecoveryAction action, {
    required bool isPrimary,
  }) {
    String buttonText;
    VoidCallback? onPressed;
    IconData? icon;

    switch (action) {
      case RecoveryAction.retry:
        buttonText = l10n.errorActionRetry;
        onPressed = _isRecovering ? null : () => _handleRecovery(action);
        icon = Icons.refresh;
        break;
      case RecoveryAction.switchCategory:
        buttonText = l10n.errorActionSwitchCategory;
        onPressed = widget.onCategorySwitched;
        icon = Icons.category;
        break;
      case RecoveryAction.continueAnyway:
        buttonText = l10n.errorActionContinueAnyway(
          _currentAnalysis!.availableQuestions,
        );
        onPressed = widget.onContinueWithLimited;
        icon = Icons.play_arrow;
        break;
      case RecoveryAction.useDefaultLanguage:
        buttonText = l10n.errorActionUseDefaultLanguage;
        onPressed = _isRecovering ? null : () => _handleRecovery(action);
        icon = Icons.language;
        break;
      case RecoveryAction.useBackupMode:
        buttonText = 'Use Backup Questions';
        onPressed = _isRecovering ? null : () => _handleRecovery(action);
        icon = Icons.backup;
        break;
      case RecoveryAction.goHome:
        buttonText = l10n.errorActionGoHome;
        onPressed = widget.onGoHome;
        icon = Icons.home;
        break;
      default:
        buttonText = 'Continue';
        onPressed = widget.onContinueWithLimited;
        icon = Icons.arrow_forward;
        break;
    }

    if (isPrimary) {
      return GradientButton(
        onPressed: onPressed,
        text: _isRecovering ? 'Processing...' : buttonText,
        gradientColors: _getGradientForAction(action),
        icon: _isRecovering ? null : icon,
      );
    } else {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(buttonText),
        style: OutlinedButton.styleFrom(
          foregroundColor: ModernColors.textSecondary,
          side: BorderSide(
            color: ModernColors.textSecondary.withValues(alpha: 0.3),
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      );
    }
  }

  List<Color> _getGradientForAction(RecoveryAction action) {
    switch (action) {
      case RecoveryAction.retry:
      case RecoveryAction.useDefaultLanguage:
        return ModernColors.blueGradient;
      case RecoveryAction.continueAnyway:
        return ModernColors.greenGradient;
      case RecoveryAction.goHome:
        return ModernColors.blueGradient;
      default:
        return ModernColors.purpleGradient;
    }
  }

  Future<void> _handleRecovery(RecoveryAction action) async {
    setState(() {
      _isRecovering = true;
      _recoveryMessage = null;
    });

    try {
      final result = await _recoveryService.attemptRecovery(
        analysis: _currentAnalysis!,
        action: action,
        fallbackLocale: 'en',
      );

      setState(() {
        _isRecovering = false;
        _recoveryMessage = result.message;
        _currentAnalysis = result.newAnalysis;
      });

      if (result.success) {
        // Notify parent about successful recovery
        switch (action) {
          case RecoveryAction.useBackupMode:
            widget.onBackupModeActivated?.call();
            break;
          case RecoveryAction.continueAnyway:
            widget.onContinueWithLimited?.call();
            break;
          default:
            break;
        }
      }
    } catch (e) {
      setState(() {
        _isRecovering = false;
        _recoveryMessage = 'Recovery failed: ${e.toString()}';
      });
    }
  }
}
