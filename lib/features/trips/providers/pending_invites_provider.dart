import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/storage/local_store.dart';
import '../../../core/sync/sync_context.dart';
import '../models/pending_invite.dart';
import '../services/reminders_service.dart';
import 'trips_provider.dart';

const _notifiedIdsKey = 'notified_invite_ids';

/// Trip-collaborator invites addressed to the signed-in user that they
/// haven't accepted or declined yet. Replaces the old silent auto-join
/// (`claim_trip_invites`, no longer called) with an explicit accept step —
/// see [PendingInvitesBanner].
///
/// No realtime/push here (the app has neither) — this only refreshes on
/// sign-in and app foreground (see `AppShell`), so a new invite is noticed
/// the next time the user opens or returns to Kipack, not instantly.
class PendingInvitesNotifier extends StateNotifier<List<PendingInvite>> {
  PendingInvitesNotifier(this.ref) : super(const []) {
    ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      if (next.asData?.value != null && canSync(ref)) {
        refresh();
      } else {
        state = const [];
      }
    });
    if (canSync(ref)) refresh();
  }

  final Ref ref;

  Future<void> refresh() async {
    if (!canSync(ref)) return;
    try {
      final rows = await Supabase.instance.client.rpc('get_pending_invites');
      final invites = (rows as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(PendingInvite.fromRow)
          .toList();
      state = invites;
      await _notifyNewOnes(invites);
    } catch (_) {
      // Transient network error — leave state as-is, the banner just won't
      // show a brand-new invite until the next successful refresh.
    }
  }

  /// Fires a local notification only for invites the user hasn't already
  /// been notified about on this device, tracked by id in local storage —
  /// otherwise every refresh (e.g. every app foreground) would re-notify
  /// for the same still-pending invite.
  Future<void> _notifyNewOnes(List<PendingInvite> invites) async {
    if (invites.isEmpty) return;
    final notifiedIds = await LocalStore.instance.readStringSet(
      _notifiedIdsKey,
    );
    final newOnes = invites
        .where((i) => !notifiedIds.contains(i.inviteId))
        .toList();
    if (newOnes.isEmpty) return;
    for (final invite in newOnes) {
      await RemindersService.instance.showInviteNotification(
        destination: invite.destination,
      );
    }
    await LocalStore.instance.writeStringSet(_notifiedIdsKey, {
      ...notifiedIds,
      ...newOnes.map((i) => i.inviteId),
    });
  }

  /// Throws on failure so the UI can show an error and leave the invite in
  /// the list to retry.
  Future<void> accept(String inviteId) async {
    await Supabase.instance.client.rpc(
      'accept_trip_invite',
      params: {'p_invite_id': inviteId},
    );
    state = state.where((i) => i.inviteId != inviteId).toList();
    // Pulls the newly-shared trip into the local trips list right away,
    // instead of waiting for the next sign-in to sync it.
    await ref.read(tripsProvider.notifier).refreshFromRemote();
  }

  Future<void> decline(String inviteId) async {
    await Supabase.instance.client.rpc(
      'decline_trip_invite',
      params: {'p_invite_id': inviteId},
    );
    state = state.where((i) => i.inviteId != inviteId).toList();
  }
}

final pendingInvitesProvider =
    StateNotifierProvider<PendingInvitesNotifier, List<PendingInvite>>((ref) {
      return PendingInvitesNotifier(ref);
    });
