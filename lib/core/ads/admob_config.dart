import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobConfig {
  static String get appIdAndroid => 'ca-app-pub-3940256099942544~3347511713';
  static String get appIdIOS => 'ca-app-pub-3940256099942544~1458002511';
  static String get bannerUnitId => 'ca-app-pub-3940256099942544/6300978111';
  static String get interstitialUnitId => 'ca-app-pub-3940256099942544/1033173712';
  static String get rewardedUnitId => 'ca-app-pub-3940256099942544/5224354917';
  static String get rewardedInterstitialUnitId => 'ca-app-pub-3940256099942544/5354046379';

  static const AdRequest defaultRequest = AdRequest();
}
