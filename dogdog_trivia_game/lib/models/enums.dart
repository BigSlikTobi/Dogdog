/// Enum representing different difficulty levels in the game
enum Difficulty {
  easy,
  medium,
  hard,
  expert;

  /// Returns the German display name for the difficulty
  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Leicht';
      case Difficulty.medium:
        return 'Mittel';
      case Difficulty.hard:
        return 'Schwer';
      case Difficulty.expert:
        return 'Experte';
    }
  }

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
enum PowerUpType {
  fiftyFifty,
  hint,
  extraTime,
  skip,
  secondChance;

  /// Returns the German display name for the power-up
  String get displayName {
    switch (this) {
      case PowerUpType.fiftyFifty:
        return 'Chew 50/50';
      case PowerUpType.hint:
        return 'Hinweis';
      case PowerUpType.extraTime:
        return 'Extra Zeit';
      case PowerUpType.skip:
        return 'Überspringen';
      case PowerUpType.secondChance:
        return 'Zweite Chance';
    }
  }

  /// Returns the description for the power-up
  String get description {
    switch (this) {
      case PowerUpType.fiftyFifty:
        return 'Entfernt zwei falsche Antworten';
      case PowerUpType.hint:
        return 'Zeigt einen Hinweis zur richtigen Antwort';
      case PowerUpType.extraTime:
        return 'Fügt 10 Sekunden zur aktuellen Frage hinzu';
      case PowerUpType.skip:
        return 'Springt zur nächsten Frage ohne Strafe';
      case PowerUpType.secondChance:
        return 'Stellt ein verlorenes Leben wieder her';
    }
  }
}

/// Enum representing different ranks/achievements in the game
enum Rank {
  chihuahua,
  pug,
  cockerSpaniel,
  germanShepherd,
  greatDane;

  /// Returns the German display name for the rank
  String get displayName {
    switch (this) {
      case Rank.chihuahua:
        return 'Chihuahua';
      case Rank.pug:
        return 'Mops';
      case Rank.cockerSpaniel:
        return 'Cocker Spaniel';
      case Rank.germanShepherd:
        return 'Deutscher Schäferhund';
      case Rank.greatDane:
        return 'Deutsche Dogge';
    }
  }

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

  /// Returns the description for the rank
  String get description {
    switch (this) {
      case Rank.chihuahua:
        return 'Kleiner Anfang - Du hast deine ersten 10 Fragen richtig beantwortet!';
      case Rank.pug:
        return 'Guter Fortschritt - 25 richtige Antworten erreicht!';
      case Rank.cockerSpaniel:
        return 'Halbzeit-Held - 50 richtige Antworten gemeistert!';
      case Rank.germanShepherd:
        return 'Treuer Begleiter - 75 richtige Antworten geschafft!';
      case Rank.greatDane:
        return 'Großer Meister - 100 richtige Antworten erreicht!';
    }
  }
}

/// Enum representing possible game results
enum GameResult {
  win,
  lose,
  quit;

  /// Returns the German display name for the game result
  String get displayName {
    switch (this) {
      case GameResult.win:
        return 'Gewonnen';
      case GameResult.lose:
        return 'Verloren';
      case GameResult.quit:
        return 'Beendet';
    }
  }
}

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
