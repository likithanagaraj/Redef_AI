import 'package:isar/isar.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;

  late String name;
  late DateTime createdAt;

  String? category;

  bool isCompleted = false;
}
