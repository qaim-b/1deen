class DiagnosticEvent {
  const DiagnosticEvent({
    required this.timestamp,
    required this.level,
    required this.event,
    this.details,
  });

  final DateTime timestamp;
  final String level;
  final String event;
  final Map<String, dynamic>? details;

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level,
      'event': event,
      'details': details,
    };
  }

  factory DiagnosticEvent.fromJson(Map<String, dynamic> json) {
    return DiagnosticEvent(
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      level: json['level'] as String? ?? 'info',
      event: json['event'] as String? ?? 'unknown',
      details: (json['details'] as Map?)?.cast<String, dynamic>(),
    );
  }
}
