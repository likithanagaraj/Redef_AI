// FullScreenTimerPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redef_ai_main/providers/deepwork_timer.dart';
class Fullscreentimerpage extends StatefulWidget {
  const Fullscreentimerpage({super.key});

  @override
  State<Fullscreentimerpage> createState() => _FullscreentimerpageState();
}

class _FullscreentimerpageState extends State<Fullscreentimerpage> {
  @override
  Widget build(BuildContext context) {
    final timer = context.watch<DeepworkTimer>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: RotatedBox(
          quarterTurns: -1, // makes text horizontal
          child: Text(
            timer.formatTime(timer.remainingSeconds),
            style: const TextStyle(
              color: Color(0xffFDFBF9),
              fontSize: 240,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
