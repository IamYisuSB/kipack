import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../weather/models/trip_weather.dart';

/// Full daily breakdown for a trip's weather — only ever opened when
/// [TripWeather.hasDailyBreakdown] is true (a real Open-Meteo forecast,
/// never the historical estimate used for trips further than ~15 days out).
class WeatherDetailSheet extends StatelessWidget {
  const WeatherDetailSheet({
    super.key,
    required this.weather,
    required this.destination,
  });

  final TripWeather weather;
  final String destination;

  static const _conditionStyles = {
    WeatherCondition.clear: (
      icon: Icons.wb_sunny_rounded,
      color: Color(0xFFF0A73A),
    ),
    WeatherCondition.partlyCloudy: (
      icon: Icons.wb_cloudy_rounded,
      color: Color(0xFFF0A73A),
    ),
    WeatherCondition.cloudy: (
      icon: Icons.cloud_rounded,
      color: Color(0xFF9CB3A3),
    ),
    WeatherCondition.fog: (icon: Icons.foggy, color: Color(0xFF9CB3A3)),
    WeatherCondition.rain: (
      icon: Icons.water_drop_rounded,
      color: Color(0xFF5B9BD5),
    ),
    WeatherCondition.storm: (
      icon: Icons.thunderstorm_rounded,
      color: Color(0xFF7A6FE0),
    ),
    WeatherCondition.snow: (
      icon: Icons.ac_unit_rounded,
      color: Color(0xFF5B9BD5),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final days = weather.dailyForecast ?? const <DailyWeather>[];
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat(
      'EEEE d MMM',
      Localizations.localeOf(context).toString(),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.weatherDetailTitle(destination),
              style: AppTextStyles.title.copyWith(color: onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.weatherDetailSubtitle,
              style: AppTextStyles.caption.copyWith(color: secondary),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 420),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: days.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final style = _conditionStyles[day.condition]!;
                    final label = dateFormat.format(day.date);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: style.color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              style.icon,
                              color: style.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label[0].toUpperCase() + label.substring(1),
                                  style: AppTextStyles.bodyStrong.copyWith(
                                    color: onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  day.condition.displayLabel(context),
                                  style: AppTextStyles.caption.copyWith(
                                    color: secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.water_drop_rounded,
                                size: 15,
                                color: secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(day.rainProbability * 100).round()}%',
                                style: AppTextStyles.caption.copyWith(
                                  color: secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${day.minTempC.round()}° / ${day.maxTempC.round()}°',
                            style: AppTextStyles.bodyStrong.copyWith(
                              color: onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
