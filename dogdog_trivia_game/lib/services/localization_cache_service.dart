import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../l10n/generated/app_localizations.dart';

/// Cached string with metadata
class _CachedString {
  final String value;
  final DateTime cachedAt;
  final int accessCount;

  const _CachedString(this.value, this.cachedAt, this.accessCount);

  _CachedString copyWithAccess() {
    return _CachedString(value, cachedAt, accessCount + 1);
  }

  bool get isExpired {
    return DateTime.now().difference(cachedAt) >
        LocalizationCacheService.cacheExpiration;
  }
}

/// High-performance localization cache service for optimized string lookup
class LocalizationCacheService {
  static LocalizationCacheService? _instance;
  static LocalizationCacheService get instance =>
      _instance ??= LocalizationCacheService._();

  LocalizationCacheService._();

  // Cache configuration
  static const int maxCacheSize = 500; // Maximum cached strings
  static const Duration cacheExpiration = Duration(minutes: 30);

  // Cache state
  final Map<String, _CachedString> _stringCache = {};
  final List<String> _accessOrder = []; // LRU tracking
  String? _currentLocale;

  /// Get the current locale
  String get currentLocale => _currentLocale ?? 'de';

  /// Initialize with current locale
  void initialize(String locale) {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      _stringCache.clear(); // Clear cache when locale changes
      _accessOrder.clear();
      if (kDebugMode) {
        if (kDebugMode) {
          print('LocalizationCacheService initialized for locale: $locale');
        }
      }
    }
  }

  /// Get cached localized string with fallback
  String getCachedString(
    BuildContext context,
    String key,
    String Function(AppLocalizations) getter, [
    String fallback = '',
  ]) {
    final cacheKey = '${_currentLocale}_$key';

    // Check cache first
    final cached = _stringCache[cacheKey];
    if (cached != null && !cached.isExpired) {
      _updateAccess(cacheKey);
      return cached.value;
    }

    // Get from localization and cache
    try {
      final l10n = AppLocalizations.of(context);
      final value = getter(l10n);
      _cacheString(cacheKey, value);
      return value;
    } catch (e) {
      if (kDebugMode) print('Failed to get localized string for key $key: $e');
    }

    return fallback;
  }

  /// Cache a string value
  void _cacheString(String key, String value) {
    _stringCache[key] = _CachedString(value, DateTime.now(), 1);
    _updateAccess(key);
    _performCacheManagement();
  }

  /// Update access tracking for LRU
  void _updateAccess(String key) {
    _accessOrder.remove(key);
    _accessOrder.add(key);

    // Update access count
    final cached = _stringCache[key];
    if (cached != null) {
      _stringCache[key] = cached.copyWithAccess();
    }
  }

  /// Perform cache size management
  void _performCacheManagement() {
    if (_stringCache.length <= maxCacheSize) {
      return;
    }

    // Remove expired entries first
    _removeExpiredEntries();

    // If still over limit, remove least recently used
    if (_stringCache.length > maxCacheSize) {
      _removeLRUEntries();
    }
  }

  /// Remove expired cache entries
  void _removeExpiredEntries() {
    final expiredKeys = <String>[];

    for (final entry in _stringCache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _stringCache.remove(key);
      _accessOrder.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      if (kDebugMode) {
        print(
          'Removed ${expiredKeys.length} expired localization cache entries',
        );
      }
    }
  }

  /// Remove least recently used entries
  void _removeLRUEntries() {
    final excessCount = _stringCache.length - maxCacheSize;
    final keysToRemove = _accessOrder.take(excessCount).toList();

    for (final key in keysToRemove) {
      _stringCache.remove(key);
      _accessOrder.remove(key);
    }

    if (kDebugMode) {
      print('Removed $excessCount LRU localization cache entries');
    }
  }

  /// Preload commonly used strings
  void preloadCommonStrings(BuildContext context) {
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context);

    // Preload frequently used strings
    final commonStrings = {
      'homeScreen_startButton': () => l10n.homeScreen_startButton,
      'gameScreen_score': () => l10n.gameScreen_score,
      'gameScreen_lives': () => l10n.gameScreen_lives,
      'gameScreen_loading': () => l10n.gameScreen_loading,
      'treasureMap_congratulations': () => l10n.treasureMap_congratulations,
      'treasureMap_completionMessage': () => l10n.treasureMap_completionMessage,
      'treasureMap_continueExploring': () => l10n.treasureMap_continueExploring,
      'category_dogBreeds': () => l10n.category_dogBreeds,
      'category_dogTraining': () => l10n.category_dogTraining,
      'category_dogBehavior': () => l10n.category_dogBehavior,
      'category_dogHealth': () => l10n.category_dogHealth,
      'category_dogHistory': () => l10n.category_dogHistory,
      'difficulty_easy': () => l10n.difficulty_easy,
      'difficulty_medium': () => l10n.difficulty_medium,
      'difficulty_hard': () => l10n.difficulty_hard,
    };

    for (final entry in commonStrings.entries) {
      try {
        final value = entry.value();
        final cacheKey = '${_currentLocale}_${entry.key}';
        _cacheString(cacheKey, value);
      } catch (e) {
        if (kDebugMode) print('Failed to preload string ${entry.key}: $e');
      }
    }

    if (kDebugMode) {
      print('Preloaded ${commonStrings.length} common localization strings');
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStatistics() {
    var expiredCount = 0;
    var totalAccessCount = 0;

    for (final cached in _stringCache.values) {
      if (cached.isExpired) expiredCount++;
      totalAccessCount += cached.accessCount;
    }

    return {
      'cachedStringsCount': _stringCache.length,
      'maxCacheSize': maxCacheSize,
      'currentLocale': _currentLocale,
      'expiredEntriesCount': expiredCount,
      'totalAccessCount': totalAccessCount,
      'averageAccessCount': _stringCache.isNotEmpty
          ? (totalAccessCount / _stringCache.length).round()
          : 0,
      'memoryUsageApproxKB': _estimateMemoryUsage(),
    };
  }

  /// Estimate memory usage in KB
  int _estimateMemoryUsage() {
    var totalChars = 0;
    for (final cached in _stringCache.values) {
      totalChars += cached.value.length;
    }
    // Rough estimate: 2 bytes per character + overhead
    return (totalChars * 2 / 1024).round();
  }

  /// Clear all caches
  void clearCache() {
    _stringCache.clear();
    _accessOrder.clear();
    if (kDebugMode) print('Cleared localization cache');
  }

  /// Get most accessed strings for optimization insights
  List<String> getMostAccessedStrings({int limit = 10}) {
    final entries = _stringCache.entries.toList()
      ..sort((a, b) => b.value.accessCount.compareTo(a.value.accessCount));

    return entries.take(limit).map((e) => e.key).toList();
  }

  /// Warm up cache with predicted strings based on context
  void warmUpCacheForContext(BuildContext context, String contextType) {
    if (!context.mounted) return;

    switch (contextType) {
      case 'game':
        _warmUpGameStrings(context);
        break;
      case 'treasureMap':
        _warmUpTreasureMapStrings(context);
        break;
      case 'categories':
        _warmUpCategoryStrings(context);
        break;
      case 'settings':
        _warmUpSettingsStrings(context);
        break;
      default:
        preloadCommonStrings(context);
    }
  }

  void _warmUpGameStrings(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final gameStrings = {
      'gameScreen_timeRemaining': () => l10n.gameScreen_timeRemaining,
      'gameScreen_questionCounter': () =>
          l10n.gameScreen_questionCounter(1, 10),
    };

    _cacheStringMap(gameStrings);
  }

  void _warmUpTreasureMapStrings(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final treasureMapStrings = {
      'treasureMap_pathCompleted': () => l10n.treasureMap_pathCompleted,
      'treasureMap_startAdventure': () => l10n.treasureMap_startAdventure,
      'treasureMap_continueAdventure': () => l10n.treasureMap_continueAdventure,
    };

    _cacheStringMap(treasureMapStrings);
  }

  void _warmUpCategoryStrings(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final categoryStrings = {
      'difficulty_easy_description': () => l10n.difficulty_easy_description,
      'difficulty_medium_description': () => l10n.difficulty_medium_description,
      'difficulty_hard_description': () => l10n.difficulty_hard_description,
    };

    _cacheStringMap(categoryStrings);
  }

  void _warmUpSettingsStrings(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final settingsStrings = {
      'appTitle': () => l10n.appTitle,
      'homeScreen_welcomeTitle': () => l10n.homeScreen_welcomeTitle,
    };

    _cacheStringMap(settingsStrings);
  }

  void _cacheStringMap(Map<String, String Function()> stringMap) {
    for (final entry in stringMap.entries) {
      try {
        final value = entry.value();
        final cacheKey = '${_currentLocale}_${entry.key}';
        _cacheString(cacheKey, value);
      } catch (e) {
        if (kDebugMode) print('Failed to cache string ${entry.key}: $e');
      }
    }
  }
}
