/// Mood types for daily check-in.
library;

enum Mood {
  great,
  okay,
  sad,
  angry,
  tired;

  String get emoji {
    switch (this) {
      case Mood.great:
        return '😊';
      case Mood.okay:
        return '😐';
      case Mood.sad:
        return '😢';
      case Mood.angry:
        return '😡';
      case Mood.tired:
        return '😴';
    }
  }

  String get label {
    switch (this) {
      case Mood.great:
        return 'Great';
      case Mood.okay:
        return 'Okay';
      case Mood.sad:
        return 'Sad';
      case Mood.angry:
        return 'Angry';
      case Mood.tired:
        return 'Tired';
    }
  }
}
