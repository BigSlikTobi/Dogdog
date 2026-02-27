import 'package:dogdog_trivia_game/models/companion_enums.dart';
import '../breed_skeleton_config.dart';
import 'golden_retriever_config.dart';
import 'german_shepherd_config.dart';
import 'dachshund_config.dart';

/// Maps every [CompanionBreed] to its [BreedSkeletonConfig].
abstract final class SkeletonConfigFactory {
  static const Map<CompanionBreed, BreedSkeletonConfig> _configs = {
    CompanionBreed.goldenRetriever: goldenRetrieverConfig,
    CompanionBreed.germanShepherd: germanShepherdConfig,
    CompanionBreed.dachshund: dachshundConfig,
  };

  static BreedSkeletonConfig forBreed(CompanionBreed breed) {
    final config = _configs[breed];
    if (config == null) {
      throw StateError('No skeleton config registered for breed: $breed');
    }
    return config;
  }
}
