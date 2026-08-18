import '../services/locale_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../constants/themes.dart';
import '../models/user_settings.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import '../services/admob_service.dart';
import '../services/pdf_export_service.dart';
import '../widgets/ad_banner_widget.dart';

class SettingsScreen extends StatefulWidget {
  final ValueChanged<bool>? onDarkModeChanged;
  final ValueChanged<String>? onThemeChanged;
  final VoidCallback? onDataReset;
  final bool isDarkMode;
  final String themeId;

  const SettingsScreen({
    super.key,
    required this.onDarkModeChanged,
    required this.onThemeChanged,
    required this.isDarkMode,
    required this.themeId,
    this.onDataReset,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = HiveService.getSettings();
  }

  void _saveSettings() {
    HiveService.saveSettings(_settings);
    setState(() {});
  }

  Future<void> _pickReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _settings.reminderTime,
    );
    if (time != null) {
      setState(() {
        _settings.reminderHour = time.hour;
        _settings.reminderMinute = time.minute;
      });
      _saveSettings();

      if (_settings.reminderEnabled) {
        await NotificationService.scheduleDailyReminder(
          hour: _settings.reminderHour,
          minute: _settings.reminderMinute,
        );
      }
    }
  }

  Future<void> _toggleReminder(bool value) async {
    if (value) {
      final hasPermission = await NotificationService.requestPermissions();
      if (!hasPermission && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification permission is required for reminders.'),
          ),
        );
        return;
      }
    }

    setState(() => _settings.reminderEnabled = value);
    _saveSettings();

    if (value) {
      await NotificationService.scheduleDailyReminder(
        hour: _settings.reminderHour,
        minute: _settings.reminderMinute,
      );
    } else {
      await NotificationService.cancelAll();
    }
  }

  void _toggleDarkMode(bool value) {
    widget.onDarkModeChanged?.call(value);
    setState(() => _settings.darkMode = value);
    _saveSettings();
  }

  void _exportData() async {
    // Generate a readable text summary
    final moods = HiveService.getAllMoods();
    final journals = HiveService.getAllJournals();
    final breathing = HiveService.getAllBreathingSessions();
    final cbt = HiveService.getAllCBTEntries();

    final buffer = StringBuffer();
    buffer.writeln('=== HealMind Data Export ===');
    buffer.writeln('Exported: ${DateTime.now().toString().substring(0, 19)}');
    buffer.writeln('');

    // Moods
    buffer.writeln('--- Mood History (${moods.length}) ---');
    for (final m in moods.take(30)) {
      buffer.writeln(
        '${m.date.toString().substring(0, 10)} | ${m.mood.emoji} ${m.mood.label}'
        '${m.note != null ? " | ${m.note}" : ""}',
      );
    }
    buffer.writeln('');

    // Journals
    buffer.writeln('--- Journal Entries (${journals.length}) ---');
    for (final j in journals.take(20)) {
      buffer.writeln('${j.date.toString().substring(0, 10)} | ${j.title}');
    }
    buffer.writeln('');

    // Breathing
    buffer.writeln('--- Breathing Sessions (${breathing.length}) ---');
    for (final b in breathing.take(20)) {
      buffer.writeln(
        '${b.date.toString().substring(0, 10)} | ${b.patternName} | '
        '${b.durationMinutes}min | ${b.cyclesCompleted} cycles',
      );
    }
    buffer.writeln('');

    // CBT
    buffer.writeln('--- CBT Reflections (${cbt.length}) ---');
    for (final c in cbt.take(20)) {
      buffer.writeln(
        '${c.date.toString().substring(0, 10)} | Intensity: ${c.intensity}/10 | '
        'Distortions: ${c.distortions.length}',
      );
      buffer.writeln('  Thought: ${c.thought}');
      buffer.writeln('  Reframed: ${c.reframedThought}');
      buffer.writeln('');
    }

    buffer.writeln('--- End of Export ---');

    // Save to file
    try {
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'healmind_export_$timestamp.txt';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(buffer.toString());

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Export Successful'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your data has been saved as a readable text file. '
                  'You can find it in your file manager under the app\'s documents folder.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('File name:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        fileName,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Summary: ${moods.length} moods, ${journals.length} journals, '
                  '${breathing.length} breathing, ${cbt.length} CBT reflections',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10n.get('deleteAllData')),
        content: Text(L10n.get('deleteAllConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(L10n.get('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              HiveService.deleteAllData().then((_) {
                // Reset settings to defaults after clearing
                setState(() {
                  _settings = UserSettings();
                  _saveSettings();
                });
                // Trigger full app rebuild so all screens refresh
                widget.onDataReset?.call();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(L10n.get('allDataDeleted'))),
                  );
                }
              });
            },
            child: Text(
              L10n.get('delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.get('settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Appearance ──
          _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            title: Text(L10n.get('darkMode')),
            secondary: Icon(
              widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            value: widget.isDarkMode,
            onChanged: _toggleDarkMode,
          ),
          // Language
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language / Bahasa'),
            subtitle: Text(_settings.language == 'id' ? 'Bahasa Indonesia' : 'English'),
            onTap: _showLanguagePicker,
          ),
          const Divider(),

          // ── Reminder ──
          _SectionHeader(title: L10n.get('reminderSettings')),
          SwitchListTile(
            title: Text(L10n.get('reminderDesc')),
            subtitle: Text(
              _settings.reminderEnabled
                  ? 'Every day at ${_settings.reminderTime.format(context)}'
                  : 'Disabled',
            ),
            secondary: const Icon(Icons.notifications_outlined),
            value: _settings.reminderEnabled,
            onChanged: _toggleReminder,
          ),
          if (_settings.reminderEnabled)
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(L10n.get('reminderTime')),
              subtitle: Text(_settings.reminderTime.format(context)),
              onTap: _pickReminderTime,
            ),
          const Divider(),

          // ── Data ──
          _SectionHeader(title: L10n.get('dataManagement')),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(L10n.get('exportData')),
            subtitle: const Text('Export as readable text file'),
            onTap: _exportData,
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Export as PDF'),
            subtitle: const Text('Share journal & mood summary as PDF'),
            onTap: _exportPdf,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(
              L10n.get('deleteAllData'),
              style: const TextStyle(color: Colors.red),
            ),
            onTap: _confirmDeleteAll,
          ),
          const Divider(),

          // ── Premium Themes ──
          _SectionHeader(title: 'Color Theme'),
          ..._buildThemeList(),
          const Divider(),

          // ── Remove Ads ──
          _SectionHeader(title: 'Remove Ads'),
          ListTile(
            leading: const Icon(Icons.ads_click),
            title: const Text('Remove Ads for 24 Hours'),
            subtitle: const Text('Watch a short video to remove all ads'),
            onTap: _showRewardedAd,
          ),
          const Divider(),

          // ── About ──
          _SectionHeader(title: L10n.get('about')),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(L10n.get('appName')),
            subtitle: Text(L10n.get('version')),
          ),
          ListTile(
            leading: const Icon(Icons.star_rate, color: Colors.amber),
            title: const Text('Rate HealMind'),
            subtitle: const Text('If you find this app helpful, please rate us!'),
            onTap: _rateApp,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(L10n.get('privacyPolicy')),
            onTap: () {
              // TODO: Show privacy policy
            },
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  void _showRewardedAd() async {
    if (AdMobService.isAdsFree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ads are already removed!')),
      );
      return;
    }
    final earned = await AdMobService.showRewardedAd();
    if (mounted) {
      if (earned) {
        AdMobService.setAdsFree(24);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ads removed for 24 hours!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ad not completed. Try again later.')),
        );
      }
    }
  }

  void _exportPdf() async {
    try {
      await PdfExportService.shareJournalPdf();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF export failed: $e')),
        );
      }
    }
  }

  void _rateApp() {
    // Show a simple dialog asking user to rate
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${L10n.get('rateHealMind')} ❤️'),
        content: Text(L10n.get('rateMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(L10n.get('rateLater')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(L10n.get('thankYou'))),
              );
            },
            child: Text('${L10n.get('rateNow')} ⭐'),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Choose Language / Pilih Bahasa'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              setState(() => _settings.language = 'en');
              _saveSettings();
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                Text('🇬🇧', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                const Text('English'),
                if (_settings.language == 'en') ...[
                  const Spacer(),
                  const Icon(Icons.check, color: Colors.green),
                ],
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              setState(() => _settings.language = 'id');
              _saveSettings();
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                Text('🇮🇩', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                const Text('Bahasa Indonesia'),
                if (_settings.language == 'id') ...[
                  const Spacer(),
                  const Icon(Icons.check, color: Colors.green),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _unlockThemes() async {
    final earned = await AdMobService.showRewardedAd();
    if (mounted) {
      if (earned) {
        setState(() {
          _settings.premiumThemesUnlocked = true;
        });
        _saveSettings();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Premium themes unlocked! 🎨')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ad not completed. Try again later.')),
        );
      }
    }
  }

  void _selectTheme(String themeId) {
    if (themeId != 'default' && !_settings.premiumThemesUnlocked) {
      _unlockThemes();
      return;
    }
    setState(() {
      _settings.selectedThemeId = themeId;
    });
    _saveSettings();
    widget.onThemeChanged?.call(themeId);
  }

  List<Widget> _buildThemeList() {
    final isUnlocked = _settings.premiumThemesUnlocked;
    return AppThemes.all.map((theme) {
      final isSelected = theme.id == widget.themeId;
      final isLocked = theme.id != 'default' && !isUnlocked;

      return ListTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.seedColor,
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: Colors.white, width: 2)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.seedColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                    )
                  ]
                : null,
          ),
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        ),
        title: Row(
          children: [
            Text(theme.name),
            if (isLocked) ...[
              const SizedBox(width: 8),
              const Icon(Icons.lock, size: 14, color: Colors.grey),
            ],
          ],
        ),
        subtitle: Text(
          isLocked ? 'Watch a video to unlock' : theme.description,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: theme.seedColor)
            : null,
        onTap: () => _selectTheme(theme.id),
      );
    }).toList();
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4, left: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}