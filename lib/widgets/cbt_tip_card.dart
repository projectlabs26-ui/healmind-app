import '../services/locale_service.dart';
import 'package:flutter/material.dart';

/// A card showing a daily CBT tip.
class CBTTipCard extends StatelessWidget {
  final String tip;
  final int tipIndex;
  final VoidCallback onNext;

  const CBTTipCard({
    super.key,
    required this.tip,
    required this.tipIndex,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
              theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  L10n.get('cbtTip'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '#${tipIndex + 1}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tip,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: Text(L10n.get('nextTip')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}