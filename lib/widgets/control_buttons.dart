import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deepwork_timer.dart';

class DeepworkControls extends StatelessWidget {
  const DeepworkControls({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<DeepworkTimer>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: timer.isRunning ? timer.pause : timer.start,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    timer.isRunning ? 'Pause' : 'Start',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    timer.isRunning ? Icons.pause : Icons.arrow_forward,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!timer.isWorkSession)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: timer.skipBreak,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Skip Break",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        if (timer.isPaused)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: timer.reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Reset",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
