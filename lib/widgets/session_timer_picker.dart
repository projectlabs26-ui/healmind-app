import 'package:flutter/material.dart';
import '../constants/breathing_patterns.dart';

/// A row of duration chips for session timer.
class SessionTimerPicker extends StatelessWidget {
  final int selectedDuration;
  final ValueChanged<int> onDurationSelected;

  const SessionTimerPicker({
    super.key,
    required this.selectedDuration,
    required this.onDurationSelected,
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
            'Duration',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Row(
          children: sessionDurations.map((duration) {
            final isSelected = duration == selectedDuration;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: duration != sessionDurations.last ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: () => onDurationSelected(duration),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$duration',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'min',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}