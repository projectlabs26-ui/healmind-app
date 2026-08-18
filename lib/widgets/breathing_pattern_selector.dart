import 'package:flutter/material.dart';
import '../constants/breathing_patterns.dart';

/// A horizontal card selector for breathing patterns.
class BreathingPatternSelector extends StatelessWidget {
  final BreathingPattern selectedPattern;
  final ValueChanged<BreathingPattern> onPatternSelected;

  const BreathingPatternSelector({
    super.key,
    required this.selectedPattern,
    required this.onPatternSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Select Pattern',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: breathingPatterns.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final pattern = breathingPatterns[index];
              final isSelected = pattern.name == selectedPattern.name;
              return _PatternCard(
                pattern: pattern,
                isSelected: isSelected,
                onTap: () => onPatternSelected(pattern),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PatternCard extends StatelessWidget {
  final BreathingPattern pattern;
  final bool isSelected;
  final VoidCallback onTap;

  const _PatternCard({
    required this.pattern,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              pattern.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pattern.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? theme.colorScheme.primary : Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}