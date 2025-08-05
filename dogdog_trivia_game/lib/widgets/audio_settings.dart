import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../widgets/animated_button.dart';

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
          activeColor: const Color(0xFF4A90E2),
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

/// Dialog for showing audio settings
class AudioSettingsDialog extends StatelessWidget {
  const AudioSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AudioSettingsWidget(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SecondaryAnimatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows the audio settings dialog
  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (context) => const AudioSettingsDialog(),
    );
  }
}
