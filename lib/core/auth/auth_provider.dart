import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Emits the current user (or null) whenever auth state changes — signed
/// in, signed out, token refreshed, etc. `null` means "no account" (guest),
/// which is the only mode the free tier ever needs.
final authStateProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map(
    (state) => state.session?.user,
  );
});

/// The raw auth-change stream, [AuthChangeEvent] included — needed to catch
/// [AuthChangeEvent.passwordRecovery] specifically, which [authStateProvider]
/// can't distinguish from an ordinary sign-in (both just produce a session).
final authChangeEventProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});
