import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/mood_entry.dart';
import '../models/journal_entry.dart';
import '../models/user_settings.dart';

import '../models/breathing_session.dart';
import '../models/cbt_entry.dart';

class HiveService {
  static const String _moodsBox = 'moods';
  static const String _journalsBox = 'journals';
  static const String _settingsBox = 'settings';
  static const String _breathingBox = 'breathing_sessions';
  static const String _cbtBox = 'cbt_entries';

  // ──────────────────────────────────────────────
  // Initialization
  // ──────────────────────────────────────────────

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_moodsBox);
    await Hive.openBox(_journalsBox);
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_breathingBox);
    await Hive.openBox(_cbtBox);
  }

  // ──────────────────────────────────────────────
  // Mood Entries
  // ──────────────────────────────────────────────

  static Box get _moods => Hive.box(_moodsBox);

  static List<MoodEntry> getAllMoods() {
    return _moods.values
        .cast<String>()
        .map((json) => MoodEntry.fromJson(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static MoodEntry? getMoodForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return getAllMoods().where((m) {
      final entryDay = DateTime(m.date.year, m.date.month, m.date.day);
      return entryDay == normalized;
    }).firstOrNull;
  }

  static Future<void> saveMood(MoodEntry entry) async {
    // Replace existing entry for same day
    final normalized = DateTime(entry.date.year, entry.date.month, entry.date.day);
    final existingKey = _moods.keys.firstWhere(
      (k) {
        final json = _moods.get(k) as String;
        final existing = MoodEntry.fromJson(jsonDecode(json));
        final existingDay = DateTime(
          existing.date.year,
          existing.date.month,
          existing.date.day,
        );
        return existingDay == normalized;
      },
      orElse: () => null,
    );

    if (existingKey != null) {
      await _moods.put(existingKey, jsonEncode(entry.toJson()));
    } else {
      await _moods.add(jsonEncode(entry.toJson()));
    }
  }

  // ──────────────────────────────────────────────
  // Journal Entries
  // ──────────────────────────────────────────────

  static Box get _journals => Hive.box(_journalsBox);

  static List<JournalEntry> getAllJournals() {
    return _journals.values
        .cast<String>()
        .map((json) => JournalEntry.fromJson(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> saveJournal(JournalEntry entry) async {
    final existingKey = _journals.keys.firstWhere(
      (k) {
        final json = _journals.get(k) as String;
        final existing = JournalEntry.fromJson(jsonDecode(json));
        return existing.id == entry.id;
      },
      orElse: () => null,
    );

    if (existingKey != null) {
      await _journals.put(existingKey, jsonEncode(entry.toJson()));
    } else {
      await _journals.add(jsonEncode(entry.toJson()));
    }
  }

  static Future<void> deleteJournal(String id) async {
    final key = _journals.keys.firstWhere(
      (k) {
        final json = _journals.get(k) as String;
        final entry = JournalEntry.fromJson(jsonDecode(json));
        return entry.id == id;
      },
      orElse: () => null,
    );
    if (key != null) {
      await _journals.delete(key);
    }
  }

  // ──────────────────────────────────────────────
  // Settings
  // ──────────────────────────────────────────────

  static Box get _settings => Hive.box(_settingsBox);

  static UserSettings getSettings() {
    final json = _settings.get('user_settings');
    if (json != null) {
      return UserSettings.fromJson(jsonDecode(json as String));
    }
    return UserSettings();
  }

  static Future<void> saveSettings(UserSettings settings) async {
    await _settings.put('user_settings', jsonEncode(settings.toJson()));
  }

  // ──────────────────────────────────────────────
  // Data Management
  // ──────────────────────────────────────────────

  static String exportAllData() {
    final data = {
      'moods': getAllMoods().map((m) => m.toJson()).toList(),
      'journals': getAllJournals().map((j) => j.toJson()).toList(),
      'breathingSessions': getAllBreathingSessions().map((b) => b.toJson()).toList(),
      'cbtEntries': getAllCBTEntries().map((c) => c.toJson()).toList(),
      'settings': getSettings().toJson(),
      'exportedAt': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static Future<void> deleteAllData() async {
    await _moods.clear();
    await _journals.clear();
    await _settings.clear();
    await _breathing.clear();
    await _cbt.clear();
  }

  // ──────────────────────────────────────────────
  // CBT Entries
  // ──────────────────────────────────────────────

  static Box get _cbt => Hive.box(_cbtBox);

  static List<CBTEntry> getAllCBTEntries() {
    return _cbt.values
        .cast<String>()
        .map((json) => CBTEntry.fromJson(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> saveCBTEntry(CBTEntry entry) async {
    final existingKey = _cbt.keys.firstWhere(
      (k) {
        final json = _cbt.get(k) as String;
        final existing = CBTEntry.fromJson(jsonDecode(json));
        return existing.id == entry.id;
      },
      orElse: () => null,
    );
    if (existingKey != null) {
      await _cbt.put(existingKey, jsonEncode(entry.toJson()));
    } else {
      await _cbt.add(jsonEncode(entry.toJson()));
    }
  }

  static Future<void> deleteCBTEntry(String id) async {
    final key = _cbt.keys.firstWhere(
      (k) {
        final json = _cbt.get(k) as String;
        final entry = CBTEntry.fromJson(jsonDecode(json));
        return entry.id == id;
      },
      orElse: () => null,
    );
    if (key != null) {
      await _cbt.delete(key);
    }
  }

  // ──────────────────────────────────────────────
  // Breathing Sessions
  // ──────────────────────────────────────────────

  static Box get _breathing => Hive.box(_breathingBox);

  static List<BreathingSession> getAllBreathingSessions() {
    return _breathing.values
        .cast<String>()
        .map((json) => BreathingSession.fromJson(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> saveBreathingSession(BreathingSession session) async {
    await _breathing.add(jsonEncode(session.toJson()));
  }

  // ──────────────────────────────────────────────
  // Streak
  // ──────────────────────────────────────────────

  static int getCurrentStreak() {
    final moods = getAllMoods();
    if (moods.isEmpty) return 0;

    int streak = 0;
    final today = DateTime.now();
    var checkDay = DateTime(today.year, today.month, today.day);

    for (int i = 0; i < 365; i++) {
      final hasEntry = moods.any((m) {
        final entryDay = DateTime(m.date.year, m.date.month, m.date.day);
        return entryDay == checkDay;
      });
      if (hasEntry) {
        streak++;
        checkDay = checkDay.subtract(const Duration(days: 1));
      } else {
        // Allow today to be missing (haven't checked in yet)
        if (i == 0 && checkDay == DateTime(today.year, today.month, today.day)) {
          checkDay = checkDay.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }
    return streak;
  }
}