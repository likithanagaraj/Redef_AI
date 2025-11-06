import 'package:flutter/material.dart';
import 'package:redef_ai_main/Theme.dart';

class UserStatsBento extends StatelessWidget {
  final int completedTasks;
  final int pendingTasks;
  final int pomodoroHours;
  final int pomodoroMinutes;
  final int habitsDone;
  final int totalHabits;
  final Function(int) onNavigateToTab; // Add this callback

  const UserStatsBento({
    super.key,
    required this.completedTasks,
    required this.pendingTasks,
    required this.pomodoroHours,
    required this.pomodoroMinutes,
    required this.habitsDone,
    required this.totalHabits,
    required this.onNavigateToTab, // Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const spacing = 5.0;
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column (2 smaller boxes)
              Flexible(
                flex: 42,
                child: Column(
                  children: [
                    // Tasks Card - Add GestureDetector
                    GestureDetector(
                      onTap: () => onNavigateToTab(4), // Navigate to Tasks tab (index 4)
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: screenWidth * 0.31,
                          width: double.infinity,
                          color: AppColors.white,
                          child: Stack(
                            children: [
                              Positioned(
                                right: -32,
                                bottom: -15,
                                child: Opacity(
                                  opacity: 0.9,
                                  child: Image.asset(
                                    'assets/images/todo_dashboard_image.png',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFC7E3C7).withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                          child: const Icon(
                                            Icons.calendar_month,
                                            size: 13,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Tasks',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
                                            letterSpacing: -0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  '$completedTasks',
                                                  style: TextStyle(
                                                    fontFamily: 'SourceSerif4',
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.0,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  'Completed',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black.withOpacity(0.5),
                                                    letterSpacing: -0.5,
                                                    height: 1.0,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 2,
                                          height: 35,
                                          margin: const EdgeInsets.symmetric(horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  '$pendingTasks',
                                                  style: TextStyle(
                                                    fontFamily: 'SourceSerif4',
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.0,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  'Pending',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black.withOpacity(0.5),
                                                    letterSpacing: -0.5,
                                                    height: 1.0,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: spacing),

                    // Deep Work Card - Add GestureDetector
                    GestureDetector(
                      onTap: () => onNavigateToTab(1), // Navigate to DeepWork tab (index 1)
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: screenWidth * 0.31,
                          width: double.infinity,
                          color: AppColors.white,
                          child: Stack(
                            children: [
                              Positioned(
                                right: -28,
                                bottom: -30,
                                child: Opacity(
                                  opacity: 0.9,
                                  child: Image.asset(
                                    'assets/images/Clock.png',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFC7E3C7).withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                          child: const Icon(
                                            Icons.hourglass_bottom,
                                            size: 13,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Deep Work',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            letterSpacing: -1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Focused Hours',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black.withOpacity(0.5),
                                                letterSpacing: -0.2,
                                                height: 1.0,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    if (pomodoroHours > 0) ...[
                                                      TextSpan(
                                                        text: '$pomodoroHours',
                                                        style: const TextStyle(
                                                          fontFamily: 'SourceSerif4',
                                                          fontSize: 28,
                                                          fontWeight: FontWeight.w700,
                                                          height: 1.0,
                                                          color: Colors.black,
                                                          letterSpacing: -0.5,
                                                        ),
                                                      ),
                                                      const TextSpan(
                                                        text: ' hr ',
                                                        style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.black87,
                                                          height: 1.0,
                                                        ),
                                                      ),
                                                    ],
                                                    TextSpan(
                                                      text: '$pomodoroMinutes',
                                                      style: TextStyle(
                                                        fontFamily: 'SourceSerif4',
                                                        fontSize: pomodoroHours > 0 ? 20 : 28,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.black,
                                                        height: 1.0,
                                                        letterSpacing: -0.3,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: ' min',
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.black87,
                                                        height: 1.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: spacing),

              // Habits Card (Right big box) - Add GestureDetector
              Flexible(
                flex: 47,
                child: GestureDetector(
                  onTap: () => onNavigateToTab(3), // Navigate to Habits tab (index 3)
                  child: Container(
                    height: screenWidth * 0.63,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC7E3C7).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  Icons.repeat,
                                  size: 14,
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Habits',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  letterSpacing: -0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Center(
                              child: totalHabits == 0
                                  ? Text(
                                'Your habits are on vacation — time to bring them back',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black.withOpacity(0.5),
                                  letterSpacing: 0,
                                  fontFamily: 'Inter',
                                ),
                              )
                                  : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$habitsDone / $totalHabits',
                                    style: TextStyle(
                                      fontFamily: 'SourceSerif4',
                                      fontSize: 36,
                                      fontWeight: FontWeight.w600,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Habits Completed Today',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: spacing),
        ],
      ),
    );
  }
}