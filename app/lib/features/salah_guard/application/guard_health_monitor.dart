import 'dart:async';

import 'package:app/core/diagnostics/diagnostics_controller.dart';
import 'package:app/features/salah_guard/platform_bridge/lock_bridge.dart';
import 'package:flutter/foundation.dart';

class GuardHealthMonitor extends ChangeNotifier {
  GuardHealthMonitor({
    required LockBridge lockBridge,
    required DiagnosticsController diagnosticsController,
  })  : _lockBridge = lockBridge,
        _diagnostics = diagnosticsController;

  final LockBridge _lockBridge;
  final DiagnosticsController _diagnostics;

  Timer? _timer;
  bool _healthy = true;
  DateTime? _lastCheckedAt;
  Map<String, dynamic> _engineDiagnostics = const {};
  bool _running = false;

  bool get healthy => _healthy;
  DateTime? get lastCheckedAt => _lastCheckedAt;
  Map<String, dynamic> get engineDiagnostics => _engineDiagnostics;

  Future<void> start() async {
    await _tick(reason: 'startup');
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      unawaited(_tick(reason: 'periodic'));
    });
  }

  void disposeMonitor() {
    _timer?.cancel();
  }

  Future<void> _tick({required String reason}) async {
    if (_running) {
      return;
    }

    _running = true;
    try {
      final isHealthy = await _lockBridge.isEngineHealthy();
      final diagnostics = await _lockBridge.getEngineDiagnostics();
      _engineDiagnostics = diagnostics;
      _lastCheckedAt = DateTime.now();

      if (isHealthy != _healthy) {
        _healthy = isHealthy;
      }
      notifyListeners();

      if (!isHealthy) {
        await _diagnostics.warn(
          'guard_unhealthy',
          details: {
            'reason': reason,
            'engine': diagnostics,
          },
        );
      }
    } catch (_) {
      await _diagnostics.error('guard_health_check_failed', details: {'reason': reason});
    } finally {
      _running = false;
    }
  }
}
