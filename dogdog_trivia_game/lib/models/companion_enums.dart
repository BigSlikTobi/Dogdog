/// Enum representing the emotional state of the companion dog
enum CompanionMood {
  happy,
  curious,
  sleepy,
  excited;

  /// Returns the display emoji for this mood
  String get emoji {
    switch (this) {
      case CompanionMood.happy:
        return '😊';
      case CompanionMood.curious:
        return '🧐';
      case CompanionMood.sleepy:
        return '😴';
      case CompanionMood.excited:
        return '🎉';
    }
  }

  /// Returns the animation trigger for this mood
  String get animationKey {
    switch (this) {
      case CompanionMood.happy:
        return 'tail_wag';
      case CompanionMood.curious:
        return 'head_tilt';
      case CompanionMood.sleepy:
        return 'yawn';
      case CompanionMood.excited:
        return 'zoomies';
    }
  }
}

/// Enum representing the growth stage of the companion
enum GrowthStage {
  puppy(0.0, 0.25),
  adolescent(0.25, 0.50),
  adult(0.50, 0.75),
  elder(0.75, 1.0);

  const GrowthStage(this.minBond, this.maxBond);

  /// Minimum bond level required for this stage
  final double minBond;

  /// Maximum bond level for this stage
  final double maxBond;

  /// Returns the display name for this stage
  String get displayName {
    switch (this) {
      case GrowthStage.puppy:
        return 'Puppy';
      case GrowthStage.adolescent:
        return 'Adolescent';
      case GrowthStage.adult:
        return 'Adult';
      case GrowthStage.elder:
        return 'Elder';
    }
  }

  /// Returns the emoji for this stage
  String get emoji {
    switch (this) {
      case GrowthStage.puppy:
        return '🐶';
      case GrowthStage.adolescent:
        return '🐕';
      case GrowthStage.adult:
        return '🦮';
      case GrowthStage.elder:
        return '👑';
    }
  }

  /// Gets the growth stage for a given bond level
  static GrowthStage fromBondLevel(double bondLevel) {
    if (bondLevel < 0.25) return GrowthStage.puppy;
    if (bondLevel < 0.50) return GrowthStage.adolescent;
    if (bondLevel < 0.75) return GrowthStage.adult;
    return GrowthStage.elder;
  }
}

/// Enum representing available companion breeds.
///
/// Intentionally limited to three visually distinct breeds so each one has
/// a fully polished procedural skeleton renderer.  All breeds are available
/// from the puppy stage — progression is expressed through bond level, not
/// breed gating.
enum CompanionBreed {
  goldenRetriever(GrowthStage.puppy, 1, 'Golden Retriever'),
  germanShepherd(GrowthStage.puppy, 1, 'German Shepherd'),
  dachshund(GrowthStage.puppy, 1, 'Dachshund');

  const CompanionBreed(this.requiredStage, this.difficulty, this.displayName);

  /// The growth stage required to unlock this breed
  final GrowthStage requiredStage;

  /// Difficulty level (1 = easy, 4 = rare)
  final int difficulty;

  /// Display name of the breed
  final String displayName;

  /// Returns the asset path for this breed's image
  String get imagePath => 'assets/images/breeds/${name.toLowerCase()}.png';

  /// Returns breeds available at a given growth stage
  static List<CompanionBreed> availableAt(GrowthStage stage) {
    return values.where((b) => b.requiredStage.index <= stage.index).toList();
  }

  /// Returns the emoji for this breed (used as fallback only)
  String get emoji {
    switch (this) {
      case CompanionBreed.goldenRetriever: return '🦮';
      case CompanionBreed.germanShepherd: return '🐕';
      case CompanionBreed.dachshund: return '🐾';
    }
  }
}

/// Enum representing world map areas
enum WorldArea {
  home('Your Home', 'Tutorial area', GrowthStage.puppy),
  barkPark('Bark Park', 'Common Breeds', GrowthStage.puppy),
  vetClinic('Vet Clinic', 'Health & Anatomy', GrowthStage.adolescent),
  dogShowArena('Dog Show Arena', 'Rare Breeds', GrowthStage.adolescent),
  adventureTrails('Adventure Trails', 'Fun Facts', GrowthStage.adult),
  beachCove('Beach Cove', 'Water Dogs', GrowthStage.adult),
  mysteryIsland('Mystery Island', 'Expert Trivia', GrowthStage.elder);

  const WorldArea(this.displayName, this.description, this.requiredStage);

  final String displayName;
  final String description;
  final GrowthStage requiredStage;

  /// Returns the emoji for this area
  String get emoji {
    switch (this) {
      case WorldArea.home:
        return '🏠';
      case WorldArea.barkPark:
        return '🌳';
      case WorldArea.vetClinic:
        return '🏥';
      case WorldArea.dogShowArena:
        return '🎪';
      case WorldArea.adventureTrails:
        return '🏔️';
      case WorldArea.beachCove:
        return '🌊';
      case WorldArea.mysteryIsland:
        return '🔒';
    }
  }

  /// Check if area is unlocked for given growth stage
  bool isUnlockedFor(GrowthStage stage) => requiredStage.index <= stage.index;
}
