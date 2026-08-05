import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_provider.dart';
import '../storage/local_store.dart';

const _storageKey = 'is_premium';

/// TEMPORARY, for the closed-testing build only — when true, every user is
/// treated as Premium, no sign-in or purchase required. **MUST be set back
/// to `false` before building the App Bundle for the production release
/// track.** Google's 12-tester/14-day closed-testing requirement is about
/// real people using the whole app, not specifically the purchase flow —
/// this exists so testers don't need per-person Play Billing test
/// purchases (or a manual SQL grant each) just to see gated features. Real
/// purchase verification (see `PurchaseStreamListener` in
/// billing_provider.dart) still runs underneath regardless; this only
/// overrides what [premiumProvider] *reports*.
const kForceTestingPremium = true;

/// Premium entitlement, backed by real Google Play purchases verified
/// server-side (see PurchaseVerificationService) — `profiles.premium_active`
/// is the source of truth once fetched; the local flag only caches it for
/// an instant read at cold start, before that fetch completes. There's no
/// public "just turn it on" setter anymore — the only way to become
/// premium is a verified purchase (see `PurchaseStreamListener` in
/// `billing_provider.dart`, which calls [refresh] after verification
/// succeeds) — aside from [kForceTestingPremium] above, for closed testing.
class PremiumNotifier extends StateNotifier<bool> {
  PremiumNotifier(this.ref) : super(kForceTestingPremium) {
    if (kForceTestingPremium) return;
    _loadCached();
    ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      final user = next.asData?.value;
      if (user != null) {
        refresh(user.id);
      } else {
        _setPremium(false);
      }
    });
  }

  final Ref ref;

  Future<void> _loadCached() async {
    state = await LocalStore.instance.readBool(_storageKey);
  }

  /// Fetches [userId]'s real entitlement from `profiles` and updates both
  /// in-memory state and the local cache. Called on sign-in and on app
  /// resume (see `AppShell`) — there's no push/webhook telling the app the
  /// moment a subscription lapses server-side, so this resume check is also
  /// what catches that, within the resolution of "next time the app is
  /// opened." The client-side expiry comparison below is a cheap extra
  /// safety net for the gap between renewals when the DB row itself hasn't
  /// been re-verified yet.
  Future<void> refresh(String userId) async {
    if (kForceTestingPremium) return;
    try {
      final row = await Supabase.instance.client
          .from('profiles')
          .select('premium_active, premium_expires_at')
          .eq('id', userId)
          .maybeSingle();
      final active = row?['premium_active'] as bool? ?? false;
      final expiresAt = row?['premium_expires_at'] as String?;
      final stillValid =
          active &&
          (expiresAt == null ||
              DateTime.parse(expiresAt).isAfter(DateTime.now()));
      await _setPremium(stillValid);
    } catch (_) {
      // Transient network error — keep whatever was last cached.
    }
  }

  Future<void> _setPremium(bool value) async {
    if (kForceTestingPremium) return;
    state = value;
    await LocalStore.instance.writeBool(_storageKey, value);
  }
}

final premiumProvider = StateNotifierProvider<PremiumNotifier, bool>((ref) {
  return PremiumNotifier(ref);
});
