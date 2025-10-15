// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 0;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      isCompleted: fields[3] == null ? false : fields[3] as bool, // Null check
      createdAt: fields[4] as DateTime,
      reminderDateTime: fields[6] as DateTime?,
      isRecurring: fields[8] == null ? false : fields[8] as bool, // Null check
      recurringTime: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.reminderDateTime)
      ..writeByte(7)
      ..writeByte(8)
      ..write(obj.isRecurring)
      ..writeByte(9)
      ..write(obj.recurringTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
