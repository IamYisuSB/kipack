import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Subscribes to Postgres change events (insert/update/delete) on a single
/// table, optionally filtered, and calls [onChange] shortly after — used to
/// trigger the same `_syncFromRemote()` a provider already runs on sign-in
/// and pull-to-refresh, so a change made on one signed-in device shows up
/// on another without needing to background/foreground the app.
///
/// Debounced by 400ms: one local write can itself fan out into several
/// row-level events (e.g. pushing a whole duplicated packing list one item
/// at a time), which would otherwise each trigger their own full refetch.
///
/// This table-level filter is just to avoid irrelevant callbacks (e.g. a
/// different trip's packing items) — it is NOT what keeps data private.
/// RLS, already enforced on every table this app reads, is what actually
/// restricts which rows a given client receives here, same as any REST
/// read.
class RealtimeTableSync {
  RealtimeTableSync({
    required String channelName,
    required String table,
    required FutureOr<void> Function() onChange,
    PostgresChangeFilter? filter,
  }) {
    final channel = Supabase.instance.client.channel(channelName);
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          filter: filter,
          callback: (_) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 400), () {
              onChange();
            });
          },
        )
        .subscribe();
    _channel = channel;
  }

  late final RealtimeChannel _channel;
  Timer? _debounce;

  void dispose() {
    _debounce?.cancel();
    Supabase.instance.client.removeChannel(_channel);
  }
}
