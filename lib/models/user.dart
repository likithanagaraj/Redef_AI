import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  late String localId; // UUID (important)
  String? supabaseId;  // nullable (for future)

  late String name;

  late DateTime createdAt;
  bool isOnboarded = false;
}
