import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/project.dart';
import '../models/session.dart';
import '../models/habit.dart';
import '../models/task.dart';
import '../models/notification_settings.dart';
import '../models/user.dart';

class IsarService {
  late Future<Isar> db;
  final uuid = const Uuid();

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
          UserSchema,
        ],
        directory: dir.path,
        inspector: true,
      );

      // Handle old user migration
      await handleOldUserMigration(isar);

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

  Future<void> handleOldUserMigration(Isar isar) async {
    final users = await isar.users.where().findAll();

    if (users.isEmpty) {
      // Old user → create user silently
      final user = User()
        ..localId = uuid.v4()
        ..name = "User" // temporary
        ..createdAt = DateTime.now()
        ..isOnboarded = false;

      await isar.writeTxn(() async {
        await isar.users.put(user);
      });
    }
  }

  Future<User?> getUser() async {
    final isar = await db;
    return await isar.users.where().findFirst();
  }

  Future<void> createUser(String name) async {
    final isar = await db;
    final existingUser = await isar.users.where().findFirst();

    final user = (existingUser ?? User())
      ..localId = existingUser?.localId ?? uuid.v4()
      ..name = name
      ..createdAt = existingUser?.createdAt ?? DateTime.now()
      ..isOnboarded = true;

    await isar.writeTxn(() async {
      await isar.users.put(user);
    });
  }
}

