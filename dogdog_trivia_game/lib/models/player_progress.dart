import 'dart:convert';
import 'achievement.dart';
import 'enums.dart';

/// Model representing the player's overall progress and statistics
class PlayerProgress {
  final int totalCorrectAnswers;
  final int totalQuestionsAnswered;
  final int totalGamesPlayed;
  final int totalScore;
  final Rank currentRank;
  final List<Achievement> achievements;
  final Map<String, bool> unlockedContent;
  final int dailyChallengeStreak;
  final DateTime lastPlayDate;
  final DateTime? lastDailyChallengeDate;
  final int highestLevel;
  final int longestStreak;

  const PlayerProgress({
    required this.totalCorrectAnswers,
    required this.totalQuestionsAnswered,
    required this.totalGamesPlayed,
    required this.totalScore,
    required this.currentRank,
    required this.achievements,
    required this.unlockedContent,
    required this.dailyChallengeStreak,
    required this.lastPlayDate,
    this.lastDailyChallengeDate,
    this.highestLevel = 1,
    this.longestStreak = 0,
  });

  /// Creates an initial PlayerProgress for a new player
  factory PlayerProgress.initial() {
    final achievements = Rank.values
        .map((rank) => Achievement.fromRank(rank))
        .toList();

    // Create initial progress with 0 correct answers
    final initialProgress = PlayerProgress(
      totalCorrectAnswers: 0,
      totalQuestionsAnswered: 0,
      totalGamesPlayed: 0,
      totalScore: 0,
      currentRank: Rank.chihuahua, // Temporary, will be calculated
      achievements: achievements,
      unlockedContent: {},
      dailyChallengeStreak: 0,
      lastPlayDate: DateTime.now(),
      lastDailyChallengeDate: null,
      highestLevel: 1,
      longestStreak: 0,
    );

    // Calculate the actual current rank based on correct answers (0)
    final actualRank = initialProgress.calculateCurrentRank();

    return initialProgress.copyWith(currentRank: actualRank);
  }

  /// Returns the accuracy percentage (0.0 to 1.0)
  double get accuracy {
    if (totalQuestionsAnswered == 0) return 0.0;
    return totalCorrectAnswers / totalQuestionsAnswered;
  }

  /// Returns the average score per game
  double get averageScore {
    if (totalGamesPlayed == 0) return 0.0;
    return totalScore / totalGamesPlayed;
  }

  /// Returns the next rank to achieve, or null if at max rank
  Rank? get nextRank {
    // Find the next rank that hasn't been achieved yet
    for (final rank in Rank.values) {
      if (totalCorrectAnswers < rank.requiredCorrectAnswers) {
        return rank;
      }
    }
    return null; // All ranks achieved
  }

  /// Returns the progress towards the next rank (0.0 to 1.0)
  double get progressToNextRank {
    final next = nextRank;
    if (next == null) return 1.0; // All ranks achieved

    // Find the previous rank (or 0 if working towards first rank)
    int previousRequired = 0;
    for (final rank in Rank.values) {
      if (rank == next) break;
      if (totalCorrectAnswers >= rank.requiredCorrectAnswers) {
        previousRequired = rank.requiredCorrectAnswers;
      }
    }

    final nextRequired = next.requiredCorrectAnswers;
    final progress = totalCorrectAnswers - previousRequired;
    final total = nextRequired - previousRequired;

    return (progress / total).clamp(0.0, 1.0);
  }

  /// Returns all unlocked achievements
  List<Achievement> get unlockedAchievements {
    return achievements.where((achievement) => achievement.isUnlocked).toList();
  }

  /// Returns all locked achievements
  List<Achievement> get lockedAchievements {
    return achievements
        .where((achievement) => !achievement.isUnlocked)
        .toList();
  }

  /// Checks if a specific rank is unlocked
  bool isRankUnlocked(Rank rank) {
    return totalCorrectAnswers >= rank.requiredCorrectAnswers;
  }

  /// Returns the current rank based on total correct answers
  Rank calculateCurrentRank() {
    for (int i = Rank.values.length - 1; i >= 0; i--) {
      final rank = Rank.values[i];
      if (totalCorrectAnswers >= rank.requiredCorrectAnswers) {
        return rank;
      }
    }
    // If no rank is achieved, return the lowest rank but mark it as not achieved
    // This is handled by the achievement system
    return Rank.chihuahua;
  }

  /// Creates a PlayerProgress from a JSON map
  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    return PlayerProgress(
      totalCorrectAnswers: json['totalCorrectAnswers'] as int,
      totalQuestionsAnswered: json['totalQuestionsAnswered'] as int,
      totalGamesPlayed: json['totalGamesPlayed'] as int,
      totalScore: json['totalScore'] as int,
      currentRank: Rank.values.firstWhere(
        (r) => r.name == json['currentRank'],
        orElse: () => Rank.chihuahua,
      ),
      achievements: (json['achievements'] as List)
          .map((a) => Achievement.fromJson(a as Map<String, dynamic>))
          .toList(),
      unlockedContent: Map<String, bool>.from(json['unlockedContent'] as Map),
      dailyChallengeStreak: json['dailyChallengeStreak'] as int,
      lastPlayDate: DateTime.parse(json['lastPlayDate'] as String),
      lastDailyChallengeDate: json['lastDailyChallengeDate'] != null
          ? DateTime.parse(json['lastDailyChallengeDate'] as String)
          : null,
      highestLevel: json['highestLevel'] as int? ?? 1,
      longestStreak: json['longestStreak'] as int? ?? 0,
    );
  }

  /// Converts the PlayerProgress to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'totalCorrectAnswers': totalCorrectAnswers,
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'totalGamesPlayed': totalGamesPlayed,
      'totalScore': totalScore,
      'currentRank': currentRank.name,
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'unlockedContent': unlockedContent,
      'dailyChallengeStreak': dailyChallengeStreak,
      'lastPlayDate': lastPlayDate.toIso8601String(),
      'lastDailyChallengeDate': lastDailyChallengeDate?.toIso8601String(),
      'highestLevel': highestLevel,
      'longestStreak': longestStreak,
    };
  }

  /// Creates a PlayerProgress from a JSON string
  factory PlayerProgress.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return PlayerProgress.fromJson(json);
  }

  /// Converts the PlayerProgress to a JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Creates a copy of this PlayerProgress with optional parameter overrides
  PlayerProgress copyWith({
    int? totalCorrectAnswers,
    int? totalQuestionsAnswered,
    int? totalGamesPlayed,
    int? totalScore,
    Rank? currentRank,
    List<Achievement>? achievements,
    Map<String, bool>? unlockedContent,
    int? dailyChallengeStreak,
    DateTime? lastPlayDate,
    DateTime? lastDailyChallengeDate,
    int? highestLevel,
    int? longestStreak,
  }) {
    return PlayerProgress(
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalQuestionsAnswered:
          totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalScore: totalScore ?? this.totalScore,
      currentRank: currentRank ?? this.currentRank,
      achievements: achievements ?? this.achievements,
      unlockedContent: unlockedContent ?? this.unlockedContent,
      dailyChallengeStreak: dailyChallengeStreak ?? this.dailyChallengeStreak,
      lastPlayDate: lastPlayDate ?? this.lastPlayDate,
      lastDailyChallengeDate:
          lastDailyChallengeDate ?? this.lastDailyChallengeDate,
      highestLevel: highestLevel ?? this.highestLevel,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PlayerProgress) return false;
    return totalCorrectAnswers == other.totalCorrectAnswers &&
        totalQuestionsAnswered == other.totalQuestionsAnswered &&
        totalGamesPlayed == other.totalGamesPlayed &&
        totalScore == other.totalScore &&
        currentRank == other.currentRank &&
        achievements.length == other.achievements.length &&
        unlockedContent.length == other.unlockedContent.length &&
        dailyChallengeStreak == other.dailyChallengeStreak &&
        lastPlayDate == other.lastPlayDate &&
        lastDailyChallengeDate == other.lastDailyChallengeDate &&
        highestLevel == other.highestLevel &&
        longestStreak == other.longestStreak;
  }

  @override
  int get hashCode {
    return Object.hash(
      totalCorrectAnswers,
      totalQuestionsAnswered,
      totalGamesPlayed,
      totalScore,
      currentRank,
      achievements.length,
      unlockedContent.length,
      dailyChallengeStreak,
      lastPlayDate,
      lastDailyChallengeDate,
      highestLevel,
      longestStreak,
    );
  }

  @override
  String toString() {
    return 'PlayerProgress(rank: $currentRank, correct: $totalCorrectAnswers, '
        'games: $totalGamesPlayed, score: $totalScore)';
  }
}
