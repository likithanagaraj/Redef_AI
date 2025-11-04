import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redef_ai_main/Theme.dart';
import 'package:redef_ai_main/providers/deepwork_timer.dart';
import 'package:redef_ai_main/utilis.dart';
import 'package:redef_ai_main/widgets/FullScreenTimerPage.dart';
import 'package:redef_ai_main/widgets/TodaysLog.dart';
import 'package:redef_ai_main/widgets/control_buttons.dart';
import 'package:redef_ai_main/widgets/timer_circle.dart';


class DeepworkScreen extends StatelessWidget {
  const DeepworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.white,
          title: _TopBar(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // This makes the content scrollable when keyboard appears
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // const SizedBox(height: 4),
                  const TodaysLog(),
                  const SizedBox(height: 40,),
                  Column(
                    children: [
                      const TimerCircle(),
                      const SizedBox(height: 25,),
                      const DeepworkControls(),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final timer = Provider.of<DeepworkTimer>(context, listen: false);

    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.hourglass_bottom, color: AppColors.secondary, size: 28),
            const SizedBox(width: 4),
            Text(
              'Deep Work',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
                letterSpacing: -1.1,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Transform.translate(
              offset: const Offset(12, 0),
              child: IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) {
                      final timer = context.watch<DeepworkTimer>();
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Select a music',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...availableMusics.map((music) {
                            return RadioListTile<String>(
                              title: Text(music.name),
                              value: music.assetPath,
                              groupValue: timer.selectedMusic,
                              onChanged: (value) {
                                timer.selectMusic(value ?? '');
                                Navigator.pop(context);
                              },
                            );
                          }),
                        ],
                      );
                    },
                  );

                },
                icon: Icon(Icons.music_note_rounded,
                    color: AppColors.secondary, size: 27),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const Fullscreentimerpage()),
                );
              },
              icon: Icon(Icons.fullscreen,
                  color: AppColors.secondary, size: 28),
            ),
          ],
        )
      ],
    );
  }
}