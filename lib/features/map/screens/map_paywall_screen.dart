import 'package:flutter/material.dart';
import '../../../core/premium/premium_locked_content.dart';
import '../../../l10n/app_localizations.dart';

/// Shown instead of the map for free users. There's no payment processor
/// wired up yet — the button just flips the local premium flag, so the
/// gate itself is fully testable before real billing (Play Billing, etc.)
/// gets built.
class MapPaywallScreen extends StatelessWidget {
  const MapPaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: PremiumLockedContent(
            title: l10n.mapPaywallTitle,
            description: l10n.mapPaywallDescription,
            icon: Icons.public_rounded,
          ),
        ),
      ),
    );
  }
}
