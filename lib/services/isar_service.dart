import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/project.dart';
import '../models/session.dart';
import '../models/habit.dart';
import '../models/task.dart';
import '../models/notification_settings.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      final isar = await Isar.open(
        [
          ProjectSchema,
          DeepworkSessionSchema,
          HabitSchema,
          TaskSchema,
          NotificationSettingsSchema,
        ],
        directory: dir.path,
        inspector: true,
      );

      // Initialize the default settings if they don't exist yet
      final settingsCount = await isar.notificationSettings.count();
      if (settingsCount == 0) {
        await isar.writeTxn(() async {
          await isar.notificationSettings.put(NotificationSettings());
        });
      }
      return isar;
    }
    return Future.value(Isar.getInstance());
  }
}
