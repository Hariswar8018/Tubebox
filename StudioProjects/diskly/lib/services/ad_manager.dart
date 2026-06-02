import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static bool isTest = false; // Toggle this to switch between real and test ads

  // --- Real Ad Unit IDs (Replace with your actual AdMob IDs) ---
  static const String _realBannerAdUnitIdAndroid = 'ca-app-pub-2241901350003769/2773021072';
  static const String _realBannerAdUnitIdIOS = 'YOUR_REAL_BANNER_AD_ID_IOS';

  static const String _realRewardedAdUnitIdAndroid ="ca-app-pub-2241901350003769/7836655816";
  static const String _realRewardedAdUnitIdIOS = 'YOUR_REAL_REWARDED_AD_ID_IOS';

  static const String _realNativeAdUnitIdAndroid = 'ca-app-pub-2241901350003769/8229892117';
  static const String _realNativeAdUnitIdIOS = 'YOUR_REAL_NATIVE_AD_ID_IOS';

  // --- Test Ad Unit IDs ---
  static const String _testBannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerAdUnitIdIOS = 'ca-app-pub-3940256099942544/2934735716';

  static const String _testRewardedAdUnitIdAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedAdUnitIdIOS = 'ca-app-pub-3940256099942544/1712485313';

  static const String _testNativeAdUnitIdAndroid = 'ca-app-pub-3940256099942544/2247696110';
  static const String _testNativeAdUnitIdIOS = 'ca-app-pub-3940256099942544/3986624511';

  // --- Getters ---
  static String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return isTest ? _testBannerAdUnitIdAndroid : _realBannerAdUnitIdAndroid;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return isTest ? _testBannerAdUnitIdIOS : _realBannerAdUnitIdIOS;
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return isTest ? _testRewardedAdUnitIdAndroid : _realRewardedAdUnitIdAndroid;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return isTest ? _testRewardedAdUnitIdIOS : _realRewardedAdUnitIdIOS;
    }
    return '';
  }

  static String get nativeAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return isTest ? _testNativeAdUnitIdAndroid : _realNativeAdUnitIdAndroid;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return isTest ? _testNativeAdUnitIdIOS : _realNativeAdUnitIdIOS;
    }
    return '';
  }

  // Maps added to support the VideoPlayerScreen snippet
  static Map<String, String> get rewardedInterstitialAdUnitIds => {
    'unlockFullVideo': rewardedAdUnitId,
  };

  static Map<String, String> get rewardedAdUnitIds => {
    'rewarded_download': rewardedAdUnitId,
    'downlaod_button_ad': rewardedAdUnitId,
  };

  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;

  void loadRewardedAd() {
    if (_isRewardedAdLoading || _rewardedAd != null) {
      return;
    }
    
    _isRewardedAdLoading = true;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          log('Rewarded Ad loaded successfully');
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          log('Rewarded Ad failed to load: $error');
          _rewardedAd = null;
          _isRewardedAdLoading = false;
        },
      ),
    );
  }

  void showRewardedAd({required Function() onRewardEarned}) {
    if (_rewardedAd == null) {
      log('Warning: attempt to show rewarded before loaded.');
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => log('Rewarded ad showed'),
      onAdDismissedFullScreenContent: (ad) {
        log('Rewarded ad dismissed');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // Load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      log('User earned reward: ${reward.amount} ${reward.type}');
      onRewardEarned();
    });
  }
}
