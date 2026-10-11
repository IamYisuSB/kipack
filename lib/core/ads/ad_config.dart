import 'package:flutter/foundation.dart';

/// AdMob ad unit ids. Debug builds always use Google's official test ids —
/// clicking your own real ads during development can get the AdMob account
/// suspended. Release builds use the real ids below once they're filled in
/// (until then they fall back to test ads, which show but earn nothing).
///
/// The AdMob *app* id lives separately in android/app/src/main/AndroidManifest.xml.
class AdConfig {
  const AdConfig._();

  static const _releaseBannerId = 'ca-app-pub-6412956832732753/3026107176';
  static const _releaseInterstitialId =
      'ca-app-pub-6412956832732753/5427900077';

  static const _testBannerId = 'ca-app-pub-3940256099942544/9214589741';
  static const _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  static String get bannerId =>
      kReleaseMode && _releaseBannerId.isNotEmpty
          ? _releaseBannerId
          : _testBannerId;

  static String get interstitialId =>
      kReleaseMode && _releaseInterstitialId.isNotEmpty
          ? _releaseInterstitialId
          : _testInterstitialId;
}
