import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionManager {
  static final SubscriptionManager _instance = SubscriptionManager._internal();
  factory SubscriptionManager() => _instance;
  SubscriptionManager._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isPremium = false;

  // Replace with your actual product ID from Play Console
  static const String premiumSubscriptionId = 'premium_monthly';

  bool get isPremium => _isPremium;

  Future<void> initialize() async {
    // Listen to purchase updates
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => print('Purchase error: $error'),
    );

    // Check if user already has premium
    await _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;

    // Also verify with Play Store
    if (await _iap.isAvailable()) {
      await _iap.restorePurchases();
      // The purchase stream will be notified of any active subscriptions
    }
  }

  Future<void> _setPremiumStatus(bool isPremium) async {
    _isPremium = isPremium;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', isPremium);
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Verify and grant premium access
        if (purchaseDetails.productID == premiumSubscriptionId) {
          _setPremiumStatus(true);
        }
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _iap.completePurchase(purchaseDetails);
      }
    }
  }

  Future<bool> purchaseSubscription() async {
    if (!await _iap.isAvailable()) {
      return false;
    }

    final ProductDetailsResponse response = await _iap.queryProductDetails({
      premiumSubscriptionId,
    });

    if (response.productDetails.isEmpty) {
      print('No products found');
      return false;
    }

    final ProductDetails productDetails = response.productDetails.first;
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );

    try {
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('Purchase error: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
      await _checkPremiumStatus();
    } catch (e) {
      print('Restore error: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
