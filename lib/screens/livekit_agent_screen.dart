import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class LiveKitAgentScreen extends StatefulWidget {
  final String tokenUrl;
  final String livekitUrl;

  const LiveKitAgentScreen({
    Key? key,
    this.tokenUrl = 'http://192.168.1.10:8000/token',
    this.livekitUrl = 'wss://redefai-0ymcdbve.livekit.cloud',
  }) : super(key: key);

  @override
  _LiveKitAgentScreenState createState() => _LiveKitAgentScreenState();
}

class _LiveKitAgentScreenState extends State<LiveKitAgentScreen> {
  lk.Room? _room;
  bool _isConnected = false;
  bool _isConnecting = false;
  String _statusMessage = 'Disconnected';
  String? _errorMessage;
  lk.LocalAudioTrack? _audioTrack;

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }

Future<String> _fetchToken() async {
  try {
    print("Calling token API: ${widget.tokenUrl}");

    final response = await http
        .get(Uri.parse(widget.tokenUrl))
        .timeout(const Duration(seconds: 10));

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'] as String;
    } else {
      throw Exception(
          'Failed to fetch token: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print("Token fetch error: $e");
    throw Exception('Error fetching token: $e');
  }
}

  // Future<String> _fetchToken() async {
  //   try {
  //     final response = await http
  //         .get(Uri.parse(widget.tokenUrl))
  //         .timeout(const Duration(seconds: 10));

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       return data['token'] as String;
  //     } else {
  //       throw Exception(
  //           'Failed to fetch token: ${response.statusCode} - ${response.body}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error fetching token: $e');
  //   }
  // }

  Future<void> _connect() async {
    if (_isConnecting || _isConnected) return;

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
      _statusMessage = 'Fetching token...';
    });

    try {
      // Fetch token from backend
      final token = await _fetchToken();

      setState(() {
        _statusMessage = 'Connecting to LiveKit...';
      });

      // Create room
      _room = lk.Room();

      // Listen to connection state changes
      _room!.addListener(() {
        setState(() {
          if (_room!.connectionState ==
              lk.ConnectionState.connected) {
            _isConnected = true;
            _statusMessage = 'Connected';
            _isConnecting = false;
            _enableMicrophone();
          } else if (_room!.connectionState ==
              lk.ConnectionState.disconnected) {
            _isConnected = false;
            _statusMessage = 'Disconnected';
            _isConnecting = false;
          }
        });
      });

      // Connect to LiveKit
      await _room!.connect(widget.livekitUrl, token);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _statusMessage = 'Connection failed';
        _isConnecting = false;
      });
      print('Error connecting to LiveKit: $e');
    }
  }

  Future<void> _enableMicrophone() async {
    try {
      // Create and publish local audio track
      _audioTrack = await lk.LocalAudioTrack.create();
      await _room!.localParticipant?.publishAudioTrack(_audioTrack!);
      print('Microphone enabled');
    } catch (e) {
      print('Error enabling microphone: $e');
      // Non-fatal error, app can work without mic
    }
  }

  Future<void> _disconnect() async {
    try {
      if (_audioTrack != null) {
        await _audioTrack!.dispose();
        _audioTrack = null;
      }

      if (_room != null) {
        await _room!.disconnect();
        _room = null;
      }

      setState(() {
        _isConnected = false;
        _statusMessage = 'Disconnected';
      });
    } catch (e) {
      print('Error disconnecting: $e');
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
              // Status Indicator
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

              // Status Text
              Text(
                _statusMessage,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isConnected ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // Connection/Disconnection Button
              ElevatedButton.icon(
                onPressed: _isConnecting ? null : (_isConnected ? _disconnect : _connect),
                icon: Icon(_isConnected ? Icons.phone_disabled : Icons.phone),
                label: Text(_isConnecting
                    ? 'Connecting...'
                    : (_isConnected ? 'Disconnect' : 'Connect to Agent')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: _isConnected ? Colors.red : cta,
                  disabledBackgroundColor: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null)
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
          ),
        ),
      ),
    );
  }
}
