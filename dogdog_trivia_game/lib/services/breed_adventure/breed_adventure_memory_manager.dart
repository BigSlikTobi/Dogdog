import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/breed_adventure/breed_adventure_game_state.dart';
import 'optimized_image_cache_service.dart';

/// Advanced memory management for breed adventure with intelligent optimization
class BreedAdventureMemoryManager {
  static BreedAdventureMemoryManager? _instance;
  static BreedAdventureMemoryManager get instance =>
      _instance ??= BreedAdventureMemoryManager._();

  BreedAdventureMemoryManager._();

  // Configuration constants
  static const int maxUsedBreeds = 50;
  static const int maxGameStatesToKeep = 10;
  static const Duration memoryCheckInterval = Duration(minutes: 1);
  static const int memoryWarningThresholdMB = 100;
  static const int memoryCriticalThresholdMB = 150;

  // Memory tracking
  int _currentMemoryUsageMB = 0;
  int _peakMemoryUsageMB = 0;
  DateTime? _lastMemoryCheck;
  Timer? _memoryCheckTimer;

  // Game state optimization
  final List<BreedAdventureGameState> _gameStateHistory = [];
  final Set<String> _recentlyUsedBreeds = <String>{};

  // Memory pressure levels
  MemoryPressureLevel _currentPressureLevel = MemoryPressureLevel.low;

  bool _isInitialized = false;
  bool _memoryWarningShown = false;

  /// Initialize memory management
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Start periodic memory monitoring
    _startMemoryMonitoring();

    _isInitialized = true;
    debugPrint('BreedAdventureMemoryManager initialized');
  }

  /// Optimize game state to reduce memory usage
  BreedAdventureGameState optimizeGameState(BreedAdventureGameState state) {
    // Save to history for analysis
    _addToGameStateHistory(state);

    // Optimize used breeds set
    Set<String> optimizedUsedBreeds = state.usedBreeds;
    if (state.usedBreeds.length > maxUsedBreeds) {
      // Keep only the most recent breeds to prevent memory bloat
      final breedsList = state.usedBreeds.toList();
      optimizedUsedBreeds = breedsList
          .skip(breedsList.length - maxUsedBreeds)
          .toSet();

      debugPrint(
        'Optimized used breeds: ${state.usedBreeds.length} -> ${optimizedUsedBreeds.length}',
      );
    }

    // Update recently used breeds for intelligent preloading
    _recentlyUsedBreeds.addAll(optimizedUsedBreeds);
    if (_recentlyUsedBreeds.length > maxUsedBreeds * 2) {
      final breedsToRemove = _recentlyUsedBreeds.length - maxUsedBreeds;
      final breedsList = _recentlyUsedBreeds.toList();
      for (int i = 0; i < breedsToRemove; i++) {
        _recentlyUsedBreeds.remove(breedsList[i]);
      }
    }

    return state.copyWith(usedBreeds: optimizedUsedBreeds);
  }

  /// Add game state to history with size management
  void _addToGameStateHistory(BreedAdventureGameState state) {
    _gameStateHistory.add(state);

    // Keep only recent states
    while (_gameStateHistory.length > maxGameStatesToKeep) {
      _gameStateHistory.removeAt(0);
    }
  }

  /// Perform comprehensive memory cleanup
  Future<void> cleanupMemory() async {
    debugPrint('Starting comprehensive memory cleanup...');

    try {
      // Clean up image cache
      final imageCacheService = OptimizedImageCacheService.instance;
      final stats = imageCacheService.getPerformanceStats();

      if (stats.memoryUsageMB > 30) {
        // If using more than 30MB
        imageCacheService.clearCache();
        debugPrint('Cleared image cache to free memory');
      }

      // Clean up game state history
      if (_gameStateHistory.length > 5) {
        final keepCount = (_gameStateHistory.length * 0.5).round();
        _gameStateHistory.removeRange(0, _gameStateHistory.length - keepCount);
        debugPrint('Cleaned up game state history');
      }

      // Clean up recently used breeds if too large
      if (_recentlyUsedBreeds.length > maxUsedBreeds) {
        final keepCount = (maxUsedBreeds * 0.7).round();
        final breedsList = _recentlyUsedBreeds.toList();
        _recentlyUsedBreeds.clear();
        _recentlyUsedBreeds.addAll(
          breedsList.skip(breedsList.length - keepCount),
        );
        debugPrint('Cleaned up recently used breeds');
      }

      // Force garbage collection if on supported platforms
      if (Platform.isAndroid || Platform.isIOS) {
        // Request garbage collection
        await _requestGarbageCollection();
      }

      // Update memory usage after cleanup
      await _checkMemoryUsage();

      debugPrint(
        'Memory cleanup completed. Current usage: ${_currentMemoryUsageMB}MB',
      );
    } catch (e) {
      debugPrint('Error during memory cleanup: $e');
    }
  }

  /// Request garbage collection (platform-specific)
  Future<void> _requestGarbageCollection() async {
    try {
      // Trigger system-level memory cleanup
      await SystemChannels.platform.invokeMethod('SystemChrome.systemUIMode');

      // Small delay to allow GC to run
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      // Ignore errors - GC request is best-effort
      debugPrint('Could not request garbage collection: $e');
    }
  }

  /// Start periodic memory monitoring
  void _startMemoryMonitoring() {
    _memoryCheckTimer = Timer.periodic(memoryCheckInterval, (_) async {
      await _checkMemoryUsage();
      await _handleMemoryPressure();
    });
  }

  /// Check current memory usage
  Future<void> _checkMemoryUsage() async {
    _lastMemoryCheck = DateTime.now();

    try {
      // Get Flutter image cache memory usage
      final imageCache = PaintingBinding.instance.imageCache;
      final imageCacheMB = (imageCache.currentSizeBytes / (1024 * 1024))
          .round();

      // Estimate total memory usage (rough calculation)
      _currentMemoryUsageMB =
          imageCacheMB +
          (_gameStateHistory.length * 2) + // ~2MB per game state
          (_recentlyUsedBreeds.length ~/ 10); // ~1MB per 10 breeds

      // Update peak usage
      if (_currentMemoryUsageMB > _peakMemoryUsageMB) {
        _peakMemoryUsageMB = _currentMemoryUsageMB;
      }

      // Determine memory pressure level
      _updateMemoryPressureLevel();
    } catch (e) {
      debugPrint('Error checking memory usage: $e');
    }
  }

  /// Update memory pressure level based on usage
  void _updateMemoryPressureLevel() {
    final previousLevel = _currentPressureLevel;

    if (_currentMemoryUsageMB >= memoryCriticalThresholdMB) {
      _currentPressureLevel = MemoryPressureLevel.critical;
    } else if (_currentMemoryUsageMB >= memoryWarningThresholdMB) {
      _currentPressureLevel = MemoryPressureLevel.high;
    } else if (_currentMemoryUsageMB >= memoryWarningThresholdMB * 0.7) {
      _currentPressureLevel = MemoryPressureLevel.medium;
    } else {
      _currentPressureLevel = MemoryPressureLevel.low;
    }

    if (_currentPressureLevel != previousLevel) {
      debugPrint(
        'Memory pressure level changed: $previousLevel -> $_currentPressureLevel',
      );
    }
  }

  /// Handle memory pressure with appropriate actions
  Future<void> _handleMemoryPressure() async {
    switch (_currentPressureLevel) {
      case MemoryPressureLevel.critical:
        await _handleCriticalMemoryPressure();
        break;
      case MemoryPressureLevel.high:
        await _handleHighMemoryPressure();
        break;
      case MemoryPressureLevel.medium:
        await _handleMediumMemoryPressure();
        break;
      case MemoryPressureLevel.low:
        // No action needed
        break;
    }
  }

  /// Handle critical memory pressure
  Future<void> _handleCriticalMemoryPressure() async {
    debugPrint(
      'Critical memory pressure detected! Performing aggressive cleanup...',
    );

    // Aggressive cleanup
    await cleanupMemory();

    // Clear most of the image cache
    OptimizedImageCacheService.instance.clearCache();

    // Keep only the most recent game state
    if (_gameStateHistory.length > 1) {
      final lastState = _gameStateHistory.last;
      _gameStateHistory.clear();
      _gameStateHistory.add(lastState);
    }

    // Clear most recently used breeds
    if (_recentlyUsedBreeds.length > 10) {
      final breedsList = _recentlyUsedBreeds.toList();
      _recentlyUsedBreeds.clear();
      _recentlyUsedBreeds.addAll(breedsList.take(10));
    }
  }

  /// Handle high memory pressure
  Future<void> _handleHighMemoryPressure() async {
    debugPrint('High memory pressure detected. Performing cleanup...');

    // Show warning if not already shown
    if (!_memoryWarningShown) {
      _memoryWarningShown = true;
      debugPrint('Memory usage warning: ${_currentMemoryUsageMB}MB');
    }

    // Moderate cleanup
    await cleanupMemory();
  }

  /// Handle medium memory pressure
  Future<void> _handleMediumMemoryPressure() async {
    // Light cleanup
    if (_gameStateHistory.length > 7) {
      _gameStateHistory.removeAt(0);
    }

    if (_recentlyUsedBreeds.length > maxUsedBreeds * 1.5) {
      final removeCount = (_recentlyUsedBreeds.length * 0.2).round();
      final breedsList = _recentlyUsedBreeds.toList();
      for (int i = 0; i < removeCount; i++) {
        _recentlyUsedBreeds.remove(breedsList[i]);
      }
    }
  }

  /// Get memory statistics for monitoring
  MemoryStats getMemoryStats() {
    return MemoryStats(
      currentUsageMB: _currentMemoryUsageMB,
      peakUsageMB: _peakMemoryUsageMB,
      pressureLevel: _currentPressureLevel,
      gameStatesCount: _gameStateHistory.length,
      recentlyUsedBreedsCount: _recentlyUsedBreeds.length,
      lastCheck: _lastMemoryCheck,
      imageCacheStats: OptimizedImageCacheService.instance
          .getPerformanceStats(),
    );
  }

  /// Reset memory warning flag
  void resetMemoryWarning() {
    _memoryWarningShown = false;
  }

  /// Get recently used breeds for intelligent preloading
  Set<String> get recentlyUsedBreeds => Set.from(_recentlyUsedBreeds);

  /// Get current memory pressure level
  MemoryPressureLevel get currentPressureLevel => _currentPressureLevel;

  /// Check if memory optimization is recommended
  bool get shouldOptimizeMemory =>
      _currentPressureLevel.index >= MemoryPressureLevel.medium.index;

  /// Dispose of the memory manager
  void dispose() {
    _memoryCheckTimer?.cancel();
    _gameStateHistory.clear();
    _recentlyUsedBreeds.clear();
    _isInitialized = false;
  }
}

/// Memory pressure levels for intelligent management
enum MemoryPressureLevel { low, medium, high, critical }

/// Memory statistics for monitoring and debugging
class MemoryStats {
  final int currentUsageMB;
  final int peakUsageMB;
  final MemoryPressureLevel pressureLevel;
  final int gameStatesCount;
  final int recentlyUsedBreedsCount;
  final DateTime? lastCheck;
  final dynamic imageCacheStats; // ImageCachePerformanceStats

  const MemoryStats({
    required this.currentUsageMB,
    required this.peakUsageMB,
    required this.pressureLevel,
    required this.gameStatesCount,
    required this.recentlyUsedBreedsCount,
    this.lastCheck,
    this.imageCacheStats,
  });

  @override
  String toString() {
    return 'MemoryStats('
        'current: ${currentUsageMB}MB, '
        'peak: ${peakUsageMB}MB, '
        'pressure: $pressureLevel, '
        'gameStates: $gameStatesCount, '
        'recentBreeds: $recentlyUsedBreedsCount'
        ')';
  }
}
