import '../services/locale_service.dart';
import 'package:flutter/material.dart';
import '../constants/cbt_data.dart';
import '../models/cbt_entry.dart';
import '../services/hive_service.dart';
import '../widgets/cbt_tip_card.dart';
import 'cbt_reframe_screen.dart';

class CBTScreen extends StatefulWidget {
  const CBTScreen({super.key});

  @override
  State<CBTScreen> createState() => _CBTScreenState();
}

class _CBTScreenState extends State<CBTScreen> {
  List<CBTEntry> _history = [];
  int _tipIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _history = HiveService.getAllCBTEntries();
      _tipIndex = _history.length % cbtTips.length;
    });
  }

  void _startReframe() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CBTReframeScreen()),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _nextTip() {
    setState(() {
      _tipIndex = (_tipIndex + 1) % cbtTips.length;
    });
  }

  void _viewEntry(CBTEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CBTReframeScreen(existingEntry: entry),
      ),
    ).then((_) => _loadData());
  }

  void _confirmDeleteEntry(CBTEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10n.get('deleteReflection')),
        content: Text(L10n.get('deleteReflectionConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(L10n.get('cancel')),
          ),
          TextButton(
            onPressed: () {
              HiveService.deleteCBTEntry(entry.id);
              Navigator.pop(ctx);
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(L10n.get('reflectionDeleted'))),
              );
            },
            child: Text(L10n.get('delete'), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.get('cbt')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header ──
          Icon(Icons.psychology, size: 40, color: theme.colorScheme.secondary),
          const SizedBox(height: 8),
          Text(
            L10n.get('cbt'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            L10n.get('reframeSubtitle'),
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // ── Daily Tip ──
          CBTTipCard(
            tip: cbtTips[_tipIndex],
            tipIndex: _tipIndex,
            onNext: _nextTip,
          ),
          const SizedBox(height: 24),

          // ── Start Button ──
          FilledButton.icon(
            onPressed: _startReframe,
            icon: const Icon(Icons.auto_fix_high),
            label: Text(L10n.get('startThoughtReframe')),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: theme.colorScheme.secondary,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24),

          // ── Stats ──
          if (_history.isNotEmpty) ...[
            Text(
              L10n.get('yourProgress'),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatCard(
                  icon: Icons.auto_fix_high,
                  value: '${_history.length}',
                  label: L10n.get('reflections'),
                  theme: theme,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.trending_down,
                  value: _averageIntensity(),
                  label: L10n.get('avgIntensity'),
                  theme: theme,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── History ──
            Text(
              L10n.get('cbtHistory'),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            ..._history.take(5).map((entry) => _CBTEntryCard(
                  entry: entry,
                  onTap: () => _viewEntry(entry),
                  onDelete: () => _confirmDeleteEntry(entry),
                )),
          ],
        ],
      ),
    );
  }

  String _averageIntensity() {
    if (_history.isEmpty) return '-';
    final avg = _history.fold<int>(0, (sum, e) => sum + e.intensity) ~/ _history.length;
    return '$avg/10';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final ThemeData theme;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.secondary),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _CBTEntryCard extends StatelessWidget {
  final CBTEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CBTEntryCard({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete, color: Colors.red.shade400),
      ),
      confirmDismiss: (_) async {
        return true;
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.secondaryContainer,
                  ),
                  child: Icon(Icons.psychology, size: 20, color: theme.colorScheme.secondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.thought,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${entry.distortions.length} distortions · Intensity ${entry.intensity}/10',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}