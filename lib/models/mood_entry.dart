import 'mood.dart';

/// A single mood check-in entry, stored in Hive.
class MoodEntry {
  final DateTime date;
  final Mood mood;
  final String? note;

  MoodEntry({
    required this.date,
    required this.mood,
    this.note,
  });

  /// Normalize date to day only (no time) for unique daily check-in.
  DateTime get day => DateTime(date.year, date.month, date.day);

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'mood': mood.name,
        'note': note,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        date: DateTime.parse(json['date'] as String),
        mood: Mood.values.byName(json['mood'] as String),
        note: json['note'] as String?,
      );

  @override
  String toString() => 'MoodEntry(${mood.emoji} ${mood.label} on $day)';
}