import 'package:redef_ai_main/core/supabase_config.dart';

class PomodoroService {

  static Future<void> recordSession({
    required DateTime start,
    required DateTime end,
    String? project,
    required int focusTimeMinutes, // <-- ADD THIS PARAMETER
  }) async {
    if (focusTimeMinutes <= 0) return;

    final authUserId = SupabaseConfig.client.auth.currentUser?.id;
    if (authUserId == null) return;

    final userRow = await SupabaseConfig.client
        .from('users')
        .select('id')
        .eq('id', authUserId)
        .maybeSingle();

    if (userRow == null) return;

    await SupabaseConfig.client.from('pomodoros').insert({
      'focus_time': focusTimeMinutes, // use selected time directly
      'session_completed_at': end.toUtc().toIso8601String(),
      'user_id': userRow['id'],
      'project': project,
    });
  }
}

