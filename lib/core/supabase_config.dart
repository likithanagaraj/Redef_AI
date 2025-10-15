import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> init() async {
    // Load .env
    await dotenv.load(fileName: ".env");

    final url = dotenv.env['SUPABASE_URL'];
    final key = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || key == null) {
      throw Exception("Supabase URL or ANON KEY is missing");
    }

    await Supabase.initialize(
      url: url,
      anonKey: key,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
