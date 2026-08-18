import 'package:flutter/material.dart';
import '../models/mood.dart';

/// A colored bar for the mood chart, representing a single day's mood.
class MoodBar extends StatelessWidget {
  final Mood? mood;
  final String dayLabel;
  final double height;
  final bool isToday;

  const MoodBar({
    super.key,
    required this.mood,
    required this.dayLabel,
    this.height = 100,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mood emoji
        if (mood != null)
          Text(
            mood!.emoji,
            style: const TextStyle(fontSize: 22),
          )
        else
          const SizedBox(height: 28),
        const SizedBox(height: 4),
        // Colored bar
        Container(
          width: 36,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                mood != null ? _getBarColor(mood!) : Colors.grey.shade300,
                mood != null
                    ? _getBarColor(mood!).withValues(alpha: 0.5)
                    : Colors.grey.shade200,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: Colors.black54, width: 2)
                : null,
          ),
        ),
        const SizedBox(height: 6),
        // Day label
        Text(
          dayLabel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? Colors.black87 : Colors.grey,
          ),
        ),
      ],
    );
  }

  Color _getBarColor(Mood mood) {
    switch (mood) {
      case Mood.great:
        return const Color(0xFF4CAF50);
      case Mood.okay:
        return const Color(0xFFFFC107);
      case Mood.sad:
        return const Color(0xFF42A5F5);
      case Mood.angry:
        return const Color(0xFFEF5350);
      case Mood.tired:
        return const Color(0xFF9E9E9E);
    }
  }
}