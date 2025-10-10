import 'package:flutter/foundation.dart';
import '../../data/models/alarm_sound_model.dart';
import '../../data/repositories/alarm_sound_repository.dart';
import 'package:uuid/uuid.dart';

class AlarmSoundProvider extends ChangeNotifier {
  final AlarmSoundRepository _repository;
  List<AlarmSoundModel> _alarmSounds = [];

  AlarmSoundProvider({required AlarmSoundRepository alarmSoundRepository})
      : _repository = alarmSoundRepository;

  List<AlarmSoundModel> get alarmSounds => _alarmSounds;

  // Load all alarm sounds
  void loadAlarmSounds() {
    _alarmSounds = _repository.getAllAlarmSounds();
    notifyListeners();
  }

  // Add new alarm sound
  Future<void> addAlarmSound({
    required String name,
    required String filePath,
    bool isSystemSound = false,
  }) async {
    final sound = AlarmSoundModel(
      id: const Uuid().v4(),
      name: name,
      filePath: filePath,
      isSystemSound: isSystemSound,
      createdAt: DateTime.now(),
    );

    await _repository.addAlarmSound(sound);
    loadAlarmSounds();
  }

  // Update alarm sound
  Future<void> updateAlarmSound(AlarmSoundModel sound) async {
    await _repository.updateAlarmSound(sound);
    loadAlarmSounds();
  }

  // Delete alarm sound
  Future<void> deleteAlarmSound(String id) async {
    await _repository.deleteAlarmSound(id);
    loadAlarmSounds();
  }

  // Get alarm sound by ID
  AlarmSoundModel? getAlarmSoundById(String id) {
    return _repository.getAlarmSoundById(id);
  }

  // Get default alarm sound
  AlarmSoundModel? getDefaultAlarmSound() {
    return _repository.getDefaultAlarmSound();
  }

  // Initialize with default system sounds if none exist
  Future<void> initializeDefaultSounds() async {
    if (!_repository.hasAlarmSounds()) {
      // Add default system sound
      await addAlarmSound(
        name: 'Default Notification',
        filePath: 'default', // Use system default
        isSystemSound: true,
      );
    }
    loadAlarmSounds();
  }
}

