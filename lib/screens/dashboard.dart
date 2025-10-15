import 'package:flutter/material.dart';
import '../core/supabase_config.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List tasks = [];
  List habits =[];
  List pomodoros = [];
  bool isLoading = true;
  int completedTasks = 0;
  int totalTasks = 0;
  double completionPercentage = 0.0;
  int pomodoroMinutes = 0;
  int habitsDone = 0;
  final user = SupabaseConfig.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    fetchTaskData();
    loadHabits();
    loadPomodoros();
  }

  Future<void> fetchTaskData() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user != null) {
      print('✅$user.id'); // auth_user_id
      print(user.email);
    }
    setState(() => isLoading = true);

    try {
      final response = await SupabaseConfig.client
          .from('tasks')
          .select('id, name, is_completed, category, completed_at')
          .order('created_at', ascending: false);

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
        .eq('auth_user_id', authUserId)
        .maybeSingle();

    if (userRow == null) return [];

    final internalUserId = userRow['id'];

    final response = await SupabaseConfig.client
        .from('pomodoros')
        .select()
        .eq('user_id', internalUserId)
        .order('session_completed_at', ascending: false); // latest first

    return List<Map<String, dynamic>>.from(response);
  }


  Future<List<Map<String, dynamic>>> fetchHabits() async {
    final authUserId = SupabaseConfig.client.auth.currentUser?.id;
    if (authUserId == null) return [];

    // get internal user id first
    final userRow = await SupabaseConfig.client
        .from('users')
        .select('id')
        .eq('auth_user_id', authUserId)
        .maybeSingle();

    if (userRow == null) return [];

    final internalUserId = userRow['id'];

    // fetch habits
    final response = await SupabaseConfig.client
        .from('habit')
        .select()
        .eq('user_id', internalUserId);

    return List<Map<String, dynamic>>.from(response);
  }

  void loadHabits() async {
    final authUserId = SupabaseConfig.client.auth.currentUser?.id;
    if (authUserId == null) return;

    // get internal user id
    final userRow = await SupabaseConfig.client
        .from('users')
        .select('id')
        .eq('auth_user_id', authUserId)
        .maybeSingle();

    if (userRow == null) return;

    final internalUserId = userRow['id'];

    // fetch habits
    final fetchedHabits = await SupabaseConfig.client
        .from('habit')
        .select()
        .eq('user_id', internalUserId);

    // fetch completed habit logs
    final completedLogs = await SupabaseConfig.client
        .from('habit_logs')
        .select('id, habit_id')
        .eq('user_id', internalUserId)
        .eq('status', true); // only completed logs

    setState(() {
      habits = List<Map<String, dynamic>>.from(fetchedHabits);
      habitsDone = (completedLogs as List).length; // count of completed logs
    });
  }


  void loadPomodoros() async {
    final fetchedPomodoros = await fetchPomodoros();
    int totalSeconds = 0;

    for (var session in fetchedPomodoros) {
      totalSeconds += session['focus_time'] as int; // focus_time in seconds
    }

    setState(() {
      pomodoros = fetchedPomodoros;
      pomodoroMinutes = (totalSeconds / 60).round(); // convert to minutes
    });
  }


  @override
  Widget build(BuildContext context) {
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
                            fontSize: 36,
                            fontFamily: 'SourceSerif4',
                            fontWeight: FontWeight.w400,
                            letterSpacing: -2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '👋',
                          style: TextStyle(fontSize: 32),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Progress Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Progress Now',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'SourceSerif4',
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Progress Bar
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: totalTasks > 0
                                        ? completedTasks / totalTasks
                                        : 0.0,
                                    minHeight: 12,
                                    backgroundColor:
                                    Colors.grey.shade300,
                                    valueColor:
                                    const AlwaysStoppedAnimation<
                                        Color>(
                                      Color(0xFF014E3C),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Progress Stats
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$completedTasks/$totalTasks Tasks Completed',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              Text(
                                '${completionPercentage.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF014E3C),
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Pomodoro Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF014E3C)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.timer,
                              color: Color(0xFF014E3C),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pomodoro Time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$pomodoroMinutes minutes',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'SourceSerif4',
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF014E3C),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Text(
                          //   '🍅',
                          //   style: TextStyle(fontSize: 28),
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Habits Done Card
                    // Container(
                    //   padding: const EdgeInsets.all(12),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(8),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.grey.withOpacity(0.08),
                    //         blurRadius: 12,
                    //         offset: const Offset(0, 4),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       Container(
                    //         padding: const EdgeInsets.all(12),
                    //         decoration: BoxDecoration(
                    //           color: const Color(0xFF014E3C)
                    //               .withOpacity(0.1),
                    //           borderRadius: BorderRadius.circular(8),
                    //         ),
                    //         child: const Icon(
                    //           Icons.favorite,
                    //           color: Color(0xFF014E3C),
                    //           size: 24,
                    //         ),
                    //       ),
                    //       const SizedBox(width: 16),
                    //       Expanded(
                    //         child: Column(
                    //           crossAxisAlignment:
                    //           CrossAxisAlignment.start,
                    //           children: [
                    //             const Text(
                    //               'Habits Completed',
                    //               style: TextStyle(
                    //                 fontSize: 14,
                    //                 fontWeight: FontWeight.w500,
                    //                 color: Colors.grey,
                    //                 letterSpacing: -0.2,
                    //               ),
                    //             ),
                    //             const SizedBox(height: 4),
                    //             Text(
                    //               '$habitsDone habits',
                    //               style: const TextStyle(
                    //                 fontSize: 22,
                    //                 fontFamily: 'SourceSerif4',
                    //                 fontWeight: FontWeight.w600,
                    //                 color: Color(0xFF014E3C),
                    //                 letterSpacing: -0.3,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       // Text(
                    //       //   '⭐',
                    //       //   style: TextStyle(fontSize: 28),
                    //       // ),
                    //     ],
                    //   ),
                    // ),
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