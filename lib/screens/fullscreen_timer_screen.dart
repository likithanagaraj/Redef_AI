import 'dart:async';
import 'package:flutter/material.dart';
import '../constants.dart';

class FullscreenTimerScreen extends StatefulWidget {
  final int initialHours;
  final int initialMinutes;
  final int initialSeconds;
  final bool isPlaying;

  const FullscreenTimerScreen({
    Key? key,
    required this.initialHours,
    required this.initialMinutes,
    required this.initialSeconds,
    required this.isPlaying,
  }) : super(key: key);

  @override
  State<FullscreenTimerScreen> createState() => _FullscreenTimerScreenState();
}

class _FullscreenTimerScreenState extends State<FullscreenTimerScreen> {
  late int _hours;
  late int _minutes;
  late int _seconds;
  Timer? _timer;
  late bool _isPlaying;

  @override
  void initState() {
    super.initState();
    _hours = widget.initialHours;
    _minutes = widget.initialMinutes;
    _seconds = widget.initialSeconds;
    _isPlaying = widget.isPlaying;

    if (_isPlaying) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_hours == 0 && _minutes == 0 && _seconds == 0) {
        timer.cancel();
        setState(() => _isPlaying = false);
        return;
      }
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _seconds = 59;
          if (_minutes > 0) {
            _minutes--;
          } else {
            _minutes = 59;
            _hours--;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: SafeArea(
          child: Center(
            child: RotatedBox(
              quarterTurns: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildTimeCard(_hours.toString().padLeft(2, '0'))),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTimeCard(_minutes.toString().padLeft(2, '0'))),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTimeCard(_seconds.toString().padLeft(2, '0'))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard(String time) {
    return Container(
      height: 300,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
      ),
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            time,
            style: const TextStyle(
              fontFamily: "ndot",
              fontSize: 160,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColon() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

