import 'package:flutter/material.dart';
import 'load_entry_screen.dart';
import 'services/ad_manager.dart';
import 'services/subscription_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdMob and subscription services
  await AdManager().initialize();
  await SubscriptionManager().initialize();

  // Preload first interstitial ad
  await AdManager().loadInterstitialAd();

  runApp(const MaxDemandCalculatorApp());
}

class MaxDemandCalculatorApp extends StatelessWidget {
  const MaxDemandCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maximum Demand Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const LoadEntryScreen(),
    );
  }
}
