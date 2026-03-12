import 'package:flutter/material.dart';
import 'package:redef_ai_main/screens/main_screen.dart';
import 'package:redef_ai_main/services/isar_service.dart';
import 'package:redef_ai_main/services/notification_service.dart';

import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await IsarService().openDB();
    await NotificationService().init();
    await NotificationService().reevaluateNotifications();
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
      home: const MainScreen(),

      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    ),
  );
}