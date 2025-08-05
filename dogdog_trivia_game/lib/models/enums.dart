/// Enum representing different difficulty levels in the game
enum Difficulty {
  easy,
  medium,
  hard,
  expert;

  /// Returns the points awarded for correct answers at this difficulty
  int get points {
    switch (this) {
      case Difficulty.easy:
        return 10;
      case Difficulty.medium:
        return 15;
      case Difficulty.hard:
        return 20;
      case Difficulty.expert:
        return 25;
    }
  }
}

/// Enum representing different types of power-ups available in the game
enum PowerUpType { fiftyFifty, hint, extraTime, skip, secondChance }

/// Enum representing different ranks/achievements in the game
enum Rank {
  chihuahua,
  pug,
  cockerSpaniel,
  germanShepherd,
  greatDane;

  /// Returns the number of correct answers required to achieve this rank
  int get requiredCorrectAnswers {
    switch (this) {
      case Rank.chihuahua:
        return 10;
      case Rank.pug:
        return 25;
      case Rank.cockerSpaniel:
        return 50;
      case Rank.germanShepherd:
        return 75;
      case Rank.greatDane:
        return 100;
    }
  }
}

/// Enum representing possible game results
enum GameResult { win, lose, quit }

/// Enum representing different types of errors that can occur
enum ErrorType {
  network,
  storage,
  audio,
  gameLogic,
  ui,
  unknown;

  /// Returns the display name for the error type
  String get displayName {
    switch (this) {
      case ErrorType.network:
        return 'Network Error';
      case ErrorType.storage:
        return 'Storage Error';
      case ErrorType.audio:
        return 'Audio Error';
      case ErrorType.gameLogic:
        return 'Game Logic Error';
      case ErrorType.ui:
        return 'Display Error';
      case ErrorType.unknown:
        return 'Unknown Error';
    }
  }
}

/// Enum representing error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical;

  /// Returns the display name for the error severity
  String get displayName {
    switch (this) {
      case ErrorSeverity.low:
        return 'Low';
      case ErrorSeverity.medium:
        return 'Medium';
      case ErrorSeverity.high:
        return 'High';
      case ErrorSeverity.critical:
        return 'Critical';
    }
  }
}
