import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redef_ai_main/providers/tasks_provider.dart';
import 'package:redef_ai_main/widgets/add_task_dialog.dart';
import 'package:redef_ai_main/widgets/task_list.dart';
import '../Theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().initialize();
    });
  }

  void _showAddTaskDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryFilter(),
            const SizedBox(height: 20),
            _buildTaskList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        onPressed: _showAddTaskDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          Icon(
            Icons.description_outlined,
            size: 28,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 8),
          Text(
            'Tasks',
            style: TextStyle(
              fontSize: 30,
              fontFamily: 'SourceSerif4',
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip(
                    label: 'All',
                    isSelected: provider.selectedCategory == 'all',
                    onTap: () => provider.setSelectedCategory('all'),
                  ),
                  const SizedBox(width: 8),
                  ...provider.categories.map((catName) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildCategoryChip(
                        label: catName,
                        isSelected: provider.selectedCategory == catName,
                        onTap: () => provider.setSelectedCategory(catName),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : Colors.transparent,
          border: Border.all(
            color: AppColors.secondary,
            width: isSelected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return Expanded(
      child: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => provider.initialize(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final activeTasks = provider.activeTasks;
          final completedTasks = provider.completedTasks;

          if (activeTasks.isEmpty && completedTasks.isEmpty) {
            return _buildEmptyState();
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              TaskListWidget(
                tasks: activeTasks,
                isCompleted: false,
                onToggleCompletion: provider.toggleTaskCompletion,
              ),
              if (completedTasks.isNotEmpty) ...[
                const SizedBox(height: 16),
                TaskListWidget(
                  tasks: completedTasks,
                  isCompleted: true,
                  title: 'Completed',
                  onToggleCompletion: provider.toggleTaskCompletion,
                ),
              ],
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
// Fallback screen if no task are there
  Widget _buildEmptyState() {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                provider.selectedCategory == 'all'
                    ? 'No tasks yet'
                    : 'No tasks in this category',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap + to add a new task',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}