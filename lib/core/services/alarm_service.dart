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
    try {
      // متوقف کردن صدای قبلی
      if (_isPlaying) {
        await stopAlarm();
      }

      if (soundPath != null && soundPath.isNotEmpty && soundPath != 'default') {
        // Play custom sound from file
        if (File(soundPath).existsSync()) {
          // Set to loop BEFORE playing
          await _audioPlayer.setReleaseMode(ReleaseMode.loop);

          await _audioPlayer.play(DeviceFileSource(soundPath));
          _isPlaying = true;

          developer.log(
            'Playing custom alarm sound: $soundPath',
            name: 'AlarmService',
          );
        } else {
          developer.log(
            'Sound file not found: $soundPath - alarm will be silent',
            name: 'AlarmService',
          );
        }
      } else {
        developer.log(
          'Default sound selected - alarm will be silent (no sound file configured)',
          name: 'AlarmService',
        );
      }
    } catch (e) {
      developer.log('Error playing alarm sound: $e', name: 'AlarmService');
      // در صورت خطا، صفحه را نمایش می‌دهیم ولی بدون صدا
    }
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
