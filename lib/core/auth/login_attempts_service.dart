import 'package:supabase_flutter/supabase_flutter.dart';

/// Result of a lockout check/record — [allowed] is false only while
/// [lockedUntil] is still in the future.
class LoginAttemptStatus {
  const LoginAttemptStatus({
    required this.allowed,
    required this.remainingAttempts,
    this.lockedUntil,
  });

  final bool allowed;
  final int remainingAttempts;
  final DateTime? lockedUntil;
}

/// Per-account (by email) sign-in lockout — separate from Supabase's own
/// IP-based auth rate limits (see login_attempts.sql for why both exist).
/// Backed by three SECURITY DEFINER Postgres functions, callable
/// pre-authentication since sign-in itself hasn't happened yet.
class LoginAttemptsService {
  const LoginAttemptsService();

  SupabaseClient get _client => Supabase.instance.client;

  LoginAttemptStatus _fromRow(Map<String, dynamic> row) {
    final lockedUntilRaw = row['locked_until'] as String?;
    return LoginAttemptStatus(
      allowed: row['allowed'] as bool? ?? lockedUntilRaw == null,
      remainingAttempts: row['remaining_attempts'] as int? ?? 0,
      lockedUntil: lockedUntilRaw != null
          ? DateTime.parse(lockedUntilRaw)
          : null,
    );
  }

  /// Checked before attempting sign-in — if [LoginAttemptStatus.allowed] is
  /// false, the sign-in call should never be made.
  Future<LoginAttemptStatus> check(String email) async {
    final rows = await _client.rpc(
      'check_login_attempt',
      params: {'p_email': email},
    );
    return _fromRow((rows as List).first as Map<String, dynamic>);
  }

  /// Called right after a "wrong password" sign-in failure — increments the
  /// counter and, once it reaches the limit, locks the account for a fixed
  /// window (see login_attempts.sql).
  Future<LoginAttemptStatus> recordFailure(String email) async {
    final rows = await _client.rpc(
      'record_failed_login',
      params: {'p_email': email},
    );
    return _fromRow((rows as List).first as Map<String, dynamic>);
  }

  /// Called right after a successful sign-in, so a legitimate user's next
  /// mistyped password starts counting from zero again.
  Future<void> clear(String email) async {
    try {
      await _client.rpc('clear_login_attempts', params: {'p_email': email});
    } catch (_) {
      // Best-effort — worst case the counter isn't reset until the next
      // successful login clears it instead.
    }
  }
}

const loginAttemptsService = LoginAttemptsService();
