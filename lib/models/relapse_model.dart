class Relapse {
  final String id;
  final String userId;
  final DateTime timestamp;
  final String reason;
  final int daysAchieved;

  Relapse({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.reason,
    required this.daysAchieved,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'reason': reason,
      'daysAchieved': daysAchieved,
    };
  }

  factory Relapse.fromMap(String id, Map<String, dynamic> map) {
    return Relapse(
      id: id,
      userId: map['userId'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      reason: map['reason'] ?? '',
      daysAchieved: map['daysAchieved'] ?? 0,
    );
  }
}