import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:avatar_glow/avatar_glow.dart';
import '../constants.dart';
import '../design_tokens.dart';
import '../widgets/dashed_border.dart';

class LiveKitAgentScreen extends StatefulWidget {
  final String tokenUrl;
  final String livekitUrl;

  const LiveKitAgentScreen({
    Key? key,
    this.tokenUrl =
        'https://lprinhfwtfsfrbnpbkme.supabase.co/functions/v1/get-token',
    this.livekitUrl = 'wss://redefai-0ymcdbve.livekit.cloud',
  }) : super(key: key);

  @override
  _LiveKitAgentScreenState createState() => _LiveKitAgentScreenState();
}

class _LiveKitAgentScreenState extends State<LiveKitAgentScreen>
    with TickerProviderStateMixin {
  lk.Room? _room;
  lk.EventsListener<lk.RoomEvent>? _roomListener;
  lk.LocalAudioTrack? _audioTrack;

  bool _isConnected = false;
  bool _isConnecting = false;
  bool _microphoneEnabled = false;
  bool _agentConnected = false;

  String _statusMessage = 'Tap mic to connect';
  String? _errorMessage;
  String? _roomName;
  String? _agentIdentity;
  String? _agentName;
  int _remoteAudioTrackCount = 0;

  final List<String> _debugLogs = <String>[];

  late AnimationController _pulseController;
  late AnimationController _orbController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _orbRotation;
  late Animation<double> _waveAnimation;

  final List<String> _suggestions = [
    "I want to set a habit for deepwork",
    "Help me plan my morning routine",
    "Add a task to buy groceries",
    "Remind me about the project deadline",
    "How is my focus session progressing?",
    "Start a new habit for reading",
  ];

  int _currentSuggestionIndex = 0;
  Timer? _suggestionTimer;

  @override
  void initState() {
    super.initState();

    _suggestionTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentSuggestionIndex =
              (_currentSuggestionIndex + 1) % _suggestions.length;
        });
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _orbRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _orbController, curve: Curves.linear));

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orbController.dispose();
    _waveController.dispose();
    _suggestionTimer?.cancel();
    _disconnect();
    super.dispose();
  }

  void _log(String message) {
    final line = '[${DateTime.now().toIso8601String()}] $message';
    debugPrint(line);
    if (!mounted) return;
    setState(() {
      _debugLogs.insert(0, line);
      if (_debugLogs.length > 30) _debugLogs.removeRange(30, _debugLogs.length);
    });
  }

  Future<String> _fetchToken() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      _log('Calling token API: ${widget.tokenUrl}');
      _log('User ID being sent: $userId');

      final response = await http
          .post(
            Uri.parse(widget.tokenUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"user_id": userId}),
          )
          .timeout(const Duration(seconds: 10));

      _log('Token API status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _roomName = data['room'] as String?;
        return data['token'] as String;
      }
      throw Exception('Failed to fetch token: ${response.statusCode}');
    } on http.ClientException catch (e) {
      _log('Token fetch error: $e');
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    } catch (e) {
      _log('Token fetch error: $e');
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('SocketException')) {
        throw Exception(
          'No internet connection. Please check your network and try again.',
        );
      }
      throw Exception('Error fetching token: $e');
    }
  }

  Future<void> _connect() async {
    if (_isConnecting || _isConnected) return;

    // Ensure clean state before connecting
    await _disconnect();

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
      _statusMessage = 'Connecting...';
      _agentConnected = false;
      _agentIdentity = null;
      _agentName = null;
      _remoteAudioTrackCount = 0;
      _debugLogs.clear();
    });

    try {
      print("Fetching token...");
      final token = await _fetchToken();
      print("TOKEN RECEIVED: $token");

      final room = lk.Room(
        roomOptions: const lk.RoomOptions(
          defaultAudioOutputOptions: lk.AudioOutputOptions(speakerOn: true),
        ),
      );

      _room = room;
      room.addListener(_onRoomStateChanged);

      _roomListener = room.createListener()
        ..on<lk.RoomConnectedEvent>((_) => print("ROOM CONNECTED"))
        ..on<lk.RoomDisconnectedEvent>((_) => print("ROOM DISCONNECTED"))
        ..on<lk.RoomReconnectingEvent>((_) => print("RECONNECTING..."))
        ..on<lk.ParticipantConnectedEvent>((event) async {
          print("PARTICIPANT JOINED: ${event.participant.identity}");
          _log('Remote participant joined: ${event.participant.identity}');
          _updateAgentState();
          await _subscribeToParticipantAudio(event.participant);
        })
        ..on<lk.ParticipantDisconnectedEvent>((event) {
          _log('Remote participant left: ${event.participant.identity}');
          _updateAgentState();
        })
        ..on<lk.TrackPublishedEvent>((event) async {
          _log('Track published: ${event.participant.identity}');
          if (event.publication.kind == lk.TrackType.AUDIO &&
              !event.publication.subscribed) {
            await event.publication.subscribe();
          }
        })
        ..on<lk.TrackSubscribedEvent>((event) {
          _log('Track subscribed: ${event.participant.identity}');
          _updateAgentState();
        })
        ..on<lk.TrackUnsubscribedEvent>((event) {
          _log('Track unsubscribed: ${event.participant.identity}');
          _updateAgentState();
        })
        ..on<lk.TrackSubscriptionExceptionEvent>((event) {
          _log('Track subscription failed: ${event.sid}');
        })
        ..on<lk.ActiveSpeakersChangedEvent>((event) {
          final speakers = event.speakers.map((s) => s.identity).join(', ');
          _log('Active speakers: $speakers');
        })
        ..on<lk.AudioPlaybackStatusChanged>((event) async {
          _log('Audio playback: isPlaying=${event.isPlaying}');
          if (_room != null && !_room!.canPlaybackAudio) {
            await _room!.startAudio();
          }
        });

      print("CONNECTING TO ROOM...");
      await room.connect(
        widget.livekitUrl,
        token,
        connectOptions: const lk.ConnectOptions(autoSubscribe: true),
      );
      print("CONNECTED SUCCESSFULLY");

      await room.setSpeakerOn(true);
      if (!room.canPlaybackAudio) await room.startAudio();

      await _inspectExistingParticipants();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _statusMessage = 'Connection failed';
        _isConnecting = false;
      });
    }
  }

  void _onRoomStateChanged() {
    final room = _room;
    if (room == null) return;

    if (room.connectionState == lk.ConnectionState.connected) {
      setState(() {
        _isConnected = true;
        _statusMessage = "Go ahead, I'm listening...";
        _isConnecting = false;
      });
      // Always try to enable microphone on connect/reconnect
      _enableMicrophone();
    } else if (room.connectionState == lk.ConnectionState.disconnected) {
      setState(() {
        _isConnected = false;
        _statusMessage = 'Tap mic to connect';
        _isConnecting = false;
        _microphoneEnabled = false;
        _agentConnected = false;
      });
    }
  }

  Future<void> _inspectExistingParticipants() async {
    final room = _room;
    if (room == null) return;
    if (room.remoteParticipants.isEmpty) {
      _updateAgentState();
      return;
    }
    for (final participant in room.remoteParticipants.values) {
      await _subscribeToParticipantAudio(participant);
    }
    _updateAgentState();
  }

  Future<void> _subscribeToParticipantAudio(
    lk.RemoteParticipant participant,
  ) async {
    for (final publication in participant.audioTrackPublications) {
      if (!publication.subscribed) await publication.subscribe();
    }
    await _room?.setSpeakerOn(true);
    _updateAgentState();
  }

  void _updateAgentState() {
    final room = _room;
    if (room == null) return;
    final participants = room.remoteParticipants.values.toList();
    final agent = participants.isNotEmpty ? participants.first : null;
    final audioTracks = participants
        .expand((p) => p.audioTrackPublications)
        .where((pub) => pub.subscribed && pub.track != null)
        .length;
    setState(() {
      _agentConnected = agent != null;
      _agentIdentity = agent?.identity;
      _agentName = agent?.name;
      _remoteAudioTrackCount = audioTracks;
    });
  }

  Future<void> _enableMicrophone() async {
    try {
      if (_audioTrack != null) return;
      _audioTrack = await lk.LocalAudioTrack.create();
      await _room!.localParticipant?.publishAudioTrack(_audioTrack!);
      print("MIC PUBLISHED");
      _log('Microphone enabled');
    } catch (e) {
      _log('Error enabling microphone: $e');
      _microphoneEnabled = false;
    }
  }

  Future<void> _disconnect() async {
    try {
      await _roomListener?.dispose();
      _roomListener = null;
      if (_audioTrack != null) {
        await _audioTrack!.dispose();
        _audioTrack = null;
      }
      if (_room != null) {
        _room!.removeListener(_onRoomStateChanged);
        await _room!.disconnect();
        _room = null;
      }
      _microphoneEnabled = false;
      if (mounted) {
        setState(() {
          _isConnected = false;
          _isConnecting = false;
          _statusMessage = 'Tap mic to connect';
          _agentConnected = false;
          _agentIdentity = null;
          _agentName = null;
          _remoteAudioTrackCount = 0;
        });
      }
    } catch (e) {
      _log('Error disconnecting: $e');
    }
  }

  void _handleMicTap() {
    if (_isConnecting) return;
    if (_isConnected) {
      _disconnect();
    } else {
      _connect();
    }
  }

  // ─── UI ──────────────────────────────────────────────────────────────────

  Widget _buildOrb() {
    final bool isSpeaking = _remoteAudioTrackCount > 0;
    final bool isActive = _isConnected || _isConnecting;

    return GestureDetector(
      onTap: _handleMicTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _orbRotation,
          _waveAnimation,
        ]),
        builder: (context, child) {
          return SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow rings
                if (isActive) ...[
                  _buildGlowRing(
                    size: 220 + (_pulseAnimation.value - 1) * 40,
                    opacity: 0.06,
                    color: isSpeaking ? const Color(0xff00C2FF) : cta,
                  ),
                  _buildGlowRing(
                    size: 180 + (_waveAnimation.value) * 20,
                    opacity: 0.10,
                    color: isSpeaking ? const Color(0xff00C2FF) : cta,
                  ),
                ],

                // Orb background blur layer
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isSpeaking
                                    ? const Color(0xff00C2FF)
                                    : (isActive
                                          ? cta
                                          : const Color(0xff333333)))
                                .withOpacity(isActive ? 0.5 : 0.2),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),

                // Main orb
                Transform.scale(
                  scale: isActive ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        transform: GradientRotation(_orbRotation.value),
                        colors: isSpeaking
                            ? [
                                const Color(0xff00C2FF),
                                const Color(0xff0066FF),
                                const Color(0xff00FFC6),
                                const Color(0xff00C2FF),
                              ]
                            : isActive
                            ? [
                                cta,
                                cta.withValues(alpha: 0.8),
                                cta.withValues(alpha: 0.6),
                                cta,
                              ]
                            : [
                                const Color(0xff2a2a2a),
                                const Color(0xff1a1a1a),
                                const Color(0xff222222),
                                const Color(0xff2a2a2a),
                              ],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Inner gloss
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              center: const Alignment(-0.3, -0.4),
                              radius: 0.8,
                              colors: [
                                Colors.white.withOpacity(0.25),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // Dots or wave indicator
                        if (isActive)
                          _buildWaveform(isSpeaking)
                        else
                          Icon(
                            Icons.mic_none_rounded,
                            color: Colors.white.withOpacity(0.4),
                            size: 36,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlowRing({
    required double size,
    required double opacity,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(opacity), width: 1.5),
      ),
    );
  }

  Widget _buildWaveform(bool isSpeaking) {
    final Color glowColor = isSpeaking ? const Color(0xff00C2FF) : cta;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(9, (i) {
        return AnimatedBuilder(
          animation: _waveController,
          builder: (context, _) {
            final double phase = (i * 0.4);
            final double speedMult = isSpeaking ? 3.0 : 1.5;
            final double val = math.sin(
              (_waveController.value * 2 * math.pi * speedMult) + phase,
            );

            // Higher amplitude and more bars when speaking
            final double amplitude = isSpeaking ? 20.0 : 8.0;
            final double height = 10.0 + (val.abs() * amplitude);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 3,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.5),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _handleMicTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isConnected
              ? cta
              : _isConnecting
              ? const Color(0xff2a2a2a)
              : cardColor,
          border: Border.all(
            color: _isConnected
                ? cta.withOpacity(0.5)
                : Colors.white.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: _isConnected
              ? [
                  BoxShadow(
                    color: cta.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: _isConnecting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white38,
                ),
              )
            : Icon(
                _isConnected ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: _isConnected ? Colors.white : Colors.white54,
                size: 28,
              ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final bool showDashed = !_isConnected && !_isConnecting;
    Widget content = Container(
      key: ValueKey(_statusMessage),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: showDashed ? Colors.transparent : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: showDashed
            ? null
            : Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(
        _statusMessage.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'ndot',
          fontSize: 12,
          color: Colors.white70,
          letterSpacing: 2.0,
        ),
      ),
    );

    if (showDashed) {
      content = DashedBorder(
        color: Colors.white.withOpacity(0.2),
        radius: 24,
        dashWidth: 4,
        dashSpace: 4,
        child: content,
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: content,
    );
  }

  Widget _buildAgentStatusRow() {
    if (!_isConnected) return const SizedBox.shrink();
    return AnimatedOpacity(
      opacity: _isConnected ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          boxShadow: [
            if (_agentConnected)
              BoxShadow(
                color: const Color(0xff00C896).withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _agentConnected
                    ? const Color(0xff00C896)
                    : Colors.white24,
                boxShadow: _agentConnected
                    ? [
                        BoxShadow(
                          color: const Color(0xff00C896).withOpacity(0.6),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _agentConnected ? 'SYSTEM ACTIVE' : 'CONNECTING...',
                    style: const TextStyle(
                      fontFamily: 'ndot',
                      fontSize: 10,
                      color: Colors.white38,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _agentConnected
                        ? (_agentName ?? _agentIdentity ?? 'Redef Agent')
                        : 'Waiting for response...',
                    style: const TextStyle(
                      fontFamily: 'TTNormsPro',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (_remoteAudioTrackCount > 0) ...[
              const SizedBox(width: 8),
              _buildAudioWave(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    if (_isConnected || _isConnecting) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          SizedBox(
            height: 60,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              child: Text(
                _suggestions[_currentSuggestionIndex],
                key: ValueKey(_currentSuggestionIndex),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'TTNormsPro',
                  fontSize: 16,
                  color: textColor.withValues(alpha: 0.4),

                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: cta, size: 16),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'TTNormsPro',
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white.withOpacity(0.2),
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildAudioWave() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (i) {
            final height =
                4.0 +
                (math.sin(
                          (_waveController.value * 2 * math.pi) +
                              (i * math.pi / 3),
                        ) *
                        6)
                    .abs();
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3,
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xff00C2FF).withOpacity(0.8),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildDebugPanel() {
    if (_debugLogs.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LOG',
            style: TextStyle(
              fontFamily: 'ndot',
              fontSize: 10,
              color: Colors.white.withOpacity(0.3),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          ...(_debugLogs
              .take(5)
              .map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    line,
                    style: TextStyle(
                      fontFamily: 'TTNormsPro',
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.25),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cta.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cta.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: cta, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontFamily: 'TTNormsPro',
                fontSize: 12,
                color: cta.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.lg,
              ),
              child: Row(
                children: [const Text('REDEF AI', style: kTitleStyle)],
              ),
            ),

            // ── Main Content ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Status text
                    _buildStatusChip(),

                    const SizedBox(height: 48),

                    // Voice Orb
                    _buildOrb(),

                    const SizedBox(height: 16),

                    // Suggestions for when idle
                    _buildSuggestions(),

                    // Agent status row
                    _buildAgentStatusRow(),

                    const SizedBox(height: 40),

                    // Error
                    _buildErrorBanner(),

                    const SizedBox(height: 40),

                    // Debug logs (collapsed)
                    // _buildDebugPanel(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ── Bottom Controls ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
              decoration: BoxDecoration(
                color: scaffoldBg,
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Chat icon button - Commented for now
                  // _buildControlButton(
                  //   icon: Icons.chat_bubble_outline_rounded,
                  //   onTap: () {},
                  // ),

                  // Mic button (main CTA)
                  _buildMicButton(),

                  // Close / end button
                  _buildControlButton(
                    icon: Icons.close_rounded,
                    onTap: _isConnected
                        ? _disconnect
                        : () => Navigator.of(context).maybePop(),
                    isDestructive: _isConnected,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDestructive ? cta.withValues(alpha: 0.12) : cardColor,
          border: Border.all(
            color: isDestructive
                ? cta.withOpacity(0.3)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Icon(
          icon,
          color: isDestructive ? cta : Colors.white38,
          size: 20,
        ),
      ),
    );
  }
}
