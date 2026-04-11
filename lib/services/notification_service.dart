import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:isar/isar.dart';

import '../models/notification_settings.dart';
import '../models/habit.dart';
import '../models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timezoneInfo.identifier;

    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notify_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
  }

  Future<bool?> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidPlugin?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    return false;
  }

  Future<NotificationSettings?> _getSettings() async {
    final isar = Isar.getInstance();
    if (isar == null) return null;
    return await isar.notificationSettings.get(1);
  }

  NotificationDetails _getNotificationDetails(
    String channelId,
    String channelName,
    String channelDescription,
  ) {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          icon: '@drawable/ic_notify_icon',
          largeIcon: const DrawableResourceAndroidBitmap('@drawable/app_logo'),
        );
    return NotificationDetails(
      android: androidNotificationDetails,
      iOS: const DarwinNotificationDetails(),
    );
  }

  // 1. Pomodoro Timer Completion
  Future<void> showPomodoroCompletion() async {
    final settings = await _getSettings();
    if (settings == null || !settings.pomodoroCompleted) return;

    await _flutterLocalNotificationsPlugin.show(
      id: 0,
      title: 'Pomodoro Complete',
      body: 'Time for a break! Great focus.',
      notificationDetails: _getNotificationDetails(
        'pomodoro_channel_v2',
        'Pomodoro Timer',
        'Notifications for pomodoro timer completion',
      ),
    );
  }

  // 2. Achievement Notifications
  Future<void> showAchievementAlert(String title, String body) async {
    final settings = await _getSettings();
    if (settings == null || !settings.achievementAlerts) return;

    await _flutterLocalNotificationsPlugin.show(
      id: 1,
      title: title,
      body: body,
      notificationDetails: _getNotificationDetails(
        'achievement_channel_v2',
        'Achievements',
        'Notifications for milestones and achievements',
      ),
    );
  }

  // 3. Schedule Daily Habit Reminders
  Future<void> scheduleDailyHabitReminder() async {
    final settings = await _getSettings();
    if (settings == null || !settings.habitReminders) {
      await _flutterLocalNotificationsPlugin.cancel(id: 2);
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      settings.habitReminderTimeHour,
      settings.habitReminderTimeMinute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: 2,
      title: 'Habit Reminder',
      body: "Don't forget to check off your habits for today!",
      scheduledDate: scheduledDate,
      notificationDetails: _getNotificationDetails(
        'habit_channel_v2',
        'Habit Reminders',
        'Daily reminders for habits',
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // 4. Schedule Daily Task Reminders
  Future<void> scheduleDailyTaskReminder() async {
    final settings = await _getSettings();
    if (settings == null || !settings.pendingTasksReminder) {
      await _flutterLocalNotificationsPlugin.cancel(id: 3);
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      settings.taskReminderTimeHour,
      settings.taskReminderTimeMinute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: 3,
      title: 'Pending Tasks',
      body: 'You still have tasks left to complete today!',
      scheduledDate: scheduledDate,
      notificationDetails: _getNotificationDetails(
        'task_channel_v2',
        'Task Reminders',
        'Daily reminders for pending tasks',
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Re-evaluate pending notifications based on current app state
  Future<void> reevaluateNotifications() async {
    final isar = Isar.getInstance();
    if (isar == null) return;

    await _flutterLocalNotificationsPlugin.cancel(id: 2);
    await _flutterLocalNotificationsPlugin.cancel(id: 3);

    final pendingTasksCount =
    await isar.tasks.filter().isCompletedEqualTo(false).count();

    if (pendingTasksCount > 0) {
      await scheduleDailyTaskReminder();
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final allHabits = await isar.habits.where().findAll();

    bool hasIncompleteHabits =
    allHabits.any((h) => !h.completedDates.contains(today));

    if (hasIncompleteHabits) {
      await scheduleDailyHabitReminder();
    }
  }

  // Clear all pending notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
