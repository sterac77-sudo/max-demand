import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'subscription_manager.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  final SubscriptionManager _subscriptionManager = SubscriptionManager();

  // Real AdMob Ad Unit IDs
  static const String bannerAdUnitId = 'ca-app-pub-2318170293675282/3862942162';
  static const String interstitialAdUnitId =
      'ca-app-pub-2318170293675282/3594800110';

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  int _calculationCount = 0;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  bool get shouldShowAds => !_subscriptionManager.isPremium;

  // Load banner ad
  Future<BannerAd?> loadBannerAd() async {
    if (!shouldShowAds) return null;

    final Completer<BannerAd?> completer = Completer();

    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded');
          completer.complete(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
          completer.complete(null);
        },
      ),
    );

    await _bannerAd?.load();
    return completer.future;
  }

  // Load interstitial ad
  Future<void> loadInterstitialAd() async {
    if (!shouldShowAds) return;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print('Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  // Show interstitial ad after every 3rd calculation
  void onCalculationCompleted() {
    if (!shouldShowAds) return;

    _calculationCount++;
    if (_calculationCount % 3 == 0) {
      showInterstitialAd();
    }
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Interstitial ad failed to show: $error');
        ad.dispose();
        loadInterstitialAd();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}
