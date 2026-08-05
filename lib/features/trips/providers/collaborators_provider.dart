import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/trip_collaborator.dart';

/// Who a trip is shared with. Cloud-only (no local cache) — sharing is
/// meaningless without a live connection to Supabase anyway.
class CollaboratorsNotifier extends StateNotifier<List<TripCollaborator>> {
  CollaboratorsNotifier(this.tripId) : super(const []) {
    refresh();
  }

  final String tripId;

  Future<void> refresh() async {
    try {
      final rows = await Supabase.instance.client
          .from('trip_collaborators')
          .select('*, profiles(display_name, avatar_url)')
          .eq('trip_id', tripId);
      state = rows.map(TripCollaborator.fromRow).toList();
    } catch (_) {
      // Leave state as-is — most likely a transient network error, and an
      // empty/stale list here just means the sharing sheet looks empty
      // rather than the app breaking.
    }
  }

  /// Throws on failure (e.g. already invited) so the UI can show why.
  Future<void> invite(String email) async {
    await Supabase.instance.client.from('trip_collaborators').insert({
      'trip_id': tripId,
      'invited_email': email.trim().toLowerCase(),
    });
    await refresh();
  }

  Future<void> remove(String collaboratorId) async {
    await Supabase.instance.client
        .from('trip_collaborators')
        .delete()
        .eq('id', collaboratorId);
    await refresh();
  }
}

final collaboratorsProvider =
    StateNotifierProvider.family<
      CollaboratorsNotifier,
      List<TripCollaborator>,
      String
    >((ref, tripId) {
      return CollaboratorsNotifier(tripId);
    });
