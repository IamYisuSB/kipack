import '../services/weather_service.dart' show GeoLocation;

/// A single destination match from the geocoding search, used to power the
/// "type a city, pick a real one" autocomplete on the new-trip form.
class GeoSuggestion {
  const GeoSuggestion({
    required this.name,
    required this.country,
    this.admin1,
    required this.lat,
    required this.lon,
    this.countryCode,
  });

  final String name;
  final String country;
  final String? admin1;
  final double lat;
  final double lon;
  final String? countryCode;

  /// e.g. "Roma, Italia" — or "Springfield, Illinois, Estados Unidos" when
  /// the region helps disambiguate a common city name.
  String get label {
    final parts = <String>[
      name,
      if (admin1 != null && admin1!.isNotEmpty) admin1!,
      country,
    ];
    return parts.where((p) => p.isNotEmpty).join(', ');
  }

  GeoLocation get location =>
      GeoLocation(lat: lat, lon: lon, countryCode: countryCode);
}
