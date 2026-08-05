import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/storage/local_store.dart';
import '../../../core/sync/realtime_table_sync.dart';
import '../../../core/sync/sync_context.dart';

const _storageKey = 'manually_visited_countries';
const _table = 'manually_visited_countries';

/// Countries the user has manually marked as visited on the map,
/// independent of any trip (e.g. a country they've been to before this app
/// existed). Countries tied to an actual trip are colored separately in
/// [TripsMapScreen] and take priority — those can only be cleared by
/// deleting the trip, not by tapping the map.
///
/// Synced to Supabase for signed-in Premium users, same strategy as
/// `TripsNotifier`: on sign-in, remote replaces local if remote has data;
/// if remote is empty, whatever's local gets pushed up.
class VisitedCountriesNotifier extends StateNotifier<Set<String>> {
  VisitedCountriesNotifier(this.ref) : super(const {}) {
    _load();
    // fireImmediately: true — this provider is only created when the user
    // opens the Map tab, well after sign-in has already happened, so the
    // one-time "session restored" auth event has already fired and gone by
    // the time we start listening. Without this, sync would only ever
    // trigger on a *future* sign-in/sign-out, never on the already-signed-in
    // state that's the common case here.
    ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      final user = next.asData?.value;
      if (user != null && canSync(ref)) {
        _syncFromRemote(user.id);
        _subscribeRealtime(user.id);
      } else {
        _unsubscribeRealtime();
      }
    }, fireImmediately: true);
  }

  final Ref ref;
  RealtimeTableSync? _realtimeSync;

  Future<void> _load() async {
    state = await LocalStore.instance.readStringSet(_storageKey);
  }

  void _subscribeRealtime(String userId) {
    _realtimeSync?.dispose();
    _realtimeSync = RealtimeTableSync(
      channelName: 'visited_countries_$userId',
      table: _table,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      onChange: () => _syncFromRemote(userId),
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

  Future<void> _syncFromRemote(String userId) async {
    try {
      final rows = await Supabase.instance.client
          .from(_table)
          .select('country_code');
      final remote = rows
          .map((r) => r['country_code'] as String)
          .toSet();
      if (remote.isEmpty) {
        final local = state;
        for (final code in local) {
          await _pushRemote(code);
        }
        return;
      }
      state = remote;
      await LocalStore.instance.writeStringSet(_storageKey, state);
    } catch (error) {
      debugPrint('No se pudieron sincronizar los países marcados: $error');
    }
  }

  Future<void> _pushRemote(String countryCode) async {
    final userId = currentUserId(ref);
    if (userId == null) return;
    try {
      await Supabase.instance.client.from(_table).upsert({
        'user_id': userId,
        'country_code': countryCode,
      });
    } catch (error) {
      debugPrint('No se pudo sincronizar el país marcado: $error');
    }
  }

  Future<void> _deleteRemote(String countryCode) async {
    try {
      await Supabase.instance.client
          .from(_table)
          .delete()
          .eq('country_code', countryCode);
    } catch (error) {
      debugPrint('No se pudo borrar el país marcado remoto: $error');
    }
  }

  Future<void> toggle(String countryCode) async {
    final next = {...state};
    final wasRemoved = next.remove(countryCode);
    if (!wasRemoved) next.add(countryCode);
    state = next;
    await LocalStore.instance.writeStringSet(_storageKey, state);
    if (!canSync(ref)) return;
    if (wasRemoved) {
      await _deleteRemote(countryCode);
    } else {
      await _pushRemote(countryCode);
    }
  }
}

final visitedCountriesProvider =
    StateNotifierProvider<VisitedCountriesNotifier, Set<String>>((ref) {
      return VisitedCountriesNotifier(ref);
    });
