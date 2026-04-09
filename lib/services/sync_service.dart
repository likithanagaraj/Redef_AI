import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:redef_ai_main/services/isar_service.dart';
import '../models/user.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Ensures the user is signed in to Supabase anonymously and 
  /// links the Supabase UID to the local Isar user profile.
  Future<void> setupAnonymousIdentity() async {
    final isarService = IsarService();
    final localUser = await isarService.getUser();

    if (localUser == null) return;

    // Ensure the Supabase session is active (even if we already have a UID locally)
    final currentSession = _supabase.auth.currentSession;
    String? supabaseUid;


    if (currentSession != null) {
      supabaseUid = currentSession.user.id;
    } else {
      // 3. Trigger Anonymous Sign-in
      try {
        final response = await _supabase.auth.signInAnonymously();
        supabaseUid = response.user?.id;
      } catch (e) {
        print("Error signing in anonymously: $e");
        return;
      }
    }

    // 4. Update the local Isar user with the Supabase UID
    if (supabaseUid != null) {
      final isar = await isarService.db;
      await isar.writeTxn(() async {
        localUser.supabaseId = supabaseUid;
        await isar.users.put(localUser);
      });
      print("Anonymous identity established: $supabaseUid");
    }
  }

  /// Helper to get the current Supabase User ID
  String? get currentUid => _supabase.auth.currentUser?.id;
}
