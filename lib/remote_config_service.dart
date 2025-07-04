import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(minutes: 30),
    ));
    await _remoteConfig.setDefaults(<String, dynamic>{
      'banner_ad_unit_id': 'ca-app-pub-3940256099942544/6300978111',
      'interstitial_ad_unit_id': 'ca-app-pub-3940256099942544/1033173712',
      'rewarded_ad_unit_id': 'ca-app-pub-3940256099942544/5224354917',
    });
    
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // Error handling
    }
  }

  String getBannerAdUnitId() {
    return _remoteConfig.getString('banner_ad_unit_id');
  }

  String getInterstitialAdUnitId() {
    return _remoteConfig.getString('interstitial_ad_unit_id');
  }

  String getRewardedAdUnitId() {
    return _remoteConfig.getString('rewarded_ad_unit_id');
  }

  // Force fetch lại từ server
  Future<void> forceFetch() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // Error handling
    }
  }
} 