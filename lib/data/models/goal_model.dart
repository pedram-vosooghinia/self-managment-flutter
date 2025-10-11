import 'package:hive/hive.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 1)
enum GoalType {
  @HiveField(0)
  shortTerm,
  @HiveField(1)
  longTerm,
}

@HiveType(typeId: 3)
class GoalModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  GoalType type;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? targetDate;

  @HiveField(8)
  DateTime? reminderDateTime;

  @HiveField(9)
  String? alarmSoundId; // ID reference to AlarmSoundModel

  GoalModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.isCompleted = false,
    required this.createdAt,
    this.targetDate,
    this.reminderDateTime,
    this.alarmSoundId,
  });

  GoalModel copyWith({
    String? id,
    String? title,
    String? description,
    GoalType? type,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? targetDate,
    DateTime? reminderDateTime,
    String? alarmSoundId,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      alarmSoundId: alarmSoundId ?? this.alarmSoundId,
    );
  }
}
