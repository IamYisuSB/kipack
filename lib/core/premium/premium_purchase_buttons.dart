import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_provider.dart';
import '../billing/billing_provider.dart';
import '../billing/billing_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Real monthly/annual purchase buttons for the Premium upsell — shared by
/// [requirePremium]'s upsell sheet and `PremiumLockedContent` so the
/// offer-list/purchase logic isn't duplicated between them. Shows a
/// sign-in prompt instead of buttons when signed out — purchases need to
/// be tied to an account for server verification and cross-device restore
/// (see `PurchaseVerificationService`).
class PremiumPurchaseButtons extends ConsumerWidget {
  const PremiumPurchaseButtons({super.key, this.onPurchaseStarted});

  /// Called right after a purchase flow is successfully *launched* — not
  /// when it completes, which arrives later via the purchase stream once
  /// server-verified. Callers use this to e.g. close a bottom sheet.
  final VoidCallback? onPurchaseStarted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final isSignedIn = ref.watch(authStateProvider).asData?.value != null;

    if (!isSignedIn) {
      return Text(
        l10n.premiumSignInRequired,
        style: AppTextStyles.body.copyWith(color: secondary),
      );
    }

    final offersAsync = ref.watch(premiumOffersProvider);
    return offersAsync.when(
      data: (offers) {
        if (offers.isEmpty) {
          return Text(
            l10n.premiumOffersUnavailable,
            style: AppTextStyles.body.copyWith(color: secondary),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final offer in offers) ...[
              _OfferButton(offer: offer, onPurchaseStarted: onPurchaseStarted),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Text(
        l10n.premiumOffersError,
        style: AppTextStyles.body.copyWith(color: AppColors.error),
      ),
    );
  }
}

class _OfferButton extends ConsumerStatefulWidget {
  const _OfferButton({required this.offer, this.onPurchaseStarted});

  final GooglePlayProductDetails offer;
  final VoidCallback? onPurchaseStarted;

  @override
  ConsumerState<_OfferButton> createState() => _OfferButtonState();
}

class _OfferButtonState extends ConsumerState<_OfferButton> {
  bool _isBuying = false;

  Future<void> _buy() async {
    setState(() => _isBuying = true);
    final launched = await billingService.buy(widget.offer);
    if (!mounted) return;
    setState(() => _isBuying = false);
    if (launched) {
      widget.onPurchaseStarted?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).premiumPurchaseError),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final basePlanId = billingService.basePlanIdOf(widget.offer);
    final label = basePlanId == kAnnualBasePlanId
        ? l10n.premiumOfferAnnual(widget.offer.price)
        : l10n.premiumOfferMonthly(widget.offer.price);
    return ElevatedButton(
      onPressed: _isBuying ? null : _buy,
      child: _isBuying
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
