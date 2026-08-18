import 'package:flutter/material.dart';

/// Displays the current streak count with a flame icon.
class StreakBadge extends StatelessWidget {
  final int streak;
  final double size;

  const StreakBadge({
    super.key,
    required this.streak,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final hasStreak = streak > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasStreak
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF6B35), Color(0xFFFFC107)],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey.shade400, Colors.grey.shade300],
              ),
        boxShadow: hasStreak
            ? [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: size * 0.35,
          ),
          Text(
            '$streak',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}