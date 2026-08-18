import '../services/locale_service.dart';
import 'package:flutter/material.dart';

/// A form with 3 gratitude text fields.
class GratitudeInput extends StatelessWidget {
  final List<TextEditingController> controllers;

  const GratitudeInput({
    super.key,
    required this.controllers,
  }) : assert(controllers.length == 3);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              L10n.get('gratitudeTitle'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _GratitudeField(
          controller: controllers[0],
          hint: L10n.get('gratitude1'),
          index: 1,
        ),
        const SizedBox(height: 8),
        _GratitudeField(
          controller: controllers[1],
          hint: L10n.get('gratitude2'),
          index: 2,
        ),
        const SizedBox(height: 8),
        _GratitudeField(
          controller: controllers[2],
          hint: L10n.get('gratitude3'),
          index: 3,
        ),
      ],
    );
  }
}

class _GratitudeField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int index;

  const _GratitudeField({
    required this.controller,
    required this.hint,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        maxLines: 1,
        textInputAction: index == 3 ? TextInputAction.done : TextInputAction.next,
      ),
    );
  }
}