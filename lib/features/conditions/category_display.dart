import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'model/first_aid_topic.dart';

/// Localized labels and icons for [TopicCategory], used by the category filter.
extension TopicCategoryDisplay on TopicCategory {
  String label(AppLocalizations l10n) {
    switch (this) {
      case TopicCategory.breathing:
        return l10n.categoryBreathing;
      case TopicCategory.cardiac:
        return l10n.categoryCardiac;
      case TopicCategory.bleeding:
        return l10n.categoryBleeding;
      case TopicCategory.trauma:
        return l10n.categoryTrauma;
      case TopicCategory.environmental:
        return l10n.categoryEnvironmental;
      case TopicCategory.medical:
        return l10n.categoryMedical;
    }
  }

  /// Category hero illustration (unDraw, recolored to the category accent).
  String get illustration => 'assets/illustrations/$name.svg';

  IconData get icon {
    switch (this) {
      case TopicCategory.breathing:
        return Icons.air;
      case TopicCategory.cardiac:
        return Icons.favorite;
      case TopicCategory.bleeding:
        return Icons.bloodtype;
      case TopicCategory.trauma:
        return Icons.personal_injury;
      case TopicCategory.environmental:
        return Icons.public;
      case TopicCategory.medical:
        return Icons.medical_services;
    }
  }
}
