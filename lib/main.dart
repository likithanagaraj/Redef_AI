// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redef_ai_main/Theme.dart';
import 'package:redef_ai_main/core/supabase_config.dart';
import 'package:redef_ai_main/providers/deepwork_timer.dart';
import 'package:redef_ai_main/providers/habit_provider.dart';
import 'package:redef_ai_main/providers/tasks_provider.dart';
import 'package:redef_ai_main/services/habit_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<HabitService>(create: (_) => HabitService()),
        ChangeNotifierProxyProvider<HabitService, HabitProvider>(
          create: (context) => HabitProvider(
            habitService: context.read<HabitService>(),
          )..initialize(), // ← Initialize immediately on app start
          update: (context, habitService, previous) =>
          previous ?? HabitProvider(habitService: habitService)..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => DeepworkTimer()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Redef.ai',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: AppFonts.primaryFont,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            textStyle: AppFonts.button,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}