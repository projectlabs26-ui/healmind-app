import 'package:flutter/material.dart';

/// A 1-10 intensity slider with labels.
class IntensitySlider extends StatelessWidget {
  final int intensity;
  final ValueChanged<int> onChanged;

  const IntensitySlider({
    super.key,
    required this.intensity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Intensity number display
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getColor(intensity).withValues(alpha: 0.15),
            border: Border.all(
              color: _getColor(intensity),
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              '$intensity',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getColor(intensity),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Label
        Text(
          _getLabel(intensity),
          style: theme.textTheme.titleSmall?.copyWith(
            color: _getColor(intensity),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Slider
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: _getColor(intensity),
            thumbColor: _getColor(intensity),
            inactiveTrackColor: _getColor(intensity).withValues(alpha: 0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
          ),
          child: Slider(
            value: intensity.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (v) => onChanged(v.round()),
            label: '$intensity',
          ),
        ),

        // Min/Max labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1 - Mild', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            Text('10 - Extreme', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Color _getColor(int value) {
    if (value <= 3) return const Color(0xFF4CAF50); // Green - mild
    if (value <= 5) return const Color(0xFFFFC107); // Amber - moderate
    if (value <= 7) return const Color(0xFFFF9800); // Orange - high
    return const Color(0xFFEF5350); // Red - extreme
  }

  String _getLabel(int value) {
    if (value <= 2) return 'Very Mild';
    if (value <= 4) return 'Mild';
    if (value <= 6) return 'Moderate';
    if (value <= 8) return 'Intense';
    return 'Very Intense';
  }
}