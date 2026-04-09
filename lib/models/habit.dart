import 'package:isar/isar.dart';
import 'sync_base.dart';

part 'habit.g.dart';

@collection
class Habit with SyncableModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? remoteId;

  late String name;
  String? description;

  late DateTime createdAt;
  late DateTime startedAt;
  DateTime? endDate;

  List<DateTime> completedDates = [];
}



extension HabitLogic on Habit {
  void cleanupCompletions() {
    final startMidnight = DateTime(startedAt.year, startedAt.month, startedAt.day);
    completedDates = completedDates.where((d) {
      final dMidnight = DateTime(d.year, d.month, d.day);
      return !dMidnight.isBefore(startMidnight);
    }).toList();
  }

  bool isCheckedOn(DateTime date) {
    return completedDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
  }

  int calculateStreak(DateTime today) {
    // Only count dates that are >= startedAt
    final startMidnight = DateTime(startedAt.year, startedAt.month, startedAt.day);
    final validDates = completedDates
        .where((d) => !DateTime(d.year, d.month, d.day).isBefore(startMidnight))
        .toList();

    if (validDates.isEmpty) return 0;
    
    final uniqueDates = validDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime checkDate = DateTime(today.year, today.month, today.day);
    
    if (uniqueDates.isNotEmpty && uniqueDates.first.isBefore(checkDate)) {
        checkDate = checkDate.subtract(const Duration(days: 1));
    }

    for (DateTime date in uniqueDates) {
      if (date.year == checkDate.year && date.month == checkDate.month && date.day == checkDate.day) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break; 
      }
    }
    return streak;
  }
}
