import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enums.dart';
import '../utils/retry_mechanism.dart';
import 'error_service.dart';

/// Service for managing audio and sound effects in the game
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  late AudioPlayer _audioPlayer;
  bool _isMuted = false;
  bool _isInitialized = false;
  double _volume = 1.0;

  /// Audio file paths
  static const String _correctAnswerSound = 'audio/happy_bark.mp3';
  static const String _incorrectAnswerSound = 'audio/sad_whimper.mp3';
  static const String _buttonClickSound = 'audio/playful_bark.mp3';
  static const String _powerUpSound = 'audio/power_up.mp3';
  static const String _achievementSound = 'audio/achievement_unlock.mp3';

  /// Initialize the audio service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final result = await AudioRetry.execute<void>(() async {
        _audioPlayer = AudioPlayer();
        await _loadSettings();
      });

      if (result.success) {
        _isInitialized = true;
      } else {
        // Fallback initialization without audio
        _isMuted = true;
        _volume = 0.0;
        _isInitialized = true;

        ErrorService().handleAudioError(
          result.error ?? Exception('Failed to initialize audio service'),
        );
      }
    } catch (error, stackTrace) {
      ErrorService().recordError(
        ErrorType.audio,
        'Critical failure in AudioService initialization',
        severity:
            ErrorSeverity.low, // Audio failure is not critical for app function
        stackTrace: stackTrace,
        originalError: error,
      );

      // Initialize in muted state as fallback
      _isMuted = true;
      _volume = 0.0;
      _isInitialized = true;
    }
  }

  /// Load audio settings from shared preferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMuted = prefs.getBool('audio_muted') ?? false;
      _volume = prefs.getDouble('audio_volume') ?? 1.0;
    } catch (e) {
      // Use default settings if loading fails
      _isMuted = false;
      _volume = 1.0;
    }
  }

  /// Save audio settings to shared preferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('audio_muted', _isMuted);
      await prefs.setDouble('audio_volume', _volume);
    } catch (e) {
      // Silently fail if saving fails
    }
  }

  /// Whether audio is currently muted
  bool get isMuted => _isMuted;

  /// Current volume level (0.0 to 1.0)
  double get volume => _volume;

  /// Toggles the mute state
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await _saveSettings();
  }

  /// Sets the mute state
  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    await _saveSettings();
  }

  /// Sets the volume level (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _saveSettings();
  }

  /// Plays an audio file from assets
  Future<void> _playSound(String assetPath) async {
    if (_isMuted || !_isInitialized) return;

    try {
      final result = await AudioRetry.execute<void>(() async {
        await _audioPlayer.stop(); // Stop any currently playing sound
        await _audioPlayer.setVolume(_volume);
        await _audioPlayer.play(AssetSource(assetPath));
      });

      if (!result.success) {
        // Fallback to system sound if audio playback fails
        await SystemSound.play(SystemSoundType.click);
      }
    } catch (error) {
      // Record error but don't crash the app
      ErrorService().handleAudioError(error);

      // Fallback to system sound
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {
        // Silent fail if even system sound fails
      }
    }
  }

  /// Dispose of resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await _audioPlayer.dispose();
      _isInitialized = false;
    }
  }

  /// Plays a happy bark sound for correct answers
  Future<void> playCorrectAnswerSound() async {
    await _playSound(_correctAnswerSound);
  }

  /// Plays a gentle whimper sound for incorrect answers
  Future<void> playIncorrectAnswerSound() async {
    await _playSound(_incorrectAnswerSound);
  }

  /// Plays a playful bark sound for button presses
  Future<void> playButtonSound() async {
    await _playSound(_buttonClickSound);
  }

  /// Plays a magical sound for power-up usage
  Future<void> playPowerUpSound() async {
    await _playSound(_powerUpSound);
  }

  /// Plays a celebration sound for achievements
  Future<void> playAchievementSound() async {
    await _playSound(_achievementSound);
  }
}
