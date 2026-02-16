import 'package:app/features/subscription/data/subscription_repository.dart';
import 'package:app/features/subscription/domain/subscription_tier.dart';
import 'package:app/features/subscription/platform/subscription_purchase_bridge.dart';
import 'package:flutter/foundation.dart';

class SubscriptionController extends ChangeNotifier {
  SubscriptionController(this._repository, this._purchaseBridge);

  final SubscriptionRepository _repository;
  final SubscriptionPurchaseBridge _purchaseBridge;

  static const annualProductId = 'premium_annual_jpy_10000';

  SubscriptionTier _tier = SubscriptionTier.free;
  bool _earlySupporter = false;
  bool _processing = false;
  String? _lastError;
  Map<String, dynamic> _catalog = const {};

  SubscriptionTier get tier => _tier;
  bool get earlySupporter => _earlySupporter;
  bool get processing => _processing;
  String? get lastError => _lastError;
  Map<String, dynamic> get catalog => _catalog;

  Future<void> initialize() async {
    _tier = _repository.loadTier();
    _earlySupporter = _repository.loadEarlySupporter();
    await refreshFromBackend();
    await refreshCatalog();
  }

  Future<void> refreshCatalog() async {
    try {
      _catalog = await _purchaseBridge.getCatalog(productId: annualProductId);
      _lastError = null;
    } catch (_) {
      _catalog = const {'available': false};
      _lastError = 'Failed to load store catalog.';
    }
    notifyListeners();
  }

  Future<void> refreshFromBackend() async {
    final backendTier = await _repository.fetchTierFromBackend();
    if (backendTier == null) {
      return;
    }

    _tier = backendTier;
    await _repository.saveTier(backendTier);
    notifyListeners();
  }

  Future<void> purchaseAnnual() async {
    _processing = true;
    _lastError = null;
    notifyListeners();

    try {
      final purchase = await _purchaseBridge.purchaseAnnualPlan(productId: annualProductId);
      if ((purchase['status'] as String?) != 'purchased') {
        _lastError = 'Purchase cancelled or failed.';
        return;
      }

      final provider = purchase['provider'] as String? ?? defaultTargetPlatform.name;
      final receiptToken = purchase['receiptToken'] as String? ?? '';
      final orderId = purchase['orderId'] as String?;

      if (receiptToken.isEmpty) {
        _lastError = 'Missing receipt token from store.';
        return;
      }

      final synced = await _repository.validateAndSyncReceipt(
        provider: provider,
        productId: annualProductId,
        receiptToken: receiptToken,
        orderId: orderId,
      );

      if (!synced) {
        _lastError = 'Receipt validation failed.';
        return;
      }

      await refreshFromBackend();
    } catch (_) {
      _lastError = 'Subscription purchase failed.';
    } finally {
      _processing = false;
      notifyListeners();
    }
  }

  Future<void> restorePurchases() async {
    _processing = true;
    _lastError = null;
    notifyListeners();

    try {
      final restored = await _purchaseBridge.restorePurchases();
      if (restored.isEmpty) {
        _lastError = 'No purchases found to restore.';
        return;
      }

      final latest = restored.first;
      final provider = latest['provider'] as String? ?? defaultTargetPlatform.name;
      final receiptToken = latest['receiptToken'] as String? ?? '';
      final orderId = latest['orderId'] as String?;
      final productId = latest['productId'] as String? ?? annualProductId;

      if (receiptToken.isEmpty) {
        _lastError = 'Restore payload missing receipt token.';
        return;
      }

      final synced = await _repository.validateAndSyncReceipt(
        provider: provider,
        productId: productId,
        receiptToken: receiptToken,
        orderId: orderId,
      );

      if (!synced) {
        _lastError = 'Restore validation failed.';
        return;
      }

      await refreshFromBackend();
    } catch (_) {
      _lastError = 'Restore failed.';
    } finally {
      _processing = false;
      notifyListeners();
    }
  }

  Future<void> setEarlySupporter(bool value) async {
    _earlySupporter = value;
    notifyListeners();
    await _repository.saveEarlySupporter(value);
  }
}
