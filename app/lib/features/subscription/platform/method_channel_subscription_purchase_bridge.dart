import 'package:app/features/subscription/platform/subscription_purchase_bridge.dart';
import 'package:flutter/services.dart';

class MethodChannelSubscriptionPurchaseBridge implements SubscriptionPurchaseBridge {
  MethodChannelSubscriptionPurchaseBridge() : _channel = const MethodChannel(_channelName);

  static const _channelName = 'one_deen/subscription_billing';
  final MethodChannel _channel;

  @override
  Future<Map<String, dynamic>> getCatalog({required String productId}) async {
    final value = await _channel.invokeMapMethod<String, dynamic>('getSubscriptionCatalog', {
      'productId': productId,
    });
    return value ?? <String, dynamic>{'available': false};
  }

  @override
  Future<Map<String, dynamic>> purchaseAnnualPlan({required String productId}) async {
    final value = await _channel.invokeMapMethod<String, dynamic>('purchaseAnnualPlan', {
      'productId': productId,
    });
    return value ?? <String, dynamic>{'status': 'failed'};
  }

  @override
  Future<List<Map<String, dynamic>>> restorePurchases() async {
    final value = await _channel.invokeMethod<List<dynamic>>('restorePurchases');
    if (value == null) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map((entry) => entry.map((key, item) => MapEntry(key.toString(), item)))
        .toList(growable: false);
  }
}
