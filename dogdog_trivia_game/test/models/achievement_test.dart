import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/models/achievement.dart';
import 'package:dogdog_trivia_game/models/enums.dart';
import 'package:dogdog_trivia_game/utils/enum_extensions.dart';
import '../helpers/test_helper.dart';

void main() {
  group('Achievement', () {
    late Achievement testAchievement;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15);
      testAchievement = Achievement(
        id: 'test_achievement',
        name: 'Test Achievement',
        description: 'A test achievement',
        iconPath: 'assets/test.png',
        requiredCorrectAnswers: 50,
        isUnlocked: true,
        unlockedDate: testDate,
        rank: Rank.cockerSpaniel,
      );
    });

    test('should create Achievement with all fields', () {
      expect(testAchievement.id, 'test_achievement');
      expect(testAchievement.name, 'Test Achievement');
      expect(testAchievement.description, 'A test achievement');
      expect(testAchievement.iconPath, 'assets/test.png');
      expect(testAchievement.requiredCorrectAnswers, 50);
      expect(testAchievement.isUnlocked, true);
      expect(testAchievement.unlockedDate, testDate);
      expect(testAchievement.rank, Rank.cockerSpaniel);
    });

    testWidgets('should create Achievement from Rank', (tester) async {
      await tester.pumpWidget(
        TestHelper.createTestApp(
          Builder(
            builder: (context) {
              final achievement = Achievement.fromRank(Rank.pug);

              expect(achievement.id, 'rank_pug');
              expect(achievement.name, Rank.pug.displayName(context));
              expect(achievement.description, Rank.pug.description(context));
              expect(achievement.iconPath, 'assets/icons/ranks/pug.png');
              expect(
                achievement.requiredCorrectAnswers,
                Rank.pug.requiredCorrectAnswers,
              );
              expect(achievement.isUnlocked, false);
              expect(achievement.unlockedDate, isNull);
              expect(achievement.rank, Rank.pug);

              return Container();
            },
          ),
          locale: const Locale('de'),
        ),
      );
    });

    test('should create unlocked Achievement from Rank', () {
      final unlockedDate = DateTime.now();
      final achievement = Achievement.fromRank(
        Rank.germanShepherd,
        isUnlocked: true,
        unlockedDate: unlockedDate,
      );

      expect(achievement.isUnlocked, true);
      expect(achievement.unlockedDate, unlockedDate);
    });

    group('progress calculation', () {
      test('should return 1.0 progress when unlocked', () {
        expect(testAchievement.getProgress(25), 1.0);
        expect(testAchievement.getProgress(100), 1.0);
      });

      test('should calculate correct progress when not unlocked', () {
        final lockedAchievement = testAchievement.copyWith(isUnlocked: false);

        expect(lockedAchievement.getProgress(0), 0.0);
        expect(lockedAchievement.getProgress(25), 0.5);
        expect(lockedAchievement.getProgress(50), 1.0);
        expect(lockedAchievement.getProgress(75), 1.0); // Clamped to 1.0
      });

      test('should handle negative progress values', () {
        final lockedAchievement = testAchievement.copyWith(isUnlocked: false);
        expect(lockedAchievement.getProgress(-10), 0.0); // Clamped to 0.0
      });
    });

    group('unlock detection', () {
      test('should detect when achievement should be unlocked', () {
        final lockedAchievement = testAchievement.copyWith(isUnlocked: false);

        expect(lockedAchievement.shouldUnlock(49), false);
        expect(lockedAchievement.shouldUnlock(50), true);
        expect(lockedAchievement.shouldUnlock(75), true);
      });

      test('should not unlock already unlocked achievement', () {
        expect(testAchievement.shouldUnlock(100), false);
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final json = testAchievement.toJson();

        expect(json['id'], 'test_achievement');
        expect(json['name'], 'Test Achievement');
        expect(json['description'], 'A test achievement');
        expect(json['iconPath'], 'assets/test.png');
        expect(json['requiredCorrectAnswers'], 50);
        expect(json['isUnlocked'], true);
        expect(json['unlockedDate'], testDate.toIso8601String());
        expect(json['rank'], 'cockerSpaniel');
      });

      test('should serialize null unlockedDate correctly', () {
        final achievementWithoutDate = Achievement(
          id: 'test_no_date',
          name: 'Test Achievement',
          description: 'A test achievement',
          iconPath: 'assets/test.png',
          requiredCorrectAnswers: 50,
          isUnlocked: false,
          unlockedDate: null,
          rank: Rank.cockerSpaniel,
        );
        final json = achievementWithoutDate.toJson();

        expect(json['unlockedDate'], isNull);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'test_2',
          'name': 'Another Achievement',
          'description': 'Another test achievement',
          'iconPath': 'assets/test2.png',
          'requiredCorrectAnswers': 25,
          'isUnlocked': false,
          'unlockedDate': null,
          'rank': 'pug',
        };

        final achievement = Achievement.fromJson(json);

        expect(achievement.id, 'test_2');
        expect(achievement.name, 'Another Achievement');
        expect(achievement.description, 'Another test achievement');
        expect(achievement.iconPath, 'assets/test2.png');
        expect(achievement.requiredCorrectAnswers, 25);
        expect(achievement.isUnlocked, false);
        expect(achievement.unlockedDate, isNull);
        expect(achievement.rank, Rank.pug);
      });

      test('should handle invalid rank gracefully', () {
        final json = {
          'id': 'test_3',
          'name': 'Test',
          'description': 'Test',
          'iconPath': 'test.png',
          'requiredCorrectAnswers': 10,
          'isUnlocked': false,
          'unlockedDate': null,
          'rank': 'invalid_rank',
        };

        final achievement = Achievement.fromJson(json);
        expect(achievement.rank, Rank.chihuahua); // Should default to chihuahua
      });

      test('should serialize and deserialize JSON string correctly', () {
        final jsonString = testAchievement.toJsonString();
        final deserializedAchievement = Achievement.fromJsonString(jsonString);

        expect(deserializedAchievement, equals(testAchievement));
      });
    });

    group('copyWith', () {
      test('should create copy with modified fields', () {
        final modifiedAchievement = testAchievement.copyWith(
          name: 'Modified Achievement',
          isUnlocked: false,
        );

        expect(modifiedAchievement.name, 'Modified Achievement');
        expect(modifiedAchievement.isUnlocked, false);
        expect(modifiedAchievement.id, testAchievement.id); // Unchanged
        expect(
          modifiedAchievement.description,
          testAchievement.description,
        ); // Unchanged
      });

      test('should create identical copy when no parameters provided', () {
        final copiedAchievement = testAchievement.copyWith();
        expect(copiedAchievement, equals(testAchievement));
      });
    });

    group('unlock method', () {
      test('should create unlocked version with current timestamp', () {
        final lockedAchievement = testAchievement.copyWith(
          isUnlocked: false,
          unlockedDate: null,
        );

        final beforeUnlock = DateTime.now();
        final unlockedAchievement = lockedAchievement.unlock();
        final afterUnlock = DateTime.now();

        expect(unlockedAchievement.isUnlocked, true);
        expect(unlockedAchievement.unlockedDate, isNotNull);
        expect(
          unlockedAchievement.unlockedDate!.isAfter(beforeUnlock) ||
              unlockedAchievement.unlockedDate!.isAtSameMomentAs(beforeUnlock),
          true,
        );
        expect(
          unlockedAchievement.unlockedDate!.isBefore(afterUnlock) ||
              unlockedAchievement.unlockedDate!.isAtSameMomentAs(afterUnlock),
          true,
        );
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all fields match', () {
        final achievement1 = testAchievement;
        final achievement2 = testAchievement.copyWith();

        expect(achievement1, equals(achievement2));
        expect(achievement1.hashCode, equals(achievement2.hashCode));
      });

      test('should not be equal when fields differ', () {
        final achievement1 = testAchievement;
        final achievement2 = testAchievement.copyWith(name: 'Different Name');

        expect(achievement1, isNot(equals(achievement2)));
      });
    });

    test('should have meaningful toString', () {
      final string = testAchievement.toString();
      expect(string, contains('test_achievement'));
      expect(string, contains('Test Achievement'));
      expect(string, contains('cockerSpaniel'));
      expect(string, contains('unlocked: true'));
    });
  });
}
