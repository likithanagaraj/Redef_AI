import 'package:flutter/material.dart';
import 'package:redef_ai_main/Theme.dart';
import 'package:redef_ai_main/screens/dashboard.dart';
import 'package:redef_ai_main/screens/redef_Ai.dart';
import 'tasks_screen.dart';
import 'habits_screen.dart';
import 'deepwork_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Callback function to handle navigation from child widgets
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // Build the screens list with navigation callback
  List<Widget> get _screens => [
    DashboardScreen(onNavigateToTab: _onItemTapped),
    DeepworkScreen(),
    const RedefScreen(),
    const HabitsScreen(),
    const TasksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Bottom Navigation Items
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
                  _buildNavItem(1, Icons.timer_outlined, Icons.timer_rounded, 'DeepWork'),
                  const SizedBox(width: 72), // Space for elevated button
                  _buildNavItem(3, Icons.repeat_outlined, Icons.repeat_rounded, 'Habits'),
                  _buildNavItem(4, Icons.task_alt_outlined, Icons.task_alt_rounded, 'Tasks'),
                ],
              ),
            ),
            // Elevated Redef AI Button
            Positioned(
              top: -20,
              left: MediaQuery.of(context).size.width / 2 - 35,
              child: GestureDetector(
                onTap: () => _onItemTapped(2),
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.secondary.withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      _selectedIndex == 2
                          ? Icons.keyboard_voice_rounded
                          : Icons.keyboard_voice_outlined,
                      color: AppColors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        splashColor: AppColors.secondary.withOpacity(0.1),
        highlightColor: AppColors.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? AppColors.secondary : Colors.grey.shade600,
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.secondary : Colors.grey.shade600,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  letterSpacing: -0.1,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}