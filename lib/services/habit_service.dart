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
      final logMap = {for (final log in logs) log.habitId: log.status};

      // Normalize date to remove time component (yyyy-MM-dd)
      final normalizedSelectedDate = DateTime(date.year, date.month, date.day);

      // Filter and merge habits WITH STREAKS (calculated up to selected date)
      final habitsWithStatus = habits
          .where((habit) {
        final normalizedCreatedDate = DateTime(
          habit.createdAt.year,
          habit.createdAt.month,
          habit.createdAt.day,
        );
        return normalizedSelectedDate.isAfter(normalizedCreatedDate) ||
            normalizedSelectedDate.isAtSameMomentAs(normalizedCreatedDate);
      })
          .map((habit) {
        return habit.copyWith(status: logMap[habit.id] ?? false);
      })
          .toList();

      // Fetch streaks for all habits in parallel - PASS THE SELECTED DATE
      final streaksResults = await Future.wait(
          habitsWithStatus.map((habit) => getHabitStreak(habit.id, upToDate: date))
      );

      // Assign streaks to habits
      for (int i = 0; i < habitsWithStatus.length; i++) {
        habitsWithStatus[i] = habitsWithStatus[i].copyWith(
            streak: streaksResults[i]
        );
      }

      return habitsWithStatus;
    } catch (e) {
      print('Error merging habits with logs: $e');
      rethrow;
    }
  }

  // Add new habit
  Future<Habit> addHabit(
      String name, {
        String? description,
        String? type,
      }) async {
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
      await SupabaseConfig.client.from(_habitsTable).delete().eq('id', habitId);
    } catch (e) {
      print('Error deleting habit: $e');
      rethrow;
    }
  }

  // Update habit
  Future<Habit> updateHabit(
      String habitId, {
        String? name,
        String? description,
      }) async {
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
        .map(
          (logs) => (logs as List)
          .map((e) => HabitLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // FIXED: Calculate streak UP TO a specific date (not always today)
  Future<int> getHabitStreak(String habitId, {DateTime? upToDate}) async {
    try {
      // Use provided date or default to today
      final targetDate = upToDate ?? DateTime.now();
      final normalizedTargetDate = DateTime(targetDate.year, targetDate.month, targetDate.day);

      // Fetch all completed logs for this habit UP TO the target date
      final response = await SupabaseConfig.client
          .from('habit_logs')
          .select('date, status')
          .eq('habit_id', habitId)
          .eq('status', true)
          .lte('date', normalizedTargetDate.toIso8601String().split('T').first)
          .order('date', ascending: false);

      if (response == null || (response as List).isEmpty) return 0;

      final logs = (response as List)
          .map((e) => DateTime.parse(e['date'] as String))
          .toList();

      int streak = 0;
      DateTime expectedDate = normalizedTargetDate;

      // Check if habit was completed on target date or the day before
      final mostRecentLog = logs.first;
      final daysSinceLastLog = normalizedTargetDate.difference(mostRecentLog).inDays;

      if (daysSinceLastLog > 1) {
        // More than 1 day gap from target date - streak is broken
        return 0;
      }

      // If completed the day before target date, start checking from that day
      if (daysSinceLastLog == 1) {
        expectedDate = normalizedTargetDate.subtract(Duration(days: 1));
      }

      // Count consecutive days going backwards from expected date
      for (final logDate in logs) {
        final normalizedLogDate = DateTime(logDate.year, logDate.month, logDate.day);

        if (normalizedLogDate.isAtSameMomentAs(expectedDate)) {
          streak++;
          expectedDate = expectedDate.subtract(Duration(days: 1));
        } else if (normalizedLogDate.isBefore(expectedDate)) {
          // Found a gap - streak is broken
          break;
        }
      }

      return streak;
    } catch (e) {
      print('Error calculating streak: $e');
      return 0;
    }
  }
}