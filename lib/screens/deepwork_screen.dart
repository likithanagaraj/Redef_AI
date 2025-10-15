import 'package:flutter/material.dart';
import 'dart:async';
import 'package:redef_ai_main/core/supabase_config.dart';

class DeepworkScreen extends StatefulWidget {
  const DeepworkScreen({super.key});

  @override
  State<DeepworkScreen> createState() => _DeepworkScreenState();
}

class _DeepworkScreenState extends State<DeepworkScreen> {
  // Timer variables
  bool _isRecording = false;
  int totalSeconds = 25 * 60; // default work duration
  int remainingSeconds = 25 * 60;
  bool isRunning = false;
  Timer? timer;

  // Pomodoro logic
  bool isWorkSession = true;
  int completedWorkSessions = 0;
  final List<int> presetTimes = [5 * 60, 25 * 60, 45 * 60]; // adjustable work times
  int currentPresetIndex = 1; // default 25 min
  final int shortBreakSeconds = 5 * 60;
  final int longBreakSeconds = 15 * 60;

  DateTime? sessionStartTime;
  DateTime? sessionEndTime;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void showTimeUpDialog({required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void startTimer() {
    if (isRunning) return;

    setState(() {
      isRunning = true;
      if (isWorkSession) sessionStartTime = DateTime.now();
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer?.cancel();
        setState(() => isRunning = false);

        if (isWorkSession) {
          // Work session completed
          await recordSession();
          completedWorkSessions++;
          if (completedWorkSessions % 4 == 0) {
            totalSeconds = longBreakSeconds;
          } else {
            totalSeconds = shortBreakSeconds;
          }
          remainingSeconds = totalSeconds;
          isWorkSession = false;
          showTimeUpDialog(message: "Work done! Take a break.");
          startTimer(); // auto start break
        } else {
          // Break completed
          totalSeconds = presetTimes[currentPresetIndex];
          remainingSeconds = totalSeconds;
          isWorkSession = true;
          showTimeUpDialog(message: "Break over! Back to work.");
        }
      }
    });
  }

  Future<void> recordSession() async {
    if (sessionStartTime == null || _isRecording) return;
    _isRecording = true;

    sessionEndTime = DateTime.now();
    final duration = sessionEndTime!.difference(sessionStartTime!);

    if (duration.inSeconds <= 0) {
      _isRecording = false;
      return;
    }

    // Get internal user ID
    final authUserId = SupabaseConfig.client.auth.currentUser?.id;
    if (authUserId == null) return;

    final userRow = await SupabaseConfig.client
        .from('users')
        .select('id')
        .eq('auth_user_id', authUserId)
        .maybeSingle();

    if (userRow == null) return;

    final internalUserId = userRow['id'];
    try {
      await SupabaseConfig.client.from('pomodoros').insert({
        'focus_time': duration.inSeconds,
        'session_completed_at': sessionEndTime!.toIso8601String(),
        'user_id': internalUserId,
      });
      print('Session recorded successfully!');
    } catch (e) {
      print('Exception while saving session: $e');
    } finally {
      sessionStartTime = null;
      sessionEndTime = null;
      _isRecording = false;
    }
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
    if (isWorkSession) recordSession();
  }

  void stopTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      remainingSeconds = totalSeconds;
    });
    if (isWorkSession) recordSession();
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      remainingSeconds = totalSeconds;
    });
  }

  void increaseTime() {
    if (!isRunning && currentPresetIndex < presetTimes.length - 1) {
      setState(() {
        currentPresetIndex++;
        if (isWorkSession) totalSeconds = presetTimes[currentPresetIndex];
        remainingSeconds = totalSeconds;
      });
    }
  }

  void decreaseTime() {
    if (!isRunning && currentPresetIndex > 0) {
      setState(() {
        currentPresetIndex--;
        if (isWorkSession) totalSeconds = presetTimes[currentPresetIndex];
        remainingSeconds = totalSeconds;
      });
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

  double getProgress() {
    return (totalSeconds - remainingSeconds) / totalSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.hourglass_bottom,
                        color: Colors.green.shade700,
                        size: 28,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Deep Work',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                            letterSpacing: -1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Timer Circle with Controls
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: CircularProgressIndicator(
                    value: getProgress(),
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatTime(remainingSeconds),
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: isRunning ? null : decreaseTime,
                          icon: Icon(
                            Icons.remove_circle_outline,
                            size: 32,
                            color: isRunning
                                ? Colors.grey.shade400
                                : Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(width: 40),
                        IconButton(
                          onPressed: isRunning ? null : increaseTime,
                          icon: Icon(
                            Icons.add_circle_outline,
                            size: 32,
                            color: isRunning
                                ? Colors.grey.shade400
                                : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Session: ${completedWorkSessions % 4}/4',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            // Start/Pause Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isRunning ? pauseTimer : startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isRunning ? 'Pause' : 'Start',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isRunning ? Icons.pause : Icons.arrow_forward,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),

// **Add Skip Break Button here**
            if (!isWorkSession)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(

                    onPressed: () {
                      timer?.cancel(); // cancel current break
                      setState(() {
                        isWorkSession = true;
                        totalSeconds = presetTimes[currentPresetIndex];
                        remainingSeconds = totalSeconds;
                      });
                      startTimer(); // optional: auto-start work session
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text("Skip Break",style: TextStyle(fontSize: 18),),
                  ),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
