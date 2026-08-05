import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../storage/local_store.dart';

enum FeedbackType { bug, suggestion }

const _lastSubmitKey = 'feedback_last_submit_at_ms';

/// Thrown by [FeedbackService.submit] when called again before
/// [FeedbackService.cooldown] has passed since the last successful send.
class FeedbackCooldownException implements Exception {
  const FeedbackCooldownException(this.remaining);

  final Duration remaining;
}

/// Sends a bug report or suggestion to the `feedback` table. Works for
/// guests too (no account needed) — the table's RLS policy allows inserts
/// from the anon role.
///
/// Guarded against spam/abuse on two layers: a client-side cooldown here
/// (persisted, so restarting the app doesn't reset it) stops one device
/// from hammering the button, and a server-side trigger on the `feedback`
/// table (`enforce_feedback_rate_limit`) caps inserts per user/anonymous
/// caller regardless of client — a scripted attacker hitting the REST
/// endpoint directly, bypassing the app, would still be capped there.
class FeedbackService {
  const FeedbackService();

  static const cooldown = Duration(seconds: 60);

  /// Time left before another submission is allowed, or null if none.
  Future<Duration?> remainingCooldown() async {
    final lastMs = await LocalStore.instance.readInt(_lastSubmitKey);
    if (lastMs == null) return null;
    final elapsed = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(lastMs),
    );
    final remaining = cooldown - elapsed;
    return remaining.isNegative || remaining == Duration.zero
        ? null
        : remaining;
  }

  Future<void> submit({
    required FeedbackType type,
    required String message,
    String? contactEmail,
  }) async {
    final remaining = await remainingCooldown();
    if (remaining != null) {
      throw FeedbackCooldownException(remaining);
    }

    final client = Supabase.instance.client;
    try {
      await client.from('feedback').insert({
        'type': type.name,
        'message': message,
        'user_id': client.auth.currentUser?.id,
        'contact_email': contactEmail,
      });
      await LocalStore.instance.writeInt(
        _lastSubmitKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (error) {
      // Rethrown so the UI can still show its own "failed" message, but
      // logged first since that generic UI message alone can't tell us why.
      debugPrint('No se pudo enviar el feedback: $error');
      rethrow;
    }
  }
}

const feedbackService = FeedbackService();
