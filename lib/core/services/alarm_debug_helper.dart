import '../../data/repositories/reminder_repository.dart';
import 'simple_alarm_service.dart';
import 'dart:developer' as developer;

/// Helper class for debugging alarm issues
class AlarmDebugHelper {
  static final AlarmDebugHelper _instance = AlarmDebugHelper._internal();
  factory AlarmDebugHelper() => _instance;
  AlarmDebugHelper._internal();

  final SimpleAlarmService _simpleAlarmService = SimpleAlarmService();

  /// Print debug information about all alarms
  Future<void> printAlarmDebugInfo() async {
    developer.log('=== Alarm Debug Info ===', name: 'AlarmDebug');

    // Get active timers from SimpleAlarmService
    developer.log(
      'Total active timers: ${_simpleAlarmService.activeAlarmsCount}',
      name: 'AlarmDebug',
    );

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

  /// Check if a specific alarm is scheduled
  bool isAlarmScheduled(int alarmId) {
    return _simpleAlarmService.isAlarmActive(alarmId);
  }

  /// Test alarm by scheduling one for 1 minute from now
  Future<void> scheduleTestAlarm() async {
    final testTime = DateTime.now().add(const Duration(minutes: 1));

    await _simpleAlarmService.scheduleSimpleAlarm(
      id: 99999,
      title: 'آلارم تست',
      body: 'این یک آلارم تستی است که باید در یک دقیقه دیگر فعال شود',
      scheduledDateTime: testTime,
      reminderId: 'test_alarm_99999',
      soundPath: 'default', // استفاده از صدای پیش‌فرض برای تست
    );

    developer.log('Test alarm scheduled for: $testTime', name: 'AlarmDebug');
  }

  /// Cancel test alarm
  void cancelTestAlarm() {
    _simpleAlarmService.cancelAlarm(99999);
    developer.log('Test alarm cancelled', name: 'AlarmDebug');
  }

  /// Get active alarms count
  int getActiveAlarmsCount() {
    return _simpleAlarmService.activeAlarmsCount;
  }
}
