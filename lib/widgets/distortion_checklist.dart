import 'package:flutter/material.dart';
import '../constants/cbt_data.dart';

/// A scrollable checklist of cognitive distortions.
class DistortionChecklist extends StatefulWidget {
  final List<String> selectedDistortions;
  final ValueChanged<List<String>> onChanged;

  const DistortionChecklist({
    super.key,
    required this.selectedDistortions,
    required this.onChanged,
  });

  @override
  State<DistortionChecklist> createState() => _DistortionChecklistState();
}

class _DistortionChecklistState extends State<DistortionChecklist> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedDistortions);
  }

  void _toggle(String name) {
    setState(() {
      if (_selected.contains(name)) {
        _selected.remove(name);
      } else {
        _selected.add(name);
      }
    });
    widget.onChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cognitiveDistortions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final d = cognitiveDistortions[index];
        final isChecked = _selected.contains(d.name);
        return _DistortionTile(
          distortion: d,
          isChecked: isChecked,
          onTap: () => _toggle(d.name),
        );
      },
    );
  }
}

class _DistortionTile extends StatelessWidget {
  final CognitiveDistortion distortion;
  final bool isChecked;
  final VoidCallback onTap;

  const _DistortionTile({
    required this.distortion,
    required this.isChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isChecked
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isChecked
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isChecked ? Icons.check_box : Icons.check_box_outline_blank,
              color: isChecked ? theme.colorScheme.primary : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    distortion.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isChecked
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    distortion.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}