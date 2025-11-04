import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redef_ai_main/Theme.dart';
import '../../providers/deepwork_timer.dart';

class DeepworkControls extends StatelessWidget {
  const DeepworkControls({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<DeepworkTimer>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Start / Pause button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: timer.isRunning ? timer.pause : timer.start,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    timer.isRunning ? 'Pause Session' : 'Start Session',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    timer.isRunning ? Icons.pause : Icons.play_arrow,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Skip Break button
          if (!timer.isWorkSession)
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: timer.skipBreak,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Skip ",
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),

          if (!timer.isWorkSession) const SizedBox(width: 12),

          // Reset button
          if (timer.isPaused)
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: timer.reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Reset ",
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
