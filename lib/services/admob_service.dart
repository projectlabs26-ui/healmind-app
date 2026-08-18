import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/colors.dart';

class AdMobService {
  // ── Production Ad Unit IDs ──────────────────────────────
  static const String _bannerId = 'ca-app-pub-1691052555871805/8383604628';
  static const String _interstitialId = 'ca-app-pub-1691052555871805/7051864168';
  static const String _rewardedId = 'ca-app-pub-1691052555871805/4425700829';
  static const String _nativeId = 'ca-app-pub-1691052555871805/4915132903';
  static const String _appOpenId = 'ca-app-pub-1691052555871805/2983104137';

  static const String bannerAdId = _bannerId;
  static const String interstitialAdId = _interstitialId;
  static const String rewardedAdId = _rewardedId;
  static const String nativeAdId = _nativeId;
  static const String appOpenAdId = _appOpenId;

  // ── Ad Instances ────────────────────────────────────────
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static AppOpenAd? _appOpenAd;
  static bool _isInterstitialReady = false;
  static bool _isRewardedReady = false;
  static bool _isAppOpenShowing = false;

  // ── Interstitial Counter ────────────────────────────────
  static int _actionCount = 0;
  static const int interstitialFrequency = 3;
  static int _breathingActionCount = 0;
  static const int breathingInterstitialFrequency = 2;

  // ── Ads-Free Timer ──────────────────────────────────────
  static DateTime? _adsFreeUntil;

  // ─────────────────────────────────────────────────────────
  // Ads-Free Check
  // ─────────────────────────────────────────────────────────

  static bool get isAdsFree {
    _loadAdsFreeStatus();
    if (_adsFreeUntil != null && _adsFreeUntil!.isAfter(DateTime.now())) {
      return true;
    }
    return false;
  }

  static DateTime? get adsFreeUntil => _adsFreeUntil;

  static void _loadAdsFreeStatus() {
    if (_adsFreeUntil != null) return;
    try {
      final box = Hive.box('settings');
      final saved = box.get('ads_free_until');
      if (saved != null) {
        _adsFreeUntil = DateTime.tryParse(saved as String);
      }
    } catch (_) {}
  }

  static void setAdsFree(int hours) {
    _adsFreeUntil = DateTime.now().add(Duration(hours: hours));
    try {
      final box = Hive.box('settings');
      box.put('ads_free_until', _adsFreeUntil!.toIso8601String());
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────
  // Banner Ad
  // ─────────────────────────────────────────────────────────

  static BannerAd createBannerAd({
    required Function(BannerAd) onAdLoaded,
  }) {
    if (isAdsFree) {
      return BannerAd(
        adUnitId: bannerAdId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: const BannerAdListener(),
      );
    }

    final banner = BannerAd(
      adUnitId: bannerAdId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(ad as BannerAd),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
    banner.load();
    return banner;
  }

  // ─────────────────────────────────────────────────────────
  // Native Ad
  // ─────────────────────────────────────────────────────────

  static NativeAd? _nativeAd;

  static void loadNative() {
    if (isAdsFree) return;
    _nativeAd?.dispose();
    _nativeAd = NativeAd(
      adUnitId: nativeAdId,
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: AppColors.surface,
      ),
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _nativeAd = ad as NativeAd;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _nativeAd!.load();
  }

  static void disposeNative() {
    _nativeAd?.dispose();
    _nativeAd = null;
  }

  // ─────────────────────────────────────────────────────────
  // Interstitial Ad
  // ─────────────────────────────────────────────────────────

  static void loadInterstitial() {
    if (isAdsFree) return;
    InterstitialAd.load(
      adUnitId: interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialReady = false;
              loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialReady = false;
              loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialReady = false;
        },
      ),
    );
  }

  /// Call after journal save or CBT done. Shows interstitial every N actions.
  static void trackActionAndShowInterstitial() {
    if (isAdsFree) return;
    _actionCount++;
    if (_actionCount >= interstitialFrequency) {
      _actionCount = 0;
      showInterstitialIfReady();
    }
  }

  /// Call after breathing session. Shows interstitial every 2 sessions.
  static void trackBreathingAndShowInterstitial() {
    if (isAdsFree) return;
    _breathingActionCount++;
    if (_breathingActionCount >= breathingInterstitialFrequency) {
      _breathingActionCount = 0;
      showInterstitialIfReady();
    }
  }

  static void showInterstitialIfReady() {
    if (isAdsFree) return;
    if (_isInterstitialReady && _interstitialAd != null) {
      _interstitialAd!.show();
      _isInterstitialReady = false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // Rewarded Ad
  // ─────────────────────────────────────────────────────────

  static void loadRewarded() {
    RewardedAd.load(
      adUnitId: rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedReady = true;
        },
        onAdFailedToLoad: (error) {
          _isRewardedReady = false;
        },
      ),
    );
  }

  /// Show a rewarded ad. Returns true if the user completed the ad.
  static Future<bool> showRewardedAd() {
    final completer = Completer<bool>();

    if (!_isRewardedReady || _rewardedAd == null) {
      completer.complete(false);
      return completer.future;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isRewardedReady = false;
        loadRewarded();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isRewardedReady = false;
        loadRewarded();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
    );

    _isRewardedReady = false;
    return completer.future;
  }

  // ─────────────────────────────────────────────────────────
  // App Open Ad
  // ─────────────────────────────────────────────────────────

  static void loadAppOpen() {
    if (isAdsFree) return;
    AppOpenAd.load(
      adUnitId: appOpenAdId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
        },
      ),
    );
  }

  /// Show app open ad if available. Call when app comes to foreground.
  static void showAppOpenIfReady() {
    if (isAdsFree) return;
    if (_isAppOpenShowing) return;
    if (_appOpenAd == null) {
      loadAppOpen();
      return;
    }

    _isAppOpenShowing = true;
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenShowing = false;
        loadAppOpen();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenShowing = false;
        loadAppOpen();
      },
      onAdShowedFullScreenContent: (ad) {},
    );

    _appOpenAd!.show();
    _appOpenAd = null;
  }

  // ─────────────────────────────────────────────────────────
  // Cleanup
  // ─────────────────────────────────────────────────────────

  static void disposeAll() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _nativeAd?.dispose();
    _nativeAd = null;
  }
}