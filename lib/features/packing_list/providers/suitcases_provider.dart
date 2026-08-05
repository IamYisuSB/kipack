import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/local_store.dart';
import '../../../core/sync/realtime_table_sync.dart';
import '../../../core/sync/sync_context.dart';
import '../models/suitcase.dart';

class SuitcasesNotifier extends StateNotifier<List<Suitcase>> {
  SuitcasesNotifier(this.tripId, this.ref) : super(const []) {
    _ready = _load();
  }

  final String tripId;
  final Ref ref;
  static const _uuid = Uuid();
  RealtimeTableSync? _realtimeSync;

  late final Future<void> _ready;
  Future<void> get ready => _ready;

  String get _storageKey => 'suitcases_$tripId';

  Future<void> _load() async {
    final raw = await LocalStore.instance.readList(_storageKey);
    state = raw.map(Suitcase.fromJson).toList();
    if (canSync(ref)) {
      await _syncFromRemote();
      _subscribeRealtime();
    }
  }

  void _subscribeRealtime() {
    _realtimeSync?.dispose();
    _realtimeSync = RealtimeTableSync(
      channelName: 'suitcases_$tripId',
      table: 'suitcases',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'trip_id',
        value: tripId,
      ),
      onChange: _syncFromRemote,
    );
  }

  @override
  void dispose() {
    _realtimeSync?.dispose();
    super.dispose();
  }

  Future<void> _persist() async {
    await LocalStore.instance.writeList(
      _storageKey,
      state.map((s) => s.toJson()).toList(),
    );
  }

  Map<String, dynamic> _suitcaseToRow(Suitcase suitcase) => {
    'id': suitcase.id,
    'trip_id': tripId,
    'name': suitcase.name,
  };

  Suitcase _rowToSuitcase(Map<String, dynamic> row) =>
      Suitcase(id: row['id'] as String, name: row['name'] as String);

  Future<void> _syncFromRemote() async {
    try {
      final rows = await Supabase.instance.client
          .from('suitcases')
          .select()
          .eq('trip_id', tripId);
      final remote = rows.map(_rowToSuitcase).toList();
      if (remote.isEmpty) {
        for (final suitcase in state) {
          await _pushSuitcase(suitcase);
        }
        return;
      }
      state = remote;
      await _persist();
    } catch (error) {
      debugPrint('No se pudieron sincronizar las maletas: $error');
    }
  }

  /// Pulls the latest suitcases from Supabase — used by pull-to-refresh.
  /// No-op for guest/free mode (nothing to pull).
  Future<void> refresh() async {
    if (canSync(ref)) await _syncFromRemote();
  }

  Future<void> _pushSuitcase(Suitcase suitcase) async {
    try {
      await Supabase.instance.client
          .from('suitcases')
          .upsert(_suitcaseToRow(suitcase));
    } catch (error) {
      debugPrint('No se pudo sincronizar la maleta: $error');
    }
  }

  Future<void> _deleteRemoteSuitcase(String id) async {
    try {
      await Supabase.instance.client.from('suitcases').delete().eq('id', id);
    } catch (error) {
      debugPrint('No se pudo borrar la maleta remota: $error');
    }
  }

  Suitcase addSuitcase(String? name) {
    final suitcase = Suitcase(
      id: _uuid.v4(),
      name: name?.trim().isNotEmpty == true
          ? name!
          : 'Maleta ${state.length + 1}',
    );
    state = [...state, suitcase];
    _persist();
    if (canSync(ref)) _pushSuitcase(suitcase);
    return suitcase;
  }

  void removeSuitcase(String id) {
    state = state.where((s) => s.id != id).toList();
    _persist();
    if (canSync(ref)) _deleteRemoteSuitcase(id);
  }

  void seedSuitcases(List<Suitcase> suitcases) {
    state = suitcases;
    _persist();
    if (canSync(ref)) {
      for (final suitcase in suitcases) {
        _pushSuitcase(suitcase);
      }
    }
  }
}

final suitcasesProvider =
    StateNotifierProvider.family<SuitcasesNotifier, List<Suitcase>, String>((
      ref,
      tripId,
    ) {
      return SuitcasesNotifier(tripId, ref);
    });
