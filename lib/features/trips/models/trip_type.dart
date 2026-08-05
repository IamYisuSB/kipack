import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

enum TripType {
  beach('Playa', Icons.beach_access_rounded),
  mountain('Montaña', Icons.terrain_rounded),
  city('Ciudad', Icons.location_city_rounded),
  business('Negocios', Icons.work_rounded),
  backpacker('Mochilero', Icons.hiking_rounded);

  const TripType(this.label, this.icon);

  /// Always Spanish, regardless of the app's display language — used to
  /// build the AI prompt (see ai_packing_list_service.dart), which is kept
  /// stable/locale-independent on purpose. UI code should use
  /// [displayLabel] instead.
  final String label;
  final IconData icon;

  String displayLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      TripType.beach => l10n.tripTypeBeach,
      TripType.mountain => l10n.tripTypeMountain,
      TripType.city => l10n.tripTypeCity,
      TripType.business => l10n.tripTypeBusiness,
      TripType.backpacker => l10n.tripTypeBackpacker,
    };
  }
}
