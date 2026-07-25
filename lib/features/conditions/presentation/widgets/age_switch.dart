import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../model/first_aid_topic.dart';

/// Localized labels for [AgeGroup].
extension AgeGroupDisplay on AgeGroup {
  String label(AppLocalizations l10n) {
    switch (this) {
      case AgeGroup.adult:
        return l10n.ageAdult;
      case AgeGroup.child:
        return l10n.ageChild;
      case AgeGroup.infant:
        return l10n.ageInfant;
    }
  }
}

/// Picks which body the steps below describe.
///
/// Shown only for topics that actually differ by age, so its presence is itself
/// the signal that this is a procedure where age changes the answer.
class AgeSwitch extends StatelessWidget {
  const AgeSwitch({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.accent,
  });

  final List<AgeGroup> options;
  final AgeGroup selected;
  final ValueChanged<AgeGroup> onChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return SegmentedButton<AgeGroup>(
      segments: <ButtonSegment<AgeGroup>>[
        for (final AgeGroup group in options)
          ButtonSegment<AgeGroup>(value: group, label: Text(group.label(l10n))),
      ],
      selected: <AgeGroup>{selected},
      showSelectedIcon: false,
      onSelectionChanged: (Set<AgeGroup> picked) => onChanged(picked.single),
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: accent.withValues(alpha: 0.14),
        selectedForegroundColor: accent,
      ),
    );
  }
}

/// States plainly whose steps are on screen, for as long as they are not the
/// adult ones.
///
/// Not a toast and not dismissible: the screen must never be ambiguous about
/// which body the instructions in front of you describe.
class AgeBanner extends StatelessWidget {
  const AgeBanner({super.key, required this.group, required this.accent});

  final AgeGroup group;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String text =
        group == AgeGroup.infant ? l10n.ageInfantBanner : l10n.ageChildBanner;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.child_care, size: 20, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: context.texts.labelLarge?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
