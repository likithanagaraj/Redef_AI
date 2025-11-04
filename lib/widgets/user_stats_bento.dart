import 'package:flutter/material.dart';
import 'package:redef_ai_main/Theme.dart';
import 'package:redef_ai_main/screens/curve.dart';

class UserStatsBento extends StatelessWidget {
  final int completedTasks;
  final int pendingTasks;
  final int pomodoroHours;
  final int pomodoroMinutes;
  final int habitsDone;
  final int totalHabits;



  const UserStatsBento({
    super.key,
    required this.completedTasks,
    required this.pendingTasks,
    required this.pomodoroHours,
    required this.pomodoroMinutes,
    required this.habitsDone,
    required this.totalHabits,
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
                    // Tasks Card
                    ClipRRect(
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
                    const SizedBox(height: spacing),

                    // Deep Work Card
                    ClipRRect(
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
                                                        fontSize: 28, // Bigger font for hours
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
                                                      fontSize: pomodoroHours > 0 ? 20 : 28, // If only minutes, make it larger
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
                  ],
                ),
              ),

              const SizedBox(width: spacing),

              // Habits Card (Right big box)
              Flexible(
                flex: 47,
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
            ],
          ),

          const SizedBox(height: spacing),

          // Energy Curve Row
          // Row(
          //   children: [
          //     Expanded(
          //       child: Container(
          //         height: screenWidth * 0.5,
          //         width: double.infinity,
          //         decoration: BoxDecoration(
          //           color: AppColors.white,
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //         child: Padding(
          //           padding: const EdgeInsets.all(16.0),
          //           child: Column(
          //             mainAxisAlignment: MainAxisAlignment.start,
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Row(
          //                 crossAxisAlignment: CrossAxisAlignment.center,
          //                 children: [
          //                   Container(
          //                     padding: const EdgeInsets.all(6),
          //                     decoration: BoxDecoration(
          //                       color: const Color(0xFFC7E3C7).withOpacity(0.5),
          //                       borderRadius: BorderRadius.circular(50),
          //                     ),
          //                     child: const Icon(
          //                       Icons.battery_charging_full_outlined,
          //                       size: 20,
          //                       color: AppColors.black,
          //                     ),
          //                   ),
          //                   const SizedBox(width: 8),
          //                   const Text(
          //                     'Your Energy Curve',
          //                     style: TextStyle(
          //                       fontWeight: FontWeight.w500,
          //                       fontSize: 21,
          //                       letterSpacing: -0.8,
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //               const SizedBox(height: 12),
          //               Expanded(
          //                 child: Center(
          //                   child: EnergyCurve()
          //
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),

          const SizedBox(height: spacing),

          // Bottom Row - Quick Win & Facts
          // Row(
          //   children: [
          //     // Quick Win
          //     Expanded(
          //       child: Container(
          //         height: screenWidth * 0.22,
          //         decoration: BoxDecoration(
          //           color: AppColors.white,
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //         padding: const EdgeInsets.all(10),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             Row(
          //               children: [
          //                 Icon(
          //                   Icons.lightbulb_outline,
          //                   size: 16,
          //                   color: AppColors.black,
          //                 ),
          //                 const SizedBox(width: 4),
          //                 Flexible(
          //                   child: Text(
          //                     'Quick Win',
          //                     style: TextStyle(
          //                       fontWeight: FontWeight.w500,
          //                       fontSize: 16,
          //                       letterSpacing: -0.6,
          //                     ),
          //                     overflow: TextOverflow.ellipsis,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //             const SizedBox(height: 6),
          //             Row(
          //               children: [
          //                 Expanded(
          //                   child: Text(
          //                     pendingTasks > 0
          //                         ? 'Complete $pendingTasks pending task${pendingTasks > 1 ? 's' : ''}'
          //                         : 'All tasks completed! 🎉',
          //                     style: TextStyle(
          //                       fontFamily: 'Inter',
          //                       fontSize: 10,
          //                       letterSpacing: 0,
          //                       color: Colors.black.withOpacity(0.5),
          //                       fontWeight: FontWeight.w500,
          //                       height: 1.3,
          //                     ),
          //                     maxLines: 2,
          //                     overflow: TextOverflow.ellipsis,
          //                   ),
          //                 ),
          //                 const SizedBox(width: 8),
          //                 Icon(
          //                   Icons.arrow_forward_ios,
          //                   color: Colors.black.withOpacity(0.5),
          //                   size: 16,
          //                 )
          //               ],
          //             )
          //           ],
          //         ),
          //       ),
          //     ),
          //
          //     const SizedBox(width: spacing),
          //
          //     // Facts About You
          //     Expanded(
          //       child: Container(
          //         height: screenWidth * 0.22,
          //         decoration: BoxDecoration(
          //           color: AppColors.white,
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //         padding: const EdgeInsets.all(10),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             Row(
          //               children: [
          //                 Icon(
          //                   Icons.person_outline,
          //                   size: 16,
          //                   color: AppColors.black,
          //                 ),
          //                 const SizedBox(width: 4),
          //                 Flexible(
          //                   child: Text(
          //                     'Facts About You',
          //                     style: TextStyle(
          //                       fontWeight: FontWeight.w500,
          //                       fontSize: 16,
          //                       letterSpacing: -0.6,
          //                     ),
          //                     overflow: TextOverflow.ellipsis,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //             const SizedBox(height: 6),
          //             Text(
          //               'You\'re most productive between 9-11 AM',
          //               style: TextStyle(
          //                 fontFamily: 'Inter',
          //                 fontSize: 10,
          //                 letterSpacing: 0,
          //                 color: Colors.black.withOpacity(0.5),
          //                 height: 1.3,
          //                 fontWeight: FontWeight.w500,
          //               ),
          //               maxLines: 2,
          //               overflow: TextOverflow.ellipsis,
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}