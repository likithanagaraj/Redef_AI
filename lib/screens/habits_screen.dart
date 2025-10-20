// lib/screens/habits_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redef_ai_main/Theme.dart';
import 'package:redef_ai_main/widgets/habit_card.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  late HabitProvider _habitProvider;

  @override
  void initState() {
    super.initState();
    _habitProvider = Provider.of<HabitProvider>(context, listen: false);
    _habitProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildDateSelector(),
            const SizedBox(height: 24),
            _buildHabitsList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // Header with title and icon
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          Icon(
            Icons.repeat_outlined,
            size: 28,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 8),
          const Text(
            'Habits',
            style: TextStyle(
              fontSize: 30,
              color: Color(0xFF014E3C),
              fontFamily: 'SourceSerif4',
              fontWeight: FontWeight.w500,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  // Date selector widget
  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Consumer<HabitProvider>(
        builder: (context, provider, _) {
          return DateSelector(
            selectedDate: provider.selectedDate,
            onDateSelected: (date) => provider.selectDate(date),
          );
        },
      ),
    );
  }

  // Habits list with loading and empty states
  Widget _buildHabitsList() {
    return Expanded(
      child: Consumer<HabitProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF014E3C)),
            );
          }

          if (provider.habits.isEmpty) {
            return EmptyHabitsState(
              onAddHabit: _showAddHabitDialog,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.habits.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final habit = provider.habits[index];
              return HabitCard(
                habit: habit,
                onToggle: () => provider.toggleHabit(habit.id, habit.status),
                onEdit: () => _showEditHabitDialog(habit),
                onDelete: () => _showDeleteConfirmation(habit.id, habit.name),
              );
            },
          );
        },
      ),
    );
  }

  // Floating action button
  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _showAddHabitDialog,
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add, size: 32, color: Colors.white),
    );
  }

  // Show add habit dialog
  void _showAddHabitDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHabitDialog(
        title: 'Add Habit',
        onSubmit: (name, description) async {
          final provider = Provider.of<HabitProvider>(context, listen: false);
          await provider.addHabit(name, description: description);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Habit added successfully'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  // Show edit habit dialog
  void _showEditHabitDialog(Habit habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHabitDialog(
        title: 'Edit Habit',
        initialName: habit.name,
        initialDescription: habit.description,
        onSubmit: (name, description) async {
          final provider = Provider.of<HabitProvider>(context, listen: false);
          await provider.updateHabit(
            habit.id,
            name: name,
            description: description,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Habit updated successfully'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.blue,
              ),
            );
          }
        },
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(String habitId, String habitName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "$habitName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = Provider.of<HabitProvider>(context, listen: false);

              // Show loading indicator
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Deleting habit...'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              }

              await provider.deleteHabit(habitId);

              if (mounted) {
                if (provider.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.error ?? 'Error deleting habit'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Habit deleted successfully'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}