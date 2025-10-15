import 'package:redef_ai_main/core/supabase_config.dart';

class PomodoroService {
  static Future<void> recordSession({
    required DateTime start,
    required DateTime end,
  }) async {
    final duration = end.difference(start);
    if (duration.inSeconds <= 0) return;

    final authUserId = SupabaseConfig.client.auth.currentUser?.id;
    if (authUserId == null) return;

    final userRow = await SupabaseConfig.client
        .from('users')
        .select('id')
        .eq('auth_user_id', authUserId)
        .maybeSingle();

    if (userRow == null) return;
    final internalUserId = userRow['id'];

    await SupabaseConfig.client.from('pomodoros').insert({
      'focus_time': duration.inSeconds,
      'session_completed_at': end.toIso8601String(),
      'user_id': internalUserId,
    });
  }
}
