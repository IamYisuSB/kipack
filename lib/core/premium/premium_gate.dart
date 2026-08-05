import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'premium_provider.dart';
import 'premium_purchase_buttons.dart';

/// Checks [premiumProvider] and, if it's off, shows an upsell sheet before
/// letting the caller proceed. Every premium-gated action (templates,
/// reminders, collaborative lists, export...) goes through this so the
/// "not premium yet" moment looks and behaves the same everywhere.
///
/// Returns true if the feature may proceed (already premium, or the user
/// activated it from the sheet), false otherwise.
Future<bool> requirePremium(
  BuildContext context,
  WidgetRef ref, {
  required String featureName,
}) async {
  if (ref.read(premiumProvider)) return true;

  final activated = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => _PremiumUpsellSheet(featureName: featureName),
  );
  return activated ?? false;
}

class _PremiumUpsellSheet extends ConsumerWidget {
  const _PremiumUpsellSheet({required this.featureName});

  final String featureName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.premiumUpsellTitle(featureName),
                  style: AppTextStyles.title.copyWith(color: onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.premiumUpsellBody(featureName),
            style: AppTextStyles.body.copyWith(color: secondary),
          ),
          const SizedBox(height: 24),
          PremiumPurchaseButtons(
            onPurchaseStarted: () => Navigator.of(context).pop(false),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.premiumNotNowButton),
            ),
          ),
        ],
      ),
    );
  }
}
