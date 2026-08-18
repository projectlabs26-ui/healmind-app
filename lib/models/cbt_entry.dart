/// A single CBT thought reframing entry, stored in Hive.
class CBTEntry {
  final String id;
  final DateTime date;
  final String thought;
  final int intensity;
  final List<String> distortions;
  final String reframedThought;
  final String? notes;

  CBTEntry({
    required this.id,
    required this.date,
    required this.thought,
    required this.intensity,
    required this.distortions,
    required this.reframedThought,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'thought': thought,
        'intensity': intensity,
        'distortions': distortions,
        'reframedThought': reframedThought,
        'notes': notes,
      };

  factory CBTEntry.fromJson(Map<String, dynamic> json) => CBTEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        thought: json['thought'] as String,
        intensity: json['intensity'] as int,
        distortions: List<String>.from(json['distortions'] ?? []),
        reframedThought: json['reframedThought'] as String,
        notes: json['notes'] as String?,
      );

  @override
  String toString() => 'CBTEntry($thought → $reframedThought)';
}