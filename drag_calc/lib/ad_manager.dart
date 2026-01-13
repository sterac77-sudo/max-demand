import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Centralized ad manager for banners & interstitials.
/// Uses Google test ad unit IDs; replace with your real IDs before release.
class AdManager {
  // Only Android/iOS builds can use google_mobile_ads; web/desktop skip.
  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool _initialized = false;
  static InterstitialAd? _interstitial;
  static DateTime? _lastInterstitialShow;

  // Production AdMob IDs
  static const String bannerTestId = 'ca-app-pub-2318170293675282/9089442015';
  static const String interstitialTestId =
      'ca-app-pub-2318170293675282/6463278671';

  static Future<void> initialize() async {
    if (!isSupported) return;
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    loadInterstitial();
  }

  static void loadInterstitial() {
    if (!isSupported) return;
    InterstitialAd.load(
      adUnitId: interstitialTestId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          ad.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          _interstitial = null;
        },
      ),
    );
  }

  static void showInterstitial({VoidCallback? onDismissed}) {
    if (!isSupported) {
      onDismissed?.call();
      return;
    }
    final ad = _interstitial;
    if (ad == null) {
      onDismissed?.call();
      return;
    }
    // Simple pacing: avoid showing more often than every 25 seconds.
    final now = DateTime.now();
    if (_lastInterstitialShow != null &&
        now.difference(_lastInterstitialShow!).inSeconds < 25) {
      onDismissed?.call();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _lastInterstitialShow = DateTime.now();
        loadInterstitial();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadInterstitial();
        onDismissed?.call();
      },
    );
    ad.show();
    _interstitial = null; // Prevent reuse
  }
}

/// Reusable banner widget.
class AdBanner extends StatefulWidget {
  final AdSize size;
  const AdBanner({super.key, this.size = AdSize.banner});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _banner;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (!AdManager.isSupported) return;
    _banner = BannerAd(
      size: widget.size,
      adUnitId: AdManager.bannerTestId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _loaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() => _loaded = false);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _banner == null) {
      return const SizedBox(height: 0);
    }
    return SizedBox(
      width: _banner!.size.width.toDouble(),
      height: _banner!.size.height.toDouble(),
      child: AdWidget(ad: _banner!),
    );
  }
}
