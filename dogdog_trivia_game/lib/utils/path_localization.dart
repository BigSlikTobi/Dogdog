import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../l10n/generated/app_localizations.dart';

/// Extension to provide localized strings for PathType enum
extension PathTypeLocalization on PathType {
  /// Returns the localized display name for the path
  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case PathType.dogBreeds:
        return l10n.pathType_dogBreeds_name;
      case PathType.dogTraining:
        return l10n.pathType_dogTraining_name;
      case PathType.healthCare:
        return l10n.pathType_healthCare_name;
      case PathType.dogBehavior:
        return l10n.pathType_dogBehavior_name;
      case PathType.dogHistory:
        return l10n.pathType_dogHistory_name;
      case PathType.breedAdventure:
        return l10n.pathType_breedAdventure_name;
    }
  }

  /// Returns the localized description for the path
  String getLocalizedDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case PathType.dogBreeds:
        return l10n.pathType_dogBreeds_description;
      case PathType.dogTraining:
        return l10n.pathType_dogTraining_description;
      case PathType.healthCare:
        return l10n.pathType_healthCare_description;
      case PathType.dogBehavior:
        return l10n.pathType_dogBehavior_description;
      case PathType.dogHistory:
        return l10n.pathType_dogHistory_description;
      case PathType.breedAdventure:
        return l10n.pathType_breedAdventure_description;
    }
  }
}
