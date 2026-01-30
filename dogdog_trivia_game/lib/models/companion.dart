import 'companion_enums.dart';

/// Model representing the player's companion dog
class Companion {
  /// Unique identifier for the companion
  final String id;

  /// Player-given name for the companion
  final String name;

  /// The breed of this companion
  final CompanionBreed breed;

  /// Bond level from 0.0 to 1.0
  final double bondLevel;

  /// Current emotional state
  final CompanionMood mood;

  /// Total correct answers (used for bond calculation)
  final int totalCorrectAnswers;

  /// Unlocked accessories
  final List<String> accessories;

  /// Currently equipped accessory
  final String? equippedAccessory;

  /// When this companion was adopted
  final DateTime adoptedAt;

  /// Hunger level from 0.0 (starving) to 1.0 (full)
  final double hunger;

  /// Currency earned from trivia, used to buy food
  final int treats;

  /// Last time the companion was fed
  final DateTime lastFedAt;

  /// Last interaction time
  final DateTime lastInteractionAt;

  const Companion({
    required this.id,
    required this.name,
    required this.breed,
    this.bondLevel = 0.0,
    this.mood = CompanionMood.happy,
    this.totalCorrectAnswers = 0,
    this.accessories = const [],
    this.equippedAccessory,
    required this.adoptedAt,
    required this.lastInteractionAt,
    this.hunger = 0.5,
    this.treats = 5,
    required this.lastFedAt,
  });

  /// Get the current growth stage based on bond level
  GrowthStage get stage => GrowthStage.fromBondLevel(bondLevel);

  /// Check if companion missed the player (idle for > 1 day)
  bool get missedPlayer {
    final hoursSinceLastInteraction =
        DateTime.now().difference(lastInteractionAt).inHours;
    return hoursSinceLastInteraction > 24;
  }

  /// Get time since last interaction in friendly format
  String get timeSinceLastVisit {
    final diff = DateTime.now().difference(lastInteractionAt);
    if (diff.inDays > 0) return '${diff.inDays} day(s)';
    if (diff.inHours > 0) return '${diff.inHours} hour(s)';
    return 'just now';
  }

  /// Creates a copy with updated fields
  Companion copyWith({
    String? id,
    String? name,
    CompanionBreed? breed,
    double? bondLevel,
    CompanionMood? mood,
    int? totalCorrectAnswers,
    List<String>? accessories,
    String? equippedAccessory,
    DateTime? adoptedAt,
    DateTime? lastInteractionAt,
    double? hunger,
    int? treats,
    DateTime? lastFedAt,
  }) {
    return Companion(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      bondLevel: (bondLevel ?? this.bondLevel).clamp(0.0, 1.0),
      mood: mood ?? this.mood,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      accessories: accessories ?? this.accessories,
      equippedAccessory: equippedAccessory ?? this.equippedAccessory,
      adoptedAt: adoptedAt ?? this.adoptedAt,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      hunger: (hunger ?? this.hunger).clamp(0.0, 1.0),
      treats: treats ?? this.treats,
      lastFedAt: lastFedAt ?? this.lastFedAt,
    );
  }

  /// Add bond from correct answers
  Companion addBond(double amount) {
    return copyWith(
      bondLevel: bondLevel + amount,
      totalCorrectAnswers: totalCorrectAnswers + 1,
      lastInteractionAt: DateTime.now(),
      treats: treats + 1, // Earn a treat for correct answer!
    );
  }

  /// Update mood
  Companion withMood(CompanionMood newMood) {
    return copyWith(mood: newMood, lastInteractionAt: DateTime.now());
  }

  /// Creates from JSON
  factory Companion.fromJson(Map<String, dynamic> json) {
    return Companion(
      id: json['id'] as String,
      name: json['name'] as String,
      breed: CompanionBreed.values.firstWhere(
        (b) => b.name == json['breed'],
        orElse: () => CompanionBreed.labrador,
      ),
      bondLevel: (json['bondLevel'] as num?)?.toDouble() ?? 0.0,
      mood: CompanionMood.values.firstWhere(
        (m) => m.name == json['mood'],
        orElse: () => CompanionMood.happy,
      ),
      totalCorrectAnswers: json['totalCorrectAnswers'] as int? ?? 0,
      accessories:
          (json['accessories'] as List<dynamic>?)?.cast<String>() ?? [],
      equippedAccessory: json['equippedAccessory'] as String?,
      adoptedAt:
          DateTime.parse(json['adoptedAt'] as String? ?? DateTime.now().toIso8601String()),
      lastInteractionAt:
          DateTime.parse(json['lastInteractionAt'] as String? ?? DateTime.now().toIso8601String()),
      hunger: (json['hunger'] as num?)?.toDouble() ?? 0.5,
      treats: json['treats'] as int? ?? 5,
      lastFedAt:
          DateTime.parse(json['lastFedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'breed': breed.name,
      'bondLevel': bondLevel,
      'mood': mood.name,
      'totalCorrectAnswers': totalCorrectAnswers,
      'accessories': accessories,
      'equippedAccessory': equippedAccessory,
      'adoptedAt': adoptedAt.toIso8601String(),
      'lastInteractionAt': lastInteractionAt.toIso8601String(),
      'hunger': hunger,
      'treats': treats,
      'lastFedAt': lastFedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Companion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Companion(name: $name, breed: ${breed.displayName}, stage: ${stage.displayName}, bond: ${(bondLevel * 100).toStringAsFixed(1)}%)';
  }
}
