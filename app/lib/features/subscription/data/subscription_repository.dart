import 'dart:convert';

import 'package:app/core/config/app_environment.dart';
import 'package:app/core/storage/app_preferences.dart';
import 'package:app/features/subscription/domain/subscription_tier.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionRepository {
  SubscriptionRepository(this._preferences);

  final AppPreferences _preferences;

  static const _keyTier = 'subscription.tier';
  static const _keyEarlySupporter = 'subscription.early_supporter';

  SubscriptionTier loadTier() => SubscriptionTierX.fromStorage(_preferences.getString(_keyTier));

  bool loadEarlySupporter() => _preferences.getBool(_keyEarlySupporter) ?? false;

  Future<void> saveTier(SubscriptionTier tier) async {
    await _preferences.setString(_keyTier, tier.storageValue);
  }

  Future<void> saveEarlySupporter(bool value) async {
    await _preferences.setBool(_keyEarlySupporter, value);
  }

  Future<SubscriptionTier?> fetchTierFromBackend() async {
    if (!AppEnvironment.hasSupabaseConfig) {
      return null;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      return null;
    }

    final rows = await Supabase.instance.client
        .from('subscriptions')
        .select('is_premium')
        .eq('user_id', userId)
        .limit(1);

    if (rows.isEmpty) {
      return SubscriptionTier.free;
    }

    final row = rows.first;
    final isPremium = row['is_premium'] as bool? ?? false;
    return isPremium ? SubscriptionTier.premium : SubscriptionTier.free;
  }

  Future<bool> validateAndSyncReceipt({
    required String provider,
    required String productId,
    required String receiptToken,
    String? orderId,
  }) async {
    if (!AppEnvironment.hasSupabaseConfig) {
      return false;
    }

    final session = Supabase.instance.client.auth.currentSession;
    final user = Supabase.instance.client.auth.currentUser;
    if (session == null || user == null) {
      return false;
    }

    final uri = Uri.parse('${AppEnvironment.supabaseUrl}/functions/v1/subscription-webhook');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'apikey': AppEnvironment.supabaseAnonKey,
        'Authorization': 'Bearer ${session.accessToken}',
      },
      body: jsonEncode({
        'user_id': user.id,
        'provider': provider,
        'product_id': productId,
        'receipt_token': receiptToken,
        'order_id': orderId,
      }),
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
