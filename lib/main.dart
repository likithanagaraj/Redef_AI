import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:redef_ai_main/screens/main_screen.dart';
import 'package:redef_ai_main/screens/onboarding_screen.dart';
import 'package:redef_ai_main/services/isar_service.dart';
import 'package:redef_ai_main/services/notification_service.dart';
import 'package:redef_ai_main/services/sync_manager.dart';
import 'package:redef_ai_main/services/sync_service.dart';
import 'package:redef_ai_main/services/widget_service.dart';

import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: kSupabaseUrl,
    anonKey: kSupabaseAnonKey,
  );

  bool isOnboarded = false;
  try {
    final isarService = IsarService();
    await isarService.openDB();
    
    // Identity Setup (Anonymous Auth)
    await SyncService().setupAnonymousIdentity();
    
    // Initial Data Reconciliation (Push & Pull)
    await SyncManager().reconcile();
    
    final user = await isarService.getUser();
    isOnboarded = user?.isOnboarded ?? false;
    
    await NotificationService().init();
    await NotificationService().reevaluateNotifications();
    await WidgetService.updateWidgetData();
  } catch (e) {
    debugPrint("Failed to initialize core services: $e");
  }

  runApp(
    MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: scaffoldBg,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: cta,
          selectionColor: cta.withValues(alpha: 0.3),
          selectionHandleColor: cta,
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'Redef.ai',
      home: isOnboarded ? const MainScreen() : const OnboardingScreen(),

      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    ),
  );
}
