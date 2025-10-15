import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;


  @HiveField(2)
  final bool isCompleted;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime? reminderDateTime;

  @HiveField(5)
  final bool isRecurring;

  @HiveField(6)
  final DateTime? recurringTime;

  TaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    this.reminderDateTime,
    this.isRecurring = false,
    this.recurringTime,
  }) : assert(
          isRecurring ? reminderDateTime == null : true,
          'تسک تکراری نباید reminderDateTime داشته باشد.',
        );

  TaskModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? reminderDateTime,
    bool? isRecurring,
    DateTime? recurringTime,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringTime: recurringTime ?? this.recurringTime,
    );
  }

  /// یادآوری امروز دارد؟
  bool get hasReminderToday {
    if (reminderDateTime == null) return false;
    final now = DateTime.now();
    return reminderDateTime!.year == now.year &&
        reminderDateTime!.month == now.month &&
        reminderDateTime!.day == now.day;
  }

  /// یادآوری در آینده دارد؟
  bool get hasUpcomingReminder {
    if (reminderDateTime == null) return false;
    return reminderDateTime!.isAfter(DateTime.now());
  }

  /// یادآوری عقب‌افتاده دارد؟
  bool get hasOverdueReminder {
    if (reminderDateTime == null) return false;
    return reminderDateTime!.isBefore(DateTime.now()) && !isCompleted;
  }

  /// آیا تنظیمات این تسک معتبر است؟
  bool get isValid {
    if (title.trim().isEmpty) return false;
    if (isRecurring && recurringTime == null) return false;
    if (!isRecurring && reminderDateTime == null) return false;
    return true;
  }
}
