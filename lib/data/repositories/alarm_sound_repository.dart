import 'package:hive/hive.dart';
import '../../core/services/hive_service.dart';
import '../models/alarm_sound_model.dart';

class AlarmSoundRepository {
  Box<AlarmSoundModel> get _box => HiveService.alarmSoundsBoxInstance;

  // Get all alarm sounds
  List<AlarmSoundModel> getAllAlarmSounds() {
    return _box.values.toList();
  }

  // Get alarm sound by ID
  AlarmSoundModel? getAlarmSoundById(String id) {
    try {
      return _box.values.firstWhere((sound) => sound.id == id);
    } catch (e) {
      // Return null if sound not found
      return null;
    }
  }

  // Add new alarm sound
  Future<void> addAlarmSound(AlarmSoundModel sound) async {
    await _box.put(sound.id, sound);
  }

  // Update alarm sound
  Future<void> updateAlarmSound(AlarmSoundModel sound) async {
    await _box.put(sound.id, sound);
  }

  // Delete alarm sound
  Future<void> deleteAlarmSound(String id) async {
    await _box.delete(id);
  }

  // Delete all alarm sounds
  Future<void> deleteAllAlarmSounds() async {
    await _box.clear();
  }

  // Check if any alarm sounds exist
  bool hasAlarmSounds() {
    return _box.isNotEmpty;
  }

  // Get default alarm sound
  AlarmSoundModel? getDefaultAlarmSound() {
    final sounds = getAllAlarmSounds();
    if (sounds.isEmpty) return null;
    // Return first system sound, or first sound if no system sounds
    final systemSound = sounds.firstWhere(
      (sound) => sound.isSystemSound,
      orElse: () => sounds.first,
    );
    return systemSound;
  }
}

