import 'package:home_widget/home_widget.dart';
import 'package:isar/isar.dart';
import '../models/task.dart';
import '../models/habit.dart';
import '../models/session.dart';

class WidgetService {
  static const String _groupId = 'group.redef_ai';
  static const String _androidWidgetName = 'StatsWidgetProvider';

  static final List<String> _quotes = [
    "Strive not to be a success, but rather to be of value.",
    "The only way to do great work is to love what you do.",
    "Focus on being productive instead of busy.",
    "Your time is limited, don't waste it living someone else's life.",
    "The secret of getting ahead is getting started.",
    "Energy and persistence conquer all things.",
    "It does not matter how slowly you go as long as you do not stop.",
  ];

  static Future<void> updateWidgetData() async {
    final isar = Isar.getInstance();
    if (isar == null) return;

    final now = DateTime.now();

    // 1. Total Focus Minutes (to match App's HomeScreen)
    final sessions = await isar.deepworkSessions.where().findAll();
    final totalMinutes = sessions.fold(0, (sum, s) => sum + s.durationInMinutes);
    
    String focusValue = "0";
    String focusUnit = "min";
    
    double totalHrs = totalMinutes / 60.0;
    if (totalHrs == 0) {
      focusValue = "0";
      focusUnit = "min";
    } else if (totalHrs < 1) {
      focusValue = (totalHrs * 60).round().toString();
      focusUnit = "min";
    } else {
      int hrsInt = totalHrs.truncate();
      focusValue = hrsInt > 999 ? "999+" : hrsInt.toString();
      focusUnit = "hrs";
    }

    // 2. Max Habit Streak
    final habits = await isar.habits.where().findAll();
    int maxStreak = 0;
    for (var habit in habits) {
      final streak = habit.calculateStreak(now);
      if (streak > maxStreak) maxStreak = streak;
    }

    // 3. Pending Tasks
    final pendingTasks = await isar.tasks.filter().isCompletedEqualTo(false).count();

    // 4. Quote (selection logic: daily hash)
    final quoteIndex = (now.year + now.month + now.day) % _quotes.length;
    final quote = _quotes[quoteIndex];

    // Set App Group ID
    await HomeWidget.setAppGroupId(_groupId);

    // Save data to SharedPreferences (for Android, home_widget uses 'HomeWidgetPreferences')
    await HomeWidget.saveWidgetData<String>('quote', quote);
    await HomeWidget.saveWidgetData<String>('focus_value', focusValue);
    await HomeWidget.saveWidgetData<String>('focus_unit', focusUnit);
    await HomeWidget.saveWidgetData<int>('habit_streak', maxStreak);
    await HomeWidget.saveWidgetData<int>('pending_tasks', pendingTasks);

    // Trigger Update
    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
    );
  }
}
