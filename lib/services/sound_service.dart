import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playWelcomeSound() async {
    await _playSound('welcome_sound.mp3');
  }

  static Future<void> playCongratsSound() async {
    await _playSound('congrats_sound.mp3');
  }

  static Future<void> _playSound(String fileName) async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      debugPrint('Sound error: $e');
    }
  }

  static void dispose() {
    _player.dispose();
  }
}