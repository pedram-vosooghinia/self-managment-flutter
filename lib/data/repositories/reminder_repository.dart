import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/reminder_model.dart';
import '../../core/services/hive_service.dart';
import '../../core/services/simple_alarm_service.dart';
import '../../core/services/notification_service.dart';

class ReminderRepository {
  late Box<ReminderModel> _box;
  final SimpleAlarmService _simpleAlarmService = SimpleAlarmService();
  final NotificationService _notificationService = NotificationService();

  ReminderRepository() {
    _box = HiveService.remindersBoxInstance;
  }

  // Create
  Future<void> addReminder(ReminderModel reminder) async {
    await _box.put(reminder.id, reminder);

    if (reminder.isActive && reminder.isUpcoming) {
      // 1. SimpleAlarmService - برای وقتی برنامه باز است (سریع‌تر)
      await _simpleAlarmService.scheduleSimpleAlarm(
        id: reminder.notificationId,
        title: reminder.title,
        body: reminder.body ?? '',
        scheduledDateTime: reminder.scheduledDateTime,
        reminderId: reminder.id,
        soundPath: reminder.alarmSoundPath,
      );

      // 2. NotificationService - برای background/closed (backup)
      await _notificationService.scheduleNotification(
        id: reminder.notificationId,
        title: reminder.title,
        body: reminder.body ?? '',
        scheduledDateTime: reminder.scheduledDateTime,
        soundPath: reminder.alarmSoundPath,
        reminderId: reminder.id,
      );
    }
  }

  // Read
  List<ReminderModel> getAllReminders() {
    return _box.values.toList();
  }

  ReminderModel? getReminderById(String id) {
    return _box.get(id);
  }

  List<ReminderModel> getRemindersByItemId(String itemId) {
    return _box.values.where((reminder) => reminder.itemId == itemId).toList();
  }

  List<ReminderModel> getActiveReminders() {
    return _box.values.where((reminder) => reminder.isActive).toList();
  }

  List<ReminderModel> getUpcomingReminders() {
    return _box.values
        .where((reminder) => reminder.isUpcoming && reminder.isActive)
        .toList();
  }

  // Update
  Future<void> updateReminder(ReminderModel reminder) async {
    await _box.put(reminder.id, reminder);

    // Cancel both
    _simpleAlarmService.cancelAlarm(reminder.notificationId);
    await _notificationService.cancelNotification(reminder.notificationId);

    if (reminder.isActive && reminder.isUpcoming) {
      await _simpleAlarmService.scheduleSimpleAlarm(
        id: reminder.notificationId,
        title: reminder.title,
        body: reminder.body ?? '',
        scheduledDateTime: reminder.scheduledDateTime,
        reminderId: reminder.id,
        soundPath: reminder.alarmSoundPath,
      );

      await _notificationService.scheduleNotification(
        id: reminder.notificationId,
        title: reminder.title,
        body: reminder.body ?? '',
        scheduledDateTime: reminder.scheduledDateTime,
        soundPath: reminder.alarmSoundPath,
        reminderId: reminder.id,
      );
    }
  }

  Future<void> toggleReminderActive(String id) async {
    final reminder = _box.get(id);
    if (reminder != null) {
      reminder.isActive = !reminder.isActive;
      await reminder.save();

      if (reminder.isActive && reminder.isUpcoming) {
        await _simpleAlarmService.scheduleSimpleAlarm(
          id: reminder.notificationId,
          title: reminder.title,
          body: reminder.body ?? '',
          scheduledDateTime: reminder.scheduledDateTime,
          reminderId: reminder.id,
          soundPath: reminder.alarmSoundPath,
        );

        await _notificationService.scheduleNotification(
          id: reminder.notificationId,
          title: reminder.title,
          body: reminder.body ?? '',
          scheduledDateTime: reminder.scheduledDateTime,
          soundPath: reminder.alarmSoundPath,
          reminderId: reminder.id,
        );
      } else {
        _simpleAlarmService.cancelAlarm(reminder.notificationId);
        await _notificationService.cancelNotification(reminder.notificationId);
      }
    }
  }

  // Delete
  Future<void> deleteReminder(String id) async {
    final reminder = _box.get(id);
    if (reminder != null) {
      _simpleAlarmService.cancelAlarm(reminder.notificationId);
      await _notificationService.cancelNotification(reminder.notificationId);
      await _box.delete(id);
    }
  }

  Future<void> deleteRemindersByItemId(String itemId) async {
    final reminders = getRemindersByItemId(itemId);
    for (var reminder in reminders) {
      await deleteReminder(reminder.id);
    }
  }

  Future<void> deleteAllReminders() async {
    _simpleAlarmService.cancelAllAlarms();
    await _notificationService.cancelAllNotifications();
    await _box.clear();
  }

  // Stream for real-time updates
  Stream<List<ReminderModel>> watchReminders() {
    return _box.watch().map((_) => getAllReminders());
  }

  // Reschedule all active upcoming reminders
  // This should be called on app startup to ensure alarms persist after device reboot
  Future<void> rescheduleAllActiveReminders() async {
    final activeReminders = getUpcomingReminders();

    for (var reminder in activeReminders) {
      try {
        // Reschedule both systems
        await _simpleAlarmService.scheduleSimpleAlarm(
          id: reminder.notificationId,
          title: reminder.title,
          body: reminder.body ?? '',
          scheduledDateTime: reminder.scheduledDateTime,
          reminderId: reminder.id,
          soundPath: reminder.alarmSoundPath,
        );

        await _notificationService.scheduleNotification(
          id: reminder.notificationId,
          title: reminder.title,
          body: reminder.body ?? '',
          scheduledDateTime: reminder.scheduledDateTime,
          soundPath: reminder.alarmSoundPath,
          reminderId: reminder.id,
        );
      } catch (e) {
        // Log error but continue with other reminders
        debugPrint('Error rescheduling reminder ${reminder.id}: $e');
      }
    }
  }
}
