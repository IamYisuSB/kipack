import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../onboarding/onboarding_provider.dart';
import 'app_shell.dart';

/// Decides between the first-run onboarding flow and the real app shell.
/// [onboardingSeenProvider] starts null while it reads SharedPreferences —
/// during that instant this renders a blank scaffold instead of flashing
/// onboarding and then immediately swapping to the app shell (or vice versa).
class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSeenOnboarding = ref.watch(onboardingSeenProvider);
    if (hasSeenOnboarding == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    return hasSeenOnboarding ? const AppShell() : const OnboardingScreen();
  }
}
