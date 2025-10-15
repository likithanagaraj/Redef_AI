import 'package:flutter/material.dart';
import 'package:redef_ai_main/widgets/control_buttons.dart';
import 'package:redef_ai_main/widgets/timer_circle.dart';


class DeepworkScreen extends StatelessWidget {
  const DeepworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            const Spacer(),
            const TimerCircle(),
            const Spacer(),
            const DeepworkControls(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Icon(Icons.hourglass_bottom, color: Colors.green.shade700, size: 28),
          const SizedBox(width: 4),
          Text(
            'Deep Work',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}
