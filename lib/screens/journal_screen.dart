import '../services/locale_service.dart';
import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/hive_service.dart';
import '../widgets/ad_native_widget.dart';
import 'journal_detail_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<JournalEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() {
    setState(() {
      _entries = HiveService.getAllJournals();
    });
  }

  void _openEntry({JournalEntry? entry}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => JournalDetailScreen(entry: entry),
      ),
    );
    if (result == true) {
      _loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.get('journalTitle')),
      ),
      body: _entries.isEmpty ? _buildEmptyState(theme) : _buildEntryList(theme),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEntry(),
        icon: const Icon(Icons.edit),
        label: Text(L10n.get('newEntry')),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              L10n.get('noEntries'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryList(ThemeData theme) {
    final items = <Widget>[];
    for (int i = 0; i < _entries.length; i++) {
      items.add(_JournalCard(
        entry: _entries[i],
        onTap: () => _openEntry(entry: _entries[i]),
      ));
      // Insert native ad every 3 entries
      if ((i + 1) % 3 == 0 && i + 1 < _entries.length) {
        items.add(const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: AdNativeWidget(),
        ));
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: items,
    );
  }
}

class _JournalCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;

  const _JournalCard({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = _formatDate(entry.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.content,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (entry.gratitudeList.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.favorite, size: 14, color: Colors.red.shade300),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.gratitudeList.length} gratitudes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade300,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(entryDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '${diff}d ago';
    return '${entryDay.day}/${entryDay.month}/${entryDay.year}';
  }
}