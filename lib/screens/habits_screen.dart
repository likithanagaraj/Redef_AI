import 'package:flutter/material.dart';
import 'package:redef_ai_main/Theme.dart';
import '../core/supabase_config.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  List habits = [];
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchData();

    SupabaseConfig.client
        .from('habit_logs')
        .stream(primaryKey: ['id'])
        .listen((_) => fetchData());
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    try {
      // 1️⃣ Fetch all habits
      final habitsResponse = await SupabaseConfig.client
          .from('habit')
          .select('id, name, description, type')
          .order('created_at', ascending: false);

      // 2️⃣ Fetch logs for the selected date
      final formattedDate = selectedDate.toIso8601String().split('T').first;
      final logsResponse = await SupabaseConfig.client
          .from('habit_logs')
          .select('habit_id, status')
          .eq('date', formattedDate);
      print(logsResponse);
      print('🥇🥇$habitsResponse');
      // 3️⃣ Merge them safely
      final List<Map<String, dynamic>> combined = [];

      for (final habit in habitsResponse) {
        // Find log matching this habit
        final log = logsResponse.cast<Map<String, dynamic>>().firstWhere(
              (l) => l['habit_id'] == habit['id'],
          orElse: () => <String, dynamic>{}, // return empty map instead of null
        );

        final merged = {
          ...habit,
          'status': log['status'] ?? false, // default false if not found
        };

        combined.add(merged);
      }

      setState(() {
        habits = combined;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching habits: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> toggleHabitCompletion(String habitId, bool isDone) async {
    final date = selectedDate.toIso8601String().split('T').first;

    // Update locally for instant UI response
    setState(() {
      habits = habits.map((h) {
        if (h['id'] == habitId) {
          h['status'] = !isDone;
        }
        return h;
      }).toList();
    });

    try {
      // Check if a log already exists
      final existing = await SupabaseConfig.client
          .from('habit_logs')
          .select()
          .eq('habit_id', habitId)
          .eq('date', date)
          .maybeSingle();
      final authUserId = SupabaseConfig.client.auth.currentUser?.id;

      if (authUserId == null) {
        // user is not logged in
        return;
      }
      if (existing == null || existing.isEmpty) {

        await SupabaseConfig.client.from('habit_logs').insert({
          'habit_id': habitId,
          'date': date,
          'status': true,
          'user_id': authUserId, // must include RLS user_id
        });
      } else {
        // Update to the exact value we want
        await SupabaseConfig.client
            .from('habit_logs')
            .update({'status': !isDone})
            .eq('id', existing['id']);
      }
    } catch (e) {
      print('Error updating habit log: $e');
    }
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    final difference = dateToCheck.difference(today).inDays;
    return '${date.day}';
  }

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

  void addHabitDialog() {
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Habit',
                      style: TextStyle(
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
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Habit name',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter habit name'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      try {
                        final authUserId = SupabaseConfig.client.auth.currentUser?.id;

                        if (authUserId == null) {
                          // user is not logged in
                          return;
                        }
                        await SupabaseConfig.client.from('habit').insert({
                          'name': nameController.text.trim(),
                          'user_id': authUserId,
                        });

                        Navigator.pop(context);
                        fetchData();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Habit added successfully'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        print('Error adding habit: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Add Habit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeHabits = habits.where((h) => !(h['status'] ?? false)).toList();
    final completedHabits = habits.where((h) => h['status'] ?? false).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.repeat_outlined,
                    size: 28,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Habits',
                    style: TextStyle(
                      fontSize: 30,
                      color: Color(0xFF014E3C),
                      fontFamily: 'SourceSerif4',
                      fontWeight: FontWeight.w500,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal date selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
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

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = date;
                          });
                          fetchData(); // refresh for new date
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: 55,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.secondary : Colors.white,
                                border: Border.all(color: AppColors.secondary, width: 1.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _getDayLabel(date),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontFamily: 'Inter',
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    _getDateLabel(date),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isToday && !isSelected)
                              Positioned(
                                bottom: 2,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Split habits
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF014E3C)),
              )
                  : habits.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.repeat_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No habits yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add a new habit',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: habits.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  return Container(
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          activeColor: Colors.grey.shade400,
                          value: habit['status'],
                          onChanged: (_) => toggleHabitCompletion(
                            habit['id'],
                            habit['status'],
                          ),
                          side: const BorderSide(color: Colors.black, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            habit['name'] ?? 'No Name',
                            style: TextStyle(
                              fontSize: 16,
                              color: habit['status']
                                  ? Colors.grey.shade500
                                  : Colors.black,
                              decoration: habit['status']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),


            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addHabitDialog,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}