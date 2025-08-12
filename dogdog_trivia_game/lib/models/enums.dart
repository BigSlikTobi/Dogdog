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

/// Enum representing question categories for the new localized format
enum QuestionCategory {
  dogTraining('Dog Training'),
  dogBreeds('Dog Breeds'),
  dogBehavior('Dog Behavior'),
  dogHealth('Dog Health'),
  dogHistory('Dog History');

  const QuestionCategory(this.displayName);
  final String displayName;

  /// Returns the localized name for the category
  String getLocalizedName(String locale) {
    switch (this) {
      case QuestionCategory.dogTraining:
        switch (locale) {
          case 'de':
            return 'Hundetraining';
          case 'es':
            return 'Entrenamiento Canino';
          default:
            return 'Dog Training';
        }
      case QuestionCategory.dogBreeds:
        switch (locale) {
          case 'de':
            return 'Hunderassen';
          case 'es':
            return 'Razas de Perros';
          default:
            return 'Dog Breeds';
        }
      case QuestionCategory.dogBehavior:
        switch (locale) {
          case 'de':
            return 'Hundeverhalten';
          case 'es':
            return 'Comportamiento Canino';
          default:
            return 'Dog Behavior';
        }
      case QuestionCategory.dogHealth:
        switch (locale) {
          case 'de':
            return 'Hundegesundheit';
          case 'es':
            return 'Salud Canina';
          default:
            return 'Dog Health';
        }
      case QuestionCategory.dogHistory:
        switch (locale) {
          case 'de':
            return 'Hundegeschichte';
          case 'es':
            return 'Historia Canina';
          default:
            return 'Dog History';
        }
    }
  }

  /// Returns the category from a string value
  static QuestionCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'dog training':
      case 'hundetraining':
      case 'entrenamiento canino':
        return QuestionCategory.dogTraining;
      case 'dog behavior':
      case 'hundeverhalten':
      case 'comportamiento canino':
        return QuestionCategory.dogBehavior;
      case 'dog health':
      case 'hundegesundheit':
      case 'salud canina':
        return QuestionCategory.dogHealth;
      case 'dog history':
      case 'hundegeschichte':
      case 'historia canina':
        return QuestionCategory.dogHistory;
      case 'dog breeds':
      case 'hunderassen':
      case 'razas de perros':
      default:
        return QuestionCategory.dogBreeds;
    }
  }
}

/// Enum representing different themed learning paths in the treasure map system
enum PathType {
  dogTrivia,
  puppyQuest;

  /// Returns the display name for the path
  String get displayName {
    switch (this) {
      case PathType.dogTrivia:
        return 'Dog Trivia';
      case PathType.puppyQuest:
        return 'Puppy Quest';
    }
  }

  /// Returns the description for the path
  String get description {
    switch (this) {
      case PathType.dogTrivia:
        return 'Learn about different dog breeds, their characteristics, and origins';
      case PathType.puppyQuest:
        return 'Test your knowledge by identifying dog breeds from photos';
    }
  }
}

/// Enum representing checkpoints in the treasure map progression
enum Checkpoint {
  chihuahua(10, 'Chihuahua', 'assets/images/chihuahua.png'),
  pug(15, 'Pug', 'assets/images/mops.png'),
  cockerSpaniel(25, 'Cocker Spaniel', 'assets/images/cocker.png'),
  germanShepherd(35, 'German Shepherd', 'assets/images/schaeferhund.png'),
  greatDane(45, 'Great Dane', 'assets/images/dogge.png'),
  deutscheDogge(60, 'Deutsche Dogge', 'assets/images/dogge.png');

  const Checkpoint(this.questionsRequired, this.displayName, this.imagePath);

  /// Number of questions required to reach this checkpoint
  final int questionsRequired;

  /// Display name for the checkpoint
  final String displayName;

  /// Path to the image asset for this checkpoint
  final String imagePath;
}
