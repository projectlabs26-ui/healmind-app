import '../services/locale_service.dart';
import 'package:flutter/material.dart';
import '../models/mood.dart';
import '../models/mood_entry.dart';
import '../services/hive_service.dart';
import '../widgets/mood_emoji_picker.dart';

class MoodCheckScreen extends StatefulWidget {
  const MoodCheckScreen({super.key});

  @override
  State<MoodCheckScreen> createState() => _MoodCheckScreenState();
}

class _MoodCheckScreenState extends State<MoodCheckScreen> {
  Mood? _selectedMood;
  final _noteController = TextEditingController();
  bool _alreadyCheckedIn = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final existing = HiveService.getMoodForDay(today);
    if (existing != null) {
      _alreadyCheckedIn = true;
      _selectedMood = existing.mood;
      _noteController.text = existing.note ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select how you feel.')),
      );
      return;
    }

    final entry = MoodEntry(
      date: DateTime.now(),
      mood: _selectedMood!,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    HiveService.saveMood(entry);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(L10n.get('moodSaved'))),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.get('howAreYou')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Mood emoji picker
            if (_alreadyCheckedIn)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          L10n.get('alreadyCheckedIn'),
                          style: TextStyle(color: Colors.amber.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Text(
              _selectedMood != null
                  ? 'You\'re feeling ${_selectedMood!.label} ${_selectedMood!.emoji}'
                  : 'Select your mood:',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            MoodEmojiPicker(
              selectedMood: _selectedMood,
              onMoodSelected: (mood) {
                setState(() => _selectedMood = mood);
              },
            ),
            const SizedBox(height: 32),

            // Note
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: L10n.get('moodNoteHint'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.edit_note),
              ),
              maxLines: 3,
              minLines: 2,
            ),
            const SizedBox(height: 32),

            // Save button
            FilledButton.icon(
              onPressed: _selectedMood != null ? _save : null,
              icon: const Icon(Icons.check),
              label: Text(
                _alreadyCheckedIn ? 'Update Mood' : L10n.get('saveMood'),
              ),
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