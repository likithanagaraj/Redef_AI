import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:redef_ai_main/Theme.dart';
import 'package:redef_ai_main/widgets/AddProject.dart';
import '../../providers/deepwork_timer.dart';

class TimerCircle extends StatelessWidget {
  const TimerCircle({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<DeepworkTimer>();

    return Stack(
      alignment: Alignment.center,
      children: [
        // Circular Progress
        SizedBox(
          width: 300,
          height: 300,
          child: CircularProgressIndicator(
            value: timer.progress,
            strokeWidth: 8,
            backgroundColor: const Color(0xffD3D3D3),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),

        // Timer text + Project name inside circle
        Container(
          constraints: const BoxConstraints(
            maxWidth: 260, // Constrain to fit inside 300px circle
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AddProject(),

              // 👇 Tap to open scrollable time picker
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  showTimerAdjustOverlay(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    timer.formatTime(timer.remainingSeconds),
                    style:  TextStyle(
                      fontSize: timer.remainingSeconds >= 3600 ? 78 : 90,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -2,
                    ),
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void showTimerAdjustOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const TimerAdjustOverlay(),
    );
  }
}

class TimerAdjustOverlay extends StatefulWidget {
  const TimerAdjustOverlay({super.key});

  @override
  State<TimerAdjustOverlay> createState() => _TimerAdjustOverlayState();
}

class _TimerAdjustOverlayState extends State<TimerAdjustOverlay> {
  late FixedExtentScrollController _scrollController;
  int _selectedMinutes = 25;

  final List<int> _timeOptions = List.generate(120, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    final timer = context.read<DeepworkTimer>();
    _selectedMinutes = (timer.remainingSeconds / 60).round();

    final initialIndex = _timeOptions.indexOf(_selectedMinutes);
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping inside
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Scroll to Adjust Timer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                      fontFamily: 'Inter',
                      letterSpacing: -0.3
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ✅ FixedExtentScrollView (snapping + centered item)
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: _scrollController,
                      itemExtent: 80,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedMinutes = _timeOptions[index];
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          final minutes = _timeOptions[index];
                          final isSelected = minutes == _selectedMinutes;

                          return AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 150),
                            style: TextStyle(
                              fontFamily: 'SourceSerif4',
                              fontSize: isSelected ? 56 : 44,
                              fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w300,
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.black.withOpacity(0.2),
                              letterSpacing: -2,
                            ),
                            child: Text('${minutes.toString().padLeft(2, '0')}:00'),
                          );
                        },
                        childCount: _timeOptions.length,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: ElevatedButton(
                      onPressed: () {
                        final timer = context.read<DeepworkTimer>();
                        final newSeconds = _selectedMinutes * 60;

                        timer.totalSeconds = newSeconds;
                        timer.remainingSeconds = newSeconds;
                        timer.notifyListeners();

                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Set Timer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter'
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}