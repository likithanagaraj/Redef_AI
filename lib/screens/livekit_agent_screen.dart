import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart' as lk;

import '../constants.dart';

class LiveKitAgentScreen extends StatefulWidget {
  final String tokenUrl;
  final String livekitUrl;

  const LiveKitAgentScreen({
    Key? key,
    this.tokenUrl = 'https://redef-ai.onrender.com/token',
    this.livekitUrl = 'wss://redefai-0ymcdbve.livekit.cloud',
  }) : super(key: key);

  @override
  _LiveKitAgentScreenState createState() => _LiveKitAgentScreenState();
}

class _LiveKitAgentScreenState extends State<LiveKitAgentScreen> {
  lk.Room? _room;
  lk.EventsListener<lk.RoomEvent>? _roomListener;
  lk.LocalAudioTrack? _audioTrack;

  bool _isConnected = false;
  bool _isConnecting = false;
  bool _microphoneEnabled = false;
  bool _agentConnected = false;

  String _statusMessage = 'Disconnected';
  String? _errorMessage;
  String? _roomName;
  String? _agentIdentity;
  String? _agentName;
  int _remoteAudioTrackCount = 0;

  final List<String> _debugLogs = <String>[];

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }

  void _log(String message) {
    final line = '[${DateTime.now().toIso8601String()}] $message';
    debugPrint(line);
    if (!mounted) return;

    setState(() {
      _debugLogs.insert(0, line);
      if (_debugLogs.length > 30) {
        _debugLogs.removeRange(30, _debugLogs.length);
      }
    });
  }

  Future<String> _fetchToken() async {
    try {
      _log('Calling token API: ${widget.tokenUrl}');

      final response = await http.get(Uri.parse(widget.tokenUrl)).timeout(const Duration(seconds: 30));

      _log('Token API status: ${response.statusCode}');
      _log('Token API body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _roomName = data['room'] as String?;
        return data['token'] as String;
      }

      throw Exception('Failed to fetch token: ${response.statusCode} - ${response.body}');
    } catch (e) {
      _log('Token fetch error: $e');
      throw Exception('Error fetching token: $e');
    }
  }

  Future<void> _connect() async {
    if (_isConnecting || _isConnected) return;

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
      _statusMessage = 'Fetching token...';
      _agentConnected = false;
      _agentIdentity = null;
      _agentName = null;
      _remoteAudioTrackCount = 0;
      _debugLogs.clear();
    });

    try {
      final token = await _fetchToken();

      setState(() {
        _statusMessage = 'Connecting to LiveKit...';
      });

      final room = lk.Room(
        roomOptions: const lk.RoomOptions(
          defaultAudioOutputOptions: lk.AudioOutputOptions(speakerOn: true),
        ),
      );

      _room = room;
      room.addListener(_onRoomStateChanged);
      _roomListener = room.createListener()
        ..on<lk.ParticipantConnectedEvent>((event) async {
          _log(
            'Remote participant joined: identity=${event.participant.identity}, '
            'name=${event.participant.name}, kind=${event.participant.kind}',
          );
          _updateAgentState();
          await _subscribeToParticipantAudio(event.participant);
        })
        ..on<lk.ParticipantDisconnectedEvent>((event) {
          _log('Remote participant left: identity=${event.participant.identity}');
          _updateAgentState();
        })
        ..on<lk.TrackPublishedEvent>((event) async {
          _log(
            'Track published: participant=${event.participant.identity}, '
            'source=${event.publication.source}, kind=${event.publication.kind}, '
            'subscribed=${event.publication.subscribed}',
          );
          if (event.publication.kind == lk.TrackType.AUDIO && !event.publication.subscribed) {
            await event.publication.subscribe();
            _log('Requested subscription for audio track ${event.publication.sid}');
          }
        })
        ..on<lk.TrackSubscribedEvent>((event) {
          _log(
            'Track subscribed: participant=${event.participant.identity}, '
            'kind=${event.track.kind}, source=${event.publication.source}, sid=${event.publication.sid}',
          );
          _updateAgentState();
        })
        ..on<lk.TrackUnsubscribedEvent>((event) {
          _log(
            'Track unsubscribed: participant=${event.participant.identity}, '
            'kind=${event.track.kind}, sid=${event.publication.sid}',
          );
          _updateAgentState();
        })
        ..on<lk.TrackSubscriptionExceptionEvent>((event) {
          _log(
            'Track subscription failed: participant=${event.participant?.identity}, '
            'sid=${event.sid}, reason=${event.reason}',
          );
        })
        ..on<lk.ActiveSpeakersChangedEvent>((event) {
          final speakers = event.speakers.map((speaker) => speaker.identity).join(', ');
          _log('Active speakers changed: $speakers');
        })
        ..on<lk.AudioPlaybackStatusChanged>((event) async {
          _log('Audio playback status changed: isPlaying=${event.isPlaying}');
          if (_room != null && !_room!.canPlaybackAudio) {
            _log('Room reports audio playback is blocked; requesting startAudio()');
            await _room!.startAudio();
          }
        });

      await room.connect(
        widget.livekitUrl,
        token,
        connectOptions: const lk.ConnectOptions(autoSubscribe: true),
      );

      await room.setSpeakerOn(true);
      if (!room.canPlaybackAudio) {
        _log('Audio playback not active yet, calling startAudio()');
        await room.startAudio();
      }

      await _inspectExistingParticipants();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _statusMessage = 'Connection failed';
        _isConnecting = false;
      });
      _log('Error connecting to LiveKit: $e');
    }
  }

  void _onRoomStateChanged() {
    final room = _room;
    if (room == null) return;

    if (room.connectionState == lk.ConnectionState.connected) {
      setState(() {
        _isConnected = true;
        _statusMessage = 'Connected';
        _isConnecting = false;
      });
      _log('Room connected. Remote participants: ${room.remoteParticipants.length}');

      if (!_microphoneEnabled) {
        _microphoneEnabled = true;
        _enableMicrophone();
      }
    } else if (room.connectionState == lk.ConnectionState.disconnected) {
      setState(() {
        _isConnected = false;
        _statusMessage = 'Disconnected';
        _isConnecting = false;
        _microphoneEnabled = false;
        _agentConnected = false;
      });
      _log('Room disconnected');
    }
  }

  Future<void> _inspectExistingParticipants() async {
    final room = _room;
    if (room == null) return;

    if (room.remoteParticipants.isEmpty) {
      _log('No remote participants present immediately after connect');
      _updateAgentState();
      return;
    }

    for (final participant in room.remoteParticipants.values) {
      _log(
        'Existing remote participant: identity=${participant.identity}, '
        'name=${participant.name}, kind=${participant.kind}, '
        'audioPubs=${participant.audioTrackPublications.length}',
      );
      await _subscribeToParticipantAudio(participant);
    }

    _updateAgentState();
  }

  Future<void> _subscribeToParticipantAudio(lk.RemoteParticipant participant) async {
    if (participant.audioTrackPublications.isEmpty) {
      _log('Participant ${participant.identity} has no published audio tracks yet');
      return;
    }

    for (final publication in participant.audioTrackPublications) {
      _log(
        'Inspecting audio publication: participant=${participant.identity}, '
        'sid=${publication.sid}, subscribed=${publication.subscribed}, muted=${publication.muted}',
      );

      if (!publication.subscribed) {
        await publication.subscribe();
        _log('Requested subscription for remote audio sid=${publication.sid}');
      }
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
        .expand((participant) => participant.audioTrackPublications)
        .where((publication) => publication.subscribed && publication.track != null)
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
      if (_audioTrack != null) {
        _log('Audio track already exists');
        return;
      }

      _audioTrack = await lk.LocalAudioTrack.create();
      await _room!.localParticipant?.publishAudioTrack(_audioTrack!);
      _log('Microphone enabled and published');
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
          _statusMessage = 'Disconnected';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scaffoldBg,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isConnected ? Colors.green[100] : Colors.grey[300],
                ),
                child: Icon(
                  _isConnected ? Icons.check_circle : Icons.radio_button_off,
                  color: _isConnected ? Colors.green : Colors.grey,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _statusMessage,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isConnected ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isConnecting ? null : (_isConnected ? _disconnect : _connect),
                icon: Icon(_isConnected ? Icons.phone_disabled : Icons.phone),
                label: Text(
                  _isConnecting ? 'Connecting...' : (_isConnected ? 'Disconnect' : 'Connect to Agent'),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: _isConnected ? Colors.red : cta,
                  disabledBackgroundColor: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              _InfoCard(
                title: 'Agent Status',
                lines: [
                  'Room: ${_roomName ?? '-'}',
                  'Agent joined: ${_agentConnected ? 'Yes' : 'No'}',
                  'Agent identity: ${_agentIdentity ?? '-'}',
                  'Agent name: ${_agentName ?? '-'}',
                  'Remote audio tracks subscribed: $_remoteAudioTrackCount',
                  'Microphone published: ${_microphoneEnabled ? 'Yes' : 'No'}',
                ],
              ),
              const SizedBox(height: 16),
              _InfoCard(
                title: 'Debug Log',
                lines: _debugLogs.isEmpty ? const ['No events yet'] : _debugLogs,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[400]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Connection Error',
                        style: TextStyle(
                          color: Colors.red[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red[800],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<String> lines;

  const _InfoCard({
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
