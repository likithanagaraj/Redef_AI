import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import '../constants.dart';
import '../design_tokens.dart';
import '../widgets/dashed_border.dart';
import 'fullscreen_timer_screen.dart';
import 'see_all_screen.dart';
import 'package:isar/isar.dart';
import 'package:redef_ai_main/services/sync_manager.dart';
import '../models/project.dart';
import '../models/session.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';

class DeepworkScreen extends StatefulWidget {
  const DeepworkScreen({Key? key}) : super(key: key);

  @override
  _DeepworkScreenState createState() => _DeepworkScreenState();
}

class _DeepworkScreenState extends State<DeepworkScreen> {
  int _selectedPreset = 1; // 0: 30:00, 1: 1:00:00, 2: 2:00:00
  bool _isPlaying = false;
  
  Project? _activeProject;
  List<Project> _projects = [];
  List<DeepworkSession> _history = [];
  
  AudioPlayer? _bgMusicPlayer;
  String _selectedMusic = "none";
  
  DateTime? _sessionStartTime;
  Duration _sessionDuration = Duration.zero;
  
  Timer? _timer;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minController;
  late FixedExtentScrollController _secController;

  int _hours = 1;
  int _minutes = 0;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _hourController = FixedExtentScrollController(initialItem: _hours);
    _minController = FixedExtentScrollController(initialItem: _minutes);
    _secController = FixedExtentScrollController(initialItem: _seconds);
    _loadData();
  }

  Future<void> _loadData() async {
    final isar = Isar.getInstance()!;
    final projects = await isar.projects.where().filter().isDeletedEqualTo(false).findAll();
    final history = await isar.deepworkSessions.where().filter().isDeletedEqualTo(false).sortByEndTimeDesc().limit(3).findAll();
    setState(() {
      _projects = projects;
      _history = history;
    });
  }

  Future<void> _saveSession() async {
    final isar = Isar.getInstance()!;
    final session = DeepworkSession()
      ..startTime = _sessionStartTime ?? DateTime.now().subtract(_sessionDuration)
      ..endTime = DateTime.now()
      ..durationInMinutes = _sessionDuration.inMinutes
      ..durationInSeconds = _sessionDuration.inSeconds
      ..isManualEntry = false;
    
    session.markAsUpdated(); // Initialize sync fields
      
    if (_activeProject != null) {
      session.project.value = _activeProject;
    }
    
    await isar.writeTxn(() async {
      await isar.deepworkSessions.put(session);
      await session.project.save();
    });
    
    // Check for Achievement Alert (e.g. 4 hours focused today)
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final sessionsToday = await isar.deepworkSessions.filter()
        .isDeletedEqualTo(false)
        .endTimeGreaterThan(startOfToday)
        .findAll();
    int totalMinutesToday = sessionsToday.fold(0, (sum, s) => sum + s.durationInMinutes);
    // If they just crossed the 4 hour mark (240 minutes) we trigger an alert.
    // We check if this exact session pushed them over the threshold to avoid spamming them
    if (totalMinutesToday >= 240 && (totalMinutesToday - session.durationInMinutes) < 240) {
      NotificationService().showAchievementAlert("Great Work!", "You focused for 4 hours today!");
    }

    _loadData();
    WidgetService.updateWidgetData();
    SyncManager().syncUp();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bgMusicPlayer?.dispose();
    _hourController.dispose();
    _minController.dispose();
    _secController.dispose();
    super.dispose();
  }

  String _getMusicAsset(String preset) {
    switch (preset) {
      case "night-rain": return "nightRainForest.mp3";
      case "campfire": return "Campfire.mp3";
      case "tic-tac": return "tic-tac.mp3";
      case "wind": return "nightRainForest.mp3"; // Fallback mapping
      default: return "";
    }
  }

  void _updateMusic() async {
    if (_bgMusicPlayer == null) {
      _bgMusicPlayer = AudioPlayer();
      _bgMusicPlayer!.setReleaseMode(ReleaseMode.loop);
    }
    
    if (_isPlaying && _selectedMusic != "none") {
      String asset = _getMusicAsset(_selectedMusic);
      if (asset.isNotEmpty) {
        await _bgMusicPlayer!.play(AssetSource('sounds/$asset'));
      }
    } else {
      await _bgMusicPlayer?.stop();
    }
  }

  void _previewMusic(String preset) async {
    if (_bgMusicPlayer == null) {
      _bgMusicPlayer = AudioPlayer();
      _bgMusicPlayer!.setReleaseMode(ReleaseMode.loop);
    }
    if (preset == "none") {
      await _bgMusicPlayer?.stop();
      return;
    }
    String asset = _getMusicAsset(preset);
    if (asset.isNotEmpty) {
      await _bgMusicPlayer!.play(AssetSource('sounds/$asset'));
    }
  }

  void _setPreset(int index) {
    setState(() => _selectedPreset = index);
    if (index == 0) {
      _hours = 0;
      _minutes = 30;
      _seconds = 0;
    } else if (index == 1) {
      _hours = 1;
      _minutes = 0;
      _seconds = 0;
    } else if (index == 2) {
      _hours = 2;
      _minutes = 0;
      _seconds = 0;
    }
    _hourController.jumpToItem(_hours);
    _minController.jumpToItem(_minutes);
    _secController.jumpToItem(_seconds);
  }

  void _toggleTimer() {
    if (_isPlaying) {
      _timer?.cancel();
      setState(() => _isPlaying = false);
      _updateMusic();
    } else {
      if (_hours == 0 && _minutes == 0 && _seconds == 0) return;
      setState(() => _isPlaying = true);
      _updateMusic();
      
      if (_sessionStartTime == null) {
        _sessionStartTime = DateTime.now();
        _sessionDuration = Duration(hours: _hours, minutes: _minutes, seconds: _seconds);
      }
      
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_hours == 0 && _minutes == 0 && _seconds == 0) {
          timer.cancel();
          _saveSession();
          _sessionStartTime = null;
          setState(() => _isPlaying = false);
          _updateMusic();
          
          final player = AudioPlayer();
          player.play(AssetSource('sounds/bell-notification.mp3'));
          NotificationService().showPomodoroCompletion();
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
        _secController.animateToItem(_seconds, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
        _minController.animateToItem(_minutes, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
        _hourController.animateToItem(_hours, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
  horizontal: Spacing.lg,
  vertical: Spacing.lg,
),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "DEEPWORK",
                    style: TextStyle(
                      fontFamily: "ndot",
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      // Pause the main-screen timer while in fullscreen
                      // to avoid double-counting; fullscreen runs its own tick.
                      _timer?.cancel();

                      final result = await Navigator.push<FullscreenTimerResult>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullscreenTimerScreen(
                            initialHours: _hours,
                            initialMinutes: _minutes,
                            initialSeconds: _seconds,
                            isPlaying: _isPlaying,
                            projectName: _activeProject?.name,
                          ),
                        ),
                      );

                      // Sync state back from fullscreen so progress is never lost
                      if (result != null && mounted) {
                        setState(() {
                          _hours = result.hours;
                          _minutes = result.minutes;
                          _seconds = result.seconds;
                          _isPlaying = result.isPlaying;
                        });
                        _hourController.jumpToItem(_hours);
                        _minController.jumpToItem(_minutes);
                        _secController.jumpToItem(_seconds);

                        // Resume the main timer if it was still running in fullscreen
                        if (_isPlaying) {
                          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
                            if (_hours == 0 && _minutes == 0 && _seconds == 0) {
                              timer.cancel();
                              _saveSession();
                              _sessionStartTime = null;
                              setState(() => _isPlaying = false);
                              _updateMusic();
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
                            _secController.animateToItem(_seconds,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeIn);
                            _minController.animateToItem(_minutes,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeIn);
                            _hourController.animateToItem(_hours,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeIn);
                          });
                        }
                      }
                    },
                    child: SvgPicture.asset(
                      "assets/icons/expand.svg",
                      width: IconSize.reg,
                      height: IconSize.reg,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  )
                ],
              ),
              const SizedBox(height: Spacing.xxl),

              // Section 1: Timer and Focus
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _showFocusBottomSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
  horizontal: Spacing.lg,
  vertical: Spacing.sm,
),
                        decoration: BoxDecoration(
                          color: textColor.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _activeProject?.name ?? "What are you focusing on",
                              style: const TextStyle(
                                fontFamily: "TTNormsPro",
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: scaffoldBg,
                              ),
                            ),
                            const SizedBox(width: Spacing.xs),
                            SvgPicture.asset(
                              "assets/icons/droparrow.svg",
                              width: 8,
                              height: 8,
                              colorFilter: const ColorFilter.mode(scaffoldBg, BlendMode.srcIn),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),
                    GestureDetector(
                      onTap: _isPlaying ? () => _showStopTimerAlert(context) : null,
                      behavior: HitTestBehavior.opaque,
                      child: IgnorePointer(
                        ignoring: _isPlaying,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: _buildTimeCard(_hourController, 24, (val) => setState(() { _hours = val; _selectedPreset = -1; }))),
                            const SizedBox(width: Spacing.sm),
                            Expanded(child: _buildTimeCard(_minController, 60, (val) => setState(() { _minutes = val; _selectedPreset = -1; }))),
                            const SizedBox(width: Spacing.sm),
                            Expanded(child: _buildTimeCard(_secController, 60, (val) => setState(() { _seconds = val; _selectedPreset = -1; }))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xxl),

              // Section 2: Preset Times and Controls
              GestureDetector(
                onTap: _isPlaying ? () => _showStopTimerAlert(context) : null,
                behavior: HitTestBehavior.opaque,
                child: IgnorePointer(
                  ignoring: _isPlaying,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPresetCircle(0, "30:00"),
                      _buildPresetCircle(1, "1:00:00"),
                      _buildPresetCircle(2, "2:00:00"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildControlBtn(
                      "Restart",
                      "close.svg", // assuming delete or close for stop
                      cardColor,
                      !_isPlaying ? textColor : textColor.withValues(alpha: 0.5),
                      onTap: () {
                         if (_isPlaying) {
                           _showStopTimerAlert(context);
                           return;
                         }
                         _timer?.cancel();
                         setState(() {
                           _isPlaying = false;
                           _sessionStartTime = null;
                           _hours = 0;
                           _minutes = 0;
                           _seconds = 0;
                         });
                         _updateMusic();
                         _hourController.jumpToItem(0);
                         _minController.jumpToItem(0);
                         _secController.jumpToItem(0);
                      }
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    flex: 2,
                    child: _buildControlBtn(
                      _isPlaying ? "Pause" : "Play",
                      _isPlaying ? "play.svg" : "Frame.svg",
                      _isPlaying ? cta.withValues(alpha: 0.8) : cta,
                      textColor,
                      onTap: _toggleTimer,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    flex: 1,
                    child: _buildControlBtn(
                      "",
                      "music.svg",
                      cardColor,
                      !_isPlaying ? textColor : textColor.withValues(alpha: 0.5),
                      onTap: () {
                         if (_isPlaying) {
                           _showStopTimerAlert(context);
                           return;
                         }
                         _showMusicBottomSheet(context);
                      }
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xxl),

              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SeeAllScreen(),
                    ),
                  );
                  _loadData();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Focus History",
                            style: TextStyle(
                              fontFamily: "TTNormsPro",
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          Text(
                            "See all",
                            style: TextStyle(
                              fontFamily: "TTNormsPro",
                              fontSize: 14,
                              color: textColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.lg),
                      if (_history.isEmpty)
                        const Text(
                          "No sessions yet",
                          style: TextStyle(
                            fontFamily: "TTNormsPro",
                            fontSize: 14,
                            color: Colors.white54,
                          ),
                        )
                      else
                        ..._history.map((session) {
                          String title = session.project.value?.name ?? "work @ ${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')}";
                          String durationStr = (session.durationInMinutes == 0 && session.durationInSeconds > 0) ? "${session.durationInSeconds} sec" : "${session.durationInMinutes} min";
                          return _buildHistoryCard(title, durationStr);
                        }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard(FixedExtentScrollController controller, int max, Function(int) onChanged) {
    return Container(
      width: 90, // you can later create ContainerSize.timerCard
      height: ContainerSize.statCardHeight,
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: ListWheelScrollView.useDelegate(
        itemExtent: 80,
        perspective: 0.005,
        diameterRatio: 1.5,
        physics: const FixedExtentScrollPhysics(),
        controller: controller,
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: max,
          builder: (context, index) {
            return Container(
              alignment: Alignment.center,
              child: Text(
                index.toString().padLeft(2, '0'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: "TTNormsPro",
                  fontSize: 64,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPresetCircle(int index, String text) {
    bool isSelected = _selectedPreset == index;
    Widget child = Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? textColor : Colors.transparent,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "TTNormsPro",
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isSelected ? scaffoldBg : textColor,
        ),
      ),
    );

    return GestureDetector(
      onTap: () => _setPreset(index),
      child: isSelected
          ? child
          : DashedBorder(
              color: textColor.withValues(alpha: 0.3),
              dashWidth: 4,
              dashSpace: 4,
              isCircle: true,
              child: child,
            ),
    );
  }

  Widget _buildControlBtn(String text, String icon, Color bgColor, Color fgColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: "ndot",
                  fontSize: 12,
                  color: text == "Play" || text == "Pause" ? textColor : fgColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: Spacing.xs),
            SvgPicture.asset(
              "assets/icons/$icon",
              width: IconSize.sm,
              height: IconSize.sm,
              colorFilter: ColorFilter.mode(text == "Play" || text == "Pause" ? textColor : fgColor, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(String title, String duration) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      padding: const EdgeInsets.symmetric(
  horizontal: Spacing.lg,
  vertical: Spacing.lg,
),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: "ndot",
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cta,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              duration,
              style: const TextStyle(
                fontFamily: "TTNormsPro",
                fontSize: 10,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFocusBottomSheet(BuildContext context) {
    Project? selected = _activeProject;
    TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 32,
              ),
              decoration: const BoxDecoration(
                color: textColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "What are you focusing on?",
                    style: TextStyle(
                      fontFamily: "TTNormsPro",
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: scaffoldBg,
                    ),
                  ),
                  const SizedBox(height: Spacing.xl),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: scaffoldBg.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(
                        fontFamily: "ndot",
                        color: scaffoldBg,
                      ),
                      onChanged: (val) {
                        setModalState(() {});
                      },
                      cursorColor: cta,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "e.g Redesigning the screen",
                        hintStyle: TextStyle(
                          fontFamily: "ndot",
                          color: scaffoldBg.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.xl),
                  if (_projects.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _projects.map((p) => _buildProjectBadge(p, selected, (val) => setModalState(() => selected = val))).toList(),
                    ),
                    const SizedBox(height: Spacing.xxl),
                  ],
                  GestureDetector(
                    onTap: () async {
                      if (controller.text.isNotEmpty) {
                        final isar = Isar.getInstance()!;
                        final newProj = Project()..name = controller.text;
                        newProj.markAsUpdated();
                        await isar.writeTxn(() async {
                          await isar.projects.put(newProj);
                        });
                          setState(() {
                            _projects.add(newProj);
                            _activeProject = newProj;
                          });
                          SyncManager().syncUp();
                        } else {
                        setState(() {
                           _activeProject = selected;
                        });
                      }
                      if (mounted) Navigator.pop(context);
                    },
                    child: Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cta,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.text.isNotEmpty ? "Create project" : "Select project",
                            style: const TextStyle(
                              fontFamily: "TTNormsPro",
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: Spacing.sm),
                          SvgPicture.asset(
                            "assets/icons/create.svg",
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(textColor, BlendMode.srcIn),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.xxl),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProjectBadge(Project project, Project? selected, Function(Project) onTap) {
    bool isSelected = project.id == selected?.id;
    Widget child = Container(
      padding: const EdgeInsets.symmetric(
  horizontal: Spacing.lg,
  vertical: Spacing.sm,
),
      decoration: BoxDecoration(
        color: isSelected ? scaffoldBg : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        project.name,
        style: TextStyle(
          fontFamily: "TTNormsPro",
          fontSize: 12,
          color: isSelected ? textColor : scaffoldBg,
        ),
      ),
    );

    return GestureDetector(
      onTap: () => onTap(project),
      child: isSelected
          ? child
          : DashedBorder(
              color: scaffoldBg.withValues(alpha: 0.3),
              radius: 20,
              strokeWidth: 1,
              child: child,
            ),
    );
  }

  void _showMusicBottomSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: textColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select a background music",
                      style: TextStyle(
                        fontFamily: "TTNormsPro",
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: scaffoldBg,
                      ),
                    ),
                    const SizedBox(height: Spacing.xl),
                    Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      children: [
                        _buildMusicBadge("none", _selectedMusic, (v) => setModalState(() { setState(() => _selectedMusic = v); _previewMusic(v); })),
                        _buildMusicBadge("night-rain", _selectedMusic, (v) => setModalState(() { setState(() => _selectedMusic = v); _previewMusic(v); })),
                        _buildMusicBadge("campfire", _selectedMusic, (v) => setModalState(() { setState(() => _selectedMusic = v); _previewMusic(v); })),
                        _buildMusicBadge("wind", _selectedMusic, (v) => setModalState(() { setState(() => _selectedMusic = v); _previewMusic(v); })),
                        _buildMusicBadge("tic-tac", _selectedMusic, (v) => setModalState(() { setState(() => _selectedMusic = v); _previewMusic(v); })),
                      ],
                    ),
                    const SizedBox(height: Spacing.xxl),
                    GestureDetector(
                      onTap: () {
                         // Selection logic here then dismiss
                         Navigator.pop(ctx);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cta,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                        ),
                        child: const Text(
                          "Select music",
                          style: TextStyle(
                            fontFamily: "ndot",
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => _updateMusic());
  }

  Widget _buildMusicBadge(String title, String selected, Function(String) onTap) {
    bool isSelected = selected == title;
    return GestureDetector(
      onTap: () => onTap(title),
      child: isSelected
        ? Container(
            padding: const EdgeInsets.symmetric(
  horizontal: Spacing.lg,
  vertical: Spacing.sm,
),
            decoration: BoxDecoration(
              color: scaffoldBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: "TTNormsPro",
                fontSize: 14,
                color: textColor,
              ),
            ),
          )
        : DashedBorder(
            color: scaffoldBg.withValues(alpha: 0.3),
            radius: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
  horizontal: Spacing.lg,
  vertical: Spacing.sm,
),
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: "TTNormsPro",
                  fontSize: 14,
                  color: scaffoldBg,
                ),
              ),
            ),
          ),
    );
  }

  void _showStopTimerAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.small)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Timer Running",
                style: TextStyle(
                  fontFamily: "TTNormsPro",
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: scaffoldBg,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Please stop or pause the timer to adjust the preset time and edit controls.",
                style: TextStyle(
                  fontFamily: "TTNormsPro",
                  fontSize: 14,
                  color: scaffoldBg.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: Spacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: scaffoldBg.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: const Text(
                        "Got It",
                        style: TextStyle(
                          fontFamily: "TTNormsPro",
                          fontSize: 14,
                          color: scaffoldBg,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
