import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'admob_config.dart';

class AdMobInterstitialService {
  const AdMobInterstitialService._();

  static Future<InterstitialAd?> loadInterstitial() async {
    InterstitialAd? interstitial;

    await InterstitialAd.load(
      adUnitId: AdMobConfig.interstitialUnitId,
      request: AdMobConfig.defaultRequest,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => interstitial = ad,
        onAdFailedToLoad: (error) => interstitial = null,
      ),
    );

    return interstitial;
  }
}
