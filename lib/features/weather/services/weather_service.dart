import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/geo_suggestion.dart';
import '../models/trip_weather.dart';

/// Fetches destination weather via Open-Meteo — free, no API key required.
///
/// - Trips starting within ~15 days get a real daily forecast.
/// - Trips further out get a climate-average estimate built from the same
///   calendar dates in the previous 3 years ([TripWeather.isHistoricalEstimate]
///   is true in that case) — callers should say it's an estimate rather than
///   present it as an exact forecast, since it will firm up into a real
///   forecast automatically once the trip is within that ~15 day window.
class WeatherService {
  const WeatherService();

  static const _geocodeUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  static const _forecastUrl = 'https://api.open-meteo.com/v1/forecast';
  static const _archiveUrl = 'https://archive-api.open-meteo.com/v1/archive';
  static const _forecastHorizonDays = 15;
  static const _historyYearsToSample = 3;

  /// Resolves a destination name to coordinates and its ISO 3166-1 alpha-2
  /// country code (lowercase, matching `countries_world_map`'s ids) — public
  /// so callers that also need the country (e.g. the trips map) don't have
  /// to geocode a second time.
  Future<GeoLocation?> geocodeDestination(
    String query, {
    String language = 'es',
  }) async {
    try {
      final uri = Uri.parse(
        '$_geocodeUrl?name=${Uri.encodeQueryComponent(query)}&count=1&language=$language&format=json',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final results = body['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return null;
      final first = results.first as Map<String, dynamic>;
      final countryCode = (first['country_code'] as String?)?.toLowerCase();
      return GeoLocation(
        lat: (first['latitude'] as num).toDouble(),
        lon: (first['longitude'] as num).toDouble(),
        countryCode: countryCode,
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns real city matches for a (partial) destination query, for an
  /// autocomplete field — deliberately doesn't fall back to the raw typed
  /// text, since the whole point is only letting the user pick a real place.
  Future<List<GeoSuggestion>> searchDestinations(
    String query, {
    String language = 'es',
  }) async {
    if (query.trim().length < 2) return [];
    try {
      final uri = Uri.parse(
        '$_geocodeUrl?name=${Uri.encodeQueryComponent(query)}&count=8&language=$language&format=json',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final results = body['results'] as List<dynamic>?;
      if (results == null) return [];
      return results.map((raw) {
        final map = raw as Map<String, dynamic>;
        return GeoSuggestion(
          name: map['name'] as String,
          country: map['country'] as String? ?? '',
          admin1: map['admin1'] as String?,
          lat: (map['latitude'] as num).toDouble(),
          lon: (map['longitude'] as num).toDouble(),
          countryCode: (map['country_code'] as String?)?.toLowerCase(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<TripWeather?> fetchTripWeather({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final location = await geocodeDestination(destination);
    if (location == null) return null;
    return fetchWeatherForLocation(
      location: location,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<TripWeather?> fetchWeatherForLocation({
    required GeoLocation location,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final coords = _Coords(location.lat, location.lon);

      final season = _seasonFor(startDate.month, coords.lat);
      final isSouthern = coords.lat < 0;
      final daysUntilTrip = _dateOnly(
        startDate,
      ).difference(_dateOnly(DateTime.now())).inDays;

      if (daysUntilTrip <= _forecastHorizonDays) {
        final real = await _fetchRealForecast(coords, startDate, endDate);
        if (real != null) {
          return TripWeather(
            season: season,
            isSouthernHemisphere: isSouthern,
            hasForecast: true,
            isHistoricalEstimate: false,
            avgMinTempC: real.min,
            avgMaxTempC: real.max,
            rainProbability: real.rainProbability,
            dailyForecast: real.daily,
          );
        }
      }

      final historical = await _fetchHistoricalAverage(
        coords,
        startDate,
        endDate,
      );
      if (historical != null) {
        return TripWeather(
          season: season,
          isSouthernHemisphere: isSouthern,
          hasForecast: true,
          isHistoricalEstimate: true,
          avgMinTempC: historical.min,
          avgMaxTempC: historical.max,
          rainProbability: historical.rainProbability,
        );
      }

      return TripWeather(
        season: season,
        isSouthernHemisphere: isSouthern,
        hasForecast: false,
      );
    } catch (_) {
      // Network/parse failure — the app keeps working with rule-based generation.
      return null;
    }
  }

  Future<_Averages?> _fetchRealForecast(
    _Coords coords,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final uri = Uri.parse(
      '$_forecastUrl?latitude=${coords.lat}&longitude=${coords.lon}'
      '&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weathercode'
      '&timezone=auto&forecast_days=16',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final daily = body['daily'] as Map<String, dynamic>?;
    if (daily == null) return null;

    final dates = (daily['time'] as List<dynamic>).cast<String>();
    final tMax = daily['temperature_2m_max'] as List<dynamic>;
    final tMin = daily['temperature_2m_min'] as List<dynamic>;
    final rainPop = daily['precipitation_probability_max'] as List<dynamic>;
    final codes = daily['weathercode'] as List<dynamic>?;

    final maxTemps = <double>[];
    final minTemps = <double>[];
    final rainProbs = <double>[];
    final dailyBreakdown = <DailyWeather>[];
    for (var i = 0; i < dates.length; i++) {
      final date = DateTime.parse(dates[i]);
      if (date.isBefore(_dateOnly(startDate)) ||
          date.isAfter(_dateOnly(endDate)))
        continue;
      if (tMax[i] == null || tMin[i] == null) continue;
      final min = (tMin[i] as num).toDouble();
      final max = (tMax[i] as num).toDouble();
      final rainProb = ((rainPop[i] as num?)?.toDouble() ?? 0) / 100;
      maxTemps.add(max);
      minTemps.add(min);
      rainProbs.add(rainProb);
      dailyBreakdown.add(
        DailyWeather(
          date: date,
          minTempC: min,
          maxTempC: max,
          rainProbability: rainProb,
          condition: WeatherCondition.fromCode(
            (codes?[i] as num?)?.toInt() ?? 0,
          ),
        ),
      );
    }
    if (maxTemps.isEmpty) return null;
    return _Averages(
      min: minTemps.reduce((a, b) => a + b) / minTemps.length,
      max: maxTemps.reduce((a, b) => a + b) / maxTemps.length,
      rainProbability: rainProbs.reduce((a, b) => a + b) / rainProbs.length,
      daily: dailyBreakdown,
    );
  }

  Future<_Averages?> _fetchHistoricalAverage(
    _Coords coords,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final maxTemps = <double>[];
    final minTemps = <double>[];
    final rainDays = <bool>[];

    for (var yearsAgo = 1; yearsAgo <= _historyYearsToSample; yearsAgo++) {
      final year = startDate.year - yearsAgo;
      final histStart = DateTime(year, startDate.month, startDate.day);
      var histEnd = DateTime(year, endDate.month, endDate.day);
      if (histEnd.isBefore(histStart)) histEnd = histStart;

      try {
        final uri = Uri.parse(
          '$_archiveUrl?latitude=${coords.lat}&longitude=${coords.lon}'
          '&start_date=${_fmt(histStart)}&end_date=${_fmt(histEnd)}'
          '&daily=temperature_2m_max,temperature_2m_min,precipitation_sum&timezone=auto',
        );
        final response = await http.get(uri);
        if (response.statusCode != 200) continue;
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final daily = body['daily'] as Map<String, dynamic>?;
        if (daily == null) continue;
        final tMax = daily['temperature_2m_max'] as List<dynamic>;
        final tMin = daily['temperature_2m_min'] as List<dynamic>;
        final precip = daily['precipitation_sum'] as List<dynamic>;
        for (var i = 0; i < tMax.length; i++) {
          if (tMax[i] == null || tMin[i] == null) continue;
          maxTemps.add((tMax[i] as num).toDouble());
          minTemps.add((tMin[i] as num).toDouble());
          rainDays.add(((precip[i] as num?)?.toDouble() ?? 0) > 1.0);
        }
      } catch (_) {
        continue;
      }
    }

    if (maxTemps.isEmpty) return null;
    return _Averages(
      min: minTemps.reduce((a, b) => a + b) / minTemps.length,
      max: maxTemps.reduce((a, b) => a + b) / maxTemps.length,
      rainProbability:
          rainDays.where((raining) => raining).length / rainDays.length,
    );
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _seasonFor(int month, double lat) {
    const northernSeasonByMonth = {
      12: 'invierno',
      1: 'invierno',
      2: 'invierno',
      3: 'primavera',
      4: 'primavera',
      5: 'primavera',
      6: 'verano',
      7: 'verano',
      8: 'verano',
      9: 'otoño',
      10: 'otoño',
      11: 'otoño',
    };
    if (lat >= 0) return northernSeasonByMonth[month]!;
    // Southern hemisphere: shift by 6 months.
    final shifted = ((month - 1 + 6) % 12) + 1;
    return northernSeasonByMonth[shifted]!;
  }
}

/// Coordinates plus the ISO 3166-1 alpha-2 country code (lowercase) for a
/// geocoded destination, when Open-Meteo returns one.
class GeoLocation {
  const GeoLocation({required this.lat, required this.lon, this.countryCode});
  final double lat;
  final double lon;
  final String? countryCode;
}

class _Coords {
  const _Coords(this.lat, this.lon);
  final double lat;
  final double lon;
}

class _Averages {
  const _Averages({
    required this.min,
    required this.max,
    required this.rainProbability,
    this.daily,
  });
  final double min;
  final double max;
  final double rainProbability;
  final List<DailyWeather>? daily;
}
