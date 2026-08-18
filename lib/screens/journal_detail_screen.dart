import '../services/locale_service.dart';
import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/hive_service.dart';
import '../services/admob_service.dart';
import '../widgets/gratitude_input.dart';

class JournalDetailScreen extends StatefulWidget {
  final JournalEntry? entry;

  const JournalDetailScreen({super.key, this.entry});

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final List<TextEditingController> _gratitudeControllers;
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _titleController = TextEditingController(text: entry?.title ?? '');
    _contentController = TextEditingController(text: entry?.content ?? '');
    _gratitudeControllers = List.generate(
      3,
      (i) => TextEditingController(
        text: (entry != null && i < entry.gratitudeList.length)
            ? entry.gratitudeList[i]
            : '',
      ),
    );
    _isEditing = entry == null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    for (final c in _gratitudeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something.')),
      );
      return;
    }

    final gratitudeList = _gratitudeControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final entry = JournalEntry(
      id: widget.entry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: widget.entry?.date ?? DateTime.now(),
      title: title.isNotEmpty ? title : 'Untitled',
      content: content,
      gratitudeList: gratitudeList,
    );

    HiveService.saveJournal(entry);
    AdMobService.trackActionAndShowInterstitial();
    Navigator.pop(context, true);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10n.get('deleteEntry')),
        content: Text(L10n.get('deleteConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(L10n.get('cancel')),
          ),
          TextButton(
            onPressed: () {
              HiveService.deleteJournal(widget.entry!.id);
              Navigator.pop(ctx);
              Navigator.pop(context, true);
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
        title: Text(_isEditing || widget.entry == null
            ? L10n.get('newEntry')
            : L10n.get('editEntry')),
        actions: [
          if (widget.entry != null)
            IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: L10n.get('delete'),
            ),
          if (!_isEditing)
            TextButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: L10n.get('titleHint'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              readOnly: !_isEditing,
              validator: (_) => null,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Content
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: L10n.get('contentHint'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              readOnly: !_isEditing,
              maxLines: 8,
              minLines: 4,
            ),
            const SizedBox(height: 20),

            // Gratitude
            GratitudeInput(controllers: _gratitudeControllers),
            const SizedBox(height: 24),

            // Save button
            if (_isEditing)
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(L10n.get('saveEntry')),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
          ],
        ),
      ),
    );
  }
}