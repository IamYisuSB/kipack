import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';

/// Owns everything ad-related: the GDPR consent flow (Google's UMP form,
/// required to serve ads to EU users), SDK init, and a single preloaded
/// interstitial.
///
/// Interstitials are deliberately rationed: they're only requested at two
/// moments (while a new trip's list is generating, and when opening the
/// map), and never more than once per [_minInterval] no matter which of
/// those triggers it.
class AdsService {
  AdsService._();

  static const _minInterval = Duration(minutes: 3);

  /// Flips to true once consent is resolved and the SDK is initialized —
  /// banners listen to this so they can load as soon as it's allowed.
  final ready = ValueNotifier<bool>(false);

  InterstitialAd? _interstitial;
  bool _isLoadingInterstitial = false;
  DateTime? _lastInterstitialAt;
  Future<void>? _init;

  /// Safe to call more than once; only the first call does anything.
  Future<void> init() => _init ??= _doInit();

  Future<void> _doInit() async {
    await _gatherConsent();
    if (!await ConsentInformation.instance.canRequestAds()) return;
    await MobileAds.instance.initialize();
    ready.value = true;
    _loadInterstitial();
  }

  Future<void> _gatherConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => ConsentForm.loadAndShowConsentFormIfRequired((error) {
        if (error != null) debugPrint('Consent form error: ${error.message}');
        done.complete();
      }),
      (error) {
        debugPrint('Consent info error: ${error.message}');
        done.complete();
      },
    );
    return done.future;
  }

  void _loadInterstitial() {
    if (_interstitial != null || _isLoadingInterstitial) return;
    _isLoadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingInterstitial = false;
          _interstitial = ad;
        },
        onAdFailedToLoad: (error) {
          _isLoadingInterstitial = false;
          debugPrint('Interstitial failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Shows the preloaded interstitial if one is ready and the cooldown has
  /// passed; otherwise does nothing. Never waits for an ad to load — the
  /// user is never kept waiting on an ad.
  void showInterstitial() {
    final ad = _interstitial;
    final last = _lastInterstitialAt;
    if (ad == null) {
      if (ready.value) _loadInterstitial();
      return;
    }
    if (last != null && DateTime.now().difference(last) < _minInterval) return;

    _interstitial = null;
    _lastInterstitialAt = DateTime.now();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitial();
      },
    );
    ad.show();
  }

  /// Whether the user must be offered a way to change their ad consent
  /// (true for EU users) — the Settings screen shows a button when so.
  Future<bool> isPrivacyOptionsRequired() async =>
      await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
      PrivacyOptionsRequirementStatus.required;

  void showPrivacyOptions() {
    ConsentForm.showPrivacyOptionsForm((error) {
      if (error != null) debugPrint('Privacy options error: ${error.message}');
    });
  }
}

final adsService = AdsService._();
