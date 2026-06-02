import 'dart:developer';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedInterstitialAdManager {
  void showAd({required String adUnitId, required Function(bool) onComplete}) {
    log('Loading RewardedInterstitialAd: $adUnitId');
    RewardedInterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          bool rewardEarned = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!rewardEarned) {
                onComplete(false);
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              log('RewardedInterstitialAd failed to show: $error');
              ad.dispose();
              onComplete(false);
            },
          );

          ad.show(onUserEarnedReward: (ad, reward) {
            rewardEarned = true;
            onComplete(true);
          });
        },
        onAdFailedToLoad: (error) {
          log('RewardedInterstitialAd failed to load: $error');
          // If ad fails to load, allow user to proceed instead of blocking them
          onComplete(true);
        },
      ),
    );
  }
}

class RewardedAdManager {
  void showAd({required String adUnitId, required Function(bool) onComplete}) {
    log('Loading RewardedAd: $adUnitId');
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          bool rewardEarned = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!rewardEarned) {
                onComplete(false);
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              log('RewardedAd failed to show: $error');
              ad.dispose();
              onComplete(false);
            },
          );

          ad.show(onUserEarnedReward: (ad, reward) {
            rewardEarned = true;
            onComplete(true);
          });
        },
        onAdFailedToLoad: (error) {
          log('RewardedAd failed to load: $error');
          // If ad fails to load, allow user to proceed instead of blocking them
          onComplete(true);
        },
      ),
    );
  }
}
