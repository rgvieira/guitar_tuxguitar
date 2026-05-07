import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'admob_config.dart';

class AdMobRewardedInterstitialService {
  const AdMobRewardedInterstitialService._();

  static Future<RewardedInterstitialAd?> loadRewardedInterstitial() async {
    RewardedInterstitialAd? ad;

    await RewardedInterstitialAd.load(
      adUnitId: AdMobConfig.rewardedInterstitialUnitId,
      request: AdMobConfig.defaultRequest,
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (rewardedAd) => ad = rewardedAd,
        onAdFailedToLoad: (error) => ad = null,
      ),
    );

    return ad;
  }
}
