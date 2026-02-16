import 'package:app/features/salah_guard/platform_bridge/lock_bridge.dart';
import 'package:app/features/settings/domain/app_settings.dart';
import 'package:flutter/services.dart';

class MethodChannelLockBridge implements LockBridge {
  MethodChannelLockBridge() : _channel = const MethodChannel(_channelName);

  static const _channelName = 'salah_guard/lock_engine';
  final MethodChannel _channel;

  @override
  Future<bool> isEngineHealthy() async {
    try {
      final value = await _channel.invokeMethod<bool>('isEngineHealthy');
      return value ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> syncConfiguration({
    required StrictnessMode strictnessMode,
    required int lockBeforeMinutes,
    required int lockAfterMinutes,
  }) async {
    try {
      final value = await _channel.invokeMethod<bool>('syncConfiguration', {
        'strictnessMode': strictnessMode.storageValue,
        'lockBeforeMinutes': lockBeforeMinutes,
        'lockAfterMinutes': lockAfterMinutes,
      });
      return value ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> syncLockWindows(List<LockWindowPayload> windows) async {
    try {
      final value = await _channel.invokeMethod<bool>('syncLockWindows', {
        'windows': windows.map((w) => w.toJson()).toList(growable: false),
      });
      return value ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> syncBlockedApps(List<String> packageNames) async {
    try {
      final value = await _channel.invokeMethod<bool>('syncBlockedApps', {
        'packageNames': packageNames,
      });
      return value ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> requestEmergencyUnlock({int durationSeconds = 30}) async {
    try {
      final value = await _channel.invokeMethod<bool>('requestEmergencyUnlock', {
        'durationSeconds': durationSeconds,
      });
      return value ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> requestIosAuthorization() async {
    try {
      final value = await _channel.invokeMethod<bool>('requestIosAuthorization');
      return value ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> scheduleAutomation() async {
    try {
      final value = await _channel.invokeMethod<bool>('scheduleAutomation');
      return value ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> consumeResyncRequired() async {
    try {
      final value = await _channel.invokeMethod<bool>('consumeResyncRequired');
      return value ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getEngineDiagnostics() async {
    try {
      final value = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getEngineDiagnostics',
      );
      if (value == null) {
        return const {};
      }
      return value.map((key, value) => MapEntry('$key', value));
    } on PlatformException {
      return const {};
    } on MissingPluginException {
      return const {};
    }
  }
}
