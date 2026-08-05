import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase Auth. Only reachable through the Account
/// tab, which is Premium-gated — free/guest mode never touches this and
/// keeps working entirely on local storage.
class AuthService {
  const AuthService();

  /// Must also be registered as a Redirect URL in the Supabase dashboard
  /// (Authentication → URL Configuration) — Supabase silently ignores any
  /// `redirectTo` that isn't on that allow-list.
  static const passwordResetRedirect = 'kipack://reset-callback';

  /// Same deal as [passwordResetRedirect] — without this, Supabase falls
  /// back to the project's default Site URL for the "confirm your email"
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

  /// Sends a "reset your password" email. Tapping its link opens the app via
  /// [passwordResetRedirect] and fires [AuthChangeEvent.passwordRecovery] on
  /// [onAuthStateChange] once Supabase has exchanged the link for a session —
  /// that's the app's cue to prompt for a new password (see [ResetPasswordScreen]).
  Future<void> sendPasswordResetEmail(String email) {
    return _auth.resetPasswordForEmail(
      email,
      redirectTo: passwordResetRedirect,
    );
  }

  /// Sets a new password for the session established by the recovery link.
  Future<void> setNewPassword(String newPassword) {
    return _auth.updateUser(UserAttributes(password: newPassword));
  }
}

const authService = AuthService();
