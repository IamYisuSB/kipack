import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/storage/local_store.dart';
import '../../../core/sync/realtime_table_sync.dart';
import '../../../core/sync/sync_context.dart';
import '../../weather/models/trip_weather.dart';
import '../models/trip.dart';
import '../models/trip_activity.dart';
import '../models/trip_type.dart';

const _storageKey = 'trips';

/// Trip store backed by local device storage, with best-effort cloud sync
/// to Supabase for signed-in Premium users (see [canSync]). Free/guest
/// mode never touches the network here — same provider, same behavior as
/// before sync existed.
///
/// Sync strategy is deliberately simple: on sign-in, if the cloud already
/// has trips for this user, they replace local state (this device is
/// "joining" an existing account); if the cloud is empty, whatever's
/// local gets pushed up (this device is the first to sync). From then on,
/// every local add/remove pushes straight to Supabase. There's no
/// field-level conflict resolution — good enough for "my own trips on my
/// own devices," not a general multi-writer sync engine.
class TripsNotifier extends StateNotifier<List<Trip>> {
  TripsNotifier(this.ref) : super(const []) {
    _load();
    // fireImmediately: true — without it, this only fires on a *future*
    // sign-in/out transition, missing the already-signed-in case (the
    // common one, since the app is usually opened with a session already
    // restored) and silently never syncing or subscribing to realtime.
    ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      final user = next.asData?.value;
      if (user != null && canSync(ref)) {
        _syncFromRemote(user.id);
        _subscribeRealtime();
      } else {
        _unsubscribeRealtime();
      }
    }, fireImmediately: true);
  }

  final Ref ref;
  static const _uuid = Uuid();
  RealtimeTableSync? _realtimeSync;

  void _subscribeRealtime() {
    _realtimeSync?.dispose();
    // No trip_id/user_id filter here either, same reason as the fetch
    // below — a collaborator's edits to a shared trip need to come through
    // too, and RLS (not this filter) is what scopes visibility.
    _realtimeSync = RealtimeTableSync(
      channelName: 'trips_changes',
      table: 'trips',
      onChange: () {
        final userId = currentUserId(ref);
        if (userId != null) _syncFromRemote(userId);
      },
    );
  }

  void _unsubscribeRealtime() {
    _realtimeSync?.dispose();
    _realtimeSync = null;
  }

  @override
  void dispose() {
    _realtimeSync?.dispose();
    super.dispose();
  }

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

  Map<String, dynamic> _tripToRow(Trip trip, String fallbackOwnerId) => {
    'id': trip.id,
    'user_id': trip.ownerId ?? fallbackOwnerId,
    'destination': trip.destination,
    'start_date': trip.startDate.toIso8601String().split('T').first,
    'end_date': trip.endDate.toIso8601String().split('T').first,
    'people_count': trip.peopleCount,
    'types': trip.types.map((t) => t.name).toList(),
    'activities': trip.activities.map((a) => a.name).toList(),
    'country_code': trip.countryCode,
    'weather': trip.weather?.toJson(),
  };

  Trip _rowToTrip(Map<String, dynamic> row) => Trip(
    id: row['id'] as String,
    destination: row['destination'] as String,
    startDate: DateTime.parse(row['start_date'] as String),
    endDate: DateTime.parse(row['end_date'] as String),
    types: (row['types'] as List<dynamic>)
        .map((t) => TripType.values.byName(t as String))
        .toList(),
    peopleCount: row['people_count'] as int,
    activities: (row['activities'] as List<dynamic>? ?? [])
        .map((a) => TripActivity.values.byName(a as String))
        .toList(),
    weather: row['weather'] != null
        ? TripWeather.fromJson(row['weather'] as Map<String, dynamic>)
        : null,
    countryCode: row['country_code'] as String?,
    ownerId: row['user_id'] as String?,
  );

  /// Re-pulls trips from Supabase for the current session — used after
  /// accepting a share invite so the newly-shared trip shows up right
  /// away, without waiting for the next sign-in. No-op if not signed in
  /// with sync enabled.
  Future<void> refreshFromRemote() async {
    final userId = currentUserId(ref);
    if (userId == null || !canSync(ref)) return;
    await _syncFromRemote(userId);
  }

  Future<void> _syncFromRemote(String userId) async {
    try {
      // No `.eq('user_id', ...)` filter here on purpose — RLS already
      // scopes this to trips the user owns AND ones shared with them, so
      // filtering by owner here would hide shared trips.
      final rows = await Supabase.instance.client.from('trips').select();
      final remoteTrips = rows.map(_rowToTrip).toList();
      if (remoteTrips.isEmpty) {
        final owned = [
          for (final trip in state)
            trip.ownerId == null ? trip.copyWith(ownerId: userId) : trip,
        ];
        state = owned;
        await _persist();
        for (final trip in owned) {
          await _pushTrip(trip);
        }
        return;
      }
      state = remoteTrips;
      await _persist();
    } catch (error) {
      debugPrint('No se pudieron sincronizar los viajes: $error');
    }
  }

  Future<void> _pushTrip(Trip trip) async {
    final userId = currentUserId(ref);
    if (userId == null) return;
    try {
      await Supabase.instance.client
          .from('trips')
          .upsert(_tripToRow(trip, userId));
    } catch (error) {
      debugPrint('No se pudo sincronizar el viaje: $error');
    }
  }

  Future<void> _deleteRemoteTrip(String id) async {
    try {
      await Supabase.instance.client.from('trips').delete().eq('id', id);
    } catch (error) {
      debugPrint('No se pudo borrar el viaje remoto: $error');
    }
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
      ownerId: currentUserId(ref),
    );
    state = [trip, ...state];
    _persist();
    if (canSync(ref)) _pushTrip(trip);
    return trip;
  }

  /// Only the owner can delete a trip — a collaborator calling this on a
  /// shared trip would have the remote delete rejected by RLS anyway, but
  /// without this guard the trip would still vanish from *their* local
  /// state, which is misleading (it still exists for everyone else).
  void removeTrip(String id) {
    Trip? trip;
    for (final t in state) {
      if (t.id == id) {
        trip = t;
        break;
      }
    }
    final isOwner =
        trip?.ownerId == null || trip!.ownerId == currentUserId(ref);
    if (!isOwner) return;

    state = state.where((t) => t.id != id).toList();
    _persist();
    LocalStore.instance.remove('packing_$id');
    LocalStore.instance.remove('suitcases_$id');
    if (canSync(ref)) _deleteRemoteTrip(id);
  }
}

final tripsProvider = StateNotifierProvider<TripsNotifier, List<Trip>>((ref) {
  return TripsNotifier(ref);
});
