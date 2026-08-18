import '../services/locale_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A swipeable, tappable affirmation card with a share button.
class AffirmationCard extends StatelessWidget {
  final String affirmation;
  final VoidCallback onNext;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const AffirmationCard({
    super.key,
    required this.affirmation,
    required this.onNext,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Swipe left to get next affirmation
        if (details.primaryVelocity != null && details.primaryVelocity! < -100) {
          onNext();
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primaryContainer,
                theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quote icon
              Icon(
                Icons.format_quote,
                color: theme.colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 16),
              // Affirmation text
              Text(
                affirmation,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Favorite button
                  if (onFavorite != null)
                    IconButton(
                      onPressed: onFavorite,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                    ),
                  // Share button
                  IconButton(
                    onPressed: () => _shareAffirmation(context),
                    icon: Icon(
                      Icons.share,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: L10n.get('shareAffirmation'),
                  ),
                  // Next button
                  IconButton(
                    onPressed: onNext,
                    icon: Icon(
                      Icons.arrow_forward,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: L10n.get('nextAffirmation'),
                  ),
                ],
              ),
              // Swipe hint
              Text(
                'Swipe left for next →',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareAffirmation(BuildContext context) {
    Clipboard.setData(ClipboardData(text: affirmation));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Affirmation copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}