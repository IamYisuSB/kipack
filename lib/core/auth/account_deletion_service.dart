import 'package:supabase_flutter/supabase_flutter.dart';

/// Thrown when the server rejects a request/confirm call, carrying the
/// (already Spanish, user-facing) message the edge function returned.
class AccountDeletionException implements Exception {
  const AccountDeletionException(this.message);
  final String message;
}

/// Two-step, code-confirmed account deletion. Both steps run server-side
/// (see the `request-account-deletion` / `confirm-account-deletion` edge
/// functions) since actually deleting a user requires the service-role
/// key, which never belongs in the client.
class AccountDeletionService {
  const AccountDeletionService();

  SupabaseClient get _client => Supabase.instance.client;

  /// Emails a 6-digit code (valid 10 minutes) to the signed-in user's own
  /// address.
  Future<void> requestDeletionCode() async {
    final res = await _client.functions.invoke('request-account-deletion');
    if (res.status != 200) {
      throw AccountDeletionException(
        _extractError(res.data) ?? 'No se pudo enviar el código.',
      );
    }
  }

  /// Verifies [code] and, if correct, permanently deletes the account.
  Future<void> confirmDeletion(String code) async {
    final res = await _client.functions.invoke(
      'confirm-account-deletion',
      body: {'code': code},
    );
    if (res.status != 200) {
      throw AccountDeletionException(
        _extractError(res.data) ?? 'No se pudo eliminar la cuenta.',
      );
    }
    // The account (and its session) no longer exists server-side — drop
    // the local session immediately rather than waiting for the next API
    // call to fail and reveal it.
    await _client.auth.signOut();
  }

  String? _extractError(dynamic data) {
    if (data is Map && data['error'] is String) return data['error'] as String;
    return null;
  }
}

const accountDeletionService = AccountDeletionService();
