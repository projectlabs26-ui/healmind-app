/// A single affirmation, can be favorited by the user.
class Affirmation {
  final String id;
  final String text;
  bool isFavorite;

  Affirmation({
    required this.id,
    required this.text,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isFavorite': isFavorite,
      };

  factory Affirmation.fromJson(Map<String, dynamic> json) => Affirmation(
        id: json['id'] as String,
        text: json['text'] as String,
        isFavorite: json['isFavorite'] as bool? ?? false,
      );

  @override
  String toString() => 'Affirmation($text)';
}