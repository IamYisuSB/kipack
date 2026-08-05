import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Declaration order is the fixed display order used everywhere a list of
/// categories is shown (packing list sections, category pickers) — not
/// arbitrary, so don't reorder without intending to change that.
enum PackingCategory {
  documents('Documentación', Icons.badge_rounded, AppColors.catDocuments),
  clothing('Ropa', Icons.checkroom_rounded, AppColors.catClothing),
  electronics('Electrónica', Icons.devices_rounded, AppColors.catElectronics),
  toiletries('Higiene', Icons.soap_rounded, AppColors.catToiletries),
  misc('Otros', Icons.category_rounded, AppColors.catMisc);

  const PackingCategory(this.label, this.icon, this.color);

  /// Always Spanish — see [TripType.label] for why. Use [displayLabel] in UI.
  final String label;
  final IconData icon;
  final Color color;

  String displayLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      PackingCategory.clothing => l10n.packingCategoryClothing,
      PackingCategory.toiletries => l10n.packingCategoryToiletries,
      PackingCategory.electronics => l10n.packingCategoryElectronics,
      PackingCategory.documents => l10n.packingCategoryDocuments,
      PackingCategory.misc => l10n.packingCategoryMisc,
    };
  }
}
