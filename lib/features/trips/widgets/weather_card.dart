import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../weather/models/trip_weather.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
    required this.weather,
    required this.destination,
    this.onTap,
  });

  final TripWeather weather;
  final String destination;

  /// Only wired up by the caller when [TripWeather.hasDailyBreakdown] is
  /// true — a historical-estimate trip has no real per-day data to expand.
  final VoidCallback? onTap;

  static const _seasonStyles = {
    'invierno': (icon: Icons.ac_unit_rounded, color: Color(0xFF5B9BD5)),
    'primavera': (icon: Icons.local_florist_rounded, color: Color(0xFF7CB86C)),
    'verano': (icon: Icons.wb_sunny_rounded, color: Color(0xFFF0A73A)),
    'otoño': (icon: Icons.eco_rounded, color: Color(0xFFCB7B3E)),
  };

  /// [weather.season] is always stored as one of these Spanish keys (also
  /// used, unchanged, when building the AI prompt) — only the on-screen
  /// label is translated, via this lookup.
  String _seasonLabel(AppLocalizations l10n) => switch (weather.season) {
    'invierno' => l10n.seasonWinter,
    'primavera' => l10n.seasonSpring,
    'verano' => l10n.seasonSummer,
    'otoño' => l10n.seasonAutumn,
    _ => weather.season,
  };

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final surfaceAlt = Theme.of(context).inputDecorationTheme.fillColor;
    final l10n = AppLocalizations.of(context);
    final rawSeasonLabel = _seasonLabel(l10n);
    final seasonLabel =
        rawSeasonLabel[0].toUpperCase() + rawSeasonLabel.substring(1);
    final seasonStyle = _seasonStyles[weather.season]!;

    final tappable = onTap != null && weather.hasDailyBreakdown;

    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: tappable ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.weatherCardTitle(destination),
                      style: AppTextStyles.subtitle.copyWith(color: onSurface),
                    ),
                  ),
                  if (tappable)
                    Icon(Icons.chevron_right_rounded, color: secondary),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: seasonStyle.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          seasonStyle.icon,
                          color: seasonStyle.color,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          seasonLabel,
                          style: AppTextStyles.bodyStrong.copyWith(
                            color: seasonStyle.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (weather.isSouthernHemisphere) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.weatherCardSouthernHemisphere,
                        style: AppTextStyles.caption.copyWith(color: secondary),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              if (weather.hasForecast) ...[
                Row(
                  children: [
                    Icon(Icons.thermostat_rounded, size: 18, color: secondary),
                    const SizedBox(width: 8),
                    Text(
                      '${weather.avgMinTempC!.round()}°C — ${weather.avgMaxTempC!.round()}°C',
                      style: AppTextStyles.body.copyWith(color: onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.water_drop_rounded,
                      size: 18,
                      color: weather.willLikelyRain
                          ? seasonStyle.color
                          : secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _rainLabel(l10n, weather.rainProbability!),
                      style: AppTextStyles.body.copyWith(color: onSurface),
                    ),
                  ],
                ),
              ] else
                Text(
                  l10n.weatherCardNoData,
                  style: AppTextStyles.body.copyWith(color: secondary),
                ),
              if (weather.isHistoricalEstimate) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.weatherCardHistoricalNote,
                          style: AppTextStyles.caption.copyWith(
                            color: secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _rainLabel(AppLocalizations l10n, double probability) {
    final pct = (probability * 100).round();
    if (probability >= 0.4) return l10n.weatherCardRainLikely(pct);
    if (probability >= 0.15) return l10n.weatherCardRainPossible(pct);
    return l10n.weatherCardRainUnlikely(pct);
  }
}
