import 'package:redef_ai_main/models/task.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';

class TaskService {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<String?> getUserId() async {
    try {
      final authUserId = _client.auth.currentUser?.id;
      if (authUserId == null) {
        print('No auth user found!');
        return null;
      }
      print('🔍 Auth user ID: $authUserId');
      final userRow = await _client
          .from('users')
          .select('id')
          .eq('id', authUserId)
          .maybeSingle();

      if (userRow == null) {
        print('No public user found for this auth user!');
        return null;
      }

      return userRow['id'] as String;
    } catch (e,stackTrace) {
      print('❌ Error getting user ID: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<List<Task>> fetchTasks(String userId) async {
    try {
      final response = await _client
          .from('tasks')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Task.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching tasks: $e');
      rethrow;
    }
  }
  Future<Task> fetchTaskById(String taskId) async {
    try {
      final response = await _client
          .from('tasks')
          .select('*')
          .eq('id', taskId)
          .single();

      return Task.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching task by ID: $e');
      rethrow;
    }
  }

  Future<Task> createTask({
    required String name,
    required String userId,
    String? category,
  }) async {
    try {
      final response = await _client
          .from('tasks')
          .insert({
        'name': name,
        'category': category,
        'is_completed': false,
        'user_id': userId,
      })
          .select()
          .single();

      return Task.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  Future<void> updateTaskCompletion({
    required String taskId,
    required bool isCompleted,
  }) async {
    try {
      await _client.from('tasks').update({
        'is_completed': isCompleted,
        'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
      }).eq('id', taskId);
    } catch (e) {
      print('Error updating task completion: $e');
      rethrow;
    }
  }

  Future<Task> updateTask({
    required String taskId,
    String? name,
    String? category,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (category != null) updateData['category'] = category;

      final response = await _client
          .from('tasks')
          .update(updateData)
          .eq('id', taskId)
          .select()
          .single();

      return Task.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _client.from('tasks').delete().eq('id', taskId);
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  List<String> extractCategories(List<Task> tasks) {
    final categories = tasks
        .where((task) => task.category != null && task.category!.isNotEmpty)
        .map((task) => task.category!)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }
}