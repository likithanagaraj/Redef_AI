import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/project.dart';
import '../models/session.dart';
import '../models/habit.dart';
import '../models/task.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [
          ProjectSchema,
          DeepworkSessionSchema,
          HabitSchema,
          TaskSchema,
        ],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }
}
