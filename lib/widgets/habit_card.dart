// lib/widgets/habit_widgets.dart

import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:redef_ai_main/Theme.dart';
import '../models/habit.dart';


// Habit Card Widget
class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final int streak;

  const HabitCard({
    Key? key,
    required this.habit,
    required this.onToggle,
    this.onDelete,
    this.onEdit,
    this.streak = 0
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>onToggle(),
      onLongPress: () => _showActionsMenu(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Checkbox(
              activeColor: Colors.grey.shade400,
              value: habit.status,
              onChanged: (_) => onToggle(),
              side: const BorderSide(color: Colors.black, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              visualDensity: VisualDensity.comfortable,
            ),
            Expanded(
              child: Text(
                habit.name,
                style: TextStyle(
                  fontSize: 16,
                  color: habit.status ? Colors.grey.shade500 : Colors.black,
                  decoration: habit.status
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            Row(
              children: [
                Image.asset('assets/images/streak.png',height: 16,width: 16,),
                SizedBox(width: 1,),
                Text('$streak',style: TextStyle(
                  fontFamily: 'SourceSerif4',
                  fontSize: 18,
                  fontWeight: FontWeight.w600
                ),)
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xffFDFBF9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit Habit'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit!();
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Habit'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete!();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// Date Selector Widget
class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Map<String, Map<String, int>> dateStats;

  const DateSelector({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.dateStats,
  }) : super(key: key);

  String _getDayLabel(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(7, (index) {
          final today = DateTime.now();
          final date = today.add(Duration(days: index - 3));
          final isSelected =
              date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
          final isToday = _isToday(date);
          final isFuture = date.isAfter(today) && !isToday;

          // Get stats for this date
          final dateKey = _getDateKey(date);
          final stats = dateStats[dateKey] ?? {'completed': 0, 'total': 0};
          final completed = stats['completed'] ?? 0;
          final total = stats['total'] ?? 0;

          // Calculate progress (0-100)
          final progress = total > 0 ? (completed / total) * 100.0 : 0.0;
          final isFullyCompleted = total > 0 && completed == total;

          final ValueNotifier<double> _valueNotifier = ValueNotifier(progress);

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 6),
              child: Column(
                children: [
                  // Day label and date wrapped together with background for today
                  Container(
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.secondary.withOpacity(0.05) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: isToday
                        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 6)
                        : EdgeInsets.zero,
                    child: Column(
                      children: [
                        Text(
                          _getDayLabel(date),
                          style: TextStyle(
                            fontSize: isSelected ? 12: 10,
                            fontFamily: 'Inter',
                            color: isSelected || isToday
                                ? Color(0xff4E8477)
                                : Colors.black,
                            fontWeight: isSelected || isToday
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: isFuture
                              ? BoxDecoration(
                            color: Color(0xffeeeeee),
                            shape: BoxShape.circle,
                          )
                              : null,
                          padding: const EdgeInsets.all(0),
                          child: isFullyCompleted
                              ? // FULLY COMPLETED = Filled circle with fire icon (no progress bar)
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Color(0xff4E8477),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/Fire.png',
                                width: 20,
                                height: 20,
                              ),
                            ),
                          )
                              : // NOT FULLY COMPLETED = Progress circle with date
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: isToday
                                ? DashedCircularProgressBar.aspectRatio(
                              aspectRatio: 1,
                              valueNotifier: _valueNotifier,
                              progress: progress,
                              maxProgress: 100,
                              corners: StrokeCap.round,
                              foregroundColor: Color(0xff4E8477),
                              backgroundColor: AppColors.white,
                              foregroundStrokeWidth: 3.5,
                              backgroundStrokeWidth: 3.5,
                              animation: true,
                              child: Center(
                                child: ValueListenableBuilder(
                                  valueListenable: _valueNotifier,
                                  builder: (_, double value, __) => Text(
                                    date.day.toString(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Color(0xff4E8477)
                                          : Colors.black,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            )
                                : DashedCircularProgressBar.aspectRatio(
                              aspectRatio: 1,
                              valueNotifier: _valueNotifier,
                              progress: progress,
                              maxProgress: 100,
                              corners: StrokeCap.round,
                              foregroundColor: Color(0xff4E8477),
                              backgroundColor: isFuture ? Colors.transparent : Colors.grey.withOpacity(0.2),
                              foregroundStrokeWidth: 3,
                              backgroundStrokeWidth: 3,
                              animation: true,
                              child: Center(
                                child: ValueListenableBuilder(
                                  valueListenable: _valueNotifier,
                                  builder: (_, double value, __) => Text(
                                    date.day.toString(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Color(0xff4E8477)
                                          : Colors.black,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      fontSize: isSelected ? 20 : 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Selection indicator dot - below the circle
                  SizedBox(height: 3),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(0xff4E8477)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Add/Edit Habit Dialog Widget
class AddHabitDialog extends StatefulWidget {
  final String title;
  final String? initialName;
  final String? initialDescription;
  final Function(String name, String? description) onSubmit;

  const AddHabitDialog({
    Key? key,
    this.title = 'Add Habit',
    this.initialName,
    this.initialDescription,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName);
    descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xffFDFBF9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'SourceSerif4',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              cursorColor: AppColors.primary,
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Habit name',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              cursorColor: AppColors.primary,
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Description (optional)',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter habit name'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  widget.onSubmit(
                    nameController.text.trim(),
                    descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  widget.title.startsWith('Add') ? 'Add Habit' : 'Update Habit',
                  style: const TextStyle(
                    color: Color(0xffFDFBF9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Empty State Widget
class EmptyHabitsState extends StatelessWidget {
  final VoidCallback onAddHabit;

  const EmptyHabitsState({Key? key, required this.onAddHabit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.repeat_outlined, size: 80, color: Colors.grey.shade500),
          const SizedBox(height: 8),
          Text(
            'No habits yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to add a new habit',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddHabit,
            icon: const Icon(Icons.add, color: Color(0xffFDFBF9)),
            label: const Text(
              'Add Your First Habit',
              style: TextStyle(color: Color(0xffFDFBF9), fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

// Progress Card Widget
class HabitProgressCard extends StatelessWidget {
  final int completedHabits;
  final int totalHabits;

  const HabitProgressCard({
    Key? key,
    required this.completedHabits,
    required this.totalHabits,
  }) : super(key: key);

  String get _motivationalMessage {
    if (totalHabits == 0) return "Add habits to get started";

    final percentage = (completedHabits / totalHabits * 100).round();

    if (percentage == 0) return "Let's get started!";
    if (percentage < 30) return "Keep going!";
    if (percentage < 50) return "On track!";
    if (percentage < 80) return "You're doing well";
    if (percentage < 100) return "Almost there!";
    return "Perfect! All done ";
  }

  @override
  Widget build(BuildContext context) {
    final percentage = totalHabits > 0
        ? (completedHabits / totalHabits * 100).round()
        : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Fire emoji icon
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Color(0xffFFF4E6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '🔥',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _motivationalMessage,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SourceSerif4',
                    color: Colors.black,
                    letterSpacing: -0.2
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$completedHabits of $totalHabits habits completed',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          // Percentage
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              fontFamily: 'SourceSerif4',
              color: Color(0xff4E8477),
              letterSpacing: -1
            ),
          ),
        ],
      ),
    );
  }
}