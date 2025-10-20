import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deepwork_timer.dart';

class TimerCircle extends StatelessWidget {
  const TimerCircle({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<DeepworkTimer>();

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: CircularProgressIndicator(
            value: timer.progress,
            strokeWidth: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timer.formatTime(timer.remainingSeconds),
              style: const TextStyle(
                fontSize: 78,
                fontWeight: FontWeight.w300,
                letterSpacing: -2,
              ),
            ),
            const SizedBox(height: 10),
            if(!timer.isRunning && !timer.isPaused)  _TimeAdjustmentControls(),
            const SizedBox(height: 10),
            Text(
              'Session: ${timer.completedWorkSessions % 4}/4',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimeAdjustmentControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final timer = context.watch<DeepworkTimer>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: timer.isRunning ? null : timer.decreaseTime,
          icon: Icon(
            Icons.remove_circle_outline,
            size: 32,
            color: timer.isRunning
                ? Colors.grey.shade400
                : Colors.green.shade700,
          ),
        ),
        const SizedBox(width: 40),
        IconButton(
          onPressed: timer.isRunning ? null : timer.increaseTime,
          icon: Icon(
            Icons.add_circle_outline,
            size: 32,
            color: timer.isRunning
                ? Colors.grey.shade400
                : Colors.green.shade700,
          ),
        ),
      ],
    );
  }
}
