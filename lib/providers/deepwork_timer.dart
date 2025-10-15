import 'dart:async';
import 'package:flutter/material.dart';
import '../services/pomodoro_service.dart';
import 'package:audioplayers/audioplayers.dart';
class DeepworkTimer extends ChangeNotifier {
  final List<int> presetTimes = [5 * 60,15 * 60, 25 * 60, 35 * 60,45 * 60,];
  final int shortBreakSeconds = 5 * 60;
  final int longBreakSeconds = 15 * 60;
  final player = AudioPlayer();
  int currentPresetIndex = 1;
  int completedWorkSessions = 0;
  bool isWorkSession = true;
  int totalSeconds;
  int remainingSeconds;
  bool isRunning = false;
  DateTime? sessionStart;
  DateTime? sessionEnd;
  bool isPaused = false;
  Timer? _timer;

  DeepworkTimer()
      : totalSeconds = 25 * 60,
        remainingSeconds = 25 * 60;

  void start() {
    if (isRunning) return;
    isRunning = true;
    isPaused = false;
    if (isWorkSession) sessionStart = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => _tick());
    notifyListeners();
  }

  void _tick() async {
    if (remainingSeconds > 0) {
      remainingSeconds--;
      notifyListeners();
    } else {
      // Timer reached zero, play sound here
      await player.play(AssetSource('sounds/bell-notification.mp3'));
      _timer?.cancel();
      isRunning = false;

      if (isWorkSession) {
        sessionEnd = DateTime.now();
        await PomodoroService.recordSession(
          start: sessionStart!,
          end: sessionEnd!,
        );
        completedWorkSessions++;
        totalSeconds = (completedWorkSessions % 4 == 0)
            ? longBreakSeconds
            : shortBreakSeconds;
        remainingSeconds = totalSeconds;
        isWorkSession = false;
        notifyListeners();
      } else {
        totalSeconds = presetTimes[currentPresetIndex];
        remainingSeconds = totalSeconds;
        isWorkSession = true;
        notifyListeners();
      }

    }
  }

  void pause() {
    _timer?.cancel();
    isRunning = false;
    isPaused = true;
    notifyListeners();
    // Record session if it's a work session
    if (isWorkSession && sessionStart != null) {
      PomodoroService.recordSession(
        start: sessionStart!,
        end: DateTime.now(),
      );
    }
  }

  void stop() {
    _timer?.cancel();
    isRunning = false;
    remainingSeconds = totalSeconds;
    notifyListeners();
    // Record session if it's a work session
    if (isWorkSession && sessionStart != null) {
      PomodoroService.recordSession(
        start: sessionStart!,
        end: DateTime.now(),
      );
    }
  }

  void reset() {
    _timer?.cancel();
    isRunning = false;
    isPaused = false;
    remainingSeconds = totalSeconds;
    notifyListeners();
  }



  void increaseTime() {
    if (!isRunning && currentPresetIndex < presetTimes.length - 1) {
      currentPresetIndex++;
      if (isWorkSession) totalSeconds = presetTimes[currentPresetIndex];
      remainingSeconds = totalSeconds;
      notifyListeners();
    }
  }

  void decreaseTime() {
    if (!isRunning && currentPresetIndex > 0) {
      currentPresetIndex--;
      if (isWorkSession) totalSeconds = presetTimes[currentPresetIndex];
      remainingSeconds = totalSeconds;
      notifyListeners();
    }
  }

  void skipBreak() {
    if (!isWorkSession) {
      _timer?.cancel();
      isWorkSession = true;
      totalSeconds = presetTimes[currentPresetIndex];
      remainingSeconds = totalSeconds;
      notifyListeners();
      start();
    }
  }

  String formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get progress =>
      (totalSeconds - remainingSeconds) / totalSeconds;
}
