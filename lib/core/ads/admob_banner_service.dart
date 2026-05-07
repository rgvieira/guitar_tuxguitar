import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'admob_config.dart';

class AdMobBannerService {
  const AdMobBannerService._();

  static BannerAd createBanner({
    AdSize size = AdSize.banner,
    void Function(Ad)? onLoaded,
    void Function(Ad, LoadAdError)? onFailedToLoad,
  }) {
    final banner = BannerAd(
      size: size,
      adUnitId: AdMobConfig.bannerUnitId,
      listener: BannerAdListener(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: onFailedToLoad,
      ),
      request: AdMobConfig.defaultRequest,
    );

    banner.load();
    return banner;
  }
}
