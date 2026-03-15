import 'package:isar/isar.dart';

part 'habit.g.dart';

@collection
class Habit {
  Id id = Isar.autoIncrement;

  late String name;
  String? description;

  late DateTime createdAt;
  late DateTime startedAt;
  DateTime? endDate;

  List<DateTime> completedDates = [];
}

extension HabitLogic on Habit {
  bool isCheckedOn(DateTime date) {
    return completedDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
  }

  int calculateStreak(DateTime today) {
    if (completedDates.isEmpty) return 0;
    
    final uniqueDates = completedDates
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
