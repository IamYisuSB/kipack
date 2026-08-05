import 'package:flutter/widgets.dart';
import '../../../l10n/app_localizations.dart';

/// Broad weather condition for a single day, derived from Open-Meteo's WMO
/// weather code — just enough categories to pick an icon/label, not the full
/// WMO table.
enum WeatherCondition {
  clear,
  partlyCloudy,
  cloudy,
  fog,
  rain,
  storm,
  snow;

  /// Maps an Open-Meteo/WMO `weathercode` to a broad condition bucket.
  factory WeatherCondition.fromCode(int code) {
    if (code == 0) return WeatherCondition.clear;
    if (code == 1 || code == 2) return WeatherCondition.partlyCloudy;
    if (code == 3) return WeatherCondition.cloudy;
    if (code == 45 || code == 48) return WeatherCondition.fog;
    if (code == 71 ||
        code == 73 ||
        code == 75 ||
        code == 77 ||
        code == 85 ||
        code == 86) {
      return WeatherCondition.snow;
    }
    if (code == 95 || code == 96 || code == 99) return WeatherCondition.storm;
    // 51/53/55 drizzle, 56/57 freezing drizzle, 61/63/65 rain,
    // 66/67 freezing rain, 80/81/82 rain showers.
    return WeatherCondition.rain;
  }

  String displayLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      WeatherCondition.clear => l10n.weatherConditionClear,
      WeatherCondition.partlyCloudy => l10n.weatherConditionPartlyCloudy,
      WeatherCondition.cloudy => l10n.weatherConditionCloudy,
      WeatherCondition.fog => l10n.weatherConditionFog,
      WeatherCondition.rain => l10n.weatherConditionRain,
      WeatherCondition.storm => l10n.weatherConditionStorm,
      WeatherCondition.snow => l10n.weatherConditionSnow,
    };
  }
}

/// A single day's forecast — only ever populated from a *real* Open-Meteo
/// forecast (trips within ~15 days), never from the historical-average
/// estimate used for trips further out, since that average is blended across
/// several different past years and doesn't correspond to any actual day.
class DailyWeather {
  const DailyWeather({
    required this.date,
    required this.minTempC,
    required this.maxTempC,
    required this.rainProbability,
    required this.condition,
  });

  final DateTime date;
  final double minTempC;
  final double maxTempC;
  final double rainProbability;
  final WeatherCondition condition;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'minTempC': minTempC,
    'maxTempC': maxTempC,
    'rainProbability': rainProbability,
    'condition': condition.name,
  };

  factory DailyWeather.fromJson(Map<String, dynamic> json) => DailyWeather(
    date: DateTime.parse(json['date'] as String),
    minTempC: (json['minTempC'] as num).toDouble(),
    maxTempC: (json['maxTempC'] as num).toDouble(),
    rainProbability: (json['rainProbability'] as num).toDouble(),
    condition: WeatherCondition.values.byName(json['condition'] as String),
  );
}

/// Weather context for a trip.
///
/// [avgMinTempC], [avgMaxTempC] and [rainProbability] are populated whenever
/// we have *some* numeric estimate — either a real forecast (trips within
/// ~15 days) or a climate-average estimate from previous years' data for
/// trips further out ([isHistoricalEstimate] tells them apart, so the UI can
/// be upfront about which one it's showing). [season] and
/// [isSouthernHemisphere] only need the destination's coordinates and the
/// travel month, so they're always available. [dailyForecast] is only ever
/// non-null/non-empty for a real forecast, never a historical estimate.
class TripWeather {
  const TripWeather({
    required this.season,
    required this.isSouthernHemisphere,
    required this.hasForecast,
    this.isHistoricalEstimate = false,
    this.avgMinTempC,
    this.avgMaxTempC,
    this.rainProbability,
    this.dailyForecast,
  });

  final String season;
  final bool isSouthernHemisphere;
  final bool hasForecast;
  final bool isHistoricalEstimate;
  final double? avgMinTempC;
  final double? avgMaxTempC;
  final double? rainProbability;
  final List<DailyWeather>? dailyForecast;

  bool get willLikelyRain => (rainProbability ?? 0) >= 0.4;
  bool get isCold => (avgMinTempC ?? 99) < 10;
  bool get isHot => (avgMaxTempC ?? -99) > 27;
  bool get hasDailyBreakdown =>
      dailyForecast != null && dailyForecast!.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'season': season,
    'isSouthernHemisphere': isSouthernHemisphere,
    'hasForecast': hasForecast,
    'isHistoricalEstimate': isHistoricalEstimate,
    'avgMinTempC': avgMinTempC,
    'avgMaxTempC': avgMaxTempC,
    'rainProbability': rainProbability,
    'dailyForecast': dailyForecast?.map((d) => d.toJson()).toList(),
  };

  factory TripWeather.fromJson(Map<String, dynamic> json) => TripWeather(
    season: json['season'] as String,
    isSouthernHemisphere: json['isSouthernHemisphere'] as bool? ?? false,
    hasForecast: json['hasForecast'] as bool,
    isHistoricalEstimate: json['isHistoricalEstimate'] as bool? ?? false,
    avgMinTempC: (json['avgMinTempC'] as num?)?.toDouble(),
    avgMaxTempC: (json['avgMaxTempC'] as num?)?.toDouble(),
    rainProbability: (json['rainProbability'] as num?)?.toDouble(),
    dailyForecast: (json['dailyForecast'] as List<dynamic>?)
        ?.map((d) => DailyWeather.fromJson(d as Map<String, dynamic>))
        .toList(),
  );
}
