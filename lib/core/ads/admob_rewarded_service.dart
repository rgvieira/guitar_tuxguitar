import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'admob_config.dart';

class AdMobRewardedService {
  const AdMobRewardedService._();

  static Future<RewardedAd?> loadRewarded() async {
    RewardedAd? rewarded;

    await RewardedAd.load(
      adUnitId: AdMobConfig.rewardedUnitId,
      request: AdMobConfig.defaultRequest,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => rewarded = ad,
        onAdFailedToLoad: (error) => rewarded = null,
      ),
    );

    return rewarded;
  }
}
