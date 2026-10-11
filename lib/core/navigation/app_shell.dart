import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/map/screens/trips_map_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/trips/screens/trips_list_screen.dart';
import '../ads/ads_service.dart';
import '../../l10n/app_localizations.dart';
import 'floating_nav_bar.dart';

/// Top-level shell with the three main destinations: trips, map, settings.
///
/// The map tab is only built the first time it's opened — its world map
/// data (~250 countries) is expensive to parse, and there's no reason to
/// pay that cost on every app launch if the user never visits it.
///
/// Ads (and the consent form they need) are started from here rather than
/// from main(), so a first-time user finishes onboarding before seeing it.
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

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;
  bool _mapVisited = false;

  @override
  void initState() {
    super.initState();
    adsService.init();
  }

  void _onDestinationSelected(int index) {
    if (index == 1 && _index != 1) adsService.showInterstitial();
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_index == 1) _mapVisited = true;
    final l10n = AppLocalizations.of(context);
    final navItems = [
      NavItem(icon: Icons.card_travel_rounded, label: l10n.navTrips),
      NavItem(icon: Icons.public_rounded, label: l10n.navMap),
      NavItem(icon: Icons.settings_outlined, label: l10n.navAccount),
    ];

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
              if (_mapVisited)
                const TripsMapScreen()
              else
                const SizedBox.shrink(),
              const SettingsScreen(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingNavBar(
              items: navItems,
              selectedIndex: _index,
              onDestinationSelected: _onDestinationSelected,
            ),
          ),
        ],
      ),
    );
  }
}
