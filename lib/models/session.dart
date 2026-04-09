import 'package:isar/isar.dart';
import 'project.dart';
import 'sync_base.dart';

part 'session.g.dart';

@collection
class DeepworkSession with SyncableModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? remoteId;

  late DateTime startTime;
  late DateTime endTime;
  late int durationInMinutes;
  int durationInSeconds = 0;
  
  bool isManualEntry = false;
  DateTime createdAt = DateTime.now();


  final project = IsarLink<Project>();
}


