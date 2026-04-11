import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../design_tokens.dart';
import '../services/notification_service.dart';

/// Returned on dismiss so [DeepworkScreen] can sync state back.
class FullscreenTimerResult {
  final int hours;
  final int minutes;
  final int seconds;
  final bool isPlaying;
  const FullscreenTimerResult({
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.isPlaying,
  });
}

class FullscreenTimerScreen extends StatefulWidget {
  final int initialHours;
  final int initialMinutes;
  final int initialSeconds;
  final bool isPlaying;
  final String? projectName;

  const FullscreenTimerScreen({
    Key? key,
    required this.initialHours,
    required this.initialMinutes,
    required this.initialSeconds,
    required this.isPlaying,
    this.projectName,
  }) : super(key: key);

  @override
  State<FullscreenTimerScreen> createState() => _FullscreenTimerScreenState();
}

class _FullscreenTimerScreenState extends State<FullscreenTimerScreen> {
  late int _hours;
  late int _minutes;
  late int _seconds;
  late bool _isPlaying;

  Timer? _timer;
  Timer? _hideControlsTimer; // auto-hides UI after 5 s of no interaction

  // Controls overlay visibility
  bool _showControls = true;

  // Drag accumulators for scroll-to-edit (one per unit group)
  double _hourDrag = 0;
  double _minDrag = 0;
  double _secDrag = 0;

  @override
  void initState() {
    super.initState();
    _hours = widget.initialHours;
    _minutes = widget.initialMinutes;
    _seconds = widget.initialSeconds;
    _isPlaying = widget.isPlaying;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (_isPlaying) _startTimer();

    // Start the initial auto-hide countdown
    _scheduleHideControls();
  }

  // ─── Controls visibility ───────────────────────────────────────────────────

  /// Called on every screen tap — shows the controls and resets the 5 s timer.
  void _onScreenTap() {
    setState(() => _showControls = true);
    _scheduleHideControls();
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  // ─── Timer logic ───────────────────────────────────────────────────────────

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_hours == 0 && _minutes == 0 && _seconds == 0) {
        t.cancel();
        setState(() => _isPlaying = false);
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
    });
  }

  void _toggleTimer() {
    if (_isPlaying) {
      _timer?.cancel();
      setState(() => _isPlaying = false);
    } else {
      if (_hours == 0 && _minutes == 0 && _seconds == 0) return;
      setState(() => _isPlaying = true);
      _startTimer();
    }
    _scheduleHideControls(); // reset the auto-hide after button press
  }

  void _dismiss() {
    _timer?.cancel();
    _hideControlsTimer?.cancel();
    Navigator.pop(
      context,
      FullscreenTimerResult(
        hours: _hours,
        minutes: _minutes,
        seconds: _seconds,
        isPlaying: _isPlaying,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hideControlsTimer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ─── Getters ───────────────────────────────────────────────────────────────

  String get _hh => _hours.toString().padLeft(2, '0');
  String get _mm => _minutes.toString().padLeft(2, '0');
  String get _ss => _seconds.toString().padLeft(2, '0');

  // ─── Drag-to-edit alert ────────────────────────────────────────────────────

  void _showTimerRunningAlert() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.small)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Timer is running",
                style: TextStyle(
                  fontFamily: "ndot",
                  fontSize: 18,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Do you want to stop the timer to edit the time?",
                style: TextStyle(
                  fontFamily: "TTNormsPro",
                  fontSize: 14,
                  color: textColor.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: Spacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                        "Keep Running",
                        style: TextStyle(
                          fontFamily: "TTNormsPro",
                          fontSize: 13,
                          color: textColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _toggleTimer();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: cta,
                        borderRadius:
                            BorderRadius.circular(AppRadius.small),
                      ),
                      child: const Text(
                        "Stop",
                        style: TextStyle(
                          fontFamily: "TTNormsPro",
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
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

  // ─── Flip-clock digit pair ─────────────────────────────────────────────────

  Widget _buildDigitPair({
    required String value,
    required String label,
    required double dragAccum,
    required void Function(double accum, int steps) onDragUpdate,
  }) {
    return GestureDetector(
      onVerticalDragStart: (_) {
        if (_isPlaying) _showTimerRunningAlert();
        _onScreenTap(); // counts as interaction
      },
      onVerticalDragUpdate: _isPlaying
          ? null
          : (d) => onDragUpdate(dragAccum + d.delta.dy, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: LayoutBuilder(builder: (ctx, cst) {
              final h = cst.maxHeight.isFinite ? cst.maxHeight : 180.0;
              final fontSize = (h * 0.62).clamp(32.0, 180.0);
              return Row(
                children: [
                  Expanded(child: _flipCard(value[0], h, fontSize)),
                  const SizedBox(width: 8),
                  Expanded(child: _flipCard(value[1], h, fontSize)),
                ],
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: "ndot",
              fontSize: 10,
              color: textColor.withValues(alpha: 0.4),
              letterSpacing: 2.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _flipCard(String digit, double h, double fontSize) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Text(
                digit,
                style: TextStyle(
                  fontFamily: "ndot",
                  fontSize: fontSize,
                  color: textColor.withValues(alpha: 0.9),
                  height: 1.0,
                ),
              ),
            ),
          ),
          Positioned(
            top: h / 2 - 1.5,
            left: 0,
            right: 0,
            child: Container(height: 3, color: scaffoldBg),
          ),
        ],
      ),
    );
  }

  Widget _colonSeparator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _dot(),
          const SizedBox(height: 12),
          _dot(),
        ],
      ),
    );
  }

  Widget _dot() => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: textColor.withValues(alpha: 0.28),
          shape: BoxShape.circle,
        ),
      );

  // ─── Overlay controls (top bar + bottom pill) ──────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Project badge
          if (widget.projectName != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt, color: cta, size: 13),
                  const SizedBox(width: 4),
                  Text(
                    widget.projectName!,
                    style: const TextStyle(
                      fontFamily: "ndot",
                      fontSize: 11,
                      color: textColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox.shrink(),

          // Close button
          GestureDetector(
            onTap: _dismiss,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.close_rounded, color: textColor, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayPausePill() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: _toggleTimer,
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(40),
          ),
          padding: const EdgeInsets.all(8),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _isPlaying ? textColor.withValues(alpha: 0.08) : cta,
              shape: BoxShape.circle,
              boxShadow: _isPlaying
                  ? null
                  : [
                      BoxShadow(
                        color: cta.withValues(alpha: 0.4),
                        blurRadius: 16,
                      )
                    ],
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: textColor,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Main layout ───────────────────────────────────────────────────────────

  Widget _buildLayout() {
    final showHours = _hours > 0 || _isPlaying;

    // Digit cards row (always visible)
    final digitRow = Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHours) ...[
              Expanded(
                flex: 2,
                child: _buildDigitPair(
                  value: _hh,
                  label: "HRS",
                  dragAccum: _hourDrag,
                  onDragUpdate: (accum, steps) {
                    setState(() {
                      _hourDrag = accum;
                      _hours = (_hours - steps).clamp(0, 23);
                    });
                  },
                ),
              ),
              _colonSeparator(),
            ],
            Expanded(
              flex: 2,
              child: _buildDigitPair(
                value: _mm,
                label: "MIN",
                dragAccum: _minDrag,
                onDragUpdate: (accum, steps) {
                  setState(() {
                    _minDrag = accum;
                    _minutes = (_minutes - steps).clamp(0, 59);
                  });
                },
              ),
            ),
            _colonSeparator(),
            Expanded(
              flex: 2,
              child: _buildDigitPair(
                value: _ss,
                label: "SEC",
                dragAccum: _secDrag,
                onDragUpdate: (accum, steps) {
                  setState(() {
                    _secDrag = accum;
                    _seconds = (_seconds - steps).clamp(0, 59);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );

    return Stack(
      children: [
        // ── Always-visible digit layer ─────────────────────────────────────
        // Tap anywhere on this layer to show controls
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onScreenTap,
          child: Column(
            children: [
              // Reserve space at top matching top bar height
              const SizedBox(height: 56),
              digitRow,
              // Reserve space at bottom matching pill height
              const SizedBox(height: 70),
            ],
          ),
        ),

        // ── Animated controls overlay ──────────────────────────────────────
        AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: IgnorePointer(
            ignoring: !_showControls,
            child: Column(
              children: [
                _buildTopBar(),
                const Spacer(),
                _buildPlayPausePill(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(child: _buildLayout()),
    );
  }
}
