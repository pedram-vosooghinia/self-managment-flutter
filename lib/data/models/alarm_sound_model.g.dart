// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_sound_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlarmSoundModelAdapter extends TypeAdapter<AlarmSoundModel> {
  @override
  final int typeId = 6;

  @override
  AlarmSoundModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlarmSoundModel(
      id: fields[0] as String,
      name: fields[1] as String,
      filePath: fields[2] as String,
      isSystemSound: fields[3] as bool,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AlarmSoundModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.isSystemSound)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmSoundModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
