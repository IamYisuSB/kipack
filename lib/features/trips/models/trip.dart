import '../../weather/models/trip_weather.dart';
import 'trip_activity.dart';
import 'trip_type.dart';

class Trip {
  Trip({
    required this.id,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.types,
    required this.peopleCount,
    this.activities = const [],
    this.weather,
    this.countryCode,
  }) : assert(types.isNotEmpty, 'A trip needs at least one TripType');

  final String id;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final List<TripType> types;
  final int peopleCount;

  /// Optional, more specific than [types] — e.g. a "Montaña" trip that's
  /// specifically for skiing needs different gear than one for hiking.
  final List<TripActivity> activities;
  final TripWeather? weather;

  /// ISO 3166-1 alpha-2 country code, lowercase (matches `countries_world_map` ids).
  final String? countryCode;

  int get durationInDays => endDate.difference(startDate).inDays + 1;

  /// A trip counts as visited once its end date is in the past.
  bool get isVisited => endDate.isBefore(DateTime.now());

  Trip copyWith({
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    List<TripType>? types,
    int? peopleCount,
    List<TripActivity>? activities,
    TripWeather? weather,
    String? countryCode,
  }) {
    return Trip(
      id: id,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      types: types ?? this.types,
      peopleCount: peopleCount ?? this.peopleCount,
      activities: activities ?? this.activities,
      weather: weather ?? this.weather,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'destination': destination,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'types': types.map((t) => t.name).toList(),
    'peopleCount': peopleCount,
    'activities': activities.map((a) => a.name).toList(),
    'weather': weather?.toJson(),
    'countryCode': countryCode,
  };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json['id'] as String,
    destination: json['destination'] as String,
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    types: json['types'] != null
        ? (json['types'] as List<dynamic>)
              .map((t) => TripType.values.byName(t as String))
              .toList()
        // Backward-compatible read of the old single `type` field.
        : [TripType.values.byName(json['type'] as String)],
    peopleCount: json['peopleCount'] as int,
    activities: json['activities'] != null
        ? (json['activities'] as List<dynamic>)
              .map((a) => TripActivity.values.byName(a as String))
              .toList()
        : const [],
    weather: json['weather'] != null
        ? TripWeather.fromJson(json['weather'] as Map<String, dynamic>)
        : null,
    countryCode: json['countryCode'] as String?,
  );
}
