import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../design_tokens.dart';
import '../models/habit.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  const HabitDetailScreen({Key? key, required this.habit}) : super(key: key);

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late DateTime displayMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    displayMonth = DateTime(now.year, now.month);
  }

  void _prevMonth() {
    setState(() {
      displayMonth = DateTime(displayMonth.year, displayMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      displayMonth = DateTime(displayMonth.year, displayMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    int currentStreak = widget.habit.calculateStreak(now);
    
    // Calculate best streak historically
    int bestStreak = _calculateBestStreak(widget.habit);
    
    // Calculate completion metrics
    final startMidnight = DateTime(widget.habit.startedAt.year, widget.habit.startedAt.month, widget.habit.startedAt.day);
    final todayMidnight = DateTime(now.year, now.month, now.day);
    
    DateTime trackEnd = todayMidnight;
    if (widget.habit.endDate != null) {
      final endMid = DateTime(widget.habit.endDate!.year, widget.habit.endDate!.month, widget.habit.endDate!.day);
      if (todayMidnight.isAfter(endMid)) trackEnd = endMid;
    }
    
    int totalPossibleDays = trackEnd.difference(startMidnight).inDays + 1;
    if (totalPossibleDays < 0) totalPossibleDays = 0;
    
    int completedDays = widget.habit.completedDates.where((d) {
       final dMid = DateTime(d.year, d.month, d.day);
       return !dMid.isBefore(startMidnight) && !dMid.isAfter(trackEnd);
    }).length;
    
    int completionPercentage = totalPossibleDays > 0 ? ((completedDays / totalPossibleDays) * 100).toInt() : 0;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: Spacing.md),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: textColor, size: 16),
            ),
          ),
        ),
        title: Text(
          widget.habit.name,
          style: const TextStyle(
             fontFamily: "TTNormsPro",
             fontSize: 16,
             fontWeight: FontWeight.w500,
             color: textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Spacing.md),
            child: GestureDetector(
              onTap: () {}, // Placeholder for future actions like Edit
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.more_horiz, color: textColor, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xl, vertical: Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Streak
            Text(
              "Current streak",
              style: TextStyle(
                fontFamily: "TTNormsPro",
                fontSize: 14,
                color: textColor.withValues(alpha: 0.5),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "$currentStreak days",
                  style: const TextStyle(
                    fontFamily: "TTNormsPro",
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    currentStreak > 0 ? "You're on fire 🔥" : "Start today!",
                    style: TextStyle(
                      fontFamily: "TTNormsPro",
                      fontSize: 14,
                      fontWeight: currentStreak > 0 ? FontWeight.w500 : FontWeight.normal,
                      color: currentStreak > 0 ? cta : textColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xxl),
            
            // Best Streak
            Text(
              "Best streak",
              style: TextStyle(
                fontFamily: "TTNormsPro",
                fontSize: 14,
                color: textColor.withValues(alpha: 0.5),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "$bestStreak days",
                  style: const TextStyle(
                    fontFamily: "TTNormsPro",
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    bestStreak > 0 ? "Well done!" : "",
                    style: TextStyle(
                      fontFamily: "TTNormsPro",
                      fontSize: 14,
                      color: textColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xxl),

            // Completion
            Text(
              "Completion",
              style: TextStyle(
                fontFamily: "TTNormsPro",
                fontSize: 14,
                color: textColor.withValues(alpha: 0.5),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "$completionPercentage%",
                  style: const TextStyle(
                    fontFamily: "ndot",
                    fontSize: 42,
                    color: cta,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    "$completedDays of $totalPossibleDays days",
                    style: TextStyle(
                      fontFamily: "TTNormsPro",
                      fontSize: 14,
                      color: textColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: Spacing.xxl),
            
            // Calendar Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 GestureDetector(
                   onTap: _prevMonth,
                   child: const Icon(Icons.arrow_back_ios, color: textColor, size: 16),
                 ),
                 Text(
                   DateFormat('MMMM yyyy').format(displayMonth),
                   style: const TextStyle(
                     fontFamily: "TTNormsPro",
                     fontSize: 16,
                     fontWeight: FontWeight.w600,
                     color: textColor,
                   ),
                 ),
                 GestureDetector(
                   onTap: _nextMonth,
                   child: const Icon(Icons.arrow_forward_ios, color: textColor, size: 16),
                 ),
              ],
            ),
            const SizedBox(height: Spacing.xl),
            
            // Calendar Grid Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ["M", "T", "W", "T", "F", "S", "S"].map((e) => Text(
                e,
                style: TextStyle(
                  fontFamily: "ndot",
                  fontSize: 14,
                  color: textColor.withValues(alpha: 0.5),
                ),
              )).toList(),
            ),
            const SizedBox(height: Spacing.md),
            
            // Calendar Grid Dates
            _buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final lastDayOfMonth = DateTime(displayMonth.year, displayMonth.month + 1, 0);
    
    // weekday is 1=Mon, 7=Sun
    // how many empty slots before day 1?
    int emptySlots = firstDayOfMonth.weekday - 1;
    
    List<Widget> dayWidgets = [];
    
    for (int i = 0; i < emptySlots; i++) {
       dayWidgets.add(const SizedBox(width: 40, height: 40)); // Placeholder
    }
    
    for (int d = 1; d <= lastDayOfMonth.day; d++) {
       DateTime date = DateTime(displayMonth.year, displayMonth.month, d);
       bool isCompleted = widget.habit.isCheckedOn(date);
       bool isFuture = date.isAfter(DateTime.now());
       
       dayWidgets.add(
         Container(
           width: 40, 
           height: 40,
           margin: const EdgeInsets.only(bottom: 8),
           alignment: Alignment.center,
           decoration: BoxDecoration(
             shape: BoxShape.circle,
             color: isFuture 
                ? Colors.transparent 
                : (isCompleted ? cta : textColor.withValues(alpha: 0.08)),
             border: Border.all(
                color: isFuture ? textColor.withValues(alpha: 0.2) : Colors.transparent, 
                width: 1
             ),
           ),
           child: Text(
             d.toString(),
             style: TextStyle(
               fontFamily: "TTNormsPro",
               fontSize: 14,
               fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w500,
                color: isFuture 
                  ? textColor.withValues(alpha: 0.4)
                  : (isCompleted ? textColor : textColor.withValues(alpha: 0.7)),
             ),
           ),
         ),
       );
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.spaceBetween,
      children: dayWidgets.map((w) => SizedBox(
         width: (MediaQuery.of(context).size.width - 2 * Spacing.xl - 6 * 8) / 7,
         child: Center(child: w),
      )).toList(),
    );
  }

  int _calculateBestStreak(Habit habit) {
    if (habit.completedDates.isEmpty) return 0;
    final dates = habit.completedDates.map((d) => DateTime(d.year, d.month, d.day)).toSet().toList()
      ..sort((a, b) => a.compareTo(b));
    
    int maxStreak = 1;
    int currentRun = 1;
    
    for (int i = 1; i < dates.length; i++) {
        if (dates[i].difference(dates[i-1]).inDays == 1) {
            currentRun++;
            if (currentRun > maxStreak) maxStreak = currentRun;
        } else if (dates[i].difference(dates[i-1]).inDays > 1) {
            currentRun = 1;
        }
    }
    return maxStreak;
  }
}
