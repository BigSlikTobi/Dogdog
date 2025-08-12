import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../l10n/generated/app_localizations.dart';

/// Extension to provide localized strings for PathType enum
extension PathTypeLocalization on PathType {
  /// Returns the localized display name for the path
  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case PathType.dogTrivia:
        return l10n.pathType_dogTrivia_name;
      case PathType.puppyQuest:
        return l10n.pathType_puppyQuest_name;
    }
  }

  /// Returns the localized description for the path
  String getLocalizedDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case PathType.dogTrivia:
        return l10n.pathType_dogTrivia_description;
      case PathType.puppyQuest:
        return l10n.pathType_puppyQuest_description;
    }
  }
}
