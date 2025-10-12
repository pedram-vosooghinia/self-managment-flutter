import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(6)
  DateTime? reminderDateTime;

  @HiveField(7)
  String? alarmSoundId; // ID reference to AlarmSoundModel

  @HiveField(8)
  bool isRecurring; // آیا این تسک روزانه تکرار می‌شود؟

  @HiveField(9)
  DateTime? recurringTime; // ساعت تکرار روزانه (فقط ساعت و دقیقه مهم است)

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.reminderDateTime,
    this.alarmSoundId,
    this.isRecurring = false,
    this.recurringTime,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? reminderDateTime,
    String? alarmSoundId,
    bool? isRecurring,
    DateTime? recurringTime,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      alarmSoundId: alarmSoundId ?? this.alarmSoundId,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringTime: recurringTime ?? this.recurringTime,
    );
  }

  bool get hasReminderToday {
    if (reminderDateTime == null) return false;
    final now = DateTime.now();
    return reminderDateTime!.year == now.year &&
        reminderDateTime!.month == now.month &&
        reminderDateTime!.day == now.day;
  }

  bool get hasUpcomingReminder {
    if (reminderDateTime == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDate = DateTime(
      reminderDateTime!.year,
      reminderDateTime!.month,
      reminderDateTime!.day,
    );
    return reminderDate.isAfter(today);
  }

  bool get hasOverdueReminder {
    if (reminderDateTime == null) return false;
    return reminderDateTime!.isBefore(DateTime.now()) && !isCompleted;
  }
}
