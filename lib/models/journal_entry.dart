/// A journal entry with optional gratitude list.
class JournalEntry {
  final String id;
  final DateTime date;
  final String title;
  final String content;
  final List<String> gratitudeList;

  JournalEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    this.gratitudeList = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'title': title,
        'content': content,
        'gratitudeList': gratitudeList,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        title: json['title'] as String,
        content: json['content'] as String,
        gratitudeList: List<String>.from(json['gratitudeList'] ?? []),
      );

  @override
  String toString() => 'JournalEntry($title, ${gratitudeList.length} gratitudes)';
}