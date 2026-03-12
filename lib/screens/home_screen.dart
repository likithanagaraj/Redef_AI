import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:isar/isar.dart';
import '../design_tokens.dart';
import '../models/task.dart';
import '../models/habit.dart';
import '../models/session.dart';
import '../screens/habits_screen.dart'; // To reuse HabitLogic extension
import '../screens/notification_settings_screen.dart';
import '../constants.dart';
import '../widgets/dashed_border.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const HomeScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _quotes = [
    "\"If your dreams don't scare you, they're too small.\"",
    "\"Focus is the new IQ. Distraction is the enemy of progress.\"",
    "\"The secret of getting ahead is getting started.\"",
    "\"What you do today can improve all your tomorrows.\"",
    "\"Amateurs sit and wait for inspiration, the rest of us just get up and go to work.\"",
    "\"Don't watch the clock; do what it does. Keep going.\"",
    "\"You don't have to see the whole staircase, just take the first step.\"",
    "\"Productivity is never an accident. It is always the result of a commitment to excellence.\"",
    "\"Strive not to be a success, but rather to be of value.\"",
    "\"Great acts are made up of small deeds.\"",
    "\"The only way to do great work is to love what you do.\"",
    "\"Success is the sum of small efforts, repeated day in and day out.\"",
    "\"Your future is created by what you do today, not tomorrow.\"",
    "\"Believe you can and you're halfway there.\"",
  ];

  int _currentQuoteIndex = 0;
  Timer? _quoteTimer;

  String _totalHours = "0";
  String _maxStreak = "0";
  String _pendingTasks = "0";

  @override
  void initState() {
    super.initState();
    _loadStats();
    _quoteTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (mounted) {
        setState(() {
          _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
        });
      }
    });
  }

  Future<void> _loadStats() async {
    final isar = Isar.getInstance();
    if (isar == null) return;

    // Calculate total deepwork hours
    final sessions = await isar.deepworkSessions.where().findAll();
    int totalMinutes = 0;
    for (var s in sessions) {
      totalMinutes += s.durationInMinutes;
    }
    double totalHrs = totalMinutes / 60.0;

    // Calculate highest streak across all habits
    final habits = await isar.habits.where().findAll();
    int highestStreak = 0;
    final today = DateTime.now();
    for (var h in habits) {
      int s = h.calculateStreak(today);
      if (s > highestStreak) {
        highestStreak = s;
      }
    }

    // Pending tasks
    final tasks = await isar.tasks.where().findAll();
    int pending = tasks.where((t) => !t.isCompleted).length;

    if (mounted) {
      setState(() {
        _totalHours = totalHrs.toString();
        _maxStreak = highestStreak.toString();
        _pendingTasks = pending.toString();
      });
    }
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Attempt to refresh stats silently when rebuilding.
    _loadStats();
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text("WELCOME", style: kTitleStyle),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          "assets/icons/home-smile.svg",
                          width: IconSize.lg,
                          height: IconSize.lg,
                          colorFilter: const ColorFilter.mode(
                            textColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_active_outlined, color: textColor),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (context) => const NotificationSettingsScreen(),
                          ),
                        ).then((_) => _loadStats());
                      },
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xxl),

                // Quote Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _quotes[_currentQuoteIndex],
                      key: ValueKey<int>(_currentQuoteIndex),
                      textAlign: TextAlign.center,
                      style: kBodyStyle.copyWith(height: 1.5, fontSize: TypographySize.quote),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),

                // Grid (Row of 3 elements)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onNavigate(1), // 14 hrs -> Deepwork
                        child: Container(
                          height: ContainerSize.statCardHeight,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  width: ContainerSize.iconContainer,
                                  height: ContainerSize.iconContainer,
                                  decoration: const BoxDecoration(
                                    color: scaffoldBg,
                                    borderRadius: BorderRadiusGeometry.all(
                                      Radius.circular(AppRadius.card),
                                    ),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      "assets/icons/solid-clock.svg",
                                      width: IconSize.md,
                                      height: IconSize.md,
                                      colorFilter: const ColorFilter.mode(
                                        textColor,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Builder(
                                    builder: (context) {
                                      final double? hrs = double.tryParse(
                                        _totalHours,
                                      );
                                      String numStr = _totalHours;
                                      String unit = "hrs";
                                      if (hrs != null) {
                                        if (hrs == 0) {
                                          numStr = "0";
                                        } else if (hrs < 1) {
                                          numStr = (hrs * 60)
                                              .round()
                                              .toString();
                                          unit = "min";
                                        } else {
                                          int hrsInt = hrs.truncate();
                                          if (hrsInt > 999) {
                                            numStr = "999+";
                                          } else {
                                            numStr = hrsInt.toString();
                                          }
                                        }
                                      }
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(numStr, style: kTitleStyle),
                                          const SizedBox(width: Spacing.xs),
                                          Flexible(
                                            child: Text(
                                              unit,
                                              style: kCaptionStyle.copyWith(
                                                color: textColor.withValues(
                                                  alpha: 0.5,
                                                ),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            widget.onNavigate(3), // 18 streak -> Habits
                        child: Container(
                          height: ContainerSize.statCardHeight,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  width: ContainerSize.iconContainer,
                                  height: ContainerSize.iconContainer,
                                  decoration: const BoxDecoration(
                                    color: scaffoldBg,
                                    borderRadius: BorderRadiusGeometry.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      "assets/icons/whiteStreaks.svg",
                                      width: IconSize.md,
                                      height: IconSize.md,
                                      colorFilter: const ColorFilter.mode(
                                        textColor,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        _maxStreak,
                                        style: const TextStyle(
                                          fontFamily: "ndot",
                                          fontSize: TypographySize.statNumber,
                                          height: 1.0,
                                          color: textColor,
                                        ),
                                      ),
                                      Flexible(
                                        // safely handle text flex without crashing
                                        child: Text(
                                          "streak",
                                          style: TextStyle(
                                            fontFamily: "TTNormsPro",
                                            fontSize: TypographySize.label,
                                            color: textColor.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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

                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            widget.onNavigate(4), // 24 pending -> Tasks
                        child: Container(
                          height: ContainerSize.statCardHeight,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  width: ContainerSize.iconContainer,
                                  height: ContainerSize.iconContainer,
                                  decoration: const BoxDecoration(
                                    color: scaffoldBg,
                                    borderRadius: BorderRadiusGeometry.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      "assets/icons/solid-task.svg",
                                      width: IconSize.md,
                                      height: IconSize.md,
                                      colorFilter: const ColorFilter.mode(
                                        textColor,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        _pendingTasks,
                                        style: const TextStyle(
                                          fontFamily: "ndot",
                                          fontSize: TypographySize.statNumber,
                                          height: 1.0,
                                          color: textColor,
                                        ),
                                      ),

                                      Flexible(
                                        child: Text(
                                          "pending",
                                          style: TextStyle(
                                            fontFamily: "TTNormsPro",
                                            fontSize: TypographySize.label,
                                            color: textColor.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                const SizedBox(height: Spacing.xl),

                // Just Say It Card
                Container(
                  width: double.infinity,
                  height: ContainerSize.aiCardHeight,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -40,
                        top: -20,
                        child: DashedBorder(
                          color: textColor.withValues(alpha: 0.2),
                          isCircle: true,
                          dashWidth: 4,
                          dashSpace: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Opacity(
                              opacity: 0.8,
                              child: Image.asset(
                                "assets/images/redef.png",
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Just Say It",
                              style: TextStyle(
                                fontFamily: "TTNormsPro",
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: Spacing.sm),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.55,
                              child: Text(
                                "Too lazy to type? Same.\nTell your AI to add tasks, habits, or plans it remembers everything.",
                                style: TextStyle(
                                  fontFamily: "TTNormsPro",
                                  fontSize: 12,
                                  color: textColor.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => widget.onNavigate(
                                2,
                              ), // Index 2 is Redef AI tab
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: cta,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.card,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Talk Now",
                                      style: TextStyle(
                                        fontFamily: "ndot",
                                        fontSize: TypographySize.button,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SvgPicture.asset(
                                      "assets/icons/home-mic.svg",
                                      width: 16,
                                      height: 16,
                                      colorFilter: const ColorFilter.mode(
                                        textColor,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
