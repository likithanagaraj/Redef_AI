// lib/services/habit_service.dart

import 'package:redef_ai_main/core/supabase_config.dart';
import '../models/habit.dart';

class HabitService {
  static const String _habitsTable = 'habit';
  static const String _logsTable = 'habit_logs';

  // Fetch all habits for current user
  Future<List<Habit>> fetchHabits() async {
    try {
      final response = await SupabaseConfig.client
          .from(_habitsTable)
          .select('id, name, description, type, user_id, created_at')
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => Habit.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching habits: $e');
      rethrow;
    }
  }

  // Fetch logs for specific date
  Future<List<HabitLog>> fetchLogsForDate(DateTime date) async {
    try {
      final formattedDate = date.toIso8601String().split('T').first;
      final response = await SupabaseConfig.client
          .from(_logsTable)
          .select()
          .eq('date', formattedDate);

      return (response as List)
          .map((e) => HabitLog.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching logs: $e');
      rethrow;
    }
  }

  // Merge habits with logs for a specific date
  Future<List<Habit>> fetchHabitsWithLogsForDate(DateTime date) async {
    try {
      final habits = await fetchHabits();
      final logs = await fetchLogsForDate(date);

      // Create a map for quick lookup
      final logMap = {
        for (final log in logs) log.habitId: log.status,
      };

      // Normalize date to remove time component (yyyy-MM-dd)
      final normalizedSelectedDate = DateTime(date.year, date.month, date.day);

      // Filter and merge habits
      return habits.where((habit) {
        // Normalize habit creation date (yyyy-MM-dd)
        final normalizedCreatedDate = DateTime(
          habit.createdAt.year,
          habit.createdAt.month,
          habit.createdAt.day,
        );

        // Only show habit if selected date >= creation date
        // Example: If habit created on Jan 15, show it on Jan 15, 16, 17... but NOT Jan 14, 13, etc
        return normalizedSelectedDate.isAfter(normalizedCreatedDate) ||
            normalizedSelectedDate.isAtSameMomentAs(normalizedCreatedDate);
      }).map((habit) {
        return habit.copyWith(status: logMap[habit.id] ?? false);
      }).toList();
    } catch (e) {
      print('Error merging habits with logs: $e');
      rethrow;
    }
  }

  // Add new habit
  Future<Habit> addHabit(String name, {String? description, String? type}) async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await SupabaseConfig.client
          .from(_habitsTable)
          .insert({
        'name': name.trim(),
        'description': description,
        'type': type,
        'user_id': userId,
      })
          .select()
          .single();

      return Habit.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error adding habit: $e');
      rethrow;
    }
  }

  // Toggle habit completion for a specific date
  Future<void> toggleHabitCompletion(
      String habitId,
      DateTime date,
      bool isDone,
      ) async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final formattedDate = date.toIso8601String().split('T').first;

      // Check if log exists
      final existing = await SupabaseConfig.client
          .from(_logsTable)
          .select()
          .eq('habit_id', habitId)
          .eq('date', formattedDate)
          .maybeSingle();

      if (existing == null) {
        // Create new log
        await SupabaseConfig.client.from(_logsTable).insert({
          'habit_id': habitId,
          'date': formattedDate,
          'status': !isDone,
          'user_id': userId,
        });
      } else {
        // Update existing log
        await SupabaseConfig.client
            .from(_logsTable)
            .update({'status': !isDone})
            .eq('id', existing['id']);
      }
    } catch (e) {
      print('Error toggling habit: $e');
      rethrow;
    }
  }

  // Delete habit
  Future<void> deleteHabit(String habitId) async {
    try {
      // First delete all logs associated with this habit
      await SupabaseConfig.client
          .from(_logsTable)
          .delete()
          .eq('habit_id', habitId);

      // Then delete the habit itself
      await SupabaseConfig.client
          .from(_habitsTable)
          .delete()
          .eq('id', habitId);
    } catch (e) {
      print('Error deleting habit: $e');
      rethrow;
    }
  }

  // Update habit
  Future<Habit> updateHabit(String habitId, {String? name, String? description}) async {
    try {
      final response = await SupabaseConfig.client
          .from(_habitsTable)
          .update({
        if (name != null) 'name': name.trim(),
        if (description != null) 'description': description.trim(),
      })
          .eq('id', habitId)
          .select()
          .single();

      return Habit.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error updating habit: $e');
      rethrow;
    }
  }

  // Stream habit logs for real-time updates
  Stream<List<HabitLog>> streamLogsForDate(DateTime date) {
    final formattedDate = date.toIso8601String().split('T').first;
    return SupabaseConfig.client
        .from(_logsTable)
        .stream(primaryKey: ['id'])
        .eq('date', formattedDate)
        .map((logs) => (logs as List)
        .map((e) => HabitLog.fromJson(e as Map<String, dynamic>))
        .toList());
  }
}