import 'dart:async';

import 'package:app/core/config/app_environment.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends ChangeNotifier {
  AuthController();

  StreamSubscription<AuthState>? _authSubscription;

  User? _user;
  bool _initialized = false;
  bool _processing = false;
  String? _error;

  bool get initialized => _initialized;
  bool get processing => _processing;
  String? get error => _error;
  User? get user => _user;
  bool get isSignedIn => _user != null;
  bool get enabled => AppEnvironment.hasSupabaseConfig;

  Future<void> initialize() async {
    if (!enabled) {
      _initialized = true;
      notifyListeners();
      return;
    }

    final client = Supabase.instance.client;
    _user = client.auth.currentUser;
    _authSubscription = client.auth.onAuthStateChange.listen((state) {
      _user = state.session?.user;
      notifyListeners();
    });

    _initialized = true;
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    if (!enabled) {
      return;
    }

    _processing = true;
    _error = null;
    notifyListeners();

    try {
      await Supabase.instance.client.auth.signInWithPassword(email: email.trim(), password: password);
    } on AuthException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Sign in failed. Please try again.';
    } finally {
      _processing = false;
      notifyListeners();
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    if (!enabled) {
      return;
    }

    _processing = true;
    _error = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      if (response.session == null) {
        _error = 'Account created. Check your email to verify, then sign in.';
      }
    } on AuthException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Sign up failed. Please try again.';
    } finally {
      _processing = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (!enabled) {
      return;
    }

    await Supabase.instance.client.auth.signOut();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
