import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../models/trip.dart';
import 'country_shape_icon.dart';

class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
    required this.onDuplicate,
    required this.onDelete,
    this.isOwner = true,
  });

  final Trip trip;
  final VoidCallback onTap;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  /// Hides "Eliminar" for a shared trip you don't own — RLS would reject
  /// the remote delete anyway, so offering it would just be misleading.
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat(
      'd MMM',
      Localizations.localeOf(context).toString(),
    );
    final dateRange =
        '${dateFormat.format(trip.startDate)} — ${dateFormat.format(trip.endDate)}';
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final isPast = trip.isVisited;

    return Opacity(
      // "Ghost" past trips instead of showing them identically to upcoming
      // ones — fading the whole card (shadow included) reads as "this
      // already happened" at a glance without a second color scheme to
      // maintain.
      opacity: isPast ? 0.55 : 1,
      child: Material(
        // A manually-painted BoxShadow (via Ink's BoxDecoration) is prone to
        // rendering artifacts — spiky/pointed corners instead of a smooth
        // blur — on some GPU/driver combos. Material's own `elevation` uses
        // the engine's native shadow rendering instead, which doesn't have
        // that failure mode.
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        elevation: isDark ? 6 : 3,
        shadowColor: isDark ? Colors.black : AppColors.primary,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isPast
                        ? Theme.of(context).inputDecorationTheme.fillColor
                        : AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CountryShapeIcon(
                    countryCode: trip.countryCode,
                    color: isPast
                        ? (secondary ?? AppColors.primary)
                        : AppColors.primary,
                    size: 28,
                    fallback: Icon(
                      trip.types.first.icon,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.destination,
                        style: AppTextStyles.title.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dateRange · ${trip.types.map((t) => t.displayLabel(context)).join(", ")}',
                        style: AppTextStyles.body.copyWith(color: secondary),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<_TripAction>(
                  icon: Icon(Icons.more_vert_rounded, color: secondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (action) {
                    switch (action) {
                      case _TripAction.duplicate:
                        onDuplicate();
                      case _TripAction.delete:
                        onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _TripAction.duplicate,
                      child: Row(
                        children: [
                          const Icon(Icons.copy_all_rounded, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            AppLocalizations.of(context).duplicateTripAction,
                          ),
                        ],
                      ),
                    ),
                    if (isOwner)
                      PopupMenuItem(
                        value: _TripAction.delete,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context).commonDelete,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _TripAction { duplicate, delete }
