import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

/// The single Play Console subscription product backing Premium (see
/// PREMIUM_ROADMAP.md) — one product with two base plans (monthly/annual,
/// priced and discounted in Play Console, not here), per Play's current
/// Subscriptions v2 model, rather than two separate products.
const kPremiumProductId = 'kipack_premium';
const kAnnualBasePlanId = 'annual';

/// Thin wrapper around [InAppPurchase]. Android-only for now (this app
/// isn't on iOS yet), so it reaches into `GooglePlayProductDetails`
/// directly rather than staying fully platform-generic.
class BillingService {
  const BillingService();

  InAppPurchase get _iap => InAppPurchase.instance;

  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  Future<bool> isAvailable() => _iap.isAvailable();

  /// One [GooglePlayProductDetails] per base plan (monthly, annual) of
  /// [kPremiumProductId] — empty if it isn't configured in Play Console
  /// yet, or the store is unreachable.
  Future<List<GooglePlayProductDetails>> queryOffers() async {
    final response = await _iap.queryProductDetails({kPremiumProductId});
    return response.productDetails
        .whereType<GooglePlayProductDetails>()
        .toList();
  }

  /// Which base plan (monthly/annual) an offer returned by [queryOffers]
  /// belongs to.
  String? basePlanIdOf(GooglePlayProductDetails offer) {
    final index = offer.subscriptionIndex;
    if (index == null) return null;
    return offer.productDetails.subscriptionOfferDetails?[index].basePlanId;
  }

  /// Launches the native purchase flow. Returns whether it launched
  /// successfully — NOT whether the purchase completed, which arrives
  /// later via [purchaseStream] and still needs server-side verification
  /// before it's trusted (see PurchaseVerificationService).
  ///
  /// [userId] is sent to Google as the purchase's "obfuscated account id"
  /// and echoed back in the server-side verification response — this is
  /// what lets verify-play-purchase confirm a purchaseToken actually
  /// belongs to the account claiming it, instead of trusting the token
  /// alone (which anyone who obtained it could otherwise replay onto a
  /// different account to get Premium for free).
  Future<bool> buy(GooglePlayProductDetails offer, {required String userId}) {
    return _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(
        productDetails: offer,
        applicationUserName: userId,
      ),
    );
  }

  Future<void> completePurchase(PurchaseDetails purchase) =>
      _iap.completePurchase(purchase);

  Future<void> restorePurchases() => _iap.restorePurchases();
}

const billingService = BillingService();
