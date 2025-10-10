import 'package:hive/hive.dart';

part 'alarm_sound_model.g.dart';

@HiveType(typeId: 6)
class AlarmSoundModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String filePath; // Path to the audio file

  @HiveField(3)
  bool isSystemSound; // True for system sounds, false for custom

  @HiveField(4)
  DateTime createdAt;

  AlarmSoundModel({
    required this.id,
    required this.name,
    required this.filePath,
    this.isSystemSound = false,
    required this.createdAt,
  });

  AlarmSoundModel copyWith({
    String? id,
    String? name,
    String? filePath,
    bool? isSystemSound,
    DateTime? createdAt,
  }) {
    return AlarmSoundModel(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      isSystemSound: isSystemSound ?? this.isSystemSound,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

