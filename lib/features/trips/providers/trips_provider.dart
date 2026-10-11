import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/local_store.dart';
import '../../weather/models/trip_weather.dart';
import '../models/trip.dart';
import '../models/trip_activity.dart';
import '../models/trip_type.dart';

const _storageKey = 'trips';

/// Trip store backed by local device storage only — there's no account or
/// cloud backend, everything lives on this device.
class TripsNotifier extends StateNotifier<List<Trip>> {
  TripsNotifier() : super(const []) {
    _load();
  }

  static const _uuid = Uuid();

  Future<void> _load() async {
    final raw = await LocalStore.instance.readList(_storageKey);
    state = raw.map(Trip.fromJson).toList();
  }

  Future<void> _persist() async {
    await LocalStore.instance.writeList(
      _storageKey,
      state.map((t) => t.toJson()).toList(),
    );
  }

  Trip addTrip({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required List<TripType> types,
    required int peopleCount,
    List<TripActivity> activities = const [],
    TripWeather? weather,
    String? countryCode,
  }) {
    final trip = Trip(
      id: _uuid.v4(),
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      types: types,
      peopleCount: peopleCount,
      activities: activities,
      weather: weather,
      countryCode: countryCode,
    );
    state = [trip, ...state];
    _persist();
    return trip;
  }

  void removeTrip(String id) {
    state = state.where((t) => t.id != id).toList();
    _persist();
    LocalStore.instance.remove('packing_$id');
    LocalStore.instance.remove('suitcases_$id');
  }
}

final tripsProvider = StateNotifierProvider<TripsNotifier, List<Trip>>((ref) {
  return TripsNotifier();
});
