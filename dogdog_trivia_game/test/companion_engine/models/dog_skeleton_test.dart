import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dogdog_trivia_game/companion_engine/models/dog_skeleton.dart';
import 'package:dogdog_trivia_game/companion_engine/models/breed_skeleton_config.dart';
import 'package:dogdog_trivia_game/companion_engine/models/skeleton_configs/skeleton_config_factory.dart';
import 'package:dogdog_trivia_game/models/companion_enums.dart';

void main() {
  group('CompanionBreed enum', () {
    test('has exactly 3 breeds', () {
      expect(CompanionBreed.values.length, 3);
    });

    test('contains goldenRetriever, germanShepherd, dachshund', () {
      final names = CompanionBreed.values.map((b) => b.name).toSet();
      expect(names, containsAll(['goldenRetriever', 'germanShepherd', 'dachshund']));
    });
  });

  group('DogSkeleton contract', () {
    for (final breed in CompanionBreed.values) {
      test('SkeletonConfigFactory provides config for $breed', () {
        final config = SkeletonConfigFactory.forBreed(breed);
        expect(config, isA<DogSkeleton>());
        expect(config, isA<BreedSkeletonConfig>());
      });
    }
  });

  group('BreedSkeletonConfig property ranges', () {
    late List<BreedSkeletonConfig> allConfigs;

    setUp(() {
      allConfigs = CompanionBreed.values
          .map(SkeletonConfigFactory.forBreed)
          .toList();
    });

    test('heightScale is in [0.4, 1.1]', () {
      for (final cfg in allConfigs) {
        expect(cfg.heightScale, greaterThanOrEqualTo(0.4),
            reason: '${cfg.breedKey} heightScale too small');
        expect(cfg.heightScale, lessThanOrEqualTo(1.1),
            reason: '${cfg.breedKey} heightScale too large');
      }
    });

    test('torsoAspectRatio is in (0.0, 4.0]', () {
      for (final cfg in allConfigs) {
        expect(cfg.torsoAspectRatio, greaterThan(0.0));
        expect(cfg.torsoAspectRatio, lessThanOrEqualTo(4.0),
            reason: '${cfg.breedKey} torsoAspectRatio too large');
      }
    });

    test('legLengthRatio is in [0.10, 0.65]', () {
      for (final cfg in allConfigs) {
        expect(cfg.legLengthRatio, greaterThanOrEqualTo(0.10),
            reason: '${cfg.breedKey} legLengthRatio too small');
        expect(cfg.legLengthRatio, lessThanOrEqualTo(0.65));
      }
    });

    test('animationSpeedMultiplier is in [0.5, 2.0]', () {
      for (final cfg in allConfigs) {
        expect(cfg.animationSpeedMultiplier, greaterThanOrEqualTo(0.5));
        expect(cfg.animationSpeedMultiplier, lessThanOrEqualTo(2.0));
      }
    });

    test('primaryCoatColor is a valid Color', () {
      for (final cfg in allConfigs) {
        expect(cfg.primaryCoatColor, isA<Color>());
        expect(cfg.secondaryCoatColor, isA<Color>());
        expect(cfg.accentColor, isA<Color>());
      }
    });

    test('breedKey is non-empty', () {
      for (final cfg in allConfigs) {
        expect(cfg.breedKey, isNotEmpty);
      }
    });
  });

  group('Breed-specific distinguishing properties', () {
    test('Dachshund has the widest torso (sausage body)', () {
      final dachshund = SkeletonConfigFactory.forBreed(CompanionBreed.dachshund);
      final golden = SkeletonConfigFactory.forBreed(CompanionBreed.goldenRetriever);
      final shepherd = SkeletonConfigFactory.forBreed(CompanionBreed.germanShepherd);
      expect(dachshund.torsoAspectRatio, greaterThan(golden.torsoAspectRatio));
      expect(dachshund.torsoAspectRatio, greaterThan(shepherd.torsoAspectRatio));
    });

    test('Dachshund has the shortest legs', () {
      final dachshund = SkeletonConfigFactory.forBreed(CompanionBreed.dachshund);
      final shepherd = SkeletonConfigFactory.forBreed(CompanionBreed.germanShepherd);
      final golden = SkeletonConfigFactory.forBreed(CompanionBreed.goldenRetriever);
      expect(dachshund.legLengthRatio, lessThan(golden.legLengthRatio));
      expect(dachshund.legLengthRatio, lessThan(shepherd.legLengthRatio));
    });

    test('German Shepherd is the tallest (highest heightScale)', () {
      final shepherd = SkeletonConfigFactory.forBreed(CompanionBreed.germanShepherd);
      final dachshund = SkeletonConfigFactory.forBreed(CompanionBreed.dachshund);
      expect(shepherd.heightScale, greaterThan(dachshund.heightScale));
    });

    test('German Shepherd has erect ears', () {
      final shepherd = SkeletonConfigFactory.forBreed(CompanionBreed.germanShepherd);
      expect(shepherd.earsFloppy, isFalse);
    });

    test('Golden Retriever and Dachshund have floppy ears', () {
      final golden = SkeletonConfigFactory.forBreed(CompanionBreed.goldenRetriever);
      final dachshund = SkeletonConfigFactory.forBreed(CompanionBreed.dachshund);
      expect(golden.earsFloppy, isTrue);
      expect(dachshund.earsFloppy, isTrue);
    });

    test('Dachshund torsoAspectRatio is > 2.5 (visibly elongated)', () {
      final dachshund = SkeletonConfigFactory.forBreed(CompanionBreed.dachshund);
      expect(dachshund.torsoAspectRatio, greaterThan(2.5));
    });

    test('German Shepherd primary coat has a different hue to Golden Retriever', () {
      final shepherd = SkeletonConfigFactory.forBreed(CompanionBreed.germanShepherd);
      final golden = SkeletonConfigFactory.forBreed(CompanionBreed.goldenRetriever);
      // They must not be the exact same colour
      expect(shepherd.primaryCoatColor, isNot(equals(golden.primaryCoatColor)));
    });
  });

  group('SkeletonConfigFactory.forBreed maps every breed', () {
    test('no breed throws', () {
      for (final breed in CompanionBreed.values) {
        expect(() => SkeletonConfigFactory.forBreed(breed), returnsNormally);
      }
    });
  });
}
