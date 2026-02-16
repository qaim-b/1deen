import 'dart:convert';

import 'package:app/core/config/app_environment.dart';
import 'package:app/features/ai/data/ai_usage_repository.dart';
import 'package:app/features/ai/domain/ai_usage_snapshot.dart';
import 'package:app/features/subscription/domain/subscription_tier.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AiService {
  AiService(this._usageRepository);

  final AiUsageRepository _usageRepository;
  static final DateFormat _day = DateFormat('yyyy-MM-dd');
  static final DateFormat _month = DateFormat('yyyy-MM');

  AiUsageSnapshot snapshot() {
    final now = DateTime.now();
    return _usageRepository.load(dayKey: _day.format(now), monthKey: _month.format(now));
  }

  Future<String> ask({required String prompt, required SubscriptionTier tier}) async {
    final now = DateTime.now();
    final dayKey = _day.format(now);
    final monthKey = _month.format(now);

    if (prompt.trim().isEmpty) {
      throw Exception('Prompt is empty.');
    }

    if (prompt.length > 700) {
      throw Exception('Prompt too long. Keep it under 700 characters.');
    }

    final response = await _queryProxy(prompt);

    if (tier == SubscriptionTier.free) {
      await _usageRepository.incrementFree(dayKey: dayKey);
    } else {
      await _usageRepository.incrementPremium(monthKey: monthKey);
    }

    return response;
  }

  Future<String> _queryProxy(String prompt) async {
    if (!AppEnvironment.hasSupabaseConfig) {
      return 'Offline demo response: keep your answer short and focused on practical steps for prayer discipline.';
    }

    final accessToken = Supabase.instance.client.auth.currentSession?.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Sign in required to use AI.');
    }

    final url = Uri.parse('${AppEnvironment.supabaseUrl}${AppEnvironment.aiProxyPath}');
    final response = await http.post(
      url,
      headers: {
        'apikey': AppEnvironment.supabaseAnonKey,
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body) as Map<String, dynamic>?;
      final error = body?['error'] as String?;
      if (response.statusCode == 429 && error == 'free_cap_reached') {
        throw Exception('Free daily AI limit reached (3/day).');
      }
      if (response.statusCode == 429 && error == 'premium_cap_reached') {
        throw Exception('Premium monthly AI limit reached (150/month).');
      }
      throw Exception('AI service error (${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['answer'] as String? ?? 'No answer returned.';
  }
}
