import 'package:isar/isar.dart';
import 'sync_base.dart';

part 'project.g.dart';

@collection
class Project with SyncableModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? remoteId;

  late String name;
  DateTime createdAt = DateTime.now();

}


