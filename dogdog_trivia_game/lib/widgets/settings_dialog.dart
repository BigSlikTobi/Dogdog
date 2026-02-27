import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../controllers/settings_controller.dart';
import '../controllers/companion_controller.dart';
import '../widgets/animated_button.dart';
import '../l10n/generated/app_localizations.dart';

/// Widget for managing language settings
class LanguageSettingsWidget extends StatelessWidget {
  const LanguageSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch for settings changes to rebuild UI
    final settingsForTranslation = Provider.of<SettingsController>(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language, color: const Color(0xFF4A90E2), size: 24),
              const SizedBox(width: 12),
              Text(
                'Language', // We could use l10n.language if available
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLanguageOption(
            context,
            'English',
            'en',
            settingsForTranslation.isLanguageSelected('en') || 
            (settingsForTranslation.locale == null && Localizations.localeOf(context).languageCode == 'en'),
            () => settingsForTranslation.setLocale(const Locale('en')),
          ),
          const SizedBox(height: 12),
          _buildLanguageOption(
            context,
            'Deutsch',
            'de',
            settingsForTranslation.isLanguageSelected('de') || 
            (settingsForTranslation.locale == null && Localizations.localeOf(context).languageCode == 'de'),
            () => settingsForTranslation.setLocale(const Locale('de')),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String label,
    String code,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A90E2).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A90E2) : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF1F2937),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF4A90E2), size: 20),
          ],
        ),
      ),
    );
  }
}

/// Widget for managing user name settings
class UserSettingsWidget extends StatefulWidget {
  const UserSettingsWidget({super.key});

  @override
  State<UserSettingsWidget> createState() => _UserSettingsWidgetState();
}

class _UserSettingsWidgetState extends State<UserSettingsWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsController>();
    _controller = TextEditingController(text: settings.userName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: const Color(0xFF4A90E2), size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.settings_userName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: l10n.settings_userNameHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              context.read<SettingsController>().setUserName(value);
            },
          ),
        ],
      ),
    );
  }
}

/// Widget for managing dog name settings
class DogSettingsWidget extends StatefulWidget {
  const DogSettingsWidget({super.key});

  @override
  State<DogSettingsWidget> createState() => _DogSettingsWidgetState();
}

class _DogSettingsWidgetState extends State<DogSettingsWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final companion = context.read<CompanionController>().companion;
    _controller = TextEditingController(text: companion?.name ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final companionCtrl = context.watch<CompanionController>();
    
    // Only show if companion exists
    if (companionCtrl.companion == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                companionCtrl.companion!.breed.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.settings_dogName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: l10n.settings_dogNameHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              companionCtrl.renameDog(value);
            },
          ),
        ],
      ),
    );
  }
}

/// Widget for managing audio settings including mute toggle and volume control
class AudioSettingsWidget extends StatefulWidget {
  const AudioSettingsWidget({super.key});

  @override
  State<AudioSettingsWidget> createState() => _AudioSettingsWidgetState();
}

class _AudioSettingsWidgetState extends State<AudioSettingsWidget> {
  final AudioService _audioService = AudioService();
  bool _isMuted = false;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _isMuted = _audioService.isMuted;
      _volume = _audioService.volume;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.volume_up, color: const Color(0xFF4A90E2), size: 24),
              const SizedBox(width: 12),
              Text(
                'Audio Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Mute toggle
          _buildMuteToggle(),

          const SizedBox(height: 20),

          // Volume slider
          if (!_isMuted) _buildVolumeSlider(),

          const SizedBox(height: 20),

          // Test sound buttons
          _buildTestSoundButtons(),
        ],
      ),
    );
  }

  /// Builds the mute toggle switch
  Widget _buildMuteToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              _isMuted ? Icons.volume_off : Icons.volume_up,
              color: _isMuted
                  ? const Color(0xFF6B7280)
                  : const Color(0xFF4A90E2),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Sound Effects',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Switch(
          value: !_isMuted,
          onChanged: (value) async {
            await _audioService.setMuted(!value);
            setState(() {
              _isMuted = !value;
            });

            // Play test sound when enabling audio
            if (value) {
              await _audioService.playButtonSound();
            }
          },
          activeThumbColor: const Color(0xFF4A90E2),
        ),
      ],
    );
  }

  /// Builds the volume slider
  Widget _buildVolumeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Volume',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.volume_down, color: const Color(0xFF6B7280), size: 16),
            Expanded(
              child: Slider(
                value: _volume,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                activeColor: const Color(0xFF4A90E2),
                inactiveColor: const Color(0xFFE5E7EB),
                onChanged: (value) {
                  setState(() {
                    _volume = value;
                  });
                },
                onChangeEnd: (value) async {
                  await _audioService.setVolume(value);
                  // Play test sound at new volume
                  await _audioService.playButtonSound();
                },
              ),
            ),
            Icon(Icons.volume_up, color: const Color(0xFF6B7280), size: 16),
          ],
        ),
        Text(
          '${(_volume * 100).round()}%',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
        ),
      ],
    );
  }

  /// Builds test sound buttons
  Widget _buildTestSoundButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test Sounds',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTestSoundButton(
              'Correct',
              Icons.check_circle,
              const Color(0xFF10B981),
              () => _audioService.playCorrectAnswerSound(),
            ),
            _buildTestSoundButton(
              'Incorrect',
              Icons.cancel,
              const Color(0xFFEF4444),
              () => _audioService.playIncorrectAnswerSound(),
            ),
            _buildTestSoundButton(
              'Power-up',
              Icons.star,
              const Color(0xFFF59E0B),
              () => _audioService.playPowerUpSound(),
            ),
            _buildTestSoundButton(
              'Achievement',
              Icons.emoji_events,
              const Color(0xFF8B5CF6),
              () => _audioService.playAchievementSound(),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds a single test sound button
  Widget _buildTestSoundButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return OutlineAnimatedButton(
      onPressed: _isMuted ? null : onPressed,
      borderColor: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: _isMuted ? const Color(0xFF9CA3AF) : color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog for showing app settings
class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent, // Background handled by child
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // User Settings
              const UserSettingsWidget(),
              
              const SizedBox(height: 16),
              
              // Dog Settings (only shows if companion exists)
              const DogSettingsWidget(),
              
              const SizedBox(height: 16),
              
              // Language Settings
              const LanguageSettingsWidget(),
              
              const SizedBox(height: 16),
              
              // Audio Settings
              const AudioSettingsWidget(),
              
              const SizedBox(height: 16),
              
              // Close Button
              SizedBox(
                width: double.infinity,
                child: SecondaryAnimatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context).common_close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows the settings dialog
  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }
}
