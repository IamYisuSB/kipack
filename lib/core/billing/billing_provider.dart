import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../premium/premium_provider.dart';
import '../sync/sync_context.dart';
import 'billing_service.dart';
import 'purchase_verification_service.dart';

/// Live monthly/annual offers for [kPremiumProductId] — watched by the
/// upsell UI to show real prices instead of a fake "demo" button.
final premiumOffersProvider = FutureProvider<List<GooglePlayProductDetails>>((
  ref,
) {
  return billingService.queryOffers();
});

/// Subscribes to the purchase stream once for the whole app (started from
/// `AppShell`, alive for the app's lifetime) — this is the only thing that
/// actually grants Premium. Every purchase (fresh or restored) is verified
/// server-side before `premiumProvider` is touched; nothing in the UI sets
/// it directly.
class PurchaseStreamListener {
  PurchaseStreamListener(this.ref) {
    _subscription = billingService.purchaseStream.listen(_onPurchases);
  }

  final Ref ref;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      await _handle(purchase);
    }
  }

  Future<void> _handle(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        return;
      case PurchaseStatus.error:
      case PurchaseStatus.canceled:
        if (purchase.pendingCompletePurchase) {
          await billingService.completePurchase(purchase);
        }
        return;
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        try {
          await purchaseVerificationService.verify(
            purchaseToken: purchase.verificationData.serverVerificationData,
          );
          final userId = currentUserId(ref);
          if (userId != null) {
            await ref.read(premiumProvider.notifier).refresh(userId);
          }
        } catch (_) {
          // Verification failed (network error, invalid/expired token,
          // etc.) — don't grant premium. Still complete the purchase below
          // so Google doesn't keep redelivering the same unacknowledged
          // purchase; the user can retry via "Restaurar compras" later,
          // which re-fires this same path.
        }
        if (purchase.pendingCompletePurchase) {
          await billingService.completePurchase(purchase);
        }
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}

/// Kept alive for the app's lifetime (started once from `AppShell.initState`
/// via `ref.read`, never disposed until the app itself closes) — a purchase
/// completed while the app was backgrounded still needs to be caught.
final purchaseStreamListenerProvider = Provider<PurchaseStreamListener>((ref) {
  final listener = PurchaseStreamListener(ref);
  ref.onDispose(listener.dispose);
  return listener;
});
