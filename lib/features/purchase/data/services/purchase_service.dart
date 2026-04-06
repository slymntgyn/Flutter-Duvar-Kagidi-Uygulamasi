import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';

/// Uygulama ici satin alma urun ID'leri.
/// Google Play Console ve App Store Connect'te ayni ID'ler tanimlanmalidir.
class PurchaseProducts {
  PurchaseProducts._();

  // Subscription product IDs
  static String get proMonthly => Platform.isIOS
      ? 'com.senseriduvarkagidi.pro_monthly'
      : 'senseriduvarkagidi_pro_monthly';

  /// Yillik Pro abonelik ID'si.
  static String get proYearly => Platform.isIOS
      ? 'com.senseriduvarkagidi.pro_yearly'
      : 'senseriduvarkagidi_pro_yearly';

  static Set<String> get all => {proMonthly, proYearly};
}

/// Satin alma durumu.
enum PurchaseStatus { idle, loading, success, error, cancelled }

/// Satin alma servisi.
/// in_app_purchase paketi ile Google Play / App Store entegrasyonu.
class PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];

  /// Satin alma stream'i - null: henuz yuklenmedi.
  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  bool get isAvailable => _products.isNotEmpty;
  List<ProductDetails> get products => List.unmodifiable(_products);

  ProductDetails? get proMonthly {
    try {
      return _products.firstWhere((p) => p.id == PurchaseProducts.proMonthly);
    } catch (_) {
      return null;
    }
  }

  ProductDetails? get proYearly {
    try {
      return _products.firstWhere((p) => p.id == PurchaseProducts.proYearly);
    } catch (_) {
      return null;
    }
  }

  /// Store'dan urun bilgilerini yukle.
  Future<bool> loadProducts() async {
    final available = await _iap.isAvailable();
    if (!available) return false;

    final ProductDetailsResponse response =
        await _iap.queryProductDetails(PurchaseProducts.all);

    if (response.error != null) return false;
    _products = response.productDetails;
    return _products.isNotEmpty;
  }

  /// Urun satin al.
  Future<void> buy(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    if (product.id == PurchaseProducts.proMonthly ||
        product.id == PurchaseProducts.proYearly) {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  /// Onceki satin alimlari geri yukle (iOS icin gerekli).
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  /// Satin alma tamamlandiktan sonra onayla.
  Future<void> completePurchase(PurchaseDetails details) async {
    if (details.pendingCompletePurchase) {
      await _iap.completePurchase(details);
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
