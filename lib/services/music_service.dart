import 'package:audioplayers/audioplayers.dart';

class MusicService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play(String assetPath) async {
    if (assetPath.isEmpty) return;

    try {
      // Stop any currently playing sound first
      await _player.stop();

      // Re-set the looping mode
      await _player.setReleaseMode(ReleaseMode.loop);

      // Now play the new one
      await _player.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (e) {
      print('Error playing music: $e');
    }
  }

  static Future<void> stop() async {
    await _player.stop();
  }

  static Future<void> pause() async {
    await _player.pause();
  }
}
