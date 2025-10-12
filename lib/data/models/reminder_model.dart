import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 4)
enum ReminderType {
  @HiveField(0)
  task,
  @HiveField(1)
  goal,
}

@HiveType(typeId: 5)
class ReminderModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String itemId; // Task or Goal ID

  @HiveField(2)
  ReminderType type;

  @HiveField(3)
  DateTime scheduledDateTime;

  @HiveField(4)
  String? alarmSoundPath;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  int notificationId;

  @HiveField(7)
  String title;

  @HiveField(8)
  String? body;

  @HiveField(9)
  bool isRecurring; // آیا این یادآور تکراری است؟

  ReminderModel({
    required this.id,
    required this.itemId,
    required this.type,
    required this.scheduledDateTime,
    this.alarmSoundPath,
    this.isActive = true,
    required this.notificationId,
    required this.title,
    this.body,
    this.isRecurring = false,
  });

  ReminderModel copyWith({
    String? id,
    String? itemId,
    ReminderType? type,
    DateTime? scheduledDateTime,
    String? alarmSoundPath,
    bool? isActive,
    int? notificationId,
    String? title,
    String? body,
    bool? isRecurring,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      type: type ?? this.type,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      alarmSoundPath: alarmSoundPath ?? this.alarmSoundPath,
      isActive: isActive ?? this.isActive,
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      body: body ?? this.body,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  bool get isPast {
    return scheduledDateTime.isBefore(DateTime.now());
  }

  bool get isUpcoming {
    return scheduledDateTime.isAfter(DateTime.now());
  }
}
