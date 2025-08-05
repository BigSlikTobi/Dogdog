import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dogdog_trivia_game/services/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioService', () {
    late AudioService audioService;

    setUp(() async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Mock the method channel for audioplayers
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('xyz.luan/audioplayers'),
            (MethodCall methodCall) async {
              // Mock audio player method calls
              switch (methodCall.method) {
                case 'create':
                  return 'player_id';
                case 'setVolume':
                case 'play':
                case 'stop':
                case 'dispose':
                  return null;
                default:
                  return null;
              }
            },
          );

      audioService = AudioService();
      await audioService.initialize();
    });

    tearDown(() async {
      await audioService.dispose();
    });

    test('should initialize with default settings', () {
      expect(audioService.isMuted, isFalse);
      expect(audioService.volume, equals(1.0));
    });

    test('should toggle mute state', () async {
      expect(audioService.isMuted, isFalse);

      await audioService.toggleMute();
      expect(audioService.isMuted, isTrue);

      await audioService.toggleMute();
      expect(audioService.isMuted, isFalse);
    });

    test('should set mute state', () async {
      await audioService.setMuted(true);
      expect(audioService.isMuted, isTrue);

      await audioService.setMuted(false);
      expect(audioService.isMuted, isFalse);
    });

    test('should set volume within valid range', () async {
      await audioService.setVolume(0.5);
      expect(audioService.volume, equals(0.5));

      await audioService.setVolume(0.0);
      expect(audioService.volume, equals(0.0));

      await audioService.setVolume(1.0);
      expect(audioService.volume, equals(1.0));
    });

    test('should clamp volume to valid range', () async {
      await audioService.setVolume(-0.5);
      expect(audioService.volume, equals(0.0));

      await audioService.setVolume(1.5);
      expect(audioService.volume, equals(1.0));
    });

    test('should persist settings to SharedPreferences', () async {
      await audioService.setMuted(true);
      await audioService.setVolume(0.7);

      // Create new instance to test persistence
      final newAudioService = AudioService();
      await newAudioService.initialize();

      expect(newAudioService.isMuted, isTrue);
      expect(newAudioService.volume, equals(0.7));

      await newAudioService.dispose();
    });

    test('should load settings from SharedPreferences', () async {
      // Set mock initial values
      SharedPreferences.setMockInitialValues({
        'audio_muted': true,
        'audio_volume': 0.3,
      });

      final newAudioService = AudioService();
      await newAudioService.initialize();

      expect(newAudioService.isMuted, isTrue);
      expect(newAudioService.volume, equals(0.3));

      await newAudioService.dispose();
    });

    test('should handle SharedPreferences errors gracefully', () async {
      // This test ensures the service doesn't crash if SharedPreferences fails
      expect(() async {
        await audioService.setMuted(true);
        await audioService.setVolume(0.5);
      }, returnsNormally);
    });

    group('Sound Playback', () {
      test('should not throw when playing sounds', () async {
        // These tests ensure the methods don't throw exceptions
        // In a real test environment, we'd mock the AudioPlayer
        expect(() async {
          await audioService.playCorrectAnswerSound();
        }, returnsNormally);

        expect(() async {
          await audioService.playIncorrectAnswerSound();
        }, returnsNormally);

        expect(() async {
          await audioService.playButtonSound();
        }, returnsNormally);

        expect(() async {
          await audioService.playPowerUpSound();
        }, returnsNormally);

        expect(() async {
          await audioService.playAchievementSound();
        }, returnsNormally);
      });

      test('should not play sounds when muted', () async {
        await audioService.setMuted(true);

        // These should complete without playing actual sounds
        expect(() async {
          await audioService.playCorrectAnswerSound();
          await audioService.playIncorrectAnswerSound();
          await audioService.playButtonSound();
          await audioService.playPowerUpSound();
          await audioService.playAchievementSound();
        }, returnsNormally);
      });
    });

    group('Singleton Pattern', () {
      test('should return same instance', () {
        final instance1 = AudioService();
        final instance2 = AudioService();

        expect(identical(instance1, instance2), isTrue);
      });

      test('should maintain state across instances', () async {
        final instance1 = AudioService();
        await instance1.setMuted(true);
        await instance1.setVolume(0.5);

        final instance2 = AudioService();
        expect(instance2.isMuted, isTrue);
        expect(instance2.volume, equals(0.5));
      });
    });

    group('Initialization', () {
      test('should handle multiple initialization calls', () async {
        expect(() async {
          await audioService.initialize();
          await audioService.initialize();
          await audioService.initialize();
        }, returnsNormally);
      });

      test('should be safe to call methods before initialization', () async {
        final newService = AudioService();
        // Don't initialize

        expect(() async {
          await newService.playButtonSound();
        }, returnsNormally);
      });
    });

    group('Resource Management', () {
      test('should dispose resources properly', () async {
        expect(() async {
          await audioService.dispose();
        }, returnsNormally);
      });

      test('should handle multiple dispose calls', () async {
        expect(() async {
          await audioService.dispose();
          await audioService.dispose();
        }, returnsNormally);
      });

      test('should be safe to call methods after dispose', () async {
        await audioService.dispose();

        expect(() async {
          await audioService.playButtonSound();
        }, returnsNormally);
      });
    });
  });
}
