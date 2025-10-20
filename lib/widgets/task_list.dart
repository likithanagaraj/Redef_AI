import 'package:flutter/material.dart';
import 'package:redef_ai_main/models/task.dart';
import 'package:redef_ai_main/widgets/edit_delete_dialog.dart';

class TaskListWidget extends StatefulWidget {
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
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: _isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.arrow_right,
                    size: 28,
                    color: Colors.grey.shade500,

                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (_isExpanded || widget.title == null) ...[
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
              children: widget.tasks
                  .map((task) => _TaskItem(
                task: task,
                isCompleted: widget.isCompleted,
                onToggle: () => widget.onToggleCompletion(task.id),
              ))
                  .toList(),
            ),
          ),
        ],
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
      onTap: () => onToggle(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (_) => onToggle(),
              activeColor: isCompleted ? Colors.grey.shade400 : null,
              side: const BorderSide(color: Colors.black, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              visualDensity: VisualDensity.comfortable,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                      height: 1,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: isCompleted
                          ? Colors.grey.shade400
                          : Colors.black,
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