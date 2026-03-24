import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class IAPService {
  final Ref _ref;
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  List<ProductDetails> products = [];
  bool isAvailable = false;

  static const String proMonthlyId = 'examai_pro_monthly';

  IAPService(this._ref);

  Future<void> init() async {
    isAvailable = await _iap.isAvailable();
    if (!isAvailable) return;

    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint('IAP Error: $error');
    });

    await fetchProducts();
  }

  Future<void> fetchProducts() async {
    final ProductDetailsResponse response =
        await _iap.queryProductDetails({proMonthlyId});
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }
    products = response.productDetails;
  }

  Future<void> buySubscription() async {
    if (products.isEmpty) {
      await fetchProducts();
    }
    if (products.isEmpty) return;

    final productDetails = products.firstWhere((p) => p.id == proMonthlyId);
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show loading if needed
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Purchase Error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            // Refresh user data to show PRO status
            _ref.read(authProvider.notifier).refreshUser();
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Send to backend for actual verification
    try {
      final api = _ref.read(apiServiceProvider);
      final response = await api.post('/subscription/verify', data: {
        'productId': purchaseDetails.productID,
        'verificationData': purchaseDetails.verificationData.serverVerificationData,
        'source': purchaseDetails.verificationData.source,
      });
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Verification failed: $e');
      return false;
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}
