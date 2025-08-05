import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/models/player_progress.dart';
import 'package:dogdog_trivia_game/models/achievement.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('PlayerProgress', () {
    late PlayerProgress testProgress;
    late DateTime testDate;
    late List<Achievement> testAchievements;

    setUp(() {
      testDate = DateTime(2024, 1, 15);
      testAchievements = [
        Achievement.fromRank(
          Rank.chihuahua,
          isUnlocked: true,
          unlockedDate: testDate,
        ),
        Achievement.fromRank(
          Rank.pug,
          isUnlocked: true,
          unlockedDate: testDate,
        ),
        Achievement.fromRank(Rank.cockerSpaniel),
        Achievement.fromRank(Rank.germanShepherd),
        Achievement.fromRank(Rank.greatDane),
      ];

      testProgress = PlayerProgress(
        totalCorrectAnswers: 30,
        totalQuestionsAnswered: 45,
        totalGamesPlayed: 10,
        totalScore: 500,
        currentRank: Rank.pug,
        achievements: testAchievements,
        unlockedContent: {'theme_blue': true, 'avatar_dog1': true},
        dailyChallengeStreak: 3,
        lastPlayDate: testDate,
        lastDailyChallengeDate: testDate.subtract(const Duration(days: 1)),
        highestLevel: 3,
        longestStreak: 8,
      );
    });

    test('should create PlayerProgress with all fields', () {
      expect(testProgress.totalCorrectAnswers, 30);
      expect(testProgress.totalQuestionsAnswered, 45);
      expect(testProgress.totalGamesPlayed, 10);
      expect(testProgress.totalScore, 500);
      expect(testProgress.currentRank, Rank.pug);
      expect(testProgress.achievements.length, 5);
      expect(testProgress.unlockedContent.length, 2);
      expect(testProgress.dailyChallengeStreak, 3);
      expect(testProgress.lastPlayDate, testDate);
      expect(
        testProgress.lastDailyChallengeDate,
        testDate.subtract(const Duration(days: 1)),
      );
      expect(testProgress.highestLevel, 3);
      expect(testProgress.longestStreak, 8);
    });

    test('should create initial PlayerProgress correctly', () {
      final initialProgress = PlayerProgress.initial();

      expect(initialProgress.totalCorrectAnswers, 0);
      expect(initialProgress.totalQuestionsAnswered, 0);
      expect(initialProgress.totalGamesPlayed, 0);
      expect(initialProgress.totalScore, 0);
      expect(initialProgress.currentRank, Rank.chihuahua);
      expect(initialProgress.achievements.length, Rank.values.length);
      expect(initialProgress.unlockedContent, isEmpty);
      expect(initialProgress.dailyChallengeStreak, 0);
      expect(initialProgress.lastDailyChallengeDate, isNull);
      expect(initialProgress.highestLevel, 1);
      expect(initialProgress.longestStreak, 0);
    });

    group('computed properties', () {
      test('should calculate accuracy correctly', () {
        expect(testProgress.accuracy, closeTo(30 / 45, 0.001));

        final noQuestionsProgress = testProgress.copyWith(
          totalQuestionsAnswered: 0,
          totalCorrectAnswers: 0,
        );
        expect(noQuestionsProgress.accuracy, 0.0);
      });

      test('should calculate average score correctly', () {
        expect(testProgress.averageScore, closeTo(500 / 10, 0.001));

        final noGamesProgress = testProgress.copyWith(
          totalGamesPlayed: 0,
          totalScore: 0,
        );
        expect(noGamesProgress.averageScore, 0.0);
      });

      test('should return correct next rank', () {
        expect(testProgress.nextRank, Rank.cockerSpaniel);

        final maxRankProgress = testProgress.copyWith(
          currentRank: Rank.greatDane,
          totalCorrectAnswers: 100, // Ensure all ranks are achieved
        );
        expect(maxRankProgress.nextRank, isNull);
      });

      test('should calculate progress to next rank correctly', () {
        // Current: Pug (25), Next: Cocker Spaniel (50)
        // Progress: (30 - 25) / (50 - 25) = 5/25 = 0.2
        expect(testProgress.progressToNextRank, closeTo(0.2, 0.001));

        final maxRankProgress = testProgress.copyWith(
          currentRank: Rank.greatDane,
          totalCorrectAnswers: 100, // Ensure all ranks are achieved
        );
        expect(maxRankProgress.progressToNextRank, 1.0);
      });

      test('should filter unlocked achievements correctly', () {
        final unlocked = testProgress.unlockedAchievements;
        expect(unlocked.length, 2);
        expect(unlocked.every((a) => a.isUnlocked), true);
      });

      test('should filter locked achievements correctly', () {
        final locked = testProgress.lockedAchievements;
        expect(locked.length, 3);
        expect(locked.every((a) => !a.isUnlocked), true);
      });
    });

    group('rank checking', () {
      test('should check if rank is unlocked correctly', () {
        expect(testProgress.isRankUnlocked(Rank.chihuahua), true); // 30 >= 10
        expect(testProgress.isRankUnlocked(Rank.pug), true); // 30 >= 25
        expect(
          testProgress.isRankUnlocked(Rank.cockerSpaniel),
          false,
        ); // 30 < 50
        expect(
          testProgress.isRankUnlocked(Rank.germanShepherd),
          false,
        ); // 30 < 75
        expect(testProgress.isRankUnlocked(Rank.greatDane), false); // 30 < 100
      });

      test('should calculate current rank correctly', () {
        expect(testProgress.calculateCurrentRank(), Rank.pug);

        final lowProgress = testProgress.copyWith(totalCorrectAnswers: 5);
        expect(lowProgress.calculateCurrentRank(), Rank.chihuahua);

        final highProgress = testProgress.copyWith(totalCorrectAnswers: 150);
        expect(highProgress.calculateCurrentRank(), Rank.greatDane);
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final json = testProgress.toJson();

        expect(json['totalCorrectAnswers'], 30);
        expect(json['totalQuestionsAnswered'], 45);
        expect(json['totalGamesPlayed'], 10);
        expect(json['totalScore'], 500);
        expect(json['currentRank'], 'pug');
        expect(json['achievements'], hasLength(5));
        expect(json['unlockedContent'], isA<Map<String, bool>>());
        expect(json['dailyChallengeStreak'], 3);
        expect(json['lastPlayDate'], testDate.toIso8601String());
        expect(
          json['lastDailyChallengeDate'],
          testDate.subtract(const Duration(days: 1)).toIso8601String(),
        );
        expect(json['highestLevel'], 3);
        expect(json['longestStreak'], 8);
      });

      test('should serialize null lastDailyChallengeDate correctly', () {
        final progressWithoutDate = PlayerProgress(
          totalCorrectAnswers: 30,
          totalQuestionsAnswered: 45,
          totalGamesPlayed: 10,
          totalScore: 500,
          currentRank: Rank.pug,
          achievements: testAchievements,
          unlockedContent: {'theme_blue': true, 'avatar_dog1': true},
          dailyChallengeStreak: 3,
          lastPlayDate: testDate,
          lastDailyChallengeDate: null,
          highestLevel: 3,
          longestStreak: 8,
        );
        final json = progressWithoutDate.toJson();

        expect(json['lastDailyChallengeDate'], isNull);
      });

      test('should deserialize from JSON correctly', () {
        final json = testProgress.toJson();
        final deserializedProgress = PlayerProgress.fromJson(json);

        expect(
          deserializedProgress.totalCorrectAnswers,
          testProgress.totalCorrectAnswers,
        );
        expect(
          deserializedProgress.totalQuestionsAnswered,
          testProgress.totalQuestionsAnswered,
        );
        expect(
          deserializedProgress.totalGamesPlayed,
          testProgress.totalGamesPlayed,
        );
        expect(deserializedProgress.totalScore, testProgress.totalScore);
        expect(deserializedProgress.currentRank, testProgress.currentRank);
        expect(
          deserializedProgress.achievements.length,
          testProgress.achievements.length,
        );
        expect(
          deserializedProgress.dailyChallengeStreak,
          testProgress.dailyChallengeStreak,
        );
        expect(deserializedProgress.lastPlayDate, testProgress.lastPlayDate);
        expect(
          deserializedProgress.lastDailyChallengeDate,
          testProgress.lastDailyChallengeDate,
        );
        expect(deserializedProgress.highestLevel, testProgress.highestLevel);
        expect(deserializedProgress.longestStreak, testProgress.longestStreak);
      });

      test('should handle missing optional fields in JSON', () {
        final json = {
          'totalCorrectAnswers': 20,
          'totalQuestionsAnswered': 30,
          'totalGamesPlayed': 5,
          'totalScore': 250,
          'currentRank': 'chihuahua',
          'achievements': [],
          'unlockedContent': {},
          'dailyChallengeStreak': 1,
          'lastPlayDate': testDate.toIso8601String(),
          'lastDailyChallengeDate': null,
          // Missing optional fields
        };

        final progress = PlayerProgress.fromJson(json);
        expect(progress.highestLevel, 1);
        expect(progress.longestStreak, 0);
      });

      test('should handle invalid rank gracefully', () {
        final json = {
          'totalCorrectAnswers': 20,
          'totalQuestionsAnswered': 30,
          'totalGamesPlayed': 5,
          'totalScore': 250,
          'currentRank': 'invalid_rank',
          'achievements': [],
          'unlockedContent': {},
          'dailyChallengeStreak': 1,
          'lastPlayDate': testDate.toIso8601String(),
          'lastDailyChallengeDate': null,
        };

        final progress = PlayerProgress.fromJson(json);
        expect(
          progress.currentRank,
          Rank.chihuahua,
        ); // Should default to chihuahua
      });

      test('should serialize and deserialize JSON string correctly', () {
        final jsonString = testProgress.toJsonString();
        final deserializedProgress = PlayerProgress.fromJsonString(jsonString);

        expect(
          deserializedProgress.totalCorrectAnswers,
          testProgress.totalCorrectAnswers,
        );
        expect(deserializedProgress.currentRank, testProgress.currentRank);
        expect(deserializedProgress.totalScore, testProgress.totalScore);
      });
    });

    group('copyWith', () {
      test('should create copy with modified fields', () {
        final modifiedProgress = testProgress.copyWith(
          totalCorrectAnswers: 60,
          currentRank: Rank.cockerSpaniel,
          totalScore: 1000,
        );

        expect(modifiedProgress.totalCorrectAnswers, 60);
        expect(modifiedProgress.currentRank, Rank.cockerSpaniel);
        expect(modifiedProgress.totalScore, 1000);
        expect(
          modifiedProgress.totalQuestionsAnswered,
          testProgress.totalQuestionsAnswered,
        ); // Unchanged
        expect(
          modifiedProgress.totalGamesPlayed,
          testProgress.totalGamesPlayed,
        ); // Unchanged
      });

      test('should create identical copy when no parameters provided', () {
        final copiedProgress = testProgress.copyWith();
        expect(
          copiedProgress.totalCorrectAnswers,
          testProgress.totalCorrectAnswers,
        );
        expect(copiedProgress.currentRank, testProgress.currentRank);
        expect(copiedProgress.totalScore, testProgress.totalScore);
      });
    });

    group('equality and hashCode', () {
      test('should be equal when key fields match', () {
        final progress1 = testProgress;
        final progress2 = testProgress.copyWith();

        expect(progress1 == progress2, true);
        expect(progress1.hashCode, equals(progress2.hashCode));
      });

      test('should not be equal when fields differ', () {
        final progress1 = testProgress;
        final progress2 = testProgress.copyWith(totalScore: 999);

        expect(progress1 == progress2, false);
      });
    });

    test('should have meaningful toString', () {
      final string = testProgress.toString();
      expect(string, contains('rank: ${Rank.pug}'));
      expect(string, contains('correct: 30'));
      expect(string, contains('games: 10'));
      expect(string, contains('score: 500'));
    });
  });
}
