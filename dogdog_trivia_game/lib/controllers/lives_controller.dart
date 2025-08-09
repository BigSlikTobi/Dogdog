import 'package:flutter/foundation.dart';

/// Controls lives state independently of the game UI.
/// Max lives are fixed to 3 as per requirements.
class LivesController extends ChangeNotifier {
  int _currentLives;
  final int _maxLives;

  LivesController({int initialLives = 3, int maxLives = 3})
    : _currentLives = initialLives.clamp(0, maxLives),
      _maxLives = maxLives;

  int get currentLives => _currentLives;
  int get maxLives => _maxLives;
  bool get isGameOver => _currentLives <= 0;

  void setLives(int value) {
    final newValue = value.clamp(0, _maxLives);
    if (newValue != _currentLives) {
      _currentLives = newValue;
      notifyListeners();
    }
  }

  void loseLife() {
    if (_currentLives > 0) {
      _currentLives--;
      notifyListeners();
    }
  }

  void restoreLife() {
    if (_currentLives < _maxLives) {
      _currentLives++;
      notifyListeners();
    }
  }

  void resetLives() {
    setLives(_maxLives);
  }
}
