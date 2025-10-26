import 'package:flutter/foundation.dart';
import 'package:redef_ai_main/models/task.dart';
import '../services/task_service.dart';

enum TaskStatus { idle, loading, success, error }

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];
  List<String> _categories = [];
  String _selectedCategory = 'all';
  String? _userId;
  TaskStatus _status = TaskStatus.idle;
  String? _errorMessage;

  List<Task> get tasks => _tasks;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String? get userId => _userId;
  TaskStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == TaskStatus.loading;

  List<Task> get filteredTasks {
    if (_selectedCategory == 'all') return _tasks;
    return _tasks.where((task) => task.category == _selectedCategory).toList();
  }

  List<Task> get activeTasks {
    return filteredTasks.where((task) => !task.isCompleted).toList();
  }

  List<Task> get completedTasks {
    return filteredTasks.where((task) => task.isCompleted).toList();
  }

  Future<void> initialize() async {
    _setStatus(TaskStatus.loading);

    try {
      _userId = await _taskService.getUserId();
      if (_userId == null) {
        _setStatus(TaskStatus.error);
        _errorMessage = 'User not authenticated';
        return;
      }

      await fetchTasks();
    } catch (e) {
      _setStatus(TaskStatus.error);
      _errorMessage = e.toString();
      print('Error initializing: $e');
    }
  }

  Future<void> fetchTasks() async {
    if (_userId == null) return;

    _setStatus(TaskStatus.loading);

    try {
      _tasks = await _taskService.fetchTasks(_userId!);
      _categories = _taskService.extractCategories(_tasks);
      // ✅ Print all tasks nicely
      print('🎁 Fetched ${userId} tasks:');
      print('✅ Fetched ${_tasks.length} tasks:');
      for (var task in _tasks) {
        print(
            '• ${task.name} - ${task.isCompleted ? "Completed" : "Pending"} - Category: ${task.category ?? "None"} - CompletedAt: ${task.completedAt}'
        );
      }
      _setStatus(TaskStatus.success);
    } catch (e) {
      _setStatus(TaskStatus.error);
      _errorMessage = e.toString();
      print('Error fetching tasks: $e');
    }
  }

  Future<bool> createTask({
    required String name,
    String? category,
  }) async {
    if (_userId == null) return false;

    try {
      final newTask = await _taskService.createTask(
        name: name,
        userId: _userId!,
        category: category,
      );

      _tasks.insert(0, newTask);
      _updateCategories();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error creating task: $e');
      return false;
    }
  }

// Improved version of toggleTaskCompletion method

  Future<void> toggleTaskCompletion(String taskId) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = _tasks[taskIndex];
    final newCompletionStatus = !task.isCompleted;

    // Optimistic update
    _tasks[taskIndex] = task.copyWith(
      isCompleted: newCompletionStatus,
      completedAt: newCompletionStatus ? DateTime.now() : null,
    );
    notifyListeners();

    try {
      // Update database
      await _taskService.updateTaskCompletion(
        taskId: taskId,
        isCompleted: newCompletionStatus,
      );

      // Refetch the specific task to get the accurate server timestamp
      final updatedTask = await _taskService.fetchTaskById(taskId);
      _tasks[taskIndex] = updatedTask;
      notifyListeners();

    } catch (e) {
      // Revert on failure
      _tasks[taskIndex] = task;
      _errorMessage = e.toString();
      notifyListeners();
      print('Error toggling task completion: $e');

      // Rethrow to let UI show error notification
      rethrow;
    }
  }
  Future<bool> updateTask({
    required String taskId,
    String? name,
    String? category,
  }) async {
    try {
      final updatedTask = await _taskService.updateTask(
        taskId: taskId,
        name: name,
        category: category,
      );

      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _tasks[index] = updatedTask;
        _updateCategories();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error updating task: $e');
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      _updateCategories();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error deleting task: $e');
      return false;
    }
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setStatus(TaskStatus status) {
    _status = status;
    notifyListeners();
  }

  void _updateCategories() {
    _categories = _taskService.extractCategories(_tasks);
  }
}
