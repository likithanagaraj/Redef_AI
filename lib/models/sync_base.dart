import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

mixin SyncableModel {
  String? remoteId;
  DateTime updatedAt = DateTime.now();
  bool isDeleted = false;
  bool isSynced = false;

  void ensureRemoteId() {
    if (remoteId == null) {
      remoteId = const Uuid().v4();
    }
  }

  void markAsUpdated() {
    ensureRemoteId();
    updatedAt = DateTime.now();
    isSynced = false;
  }

  void markAsDeleted() {
    isDeleted = true;
    markAsUpdated();
  }
}

