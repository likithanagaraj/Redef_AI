import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../constants.dart';
import '../design_tokens.dart';
import '../models/notification_settings.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  NotificationSettings? _settings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final isar = Isar.getInstance();
    if (isar == null) return;
    final settings = await isar.notificationSettings.get(1);
    setState(() {
      _settings = settings;
    });
  }

  Future<void> _saveSettings(NotificationSettings newSettings) async {
    final isar = Isar.getInstance();
    if (isar == null) return;
    await isar.writeTxn(() async {
      await isar.notificationSettings.put(newSettings);
    });
    setState(() {
      _settings = newSettings;
    });
    // Reevaluate based on new settings
    await NotificationService().reevaluateNotifications();
  }

  @override
  Widget build(BuildContext context) {
    if (_settings == null) {
      return const Scaffold(backgroundColor: scaffoldBg, body: Center(child: CircularProgressIndicator(color: cta)));
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(fontFamily: "ndot", color: textColor),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Focus & Achievements"),
              _buildSwitchTile("Pomodoro Completed", _settings!.pomodoroCompleted, (val) {
                final s = _settings!..pomodoroCompleted = val;
                _saveSettings(s);
              }),
              _buildSwitchTile("Achievement Alerts", _settings!.achievementAlerts, (val) {
                final s = _settings!..achievementAlerts = val;
                _saveSettings(s);
              }),
              const SizedBox(height: Spacing.xxl),
              _buildSectionTitle("Reminders"),
              _buildSwitchTile("Habit Reminders", _settings!.habitReminders, (val) {
                final s = _settings!..habitReminders = val;
                _saveSettings(s);
              }),
              _buildSwitchTile("Pending Tasks Reminder", _settings!.pendingTasksReminder, (val) {
                final s = _settings!..pendingTasksReminder = val;
                _saveSettings(s);
              }),
              const SizedBox(height: Spacing.xxl),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cta,
                    foregroundColor: textColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () async {
                    try {
                      print("Triggering test notification...");
                      await NotificationService().showPomodoroCompletion();
                      print("Test notification triggered successfully.");
                    } catch (e, stacktrace) {
                      print("Error triggering notification: $e");
                      print(stacktrace);
                    }
                  },
                  child: const Text("Test Notification"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: "TTNormsPro",
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: cta,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: "TTNormsPro",
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: cta,
            inactiveTrackColor: scaffoldBg.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
