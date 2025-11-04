import 'package:flutter/material.dart';
import 'package:redef_ai_main/Helper_function/time_helper.dart';
import 'package:redef_ai_main/core/supabase_config.dart';
import 'package:redef_ai_main/Theme.dart';

class TodaysLog extends StatefulWidget {
  const TodaysLog({super.key});

  @override
  State<TodaysLog> createState() => _TodaysLogState();
}

class _TodaysLogState extends State<TodaysLog> {
  int totalMinutesToday  = 0;
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadTodaysPomodoros();
  }

  Future<void> _loadTodaysPomodoros() async {
    try {
      final pomodoros = await fetchPomodoros();

      int total = 0;
      for (var session in pomodoros) {
        total += (session['focus_time'] as int);
      }

      setState(() {
        totalMinutesToday = total;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching pomodoros: $e');
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

    final range = TimeHelper.utcRangeForLocalToday();

    final response = await SupabaseConfig.client
        .from('pomodoros')
        .select()
        .eq('user_id', userRow['id'])
        .gte('session_completed_at', range['startUtc']!)
        .lt('session_completed_at', range['endUtc']!)
        .order('session_completed_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }


  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0 && remainingMinutes > 0) {
      return '${hours}hr ${remainingMinutes}min';
    } else if (hours > 0) {
      return '${hours} hr';
    } else {
      return '${remainingMinutes} min';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Todays Work Session',
              style: TextStyle(
                fontFamily: 'SourceSerif4',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.5,
              ),
            ),
            isLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.secondary,
              ),
            )
                : Text(
              _formatDuration(totalMinutesToday),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -1,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}