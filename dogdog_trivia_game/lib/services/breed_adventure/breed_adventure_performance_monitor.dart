import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Performance monitoring service for breed adventure with frame rate tracking
class BreedAdventurePerformanceMonitor {
  static BreedAdventurePerformanceMonitor? _instance;
  static BreedAdventurePerformanceMonitor get instance =>
      _instance ??= BreedAdventurePerformanceMonitor._();

  BreedAdventurePerformanceMonitor._();

  // Performance targets
  static const double targetFPS = 60.0;
  static const double minAcceptableFPS = 45.0;
  static const Duration performanceCheckInterval = Duration(seconds: 5);
  static const int maxSampleSize = 100;

  // Frame rate tracking
  final List<double> _fpsHistory = [];
  final List<Duration> _frameTimeHistory = [];
  DateTime? _lastFrameTime;
  double _currentFPS = 0.0;
  double _averageFPS = 0.0;
  int _droppedFrameCount = 0;
  int _totalFrameCount = 0;

  // Performance events tracking
  final List<PerformanceEvent> _performanceEvents = [];
  Timer? _performanceTimer;
  bool _isMonitoring = false;

  // Animation performance tracking
  final Map<String, AnimationPerformanceData> _animationPerformance = {};

  // Memory and resource tracking
  int _imageLoadCount = 0;
  int _slowImageLoadCount = 0;
  final List<Duration> _imageLoadTimes = [];

  /// Initialize performance monitoring
  Future<void> initialize() async {
    if (_isMonitoring) return;

    // Start frame rate monitoring
    _startFrameRateMonitoring();

    // Start periodic performance analysis
    _startPerformanceAnalysis();

    _isMonitoring = true;
    debugPrint(
      'BreedAdventurePerformanceMonitor initialized - target FPS: $targetFPS',
    );
  }

  /// Start monitoring frame rate using Flutter's scheduler
  void _startFrameRateMonitoring() {
    SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
      _onFrameUpdate(timeStamp);
    });
  }

  /// Handle frame update for FPS calculation
  void _onFrameUpdate(Duration timeStamp) {
    if (!_isMonitoring) return;

    final now = DateTime.now();

    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!);
      _frameTimeHistory.add(frameDuration);

      // Keep only recent samples
      if (_frameTimeHistory.length > maxSampleSize) {
        _frameTimeHistory.removeAt(0);
      }

      // Calculate current FPS
      final frameTimeMs = frameDuration.inMicroseconds / 1000.0;
      _currentFPS = frameTimeMs > 0 ? 1000.0 / frameTimeMs : 0.0;

      _fpsHistory.add(_currentFPS);
      if (_fpsHistory.length > maxSampleSize) {
        _fpsHistory.removeAt(0);
      }

      // Track dropped frames
      if (_currentFPS < minAcceptableFPS) {
        _droppedFrameCount++;
      }

      _totalFrameCount++;

      // Calculate average FPS
      if (_fpsHistory.isNotEmpty) {
        _averageFPS = _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;
      }
    }

    _lastFrameTime = now;
  }

  /// Start periodic performance analysis
  void _startPerformanceAnalysis() {
    _performanceTimer = Timer.periodic(performanceCheckInterval, (_) {
      _analyzePerformance();
    });
  }

  /// Analyze current performance and record events
  void _analyzePerformance() {
    if (_fpsHistory.isEmpty) return;

    final now = DateTime.now();
    final minFPS = _fpsHistory.reduce(math.min);
    final maxFPS = _fpsHistory.reduce(math.max);
    final droppedFrameRate = _totalFrameCount > 0
        ? _droppedFrameCount / _totalFrameCount
        : 0.0;

    // Record performance event
    final event = PerformanceEvent(
      timestamp: now,
      averageFPS: _averageFPS,
      minFPS: minFPS,
      maxFPS: maxFPS,
      droppedFrameRate: droppedFrameRate,
      totalFrames: _totalFrameCount,
      droppedFrames: _droppedFrameCount,
    );

    _performanceEvents.add(event);
    if (_performanceEvents.length > 50) {
      // Keep last 50 events
      _performanceEvents.removeAt(0);
    }

    // Log performance warnings
    if (_averageFPS < minAcceptableFPS) {
      debugPrint(
        'Performance warning: Average FPS ${_averageFPS.toStringAsFixed(1)} below target',
      );
    }

    if (droppedFrameRate > 0.1) {
      // More than 10% dropped frames
      debugPrint(
        'Performance warning: ${(droppedFrameRate * 100).toStringAsFixed(1)}% dropped frames',
      );
    }
  }

  /// Track animation performance
  void trackAnimationStart(
    String animationName,
    AnimationController controller,
  ) {
    if (!_isMonitoring) return;

    final data = AnimationPerformanceData(
      name: animationName,
      startTime: DateTime.now(),
      controller: controller,
    );

    _animationPerformance[animationName] = data;

    // Add listener to track completion
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _trackAnimationEnd(animationName);
      }
    });
  }

  /// Track animation completion
  void _trackAnimationEnd(String animationName) {
    final data = _animationPerformance[animationName];
    if (data == null) return;

    final endTime = DateTime.now();
    final duration = endTime.difference(data.startTime);

    data.endTime = endTime;
    data.totalDuration = duration;

    // Check for performance issues
    if (duration > const Duration(milliseconds: 1000)) {
      debugPrint(
        'Animation performance warning: $animationName took ${duration.inMilliseconds}ms',
      );
    }
  }

  /// Track image loading performance
  void trackImageLoadStart(String imageUrl) {
    if (!_isMonitoring) return;
    _imageLoadCount++;
  }

  /// Track image loading completion
  void trackImageLoadEnd(String imageUrl, Duration loadTime) {
    if (!_isMonitoring) return;

    _imageLoadTimes.add(loadTime);
    if (_imageLoadTimes.length > maxSampleSize) {
      _imageLoadTimes.removeAt(0);
    }

    // Track slow loads (>2 seconds)
    if (loadTime.inMilliseconds > 2000) {
      _slowImageLoadCount++;
      debugPrint(
        'Slow image load detected: $imageUrl took ${loadTime.inMilliseconds}ms',
      );
    }
  }

  /// Get current performance statistics
  PerformanceStats getPerformanceStats() {
    double averageImageLoadTime = 0;
    if (_imageLoadTimes.isNotEmpty) {
      final totalMs = _imageLoadTimes.fold<int>(
        0,
        (sum, duration) => sum + duration.inMilliseconds,
      );
      averageImageLoadTime = totalMs / _imageLoadTimes.length;
    }

    return PerformanceStats(
      currentFPS: _currentFPS,
      averageFPS: _averageFPS,
      minFPS: _fpsHistory.isNotEmpty ? _fpsHistory.reduce(math.min) : 0.0,
      maxFPS: _fpsHistory.isNotEmpty ? _fpsHistory.reduce(math.max) : 0.0,
      droppedFrameCount: _droppedFrameCount,
      totalFrameCount: _totalFrameCount,
      droppedFrameRate: _totalFrameCount > 0
          ? _droppedFrameCount / _totalFrameCount
          : 0.0,
      imageLoadCount: _imageLoadCount,
      slowImageLoadCount: _slowImageLoadCount,
      averageImageLoadTimeMs: averageImageLoadTime,
      activeAnimations: _animationPerformance.length,
      isPerformingWell: _averageFPS >= minAcceptableFPS,
      performanceEvents: List.from(_performanceEvents),
    );
  }

  /// Get detailed animation performance data
  Map<String, AnimationPerformanceData> getAnimationPerformance() {
    return Map.from(_animationPerformance);
  }

  /// Check if performance is currently good
  bool get isPerformingWell {
    return _averageFPS >= minAcceptableFPS &&
        (_totalFrameCount == 0 || _droppedFrameCount / _totalFrameCount < 0.1);
  }

  /// Get performance recommendations
  List<String> getPerformanceRecommendations() {
    final recommendations = <String>[];

    if (_averageFPS < minAcceptableFPS) {
      recommendations.add('Consider reducing animation complexity or duration');
      recommendations.add(
        'Check for memory pressure that might be affecting performance',
      );
    }

    if (_droppedFrameCount > 0 && _totalFrameCount > 0) {
      final droppedRate = _droppedFrameCount / _totalFrameCount;
      if (droppedRate > 0.1) {
        recommendations.add(
          '${(droppedRate * 100).toStringAsFixed(1)}% frames dropped - consider performance optimization',
        );
      }
    }

    if (_slowImageLoadCount > 0) {
      recommendations.add(
        '$_slowImageLoadCount slow image loads detected - consider image optimization',
      );
    }

    final activeAnimationCount = _animationPerformance.values
        .where((data) => data.endTime == null)
        .length;

    if (activeAnimationCount > 5) {
      recommendations.add(
        '$activeAnimationCount active animations - consider reducing concurrent animations',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add('Performance is good - no optimizations needed');
    }

    return recommendations;
  }

  /// Reset performance tracking data
  void resetStats() {
    _fpsHistory.clear();
    _frameTimeHistory.clear();
    _performanceEvents.clear();
    _animationPerformance.clear();
    _imageLoadTimes.clear();

    _droppedFrameCount = 0;
    _totalFrameCount = 0;
    _imageLoadCount = 0;
    _slowImageLoadCount = 0;
    _currentFPS = 0.0;
    _averageFPS = 0.0;

    debugPrint('Performance stats reset');
  }

  /// Dispose of the performance monitor
  void dispose() {
    _performanceTimer?.cancel();
    _animationPerformance.clear();
    _isMonitoring = false;
  }
}

/// Performance event data structure
class PerformanceEvent {
  final DateTime timestamp;
  final double averageFPS;
  final double minFPS;
  final double maxFPS;
  final double droppedFrameRate;
  final int totalFrames;
  final int droppedFrames;

  const PerformanceEvent({
    required this.timestamp,
    required this.averageFPS,
    required this.minFPS,
    required this.maxFPS,
    required this.droppedFrameRate,
    required this.totalFrames,
    required this.droppedFrames,
  });

  @override
  String toString() {
    return 'PerformanceEvent(${timestamp.toIso8601String()}: '
        'avgFPS=${averageFPS.toStringAsFixed(1)}, '
        'range: ${minFPS.toStringAsFixed(1)}-${maxFPS.toStringAsFixed(1)}, '
        'dropped: ${(droppedFrameRate * 100).toStringAsFixed(1)}%)';
  }
}

/// Animation performance tracking data
class AnimationPerformanceData {
  final String name;
  final DateTime startTime;
  final AnimationController controller;
  DateTime? endTime;
  Duration? totalDuration;

  AnimationPerformanceData({
    required this.name,
    required this.startTime,
    required this.controller,
    this.endTime,
    this.totalDuration,
  });

  bool get isCompleted => endTime != null;

  Duration get currentDuration =>
      endTime?.difference(startTime) ?? DateTime.now().difference(startTime);

  @override
  String toString() {
    return 'AnimationPerformanceData($name: '
        '${isCompleted ? "completed" : "running"} '
        '${currentDuration.inMilliseconds}ms)';
  }
}

/// Comprehensive performance statistics
class PerformanceStats {
  final double currentFPS;
  final double averageFPS;
  final double minFPS;
  final double maxFPS;
  final int droppedFrameCount;
  final int totalFrameCount;
  final double droppedFrameRate;
  final int imageLoadCount;
  final int slowImageLoadCount;
  final double averageImageLoadTimeMs;
  final int activeAnimations;
  final bool isPerformingWell;
  final List<PerformanceEvent> performanceEvents;

  const PerformanceStats({
    required this.currentFPS,
    required this.averageFPS,
    required this.minFPS,
    required this.maxFPS,
    required this.droppedFrameCount,
    required this.totalFrameCount,
    required this.droppedFrameRate,
    required this.imageLoadCount,
    required this.slowImageLoadCount,
    required this.averageImageLoadTimeMs,
    required this.activeAnimations,
    required this.isPerformingWell,
    required this.performanceEvents,
  });

  @override
  String toString() {
    return 'PerformanceStats('
        'FPS: ${currentFPS.toStringAsFixed(1)} (avg: ${averageFPS.toStringAsFixed(1)}, '
        'range: ${minFPS.toStringAsFixed(1)}-${maxFPS.toStringAsFixed(1)}), '
        'dropped: $droppedFrameCount/$totalFrameCount (${(droppedFrameRate * 100).toStringAsFixed(1)}%), '
        'images: $imageLoadCount (slow: $slowImageLoadCount, avg: ${averageImageLoadTimeMs.toStringAsFixed(1)}ms), '
        'animations: $activeAnimations, '
        'status: ${isPerformingWell ? "GOOD" : "POOR"}'
        ')';
  }
}
