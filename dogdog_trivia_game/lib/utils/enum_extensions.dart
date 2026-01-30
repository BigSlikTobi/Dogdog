import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../l10n/generated/app_localizations.dart';

/// Extension methods for enums to provide localized display names and descriptions
extension DifficultyExtension on Difficulty {
  /// Returns the localized display name for the difficulty
  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case Difficulty.easy:
        return l10n.difficulty_easy;
      case Difficulty.medium:
        return l10n.difficulty_medium;
      case Difficulty.hard:
        return l10n.difficulty_hard;
      case Difficulty.expert:
        return l10n.difficulty_expert;
    }
  }

  /// Returns the localized description for the difficulty
  String description(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case Difficulty.easy:
        return l10n.difficulty_easy_description;
      case Difficulty.medium:
        return l10n.difficulty_medium_description;
      case Difficulty.hard:
        return l10n.difficulty_hard_description;
      case Difficulty.expert:
        return l10n.difficulty_expert_description;
    }
  }
}

extension PowerUpTypeExtension on PowerUpType {
  /// Returns the localized display name for the power-up
  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case PowerUpType.fiftyFifty:
        return l10n.powerUp_fiftyFifty;
      case PowerUpType.hint:
        return l10n.powerUp_hint;
      case PowerUpType.extraTime:
        return l10n.powerUp_extraTime;
      case PowerUpType.skip:
        return l10n.powerUp_skip;
      case PowerUpType.secondChance:
        return l10n.powerUp_secondChance;
    }
  }

  /// Returns the localized description for the power-up
  String description(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case PowerUpType.fiftyFifty:
        return l10n.powerUp_fiftyFifty_description;
      case PowerUpType.hint:
        return l10n.powerUp_hint_description;
      case PowerUpType.extraTime:
        return l10n.powerUp_extraTime_description;
      case PowerUpType.skip:
        return l10n.powerUp_skip_description;
      case PowerUpType.secondChance:
        return l10n.powerUp_secondChance_description;
    }
  }
}

extension RankExtension on Rank {
  /// Returns the localized display name for the rank
  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case Rank.chihuahua:
        return l10n.rank_chihuahua;
      case Rank.pug:
        return l10n.rank_pug;
      case Rank.cockerSpaniel:
        return l10n.rank_cockerSpaniel;
      case Rank.germanShepherd:
        return l10n.rank_germanShepherd;
      case Rank.greatDane:
        return l10n.rank_greatDane;
    }
  }

  /// Returns the localized description for the rank
  String description(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case Rank.chihuahua:
        return l10n.rank_chihuahua_description;
      case Rank.pug:
        return l10n.rank_pug_description;
      case Rank.cockerSpaniel:
        return l10n.rank_cockerSpaniel_description;
      case Rank.germanShepherd:
        return l10n.rank_germanShepherd_description;
      case Rank.greatDane:
        return l10n.rank_greatDane_description;
    }
  }
}

extension GameResultExtension on GameResult {
  /// Returns the localized display name for the game result
  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case GameResult.win:
        return l10n.gameResult_win;
      case GameResult.lose:
        return l10n.gameResult_lose;
      case GameResult.quit:
        return l10n.gameResult_quit;
    }
  }
}

extension PathTypeExtension on PathType {
  /// Returns the localized display name for the path
  String getLocalizedName(BuildContext context) {
    switch (this) {
      case PathType.dogTrivia:
        return 'Dog Trivia';
      case PathType.puppyQuest:
         return 'Puppy Quest';
    }
  }
}
