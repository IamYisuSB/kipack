import '../storage/local_store.dart';

const _pendingRecoveryKey = 'pending_password_recovery';

/// Tapping a "reset your password" email link signs the user into a
/// temporary Supabase "recovery" session — before they've actually proven
/// they know any password. If that session is left alone (e.g. the user
/// backs out of [ResetPasswordScreen] without setting a new one, or force-
/// closes the app mid-flow), the rest of the app has no way to tell it
/// apart from a normal signed-in session, which would let anyone with
/// access to the victim's inbox get into the account without ever knowing
/// a password.
///
/// This flag is set the moment a recovery session is detected and cleared
/// only once a new password is actually saved — [main] checks it on every
/// cold start and signs out if it's still set, so an abandoned recovery
/// session never survives closing and reopening the app either.
class PasswordRecoveryGuard {
  const PasswordRecoveryGuard();

  Future<bool> isPending() => LocalStore.instance.readBool(_pendingRecoveryKey);

  Future<void> markPending() =>
      LocalStore.instance.writeBool(_pendingRecoveryKey, true);

  Future<void> clear() =>
      LocalStore.instance.writeBool(_pendingRecoveryKey, false);
}

const passwordRecoveryGuard = PasswordRecoveryGuard();
