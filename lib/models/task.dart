import 'package:isar/isar.dart';
import 'sync_base.dart';

part 'task.g.dart';

@collection
class Task with SyncableModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? remoteId;

  late String name;
  late DateTime createdAt;

  String? category;

  bool isCompleted = false;
}


