import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants.dart';
import 'deepwork_screen.dart';
import 'habits_screen.dart';
import 'tasks_screen.dart';
import 'home_screen.dart';
import 'livekit_agent_screen.dart';
import '../services/widget_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetService.updateWidgetData();
  }

  void _navigate(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> get _screens => [
    HomeScreen(onNavigate: _navigate),
    const DeepworkScreen(),
    const LiveKitAgentScreen(),
    const HabitsScreen(),
    const TasksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 80,
          decoration: const BoxDecoration(
            color: scaffoldBg,
            border: Border(top: BorderSide(color: cardColor, width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, "Home", "home.svg", "filledHome.svg"),
              _buildNavItem(1, "Deepwork", "deepwork.svg", "filledDeepwork.svg"),
              _buildRedefItem(2),
              _buildNavItem(3, "Habits", "habits.svg", "filledHabit.svg"),
              _buildNavItem(4, "Tasks", "task.svg", "filledTask.svg"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String icon, String filledIcon) {
    bool isSelected = _currentIndex == index;
    String iconPath = "assets/icons/${isSelected ? filledIcon : icon}";

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: isSelected ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              colorFilter: isSelected
                  ? const ColorFilter.mode(cta, BlendMode.srcIn)
                  : const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontFamily: 'ndot',
              color: isSelected ? cta : Colors.grey,
              fontSize: 10,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Connected to AI Agent', style: TextStyle(fontSize: 24)),
          // Here you can add LiveKit components, like video or audio controls
        ],
      ),
    );
  }

  Widget _buildRedefItem(int index) {
    bool isSelected = _currentIndex == index;
    return Transform.translate(
      offset: const Offset(0, -10),
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: isSelected ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Image.asset(
              "assets/images/redef.png",
              width: 56,
              height: 56,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
