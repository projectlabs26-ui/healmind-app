import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';
import '../constants/colors.dart';

/// A native ad widget that displays a medium-sized native ad.
class AdNativeWidget extends StatefulWidget {
  const AdNativeWidget({super.key});

  @override
  State<AdNativeWidget> createState() => _AdNativeWidgetState();
}

class _AdNativeWidgetState extends State<AdNativeWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNative();
  }

  void _loadNative() {
    if (AdMobService.isAdsFree) return;

    _nativeAd?.dispose();
    _nativeAd = NativeAd(
      adUnitId: AdMobService.nativeAdId,
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: AppColors.surface,
      ),
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) setState(() => _isLoaded = false);
        },
      ),
    );
    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AdMobService.isAdsFree) return const SizedBox.shrink();
    if (!_isLoaded || _nativeAd == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 320,
            minHeight: 100,
            maxHeight: 280,
          ),
          child: AdWidget(ad: _nativeAd!),
        ),
      ),
    );
  }
}