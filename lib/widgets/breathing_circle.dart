import 'package:flutter/material.dart';
import '../constants/breathing_patterns.dart';
import '../services/locale_service.dart';

/// Phases of a breathing cycle.
enum BreathingPhase { inhale, hold, exhale, holdAfterExhale }

/// Animated breathing circle using CustomPainter.
class BreathingCircle extends StatelessWidget {
  final double animationValue; // 0.0 to 1.0 per phase
  final BreathingPhase phase;
  final BreathingPattern pattern;
  final String? phaseLabel;

  const BreathingCircle({
    super.key,
    required this.animationValue,
    required this.phase,
    required this.pattern,
    this.phaseLabel,
  });

  /// Returns a distinct color for each breathing phase.
  static Color colorForPhase(BreathingPhase phase, ThemeData theme) {
    switch (phase) {
      case BreathingPhase.inhale:
        return const Color(0xFF4FC3F7); // Sky blue — fresh air
      case BreathingPhase.hold:
        return const Color(0xFFFFB74D); // Warm amber — holding energy
      case BreathingPhase.exhale:
        return const Color(0xFFCE93D8); // Soft purple — letting go
      case BreathingPhase.holdAfterExhale:
        return const Color(0xFF80CBC4); // Muted teal — stillness
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size.width * 0.65;
    final phaseColor = colorForPhase(phase, theme);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated circle
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _BreathingCirclePainter(
              animationValue: animationValue,
              phase: phase,
              color: phaseColor,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Phase label
        Text(
          phaseLabel ?? _defaultLabel(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
            color: phaseColor,
          ),
        ),
        const SizedBox(height: 8),
        // Phase description
        Text(
          _phaseDescription(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _defaultLabel() {
    switch (phase) {
      case BreathingPhase.inhale:
        return L10n.get('inhale');
      case BreathingPhase.hold:
        return L10n.get('hold');
      case BreathingPhase.exhale:
        return L10n.get('exhale');
      case BreathingPhase.holdAfterExhale:
        return L10n.get('hold');
    }
  }

  String _phaseDescription() {
    switch (phase) {
      case BreathingPhase.inhale:
        return '${pattern.inhaleSeconds}s';
      case BreathingPhase.hold:
        return '${pattern.holdSeconds}s';
      case BreathingPhase.exhale:
        return '${pattern.exhaleSeconds}s';
      case BreathingPhase.holdAfterExhale:
        return '${pattern.holdAfterExhaleSeconds}s';
    }
  }
}

class _BreathingCirclePainter extends CustomPainter {
  final double animationValue;
  final BreathingPhase phase;
  final Color color;

  _BreathingCirclePainter({
    required this.animationValue,
    required this.phase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 8;
    final minRadius = maxRadius * 0.35;

    double radius;
    double opacity;

    switch (phase) {
      case BreathingPhase.inhale:
        // Expand from min to max
        radius = minRadius + (maxRadius - minRadius) * _easeInOut(animationValue);
        opacity = 0.3 + 0.4 * animationValue;
      case BreathingPhase.hold:
        // Hold at max
        radius = maxRadius;
        opacity = 0.7;
      case BreathingPhase.exhale:
        // Contract from max to min
        radius = maxRadius - (maxRadius - minRadius) * _easeInOut(animationValue);
        opacity = 0.7 - 0.4 * animationValue;
      case BreathingPhase.holdAfterExhale:
        // Hold at min
        radius = minRadius;
        opacity = 0.3;
    }

    // Outer glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(center, radius + 20, glowPaint);

    // Main circle
    final circlePaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);

    // Border
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, maxRadius, borderPaint);

    // Inner dot
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, dotPaint);
  }

  double _easeInOut(double t) {
    // Smooth easing curve
    return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
  }

  @override
  bool shouldRepaint(covariant _BreathingCirclePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.phase != phase;
  }
}