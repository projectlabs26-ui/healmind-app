import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'services/admob_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive (local storage)
  await HiveService.init();

  // Init notifications
  await NotificationService.init();

  // Init AdMob
  final config = RequestConfiguration(
    testDeviceIds: ['FEE5DE1E2CCCB171B365A72A341EF8D2'],
  );
  MobileAds.instance.updateRequestConfiguration(config);
  await MobileAds.instance.initialize();

  // Preload all ads
  AdMobService.loadInterstitial();
  AdMobService.loadRewarded();
  AdMobService.loadAppOpen();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const HealMindApp());
}
