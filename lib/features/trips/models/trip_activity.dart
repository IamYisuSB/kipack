import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

/// Specific activities within a trip (independent of [TripType]) that the
/// AI packing generator can tailor gear for — e.g. a "Montaña" trip that
/// includes "Esquí" needs very different equipment than one that's just
/// "Senderismo".
enum TripActivity {
  diving('Buceo', Icons.scuba_diving_rounded),
  hiking('Senderismo', Icons.hiking_rounded),
  skiing('Esquí', Icons.downhill_skiing_rounded),
  surfing('Surf', Icons.surfing_rounded),
  cycling('Ciclismo', Icons.directions_bike_rounded),
  camping('Camping', Icons.holiday_village_rounded),
  photography('Fotografía', Icons.camera_alt_rounded),
  running('Running', Icons.directions_run_rounded);

  const TripActivity(this.label, this.icon);

  /// Always Spanish — see [TripType.label] for why. Use [displayLabel] in UI.
  final String label;
  final IconData icon;

  String displayLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      TripActivity.diving => l10n.tripActivityDiving,
      TripActivity.hiking => l10n.tripActivityHiking,
      TripActivity.skiing => l10n.tripActivitySkiing,
      TripActivity.surfing => l10n.tripActivitySurfing,
      TripActivity.cycling => l10n.tripActivityCycling,
      TripActivity.camping => l10n.tripActivityCamping,
      TripActivity.photography => l10n.tripActivityPhotography,
      TripActivity.running => l10n.tripActivityRunning,
    };
  }
}
