import 'package:flutter/material.dart';
import 'package:redef_ai_main/models/task.dart';
import 'package:redef_ai_main/widgets/edit_delete_dialog.dart';

class TaskListWidget extends StatelessWidget {
  final List<Task> tasks;
  final bool isCompleted;
  final Function(String taskId) onToggleCompletion;
  final String? title;

  const TaskListWidget({
    super.key,
    required this.tasks,
    required this.isCompleted,
    required this.onToggleCompletion,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: tasks.map((task) => _TaskItem(
              task: task,
              isCompleted: isCompleted,
              onToggle: () => onToggleCompletion(task.id),
            )).toList(),
          ),
        ),
      ],
    );
  }
}

class _TaskItem extends StatelessWidget {
  final Task task;
  final bool isCompleted;
  final VoidCallback onToggle;

  const _TaskItem({
    required this.task,
    required this.isCompleted,
    required this.onToggle,
  });


  void _showEditDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditDeleteTaskDialog(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () => _showEditDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (_) => onToggle(),
              activeColor: isCompleted ? Colors.grey.shade400 : null,
              side: const BorderSide(color: Colors.black, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? Colors.grey.shade400 : Colors.black,
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}