import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/core/di/providers.dart';
import 'package:senseriduvarkagidi/features/premium/presentation/providers/premium_provider.dart';
import 'package:senseriduvarkagidi/features/purchase/data/services/purchase_service.dart' hide PurchaseStatus;

// ==================== Purchase State ====================

class PurchaseState {
  final bool isLoading;
  final bool productsLoaded;
  final List<ProductDetails> products;
  final String? errorMessage;
  final bool purchaseSuccess;

  const PurchaseState({
    this.isLoading = false,
    this.productsLoaded = false,
    this.products = const [],
    this.errorMessage,
    this.purchaseSuccess = false,
  });

  PurchaseState copyWith({
    bool? isLoading,
    bool? productsLoaded,
    List<ProductDetails>? products,
    String? errorMessage,
    bool? purchaseSuccess,
    bool clearError = false,
  }) {
    return PurchaseState(
      isLoading: isLoading ?? this.isLoading,
      productsLoaded: productsLoaded ?? this.productsLoaded,
      products: products ?? this.products,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      purchaseSuccess: purchaseSuccess ?? this.purchaseSuccess,
    );
  }

  ProductDetails? get proMonthly {
    try {
      return products.firstWhere(
          (p) => p.id == PurchaseProducts.proMonthly);
    } catch (_) {
      return null;
    }
  }

  ProductDetails? get proYearly {
    try {
      return products.firstWhere(
          (p) => p.id == PurchaseProducts.proYearly);
    } catch (_) {
      return null;
    }
  }
}

// ==================== Purchase Provider ====================

final purchaseProvider =
    StateNotifierProvider<PurchaseNotifier, PurchaseState>((ref) {
  return PurchaseNotifier(ref);
});

class PurchaseNotifier extends StateNotifier<PurchaseState> {
  final Ref _ref;
  final PurchaseService _service = PurchaseService();
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  PurchaseNotifier(this._ref) : super(const PurchaseState()) {
    _init();
  }

  Future<void> _init() async {
    // Satin alma stream'ini dinle
    _purchaseSub = _service.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (e) => state = state.copyWith(
        isLoading: false,
        errorMessage: 'Satin alma hatasi: $e',
      ),
    );

    await loadProducts();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final loaded = await _service.loadProducts();
      state = state.copyWith(
        isLoading: false,
        productsLoaded: loaded,
        products: _service.products,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Urunler yuklenemedi: $e',
      );
    }
  }

  Future<void> buyMonthly() async {
    final product = state.proMonthly;
    if (product == null) {
      state = state.copyWith(errorMessage: 'Aylik urun bulunamadi');
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    await _service.buy(product);
  }

  Future<void> buyYearly() async {
    final product = state.proYearly;
    if (product == null) {
      state = state.copyWith(errorMessage: 'Yillik urun bulunamadi');
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    await _service.buy(product);
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _service.restorePurchases();
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _service.completePurchase(purchase);

        // Premium'u aktif et: yerel + sunucu
        await _ref.read(premiumProvider.notifier).upgradeToPro();
        await _activatePremiumOnServer();

        state = state.copyWith(
          isLoading: false,
          purchaseSuccess: true,
        );
      } else if (purchase.status == PurchaseStatus.error) {
        if (purchase.pendingCompletePurchase) {
          await _service.completePurchase(purchase);
        }
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              purchase.error?.message ?? 'Satin alma basarisiz oldu',
        );
      } else if (purchase.status == PurchaseStatus.canceled) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Sunucuda premium'u aktif eder (30 gunluk).
  Future<void> _activatePremiumOnServer() async {
    try {
      final deviceIdAsync = _ref.read(deviceIdProvider);
      final deviceId = deviceIdAsync.valueOrNull;
      if (deviceId == null || deviceId.isEmpty) return;

      final dio = _ref.read(dioClientProvider);
      await dio.post(
        ApiConstants.activatePremium(deviceId),
        queryParameters: {'days': 30},
      );
    } catch (_) {
      // Sunucu hatasi uygulamayi durdurmasin; yerel premium zaten aktif.
    }
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    _service.dispose();
    super.dispose();
  }
}
