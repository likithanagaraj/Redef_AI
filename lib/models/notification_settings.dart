import 'package:isar/isar.dart';

part 'notification_settings.g.dart';

@collection
class NotificationSettings {
  Id id = 1; // Singleton record

  bool pomodoroCompleted = true;
  bool habitReminders = true;
  bool pendingTasksReminder = true;
  bool achievementAlerts = true;

  // Global habit reminder time (e.g., 20:00 -> 8:00 PM)
  int habitReminderTimeHour = 11;
  int habitReminderTimeMinute = 0;

  // Global task reminder time (e.g., 21:00 -> 9:00 PM)
  int taskReminderTimeHour = 18;
  int taskReminderTimeMinute = 0;
}
