import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../storage/local_store.dart';

/// The one-time "remove ads" purchase (a non-consumable Play product).
///
/// No account or server: Google Play ties the purchase to the user's Google
/// account, so asking Play for past purchases on every launch is what
/// restores it on a new phone or reinstall — and what drops it again if
/// Google refunds it. The local flag only makes the very first frames
/// ad-free before Play answers.
class RemoveAdsService {
  RemoveAdsService._();

  static const productId = 'remove_ads';
  static const _cacheKey = 'ads_removed';

  final _iap = InAppPurchase.instance;

  /// True once the user owns the product.
  final adsRemoved = ValueNotifier<bool>(false);

  /// Store listing for the product (localized price), null until Play
  /// answers or if billing is unavailable.
  final product = ValueNotifier<ProductDetails?>(null);

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Future<void>? _init;

  /// Reads the cached flag (fast) and then syncs with Play in the
  /// background. Safe to call more than once.
  Future<void> init() => _init ??= _doInit();

  Future<void> _doInit() async {
    adsRemoved.value = await LocalStore.instance.readBool(_cacheKey);
    _subscription = _iap.purchaseStream.listen(
      _onPurchases,
      onError: (Object error) => debugPrint('Purchase stream error: $error'),
    );
    unawaited(_syncWithPlay());
  }

  Future<void> _syncWithPlay() async {
    try {
      if (!await _iap.isAvailable()) return;

      final details = await _iap.queryProductDetails({productId});
      if (details.productDetails.isNotEmpty) {
        product.value = details.productDetails.first;
      } else {
        // Shows in `adb logcat` — e.g. product not yet active in Play
        // Console, or an install Play didn't sign (sideloaded build).
        debugPrint(
          'remove_ads not returned by Play: '
          'notFound=${details.notFoundIDs} error=${details.error}',
        );
      }

      final android = _iap
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final past = await android.queryPastPurchases();
      if (past.error != null) return; // Keep the cached value on errors.
      var owned = false;
      for (final purchase in past.pastPurchases) {
        if (purchase.productID != productId) continue;
        if (purchase.status == PurchaseStatus.pending) continue;
        owned = true;
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }
      await _setRemoved(owned);
    } catch (error) {
      debugPrint('Could not sync purchases with Play: $error');
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != productId) continue;
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _setRemoved(true);
      }
      // Unacknowledged purchases are refunded by Google after 3 days.
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _setRemoved(bool value) async {
    adsRemoved.value = value;
    await LocalStore.instance.writeBool(_cacheKey, value);
  }

  /// Opens Google Play's purchase sheet. Returns false if the product
  /// isn't available (billing unavailable or not set up in Play Console).
  Future<bool> buy() async {
    var details = product.value;
    if (details == null) {
      await _syncWithPlay();
      details = product.value;
    }
    if (details == null) return false;
    return _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
    );
  }

  /// "Restaurar compra" — re-asks Play for past purchases.
  Future<void> restore() => _syncWithPlay();

  void dispose() => _subscription?.cancel();
}

final removeAdsService = RemoveAdsService._();
