import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../billing/remove_ads_service.dart';
import 'ad_config.dart';
import 'ads_service.dart';

/// An adaptive banner that takes up no space at all until an ad has
/// actually loaded (no empty placeholder box if ads are off, consent was
/// refused, there's no fill, or the user bought "remove ads").
class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key, this.horizontalPadding = 48});

  /// Total horizontal padding around the slot, so the ad is sized to the
  /// width it really gets.
  final double horizontalPadding;

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  BannerAd? _ad;
  bool _isLoaded = false;
  bool _requested = false;

  @override
  void initState() {
    super.initState();
    adsService.ready.addListener(_maybeLoad);
    removeAdsService.adsRemoved.addListener(_onAdsRemovedChanged);
  }

  void _onAdsRemovedChanged() {
    if (mounted) setState(() {});
    _maybeLoad();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeLoad();
  }

  Future<void> _maybeLoad() async {
    if (_requested ||
        !adsService.ready.value ||
        removeAdsService.adsRemoved.value ||
        !mounted) {
      return;
    }
    _requested = true;
    final width = (MediaQuery.sizeOf(context).width - widget.horizontalPadding)
        .truncate();
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (size == null || !mounted) return;
    _ad = BannerAd(
      adUnitId: AdConfig.bannerId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _ad = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    adsService.ready.removeListener(_maybeLoad);
    removeAdsService.adsRemoved.removeListener(_onAdsRemovedChanged);
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_isLoaded || ad == null || removeAdsService.adsRemoved.value) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }
}
