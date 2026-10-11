import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../l10n/app_localizations.dart';
import '../storage/local_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'remove_ads_service.dart';

const _lastOfferKey = 'remove_ads_offer_last_ms';
const _offerInterval = Duration(hours: 24);

/// Shown when the price hasn't loaded from Play yet.
const _fallbackPrice = '4,99 €';

/// Offers the purchase after an interstitial, at most once per
/// [_offerInterval] so it never turns into nagging.
Future<void> maybeOfferRemoveAds(BuildContext context) async {
  if (removeAdsService.adsRemoved.value) return;
  final lastMs = await LocalStore.instance.readInt(_lastOfferKey);
  final now = DateTime.now();
  if (lastMs != null &&
      now.difference(DateTime.fromMillisecondsSinceEpoch(lastMs)) <
          _offerInterval) {
    return;
  }
  await LocalStore.instance.writeInt(_lastOfferKey, now.millisecondsSinceEpoch);
  if (!context.mounted) return;
  await showRemoveAdsSheet(context);
}

Future<void> showRemoveAdsSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RemoveAdsSheet(),
  );
}

class _RemoveAdsSheet extends StatefulWidget {
  const _RemoveAdsSheet();

  @override
  State<_RemoveAdsSheet> createState() => _RemoveAdsSheetState();
}

class _RemoveAdsSheetState extends State<_RemoveAdsSheet> {
  bool _unavailable = false;

  @override
  void initState() {
    super.initState();
    removeAdsService.adsRemoved.addListener(_onAdsRemoved);
  }

  @override
  void dispose() {
    removeAdsService.adsRemoved.removeListener(_onAdsRemoved);
    super.dispose();
  }

  // Purchase completed (or restored) while the sheet is open.
  void _onAdsRemoved() {
    if (!removeAdsService.adsRemoved.value || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final thanks = AppLocalizations.of(context).removeAdsThanks;
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(thanks)));
  }

  Future<void> _buy() async {
    setState(() => _unavailable = false);
    final started = await removeAdsService.buy();
    if (!started && mounted) setState(() => _unavailable = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(child: NoAdsIcon(size: 38)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                l10n.removeAdsTitle,
                style: AppTextStyles.title.copyWith(color: onSurface),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                l10n.removeAdsBody,
                style: AppTextStyles.body.copyWith(color: secondary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            _Perk(text: l10n.removeAdsPerkNoAds),
            _Perk(text: l10n.removeAdsPerkAiChat),
            _Perk(text: l10n.removeAdsPerkForever),
            const SizedBox(height: 20),
            if (_unavailable) ...[
              Text(
                l10n.removeAdsUnavailable,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
              if (removeAdsService.lastError != null)
                Text(
                  removeAdsService.lastError!,
                  style: AppTextStyles.caption.copyWith(
                    color: secondary,
                    fontSize: 11,
                  ),
                ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: ValueListenableBuilder<ProductDetails?>(
                valueListenable: removeAdsService.product,
                builder: (context, product, _) => ElevatedButton(
                  onPressed: _buy,
                  child: Text(
                    l10n.removeAdsBuyButton(product?.price ?? _fallbackPrice),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: removeAdsService.restore,
                  child: Text(l10n.removeAdsRestore),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.removeAdsNotNow),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Perk extends StatelessWidget {
  const _Perk({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: AppColors.primaryLight,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "AD" badge with a diagonal strike-through — a no-ads symbol, since the
/// classic Material Icons font doesn't ship the Material Symbols "ad_off"
/// glyph.
class NoAdsIcon extends StatelessWidget {
  const NoAdsIcon({super.key, this.size = 18, this.color = AppColors.accent});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: size / 11),
            ),
          ),
          Text(
            'AD',
            style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
          Transform.rotate(
            angle: -0.785398, // -45°
            child: Container(
              width: size * 0.95,
              height: size / 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
