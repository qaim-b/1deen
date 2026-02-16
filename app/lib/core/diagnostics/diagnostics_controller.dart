import 'package:app/core/diagnostics/diagnostic_event.dart';
import 'package:app/core/diagnostics/diagnostics_repository.dart';
import 'package:flutter/foundation.dart';

class DiagnosticsController extends ChangeNotifier {
  DiagnosticsController(this._repository);

  final DiagnosticsRepository _repository;

  List<DiagnosticEvent> _events = const [];

  List<DiagnosticEvent> get events => _events;

  Future<void> initialize() async {
    _events = _repository.loadEvents();
    notifyListeners();
  }

  Future<void> info(String event, {Map<String, dynamic>? details}) {
    return _add(level: 'info', event: event, details: details);
  }

  Future<void> warn(String event, {Map<String, dynamic>? details}) {
    return _add(level: 'warn', event: event, details: details);
  }

  Future<void> error(String event, {Map<String, dynamic>? details}) {
    return _add(level: 'error', event: event, details: details);
  }

  Future<void> _add({
    required String level,
    required String event,
    Map<String, dynamic>? details,
  }) async {
    final item = DiagnosticEvent(
      timestamp: DateTime.now(),
      level: level,
      event: event,
      details: details,
    );

    _events = [item, ..._events].take(120).toList(growable: false);
    notifyListeners();
    await _repository.append(item);
  }

  Future<void> clear() async {
    _events = const [];
    notifyListeners();
    await _repository.clear();
  }
}
