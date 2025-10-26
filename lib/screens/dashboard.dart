// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redef_ai_main/Theme.dart';
import 'package:redef_ai_main/widgets/quote_carousel.dart';
import 'package:redef_ai_main/widgets/user_stats_bento.dart';
import '../core/supabase_config.dart';
import '../providers/habit_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List tasks = [];
  List pomodoros = [];
  bool isLoading = true;
  int completedTasks = 0;
  int totalTasks = 0;
  double completionPercentage = 0.0;
  int pomodoroMinutes = 0;
  final user = SupabaseConfig.client.auth.currentUser;

  @override
  void initState() {
    super.initState();

    // Wrap async calls to prevent setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchTaskData();
      loadPomodoros();
    });
  }

  Future<void> fetchTaskData() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user != null) {
      print('✅${user.id}'); // auth_user_id
      print(user.email);
    }
    setState(() => isLoading = true);

    try {
      final response = await SupabaseConfig.client
          .from('tasks')
          .select('id, name, is_completed, category, completed_at')
          .order('created_at', ascending: false);
      print('✅ Fetched tasks count: ${response.length}');
      print('✅ Fetched tasks : $response');

      setState(() {
        tasks = response;
        totalTasks = tasks.length;
        completedTasks =
            tasks.where((task) => task['is_completed'] == true).length;
        completionPercentage = totalTasks > 0
            ? (completedTasks / totalTasks * 100).roundToDouble()
            : 0.0;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching tasks: $e');
      setState(() => isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> fetchPomodoros() async {
    final authUserId = SupabaseConfig.client.auth.currentUser?.id;
    if (authUserId == null) return [];

    final userRow = await SupabaseConfig.client
        .from('users')
        .select('id')
        .eq('id', authUserId)
        .maybeSingle();

    if (userRow == null) return [];

    final internalUserId = userRow['id'];

    final response = await SupabaseConfig.client
        .from('pomodoros')
        .select()
        .eq('user_id', internalUserId)
        .order('session_completed_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  void loadPomodoros() async {
    final fetchedPomodoros = await fetchPomodoros();
    int totalSeconds = 0;

    for (var session in fetchedPomodoros) {
      totalSeconds += session['focus_time'] as int;
    }

    setState(() {
      pomodoros = fetchedPomodoros;
      pomodoroMinutes = (totalSeconds / 60).round();
    });
  }

  @override
  Widget build(BuildContext context) {
    int hours = pomodoroMinutes ~/ 60;
    int minutes = pomodoroMinutes % 60;

    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF014E3C)),
        )
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Welcome',
                          style: TextStyle(
                            fontSize: 34,
                            fontFamily: 'SourceSerif4',
                            fontWeight: FontWeight.w400,
                            letterSpacing: -2,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.waving_hand_outlined,
                          color: AppColors.black,
                          size: 30,
                        )
                      ],
                    ),
                    const SizedBox(height: 32),
                    QuoteCarousel(),
                    const SizedBox(height: 5),

                    // Use Consumer to get real-time habit stats
                    Consumer<HabitProvider>(
                      builder: (context, habitProvider, _) {
                        return UserStatsBento(
                          completedTasks: completedTasks,
                          pendingTasks: totalTasks - completedTasks,
                          pomodoroHours: hours,
                          pomodoroMinutes: minutes,
                          habitsDone: habitProvider.todayCompletedHabits,
                          totalHabits: habitProvider.todayTotalHabits,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}