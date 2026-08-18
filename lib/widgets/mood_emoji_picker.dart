import 'package:flutter/material.dart';
import '../models/mood.dart';

/// A row of 5 mood emoji buttons for the daily check-in.
class MoodEmojiPicker extends StatelessWidget {
  final Mood? selectedMood;
  final ValueChanged<Mood> onMoodSelected;

  const MoodEmojiPicker({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: Mood.values.map((mood) {
        final isSelected = mood == selectedMood;
        return _MoodButton(
          mood: mood,
          isSelected: isSelected,
          onTap: () => onMoodSelected(mood),
        );
      }).toList(),
    );
  }
}

class _MoodButton extends StatelessWidget {
  final Mood mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodButton({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? _getMoodColor(mood).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _getMoodColor(mood) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              mood.emoji,
              style: TextStyle(
                fontSize: isSelected ? 36 : 30,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mood.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? _getMoodColor(mood) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(Mood mood) {
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