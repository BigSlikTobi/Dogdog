import 'dart:convert';
import 'enums.dart';

/// Model representing an achievement that can be unlocked by the player
class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final int requiredCorrectAnswers;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final Rank rank;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.requiredCorrectAnswers,
    required this.isUnlocked,
    required this.rank,
    this.unlockedDate,
  });

  /// Creates an Achievement from a Rank
  factory Achievement.fromRank(
    Rank rank, {
    bool isUnlocked = false,
    DateTime? unlockedDate,
  }) {
    return Achievement(
      id: 'rank_${rank.name}',
      name: rank.displayName,
      description: rank.description,
      iconPath: 'assets/icons/ranks/${rank.name}.png',
      requiredCorrectAnswers: rank.requiredCorrectAnswers,
      isUnlocked: isUnlocked,
      unlockedDate: unlockedDate,
      rank: rank,
    );
  }

  /// Returns the progress percentage towards unlocking this achievement
  double getProgress(int currentCorrectAnswers) {
    if (isUnlocked) return 1.0;
    return (currentCorrectAnswers / requiredCorrectAnswers).clamp(0.0, 1.0);
  }

  /// Returns true if this achievement should be unlocked based on current progress
  bool shouldUnlock(int currentCorrectAnswers) {
    return !isUnlocked && currentCorrectAnswers >= requiredCorrectAnswers;
  }

  /// Creates an Achievement from a JSON map
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconPath: json['iconPath'] as String,
      requiredCorrectAnswers: json['requiredCorrectAnswers'] as int,
      isUnlocked: json['isUnlocked'] as bool,
      unlockedDate: json['unlockedDate'] != null
          ? DateTime.parse(json['unlockedDate'] as String)
          : null,
      rank: Rank.values.firstWhere(
        (r) => r.name == json['rank'],
        orElse: () => Rank.chihuahua,
      ),
    );
  }

  /// Converts the Achievement to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'requiredCorrectAnswers': requiredCorrectAnswers,
      'isUnlocked': isUnlocked,
      'unlockedDate': unlockedDate?.toIso8601String(),
      'rank': rank.name,
    };
  }

  /// Creates an Achievement from a JSON string
  factory Achievement.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return Achievement.fromJson(json);
  }

  /// Converts the Achievement to a JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Creates a copy of this Achievement with optional parameter overrides
  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? iconPath,
    int? requiredCorrectAnswers,
    bool? isUnlocked,
    DateTime? unlockedDate,
    Rank? rank,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      requiredCorrectAnswers:
          requiredCorrectAnswers ?? this.requiredCorrectAnswers,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      rank: rank ?? this.rank,
    );
  }

  /// Creates a new Achievement with unlocked status
  Achievement unlock() {
    return copyWith(isUnlocked: true, unlockedDate: DateTime.now());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Achievement) return false;
    return id == other.id &&
        name == other.name &&
        description == other.description &&
        iconPath == other.iconPath &&
        requiredCorrectAnswers == other.requiredCorrectAnswers &&
        isUnlocked == other.isUnlocked &&
        unlockedDate == other.unlockedDate &&
        rank == other.rank;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      iconPath,
      requiredCorrectAnswers,
      isUnlocked,
      unlockedDate,
      rank,
    );
  }

  @override
  String toString() {
    return 'Achievement(id: $id, name: $name, rank: $rank, unlocked: $isUnlocked)';
  }
}
