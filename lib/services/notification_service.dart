import 'locale_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(initSettings);
  }

  /// Schedule a daily reminder at the given time.
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    // Cancel existing reminders first
    await cancelAll();

    final androidDetails = AndroidNotificationDetails(
      'journal_reminder',
      L10n.get('journalReminder'),
      channelDescription: 'Daily reminder to write in your journal',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    final details = NotificationDetails(android: androidDetails);

    // Schedule daily at the specified time
    await _plugin.periodicallyShow(
      0, // notification ID
      L10n.get('reminderTitle'),
      L10n.get('reminderBody'),
      RepeatInterval.daily, // Using daily repeat
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }
}