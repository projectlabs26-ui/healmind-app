/// A completed breathing session, stored in Hive.
class BreathingSession {
  final String id;
  final DateTime date;
  final String patternName;
  final int durationMinutes;
  final int cyclesCompleted;
  final bool completed;

  BreathingSession({
    required this.id,
    required this.date,
    required this.patternName,
    required this.durationMinutes,
    required this.cyclesCompleted,
    this.completed = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'patternName': patternName,
        'durationMinutes': durationMinutes,
        'cyclesCompleted': cyclesCompleted,
        'completed': completed,
      };

  factory BreathingSession.fromJson(Map<String, dynamic> json) =>
      BreathingSession(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        patternName: json['patternName'] as String,
        durationMinutes: json['durationMinutes'] as int,
        cyclesCompleted: json['cyclesCompleted'] as int,
        completed: json['completed'] as bool? ?? true,
      );

  @override
  String toString() =>
      'BreathingSession($patternName, ${durationMinutes}min, $cyclesCompleted cycles)';
}