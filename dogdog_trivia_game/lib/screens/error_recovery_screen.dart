import 'package:flutter/material.dart';
import '../services/error_service.dart';
import '../services/progress_service.dart';
import '../services/audio_service.dart';
import '../utils/animations.dart';
import '../models/enums.dart';
import 'home_screen.dart';
import '../l10n/generated/app_localizations.dart';

/// Screen for handling error recovery and system diagnostics
class ErrorRecoveryScreen extends StatefulWidget {
  final AppError? initialError;

  const ErrorRecoveryScreen({super.key, this.initialError});

  @override
  State<ErrorRecoveryScreen> createState() => _ErrorRecoveryScreenState();
}

class _ErrorRecoveryScreenState extends State<ErrorRecoveryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _showErrorHistory = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.slowDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).errorScreen_title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    if (widget.initialError != null) _buildErrorDetails(),
                    const SizedBox(height: 24),
                    _buildRecoveryActions(),
                    const SizedBox(height: 24),
                    _buildErrorHistorySection(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.build, size: 30, color: Colors.orange),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Recovery',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF1F2937),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Diagnose and fix issues with the app',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorDetails() {
    final error = widget.initialError!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                'Current Error',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            error.userMessage,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Type: ${error.type.toString().split('.').last}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
          ),
          Text(
            'Severity: ${error.severity.toString().split('.').last}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
          ),
          Text(
            'Time: ${error.timestamp.toString()}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recovery Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        _buildActionCard(
          icon: Icons.refresh,
          title: 'Restart Services',
          description: 'Reinitialize all app services',
          onTap: _restartServices,
        ),

        const SizedBox(height: 12),

        _buildActionCard(
          icon: Icons.clear_all,
          title: 'Clear Cache',
          description: 'Clear temporary data and cache',
          onTap: _clearCache,
        ),

        const SizedBox(height: 12),

        _buildActionCard(
          icon: Icons.restore,
          title: 'Reset to Defaults',
          description: 'Reset app settings to default values',
          onTap: _resetToDefaults,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (isDestructive ? Colors.red : Colors.blue).withValues(
              alpha: 0.1,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : Colors.blue,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildErrorHistorySection() {
    final errorHistory = ErrorService().errorHistory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Error History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _showErrorHistory = !_showErrorHistory;
                });
              },
              child: Text(_showErrorHistory ? 'Hide' : 'Show'),
            ),
          ],
        ),

        if (_showErrorHistory) ...[
          const SizedBox(height: 16),
          if (errorHistory.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle, size: 48, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    'No Recent Errors',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your app is running smoothly!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: errorHistory
                    .take(5)
                    .map((error) => _buildErrorHistoryItem(error))
                    .toList(),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildErrorHistoryItem(AppError error) {
    Color typeColor;
    IconData typeIcon;

    switch (error.type) {
      case ErrorType.network:
        typeColor = Colors.orange;
        typeIcon = Icons.wifi_off;
        break;
      case ErrorType.storage:
        typeColor = Colors.red;
        typeIcon = Icons.storage;
        break;
      case ErrorType.audio:
        typeColor = Colors.blue;
        typeIcon = Icons.volume_off;
        break;
      case ErrorType.gameLogic:
        typeColor = Colors.purple;
        typeIcon = Icons.gamepad;
        break;
      case ErrorType.ui:
        typeColor = Colors.green;
        typeIcon = Icons.view_compact;
        break;
      case ErrorType.unknown:
        typeColor = Colors.grey;
        typeIcon = Icons.help_outline;
        break;
    }

    return ListTile(
      leading: Icon(typeIcon, color: typeColor, size: 20),
      title: Text(
        error.message,
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${error.type.toString().split('.').last} • ${_formatTimestamp(error.timestamp)}',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getSeverityColor(error.severity).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          error.severity.toString().split('.').last,
          style: TextStyle(
            color: _getSeverityColor(error.severity),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.green;
      case ErrorSeverity.medium:
        return Colors.orange;
      case ErrorSeverity.high:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade800;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Future<void> _restartServices() async {
    try {
      // Restart all services
      await ProgressService().initialize();
      await AudioService().initialize();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorScreen_servicesRestarted,
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).errorScreen_restartFailed(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearCache() async {
    try {
      // Clear error history
      ErrorService().clearErrorHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorScreen_cacheCleared,
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh error history display
      setState(() {
        _showErrorHistory = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).errorScreen_cacheClearFailed(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).errorScreen_resetToDefaults),
        content: Text(
          AppLocalizations.of(context).errorScreen_resetConfirmation,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context).errorScreen_reset),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Reset audio settings
        final audioService = AudioService();
        await audioService.setMuted(false);
        await audioService.setVolume(1.0);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).errorScreen_settingsReset,
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to home
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                ).errorScreen_resetFailed(e.toString()),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

/// Represents the result of a diagnostic check
class DiagnosticResult {
  final String name;
  final DiagnosticStatus status;
  final String message;

  DiagnosticResult({
    required this.name,
    required this.status,
    required this.message,
  });
}

/// Status of a diagnostic check
enum DiagnosticStatus { passed, warning, failed }
