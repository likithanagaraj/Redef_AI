import 'package:isar/isar.dart';
import 'project.dart';

part 'session.g.dart';

@collection
class DeepworkSession {
  Id id = Isar.autoIncrement;

  late DateTime startTime;
  late DateTime endTime;
  late int durationInMinutes;
  int durationInSeconds = 0;
  
  bool isManualEntry = false;

  final project = IsarLink<Project>();
}
