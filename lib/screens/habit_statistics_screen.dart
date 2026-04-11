import 'dart:math';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../design_tokens.dart';
import '../models/habit.dart';

class HabitStatisticsScreen extends StatefulWidget {
  const HabitStatisticsScreen({Key? key}) : super(key: key);

  @override
  State<HabitStatisticsScreen> createState() => _HabitsStatisticsScreenState();
}

class _HabitsStatisticsScreenState extends State<HabitStatisticsScreen> {
  bool isLoading = true;
  int totalCompleted = 0;
  int totalPossible = 0;
  int highestStreakOverall = 0;
  late Map<int, int> monthlyCompletions;
  final int currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final isar = Isar.getInstance()!;
    final loadedHabits = await isar.habits.where().filter().isDeletedEqualTo(false).findAll();

    Map<int, int> monthCounts = {for (var i = 1; i <= 12; i++) i: 0};
    int completed = 0;
    int possible = 0;
    int highestStreak = 0;

    if (loadedHabits.isNotEmpty) {
      final todayMidnight = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

      for (var habit in loadedHabits) {
        // Calculate max streak globally
        int habitBest = _calculateBestStreak(habit);
        if (habitBest > highestStreak) highestStreak = habitBest;

        // Populate Monthly completions for Current Year
        for (var date in habit.completedDates) {
          if (date.year == currentYear) {
             monthCounts[date.month] = (monthCounts[date.month] ?? 0) + 1;
          }
        }

        // Possible vs Completed globally
        final startMidnight = DateTime(habit.startedAt.year, habit.startedAt.month, habit.startedAt.day);
        if (todayMidnight.isBefore(startMidnight)) continue;

        DateTime endTrack = todayMidnight;
        if (habit.endDate != null) {
          final endMid = DateTime(habit.endDate!.year, habit.endDate!.month, habit.endDate!.day);
          if (todayMidnight.isAfter(endMid)) endTrack = endMid;
        }

        int possibleDays = endTrack.difference(startMidnight).inDays + 1;
        if (possibleDays < 0) possibleDays = 0;

        int completedDays = habit.completedDates.where((d) {
          final dMid = DateTime(d.year, d.month, d.day);
          return !dMid.isBefore(startMidnight) && !dMid.isAfter(endTrack);
        }).length;

        possible += possibleDays;
        completed += completedDays;
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
        monthlyCompletions = monthCounts;
        totalCompleted = completed;
        totalPossible = possible;
        highestStreakOverall = highestStreak;
      });
    }
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

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          "Statistics",
          style: TextStyle(
             fontFamily: "TTNormsPro",
             fontSize: 16,
             fontWeight: FontWeight.w500,
             color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: cta))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   // 1. Success / fail donut chart
                   _buildSuccessFailSection(),

                   const SizedBox(height: Spacing.xxl * 2),

                   // 3. Streak Challenge Badges
                   _buildStreakChallengeSection(),

                   const SizedBox(height: Spacing.xxl * 2),
                ],
              ),
            ),
    );
  }



  Widget _buildSuccessFailSection() {
    int missed = totalPossible - totalCompleted;
    if (missed < 0) missed = 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             children: [
               const Icon(Icons.pie_chart_outline, color: cta, size: 24),
               const Spacer(),
               Text(
                 "Success / Fail",
                 style: TextStyle(
                   fontFamily: "TTNormsPro",
                   fontSize: 16,
                   fontWeight: FontWeight.w600,
                   color: textColor.withValues(alpha: 0.7),
                 ),
               ),
               const Spacer(),
             ],
           ),
           const SizedBox(height: Spacing.xl),
           Center(
             child: SizedBox(
               height: 200,
               width: 200,
               child: Stack(
                 alignment: Alignment.center,
                 children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 65,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            color: textColor,
                            value: totalCompleted.toDouble(),
                            title: '',
                            radius: 35,
                          ),
                          PieChartSectionData(
                            color: textColor.withValues(alpha: 0.05),
                            value: missed.toDouble(),
                            title: '',
                            radius: 25,
                          ),
                        ]
                      )
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          totalCompleted.toString(),
                          style: const TextStyle(
                            fontFamily: "TTNormsPro",
                            fontSize: 36,
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                 ],
               ),
             ),
           ),
           const SizedBox(height: Spacing.md),
           Row(
             children: [
               Container(width: 12, height: 12, color: textColor),
               const SizedBox(width: 8),
               Text(
                 "Completed",
                 style: TextStyle(
                   fontFamily: "TTNormsPro",
                   fontSize: 14,
                   color: textColor.withValues(alpha: 0.8),
                 ),
               ),
               const SizedBox(width: 16),
               Container(width: 12, height: 12, color: textColor.withValues(alpha: 0.1)),
               const SizedBox(width: 8),
               Text(
                 "Incomplete periods",
                 style: TextStyle(
                   fontFamily: "TTNormsPro",
                   fontSize: 14,
                   color: textColor.withValues(alpha: 0.8),
                 ),
               ),
             ],
           )
        ],
      ),
    );
  }

  Widget _buildStreakChallengeSection() {
     final List<int> challengeWeeks = [1, 5, 15, 25, 50, 75];
     
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
            child: Row(
               children: [
                 const Icon(Icons.star_border_purple500, color: cta, size: 24),
                 const Spacer(),
                 Text(
                   "Streak challenge",
                   style: TextStyle(
                     fontFamily: "TTNormsPro",
                     fontSize: 16,
                     fontWeight: FontWeight.w600,
                     color: textColor.withValues(alpha: 0.7),
                   ),
                 ),
                 const Spacer(),
               ],
             ),
          ),
          const SizedBox(height: Spacing.xl),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: Spacing.xl),
                ...challengeWeeks.map((weeks) {
                  int daysReq = weeks * 7;
                  bool unlocked = highestStreakOverall >= daysReq;

                  return Padding(
                    padding: const EdgeInsets.only(right: Spacing.md),
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: unlocked ? textColor.withValues(alpha: 0.15) : textColor.withValues(alpha: 0.05),
                            border: unlocked ? Border.all(color: cta.withValues(alpha: 0.5), width: 2) : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                unlocked ? Icons.workspace_premium : Icons.lock, 
                                color: unlocked ? cta : textColor.withValues(alpha: 0.2),
                                size: 32,
                              ),
                              Positioned(
                                bottom: -2,
                                child: Container(
                                  width: 30,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: unlocked ? textColor.withValues(alpha: 0.15) : textColor.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          "$weeks week${weeks > 1 ? 's' : ''}",
                          style: TextStyle(
                            fontFamily: "TTNormsPro",
                            fontSize: 12,
                            color: unlocked ? textColor : textColor.withValues(alpha: 0.5),
                          ),
                        )
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(width: Spacing.md),
              ],
            ),
          ),
       ],
     );
  }
}
