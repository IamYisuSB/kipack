import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/account/screens/account_screen.dart';
import '../../features/account/screens/reset_password_screen.dart';
import '../../features/map/screens/map_paywall_screen.dart';
import '../../features/map/screens/trips_map_screen.dart';
import '../../features/trips/screens/trips_list_screen.dart';
import '../../features/trips/providers/pending_invites_provider.dart';
import '../auth/auth_provider.dart';
import '../auth/password_recovery_guard.dart';
import '../billing/billing_provider.dart';
import '../premium/premium_provider.dart';
import '../../l10n/app_localizations.dart';
import 'floating_nav_bar.dart';

/// Top-level shell with the three main destinations: trips, map, account.
///
/// The map tab is only built the first time it's opened — its world map
/// data (~250 countries) is expensive to parse, and there's no reason to
/// pay that cost on every app launch if the user never visits it. The map
/// itself is a Premium-only feature: free users see a paywall screen there
/// instead. The account tab always renders (it has a bug report/suggestion
/// button that's open to everyone); only the account-management part
/// inside it is Premium-gated.
///
/// Navigation is a floating glass pill (see FloatingNavBar) instead of a
/// bar docked to the screen edge — each tab's content renders behind it
/// (via Stack, not the Scaffold's bottomNavigationBar slot) so it reads as
/// floating above the page rather than as a solid dock.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  int _index = 0;
  bool _mapVisited = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Starts listening for the app's whole lifetime — a purchase completed
    // while the app was backgrounded still needs to be caught and verified.
    // Never disposed here on purpose (see purchaseStreamListenerProvider).
    ref.read(purchaseStreamListenerProvider);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // No realtime/push — this is how a newly-shared trip invite or a lapsed
  // subscription gets noticed without the user manually pulling to
  // refresh: whenever the app comes back to the foreground, not just on
  // sign-in.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(pendingInvitesProvider.notifier).refresh();
      final userId = ref.read(authStateProvider).asData?.value?.id;
      if (userId != null) {
        ref.read(premiumProvider.notifier).refresh(userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_index == 1) _mapVisited = true;
    final isPremium = ref.watch(premiumProvider);
    final l10n = AppLocalizations.of(context);
    final navItems = [
      NavItem(icon: Icons.card_travel_rounded, label: l10n.navTrips),
      NavItem(icon: Icons.public_rounded, label: l10n.navMap),
      NavItem(icon: Icons.person_outline_rounded, label: l10n.navAccount),
    ];

    // Fires once Supabase has exchanged a "reset your password" email link
    // for a session, regardless of which tab is on screen at the time.
    ref.listen<AsyncValue<AuthState>>(authChangeEventProvider, (
      previous,
      next,
    ) {
      if (next.value?.event == AuthChangeEvent.passwordRecovery) {
        passwordRecoveryGuard.markPending();
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ResetPasswordScreen()));
      }
    });

    return Scaffold(
      // Without this, the keyboard opening anywhere in the tree (e.g. the
      // login form's fields) shrinks this Scaffold's body, which drags the
      // Positioned(bottom: 0) nav bar up with it since that's relative to
      // the body's own (now-shorter) height — each individual screen still
      // resizes correctly for its own fields regardless, so nothing here
      // ends up hidden behind the keyboard.
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          IndexedStack(
            index: _index,
            children: [
              const TripsListScreen(),
              if (!_mapVisited)
                const SizedBox.shrink()
              else if (isPremium)
                const TripsMapScreen()
              else
                const MapPaywallScreen(),
              const AccountScreen(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingNavBar(
              items: navItems,
              selectedIndex: _index,
              onDestinationSelected: (index) => setState(() => _index = index),
            ),
          ),
        ],
      ),
    );
  }
}
