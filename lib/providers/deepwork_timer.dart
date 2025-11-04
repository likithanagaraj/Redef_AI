import 'dart:async';
import 'package:flutter/material.dart';
import 'package:redef_ai_main/services/music_service.dart';
import '../services/pomodoro_service.dart';
import 'package:audioplayers/audioplayers.dart';
class DeepworkTimer extends ChangeNotifier {
  final List<int> presetTimes = [5 * 60,10 * 60,15 * 60,20 * 60, 25 * 60,30 * 60, 35 * 60 ,40 * 60,  45 * 60 ,50 * 60,55 * 60,60 * 60   ];
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
  String selectedMusic = 'None';
// NEW: Selected project (just a string)
  String selectedProjectName = 'I am Focusing on';
  DeepworkTimer()
      : totalSeconds = 25 * 60,
        remainingSeconds = 25 * 60;

  void selectProject(String projectName) {
    selectedProjectName = projectName;
    notifyListeners();
  }
  void selectMusic(String music) {
    selectedMusic = music;
    notifyListeners();
  }
  void start() {
    if (isRunning) return;
    isRunning = true;
    isPaused = false;

    if (isWorkSession && selectedMusic != 'None') {
      MusicService.play(selectedMusic);
    }

    if (isWorkSession) sessionStart = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _tick());
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
      if (sessionStart == null) return; // avoid null crash
      if (isRunning) return; // skip extra save

      if (isWorkSession) {
        MusicService.stop();
        sessionEnd = DateTime.now();
        await PomodoroService.recordSession(
          start: sessionStart!,
          end: sessionEnd!,
          project: selectedProjectName != 'I am Focusing on'
              ? selectedProjectName
              : null, // Only save if project is selected
          focusTimeMinutes: totalSeconds ~/60
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
    MusicService.pause();
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    isRunning = false;
    remainingSeconds = totalSeconds;
    MusicService.stop();
    notifyListeners();
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
    }
  }

  String formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;

    // 👇 If above 1 hour, show only total minutes
    if (h > 0) {
      final totalMinutes = (seconds ~/ 60);
      return '${totalMinutes.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }

    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }


  double get progress =>
      (totalSeconds - remainingSeconds) / totalSeconds;
}
