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
