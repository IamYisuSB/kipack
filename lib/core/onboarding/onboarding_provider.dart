import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/local_store.dart';

const _storageKey = 'has_seen_onboarding';

/// Whether the first-run welcome/tour flow has already been shown. Starts
/// `null` while it reads SharedPreferences, so [RootGate] can hold a blank
/// frame instead of flashing the wrong screen before the real value is known.
class OnboardingNotifier extends StateNotifier<bool?> {
  OnboardingNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    state = await LocalStore.instance.readBool(_storageKey);
  }

  Future<void> markSeen() async {
    state = true;
    await LocalStore.instance.writeBool(_storageKey, true);
  }
}

final onboardingSeenProvider = StateNotifierProvider<OnboardingNotifier, bool?>(
  (ref) {
    return OnboardingNotifier();
  },
);
