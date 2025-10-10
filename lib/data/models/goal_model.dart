import 'package:hive/hive.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 1)
enum GoalType {
  @HiveField(0)
  shortTerm,
  @HiveField(1)
  longTerm,
}

@HiveType(typeId: 2)
class SubTask {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
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

  @HiveField(4)
  List<SubTask> subTasks;

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

  @HiveField(10)
  String? notes;

  GoalModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    List<SubTask>? subTasks,
    this.isCompleted = false,
    required this.createdAt,
    this.targetDate,
    this.reminderDateTime,
    this.alarmSoundId,
    this.notes,
  }) : subTasks = subTasks ?? [];

  GoalModel copyWith({
    String? id,
    String? title,
    String? description,
    GoalType? type,
    List<SubTask>? subTasks,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? targetDate,
    DateTime? reminderDateTime,
    String? alarmSoundId,
    String? notes,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      subTasks: subTasks ?? this.subTasks,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      alarmSoundId: alarmSoundId ?? this.alarmSoundId,
      notes: notes ?? this.notes,
    );
  }

  double get progress {
    if (subTasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completedCount = subTasks.where((task) => task.isCompleted).length;
    return completedCount / subTasks.length;
  }

  int get completedSubTasksCount {
    return subTasks.where((task) => task.isCompleted).length;
  }
}

