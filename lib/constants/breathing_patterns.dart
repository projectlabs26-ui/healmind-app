/// Breathing pattern definitions.
library;

class BreathingPattern {
  final String name;
  final String description;
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int holdAfterExhaleSeconds; // 0 for patterns without this phase

  /// Total seconds for one complete cycle.
  int get cycleSeconds =>
      inhaleSeconds + holdSeconds + exhaleSeconds + holdAfterExhaleSeconds;

  const BreathingPattern({
    required this.name,
    required this.description,
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    this.holdAfterExhaleSeconds = 0,
  });
}

/// Predefined breathing patterns.
const List<BreathingPattern> breathingPatterns = [
  BreathingPattern(
    name: '4-7-8',
    description: 'Inhale 4s · Hold 7s · Exhale 8s',
    inhaleSeconds: 4,
    holdSeconds: 7,
    exhaleSeconds: 8,
  ),
  BreathingPattern(
    name: 'Box Breathing',
    description: 'Inhale 4s · Hold 4s · Exhale 4s · Hold 4s',
    inhaleSeconds: 4,
    holdSeconds: 4,
    exhaleSeconds: 4,
    holdAfterExhaleSeconds: 4,
  ),
  BreathingPattern(
    name: 'Deep Belly',
    description: 'Inhale 5s · Hold 2s · Exhale 7s',
    inhaleSeconds: 5,
    holdSeconds: 2,
    exhaleSeconds: 7,
  ),
];

/// Available session durations in minutes.
const List<int> sessionDurations = [1, 3, 5, 10];