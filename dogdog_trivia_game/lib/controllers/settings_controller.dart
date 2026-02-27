import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller for managing app settings including language and user name
class SettingsController extends ChangeNotifier {
  static const String _languageKey = 'language_code';
  static const String _userNameKey = 'user_name';
  
  Locale? _locale;
  String? _userName;
  bool _initialized = false;

  /// Current locale, null means system default
  Locale? get locale => _locale;

  /// User's name
  String? get userName => _userName;

  /// Whether settings have been loaded
  bool get initialized => _initialized;

  /// Initialize and load settings
  Future<void> initialize() async {
    if (_initialized) return;
    
    await _loadSettings();
    _initialized = true;
    notifyListeners();
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode != null) {
        _locale = Locale(languageCode);
      }
      
      _userName = prefs.getString(_userNameKey);
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  /// Set the app language
  Future<void> setLocale(Locale? locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale != null) {
        await prefs.setString(_languageKey, locale.languageCode);
      } else {
        await prefs.remove(_languageKey);
      }
    } catch (e) {
      debugPrint('Error saving language setting: $e');
    }
  }

  /// Set the user's name
  Future<void> setUserName(String? name) async {
    if (_userName == name) return;

    _userName = name;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (name != null && name.isNotEmpty) {
        await prefs.setString(_userNameKey, name);
      } else {
        await prefs.remove(_userNameKey);
      }
    } catch (e) {
      debugPrint('Error saving user name: $e');
    }
  }

  /// Check if the current language is creating a specific locale (e.g. 'de')
  bool isLanguageSelected(String languageCode) {
    return _locale?.languageCode == languageCode;
  }
}
