import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'dart:developer' as developer;

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  Future<void> playAlarm(String? soundPath) async {
    if (_isPlaying) {
      await stopAlarm();
    }

    try {
      if (soundPath != null && soundPath.isNotEmpty) {
        // Play custom sound from file
        if (File(soundPath).existsSync()) {
          await _audioPlayer.play(DeviceFileSource(soundPath));
        } else {
          // Fallback to default sound
          await _playDefaultAlarm();
        }
      } else {
        // Play default alarm sound
        await _playDefaultAlarm();
      }

      _isPlaying = true;

      // Set to loop
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      developer.log('Error playing alarm: $e', name: 'AlarmService');
      await _playDefaultAlarm();
    }
  }

  Future<void> _playDefaultAlarm() async {
    // Play a default notification sound
    // You'll need to add a default alarm sound to assets
    await _audioPlayer.play(AssetSource('sounds/default_alarm.mp3'));
  }

  Future<void> stopAlarm() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  Future<void> snoozeAlarm(int minutes) async {
    await stopAlarm();
    // Return snooze duration for rescheduling
  }

  bool get isPlaying => _isPlaying;

  void dispose() {
    _audioPlayer.dispose();
  }
}
