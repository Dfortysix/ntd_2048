import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'remote_config_service.dart';

class AdManager {
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static int _gameCount = 0;
  
  // Callback khi xem xong quảng cáo có tặng thưởng
  static Function()? _onRewardedAdCompleted;
  
  // Tải quảng cáo xen kẽ
  static void loadInterstitialAd() {
    final adUnitId = RemoteConfigService().getInterstitialAdUnitId();
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print('Quảng cáo xen kẽ đã tải thành công');
        },
        onAdFailedToLoad: (error) {
          print('Quảng cáo xen kẽ tải thất bại: $error');
        },
      ),
    );
  }

  // Hiển thị quảng cáo xen kẽ
  static void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      // Tải quảng cáo mới sau khi hiển thị
      loadInterstitialAd();
    }
  }

  // Tăng số lần chơi và kiểm tra có hiển thị quảng cáo không
  static bool shouldShowAd() {
    _gameCount++;
    return _gameCount % 1 == 0; // Hiển thị quảng cáo sau mỗi 1 lần chơi
  }

  // Hiển thị quảng cáo khi game over
  static void showAdOnGameOver() {
    showInterstitialAd();
  }

  // Tải quảng cáo có tặng thưởng
  static void loadRewardedAd() {
    final adUnitId = RemoteConfigService().getRewardedAdUnitId();
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          print('Quảng cáo có tặng thưởng đã tải thành công');
        },
        onAdFailedToLoad: (error) {
          print('Quảng cáo có tặng thưởng tải thất bại: $error');
        },
      ),
    );
  }

  // Hiển thị quảng cáo có tặng thưởng
  static void showRewardedAd(Function() onCompleted) {
    _onRewardedAdCompleted = onCompleted;
    
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          // Tải quảng cáo mới sau khi hiển thị
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('Quảng cáo có tặng thưởng hiển thị thất bại: $error');
          ad.dispose();
          _rewardedAd = null;
          loadRewardedAd();
        },
      );
      
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('Người dùng nhận được phần thưởng: ${reward.amount} ${reward.type}');
          if (_onRewardedAdCompleted != null) {
            _onRewardedAdCompleted!();
            _onRewardedAdCompleted = null;
          }
        },
      );
    } else {
      print('Quảng cáo có tặng thưởng chưa sẵn sàng');
    }
  }

  // Giải phóng tài nguyên
  static void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
} 