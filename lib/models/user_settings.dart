import 'package:flutter/material.dart';

/// User settings stored in Hive.
class UserSettings {
  bool reminderEnabled;
  int reminderHour;
  int reminderMinute;
  bool darkMode;
  int lastAffirmationIndex;
  List<String> favoriteAffirmations;
  String selectedThemeId;
  bool premiumThemesUnlocked;
  String language;
  bool onboardingComplete;
  DateTime? firstLaunchDate;
  DateTime? lastRatingPromptDate;

  UserSettings({
    this.reminderEnabled = true,
    this.reminderHour = 20,
    this.reminderMinute = 0,
    this.darkMode = false,
    this.lastAffirmationIndex = 0,
    this.favoriteAffirmations = const [],
    this.selectedThemeId = 'default',
    this.premiumThemesUnlocked = false,
    this.language = 'en',
    this.onboardingComplete = false,
    this.firstLaunchDate,
    this.lastRatingPromptDate,
  });

  Map<String, dynamic> toJson() => {
        'reminderEnabled': reminderEnabled,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'darkMode': darkMode,
        'lastAffirmationIndex': lastAffirmationIndex,
        'favoriteAffirmations': favoriteAffirmations,
        'selectedThemeId': selectedThemeId,
        'premiumThemesUnlocked': premiumThemesUnlocked,
        'language': language,
        'onboardingComplete': onboardingComplete,
        'firstLaunchDate': firstLaunchDate?.toIso8601String(),
        'lastRatingPromptDate': lastRatingPromptDate?.toIso8601String(),
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        reminderEnabled: json['reminderEnabled'] as bool? ?? true,
        reminderHour: json['reminderHour'] as int? ?? 20,
        reminderMinute: json['reminderMinute'] as int? ?? 0,
        darkMode: json['darkMode'] as bool? ?? false,
        lastAffirmationIndex: json['lastAffirmationIndex'] as int? ?? 0,
        favoriteAffirmations:
            List<String>.from(json['favoriteAffirmations'] ?? []),
        selectedThemeId: json['selectedThemeId'] as String? ?? 'default',
        premiumThemesUnlocked: json['premiumThemesUnlocked'] as bool? ?? false,
        language: json['language'] as String? ?? 'en',
        onboardingComplete: json['onboardingComplete'] as bool? ?? false,
        firstLaunchDate: json['firstLaunchDate'] != null
            ? DateTime.tryParse(json['firstLaunchDate'] as String)
            : null,
        lastRatingPromptDate: json['lastRatingPromptDate'] != null
            ? DateTime.tryParse(json['lastRatingPromptDate'] as String)
            : null,
      );

  TimeOfDay get reminderTime => TimeOfDay(hour: reminderHour, minute: reminderMinute);

  @override
  String toString() =>
      'UserSettings(reminder: $reminderEnabled, dark: $darkMode)';
}