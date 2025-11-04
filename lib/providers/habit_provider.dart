// lib/providers/habit_provider.dart

import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitService _habitService;
  Map<String, Map<String, int>> _dateStats = {};

  Map<String, Map<String, int>> get dateStats => _dateStats;

  HabitProvider({required HabitService habitService}) : _habitService = habitService;

  Future<void> loadDateStats(List<DateTime> dates) async {
    try {
      final Map<String, Map<String, int>> stats = {};

      for (final date in dates) {
        final dateKey = _getDateKey(date);
        final habits = await _habitService.fetchHabitsWithLogsForDate(date);

        final completed = habits.where((h) => h.status).length;
        final total = habits.length;

        stats[dateKey] = {
          'completed': completed,
          'total': total,
        };
      }

      _dateStats = stats;
      notifyListeners();
    } catch (e) {
      print('Error loading date stats: $e');
    }
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

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

  int get todayCompletedHabits {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedSelected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (normalizedSelected.isAtSameMomentAs(normalizedToday)) {
      return _habits.where((h) => h.status).length;
    }
    return 0;
  }

  int get todayTotalHabits {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedSelected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (normalizedSelected.isAtSameMomentAs(normalizedToday)) {
      return _habits.length;
    }
    return 0;
  }

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
      // This now includes streaks automatically
      _habits = await _habitService.fetchHabitsWithLogsForDate(_selectedDate);

      final today = DateTime.now();
      final datesToLoad = List.generate(6, (index) {
        return today.add(Duration(days: index - 3));
      });
      await loadDateStats(datesToLoad);

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

  // Toggle habit completion - NOW UPDATES STREAK
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

      // IMPORTANT: Refresh the streak after toggle
      // Only refresh if we're on today's date
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);
      final normalizedSelected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

      if (normalizedSelected.isAtSameMomentAs(normalizedToday)) {
        await _refreshSingleHabitStreak(habitId);
      }
    } catch (e) {
      _setError('Failed to update habit: $e');
      // Revert local change on error
      await loadHabits();
    }
  }

  // Helper to refresh streak for a single habit
  Future<void> _refreshSingleHabitStreak(String habitId) async {
    try {
      final newStreak = await _habitService.getHabitStreak(habitId, upToDate: _selectedDate);
      final index = _habits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        _habits[index] = _habits[index].copyWith(streak: newStreak);
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing streak: $e');
    }
  }

  // Delete habit
  Future<void> deleteHabit(String habitId) async {
    _clearError();

    try {
      _habits.removeWhere((h) => h.id == habitId);
      notifyListeners();

      await _habitService.deleteHabit(habitId);
      print('✅ Habit deleted successfully: $habitId');
    } catch (e) {
      _setError('Failed to delete habit: $e');
      print('❌ Error deleting habit: $e');
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
        // Preserve the streak when updating
        _habits[index] = updatedHabit.copyWith(
          streak: _habits[index].streak,
          status: _habits[index].status,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update habit: $e');
    }
  }

  // Helper method to update habits with logs
  void _updateHabitsWithLogs(List<HabitLog> logs) async {
    final logMap = {for (final log in logs) log.habitId: log.status};
    final selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    for (var i = 0; i < _habits.length; i++) {
      if (logMap.containsKey(_habits[i].id)) {
        _habits[i] = _habits[i].copyWith(status: logMap[_habits[i].id]);
      }

      final habitCreatedDate = DateTime(
        _habits[i].createdAt.year,
        _habits[i].createdAt.month,
        _habits[i].createdAt.day,
      );

      if (selectedDate.isBefore(habitCreatedDate)) {
        _habits.removeAt(i);
        i--;
      }
    }

    // Refresh streaks for all habits if we're on today
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    if (selectedDate.isAtSameMomentAs(normalizedToday)) {
      await _refreshAllStreaks();
    }

    notifyListeners();
  }

  // Refresh streaks for all habits
  Future<void> _refreshAllStreaks() async {
    try {
      for (var i = 0; i < _habits.length; i++) {
        final streak = await _habitService.getHabitStreak(_habits[i].id);
        _habits[i] = _habits[i].copyWith(streak: streak);
      }
    } catch (e) {
      print('Error refreshing all streaks: $e');
    }
  }

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

  // This method is now redundant since streaks are loaded with habits
  Future<int> getHabitStreak(String habitId) async {
    try {
      return await _habitService.getHabitStreak(habitId);
    } catch (e) {
      print('Error getting streak: $e');
      return 0;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}