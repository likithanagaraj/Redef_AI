import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:redef_ai_main/services/isar_service.dart';
import '../models/task.dart';
import '../models/habit.dart';
import '../models/project.dart';
import '../models/session.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final _supabase = Supabase.instance.client;

  /// Performs full bi-directional sync: pushes local changes then pulls cloud changes.
  Future<void> reconcile() async {
    await syncUp();
    await syncDown();
  }

  /// Main entry point to push all local changes to Supabase in a specific order.
  Future<void> syncUp() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final isar = await IsarService().db;

    // 1. Sync Projects First (Dependency for Sessions)
    await _syncProjectsBatch(isar, user.id);

    // 2. Sync Tasks
    await _syncTasksBatch(isar, user.id);

    // 3. Sync Habits
    await _syncHabitsBatch(isar, user.id);

    // 4. Sync Sessions (Depends on Projects)
    await _syncSessionsBatch(isar, user.id);
  }

  /// Fetches all data from Supabase and merges it into the local database.
  Future<void> syncDown() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint("SyncManager: syncDown skipped - No authenticated user.");
      return;
    }

    final isar = await IsarService().db;
    debugPrint("SyncManager: Starting syncDown for user: ${user.id}");

    try {
      // 1. Fetch all data in parallel
      final results = await Future.wait([
        _supabase.from('projects').select().eq('user_id', user.id),
        _supabase.from('tasks').select().eq('user_id', user.id),
        _supabase.from('habits').select().eq('user_id', user.id),
        _supabase.from('deepwork_sessions').select().eq('user_id', user.id),
      ]);

      final List<dynamic> remoteProjects = results[0];
      final List<dynamic> remoteTasks = results[1];
      final List<dynamic> remoteHabits = results[2];
      final List<dynamic> remoteSessions = results[3];
      
      debugPrint("SyncManager: Fetched ${remoteProjects.length} projects, ${remoteTasks.length} tasks, ${remoteHabits.length} habits, ${remoteSessions.length} sessions.");

      // 2. Merge in Order (Projects first for FK)
      await _mergeProjects(isar, remoteProjects);
      await _mergeTasks(isar, remoteTasks);
      await _mergeHabits(isar, remoteHabits);
      await _mergeSessions(isar, remoteSessions);

      debugPrint("SyncManager: syncDown completed successfully.");
    } catch (e, stack) {
      debugPrint("SyncManager: Error during syncDown: $e");
      debugPrint("Stacktrace: $stack");
    }
  }

  // --- Merge Helpers ---

  Future<void> _mergeProjects(Isar isar, List<dynamic> remoteItems) async {
    final List<Project> toPut = [];
    for (var item in remoteItems) {
      final remoteId = item['id'];
      final updatedAt = DateTime.parse(item['updated_at']);
      
      final local = await isar.projects.where().filter().remoteIdEqualTo(remoteId).findFirst();
      
      bool needsUpdate = local == null;
      if (local != null) {
        final localUtc = local.updatedAt.toUtc();
        final remoteUtc = updatedAt.toUtc();
        if (remoteUtc.isAfter(localUtc)) {
           needsUpdate = true;
        } else if (remoteUtc.isBefore(localUtc)) {
           debugPrint("SyncManager: Local project '${local.name}' is newer than remote. Skipping merge.");
        }
      }

      if (needsUpdate) {
        final project = local ?? Project();
        project.remoteId = remoteId;
        project.name = item['name'] ?? "Untitled Project";
        project.isDeleted = item['is_deleted'] ?? false;
        project.createdAt = DateTime.parse(item['created_at']);
        project.updatedAt = updatedAt;
        project.isSynced = true;
        toPut.add(project);
        debugPrint("SyncManager: Prepared project '${project.name}' for local ${local == null ? 'insert' : 'update'}.");
      }

    }
    if (toPut.isNotEmpty) {
      await isar.writeTxn(() async => await isar.projects.putAll(toPut));
      debugPrint("SyncManager: Merged ${toPut.length} projects into local DB.");
    }
  }

  Future<void> _mergeTasks(Isar isar, List<dynamic> remoteItems) async {
    final List<Task> toPut = [];
    for (var item in remoteItems) {
      final remoteId = item['id'];
      final updatedAt = DateTime.parse(item['updated_at']);
      
      final local = await isar.tasks.where().filter().remoteIdEqualTo(remoteId).findFirst();
      
      bool needsUpdate = local == null;
      if (local != null) {
        final localUtc = local.updatedAt.toUtc();
        final remoteUtc = updatedAt.toUtc();
        if (remoteUtc.isAfter(localUtc)) {
           needsUpdate = true;
        } else if (remoteUtc.isBefore(localUtc)) {
           debugPrint("SyncManager: Local task '${local.name}' is newer than remote. Skipping merge.");
        }
      }

      if (needsUpdate) {
        final task = local ?? Task();
        task.remoteId = remoteId;
        task.name = item['name'] ?? "Untitled Task";
        task.category = item['category'];
        task.isCompleted = item['is_completed'] ?? false;
        task.isDeleted = item['is_deleted'] ?? false;
        task.createdAt = DateTime.parse(item['created_at']);
        task.updatedAt = updatedAt;
        task.isSynced = true;
        toPut.add(task);
        debugPrint("SyncManager: Prepared task '${task.name}' for local ${local == null ? 'insert' : 'update'}.");
      }

    }
    if (toPut.isNotEmpty) {
      await isar.writeTxn(() async => await isar.tasks.putAll(toPut));
      debugPrint("SyncManager: Merged ${toPut.length} tasks into local DB.");
    }
  }

  Future<void> _mergeHabits(Isar isar, List<dynamic> remoteItems) async {
    final List<Habit> toPut = [];
    for (var item in remoteItems) {
      final remoteId = item['id'];
      final updatedAt = DateTime.parse(item['updated_at']);
      
      final local = await isar.habits.where().filter().remoteIdEqualTo(remoteId).findFirst();
      
      // If records have identical timestamps in UTC, skip. Otherwise merge.
      bool needsUpdate = local == null;
      if (local != null) {
        // Compare UTC times to avoid timezone offset issues (Supabase is UTC)
        final localUtc = local.updatedAt.toUtc();
        final remoteUtc = updatedAt.toUtc();
        
        // We use isAfter and a small difference threshold (or just !isAtSameMomentAs)
        if (remoteUtc.isAfter(localUtc)) {
           needsUpdate = true;
        } else if (remoteUtc.isBefore(localUtc)) {
           // Local is newer, don't overwrite
           debugPrint("SyncManager: Local habit '${local.name}' is newer than remote. Skipping merge.");
        }
      }

      if (needsUpdate) {
        final habit = local ?? Habit();
        habit.remoteId = remoteId;
        habit.name = item['name'] ?? "Untitled Habit";
        habit.description = item['description'];
        habit.startedAt = DateTime.parse(item['started_at']);
        habit.endDate = item['end_date'] != null ? DateTime.parse(item['end_date']) : null;
        
        final List<dynamic>? rawDates = item['completed_dates'];
        habit.completedDates = rawDates?.map((d) => DateTime.parse(d as String)).toList() ?? [];
        
        habit.isDeleted = item['is_deleted'] ?? false;
        habit.createdAt = DateTime.parse(item['created_at']);
        habit.updatedAt = updatedAt;
        habit.isSynced = true;
        toPut.add(habit);
        debugPrint("SyncManager: Prepared habit '${habit.name}' for local ${local == null ? 'insert' : 'update'}.");
      }

    }
    if (toPut.isNotEmpty) {
      await isar.writeTxn(() async => await isar.habits.putAll(toPut));
      debugPrint("SyncManager: Merged ${toPut.length} habits into local DB.");
    } else {
      debugPrint("SyncManager: No new/updated habits to merge.");
    }
  }

  Future<void> _mergeSessions(Isar isar, List<dynamic> remoteItems) async {
    final List<DeepworkSession> toPut = [];
    for (var item in remoteItems) {
      final remoteId = item['id'];
      final updatedAt = DateTime.parse(item['updated_at']);
      
      final local = await isar.deepworkSessions.where().filter().remoteIdEqualTo(remoteId).findFirst();
      
      bool needsUpdate = local == null;
      if (local != null) {
        final localUtc = local.updatedAt.toUtc();
        final remoteUtc = updatedAt.toUtc();
        if (remoteUtc.isAfter(localUtc)) {
           needsUpdate = true;
        } else if (remoteUtc.isBefore(localUtc)) {
           // Local is newer, don't overwrite
           debugPrint("SyncManager: Local session is newer than remote. Skipping merge.");
        }
      }

      if (needsUpdate) {
        final session = local ?? DeepworkSession();
        session.remoteId = remoteId;
        session.startTime = DateTime.parse(item['start_time']);
        session.endTime = DateTime.parse(item['end_time']);
        session.durationInMinutes = item['duration_in_minutes'] ?? 0;
        session.durationInSeconds = item['duration_in_seconds'] ?? 0;
        session.isManualEntry = item['is_manual_entry'] ?? false;
        session.isDeleted = item['is_deleted'] ?? false;
        session.createdAt = DateTime.parse(item['created_at']);
        session.updatedAt = updatedAt;
        session.isSynced = true;
        
        // Link Project (Reference)
        if (item['project_id'] != null) {
          final project = await isar.projects.where().filter().remoteIdEqualTo(item['project_id']).findFirst();
          if (project != null) {
            session.project.value = project;
          }
        }
        toPut.add(session);
        debugPrint("SyncManager: Prepared session for local ${local == null ? 'insert' : 'update'}.");
      }

    }
    if (toPut.isNotEmpty) {
      await isar.writeTxn(() async {
        await isar.deepworkSessions.putAll(toPut);
        for (var s in toPut) {
          await s.project.save();
        }
      });
      debugPrint("SyncManager: Merged ${toPut.length} sessions into local DB.");
    }
  }

  // --- SyncUp Batch Helpers ---

  Future<void> _syncProjectsBatch(Isar isar, String userId) async {
    final projects = await isar.projects.where().filter().isSyncedEqualTo(false).findAll();
    if (projects.isEmpty) return;

    final data = projects.map((p) {
      p.ensureRemoteId();
      return {
        'id': p.remoteId,
        'user_id': userId,
        'name': p.name,
        'is_deleted': p.isDeleted,
        'created_at': p.createdAt.toIso8601String(),
        'updated_at': p.updatedAt.toIso8601String(),
      };
    }).toList();

    try {
      await _supabase.from('projects').upsert(data);
      await _markBatchAsSynced(projects, isar);
    } catch (e) {
      print("Error syncing projects batch: $e");
    }
  }

  Future<void> _syncTasksBatch(Isar isar, String userId) async {
    final tasks = await isar.tasks.where().filter().isSyncedEqualTo(false).findAll();
    if (tasks.isEmpty) return;

    final data = tasks.map((t) {
      t.ensureRemoteId();
      return {
        'id': t.remoteId,
        'user_id': userId,
        'name': t.name,
        'category': t.category,
        'is_completed': t.isCompleted,
        'is_deleted': t.isDeleted,
        'created_at': t.createdAt.toIso8601String(),
        'updated_at': t.updatedAt.toIso8601String(),
      };
    }).toList();

    try {
      await _supabase.from('tasks').upsert(data);
      await _markBatchAsSynced(tasks, isar);
    } catch (e) {
      print("Error syncing tasks batch: $e");
    }
  }

  Future<void> _syncHabitsBatch(Isar isar, String userId) async {
    final habits = await isar.habits.where().filter().isSyncedEqualTo(false).findAll();
    if (habits.isEmpty) return;

    final data = habits.map((h) {
      h.ensureRemoteId();
      return {
        'id': h.remoteId,
        'user_id': userId,
        'name': h.name,
        'description': h.description,
        'started_at': h.startedAt.toIso8601String(),
        'end_date': h.endDate?.toIso8601String(),
        'completed_dates': h.completedDates
            .where((d) => !DateTime(d.year, d.month, d.day).isBefore(DateTime(h.startedAt.year, h.startedAt.month, h.startedAt.day)))
            .map((d) => d.toIso8601String().split('T')[0]).toList(),
        'is_deleted': h.isDeleted,
        'created_at': h.createdAt.toIso8601String(),
        'updated_at': h.updatedAt.toIso8601String(),
      };
    }).toList();

    try {
      await _supabase.from('habits').upsert(data);
      await _markBatchAsSynced(habits, isar);
    } catch (e) {
      print("Error syncing habits batch: $e");
    }
  }

  Future<void> _syncSessionsBatch(Isar isar, String userId) async {
    final sessions = await isar.deepworkSessions.where().filter().isSyncedEqualTo(false).findAll();
    if (sessions.isEmpty) return;

    final data = sessions.map((s) {
      s.ensureRemoteId();
      final projectRemoteId = s.project.value?.remoteId;
      
      return {
        'id': s.remoteId,
        'user_id': userId,
        'project_id': projectRemoteId, 
        'start_time': s.startTime.toIso8601String(),
        'end_time': s.endTime.toIso8601String(),
        'duration_in_minutes': s.durationInMinutes,
        'duration_in_seconds': s.durationInSeconds,
        'is_manual_entry': s.isManualEntry,
        'is_deleted': s.isDeleted,
        'created_at': s.createdAt.toIso8601String(),
        'updated_at': s.updatedAt.toIso8601String(),
      };
    }).toList();

    try {
      await _supabase.from('deepwork_sessions').upsert(data);
      await _markBatchAsSynced(sessions, isar);
    } catch (e) {
      print("Error syncing sessions batch: $e");
    }
  }

  Future<void> _markBatchAsSynced(List<dynamic> models, Isar isar) async {
    await isar.writeTxn(() async {
      for (var model in models) {
        model.isSynced = true;
        if (model is Task) await isar.tasks.put(model);
        else if (model is Habit) await isar.habits.put(model);
        else if (model is Project) await isar.projects.put(model);
        else if (model is DeepworkSession) await isar.deepworkSessions.put(model);
      }
    });
  }
}
