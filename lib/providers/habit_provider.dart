// lib/providers/habit_provider.dart

import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitService _habitService;

  HabitProvider({required HabitService habitService}) : _habitService = habitService;

  // State variables
  List<Habit> _habits = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Habit> get habits => _habits;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Habit> get activeHabits =>
      _habits.where((h) => !h.status).toList();

  List<Habit> get completedHabits =>
      _habits.where((h) => h.status).toList();

  // Initialize provider and set up real-time listeners
  Future<void> initialize() async {
    await loadHabits();
    _setupRealtimeListeners();
  }

  // Set up real-time listeners
  void _setupRealtimeListeners() {
    _habitService.streamLogsForDate(_selectedDate).listen((logs) {
      _updateHabitsWithLogs(logs);
    });
  }

  // Load habits for selected date
  Future<void> loadHabits() async {
    _setLoading(true);
    _clearError();

    try {
      _habits = await _habitService.fetchHabitsWithLogsForDate(_selectedDate);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load habits: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Change selected date and reload habits
  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    await loadHabits();
  }

  // Add new habit
  Future<void> addHabit(String name, {String? description, String? type}) async {
    _clearError();

    try {
      final newHabit = await _habitService.addHabit(
        name,
        description: description,
        type: type,
      );
      _habits.add(newHabit);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add habit: $e');
    }
  }

  // Toggle habit completion
  Future<void> toggleHabit(String habitId, bool currentStatus) async {
    _clearError();

    try {
      // Update locally for instant UI feedback
      final index = _habits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        _habits[index] = _habits[index].copyWith(status: !currentStatus);
        notifyListeners();
      }

      // Update in database
      await _habitService.toggleHabitCompletion(
        habitId,
        _selectedDate,
        currentStatus,
      );
    } catch (e) {
      _setError('Failed to update habit: $e');
      // Revert local change on error
      await loadHabits();
    }
  }

  // Delete habit
  Future<void> deleteHabit(String habitId) async {
    _clearError();

    try {
      // Remove from local state immediately for UI feedback
      _habits.removeWhere((h) => h.id == habitId);
      notifyListeners();

      // Delete from database
      await _habitService.deleteHabit(habitId);

      print('✅ Habit deleted successfully: $habitId');
    } catch (e) {
      _setError('Failed to delete habit: $e');
      print('❌ Error deleting habit: $e');
      // Reload habits on error to sync state
      await loadHabits();
    }
  }

  // Update habit
  Future<void> updateHabit(String habitId, {String? name, String? description}) async {
    _clearError();

    try {
      final updatedHabit = await _habitService.updateHabit(
        habitId,
        name: name,
        description: description,
      );
      final index = _habits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        _habits[index] = updatedHabit;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update habit: $e');
    }
  }

  // Helper method to update habits with logs
  void _updateHabitsWithLogs(List<HabitLog> logs) {
    final logMap = {for (final log in logs) log.habitId: log.status};

    // Normalize selected date
    final selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    for (var i = 0; i < _habits.length; i++) {
      if (logMap.containsKey(_habits[i].id)) {
        _habits[i] = _habits[i].copyWith(status: logMap[_habits[i].id]);
      }

      // Double check habit should be visible on this date
      final habitCreatedDate = DateTime(
        _habits[i].createdAt.year,
        _habits[i].createdAt.month,
        _habits[i].createdAt.day,
      );

      if (selectedDate.isBefore(habitCreatedDate)) {
        // Remove habit if we're viewing a date before it was created
        _habits.removeAt(i);
        i--;
      }
    }
    notifyListeners();
  }

  // Helper methods for state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}