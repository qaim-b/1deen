class AppEnvironment {
  const AppEnvironment._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static const aiProxyPath = String.fromEnvironment('AI_PROXY_PATH', defaultValue: '/functions/v1/ai-proxy');

  static bool get hasSupabaseConfig => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
