abstract class SubscriptionPurchaseBridge {
  Future<Map<String, dynamic>> getCatalog({required String productId});

  Future<Map<String, dynamic>> purchaseAnnualPlan({required String productId});

  Future<List<Map<String, dynamic>>> restorePurchases();
}
