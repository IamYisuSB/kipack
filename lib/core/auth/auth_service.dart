import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase Auth. Only reachable through the Account
/// tab — free/guest mode never touches this and keeps working entirely on
/// local storage.
class AuthService {
  const AuthService();

  /// Without this, Supabase falls back to the project's default Site URL
  /// link, which for a project that's never set one is `localhost:3000`
  /// (useless for a mobile app). Must also be added to the Redirect URLs
  /// allow-list in the Supabase dashboard.
  static const emailConfirmRedirect = 'kipack://confirm-callback';

  GoTrueClient get _auth => Supabase.instance.client.auth;

  User? get currentUser => _auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) {
    return _auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
      emailRedirectTo: emailConfirmRedirect,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  /// Re-authenticates with [currentPassword] before applying the change —
  /// a password change is sensitive enough to want that extra check even
  /// though the user already has a valid session.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final email = currentUser?.email;
    if (email == null) throw AuthSessionMissingException();
    await _auth.signInWithPassword(email: email, password: currentPassword);
    await _auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Supabase sends a confirmation email for the change itself, so this
  /// doesn't take effect until the user confirms it.
  Future<void> changeEmail(String newEmail) {
    return _auth.updateUser(UserAttributes(email: newEmail));
  }

  /// Sends a "reset your password" email containing a 6-digit code (the
  /// email template must include `{{ .Token }}` — see [verifyPasswordResetCode]).
  Future<void> sendPasswordResetEmail(String email) {
    return _auth.resetPasswordForEmail(email);
  }

  /// Exchanges the code from [sendPasswordResetEmail]'s email for a
  /// recovery session — fires [AuthChangeEvent.passwordRecovery] on
  /// [onAuthStateChange] on success, which `AppShell` already listens for
  /// to push [ResetPasswordScreen] (no deep link involved: entering the
  /// code IS the whole flow).
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) {
    return _auth.verifyOTP(email: email, token: code, type: OtpType.recovery);
  }

  /// Sets a new password for the session established by [verifyPasswordResetCode].
  Future<void> setNewPassword(String newPassword) {
    return _auth.updateUser(UserAttributes(password: newPassword));
  }
}

const authService = AuthService();
