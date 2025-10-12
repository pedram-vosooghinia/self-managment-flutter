import 'dart:developer' as developer;
import 'package:uuid/uuid.dart';
import '../../data/models/task_model.dart';
import '../../data/models/reminder_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../data/repositories/alarm_sound_repository.dart';

/// سرویس مدیریت تسک‌های تکراری روزانه
/// این سرویس مسئولیت ایجاد یادآورهای روزانه برای تسک‌های تکراری را دارد
class RecurringTaskService {
  final TaskRepository _taskRepository;
  final ReminderRepository _reminderRepository;
  final AlarmSoundRepository _alarmSoundRepository;

  RecurringTaskService({
    required TaskRepository taskRepository,
    required ReminderRepository reminderRepository,
    required AlarmSoundRepository alarmSoundRepository,
  }) : _taskRepository = taskRepository,
       _reminderRepository = reminderRepository,
       _alarmSoundRepository = alarmSoundRepository;

  /// زمان‌بندی یادآورهای روزانه برای تمام تسک‌های تکراری
  /// این متد باید در هنگام شروع برنامه و هر روز نیمه‌شب فراخوانی شود
  Future<void> scheduleDailyReminders() async {
    try {
      // دریافت تمام تسک‌های تکراری
      final allTasks = _taskRepository.getAllTasks();
      final recurringTasks = allTasks
          .where((task) => task.isRecurring)
          .toList();

      developer.log(
        'یافت شد ${recurringTasks.length} تسک تکراری برای زمان‌بندی',
        name: 'RecurringTaskService',
      );

      final now = DateTime.now();

      for (final task in recurringTasks) {
        if (task.recurringTime == null) continue;

        // ایجاد زمان یادآور برای امروز
        final scheduledDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          task.recurringTime!.hour,
          task.recurringTime!.minute,
        );

        // اگر زمان یادآور از زمان فعلی گذشته است، برای فردا زمان‌بندی کن
        final finalScheduledDateTime = scheduledDateTime.isBefore(now)
            ? scheduledDateTime.add(const Duration(days: 1))
            : scheduledDateTime;

        // دریافت مسیر فایل صدای آلارم
        String? alarmSoundPath;
        if (task.alarmSoundId != null) {
          final alarmSound = _alarmSoundRepository.getAlarmSoundById(
            task.alarmSoundId!,
          );
          alarmSoundPath = alarmSound?.filePath;
        }

        // بررسی اینکه آیا قبلاً یادآوری برای این تسک در این زمان ایجاد شده است
        final existingReminders = _reminderRepository.getRemindersByItemId(
          task.id,
        );
        final hasReminderForThisTime = existingReminders.any(
          (reminder) =>
              reminder.scheduledDateTime.year == finalScheduledDateTime.year &&
              reminder.scheduledDateTime.month ==
                  finalScheduledDateTime.month &&
              reminder.scheduledDateTime.day == finalScheduledDateTime.day &&
              reminder.scheduledDateTime.hour == finalScheduledDateTime.hour &&
              reminder.scheduledDateTime.minute ==
                  finalScheduledDateTime.minute,
        );

        if (!hasReminderForThisTime) {
          // ایجاد یادآور جدید
          final reminder = ReminderModel(
            id: const Uuid().v4(),
            itemId: task.id,
            type: ReminderType.task,
            scheduledDateTime: finalScheduledDateTime,
            notificationId: DateTime.now().millisecondsSinceEpoch % 100000,
            title: '🔄 یادآور تکراری: ${task.title}',
            body: task.description ?? 'وظیفه روزانه شما',
            alarmSoundPath: alarmSoundPath,
            isActive: true,
            isRecurring: true, // علامت‌گذاری به عنوان یادآور تکراری
          );

          await _reminderRepository.addReminder(reminder);

          developer.log(
            'یادآور تکراری برای "${task.title}" در ${finalScheduledDateTime.toString()} ایجاد شد',
            name: 'RecurringTaskService',
          );
        }
      }

      // پاک کردن یادآورهای تکراری گذشته (قدیمی‌تر از دیروز)
      await _cleanUpOldRecurringReminders();
    } catch (e) {
      developer.log(
        'خطا در زمان‌بندی یادآورهای تکراری: $e',
        name: 'RecurringTaskService',
        error: e,
      );
    }
  }

  /// پاک کردن یادآورهای تکراری قدیمی
  Future<void> _cleanUpOldRecurringReminders() async {
    try {
      final allReminders = _reminderRepository.getAllReminders();
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayMidnight = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
      );

      for (final reminder in allReminders) {
        // حذف یادآورهای تکراری که قدیمی‌تر از دیروز هستند
        if (reminder.isRecurring &&
            reminder.scheduledDateTime.isBefore(yesterdayMidnight)) {
          await _reminderRepository.deleteReminder(reminder.id);
          developer.log(
            'یادآور تکراری قدیمی حذف شد: ${reminder.id}',
            name: 'RecurringTaskService',
          );
        }
      }
    } catch (e) {
      developer.log(
        'خطا در پاک کردن یادآورهای قدیمی: $e',
        name: 'RecurringTaskService',
        error: e,
      );
    }
  }

  /// زمان‌بندی یادآور برای یک تسک تکراری خاص
  /// این متد زمانی استفاده می‌شود که یک تسک تکراری جدید ایجاد یا بروزرسانی می‌شود
  Future<void> scheduleReminderForTask(TaskModel task) async {
    if (!task.isRecurring || task.recurringTime == null) return;

    try {
      final now = DateTime.now();

      // ایجاد زمان یادآور برای امروز
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        task.recurringTime!.hour,
        task.recurringTime!.minute,
      );

      // اگر زمان یادآور از زمان فعلی گذشته است، برای فردا زمان‌بندی کن
      final finalScheduledDateTime = scheduledDateTime.isBefore(now)
          ? scheduledDateTime.add(const Duration(days: 1))
          : scheduledDateTime;

      // دریافت مسیر فایل صدای آلارم
      String? alarmSoundPath;
      if (task.alarmSoundId != null) {
        final alarmSound = _alarmSoundRepository.getAlarmSoundById(
          task.alarmSoundId!,
        );
        alarmSoundPath = alarmSound?.filePath;
      }

      // حذف یادآورهای قدیمی این تسک
      final existingReminders = _reminderRepository.getRemindersByItemId(
        task.id,
      );
      for (final reminder in existingReminders) {
        if (reminder.isRecurring) {
          await _reminderRepository.deleteReminder(reminder.id);
        }
      }

      // ایجاد یادآور جدید
      final reminder = ReminderModel(
        id: const Uuid().v4(),
        itemId: task.id,
        type: ReminderType.task,
        scheduledDateTime: finalScheduledDateTime,
        notificationId: DateTime.now().millisecondsSinceEpoch % 100000,
        title: '🔄 یادآور تکراری: ${task.title}',
        body: task.description ?? 'وظیفه روزانه شما',
        alarmSoundPath: alarmSoundPath,
        isActive: true,
        isRecurring: true,
      );

      await _reminderRepository.addReminder(reminder);

      developer.log(
        'یادآور تکراری برای "${task.title}" در ${finalScheduledDateTime.toString()} ایجاد شد',
        name: 'RecurringTaskService',
      );
    } catch (e) {
      developer.log(
        'خطا در زمان‌بندی یادآور برای تسک "${task.title}": $e',
        name: 'RecurringTaskService',
        error: e,
      );
    }
  }

  /// حذف تمام یادآورهای تکراری برای یک تسک
  Future<void> removeRecurringRemindersForTask(String taskId) async {
    try {
      final reminders = _reminderRepository.getRemindersByItemId(taskId);
      for (final reminder in reminders) {
        if (reminder.isRecurring) {
          await _reminderRepository.deleteReminder(reminder.id);
        }
      }
    } catch (e) {
      developer.log(
        'خطا در حذف یادآورهای تکراری برای تسک: $e',
        name: 'RecurringTaskService',
        error: e,
      );
    }
  }
}
