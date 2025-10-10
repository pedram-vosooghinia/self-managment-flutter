import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';
import '../../data/repositories/reminder_repository.dart';
import 'dart:developer' as developer;

/// Helper class for debugging alarm issues
class AlarmDebugHelper {
  static final AlarmDebugHelper _instance = AlarmDebugHelper._internal();
  factory AlarmDebugHelper() => _instance;
  AlarmDebugHelper._internal();

  final NotificationService _notificationService = NotificationService();

  /// Get all pending notifications
  Future<List<PendingNotificationRequest>> getPendingAlarms() async {
    return await _notificationService.getPendingNotifications();
  }

  /// Print debug information about all alarms
  Future<void> printAlarmDebugInfo() async {
    developer.log('=== Alarm Debug Info ===', name: 'AlarmDebug');

    // Get pending notifications
    final pendingNotifications = await getPendingAlarms();
    developer.log(
      'Total pending notifications: ${pendingNotifications.length}',
      name: 'AlarmDebug',
    );

    for (var notification in pendingNotifications) {
      developer.log(
        'ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}',
        name: 'AlarmDebug',
      );
    }

    // Get active reminders
    final reminderRepo = ReminderRepository();
    final activeReminders = reminderRepo.getActiveReminders();
    final upcomingReminders = reminderRepo.getUpcomingReminders();

    developer.log(
      'Total active reminders: ${activeReminders.length}',
      name: 'AlarmDebug',
    );
    developer.log(
      'Total upcoming reminders: ${upcomingReminders.length}',
      name: 'AlarmDebug',
    );

    for (var reminder in upcomingReminders) {
      developer.log(
        'Reminder ID: ${reminder.id}, '
        'Notification ID: ${reminder.notificationId}, '
        'Title: ${reminder.title}, '
        'Scheduled: ${reminder.scheduledDateTime}, '
        'Active: ${reminder.isActive}',
        name: 'AlarmDebug',
      );
    }

    developer.log('=== End Debug Info ===', name: 'AlarmDebug');
  }

  /// Check if a specific notification is scheduled
  Future<bool> isNotificationScheduled(int notificationId) async {
    final pendingNotifications = await getPendingAlarms();
    return pendingNotifications.any((n) => n.id == notificationId);
  }

  /// Test alarm by scheduling one for 1 minute from now
  Future<void> scheduleTestAlarm() async {
    final testTime = DateTime.now().add(const Duration(minutes: 1));
    
    await _notificationService.scheduleNotification(
      id: 99999,
      title: 'آلارم تست',
      body: 'این یک آلارم تستی است که باید در یک دقیقه دیگر فعال شود',
      scheduledDateTime: testTime,
    );

    developer.log(
      'Test alarm scheduled for: $testTime',
      name: 'AlarmDebug',
    );
  }

  /// Cancel test alarm
  Future<void> cancelTestAlarm() async {
    await _notificationService.cancelNotification(99999);
    developer.log('Test alarm cancelled', name: 'AlarmDebug');
  }

  /// Request all necessary permissions
  Future<Map<String, bool>> checkPermissions() async {
    final hasPermission = await _notificationService.requestPermissions();
    
    return {
      'notifications': hasPermission,
    };
  }
}

